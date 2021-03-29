#
# Makefile for departures8bit
#
#

# Directory to write binaries
export BUILDS = $(shell pwd)/builds

export BEEBASM = beebasm
export GO = go

export GOOS		= linux
export GOARCH	?= amd64
export GOARM	?=

export VERSION = 1.01 ($(shell date "+%d %b %Y"))
export COPYRIGHT = $(shell date "+%Y")

.PHONY:	all clean

# Build everything
all:
	@mkdir -pv $(BUILDS)
	@$(MAKE) -C api
	@$(MAKE) -C apps

clean:
	@$(MAKE) -C api clean
	@$(MAKE) -C apps clean
	$(RM) $(BUILDS)/*


testc64: clean all
	x64sc -verbose ./builds/depart.d64
