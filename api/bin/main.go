package main

import (
	"github.com/peter-mount/departures8bit/api"
	"github.com/peter-mount/go-kernel"
	"log"
)

func main() {
	err := kernel.Launch(
		&api.TelnetServer{},
		&api.ApiCore{},
		&api.Boards{},
		&api.Helo{},
	)
	if err != nil {
		log.Fatal(err)
	}
}
