# ======================================================================
# Sinclair ZX Spectrum
# ======================================================================
	include ../Makefile.inc

BOARDS	= boards.z80

.PHONY: all network main
all: splash network main departures

clean:
	@$(MAKE) -C main clean
	@$(MAKE) -C network clean
	$(RM) *.lst *.rom *.tzx *.tap *.dsk

main:
	@$(MAKE) -C main all

network:
	@$(MAKE) -C network all

splash: splash-tzx.tzx

splash.rom: splash.z80

manifest.rom: manifest.z80

departures: departures.dsk departures.tzx departures.tap

departures.dsk: network splash.rom manifest.rom main
	cp ../teletextspectrum/teletext.dsk departures.dsk
	specfile -dsk departures.dsk manifest.rom 0x6200 splash.rom 0xFB00 network/network.rom 0xF000 main/main.rom 0x7000

departures.tzx: network splash.rom manifest.rom main
	specfile -tzx departures.tzx splash.rom 0xFB00 network/network.rom 0xF000 main/main.rom 0x7000
	cat ../teletextspectrum/teletext.tzx departures.tzx >departures1.tzx
	mv departures1.tzx departures.tzx

departures.tap: network splash.rom manifest.rom main
	specfile -tap departures.tap splash.rom 0xFB00 network/network.rom 0xF000 main/main.rom 0x7000
	cat ../teletextspectrum/teletext.tap departures.tap >departures1.tap
	mv departures1.tap departures.tap
