# 非容器化部署

每部署一个节点,将该节点ip加入集群的DNS解析记录即可.组件会自动进行DNS解析找出新启动的节点,进行互相连接通信.
如图:
![DNS](../pic/DNS.jpg)
42.192.166.82和139.196.187.142被解析到同一个web.xiaoyuantongbbbs.cn域名之后,这两个节点被加入到了同一个集群
``` 
    host = flag.String("host", "web.xiaoyuantongbbbs.cn:9527", "the  host")
	common.NodeInfo, err = node.NewNode(node.NewNodeConf(*host, protocolHandler, sessionStorageHandler, discoveryHandler, onMsg).WithPort(*port))
```
