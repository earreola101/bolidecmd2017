#include "send_receive.h"
#include "command_queue.h"
#include "packet_manager.h"
#include "byte_queue.h"
#include "utility.h"

#include "tdm_bus.h"
#include <string.h>


comm_serial_t comm_serial_cmd, comm_serial_stm32;
comm_tdm_bus_t comm_bus0, comm_bus1, comm_bus2;
command_queue_t * send_receive_RXqueue;
int tdm_gui_enable = 0;

//this thread constantly checks for incoming bytes on the serial peripheral,
//then stores them into a buffer
void *serial_receive_thread(void *data)
{
	printf("serial_receive_thread begin\n");
	comm_serial_t * comm_data = (comm_serial_t *)data;
	while(!comm_data->end)
	{
		int index_w = comm_data->index_w;
		int res = serial_read(comm_data->fid,&comm_data->buffer_read[index_w],1);
		if(res>0)
		{
//			printf("uart received something\n");
			index_w++;
			if(index_w>=RX_QUEUE_LEN)
				index_w=0;
			comm_data->index_w = index_w;
			semaphore_post(comm_data->sem_read);
		}

	}
	semaphore_post(comm_data->sem_read);

	printf("serial_receive_thread end\n");
	return 0;
}

//this thread constantly reads from TDM for an entire recieved packet.
//If the decoding succeeds, the command gets added to the RX queue
void *tdm_bus_receive_thread(void *data)
{

	printf("tdm_bus_receive_thread begin\n");
	tdm_command_t commandRx;
	comm_tdm_bus_t * comm_data = (comm_tdm_bus_t *)data;

	while(!comm_data->end)
	{
		int len = tdm_bus_read(comm_data->fid,comm_data->buffer_read,MAX_PACKET_LEN);
		if(len>0)
		{
			int res = packet_manager_tdm_decode(&commandRx, comm_data->buffer_read, len);
			if(res<0)
			{
				printf("Warning: decode failed on TDM fid %d\n", len, comm_data->fid);

				continue;	//decode fail
			}
			command_queue_putCmd(send_receive_RXqueue, &commandRx,comm_data->tag);

		}

		//else
			//printf("[APP] Non blocking\n");
	}
	printf("tdm_bus_receive_thread end\n");
	return 0;
}

//this thread constantly checks for a number of received bytes compatible with minimum lenght.
//then tries to identify an header sequence and secondly it looks for a valid payload.
//eventually the packet is addess to the RX queue
void *serial_decoding_thread(void *data)
{
	printf("serial_decoding_thread begin\n");
	comm_serial_t * comm_data = (comm_serial_t *)data;
	int auxIndexR, auxIndexW, auxLen;
	int expectedPayloadBytes;
	uint8_t decBuffer[MAX_PACKET_LEN];
	//command_t command;
	comm_data->checkHeader=1;
	while(!comm_data->end)
	{

		semaphore_wait(comm_data->sem_read);
		if(comm_data->end)
			break;
		auxIndexR = comm_data->index_r;
		auxIndexW = comm_data->index_w;
		if(comm_data->checkHeader)
		{
			if(byte_queue_get_avail_bytes(auxIndexR, auxIndexW)>=(HEADER_BYTES+LEN_BYTES))
			{
				auxLen = packet_manager_check_header(comm_data->buffer_read, &comm_data->index_r);
				if(auxLen<0)
					continue;
				comm_data->checkHeader = 0;
				expectedPayloadBytes = auxLen;
			}
		}
		else
		{
			int avail = byte_queue_get_avail_bytes(auxIndexR, auxIndexW);
			if(avail >= expectedPayloadBytes)
			{
				int auxIndR = comm_data->index_r;
				auxIndR = packet_manager_check_payload(comm_data->buffer_read, decBuffer, &comm_data->index_r, expectedPayloadBytes);
				if(auxIndR>=0)
				{
					comm_data->index_r= auxIndR;
					command_queue_putCmd(send_receive_RXqueue, (tdm_command_t *) &decBuffer[HEADER_BYTES+LEN_BYTES],TAG_SERIAL_CMD);
				}
				comm_data->checkHeader = 1;
			}
		}

	}
	printf("serial_decoding_thread end\n");
	return 0;
}

//this function handles the serial & TDM packet sending
int send_command(tdm_command_t * command_tx)
{
	uint8_t buffer[MAX_PACKET_LEN];
	int ret=0, pktLen=0;
	int indexSend=0;
	pktLen = packet_manager_generate_packet(buffer,command_tx);
	if(command_tx->receiver==DEFAULT_PC_ID)
	{
		if(tdm_gui_enable)
		{
			tdm_bus_write(comm_bus0.fid,buffer,pktLen);
		}
		else
		{
			ret = serial_write(comm_serial_cmd.fid,buffer,pktLen);
			if(ret!=pktLen)
				printf("Error: couldn't send byte to pc\n");
		}
	}
	else if(command_tx->receiver==DEFAULT_STM32_ID)
	{

		ret = serial_write(comm_serial_stm32.fid,buffer,pktLen);
		if(ret!=pktLen)
			printf("Error: couldn't send byte to STM\n");
	}
	else
	{
		tdm_bus_write(comm_bus0.fid,buffer,pktLen);
	}
	return ret;
}

//inits the available command interfaces
int send_receive_init(command_queue_t * queue)
{
	tdm_gui_enable = 0;
	send_receive_RXqueue = queue;
	send_receive_init_serial(&comm_serial_cmd, SERIAL_DEV_CMD);
	send_receive_init_serial(&comm_serial_stm32, SERIAL_DEV_STM32);


	comm_bus0.fid = tdm_bus_init(TDM_BUS_0_DEV);
	tdm_bus_set_dir(comm_bus0.fid, 1);
	comm_bus0.tag = TAG_BUS_SPLITTER;
	comm_bus1.fid = tdm_bus_init(TDM_BUS_1_DEV);
	tdm_bus_set_dir(comm_bus1.fid, 1);
	comm_bus1.tag = TAG_BUS_TV;
	comm_bus2.fid = tdm_bus_init(TDM_BUS_2_DEV);
	tdm_bus_set_dir(comm_bus2.fid, 1);
	comm_bus2.tag = TAG_BUS_MIC;
	comm_bus0.end = 0;
	comm_bus1.end = 0;
	comm_bus2.end = 0;

	thread_create(&comm_bus0.thread_read, tdm_bus_receive_thread, &comm_bus0,"bus0_th");
	thread_create(&comm_bus1.thread_read, tdm_bus_receive_thread, &comm_bus1,"bus1_th");
	thread_create(&comm_bus2.thread_read, tdm_bus_receive_thread, &comm_bus2,"bus2_th");
	return 0;
}

//init serial interface
void send_receive_init_serial(comm_serial_t * serial, char * dev)
{
	serial->end = 0;
	serial->index_r=0;
	serial->index_w=0;
	serial->checkHeader = 1;
	serial->fid = -1;
	serial->sem_read = NULL;
	semaphore_init(&serial->sem_read);
	if(serial->sem_read == NULL)
		return;
	serial->fid = serial_init(dev);
	if(serial->fid<0)
		return;
	serial->thread_read = NULL;
	thread_create(&serial->thread_read, serial_receive_thread, serial,"ser_th");
	if(serial->thread_read == NULL)
		return;
	serial->thread_decode = NULL;
	thread_create(&serial->thread_decode, serial_decoding_thread, serial,"ser_th");
	if(serial->thread_decode == NULL)
		return;

	printf("Fid %d is %s\n",serial->fid ,dev);
}

void send_receive_deinit_serial(comm_serial_t * serial)
{
	serial->end = 1;
	thread_join(serial->thread_read);
	thread_join(serial->thread_decode);


	serial->thread_read = NULL;
	serial->thread_decode = NULL;
	serial_deinit(serial->fid);
	serial->fid = -1;
	semaphore_deinit(serial->sem_read);

	serial->sem_read = NULL;
}


void send_receive_init_stm32_serial()
{
	send_receive_init_serial(&comm_serial_stm32,SERIAL_DEV_STM32);
}

void send_receive_deinit_stm32_serial()
{
	send_receive_deinit_serial(&comm_serial_stm32);
}


void send_receive_deinit(void)
{
	send_receive_deinit_stm32_serial();
	send_receive_deinit_serial(&comm_serial_cmd);
	comm_bus0.end = 1;
	comm_bus1.end = 1;
	comm_bus2.end = 1;
	thread_join(comm_bus0.thread_read);
	thread_join(comm_bus1.thread_read);
	thread_join(comm_bus2.thread_read);

	sleep_ms(999);
	tdm_bus_deinit(comm_bus0.fid);
	tdm_bus_deinit(comm_bus1.fid);
	tdm_bus_deinit(comm_bus2.fid);
	printf("Send receive deinit finished\n");
}

void send_receive_set_gui_interface(int tdmEnable)
{
	tdm_gui_enable = tdmEnable;
}
