package record

import (
	"github.com/peter-mount/departures8bit/api/command"
)

type Station struct {
	CRS    string
	Tiploc int
	Index  int
}

// Record generates the record
//
// 00 2 S#      Station & index
// 02 n string  CRS code
//
func (s Station) Record() *command.Record {
	return command.NewRecord().
		Command('S', s.Index).
		String(s.CRS)
}
