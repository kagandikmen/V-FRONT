// V-FRONT Test Suite - Test for illegal instructions
// Created:     2026-07-10
// Modified:    2026-07-10
// Author:      Kagan Dikmen

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32M
RVTEST_CODE_BEGIN

    li TESTNUM, 1
    li x1, 0x4
    add x1, x1, x1      # Corrupt this instruction in illegal_instr.mem and then simulate
    ebreak

    TEST_PASSFAIL

RVTEST_CODE_END

    .data
RVTEST_DATA_BEGIN

    TEST_DATA

RVTEST_DATA_END
