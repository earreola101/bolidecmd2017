#ifndef COMMAND_PARSER_H__
#define COMMAND_PARSER_H__

#include <stdint.h>
#include "command_queue.h"

#ifdef __cplusplus
extern "C" {
#endif

int decodePacket(uint8_t * recvBuf, int * indexW, int * indexR, command_queue_t * queue);
int generatePacket(uint8_t *pDst, tdm_command_t *pSrc);

#ifdef __cplusplus
}
#endif

#endif


