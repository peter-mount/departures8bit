package api

import (
  "context"
  "github.com/peter-mount/departures8bit/api/command"
  "github.com/peter-mount/departures8bit/api/record"
  "github.com/peter-mount/go-kernel"
  "log"
  "strings"
)

type Boards struct {
  api    *ApiCore
  server *command.Server
}

func (h *Boards) Name() string {
  return "Boards"
}

func (h *Boards) Init(k *kernel.Kernel) error {
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

func (h *Boards) PostInit() error {
  return h.server.Register("depart", h.Handle)
}

func (h *Boards) Handle(ctx context.Context) error {
  resp := command.GetResponse(ctx)

  args := command.GetArgs(ctx)
  if len(args) != 1 {
    resp.Errorf("depart crs")
    return nil
  }
  station := record.Station{CRS: strings.ToUpper(args[0])}

  log.Println("DEPART " + station.CRS)

  sr, err := h.api.ldbClient.GetSchedule(station.CRS)
  if err != nil {
    return err
  }

  log.Printf("Got %d services", len(sr.Services))

  if len(sr.Station) == 0 {
    resp.Errorf("Unknown station %s", station.CRS)
    return nil
  }

  // Create our lookup map by tiploc
  //tMap := record.NewTiplocMap(sr.Tiplocs)
  tMap := record.NewTiplocMap(nil)

  stationTiploc := sr.Station[0]
  if d, ok := sr.Tiplocs.Get(stationTiploc); ok {
    t := tMap.Add(d)
    station.Tiploc = t.Index
  }
  resp.Record(station)

  for i, service := range sr.Services {
    if i < 20 {
      tMap.Import(sr.Tiplocs, service.Origin.Tiploc)
      tMap.Import(sr.Tiplocs, service.Dest.Tiploc)
      tMap.Import(sr.Tiplocs, service.Terminates.Tiploc)
      s := record.NewService(i, service, tMap)
      resp.Record(s)
    }
  }

  for i, msg := range sr.Messages {
    resp.Record(&record.Message{Msg: msg, Index: i})
  }

  tMap.Append(resp)

  return nil
}
