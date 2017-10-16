#ifndef COMMAND_GENERATOR_H__
#define  COMMAND_GENERATOR_H__

#include "commands.h"
#include "status.h"
#include "version.h"

#ifdef __cplusplus
extern "C" {
#endif


//General
void cmd_gen_sys_status_ans( uint8_t sender, uint8_t receiver, system_status_t * status, tdm_command_t * command);
void cmd_dec_sys_status_ans(system_status_t * status, tdm_command_t * command);

void cmd_gen_dev_status_ans( uint8_t sender, uint8_t receiver, generic_device_t * dev, uint8_t count, tdm_command_t * command);
void cmd_dec_dev_status_ans(generic_device_t * dev, uint8_t *count, tdm_command_t * command);

void cmd_gen_debug_msg(uint8_t sender, uint8_t receiver, char * msgString, tdm_command_t * command);
void cmd_dec_debug_msg(char * msgString, tdm_command_t * command);

void cmd_gen_set_id(uint8_t receiver, uint8_t sender,uint64_t unique_id, uint8_t id, tdm_command_t * command);
void cmd_dec_set_id(uint64_t *unique_id, uint8_t *id, tdm_command_t * command);

void cmd_gen_stop_asking(uint8_t sender,uint64_t unique_id, tdm_command_t * command);
void cmd_dec_stop_asking(uint64_t *unique_id, tdm_command_t * command);

void cmd_gen_im_here(uint8_t receiver,uint64_t unique_id, uint8_t type, tdm_command_t * command);
void cmd_dec_im_here(uint64_t *unique_id, uint8_t *type, tdm_command_t * command);


void cmd_gen_poll(uint8_t sender,uint8_t receiver,tdm_command_t * command);
void cmd_gen_alive(uint8_t sender,uint8_t receiver,tdm_command_t * command);

void cmd_gen_dev_status_refresh(uint8_t sender,uint8_t receiver,tdm_command_t * command);

void cmd_gen_get_dev_info(uint8_t sender,uint8_t receiver, tdm_command_t * command);

void cmd_gen_get_sys_status(uint8_t receiver,uint8_t sender, tdm_command_t * command);

void cmd_gen_ret_dev_info(uint8_t sender,uint8_t receiver, dev_info_t *dev_info, tdm_command_t * command);
void cmd_dec_ret_dev_info(dev_info_t *dev_info, tdm_command_t * command);

void cmd_gen_ret_stm_ver(uint8_t sender,uint8_t receiver, uint32_t ver, tdm_command_t * command);
void cmd_dec_ret_stm_ver(uint32_t *ver, tdm_command_t * command);


void cmd_gen_too_many_dev_error(uint8_t receiver, uint8_t sender, uint8_t dev_type, tdm_command_t * command);
void cmd_dec_too_many_dev_error(uint8_t *dev_type, tdm_command_t * command);

//micpod
void cmd_gen_cpu_load(uint8_t sender,uint8_t receiver,uint8_t cpu,tdm_command_t * command);
void cmd_dec_cpu_load(uint8_t *cpu,tdm_command_t * command);

void cmd_gen_set_led_micpod(uint8_t receiver, uint8_t sender,uint8_t val, tdm_command_t * command);
void cmd_dec_set_led_micpod(uint8_t * val, tdm_command_t * command);

void cmd_gen_set_postfilter_en(uint8_t receiver, uint8_t sender,uint8_t en, tdm_command_t * command);
void cmd_dec_set_postfilter_en(uint8_t * en, tdm_command_t * command);

void cmd_gen_set_mute_micpod(uint8_t receiver, uint8_t sender,uint8_t mute, tdm_command_t * command);
void cmd_dec_set_mute_micpod(uint8_t * mute, tdm_command_t * command);

void cmd_gen_set_mute_sys(uint8_t receiver, uint8_t sender,uint8_t mute, tdm_command_t * command);
void cmd_dec_set_mute_sys(uint8_t * mute, tdm_command_t * command);

void cmd_gen_set_debug_micpod(uint8_t sender, uint8_t debug, uint8_t micpod_id, tdm_command_t * command);
void cmd_dec_set_debug_micpod(uint8_t * debug, uint8_t *micpod_id, tdm_command_t * command);

void cmd_gen_info_mute(uint8_t receiver, uint8_t sender,uint8_t mute, tdm_command_t * command);
void cmd_dec_info_mute(uint8_t * mute, tdm_command_t * command);

void cmd_gen_set_listen_micpod(uint8_t sender, uint8_t micpod_id, tdm_command_t * command);
void cmd_dec_set_listen_micpod(uint8_t *micpod_id, tdm_command_t * command);

//routing
void cmd_gen_set_routing(uint8_t receiver, uint8_t sender,uint8_t * routingBuf, tdm_command_t * command);
void cmd_dec_set_routing(uint8_t * routingBuf, tdm_command_t * command);

void cmd_gen_set_slave_interface(uint8_t receiver, uint8_t sender,uint8_t intNum, uint8_t en, tdm_command_t * command);
void cmd_dec_set_slave_interface(uint8_t * intNum, uint8_t * en, tdm_command_t * command);

void cmd_gen_info_interface_lock(uint8_t receiver, uint8_t sender,uint8_t intNum, uint8_t locked, tdm_command_t * command);
void cmd_dec_info_interface_lock(uint8_t * intNum, uint8_t * locked, tdm_command_t * command);

void cmd_gen_fw_update_start(uint8_t receiver, uint8_t sender, uint8_t dev_type, uint8_t dev_id, tdm_command_t * command);
void cmd_dec_fw_update_start(uint8_t *dev_type, uint8_t *dev_id, tdm_command_t * command);

void cmd_gen_fw_down_start(uint8_t receiver, uint8_t sender, uint32_t packetsNumber, uint32_t packetSize, uint8_t dev_type, tdm_command_t * command);
void cmd_dec_fw_down_start( uint32_t *packetsNumber, uint32_t *packetSize, uint8_t *dev_type, tdm_command_t * command);

void cmd_gen_fw_update_zynq_start(uint8_t receiver, uint8_t sender, uint32_t packetsNumber, uint32_t packetSize, tdm_command_t * command);
void cmd_dec_fw_update_zynq_start( uint32_t *packetsNumber, uint32_t *packetSize, tdm_command_t * command);

void cmd_gen_fw_update_packet(uint8_t receiver, uint8_t sender, uint8_t * packet, uint16_t packetSize, uint32_t packetSquence, tdm_command_t * command);
void cmd_dec_fw_update_packet(uint8_t * packet, uint16_t *packetSize, uint32_t *packetSquence, tdm_command_t * command);

void cmd_gen_fw_update_end( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_ack_down( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_nack_down( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_ack_packet( uint8_t sender, uint8_t receiver, uint32_t packetSquence, tdm_command_t * command);
void cmd_dec_fw_ack_packet(uint32_t *packetSquence, tdm_command_t * command);

void cmd_gen_fw_nack_packet( uint8_t sender, uint8_t receiver, uint32_t packetSquence, tdm_command_t * command);
void cmd_dec_fw_nack_packet(uint32_t *packetSquence, tdm_command_t * command);

void cmd_gen_fw_ack_file( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_nack_file( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_ack_flash( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_nack_flash( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_file_perc( uint8_t sender, uint8_t receiver, uint8_t perc, tdm_command_t * command);
void cmd_dec_fw_file_perc( uint8_t *perc, tdm_command_t * command);

void cmd_gen_fw_flash_perc( uint8_t sender, uint8_t receiver, uint8_t perc, tdm_command_t * command);
void cmd_dec_fw_flash_perc( uint8_t *perc, tdm_command_t * command);

void cmd_gen_fw_ack_start( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_nack_start( uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_fw_send_reset(uint8_t sender, uint8_t receiver, tdm_command_t * command);

void cmd_gen_set_debug_file(uint8_t receiver, uint8_t sender, uint8_t en,  char *file_name, tdm_command_t * command);
void cmd_dec_set_debug_file(uint8_t *en,  char *file_name, tdm_command_t * command);

void cmd_gen_usb_audio_connected(uint8_t receiver, uint8_t sender, uint8_t connected, tdm_command_t * command);
void cmd_dec_usb_audio_connected(uint8_t *connected, tdm_command_t * command);

void cmd_gen_usb_audio_src(uint8_t receiver, uint8_t sender, uint8_t id, tdm_command_t * command);
void cmd_dec_usb_audio_src(uint8_t *id, tdm_command_t * command);

void cmd_gen_ch_to_play(uint8_t receiver, uint8_t sender, uint8_t ch, tdm_command_t * command);
void cmd_dec_ch_to_play(uint8_t *ch, tdm_command_t * command);

void cmd_gen_set_signal_gen(uint8_t receiver, uint8_t sender, uint8_t sgn, tdm_command_t * command);
void cmd_dec_set_signal_gen(uint8_t *sgn, tdm_command_t * command);

void cmd_gen_set_volume(uint8_t receiver, uint8_t sender, uint8_t volume, tdm_command_t * command);
void cmd_dec_set_volume(uint8_t *volume, tdm_command_t * command);

#ifdef __cplusplus
}
#endif

#endif
