
## all yocto arago project ipk packages sources for beagleboard-x15 based on processor-sdk-xx.xx.xx.xx-config

	./oe-layertool-setup.sh -f configs/processor-sdk/processor-sdk-04.03.00.05-config.txt
	cd build
	. conf/setenv
	
## get the cross compiler 
	wget https://releases.linaro.org/components/toolchain/binaries/6.2-2016.11/arm-linux-gnueabihf/gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf.tar.xz
	tar -Jxvf gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf.tar.xz -C $HOME
--------
	export PATH=$HOME/gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf/bin:$PATH
	MACHINE=am57xx-evm  bitbake arago-core-tisdk-image


