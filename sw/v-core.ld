/* Generic linker script for V-CORE */
/* Created:     2025-05-24 */
/* Modified:    2025-05-24 */
/* Author:      Kagan Dikmen */

ENTRY(_start)

MEMORY
{
    pmem (rx) : ORIGIN = 0x00000000, LENGTH = 16K
    dmem (rw) : ORIGIN = 0x00004000, LENGTH = 16K
}

SECTIONS
{
    .text : {
        *(.init)

        __text_begin = .;
        *(.text*)
        __text_end = .;
    } > pmem

    .rodata : {
        __rodata_begin = .;
        *(.rodata*)
        __rodata_end = .;
    } > dmem

    .data : {
        __data_begin = .;
        *(.data*)
        *(.sdata*)
        *(.eh_frame*)
        __data_end = .;
    } > dmem

    .bss : {
        __bss_begin = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        __bss_end = .;
    } > dmem

    __stack_top = 0x3FFC;

    /DISCARD/ :
    {
        *(.comment*)
    }
}