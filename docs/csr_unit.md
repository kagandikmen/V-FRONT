# Documentation - CSR Unit

Below is a list of control and status registers V-FRONT implements in its CSR unit.

CSR             | Address        | Reset Value    | Permissions
----------------|----------------|----------------|----------------
jvt             | 0x17           | 0x0000_0000    | RW
mstatus         | 0x300          | 0x0000_0000    | RW
misa            | 0x301          | 0x4000_0000    | RW
mie             | 0x304          | 0x0000_0000    | RW
mtvec           | 0x305          | 0x0000_0000    | RW
mtvt            | 0x307          | 0x0000_0000    | RW
mscratch        | 0x340          | 0x0000_0000    | RW
mepc            | 0x341          | 0x0000_0000    | RW
mcause          | 0x342          | 0x0000_0000    | RW
mtval           | 0x343          | 0x0000_0000    | RW
custom1         | 0x7F0          | 0x0000_0000    | RW
custom2         | 0x7F1          | 0x0000_0000    | RW
mhartid         | 0xF14          | 0x0000_0000    | RO

`RW` = read & write
`RO` = read-only

Currently, V-FRONT only implements machine mode (M-mode) as privilege mode. Therefore, the CSR `jvt`, although actually being a user-level CSR, is handled like a machine-level one. V-FRONT also does not implement WARL masking yet, therefore all fields of a CSR are read-write as long as the CSR itself is read-write. Accesses to non-existent CSRs raise an illegal instruction exception (mcause = 2) in the hardware.
