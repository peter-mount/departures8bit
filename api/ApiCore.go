package api

import (
	"github.com/peter-mount/departures8bit/api/command"
	"github.com/peter-mount/go-kernel"
	refclient "github.com/peter-mount/nre-feeds/darwinref/client"
	ldbclient "github.com/peter-mount/nre-feeds/ldb/client"
)

type ApiCore struct {
	refClient refclient.DarwinRefClient // ref api
	ldbClient ldbclient.DarwinLDBClient // ldb api
	commands  *command.Server
}

func (a *ApiCore) Name() string {
	return "ApiCore"
}

func (a *ApiCore) Init(k *kernel.Kernel) error {
	svce, err := k.AddService(&command.Server{})
	if err != nil {
		return err
	}
	a.commands = svce.(*command.Server)
	return nil
}

func (a *ApiCore) PostInit() error {
	a.refClient = refclient.DarwinRefClient{Url: "https://ref.prod.a51.li"}
	a.ldbClient = ldbclient.DarwinLDBClient{Url: "https://ldb.prod.a51.li"}
	return nil
}
