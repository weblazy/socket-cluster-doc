# 读写锁
> 读的时候可以多个协程同时读，写的时候只能一个协程写

综上，写锁是独占锁，任何时刻只能有一个线程拥有。而读锁是共享锁，读锁可以被多个线程拥有。同时，读写锁可以分为读优先锁和写优先锁。读优先即锁优先服务读操作，当某一写线程被阻塞，之后又有若干读线程，会优先使得后面的读线程获得读锁，写线程一直阻塞到读锁释放。写优先锁优先服务写操作，当某一写线程请求资源，之后又有若干读线程，只要之前的读锁释放，写线程立刻获得写锁进行操作，之后的读线程会被阻塞。可以发现，读优先锁对读线程的并发性更好。但可能导致写线程的饥饿现象。而相应的，写优先锁可能导致读线程饥饿。故需要一种公平读写锁：用队列把获取锁的线程排队，无论是写线程还是读线程都按照先进先出的原则加锁。

作者：西瓜学习
链接：https://www.zhihu.com/question/66733477/answer/1567439188
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

- 锁住读锁(此时别的goroutine可以同时读,但是不能写。)
```
func (rw *RWMutex) RLock()
```
- 解除读锁
```
func (rw *RWMutex) RUnlock()
```
- 锁住写锁(此时其他goroutine既不能写,也不能读)
```
func (rw *RWMutex) Lock()
```
- 解除写锁
```
func (rw *RWMutex) Unlock()
```

如下案例，读写锁实现的并发安全的map，可以并发读，同步写。比互斥锁效率更高。(原生map delete一个key之后不会压缩底层数组有内存泄露问题)todo配图

```
package syncx

import (
	"sync"
)

// RwMap concurrent secure data storage,
// which is high-performance mapping under low concurrency conditions.
type RwMap struct {
	data map[interface{}]interface{}
	rwmu sync.RWMutex
}

// RwMap creates a new concurrent safe map with sync.RWMutex.
// The normal Map is high-performance mapping under low concurrency conditions.
func NewRwMap(capacity ...int) *RwMap {
	var cap int
	if len(capacity) > 0 {
		cap = capacity[0]
	}
	return &RwMap{
		data: make(map[interface{}]interface{}, cap),
	}
}

// Load returns the value stored in the map for a key, or nil if no
// value is present.
// The ok result indicates whether value was found in the map.
func (m *RwMap) Load(key interface{}) (value interface{}, ok bool) {
	m.rwmu.RLock()
	value, ok = m.data[key]
	m.rwmu.RUnlock()
	return value, ok
}

// Store sets the value for a key.
func (m *RwMap) Store(key, value interface{}) {
	m.rwmu.Lock()
	m.data[key] = value
	m.rwmu.Unlock()
}

// LoadOrStore returns the existing value for the key if present.
// Otherwise, it stores and returns the given value.
// The loaded result is true if the value was loaded, false if stored.
func (m *RwMap) LoadOrStore(key, value interface{}) (actual interface{}, loaded bool) {
	m.rwmu.Lock()
	actual, loaded = m.data[key]
	if !loaded {
		m.data[key] = value
		actual = value
	}
	m.rwmu.Unlock()
	return actual, loaded
}

// Delete deletes the value for a key.
func (m *RwMap) Delete(key interface{}) {
	m.rwmu.Lock()
	delete(m.data, key)
	m.rwmu.Unlock()
}

// Range calls f sequentially for each key and value present in the map.
// If f returns false, range stops the iteration.
func (m *RwMap) Range(f func(key, value interface{}) bool) bool {
	m.rwmu.RLock()
	defer m.rwmu.RUnlock()
	for k, v := range m.data {
		if !f(k, v) {
			return false
		}
	}
	return true
}

// Clear clears all current data in the map.
func (m *RwMap) Clear() {
	m.rwmu.Lock()
	for k := range m.data {
		delete(m.data, k)
	}
	m.rwmu.Unlock()
}

// Len returns the length of the map.
// Note: the count is accurate.
func (m *RwMap) Len() int {
	m.rwmu.RLock()
	defer m.rwmu.RUnlock()
	return len(m.data)
}
```