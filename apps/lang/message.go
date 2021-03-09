package lang

import (
	"github.com/peter-mount/nre-feeds/darwind3"
	"strings"
)

// Station header, holds name of station for a departure board
type Message struct {
	message  string
	category string
	severity int
}

func NewMessage(message *darwind3.StationMessage) *Message {
	m := strings.ReplaceAll(message.Message, "<p>", "")
	m = strings.ReplaceAll(m, "</p>", "\n")

	m = strings.Trim(m, "\n")

	return &Message{
		category: message.Category,
		severity: message.Severity,
		message:  m,
	}
}

func (l Message) Compile() []byte {
	r := []byte{TokenMessage}
	r = append(r, Pad(l.category, 2)...) // Tiploc 7 chars max
	r = append(r, uint8(l.severity))     // CRS 3 chars max
	r = append(r, l.message...)          // Name can be any lentgth
	return append(r, 0)
}

func (p *Block) NewMessage(messages []*darwind3.StationMessage) {
	for _, m := range messages {
		p.Append(NewMessage(m))
	}
}
