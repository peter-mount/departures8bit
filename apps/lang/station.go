package lang

import "fmt"

// Station header, holds name of station for a departure board
type Station struct {
	crs    string
	tiploc string
	name   string
}

func NewStation(crs string, tiploc string, name string) *Station {
	return &Station{
		crs:    crs,
		tiploc: tiploc,
		name:   name,
	}
}

func (l Station) Compile() []byte {
	r := []byte{TokenStation}
	r = append(r, fmt.Sprintf(
		"%-3s%-7.7s%s",
		l.crs,
		l.tiploc,
		l.name,
	)[:]...)
	return append(r, 0)
}
