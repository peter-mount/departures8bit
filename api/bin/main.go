package main

import (
	"github.com/peter-mount/departures8bit/api"
	"github.com/peter-mount/departures8bit/api/fifo"
	"github.com/peter-mount/departures8bit/api/telnet"
	"github.com/peter-mount/go-kernel"
	"log"
)

func main() {
	err := kernel.Launch(
		&api.ApiCore{},
		// Available servers
		&telnet.Server{},
		&fifo.Server{},
		// Various API commands
		&api.Boards{},
		&api.Helo{},
	)
	if err != nil {
		log.Fatal(err)
	}
}
