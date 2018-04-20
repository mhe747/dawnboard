/* gpio_tst.c - GPIO lib test                                                */
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

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include "gpio_lib.h"

#define VERSION "0.1"
#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

/* array of pins to test vectors */

int pin_array[] = 
{
  166,164,231,168,210,211,208,165,167,169,222,225
};

/* used to detect halt condition */
int running;

/* This is called when the user presses a ^C */
void sighandler(int sig)
{
	fprintf(stdout, "sighandler: Interrupt - halting\n");
	running = 0;
}

static void help(void) __attribute__ ((noreturn));

static void help(void)
{
	fprintf(stderr,
	    "Usage: gpio_tst [-t time][-v][-V][-x][-y][[-i][-o] PIN] \n"
		"  PIN is GPIO pin to use\n"
		"  -i input\n"
		"  -o output toggle\n"
		"  -x vector input\n"
		"  -y vector output toggle\n"
		"  -t set delay to time seconds\n"
		"  -v enables verbose progress messages\n"
		"  -V prints the tool version\n");
	exit(1);
}

int main(int argc, char **argv)
{
	gpio *g;
	gpio_vec *gv;
	int flags = 0, verbose = 0, input = 0, output = 0,
		vinput = 0, voutput = 0,pin, time = 1;

	/* handle (optional) flags first */
	while (1+flags < argc && argv[1+flags][0] == '-')
	{
		switch (argv[1+flags][1])
		{
		case 'i': input = 1; break;
		case 'o': output = 1; break;
		case 'x': vinput = 1; break;
		case 'y': voutput = 1; break;
		case 't':
			if (2+flags < argc)
				time = atoi(argv[flags+2]);
			flags++;
			break;
		case 'v': verbose = 1; break;
		case 'V':
			fprintf(stderr, "gpio_tst version %s\n", VERSION);
			exit(0);
		default:
			fprintf(stderr, "Error: Unsupported option "
				"\"%s\"!\n", argv[1+flags]);
			help();
			exit(1);
		}
		flags++;
	}

	/* open up GPIO port */
	if(input || output)
	{
		/* missing pin? */
		if(argc < flags + 2)
			help();
		else
			pin = atoi(argv[flags + 1]);
	
		if((g = gpio_init(pin, verbose)) == NULL)
		{
			fprintf(stderr, "Couldn't open GPIO pin %d\n", pin);
			exit(2);
		}
	}
	else if(vinput || voutput)
	{
		if((gv = gpio_vec_build(pin_array, ARRAY_SIZE(pin_array), verbose)) == NULL)
		{
			fprintf(stderr, "Couldn't open GPIO vector\n");
			exit(2);
		}
	}
	
	/* input or output */
	if(input)
	{
		/* set dir to in */
		fprintf(stderr, "Input from pin %d\n", pin);
		gpio_set_dir(g, 1);
		
		/* install signal handler for ^C */
		if(signal(SIGINT, sighandler) == SIG_ERR)
		{
			fprintf(stderr, "couldn't install signal hander\n");
			goto done;
		}
		
		/* enter loop */
		running = 1;
		while(running)
		{
			fprintf(stderr, "%d\n", gpio_get(g));
			sleep(time);
		}
		
		/* reset signal handler */
		signal(SIGINT, SIG_DFL);
	}		
	else if(output)
	{
		int data;
		
		/* set dir to out */
		fprintf(stderr, "Output to pin %d\n", pin);
		gpio_set_dir(g, 0);
		
		/* install signal handler for ^C */
		if(signal(SIGINT, sighandler) == SIG_ERR)
		{
			fprintf(stderr, "couldn't install signal hander\n");
			goto done;
		}
		
		/* enter loop */
		running = 1;
		data = 0;
		while(running)
		{
			data = gpio_get(g) ^ 1;
			
			fprintf(stderr, "%d\n", data);
			gpio_set(g, data);
			sleep(time);
		}
		
		/* reset signal handler */
		signal(SIGINT, SIG_DFL);
	}
	else if(vinput)
	{
		/* set dir to in */
		fprintf(stderr, "Vector Input from pins\n");
		gpio_vec_set_dir(gv, 0xFFFFFFFF);
		
		/* install signal handler for ^C */
		if(signal(SIGINT, sighandler) == SIG_ERR)
		{
			fprintf(stderr, "couldn't install signal hander\n");
			goto done;
		}
		
		/* enter loop */
		running = 1;
		while(running)
		{
			fprintf(stderr, "0x%08X\n", gpio_vec_get(gv));
			sleep(time);
		}
		
		/* reset signal handler */
		signal(SIGINT, SIG_DFL);
	}		
	else if(voutput)
	{
		int data;
		
		/* set dir to out */
		fprintf(stderr, "Vector Output to pins\n");
		gpio_vec_set_dir(gv, 0);
		
		/* install signal handler for ^C */
		if(signal(SIGINT, sighandler) == SIG_ERR)
		{
			fprintf(stderr, "couldn't install signal hander\n");
			goto done;
		}
		
		/* enter loop */
		running = 1;
		data = 0;
		while(running)
		{
			data = gpio_vec_get(gv);
			fprintf(stderr, "Read 0x%08X\n", data);
			
			data ^= 0xFFFFFFFF;
			gpio_vec_set(gv, data);
			fprintf(stderr, "Wrote 0x%08X\n", data);
			sleep(time);
		}
		
		/* reset signal handler */
		signal(SIGINT, SIG_DFL);
	}
	
	/* All done */
done:
	if(input||output)
		gpio_delete(g);
	else if(vinput||voutput)
		gpio_vec_delete(gv);
	
	return 0;
}
