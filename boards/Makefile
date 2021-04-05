# ======================================================================
# boards	Departure boards application
# ======================================================================
	include ../Makefile.inc

BOARDS_C64		= boards_c64.prg

TARGETS			= $(BOARDS_C64)

all: $(TARGETS)
	$(CP) $(BOARDS_C64) $(BUILDS_C64)

clean:
	$(RM) $(TARGETS)

$(BOARDS_C64):	boards_c64.asm \
				../macros.asm \
				../zeropage.asm \
				../c64/kernal.asm \
				../../teletextc64/teletext.inc \
				../network/network.inc \
				main.asm
