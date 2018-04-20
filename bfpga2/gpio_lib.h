/* gpio_lib.h - gpio sysfs access library                                    */
/* Copyright 2010 Eric Brombaugh                                             */
/*   This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
    MA 02110-1301 USA.
*/

#ifndef __gpio_lib__
#define __gpio_lib__

#include <stdio.h>

typedef struct
{
	int verbose;
	int pin;
	FILE *dirfile;
	FILE *valfile;
	char gpio_pin_dir[32];
} gpio;

typedef struct
{
	int verbose;
	int num_pins;
	gpio *gpins[32];
} gpio_vec;

gpio *gpio_init(int pin, int verbose);
void gpio_set_dir(gpio *s, int dir);
void gpio_set(gpio *s, int val);
int gpio_get(gpio *s);
void gpio_delete(gpio *s);

gpio_vec *gpio_vec_build(int *pins, int num_pins, int verbose);
void gpio_vec_set_dir(gpio_vec *s, int dir);
void gpio_vec_set(gpio_vec *s, int val);
int gpio_vec_get(gpio_vec *s);
void gpio_vec_delete(gpio_vec *s);
#endif
