# 自旋锁

> 自旋锁，为啥叫自旋，是因为它使用while循环在不断判断条件是否为真，为真则跳出循环，也就是解锁。它是在多处理器以后提出来的一个概念，因为自旋锁实际上在做忙等待，这是不符合临界区使用原则的，但是多处理器出来后，忙等待变得可以接受了，因为有多个处理器。
自旋锁通俗的说就是忙等待。通过CPU提供的CAS(Compare and Swap)实现。
CAS (Compare And Swap)技术用于鉴别线程冲突，一旦检测到冲突产生，就重试当前操作直到没有冲突为止。

自旋锁不会主动进行线程的上下文切换，所以相比于互斥锁，会更快并且开销小。其加锁有两个步骤：查看锁的状态，如果空闲则进入下一步。将锁设置为当前线程持有。在CAS中，这两步骤属于一条原子指令，保证两个步骤正确执行。自旋锁在加锁失败后会进入忙等待，直到拿到锁。注意在单核CPU下，自旋锁无法使用，自选锁的线程永远不会释放CPU资源，导致无法执行。

互斥锁加锁失败后，线程会释放 CPU，给其他线程；
自旋锁加锁失败后，线程会忙等待，直到它拿到锁；

当两个线程是属于同一个进程，因为虚拟内存是共享的，所以在切换时，虚拟内存中的资源保持不动，只需要保存切换线程的私有数据、寄存器等不共享的数据。上下文切换大概需要几十纳秒到几微秒的时间。
由此，如果临界区代码执行时间较短，使用互斥锁的开销会很大，可以选择自旋锁。

自旋锁的系统开销小，不会主动产生线程切换。适合异步，协程等在用户态切换请求的编程。自旋锁的时间和临界区的代码成正比。
作者：西瓜学习
链接：https://www.zhihu.com/question/66733477/answer/1567439188
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。