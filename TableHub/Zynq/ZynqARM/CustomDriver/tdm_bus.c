/*
 * serial.c
 *
 *  Created on: Apr 21, 2017
 *      Author: bdsound
 */

#include "tdm_bus.h"
#include <sys/ioctl.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>             //Used for UART
#include <fcntl.h>              //Used for UART
#include <termios.h>        //Used for UART
#include <time.h>
#include <string.h>
#include <poll.h>
#include "utility.h"


#define BUS_IOC_MAGIC 'y'
#define BUS_IOC_MAXNR 2


#define BUS_SET_BUF_DIR _IOW(BUS_IOC_MAGIC,1,unsigned int)
#define BUS_GET_LOCK _IOR(BUS_IOC_MAGIC,1,unsigned int)

int tdm_bus_init(const char * dev)
{
	int fid = open(dev, O_RDWR);
	return fid;
}

void tdm_bus_deinit(int fid)
{
	close(fid);
}

int tdm_bus_write(int fid, uint8_t * buf, int len)
{
	return write(fid, buf, len);
}

int tdm_bus_read(int fid, uint8_t * buf, int maxLen)
{
	return read(fid,buf,maxLen);
}

void tdm_bus_set_dir(int fid, int dir)
{
	ioctl(fid, BUS_SET_BUF_DIR, dir);
}

unsigned int tdm_bus_get_locked(int fid)
{
	unsigned int lock;
	ioctl(fid, BUS_GET_LOCK, &lock);
	return lock;
}
