# Single-Cycle-RISCV-CPU

This is a project in which I am rewriting a group assignment I contributed to for the class ["Entwurf digitaler Systeme mit VHDL und SystemC"](https://www.ce.cit.tum.de/eda/lehrveranstaltungen/?tx_tumcourses_list%5Bc15024%5D=c950695874) (Digital System Design with VHDL and SystemC) using Verilog. The project involves the implementation and testing of a single-cycle CPU based on RISC-V ISA (RV32I).

## Getting Started

This repository includes [luftALU](https://github.com/kagandikmen/luftALU) as a submodule. Run
```
git clone --recursive https://github.com/kagandikmen/Single-Cycle-RISCV-CPU.git
```
from the directory you want to clone the repository into. For the automated Vivado setup please refer to ```vivado-setup/README.md```.

## Status

The data flow instructions are completed and tested for synthesisability. The current design can run fine at 62.5 MHz on a PYNQ-Z1 board. Some control flow instructions are not implemented yet.

## Contributing

Pull requests, suggestions, bug fixes etc. are all welcome.

## License

MIT License