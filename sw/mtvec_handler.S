# Trap vector mtvec_handler to manage misaligned loads and stores
# Created:      2025-05-28
# Modified:     2025-06-02
# Author:       Kagan Dikmen

.section .text.mtvec

# in the hardware:
# mscratch stores the instruction
# csr 0x7f0 stores the addr
# csr 0x7f1 stores for loads: target register
#                  for stores: data to be written

.global mtvec_handler
mtvec_handler:
    jal ra, gpr_save
    csrr t5, mcause
    li t6, 0x6
    beq t5, t6, load_misaligned
    csrr t5, mcause
    li t6, 0x4
    beq t5, t6, store_misaligned
    j finalize

load_misaligned:
    csrr t5, mscratch
    li t6, 0x00007000
    and t6, t5, t6  
    srli t6, t6, 0xc    # stores funct3
    li t3, 0x2
    beq t6, t3, lw_misalignment
    li t3, 0x1
    beq t6, t3, lh_misalignment
    li t3, 0x5
    beq t6, t3, lhu_misalignment

lw_misalignment:
    csrr t5, mscratch
    csrr t3, 0x7f0              # stores addr
    andi t4, t3, 0x00000003     # stores offset
    slli t4, t4, 0x3            # stores offset in bits
    andi t3, t3, 0xfffffffc     # stores proper address of lower word
    mv t6, t3
    lw t3, 0(t6)                # stores lower word
    lw t6, 4(t6)                # stores upper word
    li t2, 0x20
    sub t2, t2, t4              # stores 32 minus offset in bits
    srl t0, t3, t4              # shifts lower word right by offset
    sll t1, t6, t2              # shifts upper word left by 32-offset
    add t0, t0, t1              # final result
    csrr t1, 0x7f1
    sll t1, t1, 0x2
    add t1, t1, sp
    sw t0, 0(t1)
    j finalize

lh_misalignment:
    csrr t5, mscratch
    csrr t3, 0x7f0              # stores addr
    andi t4, t3, 0x00000003     # stores offset
    li t2, 0x1
    beq t4, t2, lh_offset1
    li t2, 0x3
    beq t4, t2, lh_offset3
lh_offset1:
    andi t3, t3, 0xfffffffc     # address of the word
    lw t3, 0(t3)
    srli t3, t3, 8
    li t4, 0x0000ffff
    and t3, t3, t4
    slli t3, t3, 16
    srai t3, t3, 16
    j lh_misalignment_epilogue
lh_offset3:
    andi t3, t3, 0xfffffffc     # address of the word
    lw t4, 4(t3)
    lw t3, 0(t3)
    li t5, 0xff000000
    and t3, t3, t5
    srli t3, t3, 24
    li t5, 0x000000ff
    and t4, t4, t5
    slli t4, t4, 24
    srli t4, t4, 16
    add t3, t3, t4
    slli t3, t3, 16
    srai t3, t3, 16
    j lh_misalignment_epilogue
lh_misalignment_epilogue:
    csrr t1, 0x7f1
    sll t1, t1, 0x2
    add t1, t1, sp
    sw t3, 0(t1)
    j finalize

lhu_misalignment:
    csrr t5, mscratch
    csrr t3, 0x7f0              # stores addr
    andi t4, t3, 0x00000003     # stores offset
    li t2, 0x1
    beq t4, t2, lhu_offset1
    li t2, 0x3
    beq t4, t2, lhu_offset3
lhu_offset1:
    andi t3, t3, 0xfffffffc     # address of the word
    lw t3, 0(t3)
    srli t3, t3, 8
    li t4, 0x0000ffff
    and t3, t3, t4
    slli t3, t3, 16
    srli t3, t3, 16
    j lhu_misalignment_epilogue
lhu_offset3:
    andi t3, t3, 0xfffffffc     # address of the word
    lw t4, 4(t3)
    lw t3, 0(t3)
    li t5, 0xff000000
    and t3, t3, t5
    srli t3, t3, 24
    li t5, 0x000000ff
    and t4, t4, t5
    slli t4, t4, 24
    srli t4, t4, 16
    add t3, t3, t4
    slli t3, t3, 16
    srli t3, t3, 16
    j lh_misalignment_epilogue
lhu_misalignment_epilogue:
    csrr t1, 0x7f1
    sll t1, t1, 0x2
    add t1, t1, sp
    sw t3, 0(t1)
    j finalize

store_misaligned:
    csrr t5, mscratch
    li t6, 0x00007000
    and t6, t5, t6
    srli t6, t6, 0xc    # stores funct3
    li t3, 1
    beq t6, t3, sh_misalignment
    li t3, 2
    beq t6, t3, sw_misalignment

sh_misalignment:
    csrr t5, mscratch
    csrr t3, 0x7f0              # stores addr
    andi t4, t3, 0x00000003     # stores offset
    li t2, 0x1
    beq t4, t2, sh_offset1
    li t2, 0x3
    beq t4, t2, sh_offset3
sh_offset1:
    andi t3, t3, 0xfffffffc     # address of the word
    csrr t4, 0x7f1              # halfword to be written
    slli t4, t4, 8
    lw t5, 0(t3)
    li t6, 0xff0000ff
    and t5, t5, t6
    li t6, 0x00ffff00
    and t4, t4, t6
    add t4, t4, t5
    sw t4, 0(t3)
    j finalize
sh_offset3:
    andi t3, t3, 0xfffffffc     # address of the lower word
    csrr t4, 0x7f1              # halfword to be written
    andi t5, t4, 0x0ff          # lower byte -> t5
    srli t6, t4, 8
    andi t6, t6, 0x0ff          # upper byte -> t6
    sb t5, 3(t3)
    sb t6, 4(t3)
    j finalize

sw_misalignment:
    csrr t3, 0x7f0          # addr -> t3
    csrr t6, 0x7f1          # word -> t6
    li t2, 0x0ff
    and t2, t2, t6         # byte 0 -> t2
    sb t2, 0(t3)
    srli t6, t6, 8
    li t2, 0x0ff
    and t2, t2, t6         # byte 1 -> t2
    sb t2, 1(t3)
    srli t6, t6, 8
    li t2, 0x0ff
    and t2, t2, t6         # byte 2 -> t2
    sb t2, 2(t3)
    srli t6, t6, 8
    li t2, 0x0ff
    and t2, t2, t6         # byte 3 -> t2
    sb t2, 3(t3)
    j finalize

finalize:
    csrr t3, mepc
    addi t3, t3, 4
    csrw mepc, t3
    j gpr_restore

gpr_save:
    addi sp, sp, -128
    sw x0, 0(sp)
    sw x1, 4(sp)
    sw x2, 8(sp)    
    sw x3, 12(sp)
    sw x4, 16(sp)
    sw x5, 20(sp)
    sw x6, 24(sp)
    sw x7, 28(sp)
    sw x8, 32(sp)
    sw x9, 36(sp)
    sw x10, 40(sp)
    sw x11, 44(sp)
    sw x12, 48(sp)
    sw x13, 52(sp)
    sw x14, 56(sp)
    sw x15, 60(sp)
    sw x16, 64(sp)
    sw x17, 68(sp)
    sw x18, 72(sp)
    sw x19, 76(sp)
    sw x20, 80(sp)
    sw x21, 84(sp)
    sw x22, 88(sp)
    sw x23, 92(sp)
    sw x24, 96(sp)
    sw x25, 100(sp)
    sw x26, 104(sp)
    sw x27, 108(sp)
    sw x28, 112(sp)
    sw x29, 116(sp)
    sw x30, 120(sp)
    sw x31, 124(sp)
    ret

gpr_restore:
    lw x0, 0(sp)
    lw x1, 4(sp)
#   lw x2, 8(sp)    
    lw x3, 12(sp)
    lw x4, 16(sp)
    lw x5, 20(sp)
    lw x6, 24(sp)
    lw x7, 28(sp)
    lw x8, 32(sp)
    lw x9, 36(sp)
    lw x10, 40(sp)
    lw x11, 44(sp)
    lw x12, 48(sp)
    lw x13, 52(sp)
    lw x14, 56(sp)
    lw x15, 60(sp)
    lw x16, 64(sp)
    lw x17, 68(sp)
    lw x18, 72(sp)
    lw x19, 76(sp)
    lw x20, 80(sp)
    lw x21, 84(sp)
    lw x22, 88(sp)
    lw x23, 92(sp)
    lw x24, 96(sp)
    lw x25, 100(sp)
    lw x26, 104(sp)
    lw x27, 108(sp)
    lw x28, 112(sp)
    lw x29, 116(sp)
    lw x30, 120(sp)
    lw x31, 124(sp)
    addi sp, sp, 128
    mret

