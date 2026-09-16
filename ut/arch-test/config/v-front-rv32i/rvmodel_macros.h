#ifndef _V_FRONT_RVMODEL_MACROS_H
#define _V_FRONT_RVMODEL_MACROS_H

/*
 * Communication area observed by the Verilog testbench.
 *
 * Both symbols are 8-byte aligned and 64 bits wide, matching ACT's
 * conventional tohost/fromhost layout. V-FRONT uses the low 32-bit word.
 */
#define RVMODEL_DATA_SECTION                                      \
    .pushsection .tohost, "aw", @progbits;                        \
    .balign 8;                                                    \
    .global tohost;                                               \
tohost:                                                           \
    .dword 0;                                                     \
    .balign 8;                                                    \
    .global fromhost;                                             \
fromhost:                                                         \
    .dword 0;                                                     \
    .popsection;

/*
 * V-FRONT implements the standard RISC-V machine-mode CSR and trap model.
 * Enable ACT's standard M-mode boot and trap-handler infrastructure.
 */
#define STANDARD_SM_SUPPORTED

/*
 * Interrupt timing parameters required by the ACT environment.
 * The current RV32I test milestone does not generate interrupts.
 */
#define RVMODEL_INTERRUPT_LATENCY 10
#define RVMODEL_TIMER_INT_SOON_DELAY 100

/*
 * V-FRONT currently provides no software-controlled interrupt generator
 * to architectural tests. These hooks are placeholders required by ACT.
 */
#define RVMODEL_SET_MEXT_INT(_R1, _R2)
#define RVMODEL_CLR_MEXT_INT(_R1, _R2)

#define RVMODEL_SET_MSW_INT(_R1, _R2)
#define RVMODEL_CLR_MSW_INT(_R1, _R2)

#define RVMODEL_SET_SEXT_INT(_R1, _R2)
#define RVMODEL_CLR_SEXT_INT(_R1, _R2)

#define RVMODEL_SET_SSW_INT(_R1, _R2)
#define RVMODEL_CLR_SSW_INT(_R1, _R2)

/*
 * Write 1 to tohost to report success.
 *
 * The stores are repeated in case a future memory implementation has
 * variable acceptance latency. The testbench terminates after observing
 * the first completed store.
 */
#define RVMODEL_HALT_PASS                                         \
    li x1, 1;                                                     \
    la t0, tohost;                                                \
v_front_write_tohost_pass:                                        \
    sw x1, 0(t0);                                                 \
    sw x0, 4(t0);                                                 \
    j v_front_write_tohost_pass;

/*
 * Write 3 to tohost to report failure.
 */
#define RVMODEL_HALT_FAIL                                         \
    li x1, 3;                                                     \
    la t0, tohost;                                                \
v_front_write_tohost_fail:                                        \
    sw x1, 0(t0);                                                 \
    sw x0, 4(t0);                                                 \
    j v_front_write_tohost_fail;

/*
 * V-FRONT currently has no simulation console or UART. ACT requires this
 * macro to exist, but its implementation may be empty.
 */
#define RVMODEL_IO_WRITE_STR(_R1, _R2, _R3, _STR_PTR)

#endif