
# Welcome to the github of the BeagleSDR add-on board for the famous beagleboard-x15

## AVR / FPGA / ADC / DAC / C2VERILOG   --   ALL IN ONE

	Setup the standard ARM Cross-compiler Toolchain, since one may find some GCC7 compiler's issue with processor-sdk, I advise to use the version 6.4. ALL yocto arago project ipk packages sources for beagleboard-x15 based on processor-sdk-xx.xx.xx.xx-config
	$ wget https://releases.linaro.org/components/toolchain/binaries/6.4-2017.08/arm-linux-gnueabihf/gcc-linaro-6.4.1-2017.08-x86_64_arm-linux-gnueabihf.tar.xz
	$ tar -Jxvf gcc-linaro-6.4.1-2017.08-x86_64_arm-linux-gnueabihf.tar.xz -C $HOME
	$ nano ~/.bashrc
	add this line into .bashrc 
	export PATH=$PATH:~/gcc-linaro-6.4.1-2017.08-x86_64_arm-linux-gnueabihf/bin

	After setting the cross-compiler in your environment PATH, now have a check with
	$ . ~/.bashrc
	$ which arm-linux-gnueabihf-gcc

-------
Now we go through bitbaking some Beagleboard-x15 core packages...

	$ cd $TISDK/build/
	$ . conf/setenv
	$ MACHINE=am57xx-evm bitbake arago-core-tisdk-image
	$ MACHINE=am57xx-evm bitbake netcat
	$ MACHINE=am57xx-evm bitbake picocom
	$ MACHINE=am57xx-evm bitbake spitools
	$ MACHINE=am57xx-evm bitbake i2c-tools	
	$ MACHINE=am57xx-evm bitbake python-pyserial	
	
	Check package version and after re-generation, build the new package index in repository : 
	$ MACHINE=am57xx-evm bitbake -s
	$ MACHINE=am57xx-evm bitbake package-index 

	Ref. 	https://www.openembedded.org/wiki/Bitbake_cheat_sheet 
		http://wiki.kaeilos.com/index.php/Bitbake_options

--------
## SETUP the environment

	in PC :
 	install lighttpd server as an open embedded ipk packages server with Ubuntu
	$ sudo apt-get install lighttpd
        all yocto arago packages found inside $TISDK/build/arago-tmp-external-linaro-toolchain/deploy/ipk
	
	this is how I configured my lighttpd server :
	add these following lines in $TISDK/build/arago-tmp-external-linaro-toolchain/deploy/lighttpd.conf
	in lighttpd.conf, maybe it has to use absolute path, so just replace $TISDK with right path
	be sure the port 8000 is available too.
	------

	server.document-root = "$TISDK/build/arago-tmp-external-linaro-toolchain/deploy/"

	server.port = 8000

	server.username = "www-data"
	server.groupname = "www-data"

	mimetype.assign = (
	  ".html" => "text/html",
	  ".txt" => "text/plain",
	  ".jpg" => "image/jpeg",
	  ".png" => "image/png"
	)

	$HTTP["url"] =~ "^/ipk" {
	    dir-listing.activate = "enable"
	}

	static-file.exclude-extensions = ( ".fcgi", ".php", ".rb", "~", ".inc" )
	index-file.names = ( "index.html" )

	------

	start the http server with this command in your PC server :
	$ lighttpd -D -f $TISDK/build/arago-tmp-external-linaro-toolchain/deploy/lighttpd.conf
	then, assuming server ip at 192.168.1.17 check to browse the server address 
	homepage http://192.168.1.17:8000/ipk/

	you should see something like : 

	Index of /ipk/
	Name	        Last Modified	    Size	
	all/	        2018-Apr-07 23:26:36  -
	am57xx_evm/	2018-Apr-08 00:18:40  -
	armv7ahf-neon/	2018-Apr-13 22:16:16  -
	x86_64-nativesdk/ 2018-Apr-07 23:26:37 -
	Packages	2018-Apr-01 22:05:36  0.0K


	in Target :
 	add into beagleboard-x15 open embedded packages manager's configuration file 
	the remote LAN http server links at address of 192.168.1.17:8000/ipk

	$ vi /etc/opkg/base-feeds.conf
	src/gz all http://192.168.1.17:8000/ipk/all
	src/gz am57xx_evm http://192.168.1.17:8000/ipk/am57xx_evm
	src/gz armv7ahf-neon http://192.168.1.17:8000/ipk/armv7ahf-neon

	$ opkg update
	Downloading http://192.168.1.17:8000/ipk/all/Packages.gz.
	Updated source 'all'.
	Downloading http://192.168.1.17:8000/ipk/am57xx_evm/Packages.gz.
	Updated source 'am57xx_evm'.
	Downloading http://192.168.1.17:8000/ipk/armv7ahf-neon/Packages.gz.
	Updated source 'armv7ahf-neon'.

------

	in PC, build the netcat package for your remote target :
	$ MACHINE=am57xx-evm bitbake netcat	
	install the netcat package into the target (copy to the target ipk package through NFS or microSD) 
        
	Now do a test of file transfer over LAN between your PC and Beagleboard-x15
	
	in Target :
	$ opkg install netcat_0.7.1-r3_armv7ahf-neon.ipk
	    or
	$ opkg install netcat
	Target should at first wait for incoming connection
	$ netcat -l -p 6600 > test_nc.txt

	in PC :
	$ echo "abc123" | nc 192.168.1.16 6600


------

## CHECK Linux kernel

	in Target :
	check devices files in /dev
	$ ls -l /dev/i2c*
	$ ls -l /dev/spi*
	$ ls -l /dev/ttyS*
	if files are not present in /dev, it means you have to download required kernel patches and dtb file
	to enable I2C and SPI,  UART... Read following page : 
	BeagleSDR_KernelHack.md (https://github.com/mhe747/dawnboard/blob/master/BeagleSDR_KernelHack.md) 
	to enable i2c, spi, uart and the pin muxing in the kernel and dtb file.
	
------

## SPI 

	You may experience here issue due to kernel conflicts with MMC3. 
	This point is under investigation by Beagleboard-x15 engineers.
	
	in Target :
	$ opkg install spitools
	
	SPI had been specified as working at 48 Mhz. 

	In order to test SPI port, one can use an oscilloscope, check the frequencies of SPI_CLK at 20 Mhz 
	and its maximal frequency at 48 Mhz too.
	
	in Target :
	$ ./spidev_test -D /dev/spidev2.0 -s 20000000
	$ ./spidev_test -D /dev/spidev2.0 -s 48000000
	

------

## I2C
	
	in Target :
	$ opkg install i2c-tools

	I2C had been specified as working at 400 khz.
	
	I2C4 of the Beagleboard-X15 is connected to BeagleSDR. We then assume using i2c4, which in Linux is /dev/i2c-3
	We try to detect all connected devices on I2C4 bus.
	
	in Target :
	$ i2cdetect -y -r 3
	
	     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
	00:          -- -- -- -- -- -- -- -- -- -- -- -- --
	10: -- -- -- -- -- -- -- 17 -- -- -- -- -- -- -- --
	20: 20 -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	50: 50 -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	70: -- -- -- -- -- -- -- --

------	

## EEPROM 24Cxx / I2C

	in Target :
	There ATMEL AT24C08AN-10SU-1.8 or AT24C64DH are installed in BeagleSDR.
	We assume the EEPROM address being 0x50.	
	You may experience here some issue due to Kernel conflicts or voltage inference. 
	This point is under investigation by Beagleboard-x15 engineers.
	
	$ i2cget -y 3 0x50 0x0 

	set fpga id :
	$ i2cset -y 3 0x50 0x0 0
	$ i2cset -y 3 0x50 0x1 0x6
	$ i2cset -y 3 0x50 0x2 0
	$ i2cset -y 3 0x50 0x3 0x1
	$ i2cset -y 3 0x50 0x4 0
	$ i2cset -y 3 0x50 0x5 0

	at offset 0x0 write byte 0:
	$ i2cset -y 3 0x50 0x0 0

	at offset 0x10 write byte 0:
	$ i2cset -y 3 0x50 0x10 0

	at offset 0x1 write word 0:
	$ i2cset -y 3 0x50 0x1 0000 w

	read eeprom entire page 128 bytes :
	$ i2cdump -y 3 0x50
	
	read eeprom to eeprom.dat:
	$ eeprom -d /dev/i2c-3 -f eeprom.dat

	write eeprom.dat to eeprom:
	$ eeprom -d /dev/i2c-3 -f eeprom.dat -w

	if write failed, check if the EEPROM WR jumper JP101 is connected = Write enable ?
	if failed again, check eeprom reference datasheet vcc, is it working at 3.3v or 1.8v ?
	if failed again, check if 1.8v is correct ?


------

## PCF8574_TS Expander / I2C   - Tested, working

	in Target :
	We assume the PCF8574_TS Expander i2c address is 0x20.
	
	check PCF8574_TS4 P0 = 1, all other ports = 0 :
	$ i2cset -y 3 0x20 1

	check PCF8574_TS4 P1 = 1, all other ports = 0 :
	$ i2cset -y 3 0x20 2

	check PCF8574_TS4 P1, P2 = 1, all other ports = 0 :
	$ i2cset -y 3 0x20 6

------

## LTC 6904 / I2C   - Tested, working

	Have an oscilloscope and solder probe wire to the clock pin according to the LTC 6904 datasheet.
	in Target :
	We assume the LTC 6904 prog. osc. i2c address is 0x17.
	
	$ i2cset -y 3 0x17 0x0
	1 khz = per 1ms

	$ i2cset -y 3 0x17 0x20
	10 khz = per 100 us

	$ i2cset -y 3 0x17 0x50
	33 khz = per 30 us

	$ i2cset -y 3 0x17 0x80
	260 khz = per 3.8 us

	$ i2cset -y 3 0x17 0xA0
	1 Mhz  = 1 us

	$ i2cset -y 3 0x17 0xB0
	2 Mhz  = 0.5 us

	$ i2cset -y 3 0x17 0xC0
	4.16 Mhz  = 240 ns

	$ i2cset -y 3 0x17 0xD0
	10 Mhz  = 120 ns

	$ i2cset -y 3 0x17 0xff
	50 Mhz = per 20 ns
	
------

## UART 8,9   - Tested, working

	In order to test UART, check RX and TX by using an oscilloscope to check if something toggling. 
	UART had been specified as working at 115200 baud, or maybe at faster speed.
	
	Beagleboard-x15's UART8 should be exclusively reserved to AVR. However it is connected from Beagleboard-x15 
	to both devices (FPGA and AVR) and can be used as GPIO purpose in case of UART8 disabled.
		UART8_TX <=> FPGA_LVS_D <=> AVR_PD0
		UART8_RX <=> FPGA_LVS_E <=> AVR_PD1 
		
	Beagleboard-x15's UART9 is exclusively reserved to FPGA. No other purpose.
		FPGA_BEAGLE_UART_RX = UART9_TXD
		FPGA_BEAGLE_UART_TX = UART9_RXD


	Beagleboard-x15 talks to BeagleSDR's AVR through UART8,
	Arduino sketches can also be uploaded using avrdude :
	
	$ avrdude -V -F -c usbasp -p m328 -P /dev/ttyS8 -b 57600 -U flash:w:Arduino.hex

	avrdude: warning: cannot set sck period. please check for usbasp firmware update.
	avrdude: AVR device initialized and ready to accept instructions

	Reading | ################################################## | 100% 0.00s

	avrdude: Device signature = 0x1e9514

------

	Beagleboard-x15 talks to BeagleSDR's FPGA through UART9, 
	here is a simple UART loopback test :
	
	root@am57xx-evm:~# picocom -b 115200 -f n -d 8 -p n /dev/ttyS8
	picocom v1.7

	port is        : /dev/ttyS8
	flowcontrol    : none
	baudrate is    : 115200
	parity is      : none
	databits are   : 8
	escape is      : C-a
	local echo is  : no
	noinit is      : no
	noreset is     : no
	nolock is      : no
	send_cmd is    : sz -vv
	receive_cmd is : rz -vv
	imap is        : 
	omap is        : 
	emap is        : crcrlf,delbs,

	Terminal ready
	aaaaaaaaaaaaaaaaaaa
	
------

## GPIO - Tested, working

	In Target, try to select GPIO connected from Beagleboard-x15 to BeagleSDR :
	$ cd /sys/class/gpio
	$ echo 166 > export
	$ cd gpio166
	$ echo out > direction
	$ cat value
	$ echo 1 > value
	$ cat value

	in BeagleSDR fpga configuration file .ucf add these lines :
	NET "FPGA_BEAGLE<0>"  LOC = "P89"; # x15's pin 166 = P17.p45
	NET "FPGA_BEAGLE<1>"  LOC = "P90"; # x15's pin 164 = P17.p47
	NET "FPGA_BEAGLE<2>"  LOC = "P93"; # x15's pin 231 = P17.p51
	NET "FPGA_BEAGLE<3>"  LOC = "P94"; # x15's pin 168 = P17.p55
	NET "FPGA_BEAGLE<4>"  LOC = "P96"; # x15's pin 210 = P17.p58
	NET "FPGA_BEAGLE<5>"  LOC = "P48"; # x15's pin 211 = P17.p28
	NET "FPGA_BEAGLE<6>"  LOC = "P36"; # x15's pin 208 = P17.p12
	NET "FPGA_BEAGLE<7>"  LOC = "P41"; # x15's pin 165 = P17.p17
	NET "FPGA_BEAGLE<8>"  LOC = "P40"; # x15's pin 167 = P17.p15
	NET "FPGA_BEAGLE<9>"  LOC = "P47"; # x15's pin 169 = P17.p25
	NET "FPGA_BEAGLE<10>"  LOC = "P69"; # x15's pin 222 = P17.p4
	NET "FPGA_BEAGLE<11>"  LOC = "P74"; # x15's pin 225 = P17.p8

	in C, add these lines :
	/* array of 12 pins IO vectors */
	int pin_array[] = 
	{
	166,164,231,168,210,211,208,165,167,169,222,225
	};

------

	Great, all checks had been tested, if no error, you now are ready to make a complex project with the 
	power of the BeagleSDR, like https://github.com/mhe747/sumpx15
	
	Just Now please go to sub-directory avr, bfpga2, chips-beaglesdr to read more about it.
