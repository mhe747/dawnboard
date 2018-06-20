

These are the bitbake recipe and FPGA VHDL files previously based on H. Villeneuve and Ph. Balister design of FPGA software radio logic using GNU Radio software. I have adapted to BeagleSDR board / Beagleboard X15

That's the way :

	1. Add https://github.com/balister/meta-sdr into your bitbake sources config
	in build/conf/bblayers.conf :

		BBLAYERS += " \
		/home/osboxes/bbx15/tisdk/sources/meta-processor-sdk \
		/home/osboxes/bbx15/tisdk/sources/meta-sdr \
		...


	2. Go to bitbake sources sub-directory in "tisdk/sources/", then
	    git pull https://github.com/balister/meta-sdr
	    
	3. Add the file gr-spi_0.3.bb recipe found in this repository into your sources/meta-sdr directory
	    in bitbake's directory sources/meta-sdr/recipes-support/gr-spi

	4. MACHINE=am57xx-evm bitbake gr-spi
	    tested as 100 % compilable on gnuradio 3.8

 Basical steps : making of gnuradio plugin for BeagleSDR / Beagleboard-x15 project

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

		Start the design with Xilinx ISE 14.7
		Check reception and transmission path (maybe add downmixing/filtering) 
		Check SPI support
		Check the pins configuration to the correct one for Beagleboard-x15 P17 port (SPI connected)


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
  3. Programming using JTAG
		
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
		
		
Ext link where the old files came from and designed for Beagleboard 1st version and -xM version :
		
	http://trac.geekisp.com/opensdr/browser
	https://wiki.gnuradio.org/index.php/Main_Page
	https://wiki.gnuradio.org/index.php/Embedded_Development_with_GNU_Radio
	https://wiki.gnuradio.org/index.php/GNURadioCompanion
	https://wiki.gnuradio.org/index.php/Guided_Tutorial_GNU_Radio_in_Python
	https://wiki.gnuradio.org/index.php/Guided_Tutorial_GRC
	https://wiki.gnuradio.org/index.php/TutorialsWritePythonApplications
	https://wiki.gnuradio.org/index.php/HowToUse
	http://udel.edu/~mm/gr/
	http://www.ece.uvic.ca/~elec350/lab_manual/ar01s01s02.html

