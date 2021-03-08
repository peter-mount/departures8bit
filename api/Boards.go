package api

import (
	"github.com/peter-mount/departures8bit/apps/lang"
	"github.com/peter-mount/go-kernel"
	"log"
	"strings"
)

type Boards struct {
	server *TelnetServer
}

func (h *Boards) Name() string {
	return "Boards"
}

func (h *Boards) Init(k *kernel.Kernel) error {
	svce, err := k.AddService(&TelnetServer{})
	if err != nil {
		return err
	}
	h.server = (svce).(*TelnetServer)
	return nil
}

func (h *Boards) PostInit() error {
	return h.server.Register("depart", h)
}

func (h *Boards) Handle(prog *lang.Program, args ...string) error {

	if len(args) != 1 {
		prog.Error("depart crs")
		return nil
	}
	crs := strings.ToUpper(args[0])

	log.Println("DEPART " + crs)
	sr, err := h.server.ldbClient.GetSchedule(crs)
	if err != nil {
		return err
	}

	if sr == nil {
		prog.Error("Unknown station %s", crs)
		return nil
	}

	var stationName string
	var stationTiploc string
	if len(sr.Station) == 0 {
		stationName = sr.Crs
	} else {
		stationTiploc = sr.Station[0]
	}
	if d, ok := sr.Tiplocs.Get(stationName); ok {
		stationName = d.Name
	}

	prog.Append(lang.NewStation(crs, stationTiploc, stationTiploc))
	prog.AppendTiplocs(sr.Tiplocs)

	return nil
}
