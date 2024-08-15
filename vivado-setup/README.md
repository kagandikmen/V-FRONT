# Vivado Setup

## Creating the Project

1. Run Vivado

2. Direct to this directory with

```
cd <path>/Single-Cycle-RISCV-CPU/vivado-setup/
```

3. Run the Tcl script with

```
source ./create_project.tcl
```

## Files in this Directory

### const.xdc

Includes constants needed to synthesise and implement the CPU. Its current contents are specific to the PYNQ-Z1 board, but you can adapt it to the platform of your choice.

### create_project.tcl

Includes the Tcl script Vivado needs to build the project as intended.

### dummy_instrs.mem

Includes some dummy instructions the program memory is loaded with initially. Allows the user to test the functionality of the CPU out-of-the-shelf. You can change/extend it with your own dummy instructions.
