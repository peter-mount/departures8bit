package api

import (
	"fmt"
	"io"
	"log"
	"strings"
)

type Response struct {
	rw      *rw
	records []string
}

func NewResponse(i io.ReadCloser, o io.WriteCloser) *Response {
	return &Response{
		rw: &rw{
			i: i,
			o: o,
		},
	}
}

func (r *Response) Append(f string, a ...interface{}) *Response {
	r.records = append(r.records, fmt.Sprintf(f, a...))
	return r
}

func (r *Response) Send() error {
	var response []byte
	addr := uint(0)
	for _, l := range r.records {
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
	response = append(response, 0, 0)

	log.Println("Sending:", strings.Join(r.records, "\n"))
	err := ModemSend(r.rw, response, nil)
	log.Println("Sent", err)
	return err
}

type rw struct {
	i io.ReadCloser
	o io.WriteCloser
}

func (rw *rw) Read(p []byte) (int, error) {
	return rw.i.Read(p)
}
func (rw *rw) Write(p []byte) (int, error) {
	return rw.o.Write(p)
}
func (rw *rw) Close() error {
	return nil
}
