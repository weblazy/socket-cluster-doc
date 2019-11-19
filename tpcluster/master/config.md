# Master

####master配置
```
	MasterConf struct {
		MasterPeerConf tp.PeerConfig //master Peer 配置
		Password       string        //内部通信秘钥
	}
```

####MasterInfo属性
```
	MasterInfo struct {
		masterConf MasterConf //master配置
		nodeMap    goutil.Map // 键是sessionId,值是nodeSession类型
		timer      *timingwheel.TimingWheel //时间轮,当Node节点连接之后一段时间之内没有认证,服务端会超时自动断开,防止其他恶意连接
		startTime  time.Time //master启动时的时间
	}
```

####nodeSession属性
```
	nodeSession struct {
		session tp.Session //node节点的session
		address string //node节点内部通信地址ip:port
	}
```