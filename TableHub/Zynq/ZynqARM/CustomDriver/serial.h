/*
 * serial.h
 *
 *  Created on: Apr 21, 2017
 *      Author: bdsound
 */

#ifndef SRC_SERIAL_H_
#define SRC_SERIAL_H_

#include <pthread.h>
#include <stdint.h>
#include <semaphore.h>
#include "commands.h"

#define SERIAL_DEV_CMD		"/dev/ttyPS0"
#define SERIAL_DEV_STM32	"/dev/ttyUL0"

typedef struct comm_serial_t
{

	int fid;
	int end;

	pthread_t * thread_read;
	pthread_t * thread_decode;
	int index_w;
	int index_r;
	uint8_t buffer_read[RX_QUEUE_LEN];
	sem_t * sem_read;
	uint8_t checkHeader;
}comm_serial_t;

int serial_init(const char * dev);
void serial_deinit(int fid);
int serial_write(int fid, uint8_t * buf, int len);
int serial_read(int fid, uint8_t * buf, int maxLen);


#endif /* SRC_SERIAL_H_ */
