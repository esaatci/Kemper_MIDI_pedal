###
### Configurables
###
###

vpath %.c src
vpath %.S startup



MCU=MKL26Z64
BUILDDIR = build

C_FILES := $(wildcard src/*.c)
ASM_FILES := $(wildcard startup/*.s)
OBJS_FILES := $(C_FILES:.c=.o) $(ASM_FILES:.s=.o)
OBJS := $(foreach obj,$(OBJS_FILES), $(BUILDDIR)/$(obj))

#where the compiler and the teensy CLI are
TOOLCHAIN_PATH = ../tools

#compiler path
CC_PATH = $(TOOLCHAIN_PATH)/gcc-arm-none-eabi-9-2020-q2-update/bin

#compiler variables
CC = $(CC_PATH)/arm-none-eabi-gcc
CPU_ARCH = cortex-m0plus 
CC_FLAGS = -g -mcpu=$(CPU_ARCH) -mthumb -D CPU_MKL26Z64VFM4


LINKER = $(CC_PATH)/arm-none-eabi-ld 
LINKER_FLAGS = -o

OBJCOPY = $(CC_PATH)/arm-none-eabi-objcopy

TARGET = firmware
L_INC = inc
LDSCRIPT = mkl26z64.ld
LDFLAGS = -Os -Wl,--gc-sections -mcpu=$(CPU_ARCH) -mthumb -T$(LDSCRIPT)

# additional libraries to link
LIBS = -lm

### standard phony targets

Q = ''

###
### Target rules
###

all: hex

build: $(TARGET).elf

hex: $(TARGET).hex

$(BUILDDIR)/%.o: %.c
	@echo "[CC]\t$<"
	@mkdir -p "$(dir $@)"
	$(Q)$(CC) $(CC_FLAGS) -I$(L_INC) -o "$@" -c "$<"

$(BUILDDIR)/%.o: %.s
	@echo "Im here"
	@mkdir -p "$(dir $@)"
	$(Q)$(CC) $(CC_FLAGS) -I$(L_INC) -o "$@" -c "$<"

$(TARGET).elf: $(OBJS) $(LDSCRIPT)
	@echo "[LD]\t$@"
	@echo $(ASM_FILES)
	$(Q)$(CC) $(LDFLAGS) -o "$@" -Wl,-Map,$(TARGET).map $(OBJS) $(LIBS)

%.hex: %.elf
	@echo "[HEX]\t$@"
	@$(OBJCOPY) -O ihex -R .eeprom "$<" "$@"

# compiler generated dependency info
-include $(OBJS:.o=.d)

clean:
	@echo Cleaning...
	@rm -rf "$(BUILDDIR)"
	@rm -f "$(TARGET).elf" "$(TARGET).hex" "$(TARGET).map"
