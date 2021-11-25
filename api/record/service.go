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
		Type: "DEP",
		Data: fmt.Sprintf(
			"%02d%-8.8s%-16.16s%02X%02X%02X%-10.10s%-4.4s%-2.2s%s",
			t.Index,
			t.Time,
			t.RID,
			t.Destination,
			t.Origin,
			t.Terminates,
			t.SSD.String(),
			t.TrainId,
			t.Toc,
			t.Type,
		),
	}).RecordRaw(command.Record{
		Type: "DES",
		Data: fmt.Sprintf(
			"%02d%04d%04d",
			t.Index,
			t.Cancel,
			t.Late,
		),
	})
}
