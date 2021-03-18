# NodePush

####Ping
```
func (n *NodePush) Ping(ping *string) *tp.Status
```
响应node节点心跳请求

####SendToUid
```
func (n *NodePush) SendToUid(msg *Message) (int, *tp.Status)
```
向某个用户发送消息,Message结构如下
```
	Message struct {
		uid  string //用户Id
		path string //Node节点路由
		data interface{} //消息内容
	}
```
