package lang

// Tokens for our pseudo language
// Note These are dependent on lang.asm so don't change the values.
//
// DO NOT REMOVE an entry as this means that all deployed instances in the wild
// will break as there's no versioning in the protocol!

const (
	TokenNoResponse = 0 // Built in error on client side, not normally sent from server
	TokenError      = 1 // Error, show an error message
)

// Program is a series of lines
type Program []Line

// Compile compiles the program into it's binary equivalent.
func (p *Program) Compile() []byte {
	var response []byte
	addr := uint(0)
	sl := len(*p) - 1
	for i, l := range *p {
		bl := l.Compile()

		// Update address to point to next one
		if i == sl {
			// last line has 0 for the next address
			addr = 0
		} else {
			// Next address, including 2 bytes for address & 1 for terminator
			addr = addr + 2 + uint(len(bl)) + 1
		}

		response = append(response, byte(addr&0xff), byte((addr>>8)&0xff))
		response = append(response, bl...)
	}

	// Add terminator of address 0x0000
	return append(response, 0, 0)
}

// Line is a line in a Program
type Line interface {
	Compile() []byte
}

// Remark is a basic line of text which is ignored
type Error string

func (l Error) Compile() []byte {
	return append([]byte{TokenError}, string(l)[:]...)
}
