
# all yocto arago project ipk packages sources for beagleboard-x15 based on processor-sdk-04.02.00.09-config

./oe-layertool-setup.sh -f configs/processor-sdk/processor-sdk-04.02.00.09-config.txt
mkdir downloads
cd build
. conf/setenv
# first get the cross compiler from 
# wget https://releases.linaro.org/components/toolchain/binaries/6.2-2016.11/arm-linux-gnueabihf/gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf.tar.xz
# tar -Jxvf gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf.tar.xz -C $HOME
export PATH=$HOME/gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf/bin:$PATH
MACHINE=am57xx-evm  bitbake arago-core-tisdk-image


