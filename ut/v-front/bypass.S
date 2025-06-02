#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32M
RVTEST_CODE_BEGIN

	li TESTNUM, 1
	addi x2, x0, 4
	addi x3, x2, 0
	nop
	nop
	nop
	nop
	nop
	bne x3, x2, fail

	li TESTNUM, 2
	addi x2, x0, 4
	nop
	addi x3, x2, 0
	nop
	nop
	nop
	nop
	nop
	bne x3, x2, fail

	li TESTNUM, 3
	addi x2, x0, -6
	addi x3, x0, 6
	add x4, x2, x3
	nop
	nop
	nop
	nop
	nop
	bnez x4, fail

	TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END


