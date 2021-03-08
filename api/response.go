package api

import (
	"fmt"
	"github.com/peter-mount/departures8bit/apps/network"
	"io"
)

type Response struct {
	i       io.ReadCloser
	o       io.WriteCloser
	records []string
}

func NewResponse(i io.ReadCloser, o io.WriteCloser) *Response {
	return &Response{
		i: i,
		o: o,
	}
}

func (r *Response) Append(f string, a ...interface{}) *Response {
	r.records = append(r.records, fmt.Sprintf(f, a...))
	return r
}

// generateLines converts a slice of strings in to a byte array.
// Each line consists of a 16 bit (little endian) address of the start
// from the beginning of the response, followed by the line and a 0 terminator.
func generateLines(s []string) []byte {
	var response []byte
	addr := uint(0)
	sl := len(s) - 1
	for i, l := range s {
		// Update address to point to next one
		if i == sl {
			addr = 0 // last line has 0 for the next address
		} else {
			// Next address, including 2 bytes for address & 1 for terminator
			addr = addr + 2 + uint(len(l)) + 1
		}

		// 2 byte address of next record
		response = append(response, byte(addr&0xff), byte((addr>>8)&0xff))
		// Record content
		response = append(response, l...)
		// Record terminator
		response = append(response, 0)

	}

	// Add terminator of address 0x0000
	return append(response, 0, 0)
}

func (r *Response) Send() error {
	return r.SendImpl(r.i, r.o)
}

func (r *Response) SendImpl(i io.Reader, o io.Writer) error {
	resp := network.SplitBytes(generateLines(r.records))
	return resp.Send(i, o)
}
