package lang

import (
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
	r = append(r, Pad(l.tiploc, 7)...) // Tiploc 7 chars max
	r = append(r, Pad(l.crs, 3)...)    // CRS 3 chars max
	r = append(r, Pad(l.toc, 2)...)    // TOC 2 chars max
	r = append(r, l.name...)           // Name can be any lentgth
	return append(r, 0)
}

func (p *Block) AppendTiplocs(m *darwinref.LocationMap) {
	m.ForEach(func(location *darwinref.Location) {
		p.Append(NewTiploc(location))
	})
}
