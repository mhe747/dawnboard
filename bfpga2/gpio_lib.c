/* gpio_lib.c - gpio sysfs access library                            */
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

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "gpio_lib.h"

/* wrapper for fprintf(stderr, ...) to support verbose control */
void gpio_qprintf(gpio *s, char *fmt, ...)
{
	va_list args;
	
	if(s->verbose)
	{
		va_start(args, fmt);
		vfprintf(stderr, fmt, args);
		va_end(args);
	}
}

/* open up a gpio pin */
gpio *gpio_init(int pin, int verbose)
{
	gpio *s;
	FILE *fp; 
	char fname[256];
	
	/* allocate the object */
	if((s = calloc(1, sizeof(gpio))) == NULL)
	{
		fprintf(stderr, "gpio_init: Couldn't allocate gpio object\n");
		goto fail0;
	}
	
	/* set params */
	s->pin = pin;
	s->verbose = verbose;
	
	/* Open export file */
	if ((fp = fopen("/sys/class/gpio/export", "ab")) == NULL)
	{
		gpio_qprintf(s, "gpio_init: Cannot open export file.\n");
		goto fail1;
	}
	else
		gpio_qprintf(s, "gpio_init: Opened export file.\n");		
	
	/* Write our value of pin to the export file */
	fprintf(fp, "%d", pin);
	fclose(fp);
	gpio_qprintf(s, "gpio_init: closed export file.\n");		
	
	/* Create pin dir name */
	sprintf(fname, "/sys/class/gpio/gpio%d/direction", pin);

	/* open direction file */
	if ((s->dirfile = fopen(fname, "rb+")) == NULL)
	{
		gpio_qprintf(s, "gpio_init: Cannot open direction file %s.\n", fname);
		goto fail1;
	}
	else
		gpio_qprintf(s, "gpio_init: Opened direction file %s.\n", fname);		
	
	setvbuf(s->dirfile, NULL, _IONBF, 0);
	
	/* Create pin val name */
	sprintf(fname, "/sys/class/gpio/gpio%d/value", pin);

	/* open value file */
	if ((s->valfile = fopen(fname, "rb+")) == NULL)
	{
		gpio_qprintf(s, "gpio_init: Cannot open value file %s.\n", fname);
		goto fail2;
	}
	else
		gpio_qprintf(s, "gpio_init: Opened value file %s.\n", fname);		
	
	setvbuf(s->valfile, NULL, _IONBF, 0);

	/* init direction to input */
	//gpio_set_dir(s, 1);
	//gpio_qprintf(s, "gpio_init: Set default direction = input.\n");		
	
	/* init value to 0 */
	gpio_set(s, 0);
	gpio_qprintf(s, "gpio_init: Set default value = 0.\n");		
	
	/* Success */
	return s;

//fail3:
//	fclose(s->valfile);
fail2:
	fclose(s->dirfile);
fail1:
	free(s);				/* free the structure */
fail0:
	return NULL;
}

/* set pin direction */
void gpio_set_dir(gpio *s, int dir)
{
	char odir[4];
	
	/* setup direction */
	sprintf(odir, "%s", dir ? "in" : "out");
	
	/* Write direction to dir file */
	fwrite(odir, sizeof(char), strlen(odir), s->dirfile);
	gpio_qprintf(s, "gpio_set_dir: wrote %s to pin %d direction file.\n", odir, s->pin);		
}

/* set pin value */
void gpio_set(gpio *s, int val)
{
	char oval[2];
	
	/* setup value */
	sprintf(oval, "%d", val);
	
	/* Write value to value file */ 
	fwrite(oval, sizeof(char), strlen(oval), s->valfile);
	gpio_qprintf(s, "gpio_set: wrote %s to pin %d value file.\n", oval, s->pin);		
}

/* get pin value */
int gpio_get(gpio *s)
{
	char cval[2];
	
	/* read value from val file */ 
	rewind(s->valfile);
	fread(&cval, sizeof(char), 1, s->valfile);
	cval[1] = 0;
	gpio_qprintf(s, "gpio_get: read %s from pin %d value file.\n", cval, s->pin);		
		
	return atoi(cval);
}

/* Clean shutdown of our GPIO interface */
void gpio_delete(gpio *s)
{
	FILE *fp;
	
	fclose(s->valfile);		/* close the value file */
	gpio_qprintf(s, "gpio_delete: closed value file.\n");		
	fclose(s->dirfile);		/* close the direction file */
	gpio_qprintf(s, "gpio_delete: closed direction file.\n");		
	
	/* Open unexport file */
	if ((fp = fopen("/sys/class/gpio/unexport", "ab")) == NULL)
	{
		gpio_qprintf(s, "gpio_delete: Cannot open unexport file.\n");
	}
	else
	{	
		/* Write our value of pin to the unexport file */
		gpio_qprintf(s, "gpio_delete: opened unexport file.\n");		
		fprintf(fp, "%d", s->pin);
		fclose(fp);
		gpio_qprintf(s, "gpio_delete: closed unexport file.\n");		
	}
	
	free(s);				/* free the structure */
}

/* create a vector of pins */
gpio_vec *gpio_vec_build(int *pins, int num_pins, int verbose)
{
	gpio_vec *s;
	int i;
	
	/* idiot stop */
	if(num_pins > 32)
	{
		fprintf(stderr, "gpio_build_vec: pin array exceeds 32\n");
		goto fail0;
	}
	
	/* allocate the object */
	if((s = calloc(1, sizeof(gpio_vec))) == NULL)
	{
		fprintf(stderr, "gpio_build_vec: Couldn't allocate gpio_vec object\n");
		goto fail0;
	}
	
	/* save params */
	s->num_pins = num_pins;
	s->verbose = verbose;

	/* Iterate to build array */
	for(i=0;i<s->num_pins;i++)
	{
		if((s->gpins[i] = gpio_init(pins[i], verbose)) == NULL)
		{
			gpio_qprintf((gpio *)s, "gpio_build_vec: Couldn't create pin %d\n", pins[i]);
			goto fail1;
		}
	}
	
	/* success */
	return s;
	
fail1:
	for(i=s->num_pins-1;i>=0;i--)	/* iterate through the pin array */
	{
		if(s->gpins[i])
			gpio_delete(s->gpins[i]);
	}
	free(s);						/* free the structure */
fail0:
	return NULL;
}

/* set pin vector directions */
void gpio_vec_set_dir(gpio_vec *s, int dir)
{
	int i;
	for(i=0;i<s->num_pins;i++)	/* iterate through the pin array */
	{
		gpio_set_dir(s->gpins[i], (dir>>i)&1);
	}
}

/* set pin values */
void gpio_vec_set(gpio_vec *s, int val)
{
	int i;
	for(i=0;i<s->num_pins;i++)	/* iterate through the pin array */
	{
		gpio_set(s->gpins[i], (val>>i)&1);
	}
}

/* get pin values */
int gpio_vec_get(gpio_vec *s)
{
	int i, val = 0;
	for(i=0;i<s->num_pins;i++)	/* iterate through the pin array */
	{
		val |= ((gpio_get(s->gpins[i])&1)<<i);
	}
	
	return val;
}

/* delete the pin vector & free up storage */
void gpio_vec_delete(gpio_vec *s)
{
	int i;
	
	for(i=s->num_pins-1;i>=0;i--)	/* iterate through the pin array */
	{
		if(s->gpins[i])
			gpio_delete(s->gpins[i]);
	}
	free(s);						/* free the structure */
}
