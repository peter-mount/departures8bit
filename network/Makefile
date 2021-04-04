# ======================================================================
# Networking
# ======================================================================
	include ../Makefile.inc

NETWORK_C64	= network.prg

NETWORKSRC	= api.asm dialer.asm network.asm serial.asm

TARGETS		= $(NETWORK_C64)

all: $(TARGETS)
	$(CP) $(NETWORK_C64) $(BUILDS)/c64

clean:
	$(RM) $(TARGETS)

$(NETWORK_C64): $(NETWORKSRC)
