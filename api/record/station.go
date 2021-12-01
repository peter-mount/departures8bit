package record

import (
  "fmt"
  "github.com/peter-mount/departures8bit/api/command"
)

type Station struct {
  CRS    string
  Tiploc int
  Index  int
}

func (s Station) Record() command.Record {
  return command.Record{
    Type: fmt.Sprintf("S%02X",s.Index),
    Data: s.CRS,
  }
}
