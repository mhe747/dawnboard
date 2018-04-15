/* bfpga2_lib.c - Beagle FPGA board access library                            */
/* Copyright 2011 Eric Brombaugh                                             */
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
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <errno.h>
#include <math.h>
#include "bfpga2_lib.h"

//	has to update
#define I2C_ADDR_EXPANDER 0x20
#define I2C_ADDR_LTC 0x17
#define I2C_ADDR_EEPROM 0x50
#define PROG_FREQ 48000000
#define MAX_DUMMY_CLOCK 10000000
const unsigned char idprom[] =
{
//	has to update
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

/* .bit file header */
const char bit_hdr[] =
{
	0x00, 0x09, 0x0F, 0xF0, 0x0F, 0xF0, 0x0F, 0xF0, 0x0F, 0xF0, 0x00, 0x00, 0x01
};

const char *bit_hdr_strings[] =
{
	"filename",
	"device",
	"date",
	"time"
};

const char *deviceid = "3s500e";

/* M25P40 Flash ID */
const char flash_id[] = 
{
//	has to update
	0x00, 0x00, 0x00
};

/* wrapper for fprintf(stderr, ...) to support verbose control */
void qprintf(bfpga *s, char *fmt, ...)
{
	va_list args;
	
	if(s->verbose)
	{
		va_start(args, fmt);
		vfprintf(stderr, fmt, args);
		va_end(args);
	}
}

/* set I2C slave address */
int i2c_set_slave_addr(int file, int address)
{
	if(ioctl(file, I2C_SLAVE, address) < 0)
		return -errno;
	else
		return 0;
}

/* low-level interface to I2C read/write */
static inline __s32 i2c_smbus_access(int file, char read_write, __u8 command, 
                                     int size, union i2c_smbus_data *data)
{
	struct i2c_smbus_ioctl_data args;

	args.read_write = read_write;
	args.command = command;
	args.size = size;
	args.data = data;
	return ioctl(file,I2C_SMBUS,&args);
}

/* get a single byte from an I2C EEPROM */
int bfpga2_i2c_get_prom(bfpga *s, int saddr, __u8 loc)
{
	union i2c_smbus_data data;
	
	/* set address */
	if(i2c_set_slave_addr(s->i2c_file, saddr))
		return -1;

	/* get data */
	if (i2c_smbus_access(s->i2c_file,I2C_SMBUS_READ, loc,
	                     I2C_SMBUS_BYTE_DATA,&data))
		return -1;
	else
		return 0x0FF & data.byte;
}

/* send two bytes to I2C slave */
int bfpga2_i2c_set_prom(bfpga *s, int saddr, __u8 loc, __u8 dat)
{
	union i2c_smbus_data data;
	
	data.byte = dat;
	
	/* set address */
	if(i2c_set_slave_addr(s->i2c_file, saddr))
		return -1;

	/* send data */
	return i2c_smbus_access(s->i2c_file,I2C_SMBUS_WRITE, loc,
	                     I2C_SMBUS_BYTE_DATA,&data);
}

/* get a single byte from an I2C slave */
int bfpga2_i2c_get(bfpga *s, int saddr)
{
	union i2c_smbus_data data;
	
	/* set address */
	if(i2c_set_slave_addr(s->i2c_file, saddr))
		return -1;

	/* get data */
	if (i2c_smbus_access(s->i2c_file,I2C_SMBUS_READ, 0,
	                     I2C_SMBUS_BYTE,&data))
		return -1;
	else
		return 0x0FF & data.byte;
}

/* set a single byte to an I2C slave */
int bfpga2_i2c_set(bfpga *s, int saddr, __u8 dat)
{
	/* set address */
	if(i2c_set_slave_addr(s->i2c_file, saddr))
		return -1;

	/* send data */
	return i2c_smbus_access(s->i2c_file,I2C_SMBUS_WRITE,dat,
	                        I2C_SMBUS_BYTE,NULL);
}

/* get PCF GPIO bit */
int bfpga2_i2c_pcf_rd(bfpga *s, int bit)
{
	return (bfpga2_i2c_get(s, I2C_ADDR_EXPANDER) >> bit) & 1;
}

/* get PCF GPIO bit */
void bfpga2_i2c_pcf_wr(bfpga *s, int bit, int val)
{
	int oldval = bfpga2_i2c_get(s, I2C_ADDR_EXPANDER) | 0xC0;		// don't clear uppers
	int hmask = 1<<bit;
	int lmask = ~hmask & 0xFF;
	int newval = (oldval & lmask) | ((val & 1) << bit);
	bfpga2_i2c_set(s, I2C_ADDR_EXPANDER, newval);
}

/* set LTC6904 frequency */
int bfpga2_i2c_set_freq(bfpga *s, int freq)
{
	int oct, dac;
	__u8 msb, lsb;
	
	/* convert freq to LTC6904 control bytes */
#if 0
	/* Straight bits from caller - no conversion */
	msb = (freq>>8)&0xFF;
	lsb = freq&0xFF;
#else
	/* convert using LTC's formula */
	oct = (int)floor(3.322*log((double)freq/1039)/log(10));
	dac = (int)floor(( 2048 - (2078*pow(2.0, 10+(double)oct))/(double)freq )+0.5);
	qprintf(s, "bfpga2_i2c_set_freq: oct = %d, dac = %d\n", oct, dac);
	if((oct < 0) || (oct>15) || (dac < 0) || (dac>1023))
	{
		qprintf(s, "bfpga2_i2c_set_freq: freq out of range\n");
		return -1;
	}
	msb = (oct<<4) | ((dac >>6)&0xF);
	lsb = (dac<<2)&0xFC;
	qprintf(s, "bfpga2_i2c_set_freq: msb = 0x%02X, lsb = 0x%02X\n", msb, lsb);
#endif
	
	/* send bytes to LTC6904 */
	return bfpga2_i2c_set_prom(s, I2C_ADDR_LTC, msb, lsb);
}

/* SPI Transmit/Receive */
int bfpga2_spi_txrx(bfpga *s, uint8_t *tx, uint8_t *rx, __u32 len)
{
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		.len = len,
		.delay_usecs = 0,
		.speed_hz = 2000000,
		.bits_per_word = 8,
	};
	
	return ioctl(s->spi_file, SPI_IOC_MESSAGE(1), &tr);
}

/* initialize our FPGA interface */
bfpga *bfpga2_init(int i2c_bus, int spi_bus, int spi_add, int verbose)
{
	bfpga *s;
	char filename[20];
	uint32_t speed = PROG_FREQ;
	uint8_t mode = 0;
	//uint8_t mode = SPI_CPHA;
	//uint8_t mode = SPI_CPOL;
	int i;
	
	/* allocate the object */
	if((s = calloc(1, sizeof(bfpga))) == NULL)
	{
		qprintf(s, "bfpga2_init: Couldn't allocate bfpga object\n");
		goto fail0;
	}
	
	/* set verbose level */
	s->verbose = verbose;
	
	/* open I2C bus */
	sprintf(filename, "/dev/i2c-%d", i2c_bus);
	s->i2c_file = open(filename, O_RDWR);

	if(s->i2c_file < 0)
	{
		qprintf(s, "bfpga2_init: Couldn't open I2C device %s\n", filename);
		goto fail1;
	}
	else
		qprintf(s, "bfpga2_init: opened I2C device %s\n", filename);
		
	
	/* Check for the Beagle FPGA ID PROM */
	for(i=0;i<6;i++)
	{
		int value = bfpga2_i2c_get_prom(s, I2C_ADDR_EEPROM, i);
		qprintf(s, "bfpga2_init: ID[%1d] = 0x%02X\n", i, value);
		
/*		if(value != idprom[i])                                          
		{
			qprintf(s, "bfpga2_init: IDPROM mismatch - giving up\n");
			goto fail2;
		}
*/
	}
	qprintf(s, "bfpga2_init: found IDPROM\n");
	
	/* diagnostid - check status of port expander */
	qprintf(s, "bfpga2_init: PCF reads 0x%02X\n", bfpga2_i2c_get(s, I2C_ADDR_EXPANDER));

	/* Open the SPI port */
	sprintf(filename, "/dev/spidev%d.%d", spi_bus, spi_add);
	s->spi_file = open(filename, O_RDWR);
	
	if(s->spi_file < 0)
	{
		qprintf(s, "bfpga2_init: Couldn't open spi device %s\n", filename);
		goto fail2;
	}
	else
		qprintf(s, "bfpga2_init: opened spi device %s\n", filename);

	if(ioctl(s->spi_file, SPI_IOC_WR_MAX_SPEED_HZ, &speed) == -1)
	{
		qprintf(s, "bfpga2_init: Couldn't set SPI clock to %d Hz\n", speed);
		goto fail2;
	}
	else
		qprintf(s, "bfpga2_init: Set SPI clock to %d Hz\n", speed);
	
	if(ioctl(s->spi_file, SPI_IOC_WR_MODE, &mode) == -1)
	{
		qprintf(s, "bfpga2_init: Couldn't set SPI mode\n");
		goto fail2;
	}
	else
		qprintf(s, "bfpga2_init: Set SPI mode\n");
	
	/* Check if FPGA already configured */
	if(bfpga2_i2c_pcf_rd(s,PCF_FPGA_DONE)==0)
	{
		qprintf(s, "bfpga2_init: FPGA not already configured - DONE not high\n\r");
	}	
	
	/* Allow OMAP to drive SPI bus */
	bfpga2_i2c_pcf_wr(s,PCF_FPGA_SPI_MODE,0);		// drive nOE line low
	qprintf(s, "bfpga2_init: OMAP Drives SPI bus\n");
		
	/* success */
	return s;

	/* failure modes */
//fail3:
//	close(s->spi_file);		/* close the SPI device */
fail2:
	close(s->i2c_file);		/* close the I2C device */
fail1:
	free(s);				/* free the structure */
fail0:
	return NULL;
}

/* open a bitfile and check the header */
FILE *bfpga_open_bitfile(bfpga *s, char *bitfile, long *n)
{
	FILE *fd;
	char readbuf[READBUFSIZE], *cp;
	int read, j, d;
	
	/* open file or return error*/
	if(!(fd = fopen(bitfile, "r")))
	{
		qprintf(s, "bfpga_open_bitfile: open file %s failed\n\r", bitfile);
		return 0;
	}
	else
	{
		qprintf(s, "bfpga_open_bitfile: found bitstream file %s\n\r", bitfile);
	}

	/* Read file & send bitstream via SPI1 */
	qprintf(s, "bfpga_open_bitfile: parsing header\n\r");
	if( (read=fread(readbuf, sizeof(char), 13, fd)) == 13 )
	{
		/* init pointer to keep track */
		cp = readbuf;
		
		/* check / skip .bit header */
		for(j=0;j<13;j++)
		{
			if(bit_hdr[j] != *cp++)
			{
				qprintf(s, "bfpga_open_bitfile: .bit header mismatch\n\r");
				fclose(fd);
				return 0;
			}
		}
		qprintf(s, "bfpga_open_bitfile: found header\n\r");
	}
	else
	{
		qprintf(s, "bfpga_open_bitfile: .bit header truncated\n\r");
		fclose(fd);
		return 0;
	}
		
	/* Skip File header chunks */
	for(j=0;j<4;j++)
	{
		if( (read=fread(readbuf, sizeof(char), 3, fd)) == 3 )
		{
			/* init pointer to keep track */
			cp = readbuf;
		
			/* get 1 byte chunk desginator (a,b,c,d) */
			d = *cp++;
			
			/* compute chunksize */
			*n = *cp++;
			*n <<= 8;
			*n += *cp;
			
			/* read chunk */
			if( (read=fread(readbuf, sizeof(char), *n, fd)) == *n )
			{
				/* print chunk */
				qprintf(s, "bfpga_open_bitfile: chunk %c length %ld %s %s\n\r", d, *n, bit_hdr_strings[j], readbuf);
			}
			else
			{
				qprintf(s, "bfpga_open_bitfile: chunk data truncated\n\r");
				fclose(fd);
				return 0;
			}
			
			/* Check device type */
			if(j==1)
			{
				if(strcmp(readbuf, deviceid))
					qprintf(s, "bfpga_open_bitfile: Device != %s\n\r", deviceid);
				else
					qprintf(s, "bfpga_open_bitfile: Device == %s\n\r", deviceid);
			}
		}
		else
		{
			qprintf(s, "bfpga_open_bitfile: chunk header truncated\n\r");
			fclose(fd);
			return 0;
		}
	}
	
	if( (read=fread(readbuf, sizeof(char), 5, fd)) == 5 )
	{
		/* init pointer to keep track */
		cp = readbuf;
		
		/* Skip final chunk designator */
		cp++;
	
		/* compute config data size - modified for 16-bit int & char */
		*n = *cp++;
		*n <<= 8;
		*n += *cp++;
		*n <<= 8;
		*n += *cp++;
		*n <<= 8;
		*n += *cp++;
		qprintf(s, "bfpga_open_bitfile: config size = %ld\n\r", *n);
	}
	else
	{
		qprintf(s, "bfpga_open_bitfile: final chunk truncated\n\r");
		fclose(fd);
		return 0;
	}
	
	/* success */
	return fd;
}

/* Send a bitstream to the FPGA */
int bfpga2_cfg(bfpga *s, char *bitfile)
{
	FILE *fd;
    int read;
	long ct, n;
	unsigned char byte, rxbyte, dummybuf[READBUFSIZE];
	char readbuf[READBUFSIZE];

	/* open file or return error*/
	if(!(fd = bfpga_open_bitfile(s, bitfile, &n)))
	{
		qprintf(s, "bfpga2_cfg: open bitfile %s failed\n\r", bitfile);
		return 1;
	}
	else
	{
		qprintf(s, "bfpga2_cfg: found bitfile %s\n\r", bitfile);
	}

	/* Set FLASH_DRV */
	qprintf(s, "bfpga2_cfg: Setting OMAP -> FPGA cfg\n\r");
	bfpga2_i2c_pcf_wr(s,PCF_OMAP_FLASH_DRV,0);		// drive low
	
	/* pulse PROG_B low min 500 ns */
	bfpga2_i2c_pcf_wr(s,PCF_FPGA_PROG,0);			// drive low
	usleep(1);			// wait a bit
	
	/* Wait for INIT low */
	qprintf(s, "bfpga2_cfg: PROG low, Waiting for INIT low\n\r");
	while(bfpga2_i2c_pcf_rd(s,PCF_FPGA_INIT)==1)
	{
		asm volatile ("nop");	//"nop" means no-operation.  We don't want to do anything during the delay
	}
	
	/* Release PROG */
	bfpga2_i2c_pcf_wr(s,PCF_FPGA_PROG,1);			// set as hi
	
	/* Wait for INIT high */
	qprintf(s, "bfpga2_cfg: PROG high, Waiting for INIT high\n\r");
	while(bfpga2_i2c_pcf_rd(s,PCF_FPGA_INIT)==0)
	{
		asm volatile ("nop");	//"nop" means no-operation.  We don't want to do anything during the delay
	}

	/* wait 5us */
	usleep(5);
	qprintf(s, "bfpga2_cfg: Sending bitstream\n\r");
	
	/* Read file & send bitstream to FPGA via SPI */
	ct = 0;
	while( (read=fread(readbuf, sizeof(char), READBUFSIZE, fd)) > 0 )
	{
		/* Send bitstream */
		bfpga2_spi_txrx(s, (unsigned char *)readbuf, dummybuf, read);
		ct += read;
		
		/* diagnostic to track buffers */
		qprintf(s, ".");
		if(s->verbose)
			fflush(stdout);
		
		/* Check INIT - if low then fail */
		if(bfpga2_i2c_pcf_rd(s,PCF_FPGA_INIT)==0)
		{
			qprintf(s, "\n\rbfpga2_cfg: INIT low during bitstream send\n\r");
			fclose(fd);
			return 1;
		}
	}
	
	/* close file */
	qprintf(s, "\n\rbfpga2_cfg: sent %ld of %ld bytes\n\r", ct, n);
	qprintf(s, "bfpga2_cfg: bitstream sent, closing file\n\r");
	fclose(fd);
	
	/* send dummy data while waiting for DONE or !INIT */
 	qprintf(s, "bfpga2_cfg: sending dummy clocks, waiting for DONE or fail\n\r");
	byte = 0xFF;
	ct = 0;

// SPARTAN 3S200 size => M25P20 = 192kbyte
// SPARTAN 3S500 size => M25P40 = 384kbyte

#if 0
	while((bfpga2_i2c_pcf_rd(s,PCF_FPGA_DONE)==0) && (bfpga2_i2c_pcf_rd(s,PCF_FPGA_INIT)==1))
	{
		// Dummy - all ones 
		bfpga2_spi_txrx(s, &byte, &rxbyte, 1);
		ct++;
		/* diagnostic to track buffers */
		if (ct>MAX_DUMMY_CLOCK) {
			qprintf(s, "+");
			if(s->verbose)
				fflush(stdout);
		}
	}
 	qprintf(s, "bfpga2_cfg: %d dummy clocks sent\n\r", ct*8);
#endif		
	/* Clear FLASH_DRV */
	qprintf(s, "bfpga2_cfg: Setting FLASH -> FPGA cfg\n\r");
	bfpga2_i2c_pcf_wr(s,PCF_OMAP_FLASH_DRV,1);		// drive high
			
	/* return status */
	if(bfpga2_i2c_pcf_rd(s,PCF_FPGA_DONE)==0)
	{
		qprintf(s, "bfpga2_cfg: cfg failed - DONE not high\n\r");
		return 1;	// Done = 0 - error
	}
	else	
	{
		qprintf(s, "bfpga2_cfg: success\n\r");
		return 0;	// Done = 1 - OK
	}
}

/* Send a bitstream to the SPI Configuration Flash */
int bfpga2_pgm(bfpga *s, char *bitfile)
{
	int i, ct, read;
	long n;
	unsigned char txbuf[READBUFSIZE], rxbuf[READBUFSIZE], *cp;
	char *fcfg_fname = "flash_prog.bit";
	FILE *fd;
	
#if 0	
	/* send special flash cfg bitstream */
	qprintf(s, "bfpga2_cfg: sending flash cfg bitstream %s\n\r", fcfg_fname);
	if(bfpga2_cfg(s, fcfg_fname))
	{
		qprintf(s, "bfpga2_pgm: Error sending bitstream to FPGA\n");
		return 1;
	}
#endif

	/* Check flash memory ID */
	qprintf(s, "bfpga2_pgm: Read Flash ID:\n");
	txbuf[0] = FLASH_RDID;
	bfpga2_spi_txrx(s, txbuf, rxbuf, 21);
	qprintf(s, "MFG ID: 0x%02X\n", rxbuf[1]);
	qprintf(s, "DEV ID: 0x%02X 0x%02X\n", rxbuf[2], rxbuf[3]);
	cp = &rxbuf[1];
	
	qprintf(s, "bfpga2_pgm: found Flash ID\n\r");
	
	/* open the bitfile */
	if(!(fd = bfpga_open_bitfile(s, bitfile, &n)))
	{
		qprintf(s, "bfpga2_pgm: open bitfile %s failed\n\r", bitfile);
		return 1;
	}
	else
	{
		qprintf(s, "bfpga2_pgm: found bitfile %s\n\r", bitfile);
	}

	/* Erase the Flash */
	qprintf(s, "bfpga2_pgm: Sending WREN\n");
	txbuf[0] = FLASH_WREN;
	bfpga2_spi_txrx(s, txbuf, rxbuf, 1);
	
	qprintf(s, "bfpga2_pgm: Sending Bulk Erase\n");
	txbuf[0] = FLASH_BE;
	bfpga2_spi_txrx(s, txbuf, rxbuf, 1);
	txbuf[0] = FLASH_RDSR;
	txbuf[1] = 0x00;
	i = 0;
	do
	{
		bfpga2_spi_txrx(s, txbuf, rxbuf, 2);
		i++;
		usleep(5);
	}
	while(((rxbuf[1]&0x01) == 0x01) && (i < 30000));
	if(i == 30000)
	{
		qprintf(s, "bfpga2_pgm: Timed out waiting for Bulk Erase\n");
		fclose(fd);
		return 1;
	}
	qprintf(s, "bfpga2_pgm: Bulk Erase complete (%d checks)\n", i);
	
	/* Read file & send bitstream to flash via SPI */
	qprintf(s, "bfpga2_pgm: Sending PP\n");
	ct = 0;
	while( (read=fread(&txbuf[4], sizeof(char), 256, fd)) > 0 )
	{
		/* Send WREN */
		txbuf[0] = FLASH_WREN;
		bfpga2_spi_txrx(s, txbuf, rxbuf, 1);
	
		/* Tack on header */
		txbuf[0] = FLASH_PP;
		txbuf[1] = (ct>>16)&0xff;
		txbuf[2] = (ct>>8)&0xff;
		txbuf[3] = ct&0xff;
	
		/* Send PP & bitstream */
		bfpga2_spi_txrx(s, (unsigned char *)txbuf, rxbuf, read+4);
		ct += read;
		
		/* Wait for PP to complete */
		txbuf[0] = FLASH_RDSR;
		txbuf[1] = 0x00;
		i = 0;
		do
		{
			bfpga2_spi_txrx(s, txbuf, rxbuf, 2);
			i++;
			usleep(5);
		}
		while(((rxbuf[1]&0x01) == 0x01) && (i < 30000));
		if(i == 30000)
		{
			qprintf(s, "bfpga2_pgm: Timed out waiting for Page Program\n");
			fclose(fd);
			return 1;
		}
		
		/* diagnostic to track buffers */
		qprintf(s, ".");
		if(s->verbose)
			fflush(stdout);
	}
	qprintf(s, "bfpga2_pgm: Programmed %d bytes \n", ct);
	
	/* success */
	fclose(fd);
	return 0;
}

/* Clean shutdown of our FPGA interface */
void bfpga2_delete(bfpga *s)
{
	/* Release SPI bus */
	bfpga2_i2c_pcf_wr(s,PCF_FPGA_SPI_MODE,1);			// drive nOE line high
	qprintf(s, "bfpga2_init: OMAP off SPI bus\n");
		
	close(s->spi_file);		/* close the SPI device */
	close(s->i2c_file);		/* close the I2C device */
	free(s);				/* free the structure */
}
