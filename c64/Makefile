# ======================================================================
# Commodore 64
# ======================================================================
	include ../Makefile.inc

LOADER		= loader.prg
BOOTSTRAP	= bootstrap.prg
BOARDS		= $(BUILDS_C64)/boards_c64.prg
DISK		= $(BUILDS)/depart.d64

# Teletext build artifacts are part of the submodule so need to be sourced from there
TELETEXTBASE= ../teletext

all: $(DISK)

clean:
	$(RM) $(BOOTSTRAP) $(LOADER) $(NETWORK) $(DISK)

# BOOTSTRAP - the application bootstrap
$(BOOTSTRAP): bootstrap.asm kernal.asm

# LOADER - the disk bootstrap
$(LOADER): loader.asm basictokens.asm

# Build the disk image
# $(LOADER) needs to be the first entry for LOAD "*",8,1 to work when booting the disk.
$(DISK): $(LOADER) \
		$(BOOTSTRAP) \
		$(TELETEXTBASE)/teletext.prg \
		$(TELETEXTBASE)/testcard.prg \
		$(TELETEXTBASE)/asciicard.prg \
		$(TELETEXTBASE)/graphicscard.prg \
		$(TELETEXTBASE)/splash.prg \
		$(BUILDS_C64)/network.prg \
		$(BOARDS)
