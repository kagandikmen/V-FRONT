# V-CORE

*(The V stands for Verilog, RISC-V, or perhaps my intention to make the CPU 5-stage some day.)*

**V-CORE** is a 32-bit RISC-V processor written in Verilog. It implements RISC-V ISA base module RV32I, version 2.1. 

It also implements the extensions:
- Zicsr
- Zifencei

## Getting Started

This repository initiates [luftALU](https://github.com/kagandikmen/luftALU) as a submodule. Run
```
git submodule update --init --recursive
```
from the root directory of the project. For the automated Vivado setup please refer to `vivado-setup/README.md`.

## Status

The data and control flow instructions are implemented and tested for synthesizability. The current design runs stably at 62.5 MHz on a PYNQ-Z1 board.

There are instructions that do not pass the unit tests yet, a list of which can be found in [Makefile](Makefile).

## Contributing

Pull requests, suggestions, and bug reports are all welcome.

## License

MIT License