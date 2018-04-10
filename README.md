

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

## CHECK linux kernel

	in Target :
	$ ls -l /dev/i2c*
	$ ls -l /dev/spi*
	if files are not present in /dev, it means you have to have to download some kernel patches to enable I2C and SPI.
