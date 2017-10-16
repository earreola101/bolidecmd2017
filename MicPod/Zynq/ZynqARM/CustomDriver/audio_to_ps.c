#include "audio_to_ps.h"
#include "utility.h"
#include "interrupt_controller.h"
#include "string.h"
//#define REG1_SIZE				0x4000
static uint16_t audio_to_ps_size				=	AUDIO_TO_PS_MEM_SIZE;
static uint16_t audio_to_ps_half_size			=	AUDIO_TO_PS_BUF_SIZE_MAX;
static uint16_t audio_to_ps_sample_per_buffer	=	AUDIO_TO_PS_SAMPLE_PER_BUF_MAX;

#define AUDIO_TO_PS_OFF				(audio_to_ps_size<<16)
#define AUDIO_TO_PS_ON				(AUDIO_TO_PS_OFF|0x1)
#define AUDIO_TO_PS_CLR_ON			(AUDIO_TO_PS_ON|0x2)
#define AUDIO_TO_PS_CLR_OFF			(AUDIO_TO_PS_OFF|0x2)

int32_t * audio_to_ps_mem=0;
u32 * audio_to_ps_reg=0;

int audio_to_ps_intr_id = 0;

volatile int audio_to_ps_flag = 0;
volatile int audio_to_ps_position =0;

//this callback is triggered when some data is received
void audio_to_ps_callback(void * data)
{

	audio_to_ps_reg[1]=AUDIO_TO_PS_CLR_ON;
	audio_to_ps_position = (audio_to_ps_reg[0]>>1)&0x01;
	if(audio_to_ps_position==0)
		audio_to_ps_position=1;
	else
		audio_to_ps_position=0;


	audio_to_ps_flag = 1;
	audio_to_ps_reg[1]=AUDIO_TO_PS_ON;
	//printf("intr\n");
}

// this function connects the recieving buffer filled event with the above callback
void audio_to_ps_init_intr(uint32_t reg_base_addr, uint32_t mem_base_addr, int intr_id)
{
	audio_to_ps_intr_id = intr_id;
	audio_to_ps_mem = (int32_t*)mem_base_addr;
	audio_to_ps_reg = (u32*)reg_base_addr;
	audio_to_ps_size				=	AUDIO_TO_PS_MEM_SIZE;
	audio_to_ps_half_size			=	AUDIO_TO_PS_BUF_SIZE_MAX;
	audio_to_ps_sample_per_buffer	=	AUDIO_TO_PS_SAMPLE_PER_BUF_MAX;
	interrupt_connect(audio_to_ps_intr_id,(void *)audio_to_ps_callback,0,0,RISING_EDGE);


	audio_to_ps_reg[1] = AUDIO_TO_PS_CLR_OFF;
	sleep_ms(1);
	audio_to_ps_reg[1] = AUDIO_TO_PS_OFF;
}

// enables audio recv interrupt
void audio_to_ps_init_start()
{
	interrupt_enable(audio_to_ps_intr_id);
	audio_to_ps_reg[1] = AUDIO_TO_PS_ON;
}

// disables audio recv interrupt
void audio_to_ps_init_stop()
{
	audio_to_ps_reg[1] = AUDIO_TO_PS_CLR_OFF;
	sleep_ms(1);
	audio_to_ps_reg[1] = AUDIO_TO_PS_OFF;
	interrupt_disable(audio_to_ps_intr_id);
}

//this function allows to copy the recieved audio buffer to pDst 
int audio_to_ps_read_non_blocking(int32_t * pDst)
{
	int i;
	if(!audio_to_ps_flag)
		return 0;

	for(i=0; i<audio_to_ps_sample_per_buffer; i++)
	{
		pDst[i]=audio_to_ps_mem[audio_to_ps_position*audio_to_ps_sample_per_buffer+i];
	}
	audio_to_ps_flag=0;
	return audio_to_ps_sample_per_buffer;
}
