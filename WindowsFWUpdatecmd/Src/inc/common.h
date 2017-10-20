#ifndef COMMON_H__
#define COMMON_H__

#include <stdint.h>
#include <stdio.h>

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
#define CMD_QUEUE_LENGHT	100

#define MAX_DATA_LEN 		(MAX_MESSAGE_LEN-COMMAND_OVERHEAD)
#define TDM_COMMAND_SUCCESS	0
#define TDM_COMMAND_ERROR	(-1)

#define CMD_QUEUE_LENGHT	100

#define FW_UPDATE_PKT_SIZE					512
#define FW_SEQ_NUM_OK						0
#define FW_UPDATE_FILE_PATH_SIZE			100
#define FW_UPDATE_FILE_PATH_ROOT_FOLDER 	"/home/root/"

typedef struct fwUpdateParams_t
{
	char filePath[FW_UPDATE_PKT_SIZE];
	FILE *fwFileptr;

	uint32_t packetsNumber;
	uint32_t packetSize;

	uint32_t sequenceNumber;

}fwUpdateParams_t;

typedef struct tdm_command_t
{
	uint16_t command;
	uint8_t sender;
	uint8_t receiver;
	uint32_t sequenceNum;
	uint16_t len;
	uint8_t data[MAX_DATA_LEN];

}tdm_command_t;

typedef struct command_queue_t {

	tdm_command_t commands[CMD_QUEUE_LENGHT];
	uint16_t cmdWIndex;
	uint16_t cmdRIndex;
	uint16_t availCmds;

} command_queue_t;


/*Command list*/
// Dummy
#define CMD_DUMMY_CMD			0xFF01

//FW update
#define CMD_FW_UPDATE_START 	0x0F01
#define CMD_FW_UPDATE_END		0x0F02
#define CMD_FW_UPDATE_PKT	 	0x0F03
#define CMD_FW_UPDATE_ACK	 	0x0F04
#define CMD_FW_UPDATE_NACK	 	0x0F05

#define DATA_FW_UPDATE_SUCC		0xE1
#define DATA_FW_UPDATE_MD5_ERR	0xE2

#endif // BOLIDE_H
