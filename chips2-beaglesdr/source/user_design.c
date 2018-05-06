////////////////////////////////////////////////////////////////////////////////
//
//  CHIPS-2.0 USER DESIGN
//
//  :Author: Jonathan P Dawson
//  :Date: 17/10/2013
//  :email: chips@jondawson.org.uk
//  :license: MIT
//  :Copyright: Copyright (C) Jonathan P Dawson 2013
//
//  Simple web app demo.
//
////////////////////////////////////////////////////////////////////////////////

#include "print.h"

int find(unsigned string[], unsigned search, unsigned start, unsigned end){
	int value = start;
	while(string[value]){
	       print_decimal(string[value]); print_string("\n");
	       print_decimal(value); print_string("\n");
	       if(value == end) return -1;
	       if(string[value] == search) return value;
	       value++;
	}
	return -1;
}

void user_design()
{
	//simple echo application and LED on/off self-switching
	unsigned length;
	unsigned i, index;
	//uart buffer
	unsigned data[1024];
	unsigned word;
	unsigned speed = 0;
	unsigned leds = 0;
	unsigned adc;
	unsigned dac = 0;
	unsigned start, end;
	unsigned cmd;
	index = 0;

	while(1) {
			cmd=input_rs232_rx();
			switch(cmd) {
				case '1':
					leds = 1;
					//dac = 0;
					print_udecimal(leds);
					break;
				case '2':
					leds = 2;
					//dac = 1000;
					print_udecimal(leds);
					break;
				case '3':
					leds = 3;
					//dac = 2000;
					print_udecimal(leds);
					break;
				case '4':
					leds = 0;
					//dac = 4000;
					print_udecimal(leds);					
					break;
				case '5':
					leds = 0;
					//dac = 8000;	
					print_udecimal(leds);					
					break;
				case '6':
					leds = 0;
					//dac = 16000;		
					print_udecimal(leds);
					break;
				default :
					leds = 0;
					break;					
			}
			
			output_leds(leds);			
/* LED COUNTER
			speed++;
			if (speed>1000) {
				leds++; // LED switch every 500 ms = 5 (cycles / cpu instruction) * 1000 * 10000 = 50 Mhz
				speed=0;
			}
			if (leds>3) leds = 0;
			output_leds(leds);
			wait_clocks(10000); // wait 10000 time unit 
*/			
	}

	// dummy
	//print_udecimal(1);
}
