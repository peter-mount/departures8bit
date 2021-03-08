package lang

import "fmt"

// Tokens for our pseudo language
// Note These are dependent on lang.asm so don't change the values.
//
// DO NOT REMOVE an entry as this means that all deployed instances in the wild
// will break as there's no versioning in the protocol!

const (
	TokenNoResponse = 0   // Built in error on client side, not normally sent from server
	TokenError      = 1   // Error, show an error message
	TokenStation    = 128 // Station name, used in headers for boards
	TokenTiploc     = 129 // Tiploc lookup entry
)

// Program is a series of lines
type Program struct {
	lines []Line
}

func (p *Program) Append(l ...Line) *Program {
	p.lines = append(p.lines, l...)
	return p
}

func (p *Program) Error(f string, a ...interface{}) *Program {
	return p.Append(Error(fmt.Sprintf(f, a...)))
}

// Compile compiles the program into it's binary equivalent.
func (p *Program) Compile() []byte {
	var response []byte
	addr := uint(0)
	sl := len(p.lines) - 1
	for i, l := range p.lines {
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

func Pad(s string, l int) []byte {
	b := []byte(s)
	if len(b) > l {
		b = b[:l]
	}
	for len(b) < l {
		b = append(b, 0)
	}
	return b
}
