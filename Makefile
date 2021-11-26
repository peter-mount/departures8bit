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

# GO
export GO		 		= go
export GOOS				= linux
export GOARCH			?= amd64
export GOARM			?=

# c1541 in vice emulator required to build 1541 disk images
export C1541			= c1541

# zasm for z80/spectrum
export ZASM				= zasm

export VERSION 			= 1.01 ($(shell date "+%d %b %Y"))
export COPYRIGHT 		= $(shell date "+%Y")

.PHONY:	all clean

# Build everything
all:
	$(MKDIR) -pv $(BUILDS) $(BUILDS_C64) $(BUILDS_BBC)
	@$(MAKE) -C teletext all
	@$(MAKE) -C teletextspectrum all
	@$(MAKE) -C network all
	@$(MAKE) -C boards all
	@$(MAKE) -C c64 all
	#@$(MAKE) -C bbc all
	@$(MAKE) -C spectrum all
	$(GO) mod download
	@$(MAKE) -C api

clean:
	@$(MAKE) -C teletext clean
	@$(MAKE) -C teletextspectrum clean
	@$(MAKE) -C network clean
	@$(MAKE) -C boards clean
	@$(MAKE) -C c64 clean
	#@$(MAKE) -C bbc clean
	@$(MAKE) -C spectrum clean
	@$(MAKE) -C api clean
	$(RM) -r $(BUILDS)
	#$(RM) fuse.rx fuse.tx

# Requires Vice to run in an emulator
testc64: clean all
	x64sc -verbose -statusbar ./builds/depart.d64

# Requires fuse-emulator, runs the built tap file
testspectrumtape: all
	fuse --no-fastload -g 3x --no-traps --no-accelerate-loader -m plus2 -t spectrum/departures.tzx

testspectrumdisk: all
	fuse --no-fastload -g 3x --no-traps --no-accelerate-loader -m plus3 -t spectrum/departures.dsk

testspectrumif1: all
	fuse --no-fastload -g 3x --no-traps --no-accelerate-loader -m 48  --interface1 --rs232-tx fifo.in --rs232-rx fifo.out --no-rs232-handshake -t spectrum/departures.tzx

testspectrump3: all
	fuse --fastload -g 3x --traps --accelerate-loader -m plus3  --rs232-tx fifo.in --rs232-rx fifo.out --no-rs232-handshake -t spectrum/departures.dsk
