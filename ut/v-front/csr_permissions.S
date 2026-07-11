// V-FRONT Test Suite - Test for CSR permissions
// Created:     2026-07-10
// Modified:    2026-07-10
// Author:      Kagan Dikmen

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32M
RVTEST_CODE_BEGIN

    li TESTNUM, 1
    li x1, 4
    csrr x1, mhartid
    bne x1, x0, fail

    li TESTNUM, 2
    li x1, 4
    csrw mhartid, x1
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    TEST_PASSFAIL

RVTEST_CODE_END

    .data
RVTEST_DATA_BEGIN

    TEST_DATA

RVTEST_DATA_END
