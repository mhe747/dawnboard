

  Based on the steps of making of gnuradio plugin for BeagleSDR / Beagleboard-x15 project :

--- GNU Radio ---
Create a class, spi.control, that lets you control the FPGA and ADC from Python or C++
Add daughterboard support (see usrp/host/lib/db*)
Create spi.source and spi.sink blocks that are more flexible than spi.srcsink
Move the spi package into the gr package (it really belongs in gnuradio-core/src/lib/io)

--- OpenEmbedded ---
Make a BitBake recipe that will actually install gr-spi
Need McSPI port activated in kernel and U-Boot
Patch the BitBake recipe for GNU Radio to demand python-numpy as a prerequisite
Make a BitBake recipe that will compile and install wxPython, so GNU Radio can have wxgui-qt5

--- FPGA ---
start with the Verilog design for the USRP and adapt it to work
Add a receive path (downmixing/filtering) 
Add daughterboard support
Change the pin configuration to the correct one for Beagleboard-x15 P17 port (SPI connected)

I. Getting Started
 A. OpenEmbedded
  1. Setting up OE
  2. Adding our special patches & recipes
  3. Creating an image
 B. BeagleBoard
  1. Putting the image on an SD card
  2. Flashing the BeagleBoard to read the correct u-boot
 C. The Board with No Name
  1. Power, daughterboard, RF, and BeagleBoard connections
  2. Compiling the VHDL design
  3. Programming using JTAG or ASMI
 D. GNU Radio
  1. Running the GUIfied example
  2. Using the spi.srcsink_ss block
  3. Using the spi.control block
II. System Description
 A. Overview: big huge block diagram
 B. RF daughterboards
  1. Analog signal path
  2. Digital signals exposed
  3. Our current support for them
 C. The ADC/DAC
  1. Control registers
  2. Analog characteristics
  3. Signal processing path
 D. The FPGA
  1. Control registers
  2. SPI interface
  3. Signal processing path
 E. The BeagleBoard
  1. Pin muxing
  2. spidev
  3. The SPI and MMC subsystems: I'm not a kernel hacker, you can be one if you want
 F. GNU Radio
  1. Scheduling and "What is a block?"
  2. SWIG and flow graphs in Python
  3. Dictionary of signal processing blocks
  4. wxgui and its use
  5. Accelerating GNU Radio with NEON or DSP instructions
 G. OpenEmbedded
  1. What, exactly, OE provides (metadata)
  2. What BitBake does (tasks and built process)
  3. Creating / modifying your own recipes
