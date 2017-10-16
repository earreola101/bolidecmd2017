

#include "audio_router.h"
int audio_router_fid=-1;

int audio_router_init()
{
	int i;
	audio_router_fid = open( "/dev/audio_router", O_RDWR);
	if(audio_router_fid<0)
	{
		return -1;
	}
	//Init channel table
	uint8_t table[AUDIO_ROUTER_CH_NUM];
	for(i=0; i<AUDIO_ROUTER_CH_NUM; i++)
	{
		table[i]=i;
	}
	return audio_router_set_table(table);
}

void audio_router_deinit()
{
	if(audio_router_fid<0)
		return;
	close(audio_router_fid);
}

int audio_router_set_table(uint8_t * pSrc)
{
	return write(audio_router_fid,pSrc, AUDIO_ROUTER_CH_NUM);
}
