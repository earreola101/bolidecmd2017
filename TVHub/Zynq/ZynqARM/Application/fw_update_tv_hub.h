#ifndef __FWUPDATE_TV_HUB_H__
#define __FWUPDATE_TV_HUB_H__

#include <stdint.h>
#include <stdio.h>

#include "status.h"

#include "utility.h"


void fw_update_start(char * file_path, uint8_t type);
int fw_update_validate_packet(uint32_t rxSeqNum, uint32_t *lastSeqNum);

int fw_update_put_packet(uint8_t *buf, uint16_t len);
int fw_update_end();
void fw_update_runSTM32Updater(void);
uint8_t fw_update_get_type(void);
void fw_update_runTvHub_app_update(void);
#endif

