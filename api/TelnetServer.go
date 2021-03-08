package api

import (
	"fmt"
	"github.com/peter-mount/departures8bit/apps/lang"
	"github.com/peter-mount/departures8bit/apps/network"
	refclient "github.com/peter-mount/nre-feeds/darwinref/client"
	ldbclient "github.com/peter-mount/nre-feeds/ldb/client"
	"github.com/reiver/go-telnet"
	"io"
	"log"
	"strings"
)

const (
	TelnetBinding = ":10232"
)

type TelnetServer struct {
	server    *telnet.Server
	refClient refclient.DarwinRefClient // ref api
	ldbClient ldbclient.DarwinLDBClient // ldb api
	commands  map[string]TelnetHandler
}

type TelnetHandler interface {
	Handle(prog *lang.Program, args ...string) error
}

func (a *TelnetServer) Name() string {
	return "TelnetServer"
}

func (a *TelnetServer) PostInit() error {
	a.server = &telnet.Server{
		Addr:    TelnetBinding,
		Handler: a,
		Logger:  &TelnetLogger{},
	}

	a.refClient = refclient.DarwinRefClient{Url: "https://ref.prod.a51.li"}
	a.ldbClient = ldbclient.DarwinLDBClient{Url: "https://ldb.prod.a51.li"}

	a.commands = make(map[string]TelnetHandler)
	return nil
}

func (a *TelnetServer) Register(name string, handler TelnetHandler) error {
	if _, exists := a.commands[name]; exists {
		return fmt.Errorf("handler %s already registered", name)
	}
	a.commands[name] = handler
	return nil
}

func (a *TelnetServer) Run() error {
	log.Println("Starting telnet server on ", TelnetBinding)

	return a.server.ListenAndServe()
}
func (a *TelnetServer) ServeTELNET(ctx telnet.Context, writer telnet.Writer, reader telnet.Reader) {
	for true {
		l, err := a.readLine(reader)
		if err == nil && l != "" {
			var prog lang.Program
			args := strings.Split(l, " ")
			log.Println(args)
			cmd, ok := a.commands[args[0]]
			if ok {
				err = cmd.Handle(&prog, args[1:]...)
			} else {
				prog.Error("Unknown command %s", args[0])
			}
			if err == nil {
				b := prog.Compile()
				r := network.SplitBytes(b)
				err = r.Send(reader, writer)
			}
		}
		if err != nil {
			log.Println(err)
			if err == io.EOF {
				return
			}
		}
	}
}

func (a *TelnetServer) readLine(reader io.Reader) (string, error) {
	var s []byte
	b := []byte{0}
	for true {
		n, err := reader.Read(b)
		log.Printf("%02d %02d %02x %s", len(s), n, b[0], s)
		if err != nil {
			return "", err
		}
		if n == 1 {
			c := b[0]
			if c == '\n' {
				return string(s[:]), nil
			}

			if c >= ' ' && c < 127 {
				s = append(s, c)
			}
		}
	}
	return string(s[:]), nil
}
