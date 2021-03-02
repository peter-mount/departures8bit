package api

import "log"

type TelnetLogger struct{}

func (TelnetLogger) Debug(a ...interface{}) {
	log.Println(a...)
}
func (TelnetLogger) Debugf(f string, a ...interface{}) {
	log.Printf(f, a...)
}
func (TelnetLogger) Debugln(a ...interface{}) {
	log.Println(a...)
}

func (TelnetLogger) Error(a ...interface{}) {
	log.Println(a...)
}
func (TelnetLogger) Errorf(f string, a ...interface{}) {
	log.Printf(f, a...)
}
func (TelnetLogger) Errorln(a ...interface{}) {
	log.Println(a...)
}

func (TelnetLogger) Trace(a ...interface{}) {
	log.Println(a...)
}
func (TelnetLogger) Tracef(f string, a ...interface{}) {
	log.Printf(f, a...)
}
func (TelnetLogger) Traceln(a ...interface{}) {
	log.Println(a...)
}

func (TelnetLogger) Warn(a ...interface{}) {
	log.Println(a...)
}
func (TelnetLogger) Warnf(f string, a ...interface{}) {
	log.Printf(f, a...)
}
func (TelnetLogger) Warnln(a ...interface{}) {
	log.Println(a...)
}
