#ifndef __FWUPDATE_H__
#define __FWUPDATE_H__

#include <stdint.h>
#include <stdio.h>
#include "fw_update_def.h"
#define FW_UPDATE_MAX_SIZE					(0x400000)
#define FW_SEQ_NUM_OK						0


/*Public functions*/
void fw_update_start();
int fw_update_validate_packet(uint32_t rxSeqNum, uint32_t *lastSeqNum);
int fw_update_put_packet(uint8_t *buf, int len);
int fw_update_end(uint32_t *sw_version, uint32_t *fpga_version);
int fw_update_execute(int * page, int *pagesCount, int *phase);

#endif

