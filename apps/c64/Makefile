# ======================================================================
# Commodore 64
# ======================================================================

LOADER=loader
DEPART=depart
TELETEXT=teletext
DISK=$(BUILDS)/depart.d64

all: $(DISK)

clean:
	$(RM) $(LOADER) $(DEPART) $(TELETEXT) $(DISK)

C64SRC = main.asm \
	kernal.asm \
	loader.asm \
	basictokens.asm

TELETEXTSRC = teletext.asm charset.asm

# LOADER - the disk bootstrap
$(LOADER): diskloader.asm basictokens.asm
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# TELETEXT - the teletext emulator
$(TELETEXT): $(TELETEXTSRC)
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# DEPART - the main application
$(DEPART): $(C64SRC) $(COMMON6502)
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i $<

# Build the disk image, files ordered so first file gets loaded first!
$(DISK): $(LOADER) $(TELETEXT) $(DEPART)
	$(RM) $@
	c1541 -format departure,8 d64 $@
	$(foreach file, $^, c1541 -attach $@ -write $(file);)
