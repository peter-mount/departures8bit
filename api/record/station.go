package record

import (
	"fmt"
	"github.com/peter-mount/departures8bit/api/command"
)

type Station struct {
	CRS    string
	Tiploc int
	Name   string
}

func (s Station) Record() command.Record {
	return command.Record{
		Type: "STN",
		Data: fmt.Sprintf(
			"%3.3s%02X%-16.16s",
			s.CRS,
			s.Tiploc,
			s.Name,
		),
	}
}
