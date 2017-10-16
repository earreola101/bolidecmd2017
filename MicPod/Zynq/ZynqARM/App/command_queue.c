#include "command_queue.h"
#include <string.h>

//init command queue params
void command_queue_init(command_queue_t *c)
{
	memset(c,0,sizeof(command_queue_t));
#ifdef __linux
	mutex_init(&c->mutex);
//	semaphore_init(&c->sem);
#endif

}
void command_queue_deinit(command_queue_t *c)
{

#ifdef __linux
//	semaphore_deinit(c->sem);
	mutex_deinit(c->mutex);
#endif
	memset(c,0,sizeof(command_queue_t));

}

//returns how many commands are ready to be retrieved
int command_queue_getAvailableCmdsNonBlock(command_queue_t *c)
{
 return c->availCmds;

}

int command_queue_getAvailableCmds(command_queue_t *c)
{

#ifdef __linux
// semaphore_wait(c->sem);
#endif

 return c->availCmds;

}

//returns how many empty slots are available in the queue
int command_queue_getAvailableSpace(command_queue_t *c)
{
	return CMD_QUEUE_LENGHT-c->availCmds-1;
}

//puts the command into the specified queue
int command_queue_putCmd(command_queue_t * c, tdm_command_t * data, uint8_t tag)
{
#ifdef __linux
 mutex_lock(c->mutex);
#endif
 if (c->availCmds >= CMD_QUEUE_LENGHT)
  return -1;

 memcpy(&c->commands[c->cmdWIndex],data,data->len+COMMAND_OVERHEAD);
 c->tag[c->cmdWIndex]=tag;
 c->cmdWIndex++;
 if (c->cmdWIndex >= CMD_QUEUE_LENGHT)
	 c->cmdWIndex = 0;

 c->availCmds++;
#ifdef __linux
 mutex_unlock(c->mutex);
// semaphore_post(c->sem);
#endif
 return 0;
}

//get first available command from the queue
int command_queue_getCmd(command_queue_t * c, tdm_command_t * data, uint8_t *tag)
{
#ifdef __linux
 mutex_lock(c->mutex);
#endif
	if (c->availCmds <= 0)
		return -1;

	memcpy(data,&c->commands[c->cmdRIndex],sizeof(tdm_command_t));
	if(tag)
		*tag = c->tag[c->cmdRIndex];
	c->cmdRIndex++;
	if (c->cmdRIndex >= CMD_QUEUE_LENGHT)
		c->cmdRIndex = 0;

	c->availCmds--;

	if(c->availCmds>=CMD_QUEUE_LENGHT)
		c->availCmds=0;
#ifdef __linux
	mutex_unlock(c->mutex);
#endif
	return 0;
}

