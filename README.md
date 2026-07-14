<picture>
  <source
    srcset="docs/v-front_darkbanner.png"
    media="(prefers-color-scheme: dark)"
  />
  <source
    srcset="docs/v-front_lightbanner.png"
    media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"
  />
  <img src="docs/v-front_lightbanner.png" alt="V-FRONT Banner" />
</picture>

**V-FRONT** is a **five**-stage, 32-bit RISC-**V** CPU implemented in **V**erilog. It supports the base RISC-V ISA module RV32I, version 2.1.

### Summary

![RISC-V Badge (Static)](https://img.shields.io/badge/RISC--V-2e3168)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/kagandikmen/V-FRONT?label=last%20commit%20to%20master)](https://github.com/kagandikmen/V-FRONT/commits/master/)
[![GitHub Last Commit (dev)](https://img.shields.io/github/last-commit/kagandikmen/V-FRONT/dev?label=last%20commit%20to%20dev)](https://github.com/kagandikmen/V-FRONT/commits/dev/)
[![GitHub Actions Build Workflow Status](https://github.com/kagandikmen/V-FRONT/actions/workflows/build.yaml/badge.svg)](https://github.com/kagandikmen/V-FRONT/actions/workflows/build.yaml)
[![GitHub License](https://img.shields.io/github/license/kagandikmen/V-FRONT)](LICENSE)
[![Zenodo DOI Badge/Link](https://img.shields.io/badge/DOI-10.5281/zenodo.20783633-blue)](https://doi.org/10.5281/zenodo.20783633)

- RV32I v2.1 with Zicsr and Zifencei extensions
- Five-stage von Neumann architecture
- 32 KB unified dual-port dual-clock BRAM-based memory (16 KB program, 16 KB data)
- User (U) and machine (M) privilege modes implemented
- Handles exceptions via trap vector `mtvec_handler`
- Unit tests for functional correctness and ISA compliance
- Flow scripts enabling an easy jump-in for Vivado or QuestaSim users

## Prerequisites

[RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) needs to be installed on the host machine to run the unit tests, or just to compile a program for V-FRONT. Installation instructions can be found in its own [README.md](https://github.com/riscv-collab/riscv-gnu-toolchain/blob/master/README.md) file. Please use:
```bash
./configure --prefix=/opt/riscv --with-abi=ilp32 --with-arch=rv32i
```
while installing RISC-V GNU Toolchain, as this is the configuration required by V-FRONT. 

Unit tests can be run with Icarus Verilog or Vivado. If you are using Ubuntu, install Icarus Verilog via:
```bash
sudo apt install verilog
```
To download Vivado, please see AMD's [Downloads](https://www.xilinx.com/support/download.html) portal for Vivado Design Suite. You may need to agree to certain terms and conditions. To use Vivado, packages `libncurses5` and `libtinfo5` may also be required.

V-FRONT comes with simulation flow scripts for Vivado and QuestaSim. To download QuestaSim, please see Altera's [Downloads](https://www.altera.com/downloads/) portal. You may need to agree to certain terms and conditions.

## Getting Started

To start working with V-FRONT, run:
```bash
git clone --recursive https://github.com/kagandikmen/V-FRONT.git
```
from your working directory. If you already cloned the repository without the `--recursive` option, use:
```bash
git submodule update --init --recursive
```
from inside the V-FRONT directory. To run the unit tests with Icarus Verilog, use:
```bash
make
```
from V-FRONT project root. To run the unit tests using Vivado, run:
```bash
make SIM_TOOL=vivado
```
In correct setup, the tests should all pass; there is no test failing as of 2026-07-13.

V-FRONT comes with simulation flow scripts for Vivado and QuestaSim. To create the "ideal" Vivado project for V-FRONT, use:
```bash
make build/vivado
```
If you want to create the QuestaSim project instead (or alongside), use:
```bash
make build/questa   # GUI=0/1 MEMFILE=your_program.mem
```
To get rid of all the files generated during the tests, run:
```bash
make clean_all
```
Find an example of how a generic C program can be compiled to run on V-FRONT by navigating to [sw/test/](sw/test/).

## Project Structure

```
.
├── .github           # GitHub Actions setup
├── docs              # Project documentation and images           
├── lib               # Verilog libraries for constants and functions
├── rtl               # Verilog source code
│   └── cpu               # V-FRONT CPU and its submodules
│   └── soc               # Coherence SoC environment
├── sim               # Verilog testbenches
├── sw                # Software helpers (e.g. trap vectors and linker scripts)
│   └── test              # Demo software
├── target            # Simulation flows for an easy onboarding
│   └── questa            # QuestaSim flow
│   └── vivado            # Vivado flow
└── ut                # Unit tests (riscv-tests + V-FRONT's own)
```

## Architectural Details

V-FRONT implements a five-stage pipelined von Neumann CPU architecture. In its current configuration, it has a 32 KB unified memory to store both program and data, where the first 16 KB is reserved for program memory and the second 16 KB for data memory. Misaligned accesses to the data memory are detected by the CPU, which then raises an exception and jumps to a trap vector to handle the misaligned access.

V-FRONT implements a CSR unit with details you can find [here](docs/csr_unit.md). As of 2026-07-14, the hardware can raise exceptions in case of:

- a misaligned data memory access,
- an illegal instruction,
- an illegal instruction address.

Software exceptions are raised through `ecall` and `ebreak` instructions. Any exception is resolved through jumping to the trap vector you can find [here](sw/mtvec_handler.S). 

V-FRONT supports user mode (U-mode) and machine mode (M-mode) as its privilege modes.

V-FRONT implements `fence` and `fence_i` instructions as pure `NOP`s, as these instructions do not serve any meaningful purpose in a single-core setting.

V-FRONT is tested for functional correctness and ISA compliance using the unit tests in the [ut](ut/) folder. This directory includes tests sourced from [riscv-tests](https://github.com/riscv-software-src/riscv-tests). There are additional tests under [ut/v-front](ut/v-front/) as well. See [Getting Started](#getting-started) to learn how you can run the tests yourself.

## Status

The unit tests all pass as of 2026-07-14. The design is fully synthesizable.

### Known Issues

- The five-stage pipeline is fully implemented and tested, but not optimized yet for performance. As a result, the current implementation runs at relatively low clock frequencies (below 20 MHz on Zynq 7020).
- The control logic shoulders instruction decoding far too much. As much of it as possible should be moved to the instruction decoder module.
- There are parametrization issues. Some parameters (like `PC_WIDTH`) do little to nothing.
- The CSR module does not implement read/write masking yet. CSR write operations can write to any field of a register as long as the register is read-write.
- Interrupts are only halfway implemented.
- Documentation is very limited; needs to be extended.

## Contributing

Pull requests, suggestions, and bug reports are all welcome. Please refrain from opening pull requests that only include cosmetic changes. AI-generated code is also strongly discouraged.

## Citing

If you use V-FRONT in your work, please cite it. You can use GitHub's "Cite this repository" button on the top right of the repository page to export a citation in APA or BibTeX format.

## License

V-FRONT is licensed under the MIT License. See [LICENSE](LICENSE) for details.

V-FRONT incorporates components and code from external sources. For detailed license and copyright information regarding these components, please refer to [NOTICE.md](NOTICE.md).
