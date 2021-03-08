package lang

import (
	"fmt"
	"github.com/peter-mount/nre-feeds/darwinref"
)

// Station header, holds name of station for a departure board
type Tiploc struct {
	tiploc string `json:"tpl" xml:"tpl,attr"`
	// CRS of this station, "" for none
	crs string `json:"crs,omitempty" xml:"crs,attr,omitempty"`
	// TOC who manages this station
	toc string `json:"toc,omitempty" xml:"toc,attr,omitempty"`
	// Name of this station
	name string `json:"locname" xml:"locname,attr"`
}

func NewTiploc(location *darwinref.Location) *Tiploc {
	return &Tiploc{
		tiploc: location.Tiploc,
		crs:    location.Crs,
		toc:    location.Toc,
		name:   location.Name,
	}
}

func (l Tiploc) Compile() []byte {
	r := []byte{TokenTiploc}
	r = append(r, fmt.Sprintf(
		"%-7.7s%-3.3s%-2.2s%s",
		l.tiploc,
		l.crs,
		l.toc,
		l.name,
	)[:]...)
	return append(r, 0)
}

func (p *Program) AppendTiplocs(m *darwinref.LocationMap) {
	m.ForEach(func(location *darwinref.Location) {
		p.Append(NewTiploc(location))
	})
}
