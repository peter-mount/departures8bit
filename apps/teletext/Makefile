# ======================================================================
# Commodore 64 Teletext Emulator
# ======================================================================
	include ../../Makefile.inc

TELETEXT	= teletext.prg		# C64 teletext module
SPLASH		= splash.prg		# Splash page in PRG format
TESTCARD	= testcard.prg		# Teletext test card in PRG format

TELETEXTSRC = teletext.asm charset.asm

TARGETS = $(TELETEXT) $(SPLASH) $(TESTCARD)

all: $(TARGETS)
	$(CP) $(TARGETS) $(BUILDS)/c64

clean:
	$(RM) $(TARGETS)

# TELETEXT - the teletext emulator
$(TELETEXT): $(TELETEXTSRC)

# SPLASH - the splash screen
$(SPLASH): splash.asm

# TESTCARD - Debugging Teletext test card
$(TESTCARD): testcard.asm
