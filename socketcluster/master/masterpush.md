# MasterPush

####Ping
```
func (m *MasterPush) Ping(ping *string) *tp.Status
```
响应node节点心跳请求

####Auth
```
func (m *MasterPush) Auth(args *Auth) *tp.Status
```
node节点认证请求参数是Auth,结构如下
```
	Auth struct {
		TransAddress string //Node节点内部通信地址
		Password     string //配置文件中的秘钥
	}
```
