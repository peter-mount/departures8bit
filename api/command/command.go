package command

import (
	"context"
	"fmt"
	"github.com/reiver/go-telnet"
	"io"
	"log"
	"strings"
)

type Server struct {
	commands    map[string]Handler // Map of available commands
	preCommand  Handler            // Command to run on connection
	postCommand Handler            // Command to run on disconnection
}

func (a *Server) Name() string {
	return "CommandServer"
}

func (a *Server) PostInit() error {
	a.commands = make(map[string]Handler)
	return nil
}

func (a *Server) Register(name string, handler Handler) error {
	if _, exists := a.commands[name]; exists {
		return fmt.Errorf("handler %s already registered", name)
	}
	a.commands[name] = handler
	return nil
}

func (a *Server) OnConnect(h Handler) {
	a.preCommand = a.preCommand.Then(h)
}

func (a *Server) Shell(ctx context.Context, writer telnet.Writer, reader telnet.Reader) error {
	if a.preCommand != nil {
		r := NewResponse(reader, writer)
		err := a.preCommand.
			With("response", r).
			OnSuccess(r.Success).
			Do(ctx)
		if err != nil {
			return err
		}
	}

	if a.postCommand != nil {
		defer func() {
			r := NewResponse(reader, writer)
			_ = a.postCommand.
				With("response", r).
				OnSuccess(r.Success).
				Do(ctx)
		}()
	}

	for true {
		err := a.Exec(context.Background(), writer, reader)
		if err != nil {
			log.Println(err)
			if err == io.EOF {
				return nil
			}
		}
	}

	return nil
}

func (a *Server) Exec(ctx context.Context, writer telnet.Writer, reader telnet.Reader) error {
	resp := NewResponse(reader, writer)

	l, err := a.readLine(reader)
	if err == nil && l != "" {
		args := strings.Split(l, " ")

		log.Println(args)
		if cmd, ok := a.commands[args[0]]; ok {
			err = cmd.
				With("args", args[1:]).
				With("response", resp).
				OnError(resp.Error).
				OnSuccess(resp.Success).
				Do(ctx)
		} else {
			resp.Errorf("Unknown command %s", args[0])
			err = resp.Send()
		}
	}
	if err != nil {
		log.Println(err)
	}
	return err
}

func (a *Server) readLine(reader io.Reader) (string, error) {
	var s []byte
	b := []byte{0}
	for true {
		n, err := reader.Read(b)
		//log.Printf("%02d %02d %02x %s", len(s), n, b[0], s)
		if err != nil {
			return "", err
		}
		if n == 1 {
			c := b[0]
			if c == '\n' {
				return string(s[:]), nil
			}

			if c >= ' ' && c < 127 {
				s = append(s, c)
			}
		}
	}
	return string(s[:]), nil
}

func GetArgs(ctx context.Context) []string {
	return ctx.Value("args").([]string)
}
