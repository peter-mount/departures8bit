package api

import (
	"github.com/peter-mount/go-kernel"
	"io"
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
	return h.server.RegisterHandlerFunc("depart", h.Handler)
}

func (h *Boards) Handler(stdin io.ReadCloser, stdout io.WriteCloser, stderr io.WriteCloser, args ...string) error {
	response := NewResponse(stdin, stdout)

	if len(args) != 1 {
		return response.Append("ERR depart crs").
			Send()
	}
	crs := strings.ToUpper(args[0])

	log.Println("DEPART " + crs)
	sr, err := h.server.ldbClient.GetSchedule(crs)
	if err != nil {
		return err
	}

	if sr == nil {
		return response.Append("ERRUnknown station %s", crs).
			Send()
	}
	var stationName string
	if len(sr.Station) == 0 {
		stationName = sr.Crs
	} else {
		stationName = sr.Station[0]
	}
	if d, ok := sr.Tiplocs.Get(stationName); ok {
		stationName = d.Name
	}

	response.Append("STN%03s%-16.16s%03d", crs, stationName, len(sr.Services))

	return response.Send()
}
