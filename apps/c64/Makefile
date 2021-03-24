# ======================================================================
# Commodore 64
# ======================================================================

DEPART=depart.prg

all: $(BUILDS)/$(DEPART)

clean:
	$(RM) $(DEPART)

C64SRC = \
	kernal.asm \
	loader.asm \
	main.asm

$(DEPART): $(C64SRC) $(COMMON6502)
	$(BEEBASM) -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i main.asm

$(BUILDS)/$(DEPART): $(DEPART)
	cp $(DEPART) $(BUILDS)/$(DEPART)
