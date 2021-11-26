package record

import (
	"fmt"
	"github.com/peter-mount/departures8bit/api/command"
	"github.com/peter-mount/nre-feeds/darwinref"
	"sort"
)

type Tiploc struct {
	Index int
	Loc   *darwinref.Location
}

func (t Tiploc) RecordFull() command.Record {
	return command.Record{
		Type: "TPL",
		Data: fmt.Sprintf(
			"%02X%-7.7s%-3.3s%-2.2s%-16.16s",
			t.Index,
			t.Loc.Tiploc,
			t.Loc.Crs,
			t.Loc.Toc,
			t.Loc.Name,
		),
	}
}

func (t Tiploc) Record() command.Record {
	return command.Record{
		Type: "TPL",
		Data: fmt.Sprintf("%02X%-16.16s", t.Index, t.Loc.Name),
	}
}

type TiplocMap struct {
	m map[string]*Tiploc
}

func NewTiplocMap(s *darwinref.LocationMap) *TiplocMap {
	tMap := &TiplocMap{m: make(map[string]*Tiploc)}

	if s != nil {
		s.ForEach(func(location *darwinref.Location) {
			tMap.Add(location)
		})
	}

	return tMap
}

func (m *TiplocMap) Add(loc *darwinref.Location) {
	m.m[loc.Tiploc] = &Tiploc{Loc: loc, Index: len(m.m)}
}

func (m *TiplocMap) Get(tpl string) *Tiploc {
	if t, exists := m.m[tpl]; exists {
		return t
	}
	return nil
}
func (m *TiplocMap) Append(r *command.Response) {
	// Extract the tiplocs
	var tpls []*Tiploc
	for _, t := range m.m {
		tpls = append(tpls, t)
	}

	// Sort by Index to make it potentially quicker client side
	sort.SliceStable(tpls, func(i, j int) bool {
		return tpls[i].Index < tpls[j].Index
	})

	// Append to the result
	for i, t := range tpls {
		t.Index = i
		r.Record(t)
	}
}