package api

import (
	"github.com/peter-mount/go-kernel"
)

type ApiCore struct {
}

func (a *ApiCore) Name() string {
	return "ApiCore"
}

func (a *ApiCore) Init(k *kernel.Kernel) error {
	/*
		service, err := k.AddService(&rest.Server{})
		if err != nil {
			return err
		}
		a.restService = (service).(*rest.Server)
	*/

	return nil
}
