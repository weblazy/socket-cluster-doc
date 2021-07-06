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

####IsOnline
```
func IsOnline(clientId int64) bool
```
获取某个clientId是否在线

####BindClientId
```
func BindClientId(clientId int64) error
```
将clientId设置为在线

####GetIps
```
func GetIps(clientId int64) ([]string, error)
```
获取某个clientId所在node上,返回node对应的nodeId

####GetClientsIps
```
func GetClientsIps(clientIds []string) ([]string, map[string][]string, error)
```
获取一批clientId所在node上,返回node对应的nodeId

####ClientIdsOnline
```
func ClientIdsOnline(clientIds []int64) []int64
```
获取一批clientId是否在线

####OnClientPing
```
func OnClientPing(clientId int64) error
```
修改某个clientId的心跳时间
