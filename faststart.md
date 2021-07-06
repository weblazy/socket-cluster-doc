快速开始
```
package master

import (
	"encoding/json"
	"flag"
	"hash/fnv"
	"os"
	"strconv"

	"github.com/weblazy/socket-cluster-examples/auth"
	"github.com/weblazy/socket-cluster-examples/common"
	"github.com/weblazy/socket-cluster-examples/model"
	"github.com/weblazy/socket-cluster/business_client"
	"github.com/weblazy/socket-cluster/discovery/redis_discovery"
	"github.com/weblazy/socket-cluster/node"
	"github.com/weblazy/socket-cluster/protocol/ws_protocol"
	"github.com/weblazy/socket-cluster/session_storage/redis_storage"

	"github.com/go-redis/redis/v8"
	"github.com/spf13/cast"
	"github.com/weblazy/easy/utils/logx"
)

var (
	port = flag.Int64("port1", 9528, "the  port")
	// host = flag.String("host1", "web.xiaoyuantongbbs.cn:9527", "the  host")
	host = flag.String("host1", "127.0.0.1:9527", "the  host")
)

func Node() {
	flag.Parse()
	var err error
	redisHost := os.Getenv("REDIS_HOST")
	redisPassword := os.Getenv("REDIS_PASSWORD")
	err = auth.InitAuth(auth.NewAuthConf([]*auth.RedisNode{
		&auth.RedisNode{
			RedisConf: &redis.Options{Addr: redisHost, Password: redisPassword, DB: 0},
			Position:  1,
		}}))
	if err != nil {
		panic(err)
	}
	protocolHandler := &ws_protocol.WsProtocol{}
	sessionStorageHandler := redis_storage.NewRedisStorage([]*redis_storage.RedisNode{&redis_storage.RedisNode{
		RedisConf: &redis.Options{Addr: redisHost, Password: redisPassword, DB: 0},
		Position:  10000,
	}})

	discoveryHandler := redis_discovery.NewRedisDiscovery(&redis.Options{Addr: redisHost, Password: redisPassword, DB: 0})
	common.NodeInfo, err = node.NewNode(node.NewNodeConf(*host, protocolHandler, sessionStorageHandler, discoveryHandler, onMsg).WithPort(*port))
	if err != nil {
		logx.Info(err)
	}
	common.BusinessClient, err = business_client.NewBusinessClient(business_client.NewBusinessClientConf([]string{*host}, discoveryHandler, sessionStorageHandler, onMsg))
	if err != nil {
		logx.Info(err)
	}
}

func getIndex(key string) int64 {
	h := fnv.New32a()
	h.Write([]byte(key))
	return int64(h.Sum32()) % model.TableNum
}

func onMsg(context *node.Context) {
	logx.Info("msg:", string(context.Msg))
}
```