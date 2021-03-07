package api

import (
	"fmt"
	"io"
	"log"
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
	for _, l := range s {
		ln := uint(len(l))
		addr = addr + ln
		// 2 byte address of next record
		response = append(response, byte(ln&0xff), byte((ln>>8)&0xff))
		// Record content
		response = append(response, l...)
		// Record terminator
		response = append(response, 0)
	}

	// Add terminator of address 0x0000
	return append(response, 0, 0)
}

const (
	BlockSize = 128 // Block size in responses
)

// Convert a byte slice into a series of blocks
func splitBlocks(b []byte) [][]byte {
	var r [][]byte
	l := len(b)

	// First block contains the details of how many blocks in the response
	n := 1 + (l / BlockSize)
	r = append(r, []byte{
		0, 0, // Block 0
		2,              // Block 0 length
		byte(n & 0xff), // Number of blocks
		byte((n >> 8) & 0xff),
	})

	n = 1  // Block 0 is the header
	p := 0 // Position in src slice
	for p < l {
		bl := l - p
		if bl > BlockSize {
			bl = BlockSize
		}

		// Block content
		// 0,1	block number
		// 2	block length
		// 3...	data
		block := []byte{
			byte(n & 0xff),
			byte((n >> 8) & 0xff),
			byte(bl),
		}
		block = append(block, b[p:bl]...)

		r = append(r, block)

		// next block
		n++
		p += BlockSize
	}
	return r
}

func (r *Response) Send() error {
	return r.SendImpl(r.i, r.o)
}

func (r *Response) SendImpl(i io.Reader, o io.Writer) error {
	log.Printf("Send %d records", len(r.records))
	blocks := splitBlocks(generateLines(r.records))
	log.Printf("Sending %d blocks", len(blocks))

	curBlock := 0
	for curBlock < len(blocks) {
		log.Printf("Block %d", curBlock)
		oBuffer := make([]byte, 1)

		// Wait for NAK or ACK
		_, err := i.Read(oBuffer)

		if err == nil {
			switch {
			case oBuffer[0] == NAK:
				log.Println("NAK")
				err = sendRawBlock(curBlock, blocks, o)
			case oBuffer[0] == ACK:
				log.Println("ACK")
				curBlock++
				err = sendRawBlock(curBlock, blocks, o)
			default:
				c := oBuffer[0]
				if c < 32 || c >= 127 {
					c = '*'
				}
				log.Printf("Recv %02x %c", oBuffer[0], c)
			}
		}

		if err != nil {
			log.Println("Rcv err", err)
			return err
		}
	}

	log.Println("Send completed")
	return nil
}

func sendRawBlock(curBlock int, blocks [][]byte, o io.Writer) error {
	if curBlock < len(blocks) {
		log.Println("Sending block", curBlock)
		log.Printf("Sending block %v", blocks[curBlock])
		_, err := o.Write(blocks[curBlock])
		if err != nil {
			log.Println("Send err", err)
			return err
		}
		log.Println("Sent block", curBlock)
	}
	return nil
}
