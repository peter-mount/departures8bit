package record

import (
  "github.com/peter-mount/departures8bit/api/command"
  "github.com/peter-mount/nre-feeds/darwind3"
  "github.com/peter-mount/nre-feeds/darwinref"
)

type Reason struct {
  Index  int
  Reason *darwinref.Reason
}

func (t Reason) Record() *command.Record {
  return command.NewRecord().
    Command('R', t.Index).
    String(t.Reason.Text)
}

type ReasonMap struct {
  m []Reason
}

func NewReasonMap(s *darwinref.ReasonMap) *ReasonMap {
  m := &ReasonMap{}

  if s!=nil {
    for _, r := range s.Late {
      m.Add(r)
    }
    for _, r := range s.Cancelled {
      m.Add(r)
    }
  }

  return m
}

func (m *ReasonMap) Add(r *darwinref.Reason) {
  for _, e := range m.m {
    if e.Reason.Code == r.Code && e.Reason.Cancelled == r.Cancelled {
      return
    }
  }

  // Note ID starts from 1 as 0 means no reason
  id := len(m.m) + 1
  m.m = append(m.m, Reason{Index: id, Reason: r})
}

func (m *ReasonMap) Resolve(can bool, r darwind3.DisruptionReason) int {
  if r.Reason==0 {
    return 0
  }

  for _, e := range m.m {
    if e.Reason.Code == r.Reason && e.Reason.Cancelled == can {
      return e.Index
    }
  }

  return 0
}

func (m *ReasonMap) Append(r *command.Response) {
  for _, e := range m.m {
    r.Record(e)
  }
}
