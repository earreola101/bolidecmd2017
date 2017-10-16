#ifndef COMMAND_QUEUE_H__
#define COMMAND_QUEUE_H__

#include "commands.h"
#ifdef __linux
#include "utility.h"
#endif
typedef struct command_queue_t {

	tdm_command_t commands[CMD_QUEUE_LENGHT];
	uint8_t	tag[CMD_QUEUE_LENGHT];
	uint16_t cmdWIndex;
	uint16_t cmdRIndex;
	uint16_t availCmds;
	#ifdef __linux
	pthread_mutex_t * mutex;
	sem_t * sem;
	#endif

} command_queue_t;

#ifdef __cplusplus
extern "C" {
#endif
void command_queue_init(command_queue_t *c);
void command_queue_deinit(command_queue_t *c);
int command_queue_getAvailableCmdsNonBlock(command_queue_t *c);
int command_queue_getAvailableCmds(command_queue_t *c);
int command_queue_getAvailableSpace(command_queue_t *c);
int command_queue_putCmd(command_queue_t * c, tdm_command_t * data, uint8_t tag);
int command_queue_getCmd(command_queue_t * c, tdm_command_t * data, uint8_t *tag);

#ifdef __cplusplus
}
#endif

#endif
