
# bfpga2

## User
Using bfpga2, one can push a bitfile from Beagleboard-x15 to the BeagleSDR in order to reprogram the FPGA configuration bitfile through the SPI Bus to its internal memory. We would test the programmable clock oscillator and test the SPI control port before. The access library provides a low-level API for control of the I2C and SPI ports, as well as higher level functions for bitstream download and may be used to construct complex user-space applications for interaction with the FPGA design. Full sources are available here, forked from initial repository git://gitorious.org/bfpga_lib/bfpga2_lib.git
however the newest updated Kernel is needed. MLO, U-boot and Linux Kernel driver with pin muxing support including I2C and SPI are required.

------

## FPGA Design
Synthesizing an FPGA design requires the Xilinx ISE 14.7 which is free downloadable from the Xilinx website. Also, you can make a design using Matlab HDL Coder with Xilinx System Generator that makes Xilinx FPGAs bitfile.
This suite of tools includes IMPACT the bitfile download tool through JTAG without Beagleboard-x15, as well as command-line applications that can be run under both Linux and Windows. Designs can be created with either Verilog or VHDL, or Xilinx Schematics. IMPACT provides the possibility to convert a bitfile to the corresponding mcs file, so you can store it into the non-volatile flash memory.

------

## Upload to BeagleSDR

To adapt the I2C mapping, change the file bfpga2_lib.c :

    #define I2C_ADDR_EXPANDER 0x20
    #define I2C_ADDR_LTC 0x17
    #define I2C_ADDR_EEPROM 0x50
    #define PROG_FREQ 48000000
    #define MAX_DUMMY_CLOCK 10000000

in 
------

    To program the FPGA, one has to do :
    root@am57xx-evm:~# ./bfpga2tool -v testfile_la.bit 
    bfpga2_init: opened I2C device /dev/i2c-3
    bfpga2_init: ID[0] = 0xFF
    bfpga2_init: ID[1] = 0xFF
    bfpga2_init: ID[2] = 0xFF
    bfpga2_init: ID[3] = 0xFF
    bfpga2_init: ID[4] = 0xFF
    bfpga2_init: ID[5] = 0xFF
    bfpga2_init: found IDPROM
    bfpga2_init: PCF reads 0xEF
    bfpga2_init: opened spi device /dev/spidev2.0
    bfpga2_init: Set SPI clock to 48000000 Hz
    bfpga2_init: Set SPI mode
    bfpga2_init: OMAP Drives SPI bus
    Configuring FPGA...
    bfpga_open_bitfile: found bitstream file testfile_la.bit
    bfpga_open_bitfile: parsing header
    bfpga_open_bitfile: found header
    bfpga_open_bitfile: chunk a length 25 filename la.ncd;UserID=0xFFFFFFFF
    bfpga_open_bitfile: chunk b length 12 device 3s500epq208
    bfpga_open_bitfile: Device != 3s500e
    bfpga_open_bitfile: chunk c length 11 date 2018/04/10
    bfpga_open_bitfile: chunk d length 9 time 20:18:24
    bfpga_open_bitfile: config size = 283776
    bfpga2_cfg: found bitfile testfile_la.bit
    bfpga2_cfg: Setting OMAP -> FPGA cfg
    bfpga2_cfg: PROG low, Waiting for INIT low
    
    
    ------
    In order to have the FPGA to self-load its program at power up, we have to store it inside M25P40 non volatile memory :

    root@am57xx-evm:~# ./bfpga2tool -v -p testfile_la.bit 
    bfpga2_init: opened I2C device /dev/i2c-3
    bfpga2_init: ID[0] = 0xFF
    bfpga2_init: ID[1] = 0xFF
    bfpga2_init: ID[2] = 0xFF
    bfpga2_init: ID[3] = 0xFF
    bfpga2_init: ID[4] = 0xFF
    bfpga2_init: ID[5] = 0xFF
    bfpga2_init: found IDPROM
    bfpga2_init: PCF reads 0xEF
    bfpga2_init: opened spi device /dev/spidev2.0
    bfpga2_init: Set SPI clock to 48000000 Hz
    bfpga2_init: Set SPI mode
    bfpga2_init: OMAP Drives SPI bus
    Programming SPI Cfg Flash...
    bfpga2_pgm: Read Flash ID:
    MFG ID: 0x00
    DEV ID: 0x00 0x00
    bfpga2_pgm: found Flash ID
    bfpga_open_bitfile: found bitstream file testfile_la.bit
    bfpga_open_bitfile: parsing header
    bfpga_open_bitfile: found header
    bfpga_open_bitfile: chunk a length 25 filename la.ncd;UserID=0xFFFFFFFF
    bfpga_open_bitfile: chunk b length 12 device 3s500epq208
    bfpga_open_bitfile: Device != 3s500e
    bfpga_open_bitfile: chunk c length 11 date 2018/04/10
    bfpga_open_bitfile: chunk d length 9 time 20:18:24
    bfpga_open_bitfile: config size = 283776
    bfpga2_pgm: found bitfile testfile_la.bit
    bfpga2_pgm: Sending WREN
    bfpga2_pgm: Sending Bulk Erase
    bfpga2_pgm: Bulk Erase complete (1 checks)
    bfpga2_pgm: Sending PP
    .....................................................bfpga2_pgm: Programmed 283776 bytes 
    bfpga2_init: OMAP off SPI bus

