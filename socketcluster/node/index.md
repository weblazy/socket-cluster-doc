# Node

```
	Node interface {
		// SetClientIdOnline binds the client ID to the connection
		SetClientIdOnline(conn protocol.Connection, clientId string) error
		// OnClientPing updates the client heartbeat status
		OnClientPing(clientId int64) error
		// IsOnline gets the online status of the clientId
		IsOnline(clientId int64) bool
		// SendToClientId sends a message to a clientId
		SendToClientId(clientId string, req []byte) error
		//  SendToClientId sends a message to multiple clientIds
		SendToClientIds(clientIds []string, req []byte) error
	}
```

####启动node节点
```
func NewNode(cfg *NodeConf) (Node, error)
```
启动node节点程序入口

####OnClientPing
```
func OnClientPing(clientId int64) error
```
更新某个clientId心跳时间

####IsOnline
```
func IsOnline(clientId int64) bool
```
获取某个clientId的在线状态

####SendToClientId
```
func SendToClientId(clientId string, req []byte) error
```
向某个clientId发送数据

####SendToClientIds
```
func SendToClientIds(clientIds []string, req []byte) error
```
向多个clientId发送数据

