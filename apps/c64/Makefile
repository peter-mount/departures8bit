# ======================================================================
# Commodore 64
# ======================================================================
	include ../../Makefile.inc

LOADER		= loader.prg
BOOTSTRAP	= bootstrap.prg
DEPART		= depart.prg
DISK		= $(BUILDS)/depart.d64

all: $(DISK)

clean:
	$(RM) $(BOOTSTRAP) $(DEPART) $(LOADER) $(NETWORK) $(DISK)

# BOOTSTRAP - the application bootstrap
$(BOOTSTRAP): bootstrap.asm kernal.asm

# LOADER - the disk bootstrap
$(LOADER): loader.asm basictokens.asm

# DEPART - the main application
$(DEPART): depart.asm kernal.asm

# Build the disk image
# $(LOADER) needs to be the first entry for LOAD "*",8,1 to work when booting the disk.
$(DISK): $(LOADER) \
		$(BOOTSTRAP) \
		$(BUILDS_C64)/teletext.prg \
		$(BUILDS_C64)/testcard.prg \
		$(BUILDS_C64)/splash.prg \
		$(BUILDS_C64)/network.prg \
		$(DEPART)
