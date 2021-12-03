package record

import (
	"github.com/peter-mount/departures8bit/api/command"
	"github.com/peter-mount/nre-feeds/ldb"
	"github.com/peter-mount/nre-feeds/util"
)

type Service struct {
	Index       int              // Index in response
	RID         string           // RID
	DTime       util.WorkingTime // Planed departure time
	Time        util.WorkingTime // Expected departure time
	Origin      int              // Origin tiploc
	Destination int              // Destination tiploc
	Terminates  int              // Termination tiploc, overrides destination
	SSD         util.SSD         // SSD
	TrainId     string           // TrainId aka head code
	Toc         string           // TOC
	Type        string           // P=passenger, C=charter
	Cancel      int              // Cancel reason, 0=none
	Late        int              // Late reason, 0=none
	Plat        string           // Platform
	Delay       int              // Delay in minutes
}

func NewService(i int, s ldb.Service, m *TiplocMap) Service {
	s.Location.Times.UpdateTime()
	r := Service{
		Index:       i,
		RID:         s.RID,
		DTime:       s.Location.Times.PublicTime,
		Time:        s.Location.Time,
		Origin:      m.Get(s.Origin.Tiploc).Index,
		Destination: m.Get(s.Dest.Tiploc).Index,
		Terminates:  m.Get(s.Terminates.Tiploc).Index,
		SSD:         s.SSD,
		TrainId:     s.TrainId,
		Toc:         s.Toc,
		Cancel:      s.CancelReason.Reason,
		Late:        s.LateReason.Reason,
		Delay:       s.Location.Delay / 60,
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

	// Right align the platform but leave space on right as rarely used (SHIP)
	// and on Spectrum causes colour clash
	p := t.Plat
	switch len(p) {
	case 1:
		p = "  " + p
	case 2:
		p = " " + p
	}

	return command.NewRecord().
		Command('D', t.Index).
		WorkingTime(t.DTime).
		WorkingTime(t.Time).
		StringN(p, 4, ' ').
		Byte(t.Origin).
		Byte(t.Destination).
		Byte(t.Terminates).
		StringN(t.Type, 1, ' ').
		Word(t.Cancel).
		Word(t.Late).
		SignedWord(t.Delay)
}
