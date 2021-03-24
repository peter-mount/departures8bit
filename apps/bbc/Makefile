# ======================================================================
# Commodore 64
# ======================================================================

MASTER_ROM = master.rom

# Generated sources
VERSION_ASM = version.asm
COPYRIGHT_ASM = copyright.asm

# BBC Master 128 ROM
MASTER_SRC = \
	bbcmaster.asm \
	language.asm \
	romheader.asm \
	$(VERSION_ASM) \
	$(COPYRIGHT_ASM)

all: $(BUILDS)/$(MASTER_ROM)

clean:
	$(RM) $(MASTER_ROM) $(VERSION_ASM) $(COPYRIGHT_ASM)

$(VERSION_ASM):
	echo " EQUS \"$(VERSION)\"" >$(VERSION_ASM)

$(COPYRIGHT_ASM):
	echo " EQUS \"$(COPYRIGHT)\"" >$(COPYRIGHT_ASM)

$(MASTER_ROM): $(MASTER_SRC) $(COMMON6502)
	$(BEEBASM) -w -D bbc=1 -D bbcmaster=1 -D c64=0 -i bbcmaster.asm

$(BUILDS)/$(MASTER_ROM): $(MASTER_ROM)
	cp $(DEPART) $(BUILDS)/$(DEPART)
