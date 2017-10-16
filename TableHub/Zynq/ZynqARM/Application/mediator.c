#include "mediator.h"
#include "command_queue.h"
#include "fw_update.h"
#include "command_handler.h"
#include "send_receive.h"
#include "utility.h"
#include "string.h"
#include "audio_router.h"
#include "fw_update.h"
//#define DEBUG_CMD_EXEC
volatile int end_threads;
command_queue_t cmdQueueRX;

pthread_t * pthread_fw_update;
pthread_t * pthread_comm_exec_rx;
pthread_t * pthread_comm_check;
pthread_t * pthread_comm_die;
pthread_t * pthread_comm_poll_new;

//#define DEBUG_MSG_TEST

#ifdef DEBUG_MSG_TEST
#include <string.h>
int toogleMsg =0;
#endif


//#define MICPOD_DEVICE_TYPE		0x11
//#define TV_HUB_DEVICE_TYPE		0x12
//#define TABLE_HUB_DEVICE_TYPE	0x13
//#define MICPOD_HUB_DEVICE_TYPE	0x14
//#define STM32_DEVICE_TYPE		0x15
//#define PC_DEVICE_TYPE			0x16
int stopPoll=0;
void *thread_fw_update(void * data)
{
	int update_exec = 0;
	tdm_command_t TXcmd;
	printf("thread_fw_update begin\n");
	while(!end_threads)
	{

		//Check firmware update ready
		fw_update_state_e state = fw_update_get_state();
		if(state!=IDLE)
		{
			//TODO:
			//Check Ids
		}
		else
		{

		}
		while(state == SEND_DEV_FILE)
		{
			//send FW update to target device and/or update it

			if(end_threads)
				break;
			int type = fw_update_get_type();
			switch(type)
			{
				case (TABLE_HUB_DEVICE_TYPE):
				{
					//send ACK: file recieved and temporary written
					cmd_gen_fw_ack_flash(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID,&TXcmd);
					send_command( &TXcmd);
					//Update APP by replacing binary file in FS.
					fw_update_runTableHub_app_update();
					//Back waiting.
					fw_update_set_state(IDLE);
					break;
				}
				case (STM32_DEVICE_TYPE):
				{
					int id = fw_update_get_id();
					if(id==DEFAULT_TABLE_HUB_ID)
					{//update STM32 on Table Hub (here)

						//Stop serial connection towards STM32
						send_receive_deinit_stm32_serial();
						//Run STM32 update procedure via UART
						fw_update_runSTM32Updater();
						//Restart serial connection towards STM32
						send_receive_init_stm32_serial();
						//Set status to back waiting
						fw_update_set_state(IDLE);

						//Send STM32 FW update ACK (completed)
						cmd_gen_fw_ack_flash(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID,&TXcmd);
						send_command( &TXcmd);
					}
					else
					{//update STM32 on TV Hub					
						uint32_t sequence;
						uint8_t packet[MAX_DATA_LEN];
						uint32_t totalSequence = fw_update_get_total_seq();
						int id = fw_update_get_id();
						int len = fw_update_get_packet(packet, &sequence);

						//after getting FW update packet, generate FW update cmd
						cmd_gen_fw_update_packet(id, DEFAULT_TABLE_HUB_ID, packet,len, sequence,&TXcmd);
						int avail = command_queue_getAvailableCmdsNonBlock(&cmdQueueRX);
						while(avail>1)
						{
							//printTimeMs();
							sleep_ms(3);
							avail = command_queue_getAvailableCmdsNonBlock(&cmdQueueRX);
						}
						//printTimeMs();
						//add FW update cmd to queue
						command_queue_putCmd(&cmdQueueRX, &TXcmd, TAG_PROGRAM);

						if(sequence%20==0)
						{
							//update process percentage
							int perc = (sequence*100)/totalSequence;
							printf("Download from table hub to tv hub %d %d %% %d\n",id, perc, sequence);
							cmd_gen_fw_file_perc(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, perc,&TXcmd);
							command_queue_putCmd(&cmdQueueRX, &TXcmd, TAG_PROGRAM);
						}
					}
					break;
				}
				case (TV_HUB_DEVICE_TYPE):
				case (MICPOD_HUB_DEVICE_TYPE):
				case (MICPOD_DEVICE_TYPE):
				{
					uint32_t sequence;
					uint8_t packet[MAX_DATA_LEN];
					uint32_t totalSequence = fw_update_get_total_seq();
					int id = fw_update_get_id();

					int len = fw_update_get_packet(packet, &sequence);

					cmd_gen_fw_update_packet(id, DEFAULT_TABLE_HUB_ID, packet,len, sequence,&TXcmd);
					int avail = command_queue_getAvailableCmdsNonBlock(&cmdQueueRX);
					while(avail>1)
					{
						//printTimeMs();
						sleep_ms(3);
						avail = command_queue_getAvailableCmdsNonBlock(&cmdQueueRX);
					}

					//printTimeMs();
					command_queue_putCmd(&cmdQueueRX, &TXcmd, TAG_PROGRAM);

					if(sequence%20==19)
					{
						int perc = (sequence*100)/totalSequence;
						printf("Download from table hub to micpod (hub) %d %%\n",perc);
						cmd_gen_fw_file_perc(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, perc,&TXcmd);
						command_queue_putCmd(&cmdQueueRX, &TXcmd, TAG_PROGRAM);
					}

					//sequence++;
					//TODO:
					//gestire rollback
					break;
				}
			}
			state = fw_update_get_state();
		}

		if(state == CLOSE_DEV_FILE)
		{
			int id = fw_update_get_id();
			//generate FW update cmd end and queue it for the GUI
			cmd_gen_fw_update_end(DEFAULT_TABLE_HUB_ID, id, &TXcmd);
			command_queue_putCmd(&cmdQueueRX, &TXcmd, TAG_PROGRAM);
			fw_update_end_to_dev();

			//update % progress and queue it for the GUI
			cmd_gen_fw_file_perc(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, 100,&TXcmd);
			command_queue_putCmd(&cmdQueueRX, &TXcmd, TAG_PROGRAM);
		}

		if(state == WAIT_ERASE_FLASH)
		{
			//stop polling for new/present devices
			stopPoll=1;
		}
		else
		{
			stopPoll=0;
		}

		if(state== SEND_RESET)
		{
			int id = fw_update_get_id();
			//send reset cmd
			cmd_gen_fw_send_reset(DEFAULT_TABLE_HUB_ID, id, &TXcmd);
			command_queue_putCmd(&cmdQueueRX, &TXcmd, TAG_PROGRAM);
			printf("Send rst\n");
			
			//FW update status: IDLE
			fw_update_set_state(IDLE);
		}
		sleep_ms(10);
	}
	printf("thread_fw_update end\n");
}

void *thread_comm_exec_rx(void *data)
{
	printf("thread_comm_exec_rx begin\n");
	while(!end_threads)
	{
		tdm_command_t RXcmd;
		uint8_t tag;
		// check how many commands are ready to be decoded
		int numCmd = command_queue_getAvailableCmds(&cmdQueueRX);
		if(numCmd)
		{
//			printf("Queue full %d\n",numCmd);
			int err = command_queue_getCmd(&cmdQueueRX, &RXcmd,&tag);

			if(err==0)
			{
				//hand command to status cmd handler
				cmd_handler_status(&RXcmd, tag);
				//hand command to FW update cmd handler
				cmd_handler_fw_update(&RXcmd);

			}
			else
			{
				printf("Error: queue not empty but no command retreived.\n");
			}
		}
//		printf("Command received\n");
		sleep_ms(1);
//		printTimeMs();
	}
	printf("thread_comm_exec_rx end\n");
	return 0;
}


void *thread_comm_poll_new(void *data)
{
	printf("thread_comm_poll_new begin\n");
	int i,j;
	tdm_command_t command;
	system_status_t old_system;
	system_status_t new_system;
	//copy the current sys status in old_system
	system_status_get_all(&old_system);

	//vector interface list
	uint8_t listDev[3][MAX_INTERFACE_NUMBER];
	uint8_t listInt[3][MAX_INTERFACE_NUMBER];
	uint8_t *plistDev[3];
	uint8_t *plistInt[3];
	for(i=0; i<3; i++)
	{
		plistDev[i]=listDev[i];
		plistInt[i]=listInt[i];
	}
	int	listLen[3];

	int index[3];
	int stop[3];
	int phase=0;
	system_status_create_poll_new_list(plistDev, plistInt, listLen);
	int generate_audio_routing=0;
	while(!end_threads)
	{
		//copy the current sys status in new_system
		system_status_get_all(&new_system);
		
		//check if there's some difference in devices presence
		if(system_status_get_alive_death_diff(&old_system, &new_system))
		{
			printf("Changes on aliveness\n");
			generate_audio_routing=0;
			system_status_create_poll_new_list(plistDev, plistInt, listLen);
			for(i=0; i<3; i++)
			{

				index[i]=0;
				stop[i]=0;
				for(j=0; j<listLen[i]; j++)
				{
					//send interface disable command
					cmd_gen_set_slave_interface(listDev[i][j], DEFAULT_TABLE_HUB_ID,listInt[i][j], 0, &command);
					command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
					sleep_ms(10);
				}
				if(listLen[i]==0)
				{
					generate_audio_routing++;
					stop[i]=1;
				}
			}
		}
		else
		{
			if(generate_audio_routing<3)
			{

				for(i=0; i<3; i++)
				{
					if(stop[i]==0)
					{
						//enable all the interfaces
						cmd_gen_set_slave_interface(listDev[i][index[i]], DEFAULT_TABLE_HUB_ID,listInt[i][index[i]], 1, &command);
						command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
						//printf("Enable int\n");

						index[i]++;
						if(index[i]>=listLen[i])
						{
							generate_audio_routing++;
							stop[i]=1;
						}
					}
				}
				sleep_ms(100);
			}
			else if(generate_audio_routing==3)
			{
				generate_audio_routing++;
				system_status_set_rebuild_audio(1);
			}

			if(system_status_get_rebuild_audio())
			{
				system_status_set_rebuild_audio(0);
				//update audio source and audio routing tables
				system_status_update_audio_tables();

				//get the updated version of the system status
				system_status_get_all(&new_system);

				//update all the micpods
				for(i=0; i<7; i++)
				{
					if(new_system.micpods[i].alive>0)
					{
						cmd_gen_set_routing(new_system.micpods[i].id, DEFAULT_TABLE_HUB_ID,new_system.micpods[i].audio_table,&command);
						command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
					}
				}

				//update the micpod hubs
				for(i=0; i<3; i++)
				{
					if(new_system.micpod_hubs[i].alive>0)
					{
						cmd_gen_set_routing(new_system.micpod_hubs[i].id, DEFAULT_TABLE_HUB_ID,new_system.micpod_hubs[i].audio_table,&command);
						command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
					}
				}

				audio_router_set_table(new_system.table_hub.audio_table);
				uint8_t micListen = system_status_get_listen_micpod();
				
				//check if there's a micpod set on listen, otherwise, set it automatically
				if(micListen==0)
				{
					for(i= 0; i<MICPOD_MAX_N; i++)
					{
						if(new_system.micpods[i].alive>0)
						{
							system_status_set_listen_micpod(new_system.micpods[i].id);

							break;
						}

					}
				}
				else
				{
					generic_device_t * dev = system_status_get_device_from_id(micListen);
					if(dev==0)
					{
						int found=0;
						for(i= 0; i<MICPOD_MAX_N; i++)
						{
							if(new_system.micpods[i].alive>0)
							{
								system_status_set_listen_micpod(new_system.micpods[i].id);

								found=1;
								break;
							}
						}
						if(!found)
						{
							system_status_set_listen_micpod(0);

						}
					}

				}
				system_status_get_all(&new_system);

				//reset USB audio volume, locally or on the TV HUB
				if(new_system.table_hub.table_hub_specific.usb_source==USB_SRC_TABLE_HUB)
				{
					printf("Regenerating volume Table %d\n",new_system.table_hub.table_hub_specific.volume);
					cmd_gen_set_volume(0,DEFAULT_STM32_ID,new_system.table_hub.table_hub_specific.volume,&command);
					command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
				}
				else if(new_system.table_hub.table_hub_specific.usb_source==USB_SRC_TV_HUB)
				{
					printf("Regenerating volume TV %d\n",new_system.tv_hub.tv_hub_specific.volume);
					cmd_gen_set_volume(0,DEFAULT_STM32_ID+1,new_system.tv_hub.tv_hub_specific.volume,&command);
					command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
				}

				//send updated micpod status to the GUI
				for(i=0; i<MICPOD_MAX_N; i++)
				{
					cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, &new_system.micpods[i],i, &command);
					while(command_queue_getAvailableSpace(&cmdQueueRX)<3)
					{
						sleep_ms(1);
					}
					command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
				}

				//send updated micpod hub status to the GUI
				for(i=0; i<MICPOD_HUB_MAX_N; i++)
				{
					cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, &new_system.micpod_hubs[i],i, &command);
					while(command_queue_getAvailableSpace(&cmdQueueRX)<3)
					{
						sleep_ms(1);
					}
					command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
				}

				//send updated TV hub status to the GUI
				cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, &new_system.tv_hub,0, &command);
				while(command_queue_getAvailableSpace(&cmdQueueRX)<3)
				{
					sleep_ms(1);
				}
				command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);

				//send updated Table hub status to the GUI
				cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, &new_system.table_hub,0, &command);
				while(command_queue_getAvailableSpace(&cmdQueueRX)<3)
				{
					sleep_ms(1);
				}
				command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);

				//send status refresh command
				cmd_gen_dev_status_refresh(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, &command);
				while(command_queue_getAvailableSpace(&cmdQueueRX)<3)
				{
					sleep_ms(1);
				}
				command_queue_putCmd(&cmdQueueRX, &command, TAG_PROGRAM);
			}
		}
		memcpy(&old_system, &new_system, sizeof(system_status_t));
		sleep_ms(50);

	}
	printf("thread_comm_poll_new end\n");
	return 0;
}


void *thread_comm_die(void *data)
{
	printf("thread_comm_die begin\n");

	while(!end_threads)
	{
		if(!stopPoll)
		{	//check if any connected device has died/disconnected
			system_status_alive_dec();
		}
		sleep_ms(50);
	}
	printf("thread_comm_die end\n");
	return 0;
}

void *thread_comm_check(void *data)
{
	printf("thread_comm_check begin\n");
	while(!end_threads)
	{
		if(!stopPoll)
		{
			tdm_command_t pollCmd;
	//		printf("Generating poll\n");

			//add send poll existing devices command to queue
			cmd_gen_poll(DEFAULT_TABLE_HUB_ID,DEFAULT_BROADCAST_ID,&pollCmd);
			int err = command_queue_putCmd(&cmdQueueRX, &pollCmd, TAG_PROGRAM);

			if(err)
			{
				#ifdef DEBUG_CMD_EXEC
				printf("Queue full. Cannot add one more command.\n");
				#endif
			}
			sleep_ms(500);
		}
	}
	printf("thread_comm_check end\n");
	return 0;
}

void init_table_hub_mediator(void)
{
	end_threads=0;
	//init audio routing table
	audio_router_init();
	//init RX command queue
	command_queue_init(&cmdQueueRX);
	//init system status
	system_status_init(&cmdQueueRX);
	//init send/recv command over TDM
	send_receive_init(&cmdQueueRX);
	//init FW update parameters
	fw_update_init();

	//create FW update thread
	pthread_fw_update = NULL;
	thread_create(&pthread_fw_update, thread_fw_update, NULL,"fw_th");
	
	//create cmd executor thread (status + FW cmds)
	pthread_comm_exec_rx = NULL;
	thread_create(&pthread_comm_exec_rx, thread_comm_exec_rx, NULL,"exec_th");
	thread_set_priority(pthread_comm_exec_rx, SCHED_FIFO, 1);
	
	//create check connected device status thread
	pthread_comm_check = NULL;
	thread_create(&pthread_comm_check, thread_comm_check, NULL,"poll_th");
	
	//create update dead devices thread
	pthread_comm_die = NULL;
	thread_create(&pthread_comm_die, thread_comm_die, NULL,"die_th");
	
	//create poll new devices thread
	pthread_comm_poll_new = NULL;
	thread_create(&pthread_comm_poll_new, thread_comm_poll_new, NULL,"new_th");
	sleep_ms(1000);
	cmd_handler_init();
}


void deinit_table_hub_mediator(void)
{
	printf("deinit_table_hub_mediator begin\n");
	end_threads=1;

//	semaphore_post(cmdQueueRX.sem);
//	printf("semaphore post\n");
	thread_join(pthread_fw_update);
	thread_join(pthread_comm_check);
	thread_join(pthread_comm_die);
	thread_join(pthread_comm_poll_new);
	thread_join(pthread_comm_exec_rx);
	printf("Thread joined\n");
	fw_update_deinit();
	printf("FW deinit\n");
	send_receive_deinit();
	printf("Send receive deinit\n");
	command_queue_deinit(&cmdQueueRX);
	printf("Queue deinit\n");
	audio_router_deinit();
	printf("deinit_table_hub_mediator deinit finished\n");
}






