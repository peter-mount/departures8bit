package record

import (
	"fmt"
	"github.com/peter-mount/departures8bit/api/command"
	"github.com/peter-mount/nre-feeds/darwind3"
	"strings"
)

type Message struct {
	Msg *darwind3.StationMessage
}

func (t Message) Record() command.Record {
	return command.Record{
		Type: "STM",
		Data: fmt.Sprintf(
			"%02d%-3.3s%s",
			t.Msg.Severity,
			strings.ToUpper(t.Msg.Category),
			t.Msg.Message, // TODO allow this to break 80 bytes?
		),
	}
}
