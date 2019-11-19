# NodeCall

####Ping
```
func (n *NodeCall) UpdateNodeList(nodeList *[]string) (int64, *tp.Status)
```
更新node节点

####Auth
```
func (n *NodeCall) Auth(args *Auth) (int, *tp.Status)
```
node节点认证请求参数是Auth,结构如下
```
	Auth struct {
		TransAddress string //Node节点内部通信地址
		Password     string //配置文件中的秘钥
	}
```