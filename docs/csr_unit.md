# Documentation - CSR Unit

Below is a list of control and status registers V-FRONT implements in its CSR unit.

CSR             | Address        | Reset Value    | Permissions
----------------|----------------|----------------|----------------
jvt             | 0x17           | 0x0000_0000    | URW
mstatus         | 0x300          | 0x0000_0000    | MRW
misa            | 0x301          | 0x4010_0100    | MRW
mie             | 0x304          | 0x0000_0000    | MRW
mtvec           | 0x305          | 0x0000_0000    | MRW
mcounteren      | 0x306          | 0x0000_0000    | MRW
mstatush        | 0x310          | 0x0000_0000    | MRW
mscratch        | 0x340          | 0x0000_0000    | MRW
mepc            | 0x341          | 0x0000_0000    | MRW
mcause          | 0x342          | 0x0000_0000    | MRW
mtval           | 0x343          | 0x0000_0000    | MRW
mip             | 0x344          | 0x0000_0000    | MRW
mtinst          | 0x34A          | 0x0000_0000    | MRW
mtval2          | 0x34B          | 0x0000_0000    | MRW
mcycle          | 0xB00          | 0x0000_0000    | MRW
minstret        | 0xB02          | 0x0000_0000    | MRW
mcycleh         | 0xB80          | 0x0000_0000    | MRW
minstreth       | 0xB82          | 0x0000_0000    | MRW
mvendorid       | 0xF11          | 0x0000_0000    | MRO
marchid         | 0XF12          | 0x0000_0000    | MRO
mimpid          | 0xF13          | 0x0000_0000    | MRO
mhartid         | 0xF14          | 0x0000_0000    | MRO
mconfigptr      | 0xF15          | 0x0000_0000    | MRO

`URW` = user read & write
`MRW` = machine read & write
`MRO` = machine read-only

V-FRONT does not implement read/write masking yet, except for the misa register and the MPP field of mstatus. Otherwise, all fields of a CSR are read-write as long as the CSR itself is read-write. Accesses to non-existent or unpermitted CSRs raise an illegal instruction exception (mcause = 2). Implementing interrupts is ongoing work as of 2026-07-14.
