RISCV_PREFIX ?= riscv32-unknown-elf-
CC      := $(RISCV_PREFIX)gcc
OBJCOPY := $(RISCV_PREFIX)objcopy
CFLAGS  := -march=rv32imc -mabi=ilp32 -Os -ffreestanding -fno-builtin -nostdlib
LDFLAGS := -Wl,-Bstatic,-T,sections.lds,--gc-sections

all: firmware.hex firmware.bin

firmware.elf: start.S main.c raven_defs.h sections.lds
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ start.S main.c

firmware.hex: firmware.elf
	$(OBJCOPY) -O verilog $< $@

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary $< /dev/stdout | tail -c +1048577 > $@

reference:
	cp reference_raven_demo.hex firmware.hex

clean:
	rm -f firmware.elf firmware.hex firmware.bin

.PHONY: all reference clean
