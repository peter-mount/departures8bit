package command

import (
	"context"
	"fmt"
	"io"
	"log"
	"strings"
)

type Response struct {
	i       io.Reader
	o       io.Writer
	records []*Record
}

func GetResponse(ctx context.Context) *Response {
	return ctx.Value("response").(*Response)
}

func NewResponse(i io.Reader, o io.Writer) *Response {
	return &Response{
		i: i,
		o: o,
	}
}

func (r *Response) Error(ctx context.Context) error {
	return r.Errorf("%v", ctx.Value("err")).Send()
}

func (r *Response) Errorf(f string, a ...interface{}) *Response {
	return r.RecordRaw(NewRecord().Append('E').Stringf(f, a...))
}

func (r *Response) Record(rec RecordSource) *Response {
	if rec != nil {
		r.RecordRaw(rec.Record())
	}
	return r
}

func (r *Response) RecordRaw(rec *Record) *Response {
	r.records = append(r.records, rec)
	return r
}

func (r *Response) Success(_ context.Context) error {
	return r.Send()
}

func (r *Response) Send() error {
	c := len(r.records)
	for n, l := range r.records {
		if err := r.send(n, c, l); err != nil {
			return err
		}
	}

	return nil
}

func (r *Response) send(n, c int, rec *Record) error {
	// Block data
	d := rec.Bytes()
	cSum := rec.Sum()

	// Block of number/count length & checkSum of data with STX at start
	var b []byte
	b = append(b, 0x02, byte(n+1), byte(c), byte(len(d)), cSum)
	b = append(b, d...)

	// Due to the Spectrum IF1 unable to read 0x00 values we have to add an encoding scheme.
	// So of we have a 0 then we write 0xFF, 0x01.
	// To support 0xFF we send 0xFF,0x02.
	var b1 []byte
	for _, e := range b {
		switch e {
		case 0:
			b1 = append(b1, 0xFF, 0x01)
		case 0xff:
			b1 = append(b1, 0xFF, 0x02)
		default:
			b1 = append(b1, e)
		}
	}

	v := []byte{0}
	for v[0] != 0x06 {
		// Log and send the block data
		debug(n, b)

		_, err := r.o.Write(b1)
		if err != nil {
			return err
		}

		// Loop until we get an ACK
		v[0] = 0
		for v[0] != 0x06 && v[0] != 0x15 {
			_, err := r.i.Read(v)
			if err != nil {
				return err
			}
			switch v[0] {
			case 0x06:
				//fmt.Println("ACK")
			case 0x15:
				fmt.Println("NAK")
			default:
				log.Printf("%02X %q", v[0], v[0])
			}
		}
	}

	return nil
}

const (
	debugWidth = 16 // Width in bytes
)

func debugHeader() {

	fmt.Print("| Bk Of | ")
	for j := 0; j < debugWidth; j++ {
		fmt.Printf("+%X ", j)
	}
	fmt.Print("| ")
	for j := 0; j < debugWidth; j++ {
		fmt.Printf("%X", j)
	}
	fmt.Println(" |")

	debugSep()
}

func debug(blockId int, b []byte) {
	if (blockId % 8) == 0 {
		debugHeader()
	}

	l := len(b) // total length

	for i := 0; i < l; i += debugWidth {
		fmt.Printf("| %02X %02X | ", blockId+1, i)
		for j := 0; j < debugWidth; j++ {
			p := i + j
			if p >= l {
				fmt.Print("   ")
			} else {
				fmt.Printf("%02X ", b[p])
			}
		}
		fmt.Print("| ")
		for j := 0; j < debugWidth; j++ {
			p := i + j
			if p >= l {
				fmt.Print(" ")
			} else if b[p] >= 0x20 && b[p] < 127 {
				fmt.Printf("%c", b[p])
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println(" |")
	}
	debugSep()
}

func debugSep() {
	fmt.Printf("+-------+-%s+-%s-+\n", strings.Repeat("-", 3*debugWidth), strings.Repeat("-", debugWidth))
}
