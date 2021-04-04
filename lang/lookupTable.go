package lang

// LookupTable a lookup table for cross referencing data
type LookupTable struct {
	token uint8          // Token id
	data  [][]byte       // map of data in table
	keys  map[string]int // map of keys to indices
}

func NewLookupTable(token uint8) *LookupTable {
	return &LookupTable{
		token: token,
		keys:  make(map[string]int),
	}
}

// Add a key to the table
// Returns the index of the key and true if a new entry, false if already exists
func (t *LookupTable) Add(key string, value []byte) (int, bool) {
	if i, exists := t.keys[key]; exists {
		return i, false
	}

	index := len(t.data)
	t.data = append(t.data, value)
	t.keys[key] = index

	return index, true
}

func (t *LookupTable) Lookup(key string) (int, bool) {
	i, e := t.keys[key]
	return i, e
}

func (t *LookupTable) Compile(address uint16) []byte {
	var r []byte

	r = AppendHeader(r, t.token)

	l := len(t.data)
	r = append(r, uint8(l)) // Number of entries in table

	// offset to start of data after index
	a := address + uint16(len(r)) + uint16(2*l)

	// Index of entries
	for _, v := range t.data {
		r = AppendAddress(r, a)
		a = a + uint16(len(v))
	}

	// The data
	for _, v := range t.data {
		r = append(r, v...)
	}

	return r
}
