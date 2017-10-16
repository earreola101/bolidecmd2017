#include <string.h>
#include "utility.h"
#include "command_handler_tv_hub.h"
#include "status.h"
#include "send_receive_tv_hub.h"
#include "version_module.h"
#include "gain_module.h"
#include "fw_update_tv_hub.h"

#define DEBUG_STATUS_CMDS
//#define DEBUG_FW_UPDATE


uint8_t pktRecoveryMode = 0;
uint16_t recSeqNum = 0;
uint8_t this_id;
uint8_t usbVolume=0;
uint8_t usbConnected=0;
int fwUpdateStarted = 0;
int fwWaitForRecover = 0;
void cmd_handler_init()
{
	tdm_command_t cmd;
	cmd_gen_set_id(DEFAULT_STM32_ID+1,DEFAULT_TV_HUB_ID,0,DEFAULT_STM32_ID+1,&cmd);
	send_command(&cmd);
	fwUpdateStarted = 0;
	fwWaitForRecover = 0;
}

void cmd_handler_set_id(uint8_t id)
{
	this_id = id;
}
uint8_t cmd_handler_get_id()
{
	return this_id;
}

void cmd_handler_route(tdm_command_t *RXcmd)
{
	send_command(RXcmd);
}



void cmd_handler_status(tdm_command_t *cmd, uint8_t tag)
{
	system_status_t local_system_status;
	tdm_command_t TXcmd;

	switch (cmd->command)
	{
		case CMD_SET_DEVICE_ID:
		{
			uint64_t rec_unique;
			uint8_t id;
			uint64_t this_unique = fpga_get_dna();
			cmd_dec_set_id(&rec_unique,&id,cmd);
			if(rec_unique==this_unique)
			{
				cmd_handler_set_id(id);
				dev_info_t dev_info;
				get_version_struct(&dev_info);
				cmd_gen_ret_dev_info(id,cmd->sender, &dev_info, &TXcmd);
				send_command(&TXcmd);
				sleep_ms(10);
				cmd_gen_set_volume(DEFAULT_TABLE_HUB_ID, DEFAULT_STM32_ID+1,usbVolume,&TXcmd);
				send_command(&TXcmd);
				sleep_ms(10);
				cmd_gen_usb_audio_connected(DEFAULT_TABLE_HUB_ID,DEFAULT_STM32_ID+1, usbConnected,&TXcmd);
				send_command(&TXcmd);
			}
			else
			{

				printf("Warning set id: wrong unique id: this 0x%llx vs rec 0x%llx\n",this_unique,rec_unique);
//				cmd_handler_set_id(id);
			}


			break;
		}
		case CMD_POLL:
		{
//			printf("Poll\n");
			if(this_id!=DEFAULT_UNINIT_ID)
			{
				cmd_gen_alive(this_id, cmd->sender, &TXcmd);
				send_command(&TXcmd);
			}
			break;
		}
		case CMD_RET_STM_VER:
		{
			uint32_t ver;
			cmd_dec_ret_stm_ver(&ver, cmd);
//			system_status_ret_stm_ver(ver);
			set_stm_version(ver);
			printf("Stm 32 version %d\n",ver);
			break;
		}
		case CMD_SET_VOLUME:
		{
			if(cmd->sender==DEFAULT_TABLE_HUB_ID)
			{
				uint8_t vol;
				cmd_dec_set_volume(&vol,cmd);
				float volF = ((float)vol)/100.0f;
				set_gain(volF);
				printf("Set volume from table hub %d\n",vol);
			}
			else
			{
				cmd_dec_set_volume(&usbVolume,cmd);
				cmd_gen_set_volume(DEFAULT_TABLE_HUB_ID, DEFAULT_STM32_ID+1,usbVolume,&TXcmd);
				send_command(&TXcmd);
				printf("Set volume from stm32 %d\n",usbVolume);
			}
			break;
		}
		case CMD_DEV_USB_AUDIO_CONN:
		{
			cmd_dec_usb_audio_connected(&usbConnected, cmd);
			printf("Usb connected %d\n",usbConnected);
			cmd_gen_usb_audio_connected(DEFAULT_TABLE_HUB_ID,DEFAULT_STM32_ID+1, usbConnected,&TXcmd);
			send_command(&TXcmd);
			break;
		}

		default:
		{
			break;
		}
	}

}
void cmd_handler_status_out(tdm_command_t *cmd, uint8_t tag)
{
	system_status_t local_system_status;
	tdm_command_t TXcmd;

	switch (cmd->command)
	{
		case CMD_IM_HERE:
		{
			if(this_id==DEFAULT_UNINIT_ID)
			{
				send_command(cmd);
			}
			break;
		}
		default:
		{
			break;
		}
	}

}
int cnt=0;


void cmd_handler_fw_update(tdm_command_t *cmd)
{

	tdm_command_t TXcmd;
	TXcmd.sender = DEFAULT_TABLE_HUB_ID;


		switch (cmd->command)
		{
			case CMD_FW_UPDATE_START:
			{

				uint8_t dev_type;
				uint8_t dev_id;

				cmd_dec_fw_update_start( &dev_type, &dev_id, cmd);
				if((dev_type==STM32_DEVICE_TYPE)||(dev_type==TV_HUB_DEVICE_TYPE))
				{
					if(dev_type==STM32_DEVICE_TYPE)
					{
						printf("Fw update STM32 start recived: sending ack\n");

						fw_update_start("/media/rootfs/USBaudio.hex",dev_type);
					}
					else
					{
						printf("Fw update app start recived: sending ack\n");

						fw_update_start("/media/rootfs/tv_hub_app_",dev_type);
					}
					fwUpdateStarted=1;
					cmd_gen_fw_ack_start(DEFAULT_TV_HUB_ID, cmd->sender, &TXcmd);
					send_command(&TXcmd);
				}


				break;
			}
			case CMD_FW_UPDATE_PKT:
			{
				if(fwUpdateStarted)
				{
					uint8_t packet[MAX_DATA_LEN];
					uint16_t packetSize;
					uint32_t packetSequence;
					cmd_dec_fw_update_packet(packet, &packetSize, &packetSequence, cmd);

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
							cmd_gen_fw_nack_packet(DEFAULT_TV_HUB_ID, cmd->sender, lastSequence, &TXcmd);
							send_command(&TXcmd);
						}
					}

					else
					{
						if(val==0)
						{
							fwWaitForRecover=0;
							printf("Packet ok, size %d\n",packetSize);
							fw_update_put_packet(packet, packetSize);

						}
					}
				}
				break;
			}
			case CMD_FW_UPDATE_END:
			{
				if(fwUpdateStarted)
				{
					//Capisco quando è arrivato l'ultimo

					if(fw_update_end())
					{
						printf("FW update nack\n");
						cmd_gen_fw_nack_file(DEFAULT_TV_HUB_ID, cmd->sender, &TXcmd);
						send_command(&TXcmd);
						break;
					}

					cmd_gen_fw_ack_file(DEFAULT_TV_HUB_ID, cmd->sender, &TXcmd);
					send_command(&TXcmd);
					printf("FW update ack\n");

					if(fw_update_get_type()==STM32_DEVICE_TYPE)
					{
						send_receive_deinit_stm32_serial();
						fw_update_runSTM32Updater();
						send_receive_init_stm32_serial();
						cmd_gen_fw_ack_flash(DEFAULT_TV_HUB_ID,  cmd->sender,&TXcmd);
						send_command( &TXcmd);
						fwUpdateStarted=0;
					}
					else
					{
						cmd_gen_fw_ack_flash(DEFAULT_TV_HUB_ID,  cmd->sender,&TXcmd);
						send_command( &TXcmd);
						fw_update_runTvHub_app_update();
						fwUpdateStarted=0;
					}

				}
				break;
			}
			default:
			{
				break;
			}
		}


	return;
}




