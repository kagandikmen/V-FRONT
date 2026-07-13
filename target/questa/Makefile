# V-FRONT QuestaSim Makefile
# Created:		2026-07-13
# Modified:		2026-07-13
# Author:		Kagan Dikmen

.DEFAULT_GOAL := run

FLIST		?= v-front.f
TBLIST		?= rtl/soc/soc_tb.v
TOP			?= soc_tb
INC_DIR		?= lib
BUILD_DIR	?= build/questa
DO_SCRIPT	?= target/questa/run.do

RISCV_PREFIX ?= riscv32-unknown-elf

GUI ?= 0

ifdef TEST

MEMFILE		?= build/tests/$(TEST).mem
TOHOST_ADDR	?= $(shell $(RISCV_PREFIX)-nm -n build/tests/$(TEST).elf | gawk '$$3=="tohost" { printf "%d\n", strtonum("0x"$$1) }')
RESET_ADDR	?= $(shell $(RISCV_PREFIX)-nm -n build/tests/$(TEST).elf | gawk '$$3=="_start" { printf "%d\n", strtonum("0x"$$1) }')

else

MEMFILE		?= sim/init.mem
TOHOST_ADDR	?= 16384
RESET_ADDR	?= 0

endif

INCLUDE := $(addprefix +incdir+,$(INC_DIR))

SET_VARS := set FLIST 		{$(FLIST)};	\
			set TBLIST 		{$(TBLIST)}; \
			set TOP 		{$(TOP)}; \
			set INCLUDE 	{$(INCLUDE)}; \
			set MEMFILE 	{$(MEMFILE)}; \
			set TOHOST_ADDR {$(TOHOST_ADDR)}; \
			set RESET_ADDR	{$(RESET_ADDR)}; \
			set BUILD_DIR	{$(BUILD_DIR)}

export QSIM_INI := $(BUILD_DIR)/modelsim.ini

$(BUILD_DIR)/modelsim.ini:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && env -u QSIM_INI -u MODELSIM vmap -c

run: $(BUILD_DIR)/modelsim.ini
	if [ "$(GUI)" = "0" ]; then \
		vsim -c -l $(BUILD_DIR)/transcript -do "$(SET_VARS); do $(DO_SCRIPT); quit -f"; \
	else \
		vsim -l $(BUILD_DIR)/transcript -do "$(SET_VARS); do $(DO_SCRIPT)"; \
	fi;

clean:
	rm -rf $(BUILD_DIR)
