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

	if len(sr.Station) == 0 {
		resp.Errorf("Unknown station %s", station.CRS)
		return nil
	}

	// Create our lookup map by tiploc
	tMap := record.NewTiplocMap(sr.Tiplocs)

	stationTiploc := sr.Station[0]
	station.Name = stationTiploc
	if d := tMap.Get(stationTiploc); d != nil {
		station.Name = d.Loc.Name
		station.Tiploc = d.Index
	}

	resp.Record(station)
	tMap.Append(resp)

	for _, msg := range sr.Messages {
		resp.Record(&record.Message{Msg: msg})
	}

	for i, service := range sr.Services {
		if i < 100 {
			s := record.NewService(i, service, tMap)
			s.Append(resp)
		}
	}

	return nil
}
