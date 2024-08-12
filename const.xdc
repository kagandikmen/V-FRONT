# Constraints for Xilinx' PYNQ-Z1 Board

# 40 MHz clock signal
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports sysclk]
    create_clock -add -name sysclk -period 25.00 -waveform {0 12.5} [get_ports sysclk]

# Reset
set_property -dict { PACKAGE_PIN D19    IOSTANDARD LVCMOS33 } [get_ports rst]

# not really used, is there so that Vivado does not optimise everything away
set_property -dict { PACKAGE_PIN R14    IOSTANDARD LVCMOS33 } [get_ports led]