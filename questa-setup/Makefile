# V-FRONT QuestaSim Makefile
# Created:		2026-07-13
# Modified:		2026-07-13
# Author:		Kagan Dikmen

.DEFAULT_GOAL := batch

FLIST		?= v-front.f
TBLIST		?= rtl/soc/soc_tb.v
TOP			?= soc_tb
INC_DIR		?= lib
BUILD_DIR	?= build/questa
DO_SCRIPT	?= questa-setup/run.do

RISCV_PREFIX ?= riscv32-unknown-elf

ifdef TEST

MEMFILE		?= tests-build/$(TEST).mem
TOHOST_ADDR	?= $(shell $(RISCV_PREFIX)-nm -n tests-build/$(TEST).elf | gawk '$$3=="tohost" { printf "%d\n", strtonum("0x"$$1) }')
RESET_ADDR	?= $(shell $(RISCV_PREFIX)-nm -n tests-build/$(TEST).elf | gawk '$$3=="_start" { printf "%d\n", strtonum("0x"$$1) }')

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

gui: $(BUILD_DIR)/modelsim.ini
	DISPLAY=:2 vsim -l $(BUILD_DIR)/transcript -do "$(SET_VARS); do $(DO_SCRIPT)"

batch: $(BUILD_DIR)/modelsim.ini
	DISPLAY=:2 vsim -c -l $(BUILD_DIR)/transcript -do "$(SET_VARS); do $(DO_SCRIPT); quit -f"

clean:
	rm -rf $(BUILD_DIR)
