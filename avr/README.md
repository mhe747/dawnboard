
# AVRDUDE & AVR-GCC

## User
Using Arduino bootloader loaded in AVR microcontroller, one can push a program from Beagleboard-x15 to the BeagleSDR, in order to reprogram the AVR through the UART port linked between AVR and Beagleboard-x15. With an oscilloscope, one should test the UART port control before. The AVR had been conceived to construct complex user-space applications for interaction with your Beagleboard-x15. Some plans can be imaginable in order to control off-board motors and Radio Frequency de/modulator, filters. However the newest updated Kernel is needed. MLO, U-boot and Linux Kernel driver with pin muxing support including UART are required.

## AVR microcontroller Design
Synthesizing an AVR design can be relied on Arduino IDE which is free downloadable from its official website (https://www.arduino.cc/en/Main/Software). This suite of tools includes an IDE to edit your source codes in simplest manner. Each file has to be written in C language. In Linux systems, you can use AVR-GCC (https://gcc.gnu.org/wiki/avr-gcc) as a cross-compiler to compile your AVR microcontroller program. A Makefile is included in this directory to show these capabilities, (https://www.tldp.org/HOWTO/Avr-Microcontrollers-in-Linux-Howto/x207.html). In order to push the compiled hex file into your AVR on BeagleSDR, firstable you need to use Avrdude which can be found in (https://www.nongnu.org/avrdude/) (http://download.savannah.gnu.org/releases/avrdude/) this is the utility to download/upload/manipulate the ROM and EEPROM contents of AVR microcontrollers using the in-system programming technique. The ICSP technique need a programmer sold separately, called USBASP USBISP "AVR Programmer" through USB. At first, you should burn an Arduino Bootloader into AVR. Once bootloader flashed inside, then you can send your compiled file hex format in Arduino through UART from Beagleboard-x15 by opening UART8 port, ref. BeagleSDR schematics.

## Upload to BeagleSDR
AVR code or Arduino sketches can be uploaded using avrdude on the BeagleSDR's AVR through USB :

	$ avrdude -c usbasp -p atmega328 -e -u -U lock:w:0x3f:m -U efuse:w:0x05:m -U hfuse:w:0xda:m -U lfuse:w:0xff:m

Arduino bootloader can be uploaded using avrdude on the BeagleSDR's AVR through USB :

	$ avrdude -c usbasp -p atmega328 -U flash:w:ATmegaBOOT_168_atmega328_8MHz.hex -U lock:w:0x0f:m

Arduino sketches can be uploaded using avrdude on the BeagleSDR's AVR through UART8 :

	$ avrdude -V -F -c usbasp -p m328 -P /dev/ttyS1 -b 57600 -U flash:w:main.hex

