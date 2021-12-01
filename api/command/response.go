package command

import (
  "context"
  "fmt"
  "io"
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
  if r.Type == "" {
    return r.Data
  }
  return fmt.Sprintf("%-3.3s%s", r.Type, r.Data)
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
  c := len(r.records)
  for n, l := range r.records {
    if err := r.send(n, c, l); err != nil {
      return err
    }
  }

  return nil
}

func (r *Response) send(n, c int, rec Record) error {
  // Block data
  s := rec.String()
  d := []byte(s)
  cSum := 0
  for _, v := range d {
    cSum = (cSum + int(v)) & 0xFF
  }

  // Block of number/count length & checkSum of data wrapped in STX/ETX
  var b []byte
  b = append(b, 0x02, byte(n+1), byte(c), byte(len(d)), byte(cSum))
  b = append(b, d...)
  //b = append(b, 0x03)

  v := []byte{0}
  for v[0] != 0x06 {
    // Log and send the block
    fmt.Printf("Send %02X %02X %02X %02X %s\n", b[1], b[2], b[3], b[4], s)
    _, err := r.o.Write(b)
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
    }
  }

  return nil
}
