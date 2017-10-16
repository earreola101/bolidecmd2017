#ifndef AUDIO_ROUTER_H__
#define AUDIO_ROUTER_H__

#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>

#define AUDIO_ROUTER_CH_NUM 15

int audio_router_init();

void audio_router_deinit();
int audio_router_set_table(uint8_t * pSrc);

#endif
