#ifndef SEND_RECV_TV_HUB_H__
#define SEND_RECV_TV_HUB_H__

#include <stdbool.h>
#include <stdint.h>
#include "status.h"
#include "command_queue.h"
#include "serial.h"

int send_receive_init(command_queue_t * queue);
void send_receive_deinit(void);
int send_command(tdm_command_t * command_tx);

void send_receive_init_serial(comm_serial_t * serial, char * dev);
void send_receive_deinit_serial(comm_serial_t * serial);
void send_receive_deinit_stm32_serial();
void send_receive_init_stm32_serial();

int send_receive_get_tdm_locked();

#endif
