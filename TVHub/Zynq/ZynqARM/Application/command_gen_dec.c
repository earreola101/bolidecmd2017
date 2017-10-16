#include "command_gen_dec.h"
#include "string.h"

/*********************************************************
 * COMMAND GENERATION
 **********************************************************/

void cmd_dec_sys_status_ans(system_status_t * status, tdm_command_t * command)
{
	memcpy(status, command->data, sizeof(system_status_t));
}

void cmd_gen_debug_msg(uint8_t sender, uint8_t receiver, char * msgString, tdm_command_t * command)
{
	int i=0;
	int len=0;
	while(1)
	{
		if(msgString[i]==0)
		{
			len=i+1;
			break;
		}
		i++;
	}
	command->command=CMD_SEND_DEBUG_MSG;
	command->len=len;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	memcpy(command->data, msgString, command->len);
}

void cmd_dec_debug_msg(char * msgString, tdm_command_t * command)
{
	memcpy(msgString, command->data, command->len);
}

void cmd_gen_sys_status_ans( uint8_t sender, uint8_t receiver, system_status_t * status, tdm_command_t * command)
{
	command->command=CMD_SYS_STATUS_ANS;
	command->len=sizeof(system_status_t);
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	memcpy(command->data, status, command->len);
}

void cmd_gen_dev_status_ans( uint8_t sender, uint8_t receiver, generic_device_t * dev, uint8_t count, tdm_command_t * command)
{
	command->command=CMD_DEV_STATUS_ANS;
	command->len=sizeof(generic_device_t)+1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=count;
	memcpy(&command->data[1], dev, command->len);
}

void cmd_dec_dev_status_ans(generic_device_t * dev, uint8_t *count, tdm_command_t * command)
{
	*count = command->data[0];
	memcpy(dev, &command->data[1], command->len);
}

void cmd_gen_set_id(uint8_t receiver, uint8_t sender,uint64_t unique_id, uint8_t id, tdm_command_t * command)
{
	command->command=CMD_SET_DEVICE_ID;
	command->len=sizeof(unique_id)+1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	memcpy(command->data, &unique_id, sizeof(unique_id));
	command->data[sizeof(unique_id)]=id;
}

void cmd_dec_set_id(uint64_t *unique_id, uint8_t *id, tdm_command_t * command)
{
	memcpy( unique_id, command->data, sizeof(*unique_id));
	*id = command->data[sizeof(*unique_id)];
}
void cmd_gen_stop_asking(uint8_t sender,uint64_t unique_id, tdm_command_t * command)
{
	command->command=CMD_STOP_ASKING;
	command->len=sizeof(unique_id);
	command->sender=sender;
	command->receiver=DEFAULT_UNINIT_ID;
	command->sequence=0;
	memcpy(command->data, &unique_id, sizeof(unique_id));
}

void cmd_dec_stop_asking(uint64_t *unique_id, tdm_command_t * command)
{
	memcpy( unique_id, command->data, sizeof(*unique_id));
}

void cmd_gen_im_here(uint8_t receiver,uint64_t unique_id, uint8_t type, tdm_command_t * command)
{
	command->command=CMD_IM_HERE;
	command->len=sizeof(unique_id)+1;
	command->sender=DEFAULT_UNINIT_ID;
	command->receiver=receiver;
	command->sequence=0;
	memcpy(command->data, &unique_id, sizeof(unique_id));
	command->data[sizeof(unique_id)]=type;
}

void cmd_dec_im_here(uint64_t *unique_id, uint8_t *type, tdm_command_t * command)
{
	memcpy( unique_id, command->data, sizeof(*unique_id));
	*type = command->data[sizeof(*unique_id)];
}


void cmd_gen_poll(uint8_t sender,uint8_t receiver,tdm_command_t * command)
{
	command->command=CMD_POLL;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;

}
void cmd_gen_alive(uint8_t sender,uint8_t receiver,tdm_command_t * command)
{
	command->command=CMD_ALIVE;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_dev_status_refresh(uint8_t sender,uint8_t receiver,tdm_command_t * command)
{
	command->command=CMD_DEV_STATUS_REFRESH;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_cpu_load(uint8_t sender,uint8_t receiver,uint8_t cpu,tdm_command_t * command)
{
	command->command=CMD_SEND_CPU_LOAD;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=cpu;
}

void cmd_dec_cpu_load(uint8_t *cpu,tdm_command_t * command)
{
	*cpu = command->data[0];
}

void cmd_gen_get_dev_info(uint8_t sender,uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_GET_DEV_INFO;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_get_sys_status(uint8_t receiver,uint8_t sender, tdm_command_t * command)
{
	command->command=CMD_GET_SYS_STATUS;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_ret_dev_info(uint8_t sender,uint8_t receiver, dev_info_t *dev_info, tdm_command_t * command)
{
	command->command=CMD_RET_DEV_INFO;
	command->len=sizeof(dev_info_t);
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	memcpy(command->data, dev_info, sizeof(dev_info_t));
}

void cmd_dec_ret_dev_info(dev_info_t *dev_info, tdm_command_t * command)
{
	memcpy(dev_info, command->data, sizeof(dev_info_t));
}


void cmd_gen_ret_stm_ver(uint8_t sender,uint8_t receiver, uint32_t ver, tdm_command_t * command)
{
	command->command=CMD_RET_STM_VER;
	command->len=sizeof(uint32_t);
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	memcpy(command->data, &ver, sizeof(uint32_t));
}

void cmd_dec_ret_stm_ver(uint32_t *ver, tdm_command_t * command)
{
	memcpy(ver, command->data, sizeof(uint32_t));
}

void cmd_gen_set_led_micpod(uint8_t receiver, uint8_t sender,uint8_t val, tdm_command_t * command)
{
	command->command=CMD_SET_LED_MICPOD;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=val;
}

void cmd_dec_set_led_micpod(uint8_t * val, tdm_command_t * command)
{
	*val = command->data[0];
}

void cmd_gen_set_postfilter_en(uint8_t receiver, uint8_t sender,uint8_t en, tdm_command_t * command)
{
	command->command=CMD_SET_POST_FILER_EN;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=en;
}

void cmd_dec_set_postfilter_en(uint8_t * en, tdm_command_t * command)
{
	*en = command->data[0];
}

void cmd_gen_set_mute_micpod(uint8_t receiver, uint8_t sender,uint8_t mute, tdm_command_t * command)
{
	command->command=CMD_SET_MUTE_MICPOD;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=mute;
}

void cmd_dec_set_mute_micpod(uint8_t * mute, tdm_command_t * command)
{
	*mute = command->data[0];
}

void cmd_gen_set_mute_sys(uint8_t receiver, uint8_t sender,uint8_t mute, tdm_command_t * command)
{
	command->command=CMD_MUTE_SYSTEM;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=mute;
}

void cmd_dec_set_mute_sys(uint8_t * mute, tdm_command_t * command)
{
	*mute = command->data[0];
}

void cmd_gen_set_listen_micpod(uint8_t sender, uint8_t micpod_id, tdm_command_t * command)
{
	command->command=CMD_SET_LISTEN_MODE;
	command->len=1;
	command->sender=sender;
	command->receiver=DEFAULT_TABLE_HUB_ID;
	command->sequence=0;
	command->data[0]=micpod_id;
}

void cmd_dec_set_listen_micpod(uint8_t *micpod_id, tdm_command_t * command)
{
	*micpod_id=command->data[0];
}

void cmd_gen_set_debug_micpod(uint8_t sender, uint8_t debug, uint8_t micpod_id, tdm_command_t * command)
{
	command->command=CMD_SET_DEBUG_MODE;
	command->len=2;
	command->sender=sender;
	command->receiver=DEFAULT_TABLE_HUB_ID;
	command->sequence=0;
	command->data[0]=debug;
	command->data[1]=micpod_id;
}

void cmd_dec_set_debug_micpod(uint8_t * debug, uint8_t *micpod_id, tdm_command_t * command)
{
	*debug = command->data[0];
	*micpod_id=command->data[1];
}

void cmd_gen_info_mute(uint8_t receiver, uint8_t sender,uint8_t mute, tdm_command_t * command)
{
	command->command=CMD_INFO_MUTE_MICPOD;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=mute;
}

void cmd_dec_info_mute(uint8_t * mute, tdm_command_t * command)
{
	*mute = command->data[0];
}
void cmd_gen_set_routing(uint8_t receiver, uint8_t sender,uint8_t * routingBuf, tdm_command_t * command)
{
	command->command=CMD_SET_ROUTING;
	command->len=ROUTING_TABLE_LEN_BYTES;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	memcpy(command->data, routingBuf, ROUTING_TABLE_LEN_BYTES);
}

void cmd_dec_set_routing(uint8_t * routingBuf, tdm_command_t * command)
{
	memcpy(routingBuf, command->data, ROUTING_TABLE_LEN_BYTES);
}

void cmd_gen_set_slave_interface(uint8_t receiver, uint8_t sender,uint8_t intNum, uint8_t en, tdm_command_t * command)
{
	command->command=CMD_SET_SLAVE_INTERFACE;
	command->len=2;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=intNum;
	command->data[1]=en;
}

void cmd_dec_set_slave_interface(uint8_t * intNum, uint8_t * en, tdm_command_t * command)
{
	*intNum = command->data[0];
	*en = command->data[1];
}

void cmd_gen_info_interface_lock(uint8_t receiver, uint8_t sender,uint8_t intNum, uint8_t locked, tdm_command_t * command)
{
	command->command=CMD_INFO_INTERFACE_LOCK;
	command->len=2;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=intNum;
	command->data[1]=locked;
}

void cmd_dec_info_interface_lock(uint8_t * intNum, uint8_t * locked, tdm_command_t * command)
{
	*intNum = command->data[0];
	*locked = command->data[1];
}


void cmd_gen_fw_update_start(uint8_t receiver, uint8_t sender, uint8_t dev_type, uint8_t dev_id, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_START;
	command->len=2;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;

	command->data[0] = dev_type;
	command->data[1] = dev_id;
}

void cmd_dec_fw_update_start(uint8_t *dev_type, uint8_t *dev_id, tdm_command_t * command)
{
	*dev_type = command->data[0];
	*dev_id = command->data[1];
}

void cmd_gen_fw_down_start(uint8_t receiver, uint8_t sender, uint32_t packetsNumber, uint32_t packetSize, uint8_t dev_type, tdm_command_t * command)
{
	command->command=CMD_FW_DOWNL_START;
	command->len=9;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;

	memcpy(&command->data[0], &packetsNumber, 4);
	memcpy(&command->data[4], &packetSize, 4);
	command->data[8] = dev_type;
}

void cmd_dec_fw_down_start( uint32_t *packetsNumber, uint32_t *packetSize, uint8_t *dev_type, tdm_command_t * command)
{
	memcpy(packetsNumber, &command->data[0], 4);
	memcpy(packetSize, &command->data[4], 4);
	*dev_type = command->data[8];
}

void cmd_gen_fw_update_zynq_start(uint8_t receiver, uint8_t sender, uint32_t packetsNumber, uint32_t packetSize, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_START_ZYNQ;
	command->len=8;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;

	memcpy(&command->data[0], &packetsNumber, 4);
	memcpy(&command->data[4], &packetSize, 4);
}

void cmd_dec_fw_update_zynq_start( uint32_t *packetsNumber, uint32_t *packetSize, tdm_command_t * command)
{
	memcpy(&packetsNumber, &command->data[0], 4);
	memcpy(&packetSize, &command->data[4], 4);
}

void cmd_gen_fw_update_packet(uint8_t receiver, uint8_t sender, uint8_t * packet, uint16_t packetSize, uint32_t packetSquence, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_PKT;
	command->len=packetSize;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=packetSquence;

	memcpy(command->data, packet, packetSize);
}

void cmd_dec_fw_update_packet(uint8_t * packet, uint16_t *packetSize, uint32_t *packetSquence, tdm_command_t * command)
{
	*packetSize = command->len;
	*packetSquence = command->sequence;
	memcpy(packet, command->data,command->len);
}

void cmd_gen_fw_update_end( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_END;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_fw_ack_down( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_DOWNL_ACK_START;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_fw_nack_down( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_DOWNL_NACK_START;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_fw_ack_packet( uint8_t sender, uint8_t receiver, uint32_t packetSquence, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_ACK_PACKET;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=packetSquence;
}

void cmd_dec_fw_ack_packet(uint32_t *packetSquence, tdm_command_t * command)
{
	*packetSquence = command->sequence;
}

void cmd_gen_fw_nack_packet( uint8_t sender, uint8_t receiver, uint32_t packetSquence, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_NACK_PACKET;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=packetSquence;
}

void cmd_dec_fw_nack_packet(uint32_t *packetSquence, tdm_command_t * command)
{
	*packetSquence = command->sequence;
}

void cmd_gen_fw_ack_file( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_ACK_FILE;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_fw_nack_file( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_NACK_FILE;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_fw_ack_flash( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_ACK_FLASH;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_fw_nack_flash( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_NACK_FLASH;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}
void cmd_gen_fw_flash_perc( uint8_t sender, uint8_t receiver, uint8_t perc, tdm_command_t * command)
{
	command->command = CMD_FW_UPDATE_PERC_FLASH;
	command->len = 1;
	command->sender = sender;
	command->receiver = receiver;
	command->sequence = 0;
	command->data[0] = perc;
}
void cmd_dec_fw_flash_perc( uint8_t *perc, tdm_command_t * command)
{
	*perc = command->data[0];
}

void cmd_gen_fw_file_perc( uint8_t sender, uint8_t receiver, uint8_t perc, tdm_command_t * command)
{
	command->command = CMD_FW_UPDATE_PERC_FILE;
	command->len = 1;
	command->sender = sender;
	command->receiver = receiver;
	command->sequence = 0;
	command->data[0] = perc;
}
void cmd_dec_fw_file_perc( uint8_t *perc, tdm_command_t * command)
{
	*perc = command->data[0];
}

void cmd_gen_fw_ack_start( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_ACK_START;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_fw_nack_start( uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_UPDATE_NACK_START;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_fw_send_reset(uint8_t sender, uint8_t receiver, tdm_command_t * command)
{
	command->command=CMD_FW_SEND_RESET;
	command->len=0;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
}

void cmd_gen_too_many_dev_error(uint8_t receiver, uint8_t sender, uint8_t dev_type, tdm_command_t * command)
{
	command->command=CMD_TOO_MANY_DEV_ERROR;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=dev_type;
}

void cmd_dec_too_many_dev_error(uint8_t *dev_type, tdm_command_t * command)
{
	*dev_type = command->data[0];
}

void cmd_gen_set_debug_file(uint8_t receiver, uint8_t sender, uint8_t en,  char *file_name, tdm_command_t * command)
{
	int i=0,len=0;
	while(1)
	{
		if(file_name[i]==0 || i==49)
		{
			len = i+1;
			break;
		}
		i++;
	}


	command->command=CMD_SET_DEBUG_FILE;
	command->len=1+len;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=en;

	for(i=0; i<len; i++)
		command->data[i+1]=file_name[i];

}

void cmd_dec_set_debug_file(uint8_t *en,  char *file_name, tdm_command_t * command)
{
	int i;

	*en = command->data[0];

	for(i=0; i<(command->len-1); i++)
			file_name[i]=command->data[i+1];

}

void cmd_gen_usb_audio_connected(uint8_t receiver, uint8_t sender, uint8_t connected, tdm_command_t * command)
{
	command->command=CMD_DEV_USB_AUDIO_CONN;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=connected;
}

void cmd_dec_usb_audio_connected(uint8_t *connected, tdm_command_t * command)
{
	*connected=command->data[0];
}

void cmd_gen_usb_audio_src(uint8_t receiver, uint8_t sender, uint8_t usb_src, tdm_command_t * command)
{
	command->command=CMD_SET_USB_AUDIO_SRC;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=usb_src;
}

void cmd_dec_usb_audio_src(uint8_t *usb_src, tdm_command_t * command)
{
	*usb_src = command->data[0];
}
void cmd_gen_ch_to_play(uint8_t receiver, uint8_t sender, uint8_t ch, tdm_command_t * command)
{
	command->command=CMD_SET_CH_PLAY;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=ch;
}

void cmd_dec_ch_to_play(uint8_t *ch, tdm_command_t * command)
{
	*ch = command->data[0];
}
void cmd_gen_set_signal_gen(uint8_t receiver, uint8_t sender, uint8_t sgn, tdm_command_t * command)
{
	command->command=CMD_SET_SIGNAL_GEN;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=sgn;
}

void cmd_dec_set_signal_gen(uint8_t *sgn, tdm_command_t * command)
{
	*sgn = command->data[0];
}

void cmd_gen_set_volume(uint8_t receiver, uint8_t sender, uint8_t volume, tdm_command_t * command)
{
	command->command=CMD_SET_VOLUME;
	command->len=1;
	command->sender=sender;
	command->receiver=receiver;
	command->sequence=0;
	command->data[0]=volume;
}

void cmd_dec_set_volume(uint8_t *volume, tdm_command_t * command)
{
	*volume = command->data[0];
}
