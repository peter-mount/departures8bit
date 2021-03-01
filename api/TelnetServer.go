package api

import (
	"github.com/reiver/go-oi"
	"github.com/reiver/go-telnet"
	"log"
)

const (
	TelnetBinding = ":25232"
)

type TelnetServer struct {
}

func (a *TelnetServer) Name() string {
	return "TelnetServer"
}

func (a *TelnetServer) Run() error {
	log.Println("Starting telnet server on ", TelnetBinding)

	server := &telnet.Server{
		Addr:    TelnetBinding,
		Handler: a,
		Logger:  &TelnetLogger{},
	}

	return server.ListenAndServe()
}

func (a *TelnetServer) ServeTELNET(ctx telnet.Context, w telnet.Writer, r telnet.Reader) {
	// Dummy header to notify we are connected
	_, _ = w.Write([]byte("00 Area51 App\n"))

	// For now simulate an echo handler
	var buffer [1]byte // Seems like the length of the buffer needs to be small, otherwise will have to wait for buffer to fill up.
	p := buffer[:]

	for {
		n, err := r.Read(p)

		if n > 0 {
			_, _ = oi.LongWrite(w, p[:n])
		}

		if nil != err {
			break
		}
	}
}
