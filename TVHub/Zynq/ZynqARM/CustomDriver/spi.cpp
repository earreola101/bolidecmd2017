#include "spi.h"
#include "utility.h"

/*
    spidevlib.c - A user-space program to comunicate using spidev.
                Gustavo Zamboni
*/
#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>


struct spi_ioc_transfer xfer[2];
int spi_fid=-1;

int spi_init()
{
	int file;
	__u8    mode, lsb, bits;
	__u32 speed=2500000;

	if ((file = open("/dev/spidev0.0",O_RDWR)) < 0)
	{
		printf("[SPI] Failed to open the bus.\n");
		/* ERROR HANDLING; you can check errno to see what went wrong */
		return -1;
	}


	if (ioctl(file, SPI_IOC_RD_MODE, &mode) < 0)
	{
		printf("[SPI] rd_mode\n");
		return -1;
	}
	if (ioctl(file, SPI_IOC_RD_LSB_FIRST, &lsb) < 0)
	{
		printf("[SPI] rd_lsb_fist\n");
		return -1;
	}

	if (ioctl(file, SPI_IOC_RD_BITS_PER_WORD, &bits) < 0)
	{
		printf("[SPI] bits_per_word\n");
		return -1;
	}

	if (ioctl(file, SPI_IOC_RD_MAX_SPEED_HZ, &speed) < 0)
	{
		printf("[SPI] max_speed_hz\n");
		return -1;
	}
	printf("[SPI] Init: mode %d, %d bits per word, %d Hz max\n", mode, bits, speed);
    xfer[0].delay_usecs = 0;
    xfer[0].speed_hz = 2500000;
    xfer[0].bits_per_word = 8;
    spi_fid = file;
    return 0;
}

void spi_deinit()
{
	close(spi_fid);
}

void spi_write(uint8_t add, uint8_t regNum, uint8_t value)
{
	//BTRACE << "[SPI] Write " << (int)add << " " << (int)regNum << " " << (int)value;
    unsigned char   buf[3];
    int status;
    buf[0] = add;
    buf[1] = regNum;
    buf[2] = value;

    xfer[0].tx_buf = (unsigned long)buf;
    xfer[0].len = 3;
    status = ioctl(spi_fid, SPI_IOC_MESSAGE(1), xfer);
    if (status < 0)
	{
    	printf("[SPI] ioctl error\n");
		return;
	}
}

