#
# Makefile for departures8bit
#
#

# Directory to write binaries
export BUILDS			= $(shell pwd)/builds
export BUILDS_C64		= $(BUILDS)/c64
export BUILDS_BBC		= $(BUILDS)/bbc

export CP				= @cp -p
export MKDIR			= @mkdir -p -v

# BEEBASM & platform specific flags
export BEEBASM 			= beebasm
export BEEBASM_FLAGS	= -w
export C64_FLAGS		= $(BEEBASM_FLAGS) -D bbc=0 -D bbcmaster=0 -D c64=1
export BBC_B_FLAGS		= $(BEEBASM_FLAGS) -D bbc=1 -D bbcmaster=0 -D c64=0
export BBC_MASTER_FLAGS	= $(BEEBASM_FLAGS) -D bbc=1 -D bbcmaster=1 -D c64=0

export GO		 		= go
export GOOS				= linux
export GOARCH			?= amd64
export GOARM			?=

# c1541 in vice emulator required to build 1541 disk images
export C1541			= c1541

export VERSION 			= 1.01 ($(shell date "+%d %b %Y"))
export COPYRIGHT 		= $(shell date "+%Y")

.PHONY:	all clean

# Build everything
all:
	$(MKDIR) -pv $(BUILDS) $(BUILDS_C64) $(BUILDS_BBC)
	@$(MAKE) -C apps
	@$(MAKE) -C api

clean:
	@$(MAKE) -C apps clean
	@$(MAKE) -C api clean
	$(RM) -r $(BUILDS)

testc64: clean all
	x64sc -verbose -statusbar ./builds/depart.d64
