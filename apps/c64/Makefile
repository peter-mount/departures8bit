# ======================================================================
# Commodore 64
# ======================================================================

LOADER=loader
DEPART=depart
DISK=$(BUILDS)/depart.d64

all: $(DISK)

clean:
	$(RM) $(LOADER) $(DEPART) $(DISK)

C64SRC = \
	kernal.asm \
	loader.asm \
	main.asm \
	charset.asm \
	teletext.asm

$(LOADER): splash.asm
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i splash.asm

$(DEPART): $(C64SRC) $(COMMON6502)
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i main.asm

#$(BUILDS)/$(DEPART): $(DEPART)
#	cp $(DEPART) $(BUILDS)/$(DEPART)

# Build the disk image, files ordered so first file gets loaded first!
$(DISK): $(LOADER) $(DEPART)
	$(RM) $@
	c1541 -format departure,8 d64 $@
	$(foreach file, $^, c1541 -attach $@ -write $(file);)
