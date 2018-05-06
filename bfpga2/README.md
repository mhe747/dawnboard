  
# Fpga Xilinx Spartan 3S500E  - Tested, working

## 
We would test the programmable clock oscillator and test the SPI control port before. The access to FPGA requires working GPIO, SPI and UART ports, ref. schematics, in order build applications for interaction with the FPGA design. Therefore MLO, U-boot and Linux Kernel driver with pin muxing support including GPIO, SPI, I2C and UART are required.

------

## FPGA Design
Synthesizing an FPGA design requires the Xilinx ISE 14.7 which is free downloadable from the Xilinx website. Also, you can make a design using Matlab HDL Coder with Xilinx System Generator that makes Xilinx FPGAs bitfile, which is the best tool to make things easily and without pain.
Xilinx ISE 14.7 is a suite of tools includes IMPACT the bitfile download tool through JTAG without Beagleboard-x15, as well as command-line applications that can be run under both Linux and Windows. Designs can be created with either Verilog or VHDL, or Xilinx Schematics. IMPACT provides the possibility to convert a bitfile to the corresponding mcs file, so you can store it into the non-volatile flash memory.

------

Consider using Xilinx Platform Cable USB and Xilinx Impact to program the FPGA. This method is the fastest, tested and works very well.
