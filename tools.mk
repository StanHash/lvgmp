
# arm-none-eabi toolchain definitions

TOOLCHAIN ?= $(DEVKITARM)
export PATH := $(TOOLCHAIN)/bin:$(PATH)

PREFIX := arm-none-eabi-

CPP     := $(PREFIX)cpp
AS      := $(PREFIX)as
CC      := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy

# making sure we are using python 3

ifeq ($(PYTHON3),)
  ifeq ($(PYTHON),)
    PYHTON3 := python
  else
    PYTHON3 := $(PYTHON)
  endif
  ifneq ($(shell $(PYHTON3) -c 'import sys; print(int(sys.version_info[0] > 2))'),1)
    PYTHON3 := python3
  endif
endif

# EA and tools definitions

EA_DIR ?= tools/event-assembler

EA                := $(EA_DIR)/ColorzCore
EA_DEP            := $(EA_DIR)/ea-dep
LYN               := $(EA_DIR)/Tools/lyn
COMPRESS          := $(EA_DIR)/Tools/compress
PNG2DMP           := $(EA_DIR)/Tools/Png2Dmp
PARSEFILE         := $(EA_DIR)/Tools/ParseFile
PORTRAITFORMATTER := $(EA_DIR)/Tools/PortraitFormatter

# script tool definitions

ELF2REF := $(PYTHON3) tools/scripts/elf2ref.py
