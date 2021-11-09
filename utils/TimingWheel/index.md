# TimingWheel

时间轮算法可以高性能的实现定时任务功能,客户端连接在一定时间内没有认证的话就会被服务器主动端口,避免服务器资源连接被占用,也可以通过它实现一个有过期时间的本地内存缓存功能.
![scheme 1](https://nos.netease.com/cloud-website-bucket/201807171109599678a80c-075a-40ee-b25f-10fd82c1025c.jpg)

如图由一个数组实现一个循环队列,一个数组元素就是一个链表,链表里面每一个节点存储的就是一个一个的定时任务,定时任务里面存储着自己所在的position位置和在哪一层level,每次时间轮跑完一圈里面的任务,level就会level--,当遇到level等于0的任务就即刻执行
```
package timingwheel

import (
	"container/list"
	"fmt"
	"time"

	"github.com/weblazy/easy/utils/threading"
	"github.com/weblazy/easy/utils/timex"
)

const (
	maxDeleteCount = 10000
)

type (
	Execute     func(key, value interface{})
	TimingWheel struct {
		interval      time.Duration
		ticker        timex.Ticker
		slots         []*list.List
		timers        map[interface{}]*positionsEntry
		tickedPos     int
		numSlots      int
		execute       Execute
		setChannel    chan timingEntry
		moveChannel   chan baseEntry
		removeChannel chan interface{}
		stopChannel   chan struct{}
		deleteCount   uint32
	}
	timingEntry struct {
		baseEntry
		value   interface{}
		circle  int
		diff    int
		removed bool
	}
	baseEntry struct {
		delay time.Duration
		key   interface{}
	}
	positionsEntry struct {
		pos  int
		item *timingEntry
	}
	timingTask struct {
		key   interface{}
		value interface{}
	}
)

func NewTimingWheel(interval time.Duration, numSlots int, execute Execute) (*TimingWheel, error) {
	if interval <= 0 || numSlots <= 0 || execute == nil {
		return nil, fmt.Errorf("interval: %v, slots: %d, execute: %p", interval, numSlots, execute)
	}
	return newTimingWheelWithClock(interval, numSlots, execute, timex.NewRealTicker(interval))
}

func newTimingWheelWithClock(interval time.Duration, numSlots int, execute Execute, ticker timex.Ticker) (*TimingWheel, error) {
	tw := &TimingWheel{
		interval:      interval,
		ticker:        ticker,
		slots:         make([]*list.List, numSlots),
		timers:        make(map[interface{}]*positionsEntry),
		tickedPos:     -1,
		execute:       execute,
		numSlots:      numSlots,
		setChannel:    make(chan timingEntry),
		moveChannel:   make(chan baseEntry),
		removeChannel: make(chan interface{}),
		stopChannel:   make(chan struct{}),
	}
	tw.initSlots()
	go tw.run()
	return tw, nil
}

func (tw *TimingWheel) initSlots() {
	for i := 0; i < tw.numSlots; i++ {
		tw.slots[i] = list.New()
	}
}

func (tw *TimingWheel) run() {
	for {
		select {
		case <-tw.ticker.Chan():
			tw.onTick()
		case task := <-tw.setChannel:
			tw.setTask(&task)
		case key := <-tw.removeChannel:
			tw.removeTask(key)
		case task := <-tw.moveChannel:
			tw.moveTask(task)
		case <-tw.stopChannel:
			tw.ticker.Stop()
			return
		}
	}
}

func (tw *TimingWheel) onTick() {
	tw.tickedPos = (tw.tickedPos + 1) % tw.numSlots
	l := tw.slots[tw.tickedPos]
	tw.scanAndRunTasks(l)
}

func (tw *TimingWheel) scanAndRunTasks(l *list.List) {
	var tasks []timingTask
	for e := l.Front(); e != nil; {
		task := e.Value.(*timingEntry)
		if task.removed {
			next := e.Next()
			l.Remove(e)
			tw.delete(task.key)
			e = next
			continue
		} else if task.circle > 0 {
			task.circle--
			e = e.Next()
			continue
		} else if task.diff > 0 {
			next := e.Next()
			l.Remove(e)
			pos := (tw.tickedPos + task.diff) % tw.numSlots
			tw.slots[pos].PushBack(task)
			tw.setTimerPosition(pos, task)
			task.diff = 0
			e = next
			continue
		}
		tasks = append(tasks, timingTask{
			key:   task.key,
			value: task.value,
		})
		next := e.Next()
		l.Remove(e)
		tw.delete(task.key)
		e = next
	}
	tw.runTasks(tasks)
}

func (tw *TimingWheel) runTasks(tasks []timingTask) {
	if len(tasks) == 0 {
		return
	}
	go func() {
		for i := range tasks {
			threading.RunSafe(func() {
				tw.execute(tasks[i].key, tasks[i].value)
			})
		}
	}()
}

func (tw *TimingWheel) setTimerPosition(pos int, task *timingEntry) {
	if timer, ok := tw.timers[task.key]; ok {
		timer.pos = pos
	} else {
		tw.timers[task.key] = &positionsEntry{
			pos:  pos,
			item: task,
		}
	}
}

func (tw *TimingWheel) setTask(task *timingEntry) {
	if task.delay < tw.interval {
		task.delay = tw.interval
	}
	if entry, ok := tw.timers[task.key]; ok {
		entry.item.value = task.value
		tw.moveTask(task.baseEntry)
	} else {
		pos, circle := tw.getPositionAndCircle(task.delay)
		task.circle = circle
		tw.slots[pos].PushBack(task)
		tw.setTimerPosition(pos, task)
	}
}

func (tw *TimingWheel) getPositionAndCircle(d time.Duration) (pos int, circle int) {
	delay := int(d / tw.interval)
	pos = (tw.tickedPos + delay) % tw.numSlots
	circle = delay / tw.numSlots
	return pos, circle
}

func (tw *TimingWheel) moveTask(task baseEntry) {
	timer, ok := tw.timers[task.key]
	if !ok {
		return
	}
	if task.delay < tw.interval {
		threading.GoSafe(func() {
			tw.execute(timer.item.key, timer.item.value)
		})
	}
	pos, circle := tw.getPositionAndCircle(task.delay)
	item := timer.item
	oldSetps := (tw.numSlots + timer.pos - tw.tickedPos) % tw.numSlots
	newSetps := (tw.numSlots + pos - tw.tickedPos) % tw.numSlots
	if newSetps < oldSetps {
		if circle > 0 {
			item.circle = circle - 1
			item.diff = (tw.numSlots + pos - timer.pos) % tw.numSlots

		} else {
			item.removed = true
			newItem := &timingEntry{
				baseEntry: task,
				value:     item.value,
			}
			tw.slots[pos].PushBack(newItem)
			tw.setTimerPosition(pos, newItem)
		}
	} else {
		item.circle = circle
		item.diff = (tw.numSlots + pos - timer.pos) % tw.numSlots
	}
}

func (tw *TimingWheel) removeTask(key interface{}) {
	timer, ok := tw.timers[key]
	if !ok {
		return
	}
	timer.item.removed = true
}

func (tw *TimingWheel) MoveTimer(key interface{}, delay time.Duration) {
	if delay <= 0 || key == nil {
		return
	}
	tw.moveChannel <- baseEntry{
		delay: delay,
		key:   key,
	}
}

func (tw *TimingWheel) RemoveTimer(key interface{}) {
	if key == nil {
		return
	}
	tw.removeChannel <- key
}

func (tw *TimingWheel) SetTimer(key, value interface{}, delay time.Duration) {
	if delay <= 0 || key == nil {
		return
	}
	tw.setChannel <- timingEntry{
		baseEntry: baseEntry{
			delay: delay,
			key:   key,
		},
		value: value,
	}
}

func (tw *TimingWheel) Stop() {
	close(tw.stopChannel)
}

func (tw *TimingWheel) delete(key interface{}) {
	if _, ok := tw.timers[key]; ok {
		delete(tw.timers, key)
		tw.deleteCount++
		if tw.deleteCount > maxDeleteCount {
			timers := make(map[interface{}]*positionsEntry)
			for k1 := range tw.timers {
				timers[k1] = tw.timers[k1]
			}
			tw.timers = timers
			tw.deleteCount = 0
		}
	}

}
```

- 时间轮优化方案
![scheme 1](pic/timingwhile.png)
```
package main

import (
	"fmt"
	"sync"
	"time"

	"github.com/tal-tech/go-zero/core/collection"
	"github.com/weblazy/easy/utils/list"
	"github.com/weblazy/easy/utils/threading"
	"github.com/weblazy/easy/utils/timex"
)

const (
	drainWorkers           = 8
	defaultMaxGoroutineNum = 16
)

type (
	// Execute defines the method to execute the task.
	Execute func(key, value interface{})

	// A TimingWheel is a timing wheel object to schedule tasks.
	TimingWheel struct {
		interval      time.Duration
		ticker        timex.Ticker
		slots         []map[int]*list.List
		timers        *collection.SafeMap
		tickedPos     int
		numSlots      int
		execute       Execute
		setChannel    chan timingEntry
		moveChannel   chan baseEntry
		removeChannel chan interface{}
		drainChannel  chan func(key, value interface{})
		stopChannel   chan struct{}

		cacheList       *list.List
		taskList        *list.List
		locked          bool
		lockCh          chan bool
		lock            sync.Mutex
		maxGoroutineNum int
		goroutineNum    int
		taskCh          chan *list.Element
	}

	timingEntry struct {
		baseEntry
		value  interface{}
		circle int
	}

	baseEntry struct {
		delay time.Duration
		key   interface{}
	}

	positionEntry struct {
		pos  int
		item *list.Element // item.Value ->  *timingEntry
	}

	timingTask struct {
		key   interface{}
		value interface{}
	}
)

// NewTimingWheel returns a TimingWheel.
func NewTimingWheel(interval time.Duration, numSlots int, execute Execute) (*TimingWheel, error) {
	if interval <= 0 || numSlots <= 0 || execute == nil {
		return nil, fmt.Errorf("interval: %v, slots: %d, execute: %p", interval, numSlots, execute)
	}

	return newTimingWheelWithClock(interval, numSlots, execute, timex.NewRealTicker(interval))
}

func newTimingWheelWithClock(interval time.Duration, numSlots int, execute Execute, ticker timex.Ticker) (
	*TimingWheel, error) {
	tw := &TimingWheel{
		interval:      interval,
		ticker:        ticker,
		slots:         make([]map[int]*list.List, numSlots),
		timers:        collection.NewSafeMap(),
		tickedPos:     numSlots - 1, // at previous virtual circle
		execute:       execute,
		numSlots:      numSlots,
		setChannel:    make(chan timingEntry),
		moveChannel:   make(chan baseEntry),
		removeChannel: make(chan interface{}),
		drainChannel:  make(chan func(key, value interface{})),
		stopChannel:   make(chan struct{}),

		cacheList:       list.New(),
		taskList:        list.New(),
		locked:          true,
		lockCh:          make(chan bool),
		taskCh:          make(chan *list.Element),
		maxGoroutineNum: defaultMaxGoroutineNum,
	}

	tw.initSlots()
	go tw.runTasks()
	go tw.run()

	return tw, nil
}

// Drain drains all items and executes them.
func (tw *TimingWheel) Drain(fn func(key, value interface{})) {
	tw.drainChannel <- fn
}

// MoveTimer moves the task with the given key to the given delay.
func (tw *TimingWheel) MoveTimer(key interface{}, delay time.Duration) {
	if delay <= 0 || key == nil {
		return
	}

	tw.moveChannel <- baseEntry{
		delay: delay,
		key:   key,
	}
}

// RemoveTimer removes the task with the given key.
func (tw *TimingWheel) RemoveTimer(key interface{}) {
	if key == nil {
		return
	}

	tw.removeChannel <- key
}

// SetTimer sets the task value with the given key to the delay.
func (tw *TimingWheel) SetTimer(key, value interface{}, delay time.Duration) {
	if delay <= 0 || key == nil {
		return
	}

	tw.setChannel <- timingEntry{
		baseEntry: baseEntry{
			delay: delay,
			key:   key,
		},
		value: value,
	}
}

// Stop stops tw.
func (tw *TimingWheel) Stop() {
	close(tw.stopChannel)
}

func (tw *TimingWheel) drainAll(fn func(key, value interface{})) {
	runner := threading.NewTaskRunner(drainWorkers)
	for k := range tw.slots {
		for k1 := range tw.slots[k] {
			slot := tw.slots[k][k1]
			for e := slot.Front(); e != nil; {
				task := e.Value.(*timingEntry)
				slot.Remove(e)
				e = slot.Front()
				runner.Schedule(func() {
					fn(task.key, task.value)
				})
			}
		}
		tw.slots[k] = make(map[int]*list.List)
	}
}

func (tw *TimingWheel) getPositionAndCircle(d time.Duration) (pos, circle int) {
	steps := int(d / tw.interval)
	pos = (tw.tickedPos + steps) % tw.numSlots
	circle = (steps - 1) / tw.numSlots
	return
}

func (tw *TimingWheel) initSlots() {
	for i := 0; i < tw.numSlots; i++ {
		tw.slots[i] = make(map[int]*list.List)
	}
}

func (tw *TimingWheel) moveTask(task baseEntry) {
	val, ok := tw.timers.Get(task.key)
	if !ok {
		return
	}

	timer := val.(*positionEntry)
	item := timer.item.Value.(*timingEntry)
	// immediate execution
	if task.delay < tw.interval {
		threading.GoSafe(func() {
			tw.execute(item.key, item.value)
		})
		return
	}

	pos, circle := tw.getPositionAndCircle(task.delay)
	// unchanged
	if pos == timer.pos && circle == item.circle {
		return
	}

	if _, ok := tw.slots[pos][circle]; !ok {
		tw.slots[pos][circle] = list.New()
	}
	// remove old element
	tw.slots[timer.pos][item.circle].Remove(timer.item)

	item.circle = circle
	timer.pos = pos

	// push new element
	tw.slots[pos][circle].PushBack(item)
	timer.item = tw.slots[pos][circle].Back()
}

func (tw *TimingWheel) onTick() {
	tw.tickedPos = (tw.tickedPos + 1) % tw.numSlots
	m := tw.slots[tw.tickedPos]
	if len(m) == 0 {
		return
	}
	newM := make(map[int]*list.List)
	for k1 := range m {
		if k1 > 0 {
			newM[k1-1] = m[k1]
		} else {
			for e := m[k1].Front(); e != nil; e = m[k1].Next(e) {
				timingEntry := e.Value.(*timingEntry)
				tw.timers.Del(timingEntry.key)
			}
			tw.lock.Lock()
			tw.cacheList.MergeBack(m[k1])
			if tw.locked {
				tw.locked = false
				tw.lockCh <- tw.locked
			}
			tw.lock.Unlock()
			m[k1].Init()
		}
	}
	tw.slots[tw.tickedPos] = newM
}

func (tw *TimingWheel) removeTask(key interface{}) {
	val, ok := tw.timers.Get(key)
	if !ok {
		return
	}

	timer := val.(*positionEntry)
	item := timer.item.Value.(*timingEntry)
	tw.timers.Del(key)
	tw.slots[timer.pos][item.circle].Remove(timer.item)
}

func (tw *TimingWheel) run() {
	for {
		select {
		case <-tw.ticker.Chan():
			tw.onTick()
		case task := <-tw.setChannel:
			tw.setTask(&task)
		case key := <-tw.removeChannel:
			tw.removeTask(key)
		case task := <-tw.moveChannel:
			tw.moveTask(task)
		case fn := <-tw.drainChannel:
			tw.drainAll(fn)
		case <-tw.stopChannel:
			tw.ticker.Stop()
			return
		}
	}
}

func (tw *TimingWheel) runTasks() {
	for {
		select {
		case <-tw.lockCh:
			for {
				e := tw.taskList.Back()
				if e == nil {
					tw.lock.Lock()
					tw.taskList.MergeBack(tw.cacheList)
					tw.cacheList.Init()
					e = tw.taskList.Back()
					if e == nil {
						for tw.goroutineNum > 0 {
							tw.goroutineNum--
							tw.taskCh <- nil
						}
						tw.locked = true
						tw.lock.Unlock()
						break
					}
					tw.lock.Unlock()
				}
				tw.taskList.Remove(e)
				if tw.goroutineNum < tw.maxGoroutineNum {
					tw.goroutineNum++
					go tw.worker()
				}
				tw.taskCh <- e
			}
		}
	}
}

func (tw *TimingWheel) worker() {
	for e := range tw.taskCh {
		if e == nil {
			break
		}
		tw.execute(e.Value.(*timingEntry).key, e.Value.(*timingEntry).value)
	}
}

func (tw *TimingWheel) setTask(task *timingEntry) {
	if task.delay < tw.interval {
		task.delay = tw.interval
	}

	if val, ok := tw.timers.Get(task.key); ok {
		entry := val.(*positionEntry)
		entry.item.Value.(*timingEntry).value = task.value
		tw.moveTask(task.baseEntry)
	} else {
		pos, circle := tw.getPositionAndCircle(task.delay)
		task.circle = circle
		if _, ok := tw.slots[pos][circle]; !ok {
			tw.slots[pos][circle] = list.New()
		}
		tw.slots[pos][circle].PushBack(task)
		tw.timers.Set(task.key, &positionEntry{
			pos:  pos,
			item: tw.slots[pos][circle].Back(),
		})
	}
}

func (tw *TimingWheel) GetValue(key string) (interface{}, bool) {
	val, ok := tw.timers.Get(key)
	if !ok {
		return nil, ok
	}
	return val.(*positionEntry).item.Value, ok
}

func (tw *TimingWheel) Len() int {
	return tw.timers.Size()
}

```