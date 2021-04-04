# ======================================================================
# Pattern rules
#
# These need to be included into the other Makefiles as you can't define
# these are the root as they won't be picked up
# ======================================================================

# C64 assemble .prg executable
%.prg: %.asm
	$(BEEBASM) $(C64_FLAGS) -i $<

# C64 1541 disk image
# Files will be written to the image in the supplied order
%.d64:
	@$(C1541) -format $(shell basename $@),8 d64 $@
	@$(foreach file, $^, $(C1541) -attach $@ -write $(file) $(shell basename $(file) .prg);)
