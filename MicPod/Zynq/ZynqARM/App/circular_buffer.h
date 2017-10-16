#ifndef CIRCULAR_BUFFER_H__
#define CIRCULAR_BUFFER_H__
#include "stdint.h"

#define CIRCULAR_MS_PER_BUF_MAX			8
#define CIRCULAR_SAMPLE_FREQ			32000
#define CIRCULAR_CH_NUM					8
#define CIRCULAR_SLOTS					3
#define CIRCULAR_FRAME_PER_BUF_MAX		(CIRCULAR_MS_PER_BUF_MAX*CIRCULAR_SAMPLE_FREQ/1000)
#define CIRCULAR_SAMPLE_PER_BUF_MAX		(CIRCULAR_FRAME_PER_BUF_MAX*CIRCULAR_CH_NUM)
#define CIRCULAR_SAMPLE_MAX				(CIRCULAR_SAMPLE_PER_BUF_MAX*CIRCULAR_SLOTS)

typedef struct
{
	int  started;
	int32_t buffer[CIRCULAR_SAMPLE_MAX];
	int idxW;
	int idxR;
} bd_circBuf_t;

int circBuf_availableSpace(bd_circBuf_t *c);
int circBuf_availableSamples(bd_circBuf_t *c);
void circBuf_init(bd_circBuf_t *c);

int circBufPushI(bd_circBuf_t *c, int32_t *data, int size);
int circBufPopI(bd_circBuf_t *c, int32_t *data, int size);
int circBufPushF(bd_circBuf_t *c, float *data, int size);
int circBufPopF(bd_circBuf_t *c, float *data, int size);
#endif
