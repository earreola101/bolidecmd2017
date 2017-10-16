#include "audio_driver.h"
int captureFid = -1;
int playFid = -1;
int audio_started=0;
#define DEBUG_AUDIO_DRIVER

//This function initializes the audio peripherals.
//Please note that the audio engine is not yet started.
int audio_driver_init()
{
	captureFid = open( "/dev/audio_to_ps", O_RDWR);
	if(captureFid<0)
	{
#ifdef DEBUG_AUDIO_DRIVER
		printf("Error: cannot find audio to ps driver\n");
#endif
		return -1;
	}
	playFid = open( "/dev/audio_from_ps", O_RDWR);
	if(playFid<0)
	{
#ifdef DEBUG_AUDIO_DRIVER
		printf("Error: cannot find audio from ps driver\n");
#endif
		return -1;
	}

	ioctl(captureFid, AUDIO_TO_PS_SET_ON_OFF,0);
	ioctl(captureFid, AUDIO_TO_PS_SET_BUF_LEN,AUDIO_TO_PS_MEM_SIZE);
	ioctl(playFid, AUDIO_FROM_PS_SET_ON_OFF,0);
	ioctl(playFid, AUDIO_FROM_PS_SET_BUF_LEN,AUDIO_FROM_PS_MEM_SIZE);
	audio_started=0;
	return 0;
}

void audio_driver_deinit()
{
	if(audio_started==1)
		audio_driver_stop();

	close(captureFid);
	close(playFid);
}

//This function enables audio play
//and capture
void audio_driver_start()
{
	ioctl(captureFid, AUDIO_TO_PS_SET_ON_OFF,1);
	ioctl(playFid, AUDIO_FROM_PS_SET_ON_OFF,1);
	audio_started=1;
}

//This function stops audio play
//and capture
void audio_driver_stop()
{
	ioctl(captureFid, AUDIO_TO_PS_SET_ON_OFF,0);
	ioctl(playFid, AUDIO_FROM_PS_SET_ON_OFF,0);
	audio_started=0;
}

//This function allows to capture AUDIO_TO_PS_BUF_SIZE_MAX bytes
//of audio from the peripheral
int audio_driver_read(int * pDst)
{
	return read(captureFid,pDst,AUDIO_TO_PS_BUF_SIZE_MAX);
}

//This function allows to play AUDIO_TO_PS_BUF_SIZE_MAX bytes
//of audio on the peripheral
int audio_driver_write(int * pSrc)
{
	return write(playFid,pSrc, AUDIO_FROM_PS_BUF_SIZE_MAX);
}
