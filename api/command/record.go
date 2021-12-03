package command

import (
	"fmt"
	"github.com/peter-mount/nre-feeds/util"
	"time"
)

type Record struct {
	data []byte
}

type RecordSource interface {
	Record() *Record
}

func NewRecord() *Record {
	return &Record{}
}

func (r *Record) Bytes() []byte {
	return r.data
}

func (r *Record) Sum() byte {
	c := 0
	for _, e := range r.data {
		c = (c + int(e)) & 0xff
	}
	return byte(c & 0xff)
}

func (r *Record) Append(v ...byte) *Record {
	r.data = append(r.data, v...)
	return r
}

func (r *Record) String(v string) *Record {
	return r.Append([]byte(v)...)
}

func (r *Record) StringN(v string, n int, p byte) *Record {
	if len(v) > n {
		v = v[:n]
	}
	r.String(v)
	for i := len(v); i < n; i++ {
		r.Append(p)
	}
	return r
}

func (r *Record) Stringf(f string, a ...interface{}) *Record {
	return r.String(fmt.Sprintf(f, a...))
}

func (r *Record) Command(c byte, i int) *Record {
	return r.Append(c, byte(i&0xff))
}

func (r *Record) Byte(v ...int) *Record {
	for _, e := range v {
		r.Append(byte(e))
	}
	return r
}

func (r *Record) Word(v ...int) *Record {
	for _, e := range v {
		r.Append(byte(e&0xff), byte((e>>8)&0xff))
	}
	return r
}

func (r *Record) SignedWord(v ...int) *Record {
	for _, e := range v {
		n := e
		s := false
		if n < 0 {
			n = -n
			s = true
		}
		h := e & 0x7f
		if s {
			h = h + 0x80
		}
		l := (e >> 8) & 0xff
		r.Append(byte(l), byte(h))
	}
	return r
}

func (r *Record) Long(v ...int) *Record {
	for _, e := range v {
		r.Append(byte(e&0xff), byte((e>>8)&0xff), byte((e>>16)&0xff), byte((e>>24)&0xff))
	}
	return r
}

func (r *Record) Time(t time.Time) *Record {
	return r.Byte(t.Hour(), t.Minute(), t.Second())
}

func (r *Record) WorkingTime(t util.WorkingTime) *Record {
	it := t.Get()
	return r.Byte(it/3600, (it/60)%60, it%60)
}
