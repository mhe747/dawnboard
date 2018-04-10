
## User
Using bfpga2, one can push a bitfile from Beagleboard-x15 to the BeagleSDR in order to reprogram the FPGA by downloading FPGA configuration bitfile through the SPI Flash memory. One should have control of the programmable clock oscillator and therefore one should test the SPI control port before. The access library provides a low-level API for control of the I2C and SPI ports, as well as higher level functions for bitstream download and may be used to construct complex user-space applications for interaction with the FPGA design. Full sources are available here, forked from initial repository git://gitorious.org/bfpga_lib/bfpga2_lib.git
however the newest updated Kernel is needed. MLO, U-boot and Linux Kernel driver with pin muxing support including I2C and SPI is required.

## FPGA Design
Synthesizing an FPGA design requires the Xilinx ISE 14.7 which is free downloadable from the Xilinx website.
This suite of tools includes a IMPACT the programming tool, and IDE as well as command-line applications that can be run under both Linux and Windows.
Designs can be created with either Verilog or VHDL.


------
