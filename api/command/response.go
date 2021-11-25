package command

import (
	"context"
	"fmt"
	"io"
	"strconv"
)

type Response struct {
	i       io.Reader
	o       io.Writer
	records []Record
}

type Record struct {
	Type string
	Data string
}

type RecordSource interface {
	Record() Record
}

func (r Record) String() string {
	return fmt.Sprintf("%-3.3s%s\n", r.Type, r.Data)
}

var endRec = Record{"END", ""}

func GetResponse(ctx context.Context) *Response {
	return ctx.Value("response").(*Response)
}

func NewResponse(i io.Reader, o io.Writer) *Response {
	return &Response{
		i: i,
		o: o,
	}
}

func (r *Response) Inf(f string, a ...interface{}) *Response {
	return r.Append("INF", f, a...)
}

func (r *Response) Error(ctx context.Context) error {
	return r.Errorf("%v", ctx.Value("err")).Send()
}

func (r *Response) Errorf(f string, a ...interface{}) *Response {
	return r.Append("ERR", f, a...)
}

func (r *Response) Append(t, f string, a ...interface{}) *Response {
	r.records = append(r.records, Record{Type: t, Data: fmt.Sprintf(f, a...)})
	return r
}

func (r *Response) Record(rec RecordSource) *Response {
	if rec != nil {
		return r.RecordRaw(rec.Record())
	}
	return r
}

func (r *Response) RecordRaw(rec Record) *Response {
	r.records = append(r.records, rec)
	return r
}

func (r *Response) Success(_ context.Context) error {
	return r.Send()
}

func (r *Response) Send() error {
	return r.SendImpl(r.i, r.o)
}

func (r *Response) SendImpl(i io.Reader, o io.Writer) error {
	// Send LEN with number of lines following
	if err := r.send(o, Record{
		Type: "LEN",
		Data: strconv.Itoa(len(r.records)),
	}); err != nil {
		return err
	}

	for _, l := range r.records {
		if err := r.send(o, l); err != nil {
			return err
		}
	}

	return nil //r.send(o, endRec)
}

func (r *Response) send(w io.Writer, rec Record) error {
	_, err := w.Write([]byte(rec.String()))
	return err
}
