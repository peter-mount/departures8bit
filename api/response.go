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

const (
	BlockSize      = 80 // Block size in responses
	SOH       byte = 0x01
	STX       byte = 0x02
	EOT       byte = 0x04
	ACK       byte = 0x06
	NAK       byte = 0x15
	SUB       byte = 0x26
	POLL      byte = 'C' //0x43
)

func createBlock(blockNumber, blockCount int, payload []byte) []byte {
	l := len(payload)
	// Should not happen but truncate payload at BlockSize
	if l > BlockSize {
		l = BlockSize
	}
	block := []byte{
		SOH,                      // Start block header
		byte(blockNumber & 0xFF), // Block number
		byte(blockCount & 0xFF),  // Block count
		byte(l),                  // Block length
	}

	block = append(block, payload[0:l]...) // Block data

	// Ensure the block is full size, padd with SUB
	/*
		for ; l < BlockSize; l++ {
			block = append(block, SUB)
		}
	*/

	return block
}

// Convert a byte slice into a series of blocks
func splitBlocks(b []byte) [][]byte {
	var r [][]byte
	l := len(b)

	// First block contains the details of how many blocks in the response
	nb := 2 + (l / BlockSize)

	n := 1 // Start actual payloads from block 1
	p := 0 // Position in src slice
	for p < l {
		// Get this block's length, usually BlockSize except for the last block
		bl := l - p
		if bl > BlockSize {
			bl = BlockSize
		}

		r = append(r, createBlock(n, nb, b[p:p+bl]))

		// next block
		n++
		p += bl
	}

	return r
}

func (r *Response) Send() error {
	return r.SendImpl(r.i, r.o)
}

func (r *Response) SendImpl(i io.Reader, o io.Writer) error {
	blocks := splitBlocks(generateLines(r.records))
	log.Printf("Sending %d records %d blocks", len(r.records), len(blocks))

	curBlock := 0
	for curBlock < len(blocks) {
		oBuffer := make([]byte, 1)

		// Wait for NAK or ACK
		log.Println("block", curBlock, len(blocks))
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
				// do nothing
			}
		}

		if err != nil {
			log.Println("Rcv err", err)
			return err
		}
	}

	log.Printf("Sent %d records %d blocks", len(r.records), len(blocks))
	return nil
}

func sendRawBlock(curBlock int, blocks [][]byte, o io.Writer) error {
	if curBlock < len(blocks) {
		log.Println("Sending block", curBlock)
		_, err := o.Write(blocks[curBlock])
		if err != nil {
			log.Println("Send err", err)
			return err
		}
	}
	return nil
}
