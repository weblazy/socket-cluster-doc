目录结构如下
```
.
├── LICENSE
├── README.md
├── README_ENGLISH.md
├── admin(后台管理和监控程序)
│   ├── admin.go
│   └── html
│       └── index.html
├── connect(长连接相关代码)
├── discovery(服务发现相关代码)
│   ├── discover.go
│   ├── etcd_discovery
│   │   └── etcd_discovery.go
│   └── redis_discovery
│       └── redis_discovery.go
├── dns
│   └── dns.go
├── docs
│   └── performance_test.md
├── go.mod
├── go.sum
├── logx(日志模块)
│   ├── fileLogger.go
│   ├── filelogger_test.go
│   ├── log.go
│   ├── logx.go
│   ├── stdlogger.go
│   └── stdlogger_test.go
├── node(核心业务逻辑)
│   ├── common.go
│   ├── conf.pb.go
│   ├── conf.proto
│   ├── const.go
│   ├── msg.pb.go
│   ├── msg.proto
│   ├── node.go
│   ├── node_conf.go
│   ├── plugin.go
│   └── session.go
├── pic
│   └── websocket.png
├── protocol(内置tcp,quic,ws协议实现)
│   ├── flow_proto.go
│   ├── protocol.go
│   ├── quic_protocol
│   │   ├── quic_connect.go
│   │   ├── quic_protocol.go
│   │   └── quic_test.go
│   ├── session.go
│   ├── tcp_protocol
│   │   ├── tcp_connection.go
│   │   └── tcp_protocol.go
│   ├── tls.go
│   └── ws_protocol
│       ├── ws_connection.go
│       └── ws_protocol.go
├── session_storage(用户在线状态维护)
│   ├── redis_storage
│   │   └── redis_storage.go
│   └── session_storage.go
└── unsafehash
    └── segment_hash.go
```