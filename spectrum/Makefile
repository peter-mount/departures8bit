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
	$(RM) *.lst *.rom *.tzx *.dsk

main:
	@$(MAKE) -C main all

network:
	@$(MAKE) -C network all

splash: splash-tzx.tzx

splash.rom: splash.z80

manifest.rom: manifest.z80

departures: network splash.rom manifest.rom main
	cp ../teletextspectrum/teletext.dsk departures.dsk
	specfile -dsk departures.dsk manifest.rom 0x6200 splash.rom 0xFB00 network/network.rom 0xF000 main/main.rom 0x7000

#departures.tzx: network-tzx.tzx splash-tzx.tzx
#	cat ../teletextspectrum/loader-tzx.tzx ../teletextspectrum/teletext-tzx.tzx splash-tzx.tzx network-tzx.tzx >departures.tzx

#departures.tzx: network #../teletextspectrum/loader-tzx.tzx ../teletextspectrum/teletext-tzx.tzx splash-tzx.tzx network/network-tzx.tzx
#	cat ../teletextspectrum/loader-tzx.tzx ../teletextspectrum/teletext-tzx.tzx splash-tzx.tzx network/network-tzx.tzx >$@
#	cat $^ >$@

#departures.dsk: departures.tzx splash.rom manifest.rom

