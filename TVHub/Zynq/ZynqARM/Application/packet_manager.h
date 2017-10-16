#ifndef COMMAND_MANAGER_H__
#define COMMAND_MANAGER_H__

#include "commands.h"

int packet_manager_generate_packet(uint8_t *pDst, tdm_command_t *pSrc);
int packet_manager_check_header(uint8_t * buffer_read, int * index_read);
int packet_manager_check_payload(uint8_t * buffer_src, uint8_t * buffer_dst, int * index_read, int expectedPayloadBytes);
int packet_manager_tdm_decode(tdm_command_t * pDst, uint8_t *pSrc, int len);

#endif
