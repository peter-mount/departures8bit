package api

import (
	"fmt"
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
	shell  *telsh.ShellHandler
	server *telnet.Server
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

	err := a.shell.Register("HELO", &Helo{a: a})
	if err != nil {
		return err
	}

	return nil
}

func (a *TelnetServer) Register(name string, producer *telsh.ProducerFunc) error {
	return a.shell.Register(name, producer)
}

func (a *TelnetServer) Run() error {
	log.Println("Starting telnet server on ", TelnetBinding)

	return a.server.ListenAndServe()
}

type Helo struct {
	a *TelnetServer
}

func (h *Helo) Produce(ctx telnet.Context, name string, args ...string) telsh.Handler {
	return telsh.PromoteHandlerFunc(h.Handler)
}

func (h *Helo) Handler(stdin io.ReadCloser, stdout io.WriteCloser, stderr io.WriteCloser, args ...string) error {
	log.Printf("01 Hello %s", strings.Join(args, " "))
	_, err := stdout.Write([]byte(fmt.Sprintf("01 Hello %s", strings.Join(args, " "))))
	return err
}
