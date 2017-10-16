#include "fw_update_zynq.h"
#include "fw_update_def.h"
#include "qspi_flash.h"
#include "md5.h"
#define DEFAULT_FW_FLASH_STARTING_ADDR	0x00000000

uint8_t fw_ram_loc[FW_UPDATE_MAX_SIZE];
uint32_t flashAddr = DEFAULT_FW_FLASH_STARTING_ADDR;

int write_addr_Zynq = 0;


uint32_t currentSequenceNumberZynq;
void fw_update_start()
{
	currentSequenceNumberZynq = 0;
	write_addr_Zynq = 0;
}

int fw_update_validate_packet(uint32_t rxSeqNum, uint32_t *lastSeqNum)
{
	if(currentSequenceNumberZynq+1==rxSeqNum)
	{
		currentSequenceNumberZynq++;
		return 0;
	}
	else
	{
		if(rxSeqNum<=currentSequenceNumberZynq)
			return -1;

		*lastSeqNum = currentSequenceNumberZynq;
		return -1;
	}
}


int fw_update_put_packet(uint8_t *buf, int len)
{
	int i;
	for(i=0; i<len; i++)
	{
		fw_ram_loc[write_addr_Zynq]=buf[i];
		write_addr_Zynq++;
		if(write_addr_Zynq>=FW_UPDATE_MAX_SIZE)
		{
			printf("FW update error: max size reached\n");
			return -1;
		}
	}
	return 0;
}
int fw_update_check_md5_ram(uint8_t *buf, int len)
{
	char md5File[MD5_LENGTH];
	char * md5Computed;
	int i;
	for(i=0; i<MD5_LENGTH; i++)
	{
		md5File[i]=buf[len-MD5_LENGTH+i];
	}

	MD5 md5;
	md5Computed = md5.digestMemory(buf, len-MD5_LENGTH);
	int ret=0;
	for(i=0; i<MD5_LENGTH; i++)
	{
		if(md5File[i]!=md5Computed[i])
		{
			ret=1;
			break;
		}
	}
	if(ret!=0)
	{
		for(i=0; i<MD5_LENGTH; i++)
		{
			printf("%d: rec 0x%x calc 0x%x\n", i, md5File[i], md5Computed[i]);
		}
		return -1;
	}
	return 0;

}

int fw_update_end(uint32_t *sw_version, uint32_t *fpga_version)
{
	int i;
	int ret = fw_update_check_md5_ram(fw_ram_loc, write_addr_Zynq);
	if(ret!=0)
		return ret;

	memcpy(sw_version, &fw_ram_loc[write_addr_Zynq-(MD5_LENGTH+FW_VER_LENGTH)], 4);
	memcpy(fpga_version, &fw_ram_loc[write_addr_Zynq-(MD5_LENGTH+FW_VER_LENGTH)+4], 4);


	for(i=0; i<MD5_LENGTH+FW_VER_LENGTH; i++)
	{
		fw_ram_loc[write_addr_Zynq-(MD5_LENGTH+FW_VER_LENGTH)+i]=0xFF;
	}


	return 0;
}


int fw_update_execute(int * page, int *pagesCount, int *phase)
{
	if(*phase==0)
	{
		qspi_flash_init();
		*pagesCount = (write_addr_Zynq/PAGE_SIZE)+1;
		qspi_flash_erase(DEFAULT_FW_FLASH_STARTING_ADDR, (PAGE_SIZE*(*pagesCount)));
		*phase = 2;
		*page = 0;

	}
	else if(*phase<4)
	{
		if(*page<*pagesCount)
			qspi_flash_write((*page * PAGE_SIZE)+DEFAULT_FW_FLASH_STARTING_ADDR, PAGE_SIZE, &fw_ram_loc[*page * PAGE_SIZE]);
		else
			*phase = 3;
		//printf("Download to FLASH: %.1f %%\n", (double)(((float)page/(float)pagesCount)*100));
		*page = *page+1;
	}

	return 0;
}

