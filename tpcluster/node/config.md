# Node

####Node节点配置
```
	NodeConf struct {
		RedisConf      redis.RedisConf
		RedisMaxCount  uint32 //redis hash环最大节点数
		ClientPeerConf tp.PeerConfig //外部通信peer
		TransPeerConf  tp.PeerConfig //内部通信peer
		TransPort      int64  //内部通信端口
		MasterAddress  string //Master节点地址ip:port
		Password       string //内部通信认证的秘钥
		PingInterval   int    //心跳间隔
	}
```

####NodeInfo属性
```
NodeInfo struct {
		bizRedis       *redis.Redis //redis链接
		nodeConf       NodeConf //node配置
		masterSession  tp.Session //master session
		nodeSessions   map[string]tp.CtxSession //建是node的sessionId值是session
		clientSessions map[string]tp.Session
		uidSessions    *syncx.ConcurrentDoubleMap //分段锁封装的二维map
		groupSessions  *syncx.ConcurrentDoubleMap 
		clientPeer     tp.Peer                  //外部通信peer
		clientAddress  string                   //外部通信地址
		transPeer      tp.Peer                  //内部通信peer
		transAddress   string                   //内部通信地址address
		timer          *timingwheel.TimingWheel ///时间轮,当Node节点连接之后一段时间之内没有认证,服务端会超时自动断开,防止其他恶意连接
		startTime      time.Time //node节点启动时间
		userHashRing   *unsafehash.Consistent //用户Id的hash环
		groupHashRing  *unsafehash.Consistent //用户组的hash环
	}
```