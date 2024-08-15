# Constraints for Xilinx' PYNQ-Z1 Board

# 62.5 MHz clock signal
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports sysclk]
    create_clock -add -name sysclk -period 16.00 -waveform {0 8} [get_ports sysclk]

# Reset
set_property -dict { PACKAGE_PIN D19    IOSTANDARD LVCMOS33 } [get_ports rst]

# not really used, is there so that Vivado does not optimise everything away
set_property -dict { PACKAGE_PIN R14    IOSTANDARD LVCMOS33 } [get_ports led]