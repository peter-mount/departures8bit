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
	if len(args) != 1 {
		_, err := stdout.Write([]byte("ERR depart crs"))
		return err
	}
	crs := strings.ToUpper(args[0])

	log.Println("DEPART " + crs)

	sr, err := h.server.ldbClient.GetSchedule(crs)
	if err != nil {
		return err
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

	err = h.server.Record(stdout, "STN%03s%-16.16s%03d\n", crs, stationName, len(sr.Services))
	if err != nil {
		return err
	}

	return h.server.End(stdout)
}
