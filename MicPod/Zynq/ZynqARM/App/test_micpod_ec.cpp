

#include "interrupt_controller.h"
#include "tdm_bus_driver.h"
#include "test_micpod.h"
#include "utility.h"
#include "stdio.h"
#include "bus_router_driver.h"
#include "spi_driver.h"
#include "cs2000.h"
#include "gpios.h"
#include "audio_from_ps.h"
#include "audio_to_ps.h"
#include "audio_router.h"
#include "I_MCHP.hpp"
#include "stdlib.h"
#include "packet_manager.h"
#include "command_gen_dec.h"
#include "command_queue.h"
#include "version_driver.h"
#include "fw_update_zynq.h"
#include "math.h"
//#define USE_CIRCULAR_BUFFER

int blinking = 0;




#define SCALE_FACTOR 	256.0f
//#define MIC_GAIN		5.0f
#define MIC_GAIN		1.0f
#define SCALE_FACTOR_GAIN	(SCALE_FACTOR/MIC_GAIN)

command_queue_t cmd_queue;
uint8_t id = DEFAULT_UNINIT_ID;
#ifdef USE_CIRCULAR_BUFFER
#include "circular_buffer.h"
bd_circBuf_t from_ps_circ_buf;
int32_t buf_out1[AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX];
#endif
//bd_circBuf_t to_ps_circ_buf;
int32_t buf_in[AUDIO_TO_PS_SAMPLE_PER_BUF_MAX];
int32_t buf_out[AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX];

float mics_alloc[NUMBER_OF_MICS][AUDIO_FROM_PS_FRAME_PER_BUF_MAX];
float sout[AUDIO_FROM_PS_FRAME_PER_BUF_MAX];
float spk[AUDIO_FROM_PS_FRAME_PER_BUF_MAX];

#define MUTE_BTN_MAX_COUNT     100
uint8_t msg_rx[MAX_PACKET_LEN];
tdm_command_t RXcommand;
int led_override=0;
void HandlerRxBus(void *CallbackRef)
{

	tdm_bus_t * data = (tdm_bus_t *)CallbackRef;
	int len= tdm_bus_receive(data, msg_rx);
	if(len!=0)
	{
		//printf("Packet RX %d\n",len);
		if(command_queue_getAvailableSpace(&cmd_queue))
		{
				//printf("Queue avail\n");
				if(packet_manager_tdm_decode(&RXcommand, msg_rx, len)==0)
				{
					//printf("Decode ok len %d\n");

					if((RXcommand.receiver==0x00)||(RXcommand.receiver==id))
					{

						//printf("Packet for me\n");
						command_queue_putCmd(&cmd_queue, &RXcommand, 0);
						//printf("After put\n");
					}
				}
				else
					printf("Decode error\n");
		}
		else
			printf("Queue full\n");
	}
	else
		printf("no receive\n");
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
int mute = 0;
int executeFWupdate = 0;
int fwWaitForRecover = 0;
int fwUpdateStarted = 0;
int page=0;
int pagesCount=0;
int phase=0;
int hub_locked = 0;
int mic_locked = 0;
int current_hub_bus = BUS_ROUTER_HUB_0;
int indexEc=0;
int time;
uint8_t cpu_load=0;
int muteCounter=MUTE_BTN_MAX_COUNT;
int btnPressed = 0;
int led_vals = 0xFF;

tdm_bus_t tdm_inst;
bus_router_t bus_router_inst;
u8 routing_table[AUDIO_CH_NUMBER];
cust_timer_t timer_hub;
cust_timer_t timer_ec;
cust_timer_t timer_id;
cust_timer_t timer_blink;

spi_driver_t spi_inst;
I_MCHP *ec;
tdm_command_t command;
float *mics[NUMBER_OF_MICS];

int signal_generator = 0;
int ramp_counter = 0;
int stop_asking =0;
int loopback_audio = 0;
// Printf EC
int ec_printf(const char *commandString)
{
	tdm_command_t TXcmd;

	cmd_gen_debug_msg(id, DEFAULT_PC_ID, (char*)commandString, &TXcmd);

	send_command(&tdm_inst, &TXcmd);

	return 0;
}


int main()
{
	int i;
	led_override = 0;
	executeFWupdate = 0;

	//enable D-chache and I-cache
	enable_caches();

	printf("\n\n\n\n\nMicpod app started\n");
	printf("SW version %lu\n",sw_get_version());
	printf("FPGA version %lu\n",fpga_get_version());
	printf("FPGA unique id 0x%llx\n",fpga_get_dna());
	if(blinking)
		printf("Blinking\n");
	
	/*Setup Echo Canceller Noise Reduction parameters*/
	ec = new I_MCHP();

//	ec->SetEnable(TX_AGC_ENABLE,false);
	ec->SetMicGain_dB(+12.0f);
//	ec->SetPostGain_dB (+12.0f);
	ec->SetTxAGC_Ref_dB(-17);
	ec->SetTxNoiseMax_dB (-60);
	ec->SetLimiterOffset_dB (6);
	ec->ParseCommand("status");
	/*End setup Echo Canceller Noise Reduction parameters*/

	// EC Printf callback
	ec->OverrideTextOut(ec_printf);

	command_queue_init(&cmd_queue);
	timer_init(&timer_hub);
	timer_init(&timer_ec);
	timer_init(&timer_id);
	timer_init(&timer_blink);
	timer_reset(&timer_hub);
	timer_start(&timer_hub);
	timer_reset(&timer_id);
	timer_start(&timer_id);
	timer_reset(&timer_blink);
	timer_start(&timer_blink);
	interrupt_init();

	//GPIO
	gpios_init(GPIOS_ID);
	leds_init(LED_OFFSET);
	reset_n_adc_init(RST_OFFSET);
	mute_button_init(MUTE_OFFSET);

	//CS2000
	spi_driver_init(&spi_inst);
	cs2000_init(&spi_inst,CS2000_EXTERNAL,1);

	//BUS
	bus_router_init(&bus_router_inst,BUS_ROUTER_BASE_ADDR);
	audio_routing_init(AUDIO_ROUTING_REG_ADDR, AUDIO_CH_NUMBER);
	tdm_bus_init_intr(&tdm_inst,TX_BUS_ADDR,RX_BUS_ADDR,COMM_BUS_ADDR,RX_BUS_INTR_ID,(void *)HandlerRxBus);


	//Audio
	audio_from_ps_init_intr(AUDIO_FROM_PS_REG, AUDIO_FROM_PS_MEM, AUDIO_FROM_PS_INTR);
	audio_to_ps_init_intr(AUDIO_TO_PS_REG, AUDIO_TO_PS_MEM, AUDIO_TO_PS_INTR);



	//ec->SetEnable(POSTFILTER_ENABLE,false);

	leds_set_mask(led_vals);


	for(int i=0; i<NUMBER_OF_MICS; i++)
		mics[i]= mics_alloc[i];//(float *)malloc(sizeof(float)*AUDIO_FROM_PS_FRAME_PER_BUF_MAX);

#if NUMBER_OF_MICS!= 4
#error ASDSP builded with wrong mic number
#endif

#ifdef USE_CIRCULAR_BUFFER

	circBuf_init(&from_ps_circ_buf);
#endif

	for(i=0; i<AUDIO_CH_NUMBER; i++)
		routing_table[i]=i;
	audio_routing_set(routing_table);

	mute = 0;
	timer_reset(&timer_id);
	timer_start(&timer_id);
	while(1)
	{

		if((blinking) | (stop_asking))
		{
			//toggle LED each 0.5 sec
			if(timer_get_elapsed_ms(&timer_blink)>500)
			{
				if(led_vals==0)
					led_vals=0xFF;
				else
					led_vals=0;
				leds_set_mask(led_vals);
				timer_reset(&timer_blink);
				timer_start(&timer_blink);
			}
		}
		/********************************************/
 		/*  AUDIO PROCESSING                        */
 		/********************************************/
		if(hub_locked)
		{

			if(audio_to_ps_read_non_blocking(buf_in))
			{
				// acquire 4 MIC channels and SPK channel in buf_in  
		    	indexEc++;
		    	if(indexEc==125)
		    	{
		    		time = timer_get_elapsed_ms(&timer_ec);
		    		cpu_load = (uint8_t)(time/10);
		    		printf("Time %d ms\n",time);
		    		timer_reset(&timer_ec);
		    		indexEc=0;
		    	}
				for(i=0; i<AUDIO_TO_PS_FRAME_PER_BUF_MAX; i++)
				{
					mics[0][i]=((float)buf_in[AUDIO_TO_PS_CH_NUM*i+1])/SCALE_FACTOR_GAIN;
					mics[1][i]=((float)buf_in[AUDIO_TO_PS_CH_NUM*i+0])/SCALE_FACTOR_GAIN;
					mics[2][i]=((float)buf_in[AUDIO_TO_PS_CH_NUM*i+3])/SCALE_FACTOR_GAIN;
					mics[3][i]=((float)buf_in[AUDIO_TO_PS_CH_NUM*i+2])/SCALE_FACTOR_GAIN;

					spk[i]=((float)(buf_in[AUDIO_TO_PS_CH_NUM*i+4]+buf_in[AUDIO_TO_PS_CH_NUM*i+5]))/(2.0f*SCALE_FACTOR);
				}

				//ECNR processing
				timer_start(&timer_ec);
				ec->ProcessSpkFrame(spk);
				ec->ProcessMicFrame(mics,sout);

				if(loopback_audio)
				{
					for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX; i++)
					{
						sout[i]=spk[i];
					}
				}

				int micOut = ec->GetSteeredOut();
				if((led_override==0)&&(blinking==0))
					leds_set_beam(micOut);
				timer_stop(&timer_ec);

#ifdef USE_CIRCULAR_BUFFER
		    	int avail = circBuf_availableSpace(&from_ps_circ_buf);
		    	if(avail>=AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX)
#endif

		    	{
		    		if(mute)	//If muted, set all buf_out to zero
		    		{
						for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX; i++)
						{
							buf_out[8*i]=0;//buf_in[6*i+0];   //sout
							buf_out[8*i+1]=0; //sin0
							buf_out[8*i+2]=0; //sin1
							buf_out[8*i+3]=0; //sin2
							buf_out[8*i+4]=0; //sin3
							buf_out[8*i+5]=0; //spk0
							buf_out[8*i+6]=0; //spk1
						}
		    		}
		    		else
		    		{
						if(signal_generator==0)
						{
							//if no signal generator is active, place in output buffer the processed mics and spk
							for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX; i++)
							{

									buf_out[8*i]=(int)(sout[i]*(SCALE_FACTOR-1));
									buf_out[8*i+1]=(int)(mics[0][i]*(SCALE_FACTOR-1));
									buf_out[8*i+2]=(int)(mics[1][i]*(SCALE_FACTOR-1));
									buf_out[8*i+3]=(int)(mics[2][i]*(SCALE_FACTOR-1));
									buf_out[8*i+4]=(int)(mics[3][i]*(SCALE_FACTOR-1));
									buf_out[8*i+5]=(int)(spk[i]*(SCALE_FACTOR-1));
							}
						}
						else if(signal_generator==1)
						{
							//replace output buffer with generated ramp signal
							for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX; i++)
							{
								ramp_counter++;
								buf_out[8*i]=ramp_counter;
								buf_out[8*i+1]=ramp_counter;
								buf_out[8*i+2]=ramp_counter;
								buf_out[8*i+3]=ramp_counter;
								buf_out[8*i+4]=ramp_counter;
								buf_out[8*i+5]=ramp_counter;
							}
						}
						else if(signal_generator==2)
						{
							//replace output buffer with generated sinewave signal
							for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX; i++)
							{
								ramp_counter++;
								int auxSin = (int)(1677721.0*sin(2*M_PI*((double)ramp_counter)/32.0));
								buf_out[8*i]=auxSin;
								buf_out[8*i+1]=auxSin;
								buf_out[8*i+2]=auxSin;
								buf_out[8*i+3]=auxSin;
								buf_out[8*i+4]=auxSin;
								buf_out[8*i+5]=auxSin;
							}
						}
		    		}
#ifdef USE_CIRCULAR_BUFFER
					circBufPushI(&from_ps_circ_buf,buf_out,AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX);
#else
					audio_from_ps_write_non_blocking(buf_out);	//send audio buffer out
#endif
		    	}


			}
#ifdef USE_CIRCULAR_BUFFER
		    if(audio_from_ps_write_non_blocking(buf_out1))
			{
		    	if(circBuf_availableSamples(&from_ps_circ_buf)>=AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX)
		    	{
		    		circBufPopI(&from_ps_circ_buf,buf_out1,AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX);
		    	}
			}
#endif
		}
		/********************************************/
 		/* END AUDIO PROCESSING                     */
 		/********************************************/




		/********************************************/
 		/*  TDM MAIN LOCKING                        */
 		/********************************************/
		//main bus lock
		if(timer_get_elapsed_ms(&timer_hub)>100)
		{
			if(hub_locked==0)
			{
				mute = 0;
				stop_asking = 0;
				executeFWupdate = 0;
				fwWaitForRecover = 0;
				fwUpdateStarted = 0;
				page=0;
				pagesCount=0;
				phase=0;

				mic_locked = 0;

				indexEc=0;

				cpu_load=0;
				muteCounter=MUTE_BTN_MAX_COUNT;
				btnPressed = 0;

				//if TDM bus is locked here's set the routing direction
				if(tdm_bus_is_hub_locked(&tdm_inst))
				{
					hub_locked=1;

					if(current_hub_bus==BUS_ROUTER_HUB_0)
					{
						bus_router_set_tx0(&bus_router_inst,BUS_ROUTER_TX_HUB);
						bus_router_set_tx1(&bus_router_inst,BUS_ROUTER_SILENT);
					}
					else
					{
						bus_router_set_tx1(&bus_router_inst,BUS_ROUTER_TX_HUB);
						bus_router_set_tx0(&bus_router_inst,BUS_ROUTER_SILENT);
					}
					reset_n_set(1);
					audio_to_ps_init_start();
					audio_from_ps_init_start();


					printf("Receiver %d locked and promoted to hub\n",current_hub_bus);
				}
				else
				//bus still not locked: toggling between the 2 ports to identify TABLE HUB side from MICPODs
				{
					if(current_hub_bus==BUS_ROUTER_HUB_0)
						current_hub_bus=BUS_ROUTER_HUB_1;
					else
						current_hub_bus=BUS_ROUTER_HUB_0;
					bus_router_set_hub_sel(&bus_router_inst, current_hub_bus);
				}
			}// if(hub_locked==0)
			else
			{
				//if TDM bus is not locked, set uninit ID and revoke routing direction
				if(!tdm_bus_is_hub_locked(&tdm_inst))
				{
					timer_reset(&timer_id);
					timer_start(&timer_id);
					hub_locked=0;
					mic_locked=0;

					id=0xFF;
					audio_to_ps_init_stop();
					audio_from_ps_init_stop();


					reset_n_set(0);
					//leds_set_mask(0xFF);
					bus_router_set_tx0(&bus_router_inst,BUS_ROUTER_SILENT);
					bus_router_set_tx1(&bus_router_inst,BUS_ROUTER_SILENT);
					printf("Hub unlocked\n");
				}
			}//if(hub_locked==0) else
			timer_reset(&timer_hub);
			timer_start(&timer_hub);
		}
		/********************************************/
 		/*  END TDM MAIN LOCKING                    */
 		/********************************************/


		/********************************************/
 		/*  TDM SLAVE LOCKING                       */
 		/********************************************/
		if(hub_locked)
		{
			if(mic_locked==0)
			{
				if(tdm_bus_is_slave_locked(&tdm_inst,0))
				{
					mic_locked=1;
					cmd_gen_info_interface_lock(DEFAULT_TABLE_HUB_ID,id,0,1,&aux_command);
					send_command(&tdm_inst,&aux_command);
					printf("Mic locked\n");
				}
			}
			else
			{
				if(!tdm_bus_is_slave_locked(&tdm_inst,0))
				{
					mic_locked=0;
					cmd_gen_info_interface_lock(DEFAULT_TABLE_HUB_ID,id,0,0,&aux_command);
					send_command(&tdm_inst,&aux_command);
					printf("Mic unlocked\n");
				}
			}
		}
		/********************************************/
 		/*  END TDM SLAVE LOCKING                   */
 		/********************************************/

		//Mute btn handler: reads btn value, decides the mute state, and sends the mute command
		if(hub_locked)
		{
			//Mute
			int newMute = mute_button_get();
			if(newMute==1)
			{
				if(muteCounter<MUTE_BTN_MAX_COUNT)
					muteCounter++;
			}
			else
			{
				if(muteCounter>0)
					muteCounter--;
			}
			if(btnPressed==1)
			{
				if(muteCounter==MUTE_BTN_MAX_COUNT-1)
				{
					if(mute)
					{
						mute=0;
						cmd_gen_info_mute(DEFAULT_TABLE_HUB_ID,id,0,&aux_command);
						send_command(&tdm_inst,&aux_command);
						printf("Unmute\n");

					}
					else
					{
						mute=1;
						cmd_gen_info_mute(DEFAULT_TABLE_HUB_ID,id,1,&aux_command);
						send_command(&tdm_inst,&aux_command);
						printf("Mute\n");
					}
					btnPressed=0;
				}
			}
			else
			{
				if(muteCounter==1)
				{
					btnPressed=1;
				}
			}
		}

		/********************************************/
 		/*  COMMAND HANDLING                        */
 		/********************************************/
		if(hub_locked)
		{
			if(id==DEFAULT_UNINIT_ID)
			{
				//decode the following commands ONLY if micpod has uninitialized unique ID
				if(stop_asking==0)
				{
					//If micpod still can indentify itself, send ID request command to table hub
					if(timer_get_elapsed_ms(&timer_id)>20)
					{
						 timer_stop(&timer_id);
						 cmd_gen_im_here(DEFAULT_TABLE_HUB_ID,fpga_get_dna(), MICPOD_DEVICE_TYPE,&aux_command);
						 send_command(&tdm_inst,&aux_command);
						 timer_reset(&timer_id);
						 timer_start(&timer_id);
						 printf("Send Im here\n");
					}
				}
				//get any received command from the queue
				if(command_queue_getAvailableCmds(&cmd_queue))
				{
					uint8_t tag;
					command_queue_getCmd(&cmd_queue, &command, &tag);
					if(command.receiver==DEFAULT_UNINIT_ID)
					{
						//if ID assignment received, set ID and answer with device info
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
						else if(command.command==CMD_STOP_ASKING)
						{
							uint64_t unique_id;
							cmd_dec_stop_asking(&unique_id,  &command);
							// if stop asking for ID recieved and ID check pass
							// then stop sending ID request cmd
							if(unique_id==fpga_get_dna())
							{
								stop_asking=1;
								led_override = 1;
								leds_set_mask(0);
							}
						}
					}

				}
			}//if(id==DEFAULT_UNINIT_ID)
			else
			{
				if(command_queue_getAvailableCmds(&cmd_queue))
				{
					//printf("command received 0x%x\n",command.command);
					uint8_t tag;
					//pop command from the queue
					command_queue_getCmd(&cmd_queue, &command, &tag);
					if((command.receiver==id)||(command.receiver==0))
					{
						// decode the command (check if receiver is MICPOD or broadcast -> both fine)
						switch(command.command)
						{
							case (CMD_POLL):
//								printf("Received poll from rx\n");
								//cmd_gen_alive(id,command.sender,&aux_command);

								//ANSWER with CPU LOAD value, means also the unit is alive
								cmd_gen_cpu_load(id,command.sender,cpu_load,&aux_command);
								send_command(&tdm_inst,&aux_command);
								break;
							case (CMD_GET_DEV_INFO):
							{
								printf("Get dev info\n");

								/*	returns:

									sw_version;
									fpga_version;
									fpga_unique_id;
									stm_version;
									linux_version;*/
								dev_info_t dev_info;
								get_version_struct(&dev_info);
								cmd_gen_ret_dev_info(id,command.sender, &dev_info, &aux_command);
								send_command(&tdm_inst,&aux_command);
								break;
							}
							case (CMD_SET_LED_MICPOD):
							{
								//sets ON/OFF led
								uint8_t val;
								cmd_dec_set_led_micpod(&val, &command);
								printf("Received set led %d\n",val);
								if(val)
								{
									leds_set_mask(0);
									led_override = 1;
								}
								else
								{
									leds_set_mask(0xFF);
									led_override = 0;
								}
								break;
							}
							case (CMD_SET_MUTE_MICPOD):
							{
								//sets ON/OFF mute
								uint8_t muteAux;
								cmd_dec_set_mute_micpod(&muteAux,&command);
								mute = muteAux;
								if(mute)
									printf("Received mute\n");
								else
									printf("Received unmute\n");
								break;
							}
							case (CMD_SET_SLAVE_INTERFACE):
							{
								uint8_t intNum;
								uint8_t en;
								printf("Set slave int\n");
								cmd_dec_set_slave_interface(&intNum, &en, &command);
								if(en==1)
								{
									if(current_hub_bus==BUS_ROUTER_HUB_0)
										bus_router_set_tx1(&bus_router_inst,BUS_ROUTER_RX_0);
									else
										bus_router_set_tx0(&bus_router_inst,BUS_ROUTER_RX_1);
								}
								else
								{
									if(current_hub_bus==BUS_ROUTER_HUB_0)
										bus_router_set_tx1(&bus_router_inst,BUS_ROUTER_SILENT);
									else
										bus_router_set_tx0(&bus_router_inst,BUS_ROUTER_SILENT);
								}
								break;
							}
							case (CMD_SET_ROUTING):
								//update routing table with the recieved one
								printf("Received set routing\n");
								cmd_dec_set_routing(routing_table, &command);
								audio_routing_set(routing_table);
								break;
							case (CMD_SET_POST_FILER_EN):
							{
								uint8_t en;
								printf("Received set post filter\n");

								//enable/disable postFilter in ECNR
								cmd_dec_set_postfilter_en(&en, &command);
								if(en)
								{
									printf("Post filter enabled\n");
//									leds_set_mask(0x00);
//									ec->SetEnable(POSTFILTER_ENABLE,true);
									ec->SetEnable(TX_AGC_ENABLE,true);
								}
								else
								{
									printf("Post filter disabled\n");
//									leds_set_mask(0xFF);
//									ec->SetEnable(POSTFILTER_ENABLE,false);
									ec->SetEnable(TX_AGC_ENABLE,false);
								}


								break;
							}
							case (CMD_SET_LOOPBACK_MICPOD):
							{
								uint8_t en;
								printf("Received set loopback\n");

																//enable/disable postFilter in ECNR
								cmd_dec_set_loopback_en(&en, &command);
								loopback_audio = en;
								break;
							}
							case (CMD_FW_UPDATE_START):
							{
								printf("FW update start\n");
								uint8_t dev_type;
								uint8_t auxId;
								//loads all the necessary parameters from the recv command
								cmd_dec_fw_update_start(&dev_type, &auxId,&command);
								if(dev_type==MICPOD_DEVICE_TYPE)
								{
									//TODO:
									//set a timeout in case everything blows up
									
									//STOP TDM audio
									audio_from_ps_init_stop();
									audio_to_ps_init_stop();

									//init update params
									fw_update_start();

									//inform table HUB that the update can start for real
									cmd_gen_fw_ack_start(id,command.sender,&aux_command);
									send_command(&tdm_inst,&aux_command);
									fwUpdateStarted=1;
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
									//take binary packet from the recv command
									cmd_dec_fw_update_packet(packet, &packetSize, &packetSequence, &command);
									if(packetSequence%100==0)
										printf("FW update packet %d\n",packetSequence);
									//Valido il pacchetto
									uint32_t lastSequence;

									//validating packet, checking the sequence number
									int val = fw_update_validate_packet(packetSequence, &lastSequence);
									if(val == -1)
									{
										if(fwWaitForRecover==0)
										{
											// enter packet recovery mode: sending nack command with the last valid seq number
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
											//store recieved packet into a RAM buffer
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
									uint32_t sw_version;
									uint32_t fpga_version;
									if(fw_update_end(&sw_version,&fpga_version))
									{
										//check MD5 has failed, the computed version does not coincide with the recieved one
										printf("FW update nack\n");
										//send command NACK file
										cmd_gen_fw_nack_file(id, command.sender, &aux_command);
										send_command(&tdm_inst,&aux_command);
										break;
									}
									// MD5 check passed, inform the table HUB that file transfer is OK
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
									//reset ARM processor
									printf("reset in 500ms\n");
									sleep_ms(500);
									zynq_reset();
								}
								break;
							}
							case (CMD_SET_SIGNAL_GEN):
							{
								uint8_t sgn;
								//set signal generator to sinewave, ramp..
								cmd_dec_set_signal_gen(&sgn, &command);
								signal_generator=sgn;
								printf("Set signal generator to %d\n",sgn);
								break;
							}

							case (CMD_SEND_DEBUG_MSG):
							{
								char commandString[MAX_DATA_LEN];

								// Ec string commands
								cmd_dec_debug_msg(commandString, &command);
								printf("Received EC Command string: %s\n",commandString);

								ec->ParseCommand(commandString);
							}

							default:
								printf("Command 0x%x not recognized\n",command.command);
								break;
						}//switch(command.command)
					}//if((command.receiver==id)||(command.receiver==0))
				}//if(command_queue_getAvailableCmds(&cmd_queue))
			}//if(id==DEFAULT_UNINIT_ID) else
		}//Cmd handler (hub_loked)
		/********************************************/
 		/*  END COMMAND HANDLING                    */
 		/********************************************/


		/***************************************************************/
 		/* FW UPDATE EXECUTION (after the recv FW is validated in RAM) */
 		/***************************************************************/
		if(executeFWupdate)
		{
			//update running: ERASING, WRITING
			fw_update_execute(&page,&pagesCount, &phase);
			if(phase==2)
			{
				if(page%400==0)
				{
					uint8_t complete = (uint8_t)(((float)page/(float)pagesCount)*100);
					printf("Download to FLASH: %d %%\n", complete);
					//update the TABLE HUB with the progress percentage
					cmd_gen_fw_flash_perc( id, DEFAULT_TABLE_HUB_ID, complete, &aux_command);
					send_command(&tdm_inst,&aux_command);
				}
			}
			else if(phase==3)
			{
				printf("Firmware update finished\n");
				//notify update end to table hub
				cmd_gen_fw_ack_flash(id, command.sender, &aux_command);
				send_command(&tdm_inst,&aux_command);
				phase=4;
			}
		}
		/****************************************/
 		/* END FW UPDATE EXECUTION 				*/
 		/****************************************/
	}
	disable_caches();
	return 0;
}

