# I personnaly recommand using Linux Kernel am57xx-evm 4.* in processor-sdk
 
	Setup the standard ARM Cross-compiler Toolchain / which maybe different from the cross-compiler used to make userland's packages
	$ wget https://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/arm-linux-gnueabihf/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.xz
	$ tar -Jxvf gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.xz -C $HOME
	$ nano ~/.bashrc
	add this line into .bashrc 
	export PATH=$PATH:~/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin

	After setting the cross-compiler in your environment PATH, now have a check with
	$ . ~/.bashrc
	$ which arm-linux-gnueabihf-gcc
	  *** bash should say something like
	  /home/osboxes/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc

	Fetch git repo in TI
	$ git clone git://arago-project.org/git/projects/oe-layersetup.git tisdk
	$ cd tisdk
	$ export TISDK=`pwd`
	$ ls $TISDK/configs/processor-sdk/processor-sdk-04.03.00.05-config.txt
	  *** this file must exist because we will need to import the bitbake's layers.

	Now optimization, change $TISDK/build/conf/local.conf to set the number of your CPU cores
	PARALLEL_MAKE = "-j XX"  (eg. XX=8)

	$ ./oe-layertool-setup.sh -f configs/processor-sdk/processor-sdk-04.03.00.05-config.txt
	$ cd build
	$ . conf/setenv
	$ MACHINE=am57xx-evm bitbake arago-core-tisdk-image
	
	After several hours of compilation if errors occured you should manually fix them...
	
Check your kernel directory to find dts files in $TISDK/build/arago-tmp-external-linaro-toolchain/work/am57xx_evm-linux-gnueabi/linux-ti-staging/4.*/git/arch/arm/boot/dts/

These are dts files related to the Beagleboard-X15 revC :

	am57xx-beagle-x15-revc.dts 
	am57xx-beagle-x15-common.dtsi 
	dra74x.dtsi 
	am57xx-commercial-grade.dtsi 
	dra74x-mmc-iodelay.dtsi 
	dra7.dtsi
	dra7xx-clocks.dtsi

Only edit the file "am57xx-beagle-x15-revc.dts" which contains our custom configurations.

	gedit $TISDK/build/arago-tmp-external-linaro-toolchain/work/am57xx_evm-linux-gnueabi/linux-ti-staging/4.*/git/arch/arm/boot/dts/am57xx-beagle-x15-revc.dts

The original Linux Kernel sources can be found inside $TISDK/build/arago-tmp-external-linaro-toolchain/work-shared/am57xx-evm/kernel-sources or same as am57xx-evm/git

Now we are going to update the dts file to have BeagleSDR loaded with correct configurations.

in am57xx-beagle-x15-revc.dts, add following devices:

------

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

	&dra7_pmx_core {
		mcspi4_pins: mcspi4_pins {
			pinctrl-single,pins = <
			       DRA7XX_CORE_IOPAD(0x3794, PIN_INPUT_PULLUP  | MUX_MODE1) /*mmc3_dat4 spi4_clk*/
			       DRA7XX_CORE_IOPAD(0x3798, PIN_INPUT_PULLUP  | MUX_MODE1) /*mmc3_dat5 spi4_SOMI */
			       DRA7XX_CORE_IOPAD(0x379C, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat6 spi4_MOSI */
			       DRA7XX_CORE_IOPAD(0x37A0, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat7 spi4_cs0*/
			>;
		};
	};

	&mcspi4 { 
	       status = "okay";
	       pinctrl-names = "default";

	       spidev@1 { 
		      pinctrl-1 = <&mcspi4_pins>;
		      spi-max-frequency = <48000000>;
		      reg = <0>; 
		      compatible = "rohm,dh2228fv";
	       };
	};

------

according to am5728.pdf (page 105,106), in linux kernel dts 
you can change SPI pin mux configuration here dra74x-mmc-iodelay.dtsi

Ref.   https://groups.google.com/forum/#!topic/beagleboard-x15/OWHcEUoCzYo

	&dra7_pmx_core {

	/* This would configure the port P17, corresponding to the extension pins 17.4, 17.36, 17.7, 17.8 respectively as below 
	   but also may in same time create pertubations to i2c4 */ 
	//	mcspi3_pins: mcspi3_pins {
	//		     pinctrl-single,pins = <
	//		               DRA7XX_CORE_IOPAD(0x3780, PIN_INPUT_PULLUP  | MUX_MODE1) /*mmc3_cmd.spi3_clk*/
	//			       DRA7XX_CORE_IOPAD(0x3788, PIN_INPUT_PULLUP  | MUX_MODE1) /*mmc3_dat1 MCSPI3_SOMI */
	//		               DRA7XX_CORE_IOPAD(0x3784, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat0 MCSPI3_MOSI */
	//			       DRA7XX_CORE_IOPAD(0x378C, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat2.spi3_cs0*/
	//		>;
	//	};


	/*in case of configuration 1
	  This would configure the port P17, corresponding to the extension pins 
	17.37, 17.35, 17.38, 17.6 respectively as below */
	
	/* mcspi4_pins: mcspi4_pins {
		     pinctrl-single,pins = <
		               DRA7XX_CORE_IOPAD(0x3794, PIN_INPUT_PULLUP  | MUX_MODE1) /*mmc3_dat4 spi4_clk*/
		               DRA7XX_CORE_IOPAD(0x3798, PIN_INPUT_PULLUP  | MUX_MODE1) /*mmc3_dat5 spi4_SOMI */
		               DRA7XX_CORE_IOPAD(0x379C, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat6 spi4_MOSI */
		               DRA7XX_CORE_IOPAD(0x37A0, PIN_OUTPUT_PULLUP | MUX_MODE1) /*mmc3_dat7 spi4_cs0*/
		>;
	};*/
	
	/* in case of configuration 2
	   This would configure the port P17, corresponding to the extension pins 
	17.37, 17.35, 17.09, and 17.10 respectively as below */
	/*
	mcspi4_pins: mcspi4_pins {
	     pinctrl-single,pins = <
	        DRA7XX_CORE_IOPAD(0x3794, PIN_INPUT_PULLUP  | MUX_MODE1) /*mmc3_dat4 spi4_clk*/
	        DRA7XX_CORE_IOPAD(0x3798, PIN_INPUT_PULLUP  | MUX_MODE1) /*mmc3_dat5 spi4_SOMI */
		DRA7XX_CORE_IOPAD(0x374c, PIN_OUTPUT_PULLUP | MUX_MODE2) /* UART9.TX */
		DRA7XX_CORE_IOPAD(0x3750, PIN_OUTPUT_PULLUP | MUX_MODE2) /* UART9.RX */
		>;
	};*/

------

	$ cd ../../../..

	$ cd $TISDK/build/arago-tmp-external-linaro-toolchain/work/am57xx_evm-linux-gnueabi/linux-ti-staging/4.9.69+gitAUTOINC+a75d8e9305-r7a.arago5.tisdk16/build/

Now come back to your bitbake's TI kernel directory to check the settings of the kernel :

 	$ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j 32 menuconfig
	
	Compile the kernel again
	$ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j 32

	Compile the device tree blobs
	$ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- dtbs -j 32

	Compile the kernel modules
	$ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules -j 32

	Install TFTP and NFS in your local PC...
	$ sudo apt-get install tftpd nfsd
	
	Install compiled kernel and modules to your nfs root directory	
	$ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=$TARGET_NFS modules_install	
	$ cp arch/arm/boot/zImage /tftpboot/
	$ cp arch/arm/boot/dts/am57xx-beagle-x15-revc.dtb /tftpboot/uImage-am57xx-beagle-x15-revc.dtb
	
Change uEnv.txt to set dtb to uImage-am57xx-beagle-x15-revc.dtb
Then, boot to Beagleboard-x15, now you are inside of your target, dump the device tree

	$ uname -a
	Linux am57xx-evm 4.9.59-ga75d8e9305 #4 SMP PREEMPT Sat Apr 14 09:35:10 CEST 2018 armv7l GNU/Linux

	$ dtc -I fs /proc/device-tree > mykerneldt.txt
	
	check all aliases presence in device tree showed in mykerneldt.txt, especially uart, i2c, mcspi


Now go to your beagleboard-x15 kernel source directory and enable SPIDEV 
(to find out where it is, just type / SPIDEV in your kernel menuconfig) :

	$ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make menuconfig
	
	check SPIDEV if enabled
	$ grep SPIDEV .config
	CONFIG_SPI_SPIDEV=y

recompile your kernel with option CONFIG_SPI_SPIDEV :

	$ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make

load the zImage and dtb file into /tftpboot (assume you are using tftpboot + nfs)

	$ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make dtbs
	$ cp arch/arm/boot/dts/am57xx-beagle-x15-revc.dtb /tftpboot/uImage-am57xx-beagle-x15-revc.dtb
	$ cp arch/arm/boot/zImage /tftpboot

this is my personal uEnv.txt, simple yet powerful, only one line makes you from MLO to bash.

	# rename to /run/media/mmcblk0p1/uEnv.txt assumed that mount /dev/mmcblk0p1 on /run/media/mmcblk0p1 type vfat 
	uenvcmd=setenv autoload no;dhcp;setenv bootfile zImage;setenv fdtfile uImage-am57xx-beagle-x15-revc.dtb;setenv serverip 192.168.1.17;setenv netloadfdt tftp ${fdtaddr} ${serverip}:${fdtfile};setenv netloadimage tftp ${loadaddr} ${serverip}:${bootfile};setenv rootpath /home/osboxes/ti-processor-sdk-linux-am57xx-evm-04.03.00.05/targetNFS;run netloadimage;run netloadfdt;run netargs;bootz ${loadaddr} - ${fdtaddr};


------
after 15 seconds of reboot, now you have to do a check in target :

	Before plugging your BeagleSDR, it would be advisable to have a check each port with your osciloscope.
	Check the voltage, clock activites if that seems alright.
	
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
	[    0.940289] omap_i2c 4807a000.i2c: bus 3 rev0.12 at 400 kHz   ** this is i2c4

	root@am57xx-evm:~# dmesg | grep serial
	[    2.108010] 48020000.serial: ttyS2 at MMIO 0x48020000 (irq = 301, base_baud = 3000000) is a 8250
	[    3.224910] 48422000.serial: ttyS7 at MMIO 0x48422000 (irq = 302, base_baud = 3000000) is a 8250 <-- this is UART8
	[    3.234412] 48424000.serial: ttyS8 at MMIO 0x48424000 (irq = 303, base_baud = 3000000) is a 8250 <-- this is UART9

	if you enable both mcspi3 and mcspi4, you would see in log :
	root@am57xx-evm:~# dmesg | grep spi
	[    2.862171] omap2_mcspi 480b8000.spi: registered master spi1
	[    2.862407] spi spi1.0: setup: speed 48000000, sample leading edge, clk normal
	[    2.862419] spi spi1.0: setup mode 0, 8 bits/w, 48000000 Hz max --> 0
	[    2.862840] omap2_mcspi 480b8000.spi: registered child spi1.0
	[    2.863124] omap2_mcspi 480ba000.spi: registered master spi2
	[    2.863301] spi spi2.0: setup: speed 48000000, sample leading edge, clk normal
	[    2.863313] spi spi2.0: setup mode 0, 8 bits/w, 48000000 Hz max --> 0
	[    2.863705] omap2_mcspi 480ba000.spi: registered child spi2.0
	
	if you have some traces like :
	[    2.869937] pinctrl-single 4a003400.pinmux: could not add functions for mcspi4_pins 4294960020x
	
	that stands for pin muxing is not working in your linux kernel !


	root@am57xx-evm:~# ll /dev/i2c* 
	crw-------    1 root     root       89,   0 Apr  1 12:55 /dev/i2c-0
	crw-------    1 root     root       89,   2 Apr  1 12:55 /dev/i2c-2
	crw-------    1 root     root       89,   3 Apr  1 12:55 /dev/i2c-3   ** this is i2c4

	root@am57xx-evm:~# ll /dev/ttyS*
	crw-rw----    1 root     dialout     4,  71 Apr  1 09:47 /dev/ttyS7  ** uart8
	crw-rw----    1 root     dialout     4,  72 Apr  1 09:47 /dev/ttyS8  ** uart9


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
	
	root@am57xx-evm:~# ls -dl /sys/bus/i2c/devices/
	   i2c-3 -> ../../../devices/platform/44000000.ocp/4807a000.i2c/i2c-3

	root@am57xx-evm:/# ls /sys/devices/platform/44000000.ocp/480ba000.spi 
	driver           modalias         power            subsystem
	driver_override  of_node          spi_master       uevent

	One could read mcspi4 registers with devmem2:    
	root@am57xx-evm:~# devmem2 0x4A009808 
	/dev/mem opened. 
	Memory mapped at address 0xb6f8f000. 
	Read at address 0x4A009808 (0xb6f8f808): 0x00030000  <-- this is the value of register
	
------

   mcspiX may nor work according to all mcspi issues :
	http://e2e.ti.com/support/arm/sitara_arm/f/791/t/496527
	https://elinux.org/BeagleBone_Black_Enable_SPIDEV
	https://elinux.org/BeagleBoard/SPI


Annexe :

get the cpu temperature

	$ cat /sys/class/thermal/thermal_zone0/temp

	67000
	this is about 67 deg C in CPU

get the cpu frequency

	$ cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq

	1000000   <-- this is cpu0
	1000000   <-- this is cpu1

check the clock rate in 

	$ ls /sys/kernel/debug/clk/

check the pin mux

	$ cat /sys/kernel/debug/pinctrl/4a003400.pinmux/pinmux-pins

	Pinmux settings per pin
	Format: pin (name): mux_owner gpio_owner hog?

	in case of configuration 1
	...
	pin 229 (PIN229): 480ba000.spi (GPIO UNCLAIMED) function mcspi4_pins group mcspi4_pins
	pin 230 (PIN230): 480ba000.spi (GPIO UNCLAIMED) function mcspi4_pins group mcspi4_pins
	pin 231 (PIN231): 480ba000.spi (GPIO UNCLAIMED) function mcspi4_pins group mcspi4_pins
	pin 232 (PIN232): 480ba000.spi (GPIO UNCLAIMED) function mcspi4_pins group mcspi4_pins
	...

	in case of configuration 2
	pin 211 (PIN209): spi2.0 (GPIO UNCLAIMED) function mcspi4_pins group mcspi4_pins
	pin 212 (PIN210): spi2.0 (GPIO UNCLAIMED) function mcspi4_pins group mcspi4_pins
	pin 229 (PIN211): spi2.0 (GPIO UNCLAIMED) function mcspi4_pins group mcspi4_pins
	pin 230 (PIN212): spi2.0 (GPIO UNCLAIMED) function mcspi4_pins group mcspi4_pin
	
	$ cat /sys/kernel/debug/pinctrl/4a003400.pinmux/pinmux-functions
	function: mcspi4_pins, groups = [ mcspi4_pins ]
	function: mmc1_pins_default, groups = [ mmc1_pins_default ]
	function: mmc1_pins_hs, groups = [ mmc1_pins_hs ]
	function: mmc1_pins_sdr12, groups = [ mmc1_pins_sdr12 ]
	function: mmc1_pins_sdr25, groups = [ mmc1_pins_sdr25 ]
	function: mmc1_pins_sdr50, groups = [ mmc1_pins_sdr50 ]
	function: mmc1_pins_ddr50, groups = [ mmc1_pins_ddr50 ]
	function: mmc1_pins_sdr104, groups = [ mmc1_pins_sdr104 ]
	function: mmc2_pins_default, groups = [ mmc2_pins_default ]
	function: mmc2_pins_hs, groups = [ mmc2_pins_hs ]
	function: mmc2_pins_ddr_rev20, groups = [ mmc2_pins_ddr_rev20 ]


	$ cat /sys/kernel/debug/gpio
	gpiochip0: GPIOs 0-31, parent: platform/4ae10000.gpio, gpio:

	gpiochip1: GPIOs 32-63, parent: platform/48055000.gpio, gpio:
	 gpio-40  (                    |?                   ) out lo    
	 gpio-62  (                    |?                   ) out lo    

	gpiochip2: GPIOs 64-95, parent: platform/48057000.gpio, gpio:

	gpiochip3: GPIOs 96-127, parent: platform/48059000.gpio, gpio:
	 gpio-117 (                    |vbus                ) in  lo IRQ

	gpiochip4: GPIOs 128-159, parent: platform/4805b000.gpio, gpio:

	gpiochip5: GPIOs 160-191, parent: platform/4805d000.gpio, gpio:
	 gpio-187 (                    |cd                  ) in  lo IRQ

	gpiochip6: GPIOs 192-223, parent: platform/48051000.gpio, gpio:
	 gpio-200 (                    |?                   ) out hi    
	 gpio-201 (                    |?                   ) out lo    
	 gpio-202 (                    |?                   ) out hi    
	 gpio-203 (                    |vtt_fixed           ) out hi    
	 gpio-204 (                    |?                   ) in  hi IRQ
	 gpio-206 (                    |?                   ) out lo    
	 gpio-207 (                    |?                   ) out lo    

	gpiochip7: GPIOs 224-255, parent: platform/48053000.gpio, gpio:

	gpiochip8: GPIOs 504-511, parent: platform/48070000.i2c:tps659038@58:tps659038_gpio, 48070000.i2c:tps659038@58:tps659038_gpio, can sleep:
	 gpio-506 (                    |GPIO fan control    ) out lo    

check wakeup sources

	$ cat /sys/kernel/debug/wakeup_sources

	name		active_count	event_count	wakeup_count	expire_count	active_since	total_time	max_time	last_change	prevent_suspend_time
	48838000.rtc	0		0		0		0		0		0		0		17096		0
	48070000.i2c:tps659038@58:tps659038_rtc	0		0		0		0		0		0	016554		0
	2-006f      	1		1		0		0		0		5		5		21528		0
	480b4000.mmc	0		0		0		0		0		0		0		3080		0
	4809c000.mmc	0		0		0		0		0		0		0		3017		0
	48424000.serial	0		0		0		0		0		0		0		2776		0
	48422000.serial	0		0		0		0		0		0		0		2766		0
	48020000.serial	0		0		0		0		0		0		0		1791		0
	alarmtimer  	0		0		0		0		0		0		0		704		0
	deleted     	0		0		0		0		0		0		0		00
