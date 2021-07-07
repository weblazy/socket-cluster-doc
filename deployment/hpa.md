# hpa弹性扩容
```
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: iids-app-config
  namespace: iids
spec:
  minReplicas: 2   #至少2个副本
  maxReplicas: 5   #最多5个副本
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: iids-app-config #创建的deploment文件里面的name
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 50  #注意此时是根据使用率，也可以根据使用量：targetAverageValue
  - type: Resource
    resource:
      name: memory
      targetAverageUtilization: 50  #注意此时是根据使用率，也可以根据使用量：targetAverageValue
```
```
扩容：当CUP或者内存超过50%,HPA会根据自身算法进行扩容，启动Pod,达到满足资源的pod数量
缩容：当CUP或者内存低于50%，HPA会根据自身算法进行缩容，停止Pod,达到满足资源的pod数量
```