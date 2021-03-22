# SessionStorage

```
type SessionStorage interface {
	SetNodeId(nodeId string)
	IsOnline(clientId int64) bool
	BindClientId(clientId int64) error
	GetIps(clientId int64) ([]string, error)
	GetClientsIps(clientIds []string) ([]string, map[string][]string, error)
	ClientIdsOnline(clientIds []int64) []int64
	OnClientPing(clientId int64) error
}
```

####启动node节点
```
func NewNode(cfg *NodeConf) (Node, error)
```
启动node节点程序入口