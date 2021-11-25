package command

import "context"

type Handler func(ctx context.Context) error

func (a Handler) Do(ctx context.Context) error {
	if a == nil {
		return nil
	}
	return a(ctx)
}

func (a Handler) Then(b Handler) Handler {
	if a == nil {
		return b
	}
	if b == nil {
		return a
	}
	return func(ctx context.Context) error {
		err := a(ctx)
		if err == nil {
			err = b(ctx)
		}
		return err
	}
}

func (a Handler) With(k string, v interface{}) Handler {
	return func(ctx context.Context) error {
		return a.Do(context.WithValue(ctx, k, v))
	}
}

func (a Handler) OnError(b Handler) Handler {
	return func(ctx context.Context) error {
		err := a.Do(ctx)
		if err != nil {
			_ = b.With("err", err).Do(ctx)
		}
		return err
	}
}

func (a Handler) OnSuccess(b Handler) Handler {
	return func(ctx context.Context) error {
		err := a.Do(ctx)
		if err == nil {
			err = b.With("err", err).Do(ctx)
		}
		return err
	}
}
