# Vivado Setup

## Creating the Project

1. Run Vivado

2. On Vivado's Tcl console, navigate to this directory and run `create_project.tcl` via:

```tcl
cd <path>/V-FRONT/vivado-setup/
source ./create_project.tcl
```

## Files in this Directory

### const.xdc

Includes constants needed to synthesise and implement the CPU. Its current contents are specific to the ARTY A7-100 board, but you can adapt it to the platform of your choice.

### create_project.tcl

Includes the Tcl script Vivado needs to build the project as intended. Please consider that this Tcl script was generated using Vivado v2025.2.1, and that it may not work as seamlessly in newer versions of the tool.
