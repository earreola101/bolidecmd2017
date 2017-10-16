#include "packet_manager.h"
#include "byte_queue.h"
#include <string.h>
#include "utility.h"
//#define DEBUG_COMMANDS

//generates packet from tdm command, as:
//|*********|*********|*****|*****|*************|*****|
//|	HEADER0	| HEADER1 |	LEN	| LEN |	TDM_COMMAND	| CRC |
//|*********|*********|*****|*****|*************|*****|
int packet_manager_generate_packet(uint8_t *pDst, tdm_command_t *pSrc)
{
	int packetLen = pSrc->len+PACKET_OVERHEAD+COMMAND_OVERHEAD;
	int commandLen = pSrc->len+COMMAND_OVERHEAD;
	if(pSrc->len>MAX_MESSAGE_LEN)
		return -1;

	pDst[0] = HEADER_0;
	pDst[1] = HEADER_1;
	pDst[2] = (packetLen>>8)&0xFF;
	pDst[3] = packetLen&0xFF;

	memcpy(&pDst[4],pSrc,commandLen);

	pDst[packetLen-1]=crcCalc(pDst, packetLen-1);
	return packetLen;
}

//this function looks for an header+lenght pattern in buffer_read
//meant for byte-to-byte (serial) use
int packet_manager_check_header(uint8_t * buffer_read, int * index_read)
{
	int auxLen;
	int auxIndexR = *index_read;

	if(buffer_read[auxIndexR]!= HEADER_0)
	{
		#ifdef DEBUG_COMMANDS
		printf("Couldn't find a header at the address: %d\r\n",(*index_read));
		#endif
		*index_read = byte_queue_incr_index(*index_read);
		return -1;
	}

	byte_queue_check_index(&auxIndexR);
	if(buffer_read[auxIndexR]!= HEADER_1)
	{
		*index_read = byte_queue_incr_index(*index_read);
		return -1;
	}

	byte_queue_check_index(&auxIndexR);
	uint8_t lenH = buffer_read[auxIndexR];

	byte_queue_check_index(&auxIndexR);
	uint8_t lenL = buffer_read[auxIndexR];

	auxLen =((lenH<<8)&0xFF00) | lenL ;

	if((auxLen>MAX_PACKET_LEN)|(auxLen<0))
	{
		*index_read = byte_queue_incr_index(*index_read);
		return -1;
	}
	return auxLen;
}

//this function looks for a correct payload by checking the CRC, considering the expected lenght
//meant for byte-to-byte (serial) use
int packet_manager_check_payload(uint8_t * buffer_src, uint8_t * buffer_dst, int * index_read, int expectedPayloadBytes)
{
	int auxIndR = *index_read;
	int i;
	for(i=0; i<expectedPayloadBytes; i++)
	{
		buffer_dst[i]= buffer_src[auxIndR];
		auxIndR++;
		if(auxIndR>=RX_QUEUE_LEN)
			auxIndR=0;
	}

	if(buffer_dst[expectedPayloadBytes-1]!=crcCalc(buffer_dst, expectedPayloadBytes-1))
	{
		#ifdef DEBUG_COMMANDS
		printf("Wrong CRC\n");
		#endif
		*index_read = byte_queue_incr_index(*index_read);
//		comm_data->checkPayload = 0;
//		comm_data->checkHeader = 1;
		return -1;
	}
	return auxIndR;
}

int packet_manager_tdm_decode(tdm_command_t * pDst, uint8_t *pSrc, int len)
{
	//check packet integrity
	int auxLen;
	if(pSrc[0]!= HEADER_0)
	{
#ifdef DEBUG_COMMANDS
		printf("[APP] Error decoding packet: wrong header 0\n");
#endif
		return -1;
	}
	if(pSrc[1]!= HEADER_1)
	{
#ifdef DEBUG_COMMANDS
		printf("[APP] Error decoding packet: wrong header 1\n");
#endif
		return -1;
	}

	auxLen = ((pSrc[2]<<8)&0xFF00) | (pSrc[3]&0xFF);
	if(len!=auxLen)
	{

#ifdef DEBUG_COMMANDS
		printf("[APP] Error decoding packet: packet len different from received one\n");
#endif
		return -1;

	}
	if((auxLen>MAX_PACKET_LEN)|(auxLen<0))
	{
#ifdef DEBUG_COMMANDS
		printf("[APP] Error decoding packet: packet len out of range\n");
#endif
		return -1;
	}

	if(pSrc[auxLen-1]!=crcCalc(pSrc, auxLen-1))
	{
#ifdef DEBUG_COMMANDS
		printf("[APP] Error decoding packet: wrong crc\n");
#endif
		return -1;
	}
	memcpy(pDst,&pSrc[4],len-PACKET_OVERHEAD);

#ifdef DEBUG_COMMANDS
	printf("[APP] Packet received:\n");
	printf("[APP] Command: %d\n",pDst->command);
	printf("[APP] Sender: %d\n",pDst->sender);
	printf("[APP] Receiver: %d\n",pDst->receiver);
	printf("[APP] Len: %d\n",pDst->len);

#endif
	return 0;
}
