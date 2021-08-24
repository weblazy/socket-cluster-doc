# 容器化部署
##### Headless Services 应用场景
第一种：自己实现负载均衡,有时候 client 想自己来决定使用哪个Real Server，可以通过查询DNS来获取 Real Server 的信息。

第二种：Headless Service 的对应的每一个 Endpoints，即每一个Pod，都会有对应的DNS域名，这样Pod之间就可以互相访问。以实现内部节点之间互相连接.

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None #headless模式
  selector:
    app: nginx
```

```
{headless service}.{namespace}.svc.cluster.local 解析出节点IP。
```
因此我们可以使用Headerless Service和DNS解析配合获取所有节点的ip进而实现节点之间互相连接通信,并且实现自定义的负载均衡策略.可以通过环境变量获取本节点的ip
```
    env:
    - name: POD_OWN_IP_ADDRESS
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    - name: POD_OWN_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_OWN_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
```
```
POD_OWN_IP_ADDRESS=100.107.55.20
POD_OWN_NAME=you_pod_name
POD_OWN_NAMESPACE=dev
```
``` 
    host = flag.String("host", "{headless service}.{namespace}.svc.cluster.local:9527", "the  host")
	common.NodeInfo, err = node.NewNode(node.NewNodeConf(*host, protocolHandler, sessionStorageHandler, discoveryHandler, onMsg).WithPort(*port))
```
