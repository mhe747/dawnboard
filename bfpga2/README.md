
# bfpga2

## User
Using bfpga2, one can push a bitfile from Beagleboard-x15 to the BeagleSDR in order to reprogram the FPGA by downloading FPGA configuration bitfile through the SPI Flash memory. One should have control of the programmable clock oscillator and therefore one should test the SPI control port before. The access library provides a low-level API for control of the I2C and SPI ports, as well as higher level functions for bitstream download and may be used to construct complex user-space applications for interaction with the FPGA design. Full sources are available here, forked from initial repository git://gitorious.org/bfpga_lib/bfpga2_lib.git
however the newest updated Kernel is needed. MLO, U-boot and Linux Kernel driver with pin muxing support including I2C and SPI are required.

## FPGA Design
Synthesizing an FPGA design requires the Xilinx ISE 14.7 which is free downloadable from the Xilinx website.
This suite of tools includes IMPACT the bitfile download tool through JTAG without Beagleboard-x15, as well as command-line applications that can be run under both Linux and Windows. Designs can be created with either Verilog or VHDL, or Xilinx Schematics.

------

To adapt the I2C mapping, change the file bfpga2_lib.c :

    #define I2C_ADDR_EXPANDER 0x20
    #define I2C_ADDR_LTC 0x17
    #define I2C_ADDR_EEPROM 0x50
    #define PROG_FREQ 48000000
    #define MAX_DUMMY_CLOCK 10000000

------
To program the FPGA, one has to do :

    $ ./bfpga2tool -v flash_prog.bit
    bfpga2_init: opened I2C device /dev/i2c-4
    bfpga2_init: ID[0] = 0x00
    bfpga2_init: ID[1] = 0x00
    bfpga2_init: ID[2] = 0x00
    bfpga2_init: ID[3] = 0x00
    bfpga2_init: ID[4] = 0xFF
    bfpga2_init: ID[5] = 0xFFFFFFFF
    bfpga2_init: found IDPROM
    bfpga2_init: PCF reads 0x3F
    bfpga2_init: opened spi device /dev/spidev4.0
    bfpga2_init: Set SPI clock to 48000000 Hz
    bfpga2_init: Set SPI mode
    bfpga2_init: FPGA not already configured - DONE not high
    bfpga2_init: OMAP Drives SPI bus
    Configuring FPGA...
    bfpga_open_bitfile: found bitstream file flash_prog.bit
    bfpga_open_bitfile: parsing header
    bfpga_open_bitfile: found header
    bfpga_open_bitfile: chunk a length 33 filename flash_prog.ncd;UserID=0xFFFFFFFF
    bfpga_open_bitfile: chunk b length 12 device 3s500e
    bfpga_open_bitfile: Device == 3s500e
    bfpga_open_bitfile: chunk c length 11 date 2018/02/21
    bfpga_open_bitfile: chunk d length 9 time 17:55:20
    bfpga_open_bitfile: config size = xxxxxx
    bfpga2_cfg: found bitfile flash_prog.bit
    bfpga2_cfg: Setting OMAP -> FPGA cfg
    bfpga2_cfg: PROG low, Waiting for INIT low
    bfpga2_cfg: PROG high, Waiting for INIT high
    bfpga2_cfg: Sending bitstream
    ...................................................................................
    bfpga2_cfg: sent xxxxxx of xxxxxx bytes
    bfpga2_cfg: bitstream sent, closing file
    bfpga2_cfg: sending dummy clocks, waiting for DONE or fail
    bfpga2_cfg: 0 dummy clocks sent
    bfpga2_cfg: Setting FLASH -> FPGA cfg
    bfpga2_cfg: success
    bfpga2_init: OMAP off SPI bus
    
------
In order to have the FPGA to self-load its program at power up, we have to store it inside M25P40 non volatile memory :

    $ ./bfpga2tool -v -p test.bit
    bfpga2_init: opened I2C device /dev/i2c-4
    bfpga2_init: ID[0] = 0x00
    bfpga2_init: ID[1] = 0x00
    bfpga2_init: ID[2] = 0x00
    bfpga2_init: ID[3] = 0x00
    bfpga2_init: ID[4] = 0xFF
    bfpga2_init: ID[5] = 0xFFFFFFFF
    bfpga2_init: found IDPROM
    bfpga2_init: PCF reads 0xFF
    bfpga2_init: opened spi device /dev/spidev4.0
    bfpga2_init: Set SPI clock to 48000000 Hz
    bfpga2_init: Set SPI mode
    bfpga2_init: OMAP Drives SPI bus
    Programming SPI Cfg Flash...
    bfpga2_pgm: Read Flash ID:
    MFG ID: 0xWW
    DEV ID: 0xWW 0xYY
    bfpga2_pgm: found Flash ID
    bfpga_open_bitfile: found bitstream file test.bit
    bfpga_open_bitfile: parsing header
    bfpga_open_bitfile: found header
    bfpga_open_bitfile: chunk a length 27 filename test.ncd;UserID=0xFFFFFFFF
    bfpga_open_bitfile: chunk b length 12 device 3s500e
    bfpga_open_bitfile: Device == 3s500e
    bfpga_open_bitfile: chunk c length 11 date 2018/02/20
    bfpga_open_bitfile: chunk d length 9 time 16:55:35
    bfpga_open_bitfile: config size = 149516
    bfpga2_pgm: found bitfile test.bit
    bfpga2_pgm: Sending WREN
    bfpga2_pgm: Sending Bulk Erase
    bfpga2_pgm: Bulk Erase complete (6214 checks)
    bfpga2_pgm: Sending PP
    ........................................................................
    bfpga2_pgm: Programmed xxxxxx bytes
    bfpga2_init: OMAP off SPI bus

