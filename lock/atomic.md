# 原子操作

- 存储
此类操作的前缀为 Store
```
// StoreInt32 atomically stores val into *addr.
func StoreInt32(addr *int32, val int32)

// StoreInt64 atomically stores val into *addr.
func StoreInt64(addr *int64, val int64)

// StoreUint32 atomically stores val into *addr.
func StoreUint32(addr *uint32, val uint32)

// StoreUint64 atomically stores val into *addr.
func StoreUint64(addr *uint64, val uint64)

// StoreUintptr atomically stores val into *addr.
func StoreUintptr(addr *uintptr, val uintptr)

// StorePointer atomically stores val into *addr.
func StorePointer(addr *unsafe.Pointer, val unsafe.Pointer)
```
- 载入操作
atomic 包中提供了如下以Load为前缀的增减操作:
```
// LoadInt32 atomically loads *addr.
func LoadInt32(addr *int32) (val int32)

// LoadInt64 atomically loads *addr.
func LoadInt64(addr *int64) (val int64)

// LoadUint32 atomically loads *addr.
func LoadUint32(addr *uint32) (val uint32)

// LoadUint64 atomically loads *addr.
func LoadUint64(addr *uint64) (val uint64)

// LoadUintptr atomically loads *addr.
func LoadUintptr(addr *uintptr) (val uintptr)

// LoadPointer atomically loads *addr.
func LoadPointer(addr *unsafe.Pointer) (val unsafe.Pointer)
```
- 交换:存储的同时返回原来的数据
此类操作的前缀为 Swap：
```
// SwapInt32 atomically stores new into *addr and returns the previous *addr value.
func SwapInt32(addr *int32, new int32) (old int32)

// SwapInt64 atomically stores new into *addr and returns the previous *addr value.
func SwapInt64(addr *int64, new int64) (old int64)

// SwapUint32 atomically stores new into *addr and returns the previous *addr value.
func SwapUint32(addr *uint32, new uint32) (old uint32)

// SwapUint64 atomically stores new into *addr and returns the previous *addr value.
func SwapUint64(addr *uint64, new uint64) (old uint64)

// SwapUintptr atomically stores new into *addr and returns the previous *addr value.
func SwapUintptr(addr *uintptr, new uintptr) (old uintptr)

// SwapPointer atomically stores new into *addr and returns the previous *addr value.
func SwapPointer(addr *unsafe.Pointer, new unsafe.Pointer) (old unsafe.Pointer)
```
- 比较并交换:原数据和传入的old相同时才写入新数据,返回是否交换成功。
该操作简称 CAS(Compare And Swap)。 这类操作的前缀为 CompareAndSwap :
```
// CompareAndSwapInt32 executes the compare-and-swap operation for an int32 value.
func CompareAndSwapInt32(addr *int32, old, new int32) (swapped bool)

// CompareAndSwapInt64 executes the compare-and-swap operation for an int64 value.
func CompareAndSwapInt64(addr *int64, old, new int64) (swapped bool)

// CompareAndSwapUint32 executes the compare-and-swap operation for a uint32 value.
func CompareAndSwapUint32(addr *uint32, old, new uint32) (swapped bool)

// CompareAndSwapUint64 executes the compare-and-swap operation for a uint64 value.
func CompareAndSwapUint64(addr *uint64, old, new uint64) (swapped bool)

// CompareAndSwapUintptr executes the compare-and-swap operation for a uintptr value.
func CompareAndSwapUintptr(addr *uintptr, old, new uintptr) (swapped bool)

// CompareAndSwapPointer executes the compare-and-swap operation for a unsafe.Pointer value.
func CompareAndSwapPointer(addr *unsafe.Pointer, old, new unsafe.Pointer) (swapped bool)
```
- 增减操作
atomic 包中提供了如下以Add为前缀的增减操作:
```
// AddInt32 atomically adds delta to *addr and returns the new value.
func AddInt32(addr *int32, delta int32) (new int32)

// AddUint32 atomically adds delta to *addr and returns the new value.
// To subtract a signed positive constant value c from x, do AddUint32(&x, ^uint32(c-1)).
// In particular, to decrement x, do AddUint32(&x, ^uint32(0)).
func AddUint32(addr *uint32, delta uint32) (new uint32)

// AddInt64 atomically adds delta to *addr and returns the new value.
func AddInt64(addr *int64, delta int64) (new int64)

// AddUint64 atomically adds delta to *addr and returns the new value.
// To subtract a signed positive constant value c from x, do AddUint64(&x, ^uint64(c-1)).
// In particular, to decrement x, do AddUint64(&x, ^uint64(0)).
func AddUint64(addr *uint64, delta uint64) (new uint64)

// AddUintptr atomically adds delta to *addr and returns the new value.
func AddUintptr(addr *uintptr, delta uintptr) (new uintptr)
```

