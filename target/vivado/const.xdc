# Constraints for Xilinx' ARTY A7-100 Board

# 16.67 MHz clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports sysclk]
    create_clock -add -name sysclk -period 60.00 [get_ports sysclk]

# Reset
set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports rst]

# not really used, is there so that Vivado does not optimize everything away
set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports led]