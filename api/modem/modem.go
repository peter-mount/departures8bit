package modem

import (
	"context"
	"github.com/peter-mount/departures8bit/api/command"
	"github.com/peter-mount/go-kernel"
	"time"
)

// Modem emulates the Hayes AT commands.
// Only of use for testing, this allows us to develop client code directly rather than adding an intermediary
// which is tricky when using fifo's like with Fuse for the Spectrum
type Modem struct {
	server *command.Server
}

func (m *Modem) Name() string {
	return "Modem"
}

func (m *Modem) Init(k *kernel.Kernel) error {
	svce, err := k.AddService(&command.Server{})
	if err != nil {
		return err
	}
	m.server = (svce).(*command.Server)
	return nil
}

func (m *Modem) PostInit() error {
	if err := m.server.Register("ATH", m.ath); err != nil {
		return err
	}

	return m.server.Register("ATDT", m.atd)
}

func (m *Modem) ath(ctx context.Context) error {
	time.Sleep(time.Second)
	command.GetResponse(ctx).RecordRaw(command.NewRecord().String("OK"))
	return nil
}

func (m *Modem) atd(ctx context.Context) error {
	time.Sleep(time.Second)
	command.GetResponse(ctx).RecordRaw(command.NewRecord().String("CONNECTED"))
	return nil
}
