# ======================================================================
# Sinclair ZX Spectrum +3
#
# The +2 & 128 may be supported later, I only have a +3 physically here.
# ======================================================================
	include ../Makefile.inc

BOARDS	= boards.z80

all: spectape.tap teletext.tap

clean:
	$(RM) *.lst *.tap

teletext.tap: teletext.z80 ../teletext/charset1.asm
