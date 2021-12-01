package api

import (
  "context"
  "github.com/peter-mount/departures8bit/api/command"
  "github.com/peter-mount/go-kernel"
  "log"
  "strings"
)

type Search struct {
  api    *ApiCore
  server *command.Server
}

func (h *Search) Name() string {
  return "Search"
}

func (h *Search) Init(k *kernel.Kernel) error {
  svce, err := k.AddService(&command.Server{})
  if err != nil {
    return err
  }
  h.server = (svce).(*command.Server)

  svce, err = k.AddService(&ApiCore{})
  if err != nil {
    return err
  }
  h.api = (svce).(*ApiCore)

  return nil
}

func (h *Search) PostInit() error {
  return h.server.Register("search", h.Handle)
}

func (h *Search) Handle(ctx context.Context) error {
  resp := command.GetResponse(ctx)

  args := command.GetArgs(ctx)
  if len(args) != 1 {
    resp.Errorf("search text")
    return nil
  }

  search := strings.Join(args, " ")
  log.Println("SEARCH " + search)

  sr, err := h.api.refClient.Search(search)
  if err != nil {
    return err
  }

  for _, e := range sr {
    resp.Append("", "%-3.3s%s", e.Crs, e.Name)
    log.Printf("Found %3s %s", e.Crs, e.Label)
  }

  return nil
}
