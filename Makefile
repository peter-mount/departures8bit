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
	@$(MAKE) -C apps/bbc
	@$(MAKE) -C apps/c64

clean:
	@$(MAKE) -C api clean
	@$(MAKE) -C apps/c64 clean
	$(RM) $(BUILDS)/*
