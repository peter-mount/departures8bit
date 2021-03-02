package api

import (
	"fmt"
	"io"
	"log"
	"strings"
)

type Response struct {
	records []string
}

func NewResponse() *Response {
	return &Response{}
}

func (r *Response) Append(f string, a ...interface{}) *Response {
	r.records = append(r.records, fmt.Sprintf(f, a...))
	return r
}

func (r *Response) Write(o io.WriteCloser) error {
	r.Append("END")
	s := strings.Join(r.records, "\n")
	log.Println("Response\n" + s)
	_, err := o.Write([]byte(s))
	//log.Println(n, len(s), err)
	if err != nil {
		log.Println(err)
	}
	return err
}
