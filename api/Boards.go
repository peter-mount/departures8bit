package api

import (
	"github.com/peter-mount/departures8bit/lang"
	"github.com/peter-mount/go-kernel"
	"github.com/peter-mount/nre-feeds/darwinref"
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

func (h *Boards) Handle(prog *lang.Block, args ...string) error {

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

	//var stationTiploc string
	if len(sr.Station) == 0 {
		prog.Error("Unknown station %s", crs)
		return nil
	}

	//stationTiploc = sr.Station[0]
	//stationName := stationTiploc
	//if d, ok := sr.Tiplocs.Get(stationTiploc); ok {
	//	stationName = d.Name
	//}

	//prog.Append(lang.NewStation(crs, stationTiploc, stationName))

	tiplocs := lang.NewLookupTable(lang.TokenTiploc)
	prog.Append(tiplocs)
	if sr.Tiplocs != nil {
		sr.Tiplocs.ForEach(func(location *darwinref.Location) {
			tiplocs.Add(location.Tiploc, lang.NullString(location.Name))
		})
	}

	//prog.AppendTiplocs(sr.Tiplocs)
	//prog.NewMessage(sr.Messages)

	return nil
}
