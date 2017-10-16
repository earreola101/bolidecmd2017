#ifndef __FWUPDATE_H__
#define __FWUPDATE_H__

#include <stdint.h>
#include <stdio.h>

#include "status.h"
#include "fw_update_def.h"
#include "utility.h"


#define FW_SEQ_NUM_OK						0
#define FW_UPDATE_FILE_PATH_SIZE			100
#define FW_UPDATE_FILE_PATH_ROOT_FOLDER 	"/home/root/"


typedef enum fw_update_state_e
{
	IDLE = 0,
	REC_GUI_FILE,
	REC_GUI_COMPLETE,
	OPEN_DEV_FILE,
	WAIT_ACK_START,
	SEND_DEV_FILE,
	CLOSE_DEV_FILE,
	WAIT_ACK_FILE,
	WAIT_ERASE_FLASH,
	WAIT_ACK_COMPLETE,
	SEND_RESET
}fw_update_state_e;

typedef struct fw_update_status_t
{
	fw_update_state_e state;
	int fw_type;
	uint8_t id;

	uint8_t dev_id_list[7];
	uint8_t dev_ack_list[7];
	int dev_num;
	char * fileNameZip;

	char * fileNamePlain;
	FILE * fid;
	uint32_t curr_sequence_num;
	uint32_t sequence;
	pthread_mutex_t * mutex;
	uint32_t packet_number;
}fw_update_status_t;

void fw_update_init();
void fw_update_deinit();
fw_update_state_e fw_update_get_state();
void fw_update_set_state(fw_update_state_e state);
uint32_t fw_update_get_total_seq();
int fw_update_start_from_gui(uint32_t packetsNumber, uint32_t packetSize, uint8_t dev_type);
int fw_update_validate_packet(uint32_t rxSeqNum, uint32_t *lastSeqNum);
int fw_update_put_packet(uint8_t *buf, uint16_t packetSize);
int fw_update_end_from_gui();
int fw_update_get_type();
int fw_update_get_id();
uint32_t fw_update_get_packet_size();
uint32_t fw_update_get_packet_number();
int fw_update_start_to_dev(uint8_t dev_type, uint8_t dev_id);
int fw_update_get_packet(uint8_t *buf, uint32_t *sequence);
int fw_update_end_to_dev();
void fw_update_set_rollback(uint32_t sequence);

void fw_update_runSTM32Updater(void);
void fw_update_runTableHub_app_update(void);

void fw_update_init_dev_table(uint8_t * dev_id_list, int dev_num);
void fw_update_get_dev_table(uint8_t * dev_id_list, int *dev_num);
void fw_update_set_ack(uint8_t dev_id, fw_update_state_e next_state);

#endif

