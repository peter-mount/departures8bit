package lang

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
	r = append(r, Pad(l.crs, 3)...)    // CRS 3 max
	r = append(r, Pad(l.tiploc, 7)...) // tiploc 7 max
	r = append(r, l.name...)           // name any length
	return append(r, 0)
}
