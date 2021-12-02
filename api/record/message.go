package record

import (
	"github.com/peter-mount/departures8bit/api/command"
	"github.com/peter-mount/nre-feeds/darwind3"
	"log"
	"regexp"
	"strings"
)

type Message struct {
	Msg   *darwind3.StationMessage
	Index int
}

// Record generates the record
//
// 00 2 M#      Message & index
// 02 1 int     Severity 0..255
// 03 3 byte    Category
// 06 n string  Message content
//
func (t Message) Record() *command.Record {
	msg := t.Msg.Message
	r, _ := regexp.Compile("<.+?>")
	msg = r.ReplaceAllString(msg, "")
	log.Println(msg)
	return command.NewRecord().
		Command('M', t.Index).
		Byte(t.Msg.Severity).
		StringN(strings.ToUpper(t.Msg.Category), 3, 0).
		String(msg)
}
