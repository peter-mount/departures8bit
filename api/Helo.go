package api

import (
  "context"
  "github.com/peter-mount/departures8bit/api/command"
  "github.com/peter-mount/go-kernel"
  "strings"
)

type Helo struct {
  server *command.Server
}

func (h *Helo) Name() string {
  return "Helo"
}

func (h *Helo) Init(k *kernel.Kernel) error {
  svce, err := k.AddService(&command.Server{})
  if err != nil {
    return err
  }
  h.server = (svce).(*command.Server)
  return nil
}

func (h *Helo) PostInit() error {
  return h.server.Register("helo", h.Handler)
}

func (h *Helo) Handler(ctx context.Context) error {
  command.GetResponse(ctx).
      RecordRaw(
        command.NewRecord().
          Byte('#').
          Stringf("Hello %s", strings.Join(command.GetArgs(ctx), " ")))
  return nil
}
