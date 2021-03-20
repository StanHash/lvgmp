
CACHE_DIR := .cache_dir
$(shell mkdir -p $(CACHE_DIR) > /dev/null)

# ====================
# = TOOL DEFINITIONS =
# ====================

include tools.mk

# ==================================
# = DECOMPILATION FILE DEFINITIONS =
# ==================================

FE8_DIR := tools/fe8

FE8_GBA := $(FE8_DIR)/fe8.gba
FE8_ELF := $(FE8_DIR)/fe8.elf

FE8_REFERENCE := $(CACHE_DIR)/fe8-reference.s

# ===============
# = MAIN TARGET =
# ===============

HACK_GBA := hack.gba
MAIN_EVENT := main.event

hack: $(HACK_GBA)
base: $(FE8_GBA)

.PHONY: hack base

MAIN_DEPENDS := $(shell $(EA_DEP) $(MAIN_EVENT) -I $(EA_DIR) --add-missings)

$(HACK_GBA): $(FE8_GBA) $(MAIN_EVENT) $(MAIN_DEPENDS)
	cp -f $(FE8_GBA) $(HACK_GBA)
	$(EA) A FE8 -input:$(MAIN_EVENT) -output:$(HACK_GBA) || rm -f $(HACK_GBA)

# ==================
# = OBJECTS & DMPS =
# ==================

LYN_REFERENCE := $(FE8_REFERENCE:.s=.o)

# OBJ to event
%.lyn.event: %.o $(LYN_REFERENCE)
	$(LYN) $< $(LYN_REFERENCE) > $@

# OBJ to DMP rule
%.dmp: %.o
	$(OBJCOPY) -S $< -O binary $@

# ========================
# = ASSEMBLY/COMPILATION =
# ========================

# Setting C/ASM include directories up
INCLUDE_DIRS := wizardry/include $(FE8_DIR)/include
INCFLAGS     := $(foreach dir, $(INCLUDE_DIRS), -I "$(dir)")

# setting up compilation flags
ARCH    := -mcpu=arm7tdmi -mthumb -mthumb-interwork
CFLAGS  := $(ARCH) $(INCFLAGS) -Wall -Os -mtune=arm7tdmi -ffreestanding -mlong-calls
ASFLAGS := $(ARCH) $(INCFLAGS)

# defining dependency flags
CDEPFLAGS = -MMD -MT "$*.o" -MT "$*.asm" -MF "$(CACHE_DIR)/$(subst /,_,$*).d" -MP
SDEPFLAGS = --MD "$(CACHE_DIR)/$(subst /,_,$*).d"

# ASM to OBJ rule
%.o: %.s
	$(AS) $(ASFLAGS) $(SDEPFLAGS) -I $(dir $<) $< -o $@

# C to ASM rule
# I would be fine with generating an intermediate .s file but this breaks dependencies
%.o: %.c
	$(CC) $(CFLAGS) $(CDEPFLAGS) -g -c $< -o $@

# C to ASM rule
%.asm: %.c
	$(CC) $(CFLAGS) $(CDEPFLAGS) -S $< -o $@ -fverbose-asm

# Avoid make deleting objects it thinks it doesn't need anymore
# Without this make may fail to detect some files as being up to date
.PRECIOUS: %.o;

-include $(wildcard $(CACHE_DIR)/*.d)

# ==========================
# = GRAPHICS & COMPRESSION =
# ==========================

# PNG to 4bpp rule
%.4bpp: %.png
	$(PNG2DMP) $< -o $@

# PNG to gbapal rule
%.gbapal: %.png
	$(PNG2DMP) $< -po $@ --palette-only

# Anything to lz rule
%.lz: %
	$(COMPRESS) $< $@

# ========================
# = DECOMPILATION TARGET =
# ========================

$(FE8_REFERENCE): $(FE8_ELF)
	$(ELF2REF) $(FE8_ELF) > $(FE8_REFERENCE)

$(FE8_GBA) $(FE8_ELF) &: FORCE
	@$(MAKE) -s -C $(FE8_DIR)

FORCE:
.PHONY: FORCE
