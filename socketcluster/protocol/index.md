# protocol

####Protocol
```
type Protocol interface {
	// ListenAndServe turns on the listening service.
	ListenAndServe(port int64, onConnect func(conn Connection)) error
	// Dial connects with the socket of the destination address.
	Dial(addr string) (Connection, error)
}
```
自定义协议接口

####Protocol
```
type Connection interface {
	ReadMsg() ([]byte, error)
	WriteMsg(data []byte) error
	Close() error
	Addr() string
}
```
自定义协议接口