COMPILER_PREFIX = riscv32-unknown-elf

all: clean compile generate_hex

CFLAGS += -march=rv32i -Wall -Wextra -Os -fomit-frame-pointer \
	-ffreestanding -fno-builtin -fanalyzer -std=gnu99 \
	-Wall -Werror=implicit-function-declaration -ffunction-sections -fdata-sections
LDFLAGS += -march=rv32i -nostartfiles \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,--no-relax -Wl,--gc-sections \
	-Wl,-T../v-core.ld -Wl,--Map,test.map

compile:
	$(COMPILER_PREFIX)-gcc -c -o ../start.o $(CFLAGS) ../start.S
	$(COMPILER_PREFIX)-gcc -c -o test.o $(CFLAGS) test.c
	$(COMPILER_PREFIX)-gcc -o test.elf $(LDFLAGS) test.o ../start.o

generate_hex: compile
	../extract_hex.sh test.elf pmem.hex dmem.hex
	cp pmem.hex ../../sim/
	cp dmem.hex ../../sim/ || echo "No dmem.hex found"

clean:
	rm -rf *.o *.hex *.bin *.elf *.map ../start.o ../../sim/pmem.hex ../../sim/dmem.hex
	