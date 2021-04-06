
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
自定义协议接口


