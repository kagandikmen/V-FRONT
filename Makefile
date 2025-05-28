# V-CORE Main Makefile
# Created:		2025-05-25
# Modified:		2025-05-28
# Author:		Kagan Dikmen (kagandikmen@outlook.com)

include ut/rv32ui/Makefrag

FAILING_TESTS := fence_i ld_st lui ma_data sb sh st_ld sll sra srai srl xor

UNIT_TESTS := $(filter-out $(FAILING_TESTS), $(rv32ui_sc_tests))

DESIGN_SOURCES := \
	rtl/cpu.v

SIMULATION_SOURCES := \
	sim/cpu_tb.v

MODE ?=

TOOLCHAIN_PREFIX := riscv32-unknown-elf

CFLAGS += -march=rv32i_zicsr_zifencei -Wall -Wextra -Os -fomit-frame-pointer \
	-ffreestanding -fno-builtin -fanalyzer -std=gnu99 \
	-Wall -Werror=implicit-function-declaration -ffunction-sections -fdata-sections
LDFLAGS += -march=rv32i_zicsr_zifencei -nostartfiles \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,--no-relax -Wl,--gc-sections \
	-Wl,-Tsw/v-core.ld

all: run_tests

create_project:
	rm -rf v-core.prj
	for source in $(DESIGN_SOURCES) $(SIMULATION_SOURCES); do \
		echo "verilog work $$source" >> v-core.prj; \
	done

copy_tests: create_project
	test -d tests || mkdir tests
	for test in $(UNIT_TESTS) $(FAILING_TESTS); do \
		cp ut/rv32ui/$$test.S tests; \
	done

compile_tests: copy_tests
	test -d tests-build || mkdir tests-build
	for test in $(UNIT_TESTS) $(FAILING_TESTS); do \
		$(TOOLCHAIN_PREFIX)-gcc -c $(CFLAGS) -Iut -Iut/rv32ui -o tests-build/$$test.o tests/$$test.S; \
		$(TOOLCHAIN_PREFIX)-gcc -o tests-build/$$test.elf $(LDFLAGS) tests-build/$$test.o; \
		sw/extract_hex.sh tests-build/$$test.elf tests-build/$$test-pmem.hex tests-build/$$test-dmem.hex; \
	done

run_tests: compile_tests
	for test in $(UNIT_TESTS); do \
		echo -ne "Running test $$test:\t"; \
		TOHOST_ADDR=$$($(TOOLCHAIN_PREFIX)-nm -n tests-build/$$test.elf | awk '$$3=="tohost" { printf "%d\n", strtonum("0x"$$1) }'); \
		xelab cpu_tb -relax -timescale 1ns/1ns -debug all \
			-i rtl/ -i sim/ -i lib/ \
			-generic_top PMEM_INIT_FILE=\"tests-build/$$test-pmem.hex\" \
			-generic_top DMEM_INIT_FILE=\"tests-build/$$test-dmem.hex\" \
			-generic_top TOHOST_ADDR=$$TOHOST_ADDR \
			-prj v-core.prj > /dev/null; \
		xsim cpu_tb -R --onfinish quit > tests-build/$$test.results; \
		RESULT=$$(cat tests-build/$$test.results | awk '/Note:/ {print}' | sed 's/Note://' | awk '/Success|Failure/ {print}'); \
		echo "$$RESULT"; \
		if [ "$(MODE)" = "ci" ] || [ "$(MODE)" = "CI" ]; then \
			if echo "$$RESULT" | grep -q 'Failure'; then \
				echo "Test $$test failed!"; \
				exit 1; \
			fi; \
		fi; \
	done

clean:
	rm -rf tests-build/ webtalk* xelab* xsim* .Xil/ *.wdb vivado_pid*

clean_all: clean
	rm -rf v-core.prj tests/ sim/*.hex

