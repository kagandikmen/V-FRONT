# V-FRONT Main Makefile
# Created:		2025-05-25
# Modified:		2026-07-13
# Author:		Kagan Dikmen

include ut/riscv-tests/isa/rv32ui/Makefrag
include ut/riscv-tests/isa/rv32mi/Makefrag
include ut/v-front/Makefrag

.DEFAULT_GOAL := test
.PHONY: compile_tests test


#
#	PARAMETERS
#

BUILD_DIR := build
BUILD_TEST_DIR := $(BUILD_DIR)/tests

SIM_TOOL ?= iverilog
SIM_MODE ?=
RISCV_PREFIX ?= riscv32-unknown-elf

QUESTA_GUI ?= 0
QUESTA_MEMFILE ?= sim/init.mem

DESIGN_SOURCES := \
	rtl/soc/soc.v \
	rtl/soc/bram_dual.v \
	rtl/cpu/cpu.v

SIMULATION_SOURCES := \
	rtl/soc/soc_tb.v

TESTDIRS := ut/riscv-tests/isa/rv32ui ut/riscv-tests/isa/rv32mi ut/v-front

TESTS := $(rv32ui_sc_tests) $(rv32mi_sc_tests) $(v-front_tests)

FAILING_TESTS := mcsr illegal ma_fetch

# Exclude the tests that have to be conducted by inspecting simulations
EXCLUDE_TESTS := csr_permissions illegal_instr illegal_instr_addr

# (Yet) unimplemented M-mode functionalities
UNIMP_TESTS := breakpoint zicntr instret_overflow pmpaddr

PASSING_TESTS := $(filter-out $(FAILING_TESTS) $(EXCLUDE_TESTS) $(UNIMP_TESTS), $(TESTS))

CFLAGS += -march=rv32i_zicsr_zifencei -Wall -Wextra -Os -fomit-frame-pointer \
	-ffreestanding -fno-builtin -fanalyzer -std=gnu99 \
	-Wall -Werror=implicit-function-declaration -ffunction-sections -fdata-sections
LDFLAGS += -march=rv32i_zicsr_zifencei -nostartfiles \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,--no-relax -Wl,--gc-sections \
	-Wl,-Tsw/v-front.ld


#
#	RULES
#

v-front.f: Makefile
	rm -f $@
	for source in $(DESIGN_SOURCES); do \
		echo "$$source" >> $@; \
	done

v-front.prj: Makefile
	rm -f $@
	for source in $(DESIGN_SOURCES) $(SIMULATION_SOURCES); do \
		echo "verilog work $$source" >> $@; \
	done

$(BUILD_TEST_DIR):
	mkdir -p $@
	for testdir in $(TESTDIRS); do \
		for test in $$(ls $$testdir | grep .S); do \
			cp $$testdir/$$test $@; \
		done \
	done

compile_tests: $(BUILD_TEST_DIR) v-front.f v-front.prj 
	$(RISCV_PREFIX)-gcc -c $(CFLAGS) -o sw/mtvec_handler.o sw/mtvec_handler.S
	for testfile in $(wildcard $</*.S) ; do \
		test=$${testfile##*/}; test=$${test%.*}; \
		$(RISCV_PREFIX)-gcc -c $(CFLAGS) -Iut/riscv-tests/env/p -Iut/riscv-tests/isa/macros/scalar -Iut/riscv-tests/isa/rv32ui -Iut/riscv-tests/isa/rv32mi -o $</$$test.o $</$$test.S; \
		$(RISCV_PREFIX)-gcc -o $</$$test.elf $(LDFLAGS) $</$$test.o sw/mtvec_handler.o; \
		$(RISCV_PREFIX)-objcopy -j .text -j .data -j .rodata -O verilog --verilog-data-width=4 $</$$test.elf $</$$test.mem; \
	done

test: compile_tests
	for test in $(PASSING_TESTS) ; do \
		printf "Running test %-15s\t" "$$test:"; \
		TOHOST_ADDR=$$($(RISCV_PREFIX)-nm -n $(BUILD_TEST_DIR)/$$test.elf | gawk '$$3=="tohost" { printf "%d\n", strtonum("0x"$$1) }'); \
		RESET_ADDR=$$($(RISCV_PREFIX)-nm -n $(BUILD_TEST_DIR)/$$test.elf | gawk '$$3=="_start" { printf "%s\n", $$1 }'); \
		if [ "$(SIM_TOOL)" = "iverilog" ]; then \
			iverilog -o $(BUILD_TEST_DIR)/$$test.out \
				-Irtl/cpu/ -Irtl/cpu/luftALU/rtl/ -Irtl/cpu/luftALU/rtl/subunits/ -Ilib/ \
				-f v-front.f \
				-D UT \
				-Psoc_tb.MEM_INIT_FILE=\"$(BUILD_TEST_DIR)/$$test.mem\" \
				-Psoc_tb.TOHOST_ADDR=$$TOHOST_ADDR \
				-Psoc_tb.RESET_ADDR=32\'h$$RESET_ADDR \
				rtl/soc/soc_tb.v; \
			vvp $(BUILD_TEST_DIR)/$$test.out > $(BUILD_TEST_DIR)/$$test.results; \
		else \
			xelab soc_tb -relax -debug all \
				-i ./rtl/cpu -i ./rtl/cpu/luftALU/rtl/ -i ./rtl/cpu/luftALU/rtl/subunits/  -i ./lib/ \
				-d UT \
				-generic_top MEM_INIT_FILE=\"$(BUILD_TEST_DIR)/$$test.mem\" \
				-generic_top TOHOST_ADDR=$$TOHOST_ADDR \
				-generic_top RESET_ADDR=32\'h$$RESET_ADDR \
				-prj v-front.prj > /dev/null; \
			xsim soc_tb -R --onfinish quit > $(BUILD_TEST_DIR)/$$test.results; \
		fi; \
		RESULT=$$(cat $(BUILD_TEST_DIR)/$$test.results | gawk '/Note:/ {print}' | sed 's/Note://' | gawk '/Success|Failure/ {print}'); \
		echo "$$RESULT"; \
		if [ "$(SIM_MODE)" = "ci" ] || [ "$(SIM_MODE)" = "CI" ]; then \
			if echo "$$RESULT" | grep -q 'Failure'; then \
				echo "Test $$test failed!"; \
				exit 1; \
			fi; \
		fi; \
	done

$(BUILD_DIR)/vivado:
	vivado -source target/vivado/create_project.tcl -mode batch

$(BUILD_DIR)/questa: compile_tests
	make -f target/questa/Makefile run GUI=$(QUESTA_GUI) MEMFILE=$(QUESTA_MEMFILE)

clean:
	rm -rf webtalk* xelab* xsim* .Xil/ *.wdb vivado_pid* *.jou vivado*.log vivado*.str xvlog.pb

clean_all: clean
	rm -rf v-front.prj v-front.f sw/mtvec_handler.o build/
