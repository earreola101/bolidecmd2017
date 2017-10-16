#include "fw_update_tv_hub.h"
#include "md5.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include "commands.h"

uint32_t currentSequenceNumberZynq;

char fw_upd_file_name[100];
FILE * fw_upd_fid=0;
uint8_t fw_upd_type=0;
#define FILE_RESET_APP_SCRIPT	"/media/rootfs/tv_app_update.sh &"

int fw_update_check_md5(char * filePath, char * tmpFile)
{
	char md5File[MD5_LENGTH];
	char * md5Computed;
	char auxBuf[1000];

	//get md5
	FILE * fid = fopen(filePath, "rb");
	fseek(fid, -MD5_LENGTH, SEEK_END);
	fread(md5File, sizeof(char), MD5_LENGTH,fid);
	fclose(fid);

	//get file len
	fid = fopen(filePath, "rb");
	fseek(fid, 0L, SEEK_END);
	int totLen = ftell(fid);
	fclose(fid);

	totLen = totLen-MD5_LENGTH;

	fid = fopen(filePath, "rb");
	FILE *fidW = fopen(tmpFile, "wb");
	int countByte =0;
	while(1)
	{
		int res = fread(auxBuf, sizeof(char), 1000, fid);
		countByte+=res;
		if(countByte<totLen)
		{
			fwrite(auxBuf, sizeof(char), res, fidW);
		}
		else
		{
			countByte-=res;
			res = totLen-countByte;
			fwrite(auxBuf, sizeof(char), res, fidW);
			break;
		}
	}
	fclose(fid);
	fclose(fidW);


	MD5 md5;
	md5Computed = md5.digestFile(tmpFile);

	int ret=0, i;
	for(i=0; i<MD5_LENGTH; i++)
	{
		if(md5File[i]!=md5Computed[i])
		{
			ret=1;
			break;
		}
	}

	for(i=0; i<MD5_LENGTH; i++)
	{
		printf("%d: rec 0x%x calc 0x%x\n", i, md5File[i], md5Computed[i]);
	}

	if(ret!=0)
		return -1;
	return 0;

}

void fw_update_start(char * file_path, uint8_t type)
{
	fw_upd_type = type;
	currentSequenceNumberZynq = 0;
	fw_upd_fid = fopen(file_path,"wb");
	strcpy(fw_upd_file_name,file_path);
	if(fw_upd_fid==0)
		printf("error opening file\n");
	else
		printf("file open ok\n");


}
uint8_t fw_update_get_type(void)
{
	return fw_upd_type;
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

int fw_update_put_packet(uint8_t *buf, uint16_t len)
{
	int res =fwrite(buf,1,len,fw_upd_fid);
	printf("Written %d byte\n",res);
	return 0;
}

int fw_update_end()
{

	fclose(fw_upd_fid);
	fw_upd_fid=0;

	if(fw_update_check_md5(fw_upd_file_name, "/tmp/dummy.bin"))
	{

		return -1;
	}


	return 0;
}

void fw_update_stm23_goto_bootloader(void);
void fw_update_stm23_exit_bootloader(void);


#define DEBUG_STM32_FW_UPDATE


void fw_update_runSTM32Updater(void)
{
	char stringCmd[200];
	sprintf(stringCmd,"/media/rootfs/stm32flash.elf -w %s /dev/ttyUL0",fw_upd_file_name);

	fw_update_stm23_goto_bootloader();
	system(stringCmd);
	fw_update_stm23_exit_bootloader();
}


void fw_update_runTvHub_app_update(void)
{
	system(FILE_RESET_APP_SCRIPT);
}

void fw_update_stm23_goto_bootloader(void)
{
	system("echo 0 > /sys/class/gpio/gpio192/value");
	system("echo 1 > /sys/class/gpio/gpio193/value");
	sleep_ms(300);	//wait for STM32 to get into bootloader
	system("echo 0 > /sys/class/gpio/gpio193/value");
	sleep_ms(300);	//wait for STM32 to get into bootloader
#ifdef DEBUG_STM32_FW_UPDATE
	printf("bootloader mode on STM32.");
#endif

}

void fw_update_stm23_exit_bootloader(void)
{
	system("echo 1 > /sys/class/gpio/gpio192/value");
	system("echo 1 > /sys/class/gpio/gpio193/value");
	sleep_ms(300);	//wait for STM32 to get out of bootloader
	system("echo 0 > /sys/class/gpio/gpio193/value");

#ifdef DEBUG_STM32_FW_UPDATE
	printf("Normal mode on STM32.");
#endif

}



