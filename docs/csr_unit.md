# Documentation - CSR Unit

Below is a list of control and status registers V-FRONT implements in its CSR unit.

CSR             | Address        | Reset Value    | Permissions
----------------|----------------|----------------|----------------
jvt             | 0x17           | 0x0000_0000    | URW
mstatus         | 0x300          | 0x0000_0000    | MRW
misa            | 0x301          | 0x4000_0000    | MRW
medeleg         | 0x302          | 0x0000_0000    | MRW
mideleg         | 0x303          | 0x0000_0000    | MRW
mie             | 0x304          | 0x0000_0000    | MRW
mtvec           | 0x305          | 0x0000_0000    | MRW
mcounteren      | 0x306          | 0x0000_0000    | MRW
mstatush        | 0x307          | 0x0000_0000    | MRW
medelegh        | 0x308          | 0x0000_0000    | MRW
mtvt            | 0x307          | 0x0000_0000    | MRW
mscratch        | 0x340          | 0x0000_0000    | MRW
mepc            | 0x341          | 0x0000_0000    | MRW
mcause          | 0x342          | 0x0000_0000    | MRW
mtval           | 0x343          | 0x0000_0000    | MRW
mip             | 0x344          | 0x0000_0000    | MRW
mtinst          | 0x34A          | 0x0000_0000    | MRW
mtval2          | 0x34B          | 0x0000_0000    | MRW
mvendorid       | 0xF11          | 0x0000_0000    | MRO
marchid         | 0XF12          | 0x0000_0000    | MRO
mimpid          | 0xF13          | 0x0000_0000    | MRO
mhartid         | 0xF14          | 0x0000_0000    | MRO
mconfigptr      | 0xF15          | 0x0000_0000    | MRO

`URW` = user read & write
`MRW` = machine read & write
`MRO` = machine read-only

V-FRONT also does not implement WARL masking yet, therefore all fields of a CSR are read-write as long as the CSR itself is read-write. Accesses to non-existent CSRs raise an illegal instruction exception (mcause = 2) in the hardware.
