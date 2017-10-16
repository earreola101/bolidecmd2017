#ifndef AUDIO_FROM_PS_H__
#define AUDIO_FROM_PS_H__
#include "xparameters.h"
#include "xil_types.h"



//#define AUDIO_FROM_PS_MEM_BASE_ADDRESS 		XPAR_AUDIO_FROM_PS_AUDIO_FROM_PS_BRAM_CTRL_S_AXI_BASEADDR
//#define AUDIO_FROM_PS_REG_BASE_ADDRESS		XPAR_AUDIO_FROM_PS_AUDIO_FROM_PS_0_BASEADDR
//
//#define AUDIO_FROM_PS_IRQ 					(XPAR_FABRIC_AUDIO_FROM_PS_AUDIO_FROM_PS_0_INTR_INTR)


#define AUDIO_FROM_PS_MS_PER_BUF_MAX		8
#define AUDIO_FROM_PS_SAMPLE_FREQ			32000
#define AUDIO_FROM_PS_CH_NUM				8
#define AUDIO_FROM_PS_FRAME_PER_BUF_MAX		(AUDIO_FROM_PS_MS_PER_BUF_MAX*AUDIO_FROM_PS_SAMPLE_FREQ/1000)
#define AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX	(AUDIO_FROM_PS_FRAME_PER_BUF_MAX*AUDIO_FROM_PS_CH_NUM)
#define AUDIO_FROM_PS_BUF_SIZE_MAX			(AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX*4)
#define AUDIO_FROM_PS_MEM_SIZE				(AUDIO_FROM_PS_BUF_SIZE_MAX*2)





void audio_from_ps_init_intr(uint32_t reg_base_addr, uint32_t mem_base_addr, int intr_id);
void audio_from_ps_init_start();
void audio_from_ps_init_stop();
int audio_from_ps_write_non_blocking(int32_t * pSrc);



#endif
