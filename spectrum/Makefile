# ======================================================================
# Sinclair ZX Spectrum
# ======================================================================
	include ../Makefile.inc

BOARDS	= boards.z80
TAP		= $(BUILDS_SPECTRUM)/depart.tap
TZX		= $(BUILDS_SPECTRUM)/depart.tzx
DSK		= $(BUILDS_SPECTRUM)/depart.dsk

# Path to the teletext emulator for the spectrum
TELETEXT_BASE = ../teletextspectrum

.PHONY: all network main
all: $(DSK) $(TAP) $(TZX)

clean:
	@$(MAKE) -C main clean
	@$(RM) *.lst *.rom *.tzx *.tap *.dsk

main:
	@$(MAKE) -C main all

splash.rom: splash.z80

manifest.rom: manifest.z80

$(DSK): network splash.rom manifest.rom main
	@cp $(TELETEXT_BASE)/teletext.dsk $@
	@specfile -dsk $@ manifest.rom 0x6200 splash.rom 0xFB00 main/main.rom 0xe000

$(TZX): network splash.rom main
	@specfile -tzx departures.tzx splash.rom 0xFB00 main/main.rom 0xe000
	@cat $(TELETEXT_BASE)/teletext.tzx departures.tzx >$@

$(TAP): network splash.rom main
	@specfile -tap departures.tap splash.rom 0xFB00 main/main.rom 0xe000
	@cat $(TELETEXT_BASE)/teletext.tap departures.tap >$@
