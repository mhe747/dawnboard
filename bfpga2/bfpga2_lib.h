/* bfpga2_lib.h - Beagle FPGA board access library                            */
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

#ifndef __bfpga2_lib__
#define __bfpga2_lib__

#include <stdint.h>
#include <linux/types.h>

#define I2C_SLAVE	0x0703	/* Change slave address			*/
#define I2C_SMBUS	0x0720	/* SMBus-level access */
#define I2C_SMBUS_READ	1
#define I2C_SMBUS_WRITE	0
#define I2C_SMBUS_BYTE		    1
#define I2C_SMBUS_BYTE_DATA	    2 

/* 
 * Data for SMBus Messages 
 */
#define I2C_SMBUS_BLOCK_MAX	32	/* As specified in SMBus standard */	
#define I2C_SMBUS_I2C_BLOCK_MAX	32	/* Not specified but we use same structure */
union i2c_smbus_data {
	__u8 byte;
	__u16 word;
	__u8 block[I2C_SMBUS_BLOCK_MAX + 2]; /* block[0] is used for length */
	                                            /* and one more for PEC */
};

/* This is the structure as used in the I2C_SMBUS ioctl call */
struct i2c_smbus_ioctl_data {
	char read_write;
	__u8 command;
	int size;
	union i2c_smbus_data *data;
};

/* PCF8574 I/O bit definitions */
#define PCF_FPGA_INIT 7			/* reads cfg progress - leave set high */ 
#define PCF_FPGA_DONE 6			/* high for success - leave set high */
#define PCF_FPGA_PROG 5			/* starts cfg - pulse low to begin */
#define PCF_FPGA_SPI_MODE 4		/* drive low to enable OMAP onto SPI bus */
#define PCF_OMAP_FLASH_DRV 3	/* drive low to read/write SPI Flash */
#define PCF_LVS_C_DIR 2			/* mcbsp3 dx dir */ 
#define PCF_LVS_E_DIR 1			/* mcbsp3 fsx dir */ 
#define PCF_LVS_F_DIR 0			/* mcbsp3 dr dir */ 

/* M25P20 Instructions */
#define FLASH_WREN 0x06			/* Write Enable */
#define FLASH_WRDI 0x04			/* Write Disable */
#define FLASH_RDID 0x9f			/* Read ID register */
#define FLASH_RDSR 0x05			/* Read Status register */
#define FLASH_WRSR 0x01			/* Write Status register */
#define FLASH_READ 0x03			/* Read */
#define FLASH_FAST_READ 0x0B	/* Fast Read */
#define FLASH_PP 0x02			/* Page Program */
#define FLASH_SE 0xD8			/* Sector Erase */
#define FLASH_BE 0xC7			/* Bulk Erase */

/* state structure */
typedef struct
{
	int i2c_file;		/* I2C device */
	int spi_file;		/* SPI device */
	int verbose;		/* Verbose level */
} bfpga;

#define READBUFSIZE 512

int bfpga2_i2c_get_prom(bfpga *s, int saddr, __u8 loc);
int bfpga2_i2c_set_prom(bfpga *s, int saddr, __u8 loc, __u8 dat);
int bfpga2_i2c_get(bfpga *s, int saddr);
int bfpga2_i2c_set(bfpga *s, int saddr, __u8 dat);
int bfpga2_i2c_pcf_rd(bfpga *s, int bit);
void bfpga2_i2c_pcf_wr(bfpga *s, int bit, int val);
int bfpga2_i2c_set_freq(bfpga *s, int freq);
int bfpga2_spi_txrx(bfpga *s, uint8_t *tx, uint8_t *rx, __u32 len);
bfpga *bfpga2_init(int i2c_bus, int spi_bus, int spi_add, int verbose);
FILE *bfpga_open_bitfile(bfpga *s, char *bitfile, long *n);
int bfpga2_cfg(bfpga *s, char *bitfile);
int bfpga2_pgm(bfpga *s, char *bitfile);
void bfpga2_delete(bfpga *s);

#endif
