#include <string.h>
#include "utility.h"
#include "command_handler.h"
#include "status.h"
#include "send_receive.h"

#define DEBUG_STATUS_CMDS
//#define DEBUG_FW_UPDATE


uint8_t pktRecoveryMode = 0;
uint16_t recSeqNum = 0;


void cmd_handler_init()
{
	tdm_command_t cmd;
	cmd_gen_set_id(DEFAULT_STM32_ID,DEFAULT_TABLE_HUB_ID,0,DEFAULT_STM32_ID,&cmd);
	send_command(&cmd);
}

//handles all the identified commands by the comm_exec_rx thread
void cmd_handler_status(tdm_command_t *cmd, uint8_t tag)
{
	system_status_t local_system_status;
	tdm_command_t TXcmd;

	switch (cmd->command)
	{
		case CMD_ALIVE:
		{
			//printf("Alive from %d\n",cmd->sender);
			system_status_set_alive(cmd->sender);

			break;
		}
		case CMD_SEND_CPU_LOAD:
		{
			uint8_t cpu_load;
//			printf("Cpu from %d\n",cmd->sender);
			cmd_dec_cpu_load(&cpu_load,cmd);
			//update CPU load value
			system_status_set_cpu_load(cpu_load, cmd->sender);
			//notify the GUI with the update CPU value
			cmd_gen_cpu_load(cmd->sender, DEFAULT_PC_ID,cpu_load,&TXcmd);
			send_command(&TXcmd);
			break;
		}
		case CMD_POLL:
		{
//			printf("Poll\n");
			if(cmd->receiver==DEFAULT_TABLE_HUB_ID)
			{
//				printf("Poll arrived\n");
				if(tag==TAG_SERIAL_CMD)
					send_receive_set_gui_interface(0);
				else
					send_receive_set_gui_interface(1);

				//send poll command to device
				cmd_gen_alive(DEFAULT_TABLE_HUB_ID, cmd->sender, &TXcmd);
				send_command(&TXcmd);

			}
			else
			{
//				printf("Poll send\n");
				send_command(cmd);
			}

			break;
		}
		case CMD_SET_SLAVE_INTERFACE:
		{
			//enable/disable an interface
			uint8_t intNum;
			uint8_t en;
			cmd_dec_set_slave_interface(&intNum,&en,cmd);
			system_status_set_slave_interface(cmd->receiver, intNum, en);
			send_command(cmd);
			break;
		}
		case CMD_INFO_INTERFACE_LOCK:
		{
			//update interface lock status
			uint8_t intNum;
			uint8_t locked;
			cmd_dec_info_interface_lock(&intNum, &locked, cmd);
			system_status_info_interface_lock(cmd->sender, intNum, locked);
			if(locked)
				printf("Interface %d of id %d locked\n",intNum, cmd->sender);
			break;
		}
		case CMD_GET_SYS_STATUS:
		{
			int i;
			//answer with the whole system status to the GUI
			if(tag==TAG_SERIAL_CMD)
				send_receive_set_gui_interface(0);
			else
				send_receive_set_gui_interface(1);
			system_status_get_all(&local_system_status);
			for(i=0; i<MICPOD_MAX_N; i++)
			{
				cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID, cmd->sender, &local_system_status.micpods[i],i, &TXcmd);
				send_command(&TXcmd);
				sleep_ms(1);
			}

			for(i=0; i<MICPOD_HUB_MAX_N; i++)
			{
				cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID, cmd->sender, &local_system_status.micpod_hubs[i],i, &TXcmd);
				send_command(&TXcmd);
				sleep_ms(1);
			}
			cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID, cmd->sender, &local_system_status.tv_hub,0, &TXcmd);
			send_command(&TXcmd);
			sleep_ms(1);
			cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID, cmd->sender, &local_system_status.table_hub,0, &TXcmd);
			send_command(&TXcmd);
			sleep_ms(1);
			cmd_gen_dev_status_refresh(DEFAULT_TABLE_HUB_ID, cmd->sender, &TXcmd);
			send_command(&TXcmd);
			sleep_ms(1);
			break;
		}
		case CMD_DEV_STATUS_ANS:
		{
			send_command(cmd);
			break;
		}
		case CMD_DEV_STATUS_REFRESH:
		{

			send_command(cmd);
			break;
		}
		case CMD_DEV_USB_AUDIO_CONN:
		{
			uint8_t connected;
			cmd_dec_usb_audio_connected(&connected, cmd);

			system_status_set_usb_connected(cmd->sender,connected);
			if(connected)
				printf("USB %d connected\n",cmd->sender);
			else
				printf("USB %d disconnected\n",cmd->sender);

			break;
		}
		case CMD_SET_LED_MICPOD:
		{
			uint8_t micId = cmd->receiver;
			uint8_t status = cmd->data[0];
			system_status_set_micpod_led(micId, status);
			send_command(cmd);
			//TODO: cambiare nomi alle funzioni di status
			break;
		}
		case CMD_SET_MUTE_MICPOD:
		{
			uint8_t mute;
			cmd_dec_set_mute_micpod(&mute,cmd);
			system_status_set_micpod_mute(cmd->receiver, mute);
			send_command(cmd);
			if(mute)
				printf("Micpod %d muted\n", cmd->receiver);
			else
				printf("Micpod %d unmuted\n", cmd->receiver);

			break;
		}
		case CMD_SET_ROUTING:
		{
			//Set routing to specific receiver
//			printf("Set routing to %d\n",cmd->receiver);
			send_command(cmd);
			break;
		}
		case CMD_INFO_MUTE_MICPOD:
		{
			uint8_t mute;

			//update micpod mute status
			cmd_dec_info_mute(&mute,cmd);
			system_status_set_micpod_mute(cmd->sender, mute);
			if(mute)
				printf("Micpod %d muted\n", cmd->sender);
			else
				printf("Micpod %d unmuted\n", cmd->sender);
			generic_device_t * dev = system_status_get_device_from_id(cmd->sender);

			//send the updated status to the GUI
			cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID,dev,system_status_get_micpod_index_from_id(cmd->sender),&TXcmd);
//			printf("Send dev status\n");
			send_command(&TXcmd);
			cmd_gen_dev_status_refresh(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID, &TXcmd);
//			printf("Send refresh\n");
			send_command(&TXcmd);
			break;
		}
		case CMD_RET_DEV_INFO:
		{
			//retrieve device info
			dev_info_t info;
			cmd_dec_ret_dev_info(&info, cmd);
			system_status_ret_dev_info(cmd->sender, &info);
			break;
		}
		case CMD_RET_STM_VER:
		{
			uint32_t ver;
			//retrieve STM32 version
			cmd_dec_ret_stm_ver(&ver, cmd);
			system_status_ret_stm_ver(ver);

			printf("Stm 32 version %d\n",ver);
			break;
		}
		case CMD_IM_HERE:
		{
			if(cmd->sender==DEFAULT_UNINIT_ID)
			{
				//new device appeared with default uninitialized ID
				generic_device_t *device;
				uint64_t uniqueId;
				uint8_t deviceType;
				cmd_dec_im_here(&uniqueId, &deviceType, cmd);
				printf("Received I'm here from unique 0x%llx, tag 0x%x\n",uniqueId, tag);

				uint8_t newId = system_status_assign_device_id(deviceType,uniqueId, tag,&device);
				if(newId!=0)
				{
					//new ID assigned, inform the device
					cmd_gen_set_id(DEFAULT_UNINIT_ID,DEFAULT_TABLE_HUB_ID,uniqueId, newId,  &TXcmd);
					send_command(&TXcmd);
					printf("Assigned %d\n",newId);

				}
				else
				{
					//unassignable new ID, throw error message, send stop asking command
					cmd_gen_stop_asking(DEFAULT_TABLE_HUB_ID,uniqueId,  &TXcmd);
					send_command(&TXcmd);
					sleep_ms(10);
					cmd_gen_too_many_dev_error(DEFAULT_PC_ID,DEFAULT_TABLE_HUB_ID,deviceType, &TXcmd);
					send_command(&TXcmd);
					printf("Error: couldn't assign id\n");
				}
			}
			break;
		}
		case CMD_MUTE_SYSTEM:
		{
			uint8_t mute;
			cmd_dec_set_mute_sys(&mute,cmd);
			system_status_set_sys_mute(mute);
			if(mute)
			{
				printf("Received MUTE request.\n");
			}
			else
				printf("Received UNMUTE request.\n");

			break;
		}
		case CMD_SET_DEBUG_MODE:
		{
			uint8_t debug, micpodId;
			cmd_dec_set_debug_micpod(&debug,&micpodId,cmd);
			system_status_set_debug_micpod(debug, micpodId);
#ifdef DEBUG_STATUS_CMDS
			if(debug)
				printf("Received DEBUG ON request to micpod %d\n", micpodId);
			else
				printf("Received DEBUG OFF request to micpod %d\n", micpodId);
#endif
			break;
		}
		case CMD_SET_LISTEN_MODE:
		{
			uint8_t micpodId;
			cmd_dec_set_listen_micpod(&micpodId,cmd);
			system_status_set_listen_micpod(micpodId);
#ifdef DEBUG_STATUS_CMDS
			printf("Received LISTEN ON request to micpod %d\n", micpodId);
#endif
			break;
		}
		case CMD_SET_POST_FILER_EN:
		{
			uint8_t postFilterEn;
			cmd_dec_set_postfilter_en(&postFilterEn, cmd);
			system_status_set_postfilter_micpod(postFilterEn,cmd->receiver);
#ifdef DEBUG_STATUS_CMDS
			if(postFilterEn)
				printf("Received POST FILTER ON request to micpod %d\n", cmd->receiver);
			else
				printf("Received POST FILTER OFF request to micpod %d\n", cmd->receiver);
#endif
			send_command(cmd);
			break;
		}
		case CMD_SET_LOOPBACK_MICPOD:
		{
			uint8_t postFilterEn;
			cmd_dec_set_postfilter_en(&postFilterEn, cmd);
			system_status_set_postfilter_micpod(postFilterEn,cmd->receiver);
#ifdef DEBUG_STATUS_CMDS
			if(postFilterEn)
				printf("Received LOOPBACK ON request to micpod %d\n", cmd->receiver);
			else
				printf("Received LOOPBACK OFF request to micpod %d\n", cmd->receiver);
#endif
			send_command(cmd);
			break;
		}
		case CMD_SET_DEBUG_FILE:
		{
			uint8_t debugEn;
			char file_name[50];
			cmd_dec_set_debug_file(&debugEn, file_name, cmd);
#ifdef DEBUG_STATUS_CMDS
			if(debugEn)
				printf("Received DEBUG RECORD ON request with filename: %s\n", file_name);
			else
				printf("Received DEBUG RECORD OFF request with filename: %s\n", file_name);
#endif
			if(system_status_set_debug_file(debugEn, file_name)!=0)
			{
				generic_device_t * dev = system_status_get_device_from_id(DEFAULT_TABLE_HUB_ID);

				cmd_gen_dev_status_ans(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID,dev,0,&TXcmd);
	//			printf("Send dev status\n");
				send_command(&TXcmd);
				cmd_gen_dev_status_refresh(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID, &TXcmd);
	//			printf("Send refresh\n");
				send_command(&TXcmd);

			}
			break;
		}
		case CMD_SET_USB_AUDIO_SRC:
		{
			uint8_t usb_src;
			cmd_dec_usb_audio_src(&usb_src,cmd);
			system_status_set_usb_src(usb_src);
			system_status_set_rebuild_audio(1);
			if(usb_src!=USB_SRC_DEBUG)
				system_status_set_channel_to_play(13);
			break;
		}
		case CMD_SET_CH_PLAY:
		{
			uint8_t ch;
			cmd_dec_ch_to_play(&ch, cmd);
			int auxCh = ch;
			system_status_set_channel_to_play(auxCh);
			printf("Se ch to play to %d\n", auxCh);
			break;
		}
		case CMD_SET_SIGNAL_GEN:
		{
			printf("Forwarding set signal gen command\n");
			send_command(cmd);
			break;
		}
		case CMD_SET_VOLUME:
		{

			uint8_t vol;
			cmd_dec_set_volume(&vol,cmd);
			int ret = system_status_set_volume(cmd->sender,vol);


			if(ret>0)
			{
				printf("Sending volume to all; %d\n",vol);
				cmd_gen_set_volume(0,DEFAULT_TABLE_HUB_ID,vol,&TXcmd);
				send_command(&TXcmd);
			}
			break;
		}

		/********************
		 * SPP
		 ********************/
		case CMD_SEND_DEBUG_MSG:
		{
			if(cmd->receiver==DEFAULT_TABLE_HUB_ID)
			{
				char commandString[MAX_DATA_LEN];
				cmd_dec_debug_msg(commandString, cmd);
				system_status_spp_set_cmd_string(commandString);
				system_status_spp_get_status();
			}
			else
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
			case CMD_FW_DOWNL_START:
			{
				uint32_t packetsNumber;
				uint32_t packetSize;
				uint8_t dev_type;

				printf("Start download update file from gui\n");

				cmd_dec_fw_down_start(&packetsNumber, &packetSize, &dev_type, cmd);

				//prepare file storing for incoming FW update
				if(fw_update_start_from_gui(packetsNumber, packetSize, dev_type)==0)
				{
					printf("Sending ack\n");
					cmd_gen_fw_ack_down(DEFAULT_TABLE_HUB_ID, cmd->sender, &TXcmd);
				}
				else
				{
					printf("Sending nack\n");
					cmd_gen_fw_nack_down(DEFAULT_TABLE_HUB_ID, cmd->sender, &TXcmd);
				}
				send_command( &TXcmd);
				break;
			}
			case CMD_FW_UPDATE_START:
			{
				if(cmd->receiver==DEFAULT_TABLE_HUB_ID)
				{
					uint8_t dev_type;
					uint8_t dev_id;

					cmd_dec_fw_update_start( &dev_type, &dev_id, cmd);

					//Check the stored file, if OK, proceed
					if(!fw_update_start_to_dev(dev_type, dev_id)==0)
					{
						printf("Sending nack\n");
						cmd_gen_fw_nack_start(DEFAULT_TABLE_HUB_ID, cmd->sender, &TXcmd);
					}

					if(dev_id!= DEFAULT_TABLE_HUB_ID)
					{
						//send update start command to the destination device.
						printf("Start fw update type %d id %d\n",dev_type,dev_id);
						cmd_gen_fw_update_start(dev_id, DEFAULT_TABLE_HUB_ID,dev_type, dev_id,&TXcmd);
						send_command( &TXcmd);
					}
					else
					{
						//update for the table hub. Start it by switching state to SEND_DEV_FILE
						fw_update_set_state(SEND_DEV_FILE);
					}
					if((dev_type==MICPOD_DEVICE_TYPE)||(dev_type==MICPOD_HUB_DEVICE_TYPE))
					{
						uint8_t dev_id_list[7];
						int dev_num;
						int i;
						if(dev_id==0)
						{
							//Update to all
							//Get alive list
							//TODO: handle disconnections
							system_status_get_alive_list(dev_type, dev_id_list, &dev_num);
						}
						else
						{
							//Update single
							dev_id_list[0] = dev_id;
							dev_num=1;

						}
						fw_update_init_dev_table(dev_id_list, dev_num);
					}
				}
				else
				{
					printf("Forwarding start cmd\n");
					send_command( cmd);
				}

				break;
			}
			case CMD_FW_UPDATE_PKT:
			{
				if(cmd->receiver==DEFAULT_TABLE_HUB_ID)
				{
					uint8_t packet[MAX_PACKET_LEN];
					uint16_t packetSize;
					uint32_t packetSequence;
					uint32_t lastSeqNum;

					cmd_dec_fw_update_packet(packet, &packetSize, &packetSequence, cmd);

					//check if seq number is right
					if(fw_update_validate_packet(packetSequence, &lastSeqNum)<0)
					{
						cmd_gen_fw_nack_packet(DEFAULT_TABLE_HUB_ID, cmd->sender, lastSeqNum, &TXcmd);
						send_command( &TXcmd);
						printf("Error validate packet\n");
						break;
					}
					if(cnt%100==0)
					{
						printTimeMs();
						printf("CMD_FW_UPDATE_PKT %d arrived\n",packetSequence);
					}
					//write update packet to file
					fw_update_put_packet(packet, packetSize);
					cnt++;
				}
				else
				{
//					printf("Send packet to %d\n",cmd->receiver);
					//send update packet to receiver device
					send_command(cmd);
					sleep_ms(4);
				}
				break;
			}
			case CMD_FW_UPDATE_PERC_FILE:
			{
				if(cmd->receiver!=DEFAULT_TABLE_HUB_ID)
					send_command(cmd);
				else
					printf("Error: this message should not exist\n");
				break;
			}
			case CMD_FW_UPDATE_END:
			{
				if(cmd->receiver==DEFAULT_TABLE_HUB_ID)
				{
					printf("CMD_FW_UPDATE_END arrived\n");

					//Close file, unizip it, check MD5
					int status = fw_update_end_from_gui();

					if(status)
					{
						printf("CMD_FW_UPDATE_END nack send\n");
						cmd_gen_fw_nack_file(DEFAULT_TABLE_HUB_ID, cmd->sender, &TXcmd);
						send_command( &TXcmd);
						break;
					}

					printf("CMD_FW_UPDATE_END ack send\n");
					cmd_gen_fw_ack_file(DEFAULT_TABLE_HUB_ID, cmd->sender, &TXcmd);
					send_command( &TXcmd);
				}
				else
				{
					printf("CMD_FW_UPDATE_END forward to id %d\n",cmd->receiver);
					send_command(cmd);
				}
				break;
			}
			case CMD_FW_UPDATE_ACK_START:
			{
				printf("Dev ack start: %d\n",cmd->sender);
				
				//check if still waiting for ack
				fw_update_set_ack(cmd->sender, SEND_DEV_FILE);

//				fw_update_set_state(SEND_DEV_FILE);
				//printf("Dev ack start\n");
				//TODO:
				//Handle multiple ids
				break;
			}
			case CMD_FW_UPDATE_NACK_START:
			{
				printf("Dev nack start\n");
				//TODO: error
				break;
			}
			case CMD_FW_UPDATE_ACK_PACKET:
			{
				printf("Dev ack packet\n");
				//should not happen
				break;
			}
			case CMD_FW_UPDATE_NACK_PACKET:
			{
				uint32_t sequence;
				cmd_dec_fw_nack_packet(&sequence,cmd);
				printf("Dev nack packet %d\n",sequence);
				fw_update_set_rollback(sequence);

				//TODO: recover procedure
				break;
			}
			case CMD_FW_UPDATE_ACK_FILE:
			{

				printf("Dev ack file: %d\n",cmd->sender);
//				fw_update_set_state(WAIT_ERASE_FLASH);
				fw_update_set_ack(cmd->sender, WAIT_ERASE_FLASH);

				break;
			}
			case CMD_FW_UPDATE_NACK_FILE:
			{
				printf("Dev nack file\n");
				//TODO: send file back
				break;
			}
			case CMD_FW_UPDATE_PERC_FLASH:
			{
				uint8_t perc;
				if(fw_update_get_state()!=WAIT_ACK_COMPLETE)
					fw_update_set_ack(cmd->sender, WAIT_ACK_COMPLETE);
				else
				{
//				fw_update_set_state(WAIT_ACK_COMPLETE);
					//write to flash memory command
					cmd_dec_fw_flash_perc( &perc, cmd);
					printf("Flash write from %d: %d %%\n",cmd->sender,perc);
					cmd_gen_fw_flash_perc(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID,perc,&TXcmd);
					send_command( &TXcmd);
				}
				break;
			}
			case CMD_FW_UPDATE_ACK_FLASH:
			{
				fw_update_set_ack(cmd->sender, SEND_RESET);
				printf("Dev ack flash: update finished id : %d\n",cmd->sender);
//				fw_update_set_state(IDLE);
				if(fw_update_get_state()==SEND_RESET)
				{
					cmd_gen_fw_flash_perc(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID,100,&TXcmd);
					send_command( &TXcmd);

					cmd_gen_fw_ack_flash(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID,&TXcmd);
					send_command( &TXcmd);
				}
				break;
			}
			case CMD_FW_SEND_RESET:
			{
				send_command(cmd);
				break;
			}
			case CMD_FW_UPDATE_NACK_FLASH:
			{
				printf("Dev nack flash\n");
				//error in writing to flash memory
				fw_update_set_state(IDLE);
				cmd_gen_fw_nack_flash(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID,&TXcmd);
				send_command( &TXcmd);
				break;
			}
			default:
			{
				break;
			}
		}


	return;
}
