# ======================================================================
# The individual apps
# ======================================================================

.PHONY: all clean

all:
	@$(MAKE) -C c64 all
	@$(MAKE) -C bbc all

clean:
	@$(MAKE) -C c64 clean
	@$(MAKE) -C bbc clean

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
	../utils/mathstr.asm \
	../utils/outputbuffer.asm \
	../utils/prompt.asm \
	../utils/screen.asm \
	../utils/strings.asm \
	../utils/welcome.asm
