package telnet

import (
	"context"
	"flag"
	"github.com/peter-mount/departures8bit/api/command"
	"github.com/peter-mount/go-kernel"
	"github.com/reiver/go-telnet"
	"log"
)

type Server struct {
	server      *telnet.Server
	commands    *command.Server
	portBinding *string
}

func (a *Server) Name() string {
	return "TelnetServer"
}

func (a *Server) Init(k *kernel.Kernel) error {
	svce, err := k.AddService(&command.Server{})
	if err != nil {
		return err
	}
	a.commands = svce.(*command.Server)

	a.portBinding = flag.String("telnet", "", "Enable telnet server on :port")
	return nil
}

func (a *Server) PostInit() error {
	if *a.portBinding != "" {
		a.server = &telnet.Server{
			Addr:    *a.portBinding,
			Handler: a,
			Logger:  &Logger{},
		}
	}
	return nil
}

func (a *Server) Run() error {
	if a.portBinding != nil && *a.portBinding != "" {
		log.Println("Starting telnet server on ", *a.portBinding)

		return a.server.ListenAndServe()
	}

	return nil
}

func (a *Server) ServeTELNET(ctx telnet.Context, writer telnet.Writer, reader telnet.Reader) {
	_ = a.commands.Shell(context.WithValue(context.Background(), "telnet", ctx), writer, reader)
}
