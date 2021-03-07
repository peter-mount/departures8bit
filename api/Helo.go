package api

import (
	"github.com/peter-mount/go-kernel"
	"io"
	"strings"
)

type Helo struct {
	server *TelnetServer
}

func (h *Helo) Name() string {
	return "Helo"
}

func (h *Helo) Init(k *kernel.Kernel) error {
	svce, err := k.AddService(&TelnetServer{})
	if err != nil {
		return err
	}
	h.server = (svce).(*TelnetServer)
	return nil
}

func (h *Helo) PostInit() error {
	return h.server.RegisterHandlerFunc("helo", h.Handler)
}

func (h *Helo) Handler(stdin io.ReadCloser, stdout io.WriteCloser, stderr io.WriteCloser, args ...string) error {
	return NewResponse(stdin, stdout).
		Append("INF%s", strings.Join(args, " ")).
		Send()
}
