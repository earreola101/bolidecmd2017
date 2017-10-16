#include "tv_hub_mediator.h"
#include "command_queue.h"
#include "command_handler_tv_hub.h"
#include "send_receive_tv_hub.h"
#include "utility.h"
#include "string.h"

#include "cs2000.h"
#include "version_module.h"
//#define DEBUG_CMD_EXEC
volatile int end_threads;
command_queue_t cmdQueueRX;

pthread_t * pthread_comm_exec_rx;
pthread_t * pthread_im_here_thread;


//#define DEBUG_MSG_TEST

#ifdef DEBUG_MSG_TEST
#include <string.h>
int toogleMsg =0;
#endif



void *thread_comm_exec_rx(void *data)
{
	printf("thread_comm_exec_rx begin\n");
	tdm_command_t RXcmd;
	uint8_t tag;
	uint8_t local_id = DEFAULT_UNINIT_ID;
	while(!end_threads)
	{


		if(!send_receive_get_tdm_locked())
		{
			cmd_handler_set_id(DEFAULT_UNINIT_ID);
			local_id = DEFAULT_UNINIT_ID;
		}

		local_id = cmd_handler_get_id();
		if(command_queue_getAvailableCmds(&cmdQueueRX))
		{

			int err = command_queue_getCmd(&cmdQueueRX, &RXcmd,&tag);
			if((tag==TAG_SERIAL_CMD)&&(RXcmd.sender!=DEFAULT_STM32_ID+1))
			{

				cmd_handler_route(&RXcmd);
			}
			else
			{
				if(RXcmd.receiver == DEFAULT_PC_ID)
				{
					cmd_handler_route(&RXcmd);
				}
				else if((RXcmd.receiver == local_id)||(RXcmd.receiver == DEFAULT_TV_HUB_ID)||(RXcmd.receiver == 0))
				{
					cmd_handler_status(&RXcmd, tag);
				}
				else
				{

					if(RXcmd.sender == local_id)
					{
						cmd_handler_status_out(&RXcmd, tag);
					}
				}

				if(RXcmd.receiver == local_id)
					cmd_handler_fw_update(&RXcmd);
			}
//			printf("Command received\n");
		}

		sleep_ms(1);
//		printTimeMs();
	}
	printf("thread_comm_exec_rx end\n");
	return 0;
}

void * im_here_thread(void * data)
{
	tdm_command_t TXcmd;
	while(!end_threads)
	{

		if(cmd_handler_get_id()==DEFAULT_UNINIT_ID)
		{

			if(send_receive_get_tdm_locked())
			{

				cmd_gen_im_here(TABLE_HUB_DEVICE_TYPE,fpga_get_dna(),TV_HUB_DEVICE_TYPE,&TXcmd);
				command_queue_putCmd(&cmdQueueRX, &TXcmd,TAG_PROGRAM);
			}
		}

		sleep_ms(200);
	}
	return 0;
}



void init_table_hub_mediator(void)
{
	end_threads=0;
	cs2000_init(BD_PLL_EXTERNAL, 1);
	//init UART to stm32 and TDM
	command_queue_init(&cmdQueueRX);
	//fw_update_initFwUpdateParams(&fwUpdateParams, 0, FW_UPDATE_PKT_SIZE);
	send_receive_init(&cmdQueueRX);
	pthread_comm_exec_rx = NULL;
	thread_create(&pthread_comm_exec_rx, thread_comm_exec_rx, NULL,"exec_th");
	sleep_ms(500);
	cmd_handler_init();
	sleep_ms(500);
	pthread_im_here_thread = NULL;
	thread_create(&pthread_im_here_thread, im_here_thread, NULL,"im_here");
}


void deinit_table_hub_mediator(void)
{
	printf("deinit_table_hub_mediator begin\n");
	end_threads=1;
	thread_join(pthread_comm_exec_rx);
	thread_join(pthread_im_here_thread);
	printf("Thread joined\n");
	printf("FW deinit\n");
	send_receive_deinit();
	printf("Send receive deinit\n");
	command_queue_deinit(&cmdQueueRX);
	cs2000_deinit();
	printf("deinit_table_hub_mediator deinit finished\n");
}






