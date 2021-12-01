package record

import (
  "fmt"
  "github.com/peter-mount/departures8bit/api/command"
  "github.com/peter-mount/nre-feeds/ldb"
  "github.com/peter-mount/nre-feeds/util"
)

type Service struct {
  Index       int
  RID         string
  Time        string
  Origin      int
  Destination int
  Terminates  int
  SSD         util.SSD
  TrainId     string
  Toc         string
  Type        string // P=passenger, C=charter
  Cancel      int
  Late        int
  Plat        string
}

func NewService(i int, s ldb.Service, m *TiplocMap) Service {
  r := Service{
    Index:       i,
    RID:         s.RID,
    Time:        s.Location.Time.String(),
    Origin:      m.Get(s.Origin.Tiploc).Index,
    Destination: m.Get(s.Dest.Tiploc).Index,
    Terminates:  m.Get(s.Terminates.Tiploc).Index,
    SSD:         s.SSD,
    TrainId:     s.TrainId,
    Toc:         s.Toc,
    Cancel:      s.CancelReason.Reason,
    Late:        s.LateReason.Reason,
  }

  if !s.Location.Forecast.Platform.Suppressed && !s.Location.Forecast.Platform.CISSuppressed {
    r.Plat = s.Location.Forecast.Platform.Platform
  }

  if s.PassengerService {
    r.Type = "P"
  }
  if s.Charter {
    r.Type = "C"
  }

  return r
}

func (t Service) Append(r *command.Response) {

  r.RecordRaw(command.Record{
    Type: fmt.Sprintf("D%02X",t.Index),
    Data: fmt.Sprintf(
      "%-5.5s%4.4s%02X%02X%02X%-2.2s%3.3s%02X%02X",
      t.Time,
      t.Plat,
      t.Destination,
      t.Origin,
      t.Terminates,
      t.Toc,
      t.Type,
      t.Cancel,
      t.Late,
    ),
  })
}
