// V-FRONT Test Suite - Test for wfi Instruction
// Created:     2026-07-14
// Modified:    2026-10-04
// Author:      Kagan Dikmen

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32M
RVTEST_CODE_BEGIN

    li TESTNUM, 1
    li x7, 4
    li x8, 4
    wfi
    bne x8, x7, fail

    la x5, umode_tests
    csrw mepc, x5
    li x5, (3 << 11)
    csrc mstatus, x5
    li x5, (1 << 21)
    csrs mstatus, x5
    mret

umode_tests:
    li TESTNUM, 2
    li x7, 4
    li x8, 4
    wfi
    bne x8, x7, fail

    TEST_PASSFAIL

RVTEST_CODE_END

    .data
RVTEST_DATA_BEGIN

    TEST_DATA

tdat:
tdat1:  .byte 0xff
tdat2:  .byte 0x00
tdat3:  .byte 0xf0
tdat4:  .byte 0x0f

RVTEST_DATA_END
