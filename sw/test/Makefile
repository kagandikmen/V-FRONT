RISCV_PREFIX ?= riscv32-unknown-elf

all: clean compile copy

CFLAGS += -march=rv32i -Wall -Wextra -Os -fomit-frame-pointer \
	-ffreestanding -fno-builtin -fanalyzer -std=gnu99 \
	-Wall -Werror=implicit-function-declaration -ffunction-sections -fdata-sections
LDFLAGS += -march=rv32i -nostartfiles \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,--no-relax -Wl,--gc-sections \
	-Wl,-T../v-front.ld -Wl,--Map,test.map

compile:
	$(RISCV_PREFIX)-gcc -c -o ../start.o $(CFLAGS) ../start.S
	$(RISCV_PREFIX)-gcc -c -o test.o $(CFLAGS) test.c
	$(RISCV_PREFIX)-gcc -o test.elf $(LDFLAGS) test.o ../start.o
	$(RISCV_PREFIX)-objcopy -j .text -j .data -j .rodata -O verilog --verilog-data-width=4 test.elf test.mem

copy:
	cat test.mem > ../../sim/init.mem

clean:
	rm -rf *.o *.hex *.bin *.elf *.map ../start.o
