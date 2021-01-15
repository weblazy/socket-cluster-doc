# 重入锁
> 如果在本次操作锁释放之前需要再次使用锁的话,为了减少锁的切换，减少上下文切换，可以用重入锁，合并锁操作。使用重入锁之后可以防止其他线程在两次锁操作之间抢占锁
```
package main

import (
	"fmt"
	"github.com/petermattis/goid"
	"sync"
	"sync/atomic"
)

//重入锁结构体
type ReentryMutex struct {
	 sync.Mutex
	owner int64 //当前锁持有者(go routine id)
	reentry int32 //重入次数
}


//重入锁加锁
func (m *ReentryMutex) Lock() {
	//获取当前go id
	gid := goid.Get()
	//如果当前持有锁的go routine就是调用者,重入次数+1
	if atomic.LoadInt64(&m.owner) == gid {
		m.reentry++
		return
	}

	m.Mutex.Lock()
	//第一次调用,记录锁的所属者
	atomic.StoreInt64(&m.owner,gid)
	//初始化重入次数
	m.reentry =1
}

func (m *ReentryMutex) Unlock() {
	gid := goid.Get()

	//解锁的人不是当前锁持有者直接panic
	if atomic.LoadInt64(&m.owner) != gid{
		panic(fmt.Sprintf("wrong the owner(%d): %d!",m.owner,gid))
	}

	//调用次数减一
	m.reentry--
	if m.reentry != 0{
		return
	}

	//最后一次调用需要释放锁
	atomic.StoreInt64(&m.owner,-1)
	m.Mutex.Unlock()

}
```