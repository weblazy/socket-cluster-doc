# protocol

```
type Protocol interface {
	// ListenAndServe turns on the listening service.
	ListenAndServe(port int64, onConnect func(conn Connection)) error
	// Dial connects with the socket of the destination address.
	Dial(addr string) (Connection, error)
}
```
####ListenAndServe
```
func ListenAndServe(port int64, onConnect func(conn Connection)) error
```
监听端口,传入连接回调函数,协议需要实现如下接口

####Dial
```
func Dial(addr string) (Connection, error)
```
自定义协议需要实现,连接服务端接口

```
type Connection interface {
	ReadMsg() ([]byte, error)
	WriteMsg(data []byte) error
	Close() error
	Addr() string
}
```
####ReadMsg
```
func ReadMsg() ([]byte, error)
```
读取对方发来的消息

####WriteMsg
```
func WriteMsg(data []byte) error
```
向对方写消息

####Close
```
func Close() error
```
关闭连接

####Addr
```
func Addr() string
```
获取连接唯一标识符,tcp,ws均为ip:端口