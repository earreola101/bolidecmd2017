#include "version_module.h"
#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>

uint32_t stm_version = 0;
uint32_t sw_get_version()
{
	return SW_VERSION;
}

uint32_t fpga_get_version()
{
	int fid = open( "/dev/version_module", O_RDWR);
	uint32_t reg[3];
	read(fid,reg,12);
	close(fid);
	return reg[0];
}
uint64_t fpga_get_dna()
{
	int fid = open( "/dev/version_module", O_RDWR);
	uint32_t reg[3];
	read(fid,reg,12);
	close(fid);

	uint64_t auxVal = reg[2];
	auxVal = (auxVal << 32)&0xFFFFFFFF00000000;
	auxVal |= reg[1];
	return auxVal;
}
uint32_t linux_get_version()
{
	FILE * fid = fopen("/home/root/repo_version.h","rt");
	if(fid==0)
	{
		printf("Linux version file not found\n");
		return 0xFFFFFFFF;
	}
	char word1[40],word2[40];
	int version;
	fscanf (fid, "%s %s %d", word1,word2,&version);
	//printf("Linux version file: %s %s %d\n", word1,word2,version);
	fclose(fid);
	return version;
}

void get_version_struct(dev_info_t * ver)
{
	ver->sw_version = sw_get_version();
	ver->fpga_version = fpga_get_version();
	ver->fpga_unique_id = fpga_get_dna();
	ver->linux_version = linux_get_version();
	ver->stm_version = stm_version;
}
void set_stm_version(uint32_t ver)
{
	stm_version = ver;
}
