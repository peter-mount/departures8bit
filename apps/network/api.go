package network

import (
	"io"
	"log"
)

const (
	BlockSize      = 128 // Max size of data in a block, must match that in api.asm
	SOH       byte = 0x01
	STX       byte = 0x02
	EOT       byte = 0x04
	ACK       byte = 0x06
	NAK       byte = 0x15
	SUB       byte = 0x26
)

// Block is the data sent to the client.
// The format of this is critical as it must be acceptable by api.asm
type Block []byte

// Response is a slice of blocks to be sent to the client
type Response []Block

func NewBlock(blockNumber, blockCount int, payload []byte) Block {
	l := len(payload)
	// Should not happen but truncate payload at BlockSize
	if l > BlockSize {
		l = BlockSize
	}

	// Again this mush match api.asm. This is the raw stream sent to the client.
	block := Block{
		SOH,                      // Start block header
		byte(blockNumber & 0xFF), // Block number
		byte(blockCount & 0xFF),  // Block count
		byte(l),                  // Block length
	}

	block = append(block, payload[0:l]...) // Block data

	return block
}

// SplitBytes splits a byte slice into a slice of blocks
func SplitBytes(b []byte) Response {
	var r Response
	l := len(b)

	// First block contains the details of how many blocks in the response
	nb := 1 + (l / BlockSize)

	n := 0 // Start block id at 0
	p := 0 // Position in src slice
	for p < l {
		// Get this block's length, usually BlockSize except for the last block
		bl := l - p
		if bl > BlockSize {
			bl = BlockSize
		}

		r = append(r, NewBlock(n, nb, b[p:p+bl]))

		// next block
		n++
		p += bl
	}

	return r
}

func (b Block) send(o io.Writer) error {
	log.Printf("Sending block %d", b[0])
	_, err := o.Write(b)
	return err
}

func (r Response) Send(i io.Reader, o io.Writer) error {
	log.Printf("Sending %d blocks", len(r))

	curBlock := 0
	numBlock := len(r)
	for curBlock < numBlock {
		oBuffer := make([]byte, 1)

		// Wait for NAK or ACK
		_, err := i.Read(oBuffer)

		if err == nil {
			switch {
			case oBuffer[0] == NAK:
				log.Printf("NAK block %d/%d", curBlock, numBlock)
				err = r[curBlock].send(o)
			case oBuffer[0] == ACK:
				log.Printf("ACK block %d/%d", curBlock, numBlock)
				curBlock++
				if curBlock < numBlock {
					err = r[curBlock].send(o)
				}
			default:
				// do nothing
			}
		}

		if err != nil {
			log.Println("Rcv err", err)
			return err
		}
	}

	log.Printf("Sent %d blocks", len(r))
	return nil
}
