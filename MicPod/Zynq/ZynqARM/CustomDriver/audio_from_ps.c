#include "audio_from_ps.h"
#include "utility.h"
#include "interrupt_controller.h"
#include "string.h"
//#define REG1_SIZE				0x4000
static uint16_t audio_from_ps_size				=	AUDIO_FROM_PS_MEM_SIZE;
static uint16_t audio_from_ps_half_size			=	AUDIO_FROM_PS_BUF_SIZE_MAX;
static uint16_t audio_from_ps_sample_per_buffer	=	AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX;

#define AUDIO_FROM_PS_OFF				(audio_from_ps_size<<16)
#define AUDIO_FROM_PS_ON				(AUDIO_FROM_PS_OFF|0x1)
#define AUDIO_FROM_PS_CLR_ON			(AUDIO_FROM_PS_ON|0x2)
#define AUDIO_FROM_PS_CLR_OFF			(AUDIO_FROM_PS_OFF|0x2)

int32_t * audio_from_ps_mem = 0;
u32 * audio_from_ps_reg = 0;
int audio_from_ps_intr_id = 0;

volatile int audio_from_ps_flag = 0;
volatile int audio_from_ps_position =0;

//this callback is triggered when some data is sent
void audio_from_ps_callback(void * data)
{
	audio_from_ps_size				=	AUDIO_FROM_PS_MEM_SIZE;
	audio_from_ps_half_size			=	AUDIO_FROM_PS_BUF_SIZE_MAX;
	audio_from_ps_sample_per_buffer	=	AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX;
	audio_from_ps_reg[1]=AUDIO_FROM_PS_CLR_ON;
	audio_from_ps_position = (audio_from_ps_reg[0]>>1)&0x01;
	if(audio_from_ps_position==0)
		audio_from_ps_position=1;
	else
		audio_from_ps_position=0;
	audio_from_ps_flag = 1;
	audio_from_ps_reg[1]=AUDIO_FROM_PS_ON;
	//printf("intr\n");
}

// this function connects the sending buffer filled event with the above callback
void audio_from_ps_init_intr(uint32_t reg_base_addr, uint32_t mem_base_addr, int intr_id)
{
	audio_from_ps_intr_id = intr_id;
	audio_from_ps_mem = (int32_t*)mem_base_addr;
	audio_from_ps_reg = (u32*)reg_base_addr;

	audio_from_ps_reg[1] = AUDIO_FROM_PS_CLR_OFF;
	sleep_ms(1);
	audio_from_ps_reg[1] = AUDIO_FROM_PS_OFF;
	interrupt_connect(audio_from_ps_intr_id,(void *)audio_from_ps_callback,0,8,RISING_EDGE);

}

// enables audio send interrupt
void audio_from_ps_init_start()
{
	interrupt_enable(audio_from_ps_intr_id);
	audio_from_ps_reg[1] = AUDIO_FROM_PS_ON;
}

// disables audio send interrupt
void audio_from_ps_init_stop()
{
	audio_from_ps_reg[1] = AUDIO_FROM_PS_CLR_OFF;
	sleep_ms(1);
	audio_from_ps_reg[1] = AUDIO_FROM_PS_OFF;
	interrupt_disable(audio_from_ps_intr_id);
}


//this function allows to copy the audio buffer to be sent into at defined memory address,
//ready to be send
int audio_from_ps_write_non_blocking(int32_t * pSrc)
{
	int i;
	if(!audio_from_ps_flag)
		return 0;


	for(i=0; i<audio_from_ps_sample_per_buffer; i++)
	{
		audio_from_ps_mem[audio_from_ps_position*audio_from_ps_sample_per_buffer+i]=pSrc[i];
	}
	audio_from_ps_flag=0;
	return audio_from_ps_sample_per_buffer;
}
