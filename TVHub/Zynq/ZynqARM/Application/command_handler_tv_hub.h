#ifndef COMMAND_HANDLER_TV_HUB_H__
#define COMMAND_HANDLER_TV_HUB_H__

#include "commands.h"
#include "command_gen_dec.h"


void cmd_handler_route(tdm_command_t *RXcmd);
void cmd_handler_status(tdm_command_t *cmd, uint8_t tag);
void cmd_handler_status_out(tdm_command_t *cmd, uint8_t tag);
void cmd_handler_fw_update(tdm_command_t *cmd);
void cmd_handler_set_id(uint8_t id);
uint8_t cmd_handler_get_id();
void cmd_handler_init();
#endif
