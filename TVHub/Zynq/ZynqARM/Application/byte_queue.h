#ifndef BYTE_QUEUE_H__
#define BYTE_QUEUE_H__

#include "commands.h"

#ifdef __cplusplus
extern "C" {
#endif
/*Bytes on TTY management*/
void byte_queue_check_index(int * index);
int byte_queue_incr_index(int index);
int byte_queue_get_avail_bytes(int indexR, int indexW);

#ifdef __cplusplus
}
#endif

#endif
