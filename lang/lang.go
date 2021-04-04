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
	TokenMessage    = 130 // Station Message
)

// Block is a series of lines
type Block struct {
	lines []Line
}

func (p *Block) Append(l ...Line) *Block {
	p.lines = append(p.lines, l...)
	return p
}

func (p *Block) Error(f string, a ...interface{}) *Block {
	return p.Append(Error(fmt.Sprintf(f, a...)))
}

// Compile compiles the program into it's binary equivalent.
func (p *Block) Compile(address uint16) []byte {
	var response []byte
	sl := len(p.lines) - 1
	for i, l := range p.lines {
		bl := l.Compile(address)

		// Update address to point to next one
		if i == sl {
			// last line has 0 for the next address
			address = 0
		} else {
			// Next address, including 2 bytes for address
			address = address + 2 + uint16(len(bl))
		}

		// Fix address
		bl[0] = uint8(address & 0xFF)
		bl[1] = uint8((address >> 8) & 0xFF)

		response = append(response, bl...)
	}

	// Add terminator of address 0x0000
	return append(response, 0, 0)
}

func AppendHeader(r []byte, token uint8) []byte {
	// 0,0 are for the next address which gets filled in later
	return append(r, 0, 0, token)
}

func AppendAddress(r []byte, address uint16) []byte {
	return append(r, uint8(address&0xFF), uint8((address>>8)&0xFF))
}

func NullString(s string) []byte {
	return append([]byte(s), 0)
}

// Line is a line in a Block
type Line interface {
	Compile(address uint16) []byte
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
