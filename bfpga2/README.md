 
# Fpga Xilinx Spartan 3S500E  - Tested, working

## 
We would test the programmable clock oscillator and test the SPI control port before. The access to FPGA requires working GPIO, SPI and UART ports, ref. schematics, in order build applications for interaction with the FPGA design. Therefore MLO, U-boot and Linux Kernel driver with pin muxing support including GPIO, SPI, I2C and UART are required.

------

## FPGA Design
Synthesizing an FPGA design requires the Xilinx ISE 14.7 which is free downloadable from the Xilinx website. Also, you can make a design using Matlab HDL Coder with Xilinx System Generator (should be compatible to Matlab 2009 - 2012) that makes Xilinx FPGAs bitfile, which is the best tool to make things easily and without pain.
Xilinx ISE 14.7 is a suite of tools includes IMPACT the bitfile download tool through JTAG without Beagleboard-x15, as well as command-line applications that can be run under both Linux and Windows. Designs can be created with either Verilog or VHDL, or Xilinx Schematics. IMPACT provides the possibility to convert a bitfile to the corresponding mcs file, so you can store it into the non-volatile flash memory.

------

Consider using Xilinx Platform Cable USB and Xilinx Impact to program the FPGA. This method is the fastest, tested and works very well.
Sometimes, people used to ask me how to freeze the FPGA rom and to avoid burning every time the same bit file, so ok following description would be the operation to perform :

	Programmer cable should be connected to the Spartan 3S500E BeagleSDR board.
	Launch Xilinx iMPACT (ISE Design Suite > ISE Design Tools > 64-bit Tools)
	
	** Double-Click on Boundary Scan, or Right-Click in main window and select “Initialize Chain”.	
	** In the iMPACT Flows window, DC on “Create PROM File (PROM File Format...” should be the third options from top.
	** Select SPI Flash, then Green Arrow between Step1 and Step2.
	** Change Storage device to 4M and click on “Add Storage Device”, then second Green Arrow between Step2 and Step3.
	** Enter Output File Name.
	** Enter Output File Location (use same location as .bit file).
	** Click OK.
	** At Add Device popup, click OK.
	** Select the .bit File.
	** Click NO when asked “would you like to add another device file to”.
	** Click OK to “You have completed the device file entry”.
	** In the iMPACT Processes window, DC on Generate File.  Should then say “Generate Succeeded”.
	** Go back and click on Boundary Scan, Initialize the chaine.
	** Choose the .bit file, a pop up window opens to ask you if you want to attach an SPI or BPI PROM to this device
	** Click on yes, and choose the previously generated mcs file
	** In new pop up window select SPI PROM (left) and at right the “M25P40” device.
	** In Main Window, the fpga xc3s500e icon now is shown with new icon “FLASH” above it.
	** Right click on it and Program.


Just Relax. 
PROM programming should now start. At its end, “Program Succeeded” should be displayed. From here, you should no longer need to burn the .bit file again.
