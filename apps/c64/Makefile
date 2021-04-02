# ======================================================================
# Commodore 64
# ======================================================================

LOADER		= loader
BOOTSTRAP	= bootstrap
DEPART		= depart
NETWORK		= network
SPLASH		= splash
TELETEXT	= teletext
TESTCARD	= testcard
DISK		= $(BUILDS)/depart.d64

all: $(DISK)

clean:
	$(RM) $(BOOTSTRAP) $(DEPART) $(LOADER) $(NETWORK) $(SPLASH) $(TELETEXT) $(TESTCARD) $(DISK)

C64SRC = main.asm \
	kernal.asm \
	loader.asm \
	basictokens.asm

TELETEXTSRC = teletext.asm charset.asm

# BOOTSTRAP - the application bootstrap
$(BOOTSTRAP): bootstrap.asm
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# LOADER - the disk bootstrap
$(LOADER): diskloader.asm basictokens.asm
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# LOADER - the disk bootstrap
$(NETWORK): network.asm ../network/api.asm ../network/dialer.asm ../network/serial.asm
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# SPLASH - the splash screen
$(SPLASH): splash.asm
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# TESTCARD - Debugging Teletext test card
$(TESTCARD): testcard.asm
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# TELETEXT - the teletext emulator
$(TELETEXT): $(TELETEXTSRC)
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# DEPART - the main application
$(DEPART): $(C64SRC) $(COMMON6502)
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# Build the disk image
# $(LOADER) needs to be the first entry for LOAD "*",8,1 to work when booting the disk.
$(DISK): $(LOADER) $(BOOTSTRAP) $(TELETEXT) $(TESTCARD) $(SPLASH) $(NETWORK) $(DEPART)
	$(RM) $@
	c1541 -format ukdepartures,8 d64 $@
	$(foreach file, $^, c1541 -attach $@ -write $(file);)
