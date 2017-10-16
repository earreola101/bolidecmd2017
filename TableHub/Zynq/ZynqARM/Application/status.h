#ifndef STATUS_H__
#define STATUS_H__

#include <stdint.h>
#include "version.h"
#include "command_queue.h"

#define MICPOD_MAX_N			7
#define MICPOD_HUB_MAX_N		3
#define MAX_INTERFACE_NUMBER 	(MICPOD_MAX_N*1+MICPOD_HUB_MAX_N*3+1*2)

#define MICPOD_MUTE				1
#define MICPOD_UNMUTE			0

#define MICPOD_POSTFILTER_ON	1
#define MICPOD_POSTFILTER_OFF	0
#define MICPOD_DEBUG_ON			1
#define MICPOD_DEBUG_OFF		0


#define SYSTEM_MUTE				1
#define SYSTEM_UNMUTE			0

#define MICPOD_LED_ON			1
#define MICPOD_LED_OFF			0

#define ALIVE_RESET_COUNT		20

#define MICPOD_DEVICE_TYPE		0x11
#define TV_HUB_DEVICE_TYPE		0x12
#define TABLE_HUB_DEVICE_TYPE	0x13
#define MICPOD_HUB_DEVICE_TYPE	0x14
#define STM32_DEVICE_TYPE		0x15
#define PC_DEVICE_TYPE			0x16

#define ROUTING_TABLE_LEN_BYTES	15


#define TAG_PROGRAM				0x00
#define TAG_SERIAL_STM			0x01
#define TAG_SERIAL_CMD			0x02
#define TAG_BUS_SPLITTER		0x03
#define TAG_BUS_TV				0x04
#define TAG_BUS_MIC				0x05

#define DEFAULT_UNINIT_ID		0xFF

#define DEFAULT_PC_ID			0xF0
#define DEFAULT_TABLE_HUB_ID	0x10
#define DEFAULT_MICPOD_ID		0x20
#define DEFAULT_MICPOD_HUB_ID	0x30
#define DEFAULT_TV_HUB_ID		0x40
#define DEFAULT_STM32_ID		0x50
#define DEFAULT_SPK_HUB_ID		0x60
#define DEFAULT_BROADCAST_ID	0x00

#define AUDIO_TAG_SOUT			0x00
#define AUDIO_TAG_SIN0			0x01
#define AUDIO_TAG_SIN1			0x02
#define AUDIO_TAG_SIN2			0x03
#define AUDIO_TAG_SIN3			0x04
#define AUDIO_TAG_ROUT			0x05
#define AUDIO_TAG_SPK_L			0x06
#define AUDIO_TAG_SPK_R			0x07

#define AUDIO_TAG_INVALID		0xFF
#define AUDIO_INVALID_ROUTING	45
#define AUDIO_TV_HUB_SPK_L		15
#define AUDIO_TV_HUB_SPK_R		16
#define AUDIO_TABLE_HUB_SPK_L	17
#define AUDIO_TABLE_HUB_SPK_R	18

#define USB_SRC_TABLE_HUB		0x01
#define USB_SRC_TV_HUB			0x02
#define USB_SRC_DEBUG			0x03
#define USB_SRC_SINEWAVE		0x04

#define DEBUG_FILE_MAX_LEN		50
typedef struct micpod_specific_t{
	uint8_t mute;
	uint8_t ledOn;
	uint8_t cpuLoad;
	uint8_t postFilter;
}micpod_specific_t;

#define SPP_PEQ_NUM_BANDS 6
typedef struct spp_status_t
{
	// PEQ
    int peq_enable;
    int peq_types[SPP_PEQ_NUM_BANDS];
    float peq_frequencies[SPP_PEQ_NUM_BANDS];
    float peq_gains[SPP_PEQ_NUM_BANDS];
    float peq_Qs[SPP_PEQ_NUM_BANDS];

    // High Pass Mode
	int	high_pass_mode;

    // Limiter 
    int	lim_enable;
    float lim_threshold;

}spp_status_t;

typedef struct table_hub_specific_t{
	uint8_t listenId;
	char debug_file[DEBUG_FILE_MAX_LEN];
	uint8_t debug_enabled;
	uint8_t usb_connected;
	uint8_t usb_source;
	int ch_to_listen;
	uint8_t volume;
	uint8_t mute;
	spp_status_t spp_status;
}table_hub_specific_t;

typedef struct tv_hub_specific_t{
	uint8_t usb_connected;
	uint8_t volume;
}tv_hub_specific_t;

typedef struct micpod_hub_specific_t{
	uint8_t ledOn;
}micpod_hub_specific_t;

typedef struct generic_device_t
{
	uint8_t id;
	uint8_t alive;
	uint8_t type;
	dev_info_t dev_info;
	micpod_specific_t micpod_specific;
	table_hub_specific_t table_hub_specific;
	tv_hub_specific_t tv_hub_specific;
	micpod_hub_specific_t micpod_hub_specific;
	uint8_t audio_table[ROUTING_TABLE_LEN_BYTES];
	uint8_t audio_id[ROUTING_TABLE_LEN_BYTES];
	uint8_t audio_tag[ROUTING_TABLE_LEN_BYTES];
	uint8_t debug_mode;
	uint8_t micCh;
	uint8_t spkCh;
	uint8_t int_num;
	uint8_t intLocked[3];
	uint8_t intEnabled[3];
	struct generic_device_t * intDevice[3];
	uint8_t intId[3];
	struct generic_device_t * parent;
	uint8_t parentId;
	uint8_t parentIntNum;
	uint8_t tag;
}generic_device_t;

typedef struct system_specific_t
{
	int reset_candidates;
	int rebuild_audio;
}system_specific_t;

typedef struct system_status_t
{
	generic_device_t micpod_hubs[MICPOD_HUB_MAX_N];
	generic_device_t micpods[MICPOD_MAX_N];
	generic_device_t tv_hub;
	generic_device_t table_hub;
	system_specific_t system_spec;

}system_status_t;


void system_status_init(command_queue_t *queue);

//utility
uint8_t system_status_assign_device_id(uint8_t device_type, uint64_t unique_id, uint8_t tag, generic_device_t ** device_assigned);
void system_status_create_poll_new_list(uint8_t **listDev, uint8_t **listInt, int *listLen);
int system_status_get_alive_death_diff(system_status_t * oldSystem,system_status_t * newSystem);
void system_status_print_device_tree();
generic_device_t * system_status_get_device_from_id(uint8_t id);
int system_status_get_micpod_index_from_id(uint8_t id);
void system_status_get_all(system_status_t * status);
void system_status_rebuild_dependencies(system_status_t * status);

void system_status_update_audio_tables();
int system_status_get_rebuild_audio();
void system_status_set_rebuild_audio(int val);
//cmd exec
void system_status_set_cpu_load(uint8_t cpu, uint8_t id);
void system_status_set_alive(uint8_t id);
void system_status_alive_dec();
void system_status_get_alive_list(uint8_t dev_type, uint8_t * dev_id_list, int * dev_num);

void system_status_set_micpod_led(uint8_t micId, uint8_t status);
uint8_t system_status_get_micpod_led(uint8_t micId);

void system_status_set_micpod_mute(uint8_t micId, uint8_t status);
uint8_t system_status_get_micpod_mute(uint8_t micId);

void system_status_set_sys_mute(uint8_t mute);
uint8_t system_status_get_sys_mute();

void system_status_set_debug_micpod(uint8_t en, uint8_t micId);



void system_status_set_postfilter_micpod(uint8_t en, uint8_t micId);
uint8_t system_status_get_micpod_postfilter(uint8_t micId);
int system_status_set_slave_interface(uint8_t id, uint8_t intNum, uint8_t en);
int system_status_info_interface_lock(uint8_t id, uint8_t intNum, uint8_t locked);

int system_status_ret_dev_info(uint8_t id, dev_info_t * info);
void system_status_ret_stm_ver(uint32_t ver);


int system_status_update_dev_struct(generic_device_t * dev, uint8_t dev_count);
void system_status_set_listen_micpod(uint8_t micId);
uint8_t system_status_get_listen_micpod();

int system_status_get_channel_from_id(uint8_t id);


int system_status_set_debug_file(uint8_t en, char * file_name);
uint8_t system_status_get_debug_en();
void system_status_get_debug_file_name(char * file_name);

void system_status_set_usb_src(uint8_t usb_src);
uint8_t system_status_get_usb_src(void);
void system_status_set_usb_connected(uint8_t id, uint8_t status);
int system_status_get_usb_connected(uint8_t id);
int system_status_get_channel_to_play();
void system_status_set_channel_to_play(int ch);
int system_status_get_play_wave();

int system_status_set_volume(uint8_t id, uint8_t vol);

#ifndef WIN32
// SPP
void system_status_spp_process(float *pSrc, float *pDst);
int system_status_spp_set_cmd_string(char* CommandString);
int system_status_spp_printf(const char *commandString);
void system_status_spp_init_peq();
void system_status_spp_get_status();
#endif

#endif