package api

import (
	"fmt"
	refclient "github.com/peter-mount/nre-feeds/darwinref/client"
	ldbclient "github.com/peter-mount/nre-feeds/ldb/client"
	"github.com/reiver/go-telnet"
	"github.com/reiver/go-telnet/telsh"
	"io"
	"log"
	"strings"
)

const (
	TelnetBinding = ":25232"
)

type TelnetServer struct {
	shell     *telsh.ShellHandler
	server    *telnet.Server
	refClient refclient.DarwinRefClient // ref api
	ldbClient ldbclient.DarwinLDBClient // ldb api
}

func (a *TelnetServer) Name() string {
	return "TelnetServer"
}

func (a *TelnetServer) PostInit() error {
	a.shell = telsh.NewShellHandler()
	a.shell.Prompt = ""
	a.shell.WelcomeMessage = "00 DEPARTUREBOARDS.MOBI API"
	a.shell.ExitCommandName = "QUIT"
	a.shell.ExitMessage = "00 BYE"

	a.server = &telnet.Server{
		Addr:    TelnetBinding,
		Handler: a.shell,
		Logger:  &TelnetLogger{},
	}

	a.refClient = refclient.DarwinRefClient{Url: "https://ref.prod.a51.li"}
	a.ldbClient = ldbclient.DarwinLDBClient{Url: "https://ldb.prod.a51.li"}

	err := a.shell.Register("HELO", &Helo{a: a})
	if err != nil {
		return err
	}

	return nil
}

func (a *TelnetServer) Register(name string, producer *telsh.ProducerFunc) error {
	return a.shell.Register(name, producer)
}

func (a *TelnetServer) RegisterHandlerFunc(name string, producer telsh.HandlerFunc) error {
	return a.shell.RegisterHandlerFunc(name, producer)
}

func (a *TelnetServer) Run() error {
	log.Println("Starting telnet server on ", TelnetBinding)

	return a.server.ListenAndServe()
}

func (a *TelnetServer) Info(stdout io.WriteCloser, f string, args ...interface{}) error {
	return a.Record(stdout, "INF"+f, args...)
}

func (a *TelnetServer) Record(stdout io.WriteCloser, f string, args ...interface{}) error {
	s := fmt.Sprintf(f, args...)
	log.Println(s)
	_, err := stdout.Write([]byte(s))
	return err
}

func (a *TelnetServer) End(stdout io.WriteCloser) error {
	_, err := stdout.Write([]byte("END\n"))
	return err
}

type Helo struct {
	a *TelnetServer
}

func (h *Helo) Produce(ctx telnet.Context, name string, args ...string) telsh.Handler {
	return telsh.PromoteHandlerFunc(h.Handler)
}

func (h *Helo) Handler(stdin io.ReadCloser, stdout io.WriteCloser, stderr io.WriteCloser, args ...string) error {
	err := h.a.Info(stdout, "Hello %s", strings.Join(args, " "))
	if err != nil {
		return err
	}
	return h.a.End(stdout)
}
