# V-CORE Main Makefile
# Created:		2025-05-25
# Modified:		2025-05-31
# Author:		Kagan Dikmen

include ut/rv32ui/Makefrag
include ut/vcore/Makefrag

TESTDIRS := ut/rv32ui ut/vcore

TESTS := $(rv32ui_sc_tests) $(vcore_tests)

FAILING_TESTS := 

PASSING_TESTS := $(filter-out $(FAILING_TESTS), $(TESTS))

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

all: clean run_iverilog

vivado: clean run_vivado

create_project:
	rm -rf v-core.prj
	for source in $(DESIGN_SOURCES) $(SIMULATION_SOURCES); do \
		echo "verilog work $$source" >> v-core.prj; \
	done

copy_tests: create_project
	test -d tests || mkdir tests
	for testdir in $(TESTDIRS); do \
		for test in $$(ls $$testdir | grep .S); do \
			cp $$testdir/$$test tests; \
		done \
	done

compile_tests: copy_tests
	test -d tests-build || mkdir tests-build
	$(TOOLCHAIN_PREFIX)-gcc -c $(CFLAGS) -o sw/mtvec_handler.o sw/mtvec_handler.S
	for test in tests/* ; do \
		test=$${test##*/}; test=$${test%.*}; \
		$(TOOLCHAIN_PREFIX)-gcc -c $(CFLAGS) -Iut -Iut/rv32ui -o tests-build/$$test.o tests/$$test.S; \
		$(TOOLCHAIN_PREFIX)-gcc -o tests-build/$$test.elf $(LDFLAGS) tests-build/$$test.o sw/mtvec_handler.o; \
		$(TOOLCHAIN_PREFIX)-objcopy -j .text -j .data -j .rodata -O binary tests-build/$$test.elf tests-build/$$test.bin; \
		hexdump -v -e '1/4 "%08x\n"' tests-build/$$test.bin > tests-build/$$test.hex; \
	done

run_vivado: compile_tests
	for test in $(PASSING_TESTS) ; do \
		printf "Running test %-15s\t" "$$test:"; \
		TOHOST_ADDR=$$($(TOOLCHAIN_PREFIX)-nm -n tests-build/$$test.elf | awk '$$3=="tohost" { printf "%d\n", strtonum("0x"$$1) }'); \
		xelab cpu_tb -relax -debug all \
			-generic_top MEM_INIT_FILE=\"tests-build/$$test.hex\" \
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

run_iverilog: compile_tests
	for test in $(PASSING_TESTS) ; do \
		printf "Running test %-15s\t" "$$test:"; \
		TOHOST_ADDR=$$($(TOOLCHAIN_PREFIX)-nm -n tests-build/$$test.elf | awk '$$3=="tohost" { printf "%d\n", strtonum("0x"$$1) }'); \
		iverilog -o tests-build/$$test.out \
			-Irtl/ -Isim/ -Irtl/luftALU/rtl/ -Irtl/luftALU/rtl/subunits/ \
			-Pcpu_tb.MEM_INIT_FILE=\"tests-build/$$test.hex\" \
			-Pcpu_tb.TOHOST_ADDR=$$TOHOST_ADDR \
			sim/cpu_tb.v; \
		vvp tests-build/$$test.out > tests-build/$$test.results; \
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
	rm -rf v-core.prj sw/mtvec_handler.o tests/ sim/*.hex

