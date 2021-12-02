package record

import (
  "github.com/peter-mount/departures8bit/api/command"
  "github.com/peter-mount/nre-feeds/ldb"
  "github.com/peter-mount/nre-feeds/util"
  "time"
)

type Service struct {
  Index       int
  RID         string
  Time        util.WorkingTime
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
    Time:        s.Location.Time,
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

// Record generates the record
//
// 00 2 D#      Departure & index
// 02 3 time    Departure time in HMS per byte
// 05 3 time    Expected time in HMS per byte
// 08 4 byte    Platform
// 12 1 tiploc  Tiploc of origin
// 13 1 tiploc  Tiploc of destination
// 14 1 tiploc  Tiploc of terminating location
// 15 1 type    Type of service, ' ', 'C' or 'P'
// 15 2 reason  Cancel reason, 0=none
// 17 2 late    Late reason, 0=none
//
func (t Service) Record() *command.Record {
  return command.NewRecord().
    Command('D', t.Index).
    Time(t.Time.Time(time.Now())).
    Time(t.Time.Time(time.Now())).
    StringN(t.Plat, 4, ' ').
    Byte(t.Origin).
    Byte(t.Destination).
    Byte(t.Terminates).
    StringN(t.Type, 1, ' ').
    Word(t.Cancel).
    Word(t.Late)
}
