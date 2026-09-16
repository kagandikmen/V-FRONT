/* V-FRONT linker script for riscv-arch-test */

PMEM_ORIGIN = 0x00000000;
PMEM_LENGTH = 0x00021000;

DMEM_ORIGIN = 0x00021000;
DMEM_LENGTH = 0x0001F000;

TEST_BASE = PMEM_ORIGIN;
NUM_HARTS = 1;

STACK_SIZE = 0x00000800;

OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

MEMORY
{
    pmem (rx) : ORIGIN = PMEM_ORIGIN, LENGTH = PMEM_LENGTH
    dmem (rw) : ORIGIN = DMEM_ORIGIN, LENGTH = DMEM_LENGTH
}

PROVIDE(__stack_size = STACK_SIZE);
PROVIDE(__num_harts = NUM_HARTS);

SECTIONS
{
    .text.init TEST_BASE :
    {
        *(.text.init)
    } > pmem

    .text.rvtest . :
    {
        *(.text.rvtest)
        *(.text.rvtest.*)
    } > pmem

    __rvtest_text_end = .;

    .rodata ORIGIN(dmem) :
    {
        *(.rodata)
        *(.rodata.*)
        *(.srodata)
        *(.srodata.*)
    } > dmem

    .data . :
    {
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
        *(.tohost)
        *(.tohost.*)
    } > dmem

    . = ALIGN(16);

    .bss . :
    {
        __bss_start = .;

        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)

        . = ALIGN(16);
        __bss_end = .;
    } > dmem

    . = ALIGN(16);
    __stack_bottom = .;
    . += __stack_size * __num_harts;
    __stack_top = .;
    __dmem_end = .;

    /*
     * This section must appear after the data and stack declarations in
     * linker-script order. Its address is nevertheless returned to pmem.
     *
     * Keeping it after data ensures DUT-specific macros do not alter the
     * addresses of signature data between Sail and DUT builds.
     */
    .text.rvmodel ALIGN(__rvtest_text_end, 16) :
    {
        *(.text.rvmodel)
        *(.text.rvmodel.*)
        *(.text)
        *(.text.*)
    } > pmem

    __pmem_end =
        ALIGN(__rvtest_text_end, 16) + SIZEOF(.text.rvmodel);

    _end = __dmem_end;

    ASSERT(
        __pmem_end <= ORIGIN(pmem) + LENGTH(pmem),
        "ACT executable code exceeds V-FRONT's 132 KiB program memory"
    )

    ASSERT(
        __dmem_end <= ORIGIN(dmem) + LENGTH(dmem),
        "ACT data and stack exceed V-FRONT's 124 KiB data memory"
    )
}
