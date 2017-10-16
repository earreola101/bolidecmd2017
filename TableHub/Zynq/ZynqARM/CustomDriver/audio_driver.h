#ifndef AUDIO_DRIVER_H__
#define AUDIO_DRIVER_H__

#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>


#define AUDIO_TO_PS_MS_PER_BUF_MAX		2
#define AUDIO_TO_PS_SAMPLE_FREQ			32000
#define AUDIO_TO_PS_CH_NUM				16
#define AUDIO_TO_PS_FRAME_PER_BUF_MAX	(AUDIO_TO_PS_MS_PER_BUF_MAX*AUDIO_TO_PS_SAMPLE_FREQ/1000)
#define AUDIO_TO_PS_SAMPLE_PER_BUF_MAX	(AUDIO_TO_PS_FRAME_PER_BUF_MAX*AUDIO_TO_PS_CH_NUM)
#define AUDIO_TO_PS_BUF_SIZE_MAX		(AUDIO_TO_PS_SAMPLE_PER_BUF_MAX*4)
#define AUDIO_TO_PS_MEM_SIZE			(AUDIO_TO_PS_BUF_SIZE_MAX*2)

#define AUDIO_FROM_PS_MS_PER_BUF_MAX		2
#define AUDIO_FROM_PS_SAMPLE_FREQ			32000
#define AUDIO_FROM_PS_CH_NUM				4
#define AUDIO_FROM_PS_FRAME_PER_BUF_MAX		(AUDIO_FROM_PS_MS_PER_BUF_MAX*AUDIO_FROM_PS_SAMPLE_FREQ/1000)
#define AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX	(AUDIO_FROM_PS_FRAME_PER_BUF_MAX*AUDIO_FROM_PS_CH_NUM)
#define AUDIO_FROM_PS_BUF_SIZE_MAX			(AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX*4)
#define AUDIO_FROM_PS_MEM_SIZE				(AUDIO_FROM_PS_BUF_SIZE_MAX*2)


#define AUDIO_TO_PS_IOC_MAGIC 'x'
#define AUDIO_TO_PS_IOC_MAXNR 2
#define AUDIO_TO_PS_SET_BUF_LEN _IOW(AUDIO_TO_PS_IOC_MAGIC,1,unsigned int)
#define AUDIO_TO_PS_SET_ON_OFF _IOW(AUDIO_TO_PS_IOC_MAGIC,2,unsigned int)

#define AUDIO_FROM_PS_IOC_MAGIC 'z'
#define AUDIO_FROM_PS_IOC_MAXNR 2
#define AUDIO_FROM_PS_SET_BUF_LEN _IOW(AUDIO_FROM_PS_IOC_MAGIC,1,unsigned int)
#define AUDIO_FROM_PS_SET_ON_OFF _IOW(AUDIO_FROM_PS_IOC_MAGIC,2,unsigned int)

int audio_driver_init();
void audio_driver_deinit();
void audio_driver_start();
void audio_driver_stop();


int audio_driver_read(int * pDst);
int audio_driver_write(int * pSrc);

#endif

