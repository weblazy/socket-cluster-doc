
# ServiceDiscovery

####ServiceDiscovery
```
type ServiceDiscovery interface {
	// SetNodeId sets nodeId
	SetNodeId(nodeId string)
	// WatchService Listens for a new node to start
	WatchService(watchChan WatchChan)
	// UpdateInfo Updates the information for this node
	UpdateInfo([]byte) error
	// Register registers the NodeID and notify other nodes
	Register() error
}
```
服务发现模块采用插件模式,目前已经内置了redis和ectd两种方式.你可以自己实现自己的服务发现组件.节点启动时会向服务发现组件发一条通知,其他节点服务发现组件接收到通知之后,进行dns解析,遍历每一个ip找出新启动的节点建立连接,新节点从而加入集群.
####SetNodeId
```
func SetNodeId(nodeId string)
```
节点启动时向服务发现组件设置本节点的唯一标识符nodeId(启动时自动生成的uuid)

####WatchService
```
func WatchService(watchChan WatchChan)
```
当服务发现模块发现有节点变化(新增或者减少时)会给传入的watchChan信号,node节点会监听触发dns解析,自动连接新的节点

####UpdateInfo
```
func UpdateInfo([]byte) error
```
更新节点的心跳状态和后台统计信息.

####Register
```
func Register() error
```
节点启动时向服务发现组件(etcd,redis已经内置)注册本节点的唯一标识符nodeId
