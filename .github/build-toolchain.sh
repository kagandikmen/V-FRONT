#!/bin/bash

cd /opt/
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
mkdir riscv
cd riscv-gnu-toolchain/
./configure --prefix=/opt/riscv --with-abi=ilp32 --with-arch=rv32i
make -j $(nproc)
