 
 I personnaly recommand this version of kernel https://github.com/RobertCNelson/ti-linux-kernel-dev/tree/ti-linux-4.9.y
 
 	to build the kernel :
 	$ ./build_kernel.sh
	
 Then, boot to Beagleboard-x15, inside of your target, dump the device tree

	$ dtc -I fs /proc/device-tree > mydt4988.txt
	    check all aliases in device tree showed in mydt4988.txt, especially uart, i2c, mcspi

Now go to your kernel directory in $TISDK/build/arago-tmp-external-linaro-toolchain/work/am57xx_evm-linux-gnueabi/linux-ti-staging/4.9.69+gitAUTOINC+a75d8e9305-r7a.arago5.tisdk16/build, find dts files in arch/arm/boot/dts/
we are going to change dts file to have BeagleSDR loaded with correct configurations.

in am57xx-beagle-x15-revc.dts, add following devices:

	&i2c4 {
		status = "okay";
		clock-frequency = <400000>;
	};

	&uart8 {
		status = "okay";
	};

	&uart9 {
		status = "okay";
	};

	&mcspi3 { 
	       status = "okay";
	       pinctrl-names = "default";
	       pinctrl-0 = <&mcspi3_pins>;
	       spidev@3 { 
		      spi-max-frequency = <48000000>;
		      reg = <0>; 
		      compatible = "rohm,dh2228fv";
	       };
	};

	&mcspi4 { 
	       status = "okay";
	       pinctrl-names = "default";
	       pinctrl-0 = <&mcspi4_pins>;
	       spidev@4 { 
		      spi-max-frequency = <48000000>;
		      reg = <0>; 
		      compatible = "rohm,dh2228fv";
	       };
	};

------

according to am5728.pdf (page 105,106), in linux kernel dts dra74x-mmc-iodelay.dtsi, change SPI pin mux configuration


	&dra7_pmx_core {

	mcspi3_pins: mcspi3_pins {
		     pinctrl-single,pins = <
		               DRA7XX_CORE_IOPAD(0x1780, PIN_INPUT_PULLUP | MUX_MODE1) /*mmc3_cmd.spi3_clk*/
		               DRA7XX_CORE_IOPAD(0x1784, PIN_INPUT_PULLUP | MUX_MODE1) /*mmc3_dat0.spi3_d1*/
		               DRA7XX_CORE_IOPAD(0x1788, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat1.spi3_d0*/
		               DRA7XX_CORE_IOPAD(0x178C, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat2.spi3_cs0*/
		>;
	};

	mcspi4_pins: mcspi4_pins {
		     pinctrl-single,pins = <
		               DRA7XX_CORE_IOPAD(0x1794, PIN_INPUT_PULLUP | MUX_MODE1) /*mmc3_dat4.spi4_clk*/
		               DRA7XX_CORE_IOPAD(0x1798, PIN_INPUT_PULLUP | MUX_MODE1) /*mmc3_dat5.spi4_d1*/
		               DRA7XX_CORE_IOPAD(0x179C, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat6.spi4_d0*/
		               DRA7XX_CORE_IOPAD(0x17A0, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat7.spi4_cs0*/
		>;
	};

------

Now go to your beagleboard-x15 kernel source directory and enable SPIDEV in your kernel :

	$ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make menuconfig 
	$ grep SPIDEV .config
	CONFIG_SPI_SPIDEV=y

recompile your kernel with option CONFIG_SPI_SPIDEV :

	$ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make

load the zImage and dtb file into /tftpboot (assume you are using tftpboot + nfs)

	$ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make dtbs
	$ cp arch/arm/boot/dts/am57xx-beagle-x15-revc.dtb /tftpboot/uImage-am57xx-beagle-x15-revc.dtb
	$ cp arch/arm/boot/zImage /tftpboot

------
after 15 seconds of reboot, now you have to do a check in target :
	
	In target :
	$ ls /sys/devices/platform/44000000.ocp
	drwxr-xr-x    4 root     root             0 Apr  1 11:23 4807a000.i2c    ** i2c4 = "/ocp/i2c@4807a000";
	drwxr-xr-x    4 root     root             0 Apr  1 11:23 480b8000.spi    ** mcspi3 = "/ocp/spi@480b8000";
	drwxr-xr-x    4 root     root             0 Apr  1 11:23 480ba000.spi    ** mcspi4 = "/ocp/spi@480ba000";
	drwxr-xr-x    4 root     root             0 Apr  1 11:23 48422000.serial ** uart8 = "/ocp/serial@48422000";
	drwxr-xr-x    4 root     root             0 Apr  1 11:23 48424000.serial ** uart9 = "/ocp/serial@48424000";

	$ cat /proc/devices    
	Character devices:
	  4 ttyS
	 89 i2c
	153 spi
	...

	root@am57xx-evm:~# dmesg | grep i2c
	[    0.939269] omap_i2c 48070000.i2c: bus 0 rev0.12 at 400 kHz
	[    0.939868] omap_i2c 48060000.i2c: bus 2 rev0.12 at 400 kHz
	[    0.940289] omap_i2c 4807a000.i2c: bus 3 rev0.12 at 400 kHz

	root@am57xx-evm:~# dmesg | grep serial
	[    2.108010] 48020000.serial: ttyS2 at MMIO 0x48020000 (irq = 301, base_baud = 3000000) is a 8250
	[    3.224910] 48422000.serial: ttyS0 at MMIO 0x48422000 (irq = 302, base_baud = 3000000) is a 8250 <-- this is UART8
	[    3.234412] 48424000.serial: ttyS1 at MMIO 0x48424000 (irq = 303, base_baud = 3000000) is a 8250 <-- this is UART9

	root@am57xx-evm:~# dmesg | grep spi
	[    3.412919] pinctrl-single 4a003400.pinmux: could not add functions for mcspi3_pins 4294954880x  ** SPI3
	[    3.430787] pinctrl-single 4a003400.pinmux: could not add functions for mcspi4_pins 4294954900x  ** SPI4

	root@am57xx-evm:~# ll /dev/i2c* 
	crw-------    1 root     root       89,   0 Apr  1 12:55 /dev/i2c-0
	crw-------    1 root     root       89,   2 Apr  1 12:55 /dev/i2c-2
	crw-------    1 root     root       89,   3 Apr  1 12:55 /dev/i2c-3   ** this is i2c4

	root@am57xx-evm:~# ll /dev/ttyS*
	crw-rw----    1 root     dialout     4,  64 Apr  1 12:55 /dev/ttyS0   ** this is uart8
	crw-rw----    1 root     dialout     4,  65 Apr  1 12:55 /dev/ttyS1   ** this is uart9
	crw-------    1 root     tty         4,  66 Apr  1 13:14 /dev/ttyS2


	root@am57xx-evm:~# ll /dev/spi*
	crw-------    1 root     root      153,   0 Apr  1 12:55 /dev/spidev1.0   ** this is SPI3
	crw-------    1 root     root      153,   1 Apr  1 12:55 /dev/spidev2.0   ** this is SPI4

	in case you'd like to add permissions :
	chmod a+rw /dev/ttyS*
	chmod a+rw /dev/i2c*
	chmod a+rw /dev/spi*


	root@am57xx-evm:~# i2cdetect -y -r 3
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

according to spi :
http://e2e.ti.com/support/arm/sitara_arm/f/791/t/496527
https://elinux.org/BeagleBone_Black_Enable_SPIDEV
https://elinux.org/BeagleBoard/SPI
