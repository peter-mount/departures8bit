# ======================================================================
# Sinclair ZX Spectrum
# ======================================================================
	include ../../Makefile.inc

all: network.rom network-tzx.tzx

clean:
	$(RM) *.lst *.rom *.tzx

network.rom: network.z80 if1/if1.z80 if1/get.z80 plus3/plus3.z80 plus3/get.z80

network-tzx.tzx: network-tzx.z80 network.rom
