#ifndef COMMAND_HANDLER_H__
#define COMMAND_HANDLER_H__


#include "commands.h"
#include "command_gen_dec.h"
#include "fw_update.h"

void cmd_handler_init();
void cmd_handler_status(tdm_command_t *cmd, uint8_t tag);
void cmd_handler_fw_update(tdm_command_t *cmd);

void cmd_handler_spp(tdm_command_t *cmd);

#endif
