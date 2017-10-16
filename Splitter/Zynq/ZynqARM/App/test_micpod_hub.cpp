

#include "interrupt_controller.h"
#include "tdm_bus_driver.h"
#include "test_micpod_hub.h"
#include "utility.h"
#include "stdio.h"
#include "bus_router_driver_micpod_hub.h"
#include "spi_driver.h"
#include "cs2000.h"
#include "audio_router.h"
#include "stdlib.h"
#include "packet_manager.h"
#include "command_gen_dec.h"
#include "gpios_micpod_hub.h"
#include "command_queue.h"
#include "version_driver.h"
#include "fw_update_zynq.h"
command_queue_t cmd_queue;
int blinking = 0;
int led_vals = 0xF;
uint8_t id = DEFAULT_UNINIT_ID;
tdm_command_t commandRx;
uint8_t msg_rx[1024];
void HandlerRxBus(void *CallbackRef)
{


	tdm_bus_t * data = (tdm_bus_t *)CallbackRef;
	int len= tdm_bus_receive(data, msg_rx);
	if(len!=0)
	{
		//printf("message received from %d\n",data->inst_num);
		if(command_queue_getAvailableSpace(&cmd_queue))
		{

				if(packet_manager_tdm_decode(&commandRx, msg_rx, len)==0)
				{
					if((commandRx.receiver==0x00)||(commandRx.receiver==id))
					{
						command_queue_putCmd(&cmd_queue, &commandRx, 0);
					}
				}
				else
					printf("Decode error\n");

		}
		else
		{
			printf("Queue full\n");
		}
	}
	else
		printf("no receive\n");
//
//	return 0;
}

#include "xscuwdt.h"
#define WDT_LOAD_VALUE		0x1000000
int zynq_reset()
{
	XScuWdt_Config *ConfigPtr;
	int Count = 0;
	XScuWdt Watchdog;
	ConfigPtr = XScuWdt_LookupConfig(XPAR_SCUWDT_0_DEVICE_ID);
	int Status = XScuWdt_CfgInitialize(&Watchdog, ConfigPtr,ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	XScuWdt_SetWdMode(&Watchdog);
	XScuWdt_LoadWdt(&Watchdog, WDT_LOAD_VALUE);
	XScuWdt_Start(&Watchdog);
	while(1)
	{

	}
	return 0;
}

int send_command(tdm_bus_t * bus,tdm_command_t * command)
{
	uint8_t pkt_tx[1024];
	int pktLen = packet_manager_generate_packet(pkt_tx,command);
	return tdm_bus_send_blocking(bus,pkt_tx,pktLen);
}

tdm_command_t aux_command;

int executeFWupdate = 0;
int fwWaitForRecover = 0;
int fwUpdateStarted = 0;
int page=0;
int pagesCount=0;
int phase=0;



int hub_locked = 0;
int slave_locked[3];

int current_hub_bus = SEL_HUB_0;
int current_hub_int = 0;


tdm_bus_t tdm_inst;
bus_router_t bus_router_inst;

cust_timer_t timer_id;
cust_timer_t timer_blink;
cust_timer_t timer_hub;

spi_driver_t spi_inst;
tdm_command_t command;
int main()
{
	int i;
	slave_locked[0]=0;
	slave_locked[1]=0;
	slave_locked[2]=0;
	executeFWupdate = 0;
	enable_caches();

	printf("\n\n\n\n\nMicpod hub app started\n");
	printf("SW version %lu\n",sw_get_version());
	printf("FPGA version %lu\n",fpga_get_version());
	printf("FPGA unique id 0x%llx\n",fpga_get_dna());
	command_queue_init(&cmd_queue);
	interrupt_init();

	//GPIO
	gpios_micpodhub_init(GPIOS_ID);
	leds_micpodhub_init(LED_OFFSET);
	//CS2000
	spi_driver_init(&spi_inst);
	cs2000_init(&spi_inst,CS2000_EXTERNAL,1);

	//BUS
	bus_router_init(&bus_router_inst,BUS_ROUTER_BASE_ADDR);
	audio_routing_init(AUDIO_ROUTING_REG_ADDR, AUDIO_CH_NUMBER);
	tdm_bus_init_intr(&tdm_inst,TX_BUS_ADDR,RX_BUS_ADDR,COMM_BUS_ADDR,RX_BUS_INTR_ID,(void *)HandlerRxBus);


	//Audio
	timer_init(&timer_hub);
	timer_init(&timer_blink);
	timer_init(&timer_id);
	timer_reset(&timer_id);
	timer_start(&timer_id);
	timer_reset(&timer_blink);
	timer_start(&timer_blink);
	timer_reset(&timer_hub);
	timer_start(&timer_hub);

	int oldLeds=0xF;
	leds_micpodhub_set_mask(0x0);


	u8 routing_table[AUDIO_CH_NUMBER];
	for(i=0; i<AUDIO_CH_NUMBER; i++)
		routing_table[i]=i;
	audio_routing_set(routing_table);


	bus_router_set_dir0(&bus_router_inst, DIR_RX);
	bus_router_set_dir1(&bus_router_inst, DIR_RX);
	bus_router_set_dir2(&bus_router_inst, DIR_RX);
	bus_router_set_dir3(&bus_router_inst, DIR_RX);

	while(1)
	{
		if(blinking)
		{

			if(timer_get_elapsed_ms(&timer_blink)>500)
			{
				if(led_vals==0)
					led_vals=0xFF;
				else
					led_vals=0;

				leds_micpodhub_set_mask(led_vals);
				timer_reset(&timer_blink);
				timer_start(&timer_blink);
			}
		}
		//bus
		if(timer_get_elapsed_ms(&timer_hub)>100)
		{

			if(hub_locked==0)
			{
				executeFWupdate = 0;
				fwWaitForRecover = 0;
				fwUpdateStarted = 0;
				page=0;
				pagesCount=0;
				phase=0;
				slave_locked[0]=0;
				slave_locked[1]=0;
				slave_locked[2]=0;
				id = DEFAULT_UNINIT_ID;
				if(tdm_bus_is_hub_locked(&tdm_inst))
				{
					hub_locked=1;

					if(current_hub_bus==SEL_HUB_0)
					{
						leds_micpodhub_set(0,1);
						leds_micpodhub_set(1,1);
						bus_router_set_tx0(&bus_router_inst,CONNECT_TX_HUB);
						bus_router_set_tx1(&bus_router_inst,BUS_SILENT);
						bus_router_set_tx2(&bus_router_inst,BUS_SILENT);
						bus_router_set_tx3(&bus_router_inst,BUS_SILENT);
						if(current_hub_int==SEL_RJ_0)
						{

							bus_router_set_dir1(&bus_router_inst, DIR_TX);
						}
						else
						{
							bus_router_set_dir0(&bus_router_inst, DIR_TX);
						}
						bus_router_set_dir2(&bus_router_inst, DIR_TX);
						bus_router_set_dir3(&bus_router_inst, DIR_RX);
						bus_router_set_rx1_sel(&bus_router_inst,SEL_RJ_2);
					}
					else
					{
						leds_micpodhub_set(2,1);
						leds_micpodhub_set(3,1);
						bus_router_set_tx0(&bus_router_inst,BUS_SILENT);
						bus_router_set_tx1(&bus_router_inst,CONNECT_TX_HUB);
						bus_router_set_tx2(&bus_router_inst,BUS_SILENT);
						bus_router_set_tx3(&bus_router_inst,BUS_SILENT);
						if(current_hub_int==SEL_RJ_2)
						{
							bus_router_set_dir3(&bus_router_inst, DIR_TX);
						}
						else
						{
							bus_router_set_dir2(&bus_router_inst, DIR_TX);
						}
						bus_router_set_dir0(&bus_router_inst, DIR_TX);
						bus_router_set_dir1(&bus_router_inst, DIR_RX);
						bus_router_set_rx0_sel(&bus_router_inst,SEL_RJ_0);
					}

					printf("Receiver %d locked and promoted to hub\n",current_hub_bus);

//					timer_reset(&timer_id);
//					timer_start(&timer_id);
				}
				else
				{

					if(current_hub_bus==SEL_HUB_0)
					{
						if(current_hub_int==SEL_RJ_1)
						{
							current_hub_bus=SEL_HUB_1;
							current_hub_int=SEL_RJ_2;
						}
						else
						{
							current_hub_int=SEL_RJ_1;
						}

					}
					else
					{
						if(current_hub_int==SEL_RJ_3)
						{
							current_hub_bus=SEL_HUB_0;
							current_hub_int=SEL_RJ_0;

						}
						else
						{
							current_hub_int=SEL_RJ_3;
						}
					}
					if(current_hub_bus==SEL_HUB_0)
						bus_router_set_rx0_sel(&bus_router_inst, current_hub_int);
					else
						bus_router_set_rx1_sel(&bus_router_inst, current_hub_int);
					bus_router_set_hub_sel(&bus_router_inst, current_hub_bus);
				}


			}
			else
			{

				if(!tdm_bus_is_hub_locked(&tdm_inst))
				{
					timer_reset(&timer_id);
					timer_start(&timer_id);
					leds_micpodhub_set_mask(0x0);
					bus_router_set_dir0(&bus_router_inst, DIR_RX);
					bus_router_set_dir1(&bus_router_inst, DIR_RX);
					bus_router_set_dir2(&bus_router_inst, DIR_RX);
					bus_router_set_dir3(&bus_router_inst, DIR_RX);

					hub_locked=0;
					slave_locked[0]=0;
					slave_locked[1]=0;
					slave_locked[2]=0;
					id=DEFAULT_UNINIT_ID;

//					leds_set_mask(0xFF);
					bus_router_set_tx0(&bus_router_inst,BUS_SILENT);
					bus_router_set_tx1(&bus_router_inst,BUS_SILENT);
					bus_router_set_tx2(&bus_router_inst,BUS_SILENT);
					bus_router_set_tx3(&bus_router_inst,BUS_SILENT);

					current_hub_bus	=	SEL_HUB_0;
					current_hub_int	= 	SEL_RJ_0;


					bus_router_set_rx0_sel(&bus_router_inst, SEL_RJ_0);
					bus_router_set_rx1_sel(&bus_router_inst, SEL_RJ_2);
					bus_router_set_hub_sel(&bus_router_inst, current_hub_bus);
					printf("Hub unlocked\n");
				}
			}
			timer_reset(&timer_hub);
			timer_start(&timer_hub);
		}

		if(hub_locked)
		{
			for(i=0; i<3; i++)
			{
				if(slave_locked[i]==0)
				{
					if(tdm_bus_is_slave_locked(&tdm_inst,i))
					{
						if(i==0)
						{
							if(current_hub_bus==SEL_HUB_0)
								leds_micpodhub_set(3,1);
							else
								leds_micpodhub_set(1,1);
						}
						slave_locked[i]=1;

						//leds_set(i,1);

						cmd_gen_info_interface_lock(DEFAULT_TABLE_HUB_ID,id,i,1,&aux_command);
						send_command(&tdm_inst,&aux_command);
						printf("Slave %d locked\n", i);
					}
				}
				else
				{
					if(!tdm_bus_is_slave_locked(&tdm_inst,i))
					{
						slave_locked[i]=0;
						if(i==0)
						{
							if(current_hub_bus==SEL_HUB_0)
								leds_micpodhub_set(3,0);
							else
								leds_micpodhub_set(1,0);
						}
						//leds_set(i,0);
						cmd_gen_info_interface_lock(DEFAULT_TABLE_HUB_ID,id,i,0,&aux_command);
						send_command(&tdm_inst,&aux_command);
						printf("Slave %d unlocked\n", i);
					}
				}
			}
			if(id==DEFAULT_UNINIT_ID)
			{
				if(timer_get_elapsed_ms(&timer_id)>20)
				{
					 timer_stop(&timer_id);
					 cmd_gen_im_here(DEFAULT_TABLE_HUB_ID,fpga_get_dna(), MICPOD_HUB_DEVICE_TYPE,&aux_command);
					 send_command(&tdm_inst,&aux_command);
					 timer_reset(&timer_id);
					 timer_start(&timer_id);
					 printf("Send Im here\n");
				}

				//if(timeout elapsed)
				//send I'm here sender 0xFF, unique id, tipo (micpod) timout
				if(command_queue_getAvailableCmds(&cmd_queue))
				{
					uint8_t tag;
					command_queue_getCmd(&cmd_queue, &command, &tag);
					if(command.receiver==DEFAULT_UNINIT_ID)
					{
						if(command.command==CMD_SET_DEVICE_ID)
						{
							uint64_t unique_id;
							uint8_t aux_id;
							cmd_dec_set_id(&unique_id, &aux_id, &command);
							if(unique_id==fpga_get_dna())
							{
								id=aux_id;
								printf("Set id: %d\n",id);

							}
							else
							{
								printf("Set id: unique id wrong\n");
							}
							dev_info_t dev_info;
							get_version_struct(&dev_info);
							cmd_gen_ret_dev_info(id,command.sender, &dev_info, &aux_command);
							send_command(&tdm_inst,&aux_command);
						}
					}
				}
			}
			else
			{
				if(command_queue_getAvailableCmds(&cmd_queue))
				{
					uint8_t tag;
					command_queue_getCmd(&cmd_queue, &command, &tag);
					if((command.receiver==id)||(command.receiver==0))
					{
						switch(command.command)
						{
							case (CMD_POLL):
								//printf("Received poll from rx\n");
								cmd_gen_alive(id,command.sender,&aux_command);
								send_command(&tdm_inst,&aux_command);
								break;
							case (CMD_GET_DEV_INFO):
							{
								dev_info_t dev_info;
								get_version_struct(&dev_info);
								cmd_gen_ret_dev_info(id,command.sender, &dev_info, &aux_command);
								send_command(&tdm_inst,&aux_command);
								break;
							}
							case (CMD_SET_SLAVE_INTERFACE):
							{
								uint8_t intNum;
								uint8_t en;

								cmd_dec_set_slave_interface(&intNum, &en, &command);
								if(en==1)
								{
//									printf("Received enable interface %d\n", intNum);

									if(current_hub_bus==SEL_HUB_0)
									{
										switch(intNum)
										{
										case 0:
											leds_micpodhub_set(2,1);
											bus_router_set_tx1(&bus_router_inst,CONNECT_RX_0);
											break;
										case 1:
											bus_router_set_tx2(&bus_router_inst,CONNECT_RX_0);
											break;
										case 2:
											bus_router_set_tx3(&bus_router_inst,CONNECT_RX_0);
											break;
										default:
											printf("Error: wrong interface number\n");
											break;
										}
									}
									else
									{
										switch(intNum)
										{
										case 0:
											leds_micpodhub_set(0,1);
											bus_router_set_tx0(&bus_router_inst,CONNECT_RX_1);
											break;
										case 1:
											bus_router_set_tx2(&bus_router_inst,CONNECT_RX_1);
											break;
										case 2:
											bus_router_set_tx3(&bus_router_inst,CONNECT_RX_1);
											break;
										default:
											printf("Error: wrong interface number\n");
											break;
										}
									}

								}
								else
								{
//									printf("Received disable interface %d\n", intNum);
									if(current_hub_bus==SEL_HUB_0)
									{
										switch(intNum)
										{
										case 0:
											leds_micpodhub_set(2,0);
											bus_router_set_tx1(&bus_router_inst,BUS_SILENT);
											break;
										case 1:
											bus_router_set_tx2(&bus_router_inst,BUS_SILENT);
											break;
										case 2:
											bus_router_set_tx3(&bus_router_inst,BUS_SILENT);
											break;
										default:
											printf("Error: wrong interface number\n");
											break;
										}
									}
									else
									{
										switch(intNum)
										{
										case 0:
											leds_micpodhub_set(0,0);
											bus_router_set_tx0(&bus_router_inst,BUS_SILENT);
											break;
										case 1:
											bus_router_set_tx2(&bus_router_inst,BUS_SILENT);
											break;
										case 2:
											bus_router_set_tx3(&bus_router_inst,BUS_SILENT);
											break;
										default:
											printf("Error: wrong interface number\n");
											break;
										}
									}
								}
								break;
							}

							case (CMD_SET_ROUTING):
								printf("Received set routing\n");
								cmd_dec_set_routing(routing_table, &command);
								audio_routing_set(routing_table);
								break;
							case (CMD_FW_UPDATE_START):
							{
								printf("FW update start\n");
								//prende i parametri dell'update
								uint8_t dev_type;
								uint8_t auxId;

								cmd_dec_fw_update_start(&dev_type, &auxId,&command);
								if(dev_type==MICPOD_HUB_DEVICE_TYPE)
								{
									//TODO:
									//attiva un timeout nel caso vada tutto a rotoli
									fw_update_start();
									cmd_gen_fw_ack_start(id,command.sender,&aux_command);
									send_command(&tdm_inst,&aux_command);
									fwUpdateStarted = 1;
								}
								break;
							}

							case (CMD_FW_UPDATE_PKT):
							{
								if(fwUpdateStarted)
								{
									uint8_t packet[MAX_DATA_LEN];
									uint16_t packetSize;
									uint32_t packetSequence;
									cmd_dec_fw_update_packet(packet, &packetSize, &packetSequence, &command);
									if(packetSequence%100==0)
										printf("FW update packet %d\n",packetSequence);
									//Valido il pacchetto
									uint32_t lastSequence;
									int val = fw_update_validate_packet(packetSequence, &lastSequence);
									if(val == -1)
									{
										if(fwWaitForRecover==0)
										{
											fwWaitForRecover =1;
											printf("Not valid arrived %d vs last %d\n",packetSequence, lastSequence);
											cmd_gen_fw_nack_packet(id, command.sender, lastSequence, &aux_command);
											send_command(&tdm_inst,&aux_command);
										}
									}
									else
									{
										if(val==0)
										{
											fwWaitForRecover=0;
		//									printf("Packet ok, size %d\n",packetSize);
											fw_update_put_packet(packet, packetSize);
										}
									}
								}
								break;
							}
							case (CMD_FW_UPDATE_END):
							{
								if(fwUpdateStarted)
								{
									//Capisco quando è arrivato l'ultimo
									uint32_t sw_version;
									uint32_t fpga_version;
									if(fw_update_end(&sw_version,&fpga_version))
									{
										printf("FW update nack\n");
										cmd_gen_fw_nack_file(id, command.sender, &aux_command);
										send_command(&tdm_inst,&aux_command);
										break;
									}

									cmd_gen_fw_ack_file(id, command.sender, &aux_command);
									send_command(&tdm_inst,&aux_command);
									printf("FW update ack\n");
									printf("SW version %lu\n",sw_version);
									printf("FPGA version %lu\n",fpga_version);

									executeFWupdate=1;
									page=0;
									pagesCount=0;
									phase=0;
									fwUpdateStarted=0;
								}
//								audio_from_ps_init_start();
//								audio_to_ps_init_start();
								break;
							}
							case (CMD_FW_SEND_RESET):
							{
								if(executeFWupdate)
								{

									printf("reset in 500ms\n");
									sleep_ms(500);
									zynq_reset();
								}
								break;
							}
							default:

								printf("Command 0x%x not recognized\n",command.command);
								break;
						}//switch(command.command)
					}//if((command.receiver==id)||(command.receiver==0))
				}//if(command_queue_getAvailableCmds(&cmd_queue))
			}//if(id==DEFAULT_UNINIT_ID) else
		}//Cmd handler (hub_loked)
		if(executeFWupdate)
		{
			fw_update_execute(&page,&pagesCount, &phase);
			if(phase==2)
			{
				if(page%400==0)
				{
					uint8_t complete = (uint8_t)(((float)page/(float)pagesCount)*100);
					printf("Download to FLASH: %d %%\n", complete);
					cmd_gen_fw_flash_perc( id, DEFAULT_TABLE_HUB_ID, complete, &aux_command);
					send_command(&tdm_inst,&aux_command);
				}
			}
			else if(phase==3)
			{
				printf("Firmware update finished\n");
				cmd_gen_fw_ack_flash(id, command.sender, &aux_command);
				send_command(&tdm_inst,&aux_command);
				phase=4;
			}
		}

	}
	disable_caches();
	return 0;
}

