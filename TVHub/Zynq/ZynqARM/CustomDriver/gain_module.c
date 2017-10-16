#include "gain_module.h"
#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>



void set_gain(float gain)
{
	int fid = open( "/dev/gain_module", O_RDWR);
	if(fid<0)
	{
		printf("Error opening gain module\n");
		return;
	}

	uint32_t reg;
	reg = (uint32_t)(gain*4095.0f);

//	printf("setting gain to %f -> %x -> %d\n",gain, reg, reg);
	write(fid,&reg,4);
	close(fid);
}
