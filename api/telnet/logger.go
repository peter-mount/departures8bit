package telnet

import "log"

type Logger struct{}

func (Logger) Debug(a ...interface{}) {
	log.Println(a...)
}
func (Logger) Debugf(f string, a ...interface{}) {
	log.Printf(f, a...)
}
func (Logger) Debugln(a ...interface{}) {
	log.Println(a...)
}

func (Logger) Error(a ...interface{}) {
	log.Println(a...)
}
func (Logger) Errorf(f string, a ...interface{}) {
	log.Printf(f, a...)
}
func (Logger) Errorln(a ...interface{}) {
	log.Println(a...)
}

func (Logger) Trace(a ...interface{}) {
	log.Println(a...)
}
func (Logger) Tracef(f string, a ...interface{}) {
	log.Printf(f, a...)
}
func (Logger) Traceln(a ...interface{}) {
	log.Println(a...)
}

func (Logger) Warn(a ...interface{}) {
	log.Println(a...)
}
func (Logger) Warnf(f string, a ...interface{}) {
	log.Printf(f, a...)
}
func (Logger) Warnln(a ...interface{}) {
	log.Println(a...)
}
