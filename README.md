

# Welcome to the github of the BeagleSDR add-on board for the famous beagleboard-x15

## ALL yocto arago project ipk packages sources for beagleboard-x15 based on processor-sdk-xx.xx.xx.xx-config
        in PC :
	$ ./oe-layertool-setup.sh -f configs/processor-sdk/processor-sdk-04.03.00.05-config.txt
	$ cd build
	$ . conf/setenv
	
## GET the cross compiler 
	$ wget https://releases.linaro.org/components/toolchain/binaries/6.2-2016.11/arm-linux-gnueabihf/gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf.tar.xz
	$ tar -Jxvf gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf.tar.xz -C $HOME
--------
	$ export PATH=$HOME/gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf/bin:$PATH
	$ MACHINE=am57xx-evm  bitbake arago-core-tisdk-image
	$ MACHINE=am57xx-evm  bitbake netcat

--------
## SETUP the environment
	in PC :
 	install lighttpd server as an open embedded ipk packages server with
        all yocto arago packages found inside tisdk/build/arago-tmp-external-linaro-toolchain/deploy/ipk

	in Target :
 	add local LAN network the http server links in
 	$ vi /etc/opkg/base-feeds.conf
        add these 2 lines
  	src/gz armv7ahf-neon http://.../armv7ahf-neon
  	src/gz am57xx_evm http://.../am57xx_evm

------

	in PC :
	MACHINE=am57xx-evm bitbake netcat
	install the netcat package in the target (copy to the target the ipk packages through NFS or microSD) 
        and do a test of file transfer between 2 linux hosts
	$ opkg install netcat_0.7.1-r3_armv7ahf-neon.ipk
	$ echo "abc123" | nc 192.168.1.16 6600

	in Target :
	$ opkg install netcat..ipk
	$ netcat -l -p 6600 > test_nc.txt

------

## CHECK Linux kernel

	in Target :
	$ ls -l /dev/i2c*
	$ ls -l /dev/spi*
	if files are not present in /dev, it means you have to download required kernel patches and dtb file to enable I2C and SPI. Please contact kernel hackers to achieve the kernel adaptation.
	

## SPI 

	SPI had been specified as working at 48 Mhz.
	Enabling spidev and the pin muxing in the kernel and dtb

	In order to test SPI port, one has to strap MOSI and MISO wires
	Using an oscilloscope, check the frequencies at 20 Mhz and the maximal frequency at 48 Mhz too
	in Target :
	$ ./spitest -D /dev/spidev4.0 -s 20000000
	$ ./spitest -D /dev/spidev4.0 -s 48000000
	
	check the message has been looped back

------

## I2C

	I2C4 of the Beagleboard-X15 is connected to BeagleSDR. We then assume using /dev/i2c4
	try to detect devices on I2C4 bus
	in Target :
	$ i2cdetect -y 4

## EEPROM 24Cxx / I2C
	in Target :
	We assume the EEPROM address is 0x50

	$ i2cget -y 4 0x50 0x0 

	set fpga id :
	$ i2cset -y 4 0x50 0x0 0
	$ i2cset -y 4 0x50 0x1 0x6
	$ i2cset -y 4 0x50 0x2 0
	$ i2cset -y 4 0x50 0x3 0x1
	$ i2cset -y 4 0x50 0x4 0
	$ i2cset -y 4 0x50 0x5 0

	at offset 0x0 write byte 0:
	$ i2cset -y 4 0x50 0x0 0

	at offset 0x10 write byte 0:
	$ i2cset -y 4 0x50 0x10 0

	at offset 0x1 write word 0:
	$ i2cset -y 4 0x50 0x1 0000 w

	read eeprom entire page 128 bytes :
	$ i2cdump -y 4 0x50
	
	read eeprom to eeprom.dat:
	$ eeprom -d /dev/i2c-4 -f eeprom.dat

	write eeprom.dat to eeprom:
	$ eeprom -d /dev/i2c-4 -f eeprom.dat -w

	if write failed, check if the EEPROM WR jumper JP101 is connected = Write enable ?
	if failed again, check eeprom reference datasheet vcc, is it working at 3.3v or 1.8v ?
	if failed again, check if 1.8v is correct ?


------

## PCF8574_TS Expander / I2C
	in Target :
	check PCF8574_TS4 P0 = 1, all other ports = 0 :
	$ i2cset -y 4 0x20 1

	check PCF8574_TS4 P1 = 1, all other ports = 0 :
	$ i2cset -y 4 0x20 2

	check PCF8574_TS4 P1, P2 = 1, all other ports = 0 :
	$ i2cset -y 4 0x20 6

------

## LTC 6904 / I2C

	Have an oscilloscope and solder wire to the clock pin according to the LTC 6904 datasheet
	in Target :
	$ i2cset -y 4 0x17 0x0
	1 khz = per 1ms

	$ i2cset -y 4 0x17 0x20
	10 khz = per 1ms

	$ i2cset -y 4 0x17 0x50
	33 khz = per 30 us

	$ i2cset -y 4 0x17 0x80
	260 khz = per 3.8 us

	$ i2cset -y 4 0x17 0xA0
	1 Mhz  = 1 us

	$ i2cset -y 4 0x17 0xB0
	2 Mhz  = 0.5 us

	$ i2cset -y 4 0x17 0xC0
	4.16 Mhz  = 240 ns

	$ i2cset -y 4 0x17 0xD0
	10 Mhz  = 120 ns

	$ i2cset -y 4 0x17 0xff
	50 Mhz = per 20 ns

------

## UART

	in order to test UART, strap RX and TX wires and use an oscilloscope to check.
	Then, have a picocom to have a loopback test 

------

	Great, all checks had been tested, if no error, you are ready to program the AVR and the FPGA. 
	Now, go to sub-directory to follow further steps.
