package fifo

import (
	"context"
	"errors"
	"flag"
	"github.com/peter-mount/departures8bit/api/command"
	"github.com/peter-mount/go-kernel"
	"log"
	"os"
)

type Server struct {
	commands *command.Server
	inFifo   *string
	outFifo  *string
	enabled  bool
}

func (a *Server) Name() string {
	return "FifoServer"
}

func (a *Server) Init(k *kernel.Kernel) error {
	svce, err := k.AddService(&command.Server{})
	if err != nil {
		return err
	}
	a.commands = svce.(*command.Server)

	a.inFifo = flag.String("fifo-in", "", "Enable fifo")
	a.outFifo = flag.String("fifo-out", "", "Enable fifo")
	return nil
}

func (a *Server) PostInit() error {
	// Enable is both set, but fail if just one is set
	a.enabled = *a.inFifo != "" && *a.outFifo != ""
	if !a.enabled && (*a.inFifo != "" && *a.outFifo != "") {
		return errors.New("if used both -fifo-in and -fifo-out must be defined")
	}

	return nil
}

func (a *Server) Run() error {
	if !a.enabled {
		return nil
	}

	for true {
	    err:= a.run()
        if err!=nil {
            return err
        }
	}
	return nil
}

func (a *Server) run() error {
	log.Println("Starting fifo server on ", *a.inFifo, *a.outFifo)

	r, err := os.OpenFile(*a.inFifo, os.O_RDONLY, 0644)
	if err != nil {
		return err
	}
	defer r.Close()

	w, err := os.OpenFile(*a.outFifo, os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	defer w.Close()

	return a.commands.Shell(context.Background(), w, r)
}
