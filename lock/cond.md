# 条件锁

> 条件变量的作用并不是保证在同一时刻仅有一个线程访问某一个共享数据，而是在对应的共享数据的状态发生变化时，通知其他因此而被阻塞的线程。

- 初始化一个条件锁
```
func NewCond(l Locker) *Cond
```
- 等待通知: 阻塞当前线程，直到收到该条件变量发来的通知
```
func (c *Cond) Wait() 
```

- 单发通知: 让该条件变量向一个正在等待它的通知的线程发送通知，表示共享数据的状态已经改变。
```
func (c *Cond) Signal() 
```
- 广播通知: 让条件变量给正在等待它的通知的所有线程都发送通知。
```
func (c *Cond) Broadcast()
```


todo如图(后面补上):
如下案例,感觉像是实现了一个channel的功能
```
package main

import (
	"container/list"
	"fmt"
	"math/rand"
	"sync"
	"time"
)

var (
	cond  sync.Cond    // 条件变量
	queue = list.New() // 使用链表实现的队列池
)

func producer(idx int) {
	for {
		// 先加锁
		cond.L.Lock()
		// 判断缓冲区是否满,缓冲区已满时阻塞等待消费者消费数据
		for queue.Len() == 3 {
			cond.Wait()
		}
		// 生产数据
		num := rand.Intn(1000)
		queue.PushBack(num)
		fmt.Printf("第%d个生产者, 生产: %d\n", idx, num)
		// 访问公共区结束, 并且打印结束,解锁
		cond.L.Unlock()
		// 唤醒阻塞在条件变量上的消费者
		cond.Signal()

	}
}

func consumer(idx int) {
	for {
		// 先加锁
		cond.L.Lock()
		// 判断缓冲区是否为空,缓冲区为空时阻塞等待生产者添加数据
		for queue.Len() == 0 {
			cond.Wait()
		}
		// 消费数据
		num := queue.Front()
		queue.Remove(num)
		fmt.Printf("---第%d个消费者, 消费: %d\n", idx, num.Value)
		// 访问公共区结束后,解锁
		cond.L.Unlock()
		// 唤醒阻塞在条件变量上的生产者
		cond.Signal()
	}
}

func main() {
	// 设置随机种子数
	rand.Seed(time.Now().UnixNano())
	cond.L = new(sync.Mutex)
	// 创建5个生产者
	for i := 0; i < 5; i++ {
		go producer(i + 1)
	}
	//创建5个消费者
	for i := 0; i < 5; i++ {
		go consumer(i + 1)
	}
	time.Sleep(time.Second * 1)
}

```