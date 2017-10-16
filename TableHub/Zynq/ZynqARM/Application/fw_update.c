#include "fw_update.h"
#include "md5.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include "commands.h"


#define FILE_NAME_STM32_ZIP			"/media/rootfs/USBaudio.hex.zip"
#define FILE_NAME_MICPOD_ZIP		"/media/rootfs/boot_mic_pod.bin.zip"
#define FILE_NAME_MICPOD_HUB_ZIP	"/media/rootfs/boot_mic_pod_hub.bin.zip"
#define FILE_NAME_TV_HUB_UPD_ZIP	"/media/rootfs/tv_hub_app_upd.zip"
#define FILE_NAME_TABLE_HUB_UPD_ZIP	"/media/rootfs/table_hub_app_upd.zip"

#define FILE_NAME_STM32_PLAIN			"/media/rootfs/USBaudio.hex"
#define FILE_NAME_MICPOD_PLAIN			"/media/rootfs/boot_mic_pod.bin"
#define FILE_NAME_MICPOD_HUB_PLAIN		"/media/rootfs/boot_mic_pod_hub.bin"
#define FILE_NAME_TV_HUB_UPD_PLAIN		"/media/rootfs/tv_hub_app_"
#define FILE_NAME_TABLE_HUB_UPD_PLAIN	"/media/rootfs/table_hub_app_"

#define FILE_RESET_APP_SCRIPT	"/media/rootfs/table_app_update.sh &"

fw_update_status_t fw_status;

//#define MICPOD_DEVICE_TYPE		0x11
//#define TV_HUB_DEVICE_TYPE		0x12
//#define TABLE_HUB_DEVICE_TYPE	0x13
//#define MICPOD_HUB_DEVICE_TYPE	0x14
//#define STM32_DEVICE_TYPE		0x15
//#define PC_DEVICE_TYPE			0x16

//this function checks if MD5 appended to the downloaded file 
//coincides with the computed one.
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

//init FW update procedure parameters
void fw_update_init()
{
	fw_status.state = IDLE;
	fw_status.fw_type = 0;
	fw_status.id = 0xFF;
	fw_status.fileNameZip = NULL;
	fw_status.fileNamePlain = NULL;
	fw_status.fid = NULL;
	fw_status.curr_sequence_num=0;
	fw_status.sequence=0;
	mutex_init(&fw_status.mutex);
}

void fw_update_deinit()
{
	mutex_deinit(fw_status.mutex);
}

//returns the current state of the FW update procedure
fw_update_state_e fw_update_get_state()
{
	return fw_status.state;
}

void fw_update_set_state(fw_update_state_e state)
{
	fw_status.state = state;
}

//prepares update file storing from recieved GUI command
int fw_update_start_from_gui(uint32_t packetsNumber, uint32_t packetSize, uint8_t dev_type)
{

	if(fw_status.state!=IDLE)
		return -1;
	fw_status.state = REC_GUI_FILE;
	fw_status.fw_type = dev_type;
	switch(fw_status.fw_type)
	{
		case (STM32_DEVICE_TYPE):
			fw_status.fileNameZip = FILE_NAME_STM32_ZIP;
			fw_status.fileNamePlain = FILE_NAME_STM32_PLAIN;
			break;
		case (MICPOD_DEVICE_TYPE):
			fw_status.fileNameZip = FILE_NAME_MICPOD_ZIP;
			fw_status.fileNamePlain = FILE_NAME_MICPOD_PLAIN;
			break;
		case (MICPOD_HUB_DEVICE_TYPE):
			fw_status.fileNameZip = FILE_NAME_MICPOD_HUB_ZIP;
			fw_status.fileNamePlain = FILE_NAME_MICPOD_HUB_PLAIN;
			break;
		case (TV_HUB_DEVICE_TYPE):
			fw_status.fileNameZip = FILE_NAME_TV_HUB_UPD_ZIP;
			fw_status.fileNamePlain = FILE_NAME_TV_HUB_UPD_PLAIN;
			break;
		case (TABLE_HUB_DEVICE_TYPE):
			fw_status.fileNameZip = FILE_NAME_TABLE_HUB_UPD_ZIP;
			fw_status.fileNamePlain = FILE_NAME_TABLE_HUB_UPD_PLAIN;
			break;
	}
	fw_status.fid = fopen(fw_status.fileNameZip, "wb");
	if(fw_status.fid ==0)
	{
		printf("File not found\n");
		printf("File name %s\n",fw_status.fileNameZip);
		return -1;
	}

	fw_status.curr_sequence_num=0;
	return 0;
}

//this function validates the FW update sequence number
int fw_update_validate_packet(uint32_t rxSeqNum, uint32_t *lastSeqNum)
{
	int ret=0;
	if(fw_status.curr_sequence_num+1==rxSeqNum)
	{
		fw_status.curr_sequence_num++;
		return ret;
	}
	else
	{
		*lastSeqNum = fw_status.curr_sequence_num;
		return -1;
	}
}

//this function stores the recieved GUI packet into file (composing FW file)
int fw_update_put_packet(uint8_t *buf, uint16_t packetSize)
{
	if(fw_status.state!=REC_GUI_FILE)
		return -1;
	return fwrite(buf , sizeof(uint8_t) , packetSize , fw_status.fid);
}

//Unizip and check MD5 on the downloaded and stored FW file
int fw_update_end_from_gui()
{
	if(fw_status.state!=REC_GUI_FILE)
		return -1;
	fclose(fw_status.fid);
	//Todo unzip
	char commandLine[200];
	printf("Unzipping file\n");
	sprintf(commandLine, "unzip -o -d /media/rootfs %s", fw_status.fileNameZip);
	system(commandLine);
	//system("sync");
	printf("Unzipping file finished\n");
	if(fw_update_check_md5(fw_status.fileNamePlain, "/tmp/dummy.bin"))
	{
		printf("Md5 wrong\n");
		fw_status.state=IDLE;
		return -1;
	}

	printf("Md5 correct\n");
	fw_status.state=IDLE;
	return 0;
}

int fw_update_get_type()
{
	return fw_status.fw_type;
}

int fw_update_get_id()
{
	return fw_status.id;
}

//update device update list for multiple FW update
void fw_update_init_dev_table(uint8_t * dev_id_list, int dev_num)
{
	int i;
	fw_status.dev_num=dev_num;
	for(i=0; i<dev_num; i++)
	{
		fw_status.dev_id_list[i]=dev_id_list[i];
		fw_status.dev_ack_list[i]=0;

	}

}

//update FW transfer ack status for specific device
void fw_update_set_ack(uint8_t dev_id, fw_update_state_e next_state)
{
	int i;
	int waiting_ack=0;
	for(i=0; i<fw_status.dev_num; i++)
	{
		if(fw_status.dev_id_list[i]==dev_id)
		{
			fw_status.dev_ack_list[i]=1;
		}
		else if(fw_status.dev_ack_list[i]==0)
		{

			waiting_ack=1;
		}
	}
	if(waiting_ack==0)
	{
		printf("no more waiting for ack: %d\n", next_state);
		fw_update_set_state(next_state);
		for(i=0; i<fw_status.dev_num; i++)
		{

			fw_status.dev_ack_list[i]=0;
		}
	}
	else
		printf("still waiting for ack\n");
}

//opens update file, checks how many packets are needed to be transferred
int fw_update_start_to_dev( uint8_t dev_type, uint8_t dev_id)
{

	if(fw_status.state!=IDLE)
	{
		printf("Error fw_update_start_to_dev: wrong previous state %d\n",fw_status.state);
		return -1;
	}

	fw_status.fw_type = dev_type;
	fw_status.id = dev_id;
	fw_status.sequence=0;
	fw_status.state = WAIT_ACK_START;

	switch(fw_status.fw_type)
	{
		case (STM32_DEVICE_TYPE):
			fw_status.fileNamePlain = FILE_NAME_STM32_PLAIN;
			break;
		case (MICPOD_DEVICE_TYPE):
			fw_status.fileNamePlain = FILE_NAME_MICPOD_PLAIN;
			break;
		case (MICPOD_HUB_DEVICE_TYPE):
			fw_status.fileNamePlain = FILE_NAME_MICPOD_HUB_PLAIN;
			break;
		case (TV_HUB_DEVICE_TYPE):
			fw_status.fileNamePlain = FILE_NAME_TV_HUB_UPD_PLAIN;
			break;
		case (TABLE_HUB_DEVICE_TYPE):
			fw_status.fileNamePlain = FILE_NAME_TABLE_HUB_UPD_PLAIN;
			break;
	}
	fw_status.fid = fopen(fw_status.fileNamePlain, "rb");
	if(fw_status.fid==0)
	{
		printf("Error in fw_update_start_to_dev. File not found: %s\n",fw_status.fileNamePlain);
		return -1;
	}
	fw_status.sequence=0;

	fseek(fw_status.fid,0,SEEK_END);
	int size = ftell(fw_status.fid);
	fseek(fw_status.fid,0,SEEK_SET);

	fw_status.packet_number = 1+(size/FW_UPDATE_PKT_SIZE);
	printf("fw_update_start_to_dev done: %s\n",fw_status.fileNamePlain);

	int i;
	fw_status.dev_num=1;
	fw_status.dev_id_list[0]=dev_id;
	return 0;
}

//read FW packet from file, update sequence tracking
int fw_update_get_packet(uint8_t *buf, uint32_t *sequence)
{
	int res = 0;
	if(fw_status.state!=SEND_DEV_FILE)
		return -1;
	mutex_lock(fw_status.mutex);
	res = fread(buf , sizeof(uint8_t) , FW_UPDATE_PKT_SIZE, fw_status.fid);
	if(res<FW_UPDATE_PKT_SIZE)
		fw_status.state = CLOSE_DEV_FILE;

	fw_status.sequence++;
	*sequence=fw_status.sequence;

	mutex_unlock(fw_status.mutex);
	return res;
}

//returns the overall packet number for file transfer
uint32_t fw_update_get_total_seq()
{
	return fw_status.packet_number;

}

//sets file read index for rollback handling (NACK on packet trasfer)
void fw_update_set_rollback(uint32_t sequence)
{
	mutex_lock(fw_status.mutex);
	fseek(fw_status.fid, sequence*FW_UPDATE_PKT_SIZE, SEEK_SET);
	fw_status.sequence=sequence;
	mutex_unlock(fw_status.mutex);
}

//close file read, and wait for device ack
int fw_update_end_to_dev()
{
	if(fw_status.state!=CLOSE_DEV_FILE)
		return -1;
	fclose(fw_status.fid);

	fw_status.state=WAIT_ACK_FILE;
	return 0;
}

//get updating device list
void fw_update_get_dev_table(uint8_t * dev_id_list, int *dev_num)
{
	int i;
	for(i=0; i<fw_status.dev_num; i++)
	{
		dev_id_list[i]=fw_status.dev_id_list[i];
	}
	*dev_num = fw_status.dev_num;
}

void fw_update_stm23_goto_bootloader(void);
void fw_update_stm23_exit_bootloader(void);


#define DEBUG_STM32_FW_UPDATE

//this function set STM32 pins to go to bootloader mode, runs STM32FLASHER for updating the firmware,
//resets the pins and device when complete
void fw_update_runSTM32Updater(void)
{
	char stringCmd[200];
	sprintf(stringCmd,"/media/rootfs/stm32flash.elf -w %s /dev/ttyUL0",fw_status.fileNamePlain);

	fw_update_stm23_goto_bootloader();
	system(stringCmd);
	fw_update_stm23_exit_bootloader();
}

//runs table hub update script: replace the updated version with the running binary.
void fw_update_runTableHub_app_update(void)
{
	system(FILE_RESET_APP_SCRIPT);
}

//sets BOOT0 pin and resets the MCU
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
//resets BOOT0 pin and resets the MCU
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



