#include "audio_router.h"

u32 * audio_routing_reg=0;
int audio_ch_num=0;
void audio_routing_init(u32 base_addr, int ch_num)
{
	audio_routing_reg = (u32 *)base_addr;
	audio_ch_num =ch_num;
}
void audio_routing_set(u8 *routing_table)
{
	int i=0;

	for(i=0; i<audio_ch_num; i++)
	{
		audio_routing_reg[i/4]&=~(0xFF<<(8*(i%4)));
		audio_routing_reg[i/4]|=routing_table[i]<<(8*(i%4));
	}
}
