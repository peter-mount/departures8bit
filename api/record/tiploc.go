package record

import (
  "github.com/peter-mount/departures8bit/api/command"
  "github.com/peter-mount/nre-feeds/darwinref"
  "sort"
)

type Tiploc struct {
  Index int
  Loc   *darwinref.Location
}

// Record generates the record
//
// 00 2 T#      Tiploc & index
// 02 n string  Tiploc name
//
func (t Tiploc) Record() *command.Record {
  return command.NewRecord().
    Command('T', t.Index).
    String(t.Loc.Name)
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

func (m *TiplocMap) Add(loc *darwinref.Location) *Tiploc {
  t, exists := m.m[loc.Tiploc]
  if !exists {
    t = &Tiploc{Loc: loc, Index: len(m.m)}
    m.m[loc.Tiploc] = t
  }
  return t
}

func (m *TiplocMap) Import(s *darwinref.LocationMap, tpl string) *Tiploc {
  t, exists := m.m[tpl]
  if !exists {
    loc, exists := s.Get(tpl)
    if exists {
      t = &Tiploc{Loc: loc, Index: len(m.m)}
      m.m[loc.Tiploc] = t
    }
  }
  return t
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
