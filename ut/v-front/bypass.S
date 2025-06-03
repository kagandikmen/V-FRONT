#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32M
RVTEST_CODE_BEGIN

	li TESTNUM, 1
	addi x5, x0, 4
	addi x6, x5, 0
	nop
	nop
	nop
	nop
	nop
	bne x5, x6, fail

	li TESTNUM, 2
	addi x5, x0, 4
	nop
	addi x6, x5, 0
	nop
	nop
	nop
	nop
	nop
	bne x6, x5, fail

	li TESTNUM, 3
	addi x5, x0, -6
	addi x6, x0, 6
	add x7, x5, x6
	nop
	nop
	nop
	nop
	nop
	bnez x7, fail

	TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END


