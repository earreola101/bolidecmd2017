#ifndef COMMANDS_H__
#define COMMANDS_H__

#include <stdint.h>
#include <stdio.h>

//#define TDM_BUS_TEST


#define HEADER_BYTES	2
#define HEADER_0		0x55
#define HEADER_1		0xAA

#define LEN_BYTES		2
#define CRC_BYTES		1

#define PACKET_OVERHEAD		(HEADER_BYTES+LEN_BYTES+CRC_BYTES)
#define COMMAND_OVERHEAD	10

#define MAX_PACKET_LEN		1024
#define MAX_MESSAGE_LEN 	(MAX_PACKET_LEN-PACKET_OVERHEAD)
#define RX_QUEUE_LEN 		(MAX_PACKET_LEN*4)


#ifdef __linux
#define CMD_QUEUE_LENGHT	10//0
#elif defined STM32F40XX
#define CMD_QUEUE_LENGHT	4
#else
#define CMD_QUEUE_LENGHT	10
#endif

#define MAX_DATA_LEN 		(MAX_MESSAGE_LEN-COMMAND_OVERHEAD)
#define TDM_COMMAND_SUCCESS	0
#define TDM_COMMAND_ERROR	(-1)


#define FW_UPDATE_PKT_SIZE					512
#define FW_SEQ_NUM_OK						0
#define FW_UPDATE_FILE_PATH_SIZE			100
#define FW_UPDATE_FILE_PATH_ROOT_FOLDER 	"/home/root/"

typedef struct tdm_command_t
{
	uint16_t command;
	uint8_t sender;
	uint8_t receiver;
	uint32_t sequence;
	uint16_t len;
	uint8_t data[MAX_DATA_LEN];

}tdm_command_t;




/*Command list*/
//General commands
#define CMD_POLL				0x0001
#define CMD_ALIVE				0x0002
#define CMD_ACK 				0x0003
#define CMD_IM_HERE 			0x0004
#define CMD_GET_SYS_STATUS	 	0x0005
#define CMD_SYS_STATUS_ANS 		0x0006
#define CMD_SET_DEVICE_ID		0x0007
#define CMD_SEND_CPU_LOAD		0x0008
#define CMD_SEND_DEBUG_MSG		0x0009
#define CMD_GET_DEV_INFO		0x000A
#define CMD_RET_DEV_INFO		0x000B
#define CMD_DEV_STATUS_ANS 		0x000C
#define CMD_TOO_MANY_DEV_ERROR 	0x000D
#define CMD_DEV_STATUS_REFRESH  0x000E
#define CMD_DEV_USB_AUDIO_CONN	0x000F
#define CMD_SET_USB_AUDIO_SRC	0x0010
#define CMD_STOP_ASKING			0x0011
#define CMD_RET_STM_VER			0x0012

//FW update commands
#define CMD_FW_UPDATE_START 		0x0F01
#define CMD_FW_UPDATE_END			0x0F02
#define CMD_FW_UPDATE_PKT	 		0x0F03
#define CMD_FW_DOWNL_START	 		0x0F04
//#define CMD_FW_UPDATE_NACK	 		0x0F05
#define CMD_FW_UPDATE_START_ZYNQ 	0x0F06
#define CMD_FW_UPDATE_ACK_PACKET 	0x0F07
#define CMD_FW_UPDATE_NACK_PACKET 	0x0F08
#define CMD_FW_UPDATE_ACK_FILE 		0x0F09
#define CMD_FW_UPDATE_NACK_FILE 	0x0F0A
#define CMD_FW_UPDATE_ACK_FLASH 	0x0F0B
#define CMD_FW_UPDATE_NACK_FLASH 	0x0F0C
#define CMD_FW_UPDATE_ACK_START 	0x0F0D
#define CMD_FW_UPDATE_NACK_START 	0x0F0E
#define CMD_FW_UPDATE_PERC_FLASH 	0x0F0F
#define CMD_FW_DOWNL_ACK_START 		0x0F10
#define CMD_FW_DOWNL_NACK_START 	0x0F11
#define CMD_FW_UPDATE_PERC_FILE		0x0F12
#define CMD_FW_SEND_RESET			0x0F13


//FW update define
#define DATA_FW_UPDATE_SUCC		0xE1
#define DATA_FW_UPDATE_MD5_ERR	0xE2

//Micpod commands
#define CMD_SET_LED_MICPOD	 	0x0E01
#define CMD_SET_MUTE_MICPOD 	0x0E02
#define CMD_INFO_MUTE_MICPOD 	0x0E03
#define CMD_GET_LED_MICPOD	 	0x0E04
#define CMD_SET_POST_FILER_EN	0x0E05

//Routing commands
#define CMD_SET_ROUTING			0x0201 //v
#define CMD_SET_SLAVE_INTERFACE 0x0202
#define CMD_INFO_INTERFACE_LOCK 0x0203

//Audio commands
#define CMD_MUTE_SYSTEM			0x0301
#define CMD_SET_DEBUG_MODE		0x0302
#define CMD_SET_LISTEN_MODE		0x0303
#define CMD_SET_DEBUG_FILE		0x0304
#define CMD_SET_CH_PLAY			0x0305
#define CMD_SET_SIGNAL_GEN		0x0306
#define CMD_SET_VOLUME			0x0307
// Dummy
#define CMD_DUMMY_CMD			0xFF01







#endif // BOLIDE_H
