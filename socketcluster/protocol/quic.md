
# Quic
```
package quic_protocol

import (
	"sync"

	"github.com/lucas-clemente/quic-go"
	"github.com/weblazy/socket-cluster/protocol"
)

type QuicConnection struct {
	stream              quic.Stream
	session             quic.Session
	mutex               sync.Mutex
	flowProtocolHandler protocol.Proto
}

func NewQuicConnection(stream quic.Stream, session quic.Session) *QuicConnection {
	return &QuicConnection{
		session:             session,
		stream:              stream,
		flowProtocolHandler: protocol.NewFlowProtocol(protocol.HEADER, protocol.MAX_LENGTH, stream),
	}
}

// WriteMsg sends byte array message
func (this *QuicConnection) WriteMsg(data []byte) error {
	data, err := this.flowProtocolHandler.Pack(data)
	if err != nil {
		return err
	}
	this.mutex.Lock()
	defer this.mutex.Unlock()
	_, err = this.stream.Write(data)
	return err
}

// ReadMsg reads byte array message
func (this *QuicConnection) ReadMsg() ([]byte, error) {
	msg, err := this.flowProtocolHandler.ReadMsg()
	if err != nil {
		return nil, err
	}
	return msg, err
}

func (this *QuicConnection) Addr() string {
	return this.session.RemoteAddr().String()
}

func (this *QuicConnection) Close() error {
	if this.stream == nil {
		return nil
	}
	return this.stream.Close()
}

func (this *QuicConnection) SetFlowProtocolHandler(flowProtocolHandler protocol.Proto) {
	this.flowProtocolHandler = flowProtocolHandler
}
```

```
package quic_protocol

import (
	"context"
	"fmt"

	"github.com/lucas-clemente/quic-go"
	"github.com/weblazy/socket-cluster/logx"
	"github.com/weblazy/socket-cluster/protocol"
)

type QuicProtocol struct {
}

func (this *QuicProtocol) ListenAndServe(port int64, onConnect func(conn protocol.Connection)) error {
	// Setup a bare-bones TLS config for the server
	tlsConf := protocol.GenerateTLSConfigForServer()
	listener, err := quic.ListenAddr(fmt.Sprintf(":%d", port), tlsConf, nil)
	if err != nil {
		logx.LogHandler.Error(err)
	}
	for {
		session, err := listener.Accept(context.Background())
		if err != nil {
			logx.LogHandler.Error(err)
		} else {
			go func(session quic.Session) {
				// Use only the first stream
				stream, err := session.AcceptStream(context.Background())
				if err != nil {
					panic(err)
				}
				conn := NewQuicConnection(stream, session)
				onConnect(conn)
			}(session)
		}
	}
}

func (this *QuicProtocol) Dial(addr string) (protocol.Connection, error) {
	// Setup a bare-bones TLS config for the client
	tlsConf := protocol.GenerateTLSConfigForClient()
	session, err := quic.DialAddr(addr, tlsConf, nil)
	if err != nil {
		return nil, err
	}
	// Use only the first stream
	stream, err := session.OpenStreamSync(context.Background())
	if err != nil {
		return nil, err
	}
	return NewQuicConnection(stream, session), err
}
```
