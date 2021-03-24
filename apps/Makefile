# ======================================================================
# The individual apps
# ======================================================================

.PHONY: all clean

all: c64

clean:
	@$(MAKE) -C c64 clean

c64:
	@$(MAKE) -C c64 all

# ======================================================================
# Common sources

# 6502, 6510, 65C02 & 6515 processor family
export COMMON6502 = \
	../macros.asm \
	../zeropage.asm \
	../main.asm \
	../lang/lang.asm \
	../network/serial.asm \
	../network/dialer.asm \
	../network/api.asm \
	../utils/outputbuffer.asm \
	../utils/screen.asm \
	../utils/strings.asm \
	../utils/welcome.asm
