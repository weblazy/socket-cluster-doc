# Websocket
```

type WsConnection struct {
	Conn  *websocket.Conn
	Mutex sync.Mutex
	protocol.Connection
}

func NewWsConnection(conn *websocket.Conn) *WsConnection {
	return &WsConnection{
		Conn: conn,
	}
}

// WriteMsg send byte array message
func (this *WsConnection) WriteMsg(data []byte) error {
	this.Mutex.Lock()
	defer this.Mutex.Unlock()
	return this.Conn.WriteMessage(websocket.TextMessage, data)
}

func (this *WsConnection) ReadMsg() ([]byte, error) {
	_, msg, err := this.Conn.ReadMessage()
	if err != nil {
		if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {

		}
		return nil, err
	}
	return msg, err
}

func (this *WsConnection) Addr() string {
	return this.Conn.RemoteAddr().String()
}

func (this *WsConnection) Close() error {
	if this.Conn == nil {
		return nil
	}
	return this.Conn.Close()
}

func OptionHandler(c echo.Context) error {
	c.Response().Header().Set("Access-Control-Allow-Origin", "*")
	c.Response().Header().Set("Access-Control-Allow-Headers", "*")
	return c.String(200, "")
}

func OriginMiddlewareFunc(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		c.Response().Header().Set("Access-Control-Allow-Origin", "*")
		c.Response().Header().Set("Access-Control-Allow-Headers", "*")
		return next(c)
	}
}
```
```
package ws_protocol

import (
	"fmt"
	"net/http"

	"github.com/gorilla/websocket"
	"github.com/labstack/echo/v4"
	"github.com/weblazy/socket-cluster/protocol"
)

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:    4096,
		WriteBufferSize:   4096,
		EnableCompression: true,
		CheckOrigin: func(r *http.Request) bool {
			return true
		},
	}
)

type WsProtocol struct {
}

func (this *WsProtocol) ListenAndServe(port int64, onConnect func(conn protocol.Connection)) error {
	e := echo.New()
	e.GET("/client", func(c echo.Context) error {
		connect, err := upgrader.Upgrade(c.Response(), c.Request(), nil)
		if err != nil {
			if _, ok := err.(websocket.HandshakeError); !ok {

			}
			return err
		}
		conn := NewWsConnection(connect)
		onConnect(conn)
		return nil
	})
	go func() {
		err := e.Start(fmt.Sprintf(":%d", port))
		if err != nil {
			panic(err)
		}
	}()
	return nil
}

func (this *WsProtocol) Dial(addr string) (protocol.Connection, error) {
	connect, _, err := websocket.DefaultDialer.Dial(addr, nil)
	if err != nil {
		return nil, err
	}
	return NewWsConnection(connect), nil
}
```