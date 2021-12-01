package record

import (
  "fmt"
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

func (t Message) Record() command.Record {
  msg := t.Msg.Message
  r, _ := regexp.Compile("<.+?>")
  msg = r.ReplaceAllString(msg, "")
  log.Println(msg)
  return command.Record{
    Type: fmt.Sprintf("M%02X",t.Index),
    Data: fmt.Sprintf(
      "%02d%-3.3s%s",
      t.Msg.Severity,
      strings.ToUpper(t.Msg.Category),
      msg,
    ),
  }
}
