// V-FRONT Test Suite - Test for illegal instruction address
// Created:     2026-07-11
// Modified:    2026-07-11
// Author:      Kagan Dikmen

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32M
RVTEST_CODE_BEGIN

    li TESTNUM, 1
    li x1, 0x4
    j test_target       # Corrupt this instruction in illegal_instr_addr.mem and then simulate
    ebreak

    TEST_PASSFAIL

RVTEST_CODE_END

test_target:

    li x31, 0xFF
    add x31, x31, x0
    unimp

    .data
RVTEST_DATA_BEGIN

    TEST_DATA

RVTEST_DATA_END
