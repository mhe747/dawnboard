# AVRDUDE & AVR-GCC

## User
Using Arduino bootloader loaded in AVR microcontroller, one can push a program from Beagleboard-x15 to the BeagleSDR, in order to reprogram the AVR through the UART port linked between AVR and Beagleboard-x15. With an oscilloscope, one should test the UART port control before. The AVR had been conceived to construct complex user-space applications for interaction with your Beagleboard-x15. Some plans can be imaginable in order to control off-board motors and Radio Frequency de/modulator, filters. However the newest updated Kernel is needed. MLO, U-boot and Linux Kernel driver with pin muxing support including UART are required.

------

## AVR microcontroller Design
Synthesizing an AVR design can be relied on Arduino IDE which is free downloadable from its official website (https://www.arduino.cc/en/Main/Software). This suite of tools includes an IDE to edit your source codes in simplest manner. Each file has to be written in C language. In Linux systems, you can use AVR-GCC (https://gcc.gnu.org/wiki/avr-gcc) as a cross-compiler to compile your AVR microcontroller program. A Makefile is included in this directory to show these capabilities, (https://www.tldp.org/HOWTO/Avr-Microcontrollers-in-Linux-Howto/x207.html). In order to push the compiled hex file into your AVR on BeagleSDR, firstable you need to use Avrdude which can be found in (https://www.nongnu.org/avrdude/) (http://download.savannah.gnu.org/releases/avrdude/) this is the utility to download/upload/manipulate the ROM and EEPROM contents of AVR microcontrollers using the in-system programming technique. The ICSP technique need a programmer sold separately, called USBASP USBISP "AVR Programmer" through USB. At first, you should burn an Arduino Bootloader into AVR. Once bootloader flashed inside, then you can send your compiled file hex format in Arduino through UART from Beagleboard-x15 by opening UART8 port, ref. BeagleSDR schematics.

------
add bitbake files : avrdude_6.3.bb and avrdude.inc in $TISDK/sources/meta-openembedded/meta-oe/recipes-devtools/avrdude

avrdude_6.3.bb :

	require avrdude.inc

	PR = "r2"

	SRC_URI[md5sum] = "58bb42049122cf80fe4f4d0ce36d92ee"
	SRC_URI[sha256sum] = "0f9f731b6394ca7795b88359689a7fa1fba818c6e1d962513eb28da670e0a196"

avrdude.inc :

	DESCRIPTION = "AVRDUDE is software for programming Atmel AVR Microcontrollers."
	HOMEPAGE = "http://www.nongnu.org/avrdude/"
	SECTION = "console"
	LICENSE = "GPLv2"

	DEPENDS = "virtual/libusb0 ncurses"

	SRC_URI = "http://savannah.nongnu.org/download/avrdude/avrdude-${PV}.tar.gz"

	inherit autotools

------

## Upload to BeagleSDR

Install new packages libusb and avrdude into target

	$ opkg install libusb-0.1-4 avrdude

------

The BeagleSDR's AVR port configurations need new setup :

	$ avrdude -c usbasp -p m328 -e -u -U lock:w:0x3f:m -U efuse:w:0x05:m -U hfuse:w:0xda:m -U lfuse:w:0xff:m

	avrdude: warning: cannot set sck period. please check for usbasp firmware update.
	avrdude: AVR device initialized and ready to accept instructions

	Reading | ################################################## | 100% 0.00s

	avrdude: Device signature = 0x1e9514 (probably m328)
	avrdude: erasing chip
	avrdude: warning: cannot set sck period. please check for usbasp firmware update.
	avrdude: reading input file "0x3f"
	avrdude: writing lock (1 bytes):

	Writing | ################################################## | 100% 0.00s
	...
	
------

Arduino bootloader can be uploaded using avrdude on the BeagleSDR's AVR through USB :

	$ avrdude -c usbasp -p m328 -U flash:w:ATmegaBOOT_168_atmega328_8MHz.hex -U lock:w:0x0f:m

	avrdude: AVR device initialized and ready to accept instructions

	Reading | ################################################## | 100% 0.00s

	avrdude: Device signature = 0x1e9514 (probably m328)
	avrdude: NOTE: "flash" memory has been specified, an erase cycle will be performed
		 To disable this feature, specify the -D option.
	avrdude: erasing chip
	avrdude: warning: cannot set sck period. please check for usbasp firmware update.
	avrdude: reading input file "ATmegaBOOT_168_atmega328_pro_8MHz.hex"
	avrdude: input file ATmegaBOOT_168_atmega328_pro_8MHz.hex auto detected as Intel Hex
	avrdude: writing flash (32652 bytes):

	Writing | ################################################## | 100% 0.00s

	avrdude: 32652 bytes of flash written
	avrdude: verifying flash memory against ATmegaBOOT_168_atmega328_pro_8MHz.hex:
	avrdude: load data flash data from input file ATmegaBOOT_168_atmega328_pro_8MHz.hex:
	avrdude: input file ATmegaBOOT_168_atmega328_pro_8MHz.hex auto detected as Intel Hex
	avrdude: input file ATmegaBOOT_168_atmega328_pro_8MHz.hex contains 32652 bytes
	avrdude: reading on-chip flash data:

	Reading | ################################################## | 100% 0.00s

	avrdude: verifying ...
	avrdude: 32652 bytes of flash verified
	avrdude: reading input file "0x0f"
	avrdude: writing lock (1 bytes):

	Writing | ################################################## | 100% 0.01s

	avrdude: 1 bytes of lock written
	avrdude: verifying lock memory against 0x0f:
	avrdude: load data lock data from input file 0x0f:
	avrdude: input file 0x0f contains 1 bytes
	avrdude: reading on-chip lock data:

	Reading | ################################################## | 100% 0.00s

	avrdude: verifying ...
	avrdude: 1 bytes of lock verified

	avrdude: safemode: Fuses OK (E:FD, H:DA, L:FF)

	avrdude done.  Thank you.

------

Arduino sketches now can be uploaded using avrdude on the BeagleSDR's AVR through UART8 :

	$ avrdude -V -F -c usbasp -p m328 -P /dev/ttyS8 -b 57600 -U flash:w:Arduino.hex

	avrdude: warning: cannot set sck period. please check for usbasp firmware update.
	avrdude: AVR device initialized and ready to accept instructions

	Reading | ################################################## | 100% 0.00s

	avrdude: Device signature = 0x1e9514
	avrdude: Expected signature for ATMEGA329 is 1E 95 03
	avrdude: NOTE: FLASH memory has been specified, an erase cycle will be performed
		 To disable this feature, specify the -D option.
	avrdude: erasing chip
	avrdude: warning: cannot set sck period. please check for usbasp firmware update.
	avrdude: reading input file "Arduino.hex"
	avrdude: input file Arduino.hex auto detected as Intel Hex
	avrdude: writing flash (950 bytes):

	Writing | ################################################## | 100% 0.57s

	avrdude: 950 bytes of flash written

	avrdude: safemode: Fuses OK

	avrdude done.  Thank you.

Arduino sketches binary in hex format can be read using avrdude on the BeagleSDR's AVR through UART8, 
provided that UART8 enabled in Beagleboard-x15 Linux Kernel :

	$ avrdude -c usbasp -p m328 -U flash:r:toto.hex:r
	$ hexdump -C toto.hex -n 32638
	
------
	
	Each of the 14 digital pins on the AVR microcontroller can be used as an input or output, 
	using pinMode(), digitalWrite(), and digitalRead() functions. 
	They operate at 5 volts. Each pin can provide or receive a maximum of 40 mA and has an internal 
	pull-up resistor (disconnected by default) of 20-50 kOhms. In addition, some pins have specialized functions:

    Serial: 0 (RX) and 1 (TX). Used to receive (RX) and transmit (TX) TTL serial data. 
    These pins are connected to the corresponding pins of the FTDI USB-to-TTL Serial chip.
    External Interrupts: 2 and 3. These pins can be configured to trigger an interrupt on a low value, 
    a rising or falling edge, or a change in value. See the attachInterrupt() function for details.
    PWM: 3, 5, 6, 9, 10, and 11. Provide 8-bit PWM output with the analogWrite() function.
    SPI: 10 (SS), 11 (MOSI), 12 (MISO), 13 (SCK). These pins support SPI communication, 
    which, although provided by the underlying hardware, is not currently included in the Arduino language.
    LED: 13. There is a built-in LED connected to digital pin 13. When the pin is HIGH value, the LED is on, 
    when the pin is LOW, it's off. 
------
	The AVR microcontroller has 8 analog inputs, each of which provide 10 bits of 
	resolution (i.e. 1024 different values). By default they measure from ground to 5 volts, 
	though is it possible to change the upper end of their range using the analogReference() function. 
	Analog pins 6 and 7 cannot be used as digital pins. Additionally, some pins have specialized functionality:

    I2C: 4 (SDA) and 5 (SCL). Support I2C (TWI) communication using the Wire library (documentation on the Wiring website). 
------

	There are a couple of other pins on the board:

    AREF. Reference voltage for the analog inputs. Used with analogReference().
    Reset. Bring this line LOW to reset the microcontroller. Typically used to add a reset button 
    to shields which block the one on the board. 
    
