/*
 * serial.h
 *
 *  Created on: Apr 21, 2017
 *      Author: bdsound
 */

#ifndef TDM_BUS_H__
#define TDM_BUS_H__

#include <stdint.h>
#include <pthread.h>
#include <stdint.h>
#include <semaphore.h>
#include "commands.h"

#define TDM_BUS_0_DEV	"/dev/bus0"
#define TDM_BUS_1_DEV	"/dev/bus1"
#define TDM_BUS_2_DEV	"/dev/bus2"

typedef struct comm_tdm_bus_t
{
	uint8_t tag;
	int fid;
	bool end;
	pthread_t * thread_read;
	uint8_t buffer_read[RX_QUEUE_LEN];
}comm_tdm_bus_t;

int tdm_bus_init(const char * dev);
void tdm_bus_deinit(int fid);
int tdm_bus_write(int fid, uint8_t * buf, int len);
int tdm_bus_read(int fid, uint8_t * buf, int maxLen);
void tdm_bus_set_dir(int fid, int dir);
unsigned int tdm_bus_get_locked(int fid);
#endif /* SRC_SERIAL_H_ */
