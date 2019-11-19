# Node

####启动node节点
```
func StartNode(cfg NodeConf, controllers []interface{}, globalLeftPlugin ...tp.Plugin)
```
controllers是实现了tp.PushCtx接口的结构体实例

####IsOnline
```
func IsOnline(uid string) bool
```
判断某个用户是否在线

####GroupOnline
```
func GroupOnline(gid string) []string
```
获取某个群组的所有在线用户

####GetSession
```
func GetSession(context tp.PreCtx) tp.Session
```
从tp.PreCtx中获取对应的tp.Session

####BindUid
```
func BindUid(uid string, context tp.PreCtx) error
```
将用户uid和session绑定

####SendToUid
```
func SendToUid(uid string, path string, req interface{}) (int, *tp.Status)
```
向某个用户发送消息

####JoinGroup
```
func JoinGroup(gid string, session tp.Session) (int, *tp.Status)
```
加入用户组

####LeaveGroup
```
func LeaveGroup(gid string, session tp.Session) (int, *tp.Status)
```
离开用户组

####SendToGroup
```
func SendToGroup(gid string, path string, req interface{}) (int, *tp.Status)
```
向某个用户组发送消息
