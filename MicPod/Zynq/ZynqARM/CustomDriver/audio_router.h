#ifndef AUDIO_ROUTER_H__
#define AUDIO_ROUTER_H__
#include "xil_types.h"



void audio_routing_init(u32 base_addr, int ch_num);
void audio_routing_set(u8 *routing_table);


#endif
