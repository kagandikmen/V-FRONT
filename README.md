# V-FRONT

*(The V stands for Verilog, RISC-V, or perhaps my intention to make the CPU 5-stage some day.)*

**V-FRONT** is a 32-bit RISC-V processor written in Verilog. It implements RISC-V ISA base module RV32I, version 2.1. 

### Features

- RV32I (v2.1) compliant, with Zicsr and Zifencei extensions
- Single-cycle von Neumann architecture
- 32 KB unified dual-port dual-clock BRAM-based memory (16 KB code, 16 KB data)
- CSR unit with 4096 CSR registers
- Handles misaligned memory accesses via trap vector `mtvec_handler`
- Fully tested with riscv-tests as of 2025-05-29

## Prerequisites

[RISC-V GNU TOOLCHAIN](https://github.com/riscv-collab/riscv-gnu-toolchain) needs to be installed on the host machine to run the unit tests, or just to compile a program for V-FRONT. Installation instructions can be found in its own [README.md](https://github.com/riscv-collab/riscv-gnu-toolchain/blob/master/README.md) file. Please use 
```
./configure --prefix=/opt/riscv --with-abi=ilp32 --with-arch=rv32i
```
while installing RISC-V GNU Toolchain, as this is the configuration required by V-FRONT. To run the unit tests, Icarus Verilog needs to be installed on the host machine. For this, run
```
sudo apt install iverilog
```
The tests can be run using Vivado, as well. To download Vivado, please see AMD's [Downloads](https://www.xilinx.com/support/download.html) portal for Vivado Design Suite. To run the unit tests using Vivado, libraries `libncurses5` and `libtinfo5` are also required, which can be installed through
```
sudo apt install libncurses5 libtinfo5
```

## Getting Started

To start working with V-FRONT, run
```
git clone --recursive https://github.com/kagandikmen/V-FRONT.git
```
from your working directory. To run the unit tests with Icarus Verilog, use
```
make
```
after navigating into the V-FRONT directory. To run the tests using Vivado, run
```
make run_vivado
```
In correct setup, the tests should all pass; there is no test failing as of 2025-05-29. To get rid of all the files generated during the tests, run
```
make clean_all
```
Find an example of how a generic C file can be compiled to run on V-FRONT by navigating to [sw/test/](sw/test/). A Tcl script automatizing Vivado project generation is also offered with V-FRONT; for this, please refer to [vivado-setup/README.md](vivado-setup/README.md).

## Project Structure

- `lib/` - Verilog libraries for constants and functions commonly used throughout the design
- `rtl/` - Verilog source code
- `sim/` - Verilog testbenches
- `sw/` - Software helpers such as trap vectors and linker scripts; also includes demo software
- `ut/` - Unit tests taken from [riscv-tests](https://github.com/riscv-software-src/riscv-tests)
- `vivado-setup/` - Helpers for easy setup on Vivado

## Architectural Details

V-FRONT has been tested for full RV32I compliance using the unit tests in the [ut](ut/) folder, which are sourced from [riscv-tests](https://github.com/riscv-software-src/riscv-tests), the official test suite provided by RISC-V International.

V-FRONT implements a single-cycle von Neumann CPU architecture. In its current configuration, it has a 32 KB unified memory to store both program and data, where the first 16 KB is reserved for programs and the second 16 KB for data. Misaligned accesses to this unified BRAM memory are allowed, where the CPU then raises an exception and jumps to a trap vector to handle the misaligned access.

V-FRONT implements 4096 CSR registers in its CSR unit. As of 2025-05-29, the only exception the hardware itself can raise is when a misaligned memory access is attempted. But software can raise any exception through `ecall` and `ebreak` instructions, where the program then jumps to the address stored in the CSR register `MTVEC`.

V-FRONT implements `fence` and `fence_i` instructions as pure `NOP`s, as these instructions do not serve any meaningful purpose in a single-core setting.

## Status

The unit tests all pass as of 2025-05-29.

## Contributing

Pull requests, suggestions, and bug reports are all welcome.

## License

V-FRONT is licensed under MIT License. See [LICENSE](LICENSE) for details.

V-FRONT incorporates components and code from external sources. For detailed license and copyright information regarding these components, please refer to [NOTICE.md](NOTICE.md).