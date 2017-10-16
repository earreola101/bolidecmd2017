#include "command_parser.h"
#include "command_queue.h"
#include "byte_queue.h"
#include <string.h>

int checkPayload = 0;
int auxIndexR, auxIndexW, auxLen, expectedPayloadBytes;

uint8_t crcCalc(uint8_t * pSrc, int len)
{
	uint8_t auxByte=0;
	int i;
	for(i=0; i<len; i++)
		auxByte^=pSrc[i];
	return auxByte;
}


int decodePacket(uint8_t * recvBuf, int * indexW, int * indexR, command_queue_t * queue)
{
	uint8_t buffer[MAX_PACKET_LEN];
	uint8_t lenH, lenL;
	tdm_command_t * cmdPtr;
	int i;
	auxIndexR = *indexR;
	auxIndexW = *indexW;
	

	if(!checkPayload)
	{
		if(byte_queue_get_avail_bytes(auxIndexR, auxIndexW)>=(HEADER_BYTES+LEN_BYTES))
		{
			if(recvBuf[auxIndexR]!= HEADER_0)
			{
				#ifdef DEBUG_COMMANDS
				printf("Non ho trovato un header all'indirizzo: %d\r\n",comm_data->index_r_read);
				#endif
				*indexR = byte_queue_incr_index(*indexR);
				return -1;
			}

			byte_queue_check_index(&auxIndexR);
			if(recvBuf[auxIndexR]!= HEADER_1)
			{
				*indexR = byte_queue_incr_index(*indexR);
				return -1;
			}

			byte_queue_check_index(&auxIndexR);
			lenH = recvBuf[auxIndexR];

			byte_queue_check_index(&auxIndexR);
			lenL = recvBuf[auxIndexR];

			auxLen =((lenH<<8)&0xFF00) | lenL ;

			if((auxLen>MAX_PACKET_LEN)|(auxLen<0))
			{
				*indexR = byte_queue_incr_index(*indexR);
				return -1;
			}

			checkPayload = 1;
			expectedPayloadBytes = auxLen;
		}
	}
	else
	{
		int avail = byte_queue_get_avail_bytes(auxIndexR, auxIndexW);
		if(avail >= expectedPayloadBytes)
		{
			int auxIndR = *indexR;
			for(i=0; i<expectedPayloadBytes; i++)
			{
				buffer[i]= recvBuf[auxIndR];
				auxIndR++;
				if(auxIndR>=RX_QUEUE_LEN)
					auxIndR=0;
			}

			if(buffer[expectedPayloadBytes-1]!=crcCalc(buffer, expectedPayloadBytes-1))
			{
				#ifdef DEBUG_COMMANDS
				printf("Wrong CRC\n");
				#endif
				*indexR = byte_queue_incr_index(*indexR);
				checkPayload = 0;
				return -1;
			}

			*indexR= auxIndR;
			command_queue_putCmd(queue, (tdm_command_t *) &buffer[HEADER_BYTES+LEN_BYTES],0);
			cmdPtr = (tdm_command_t *)&buffer[HEADER_BYTES+LEN_BYTES];
			#ifdef DEBUG_COMMANDS
			printf("Received command: %d\r\n", cmdPtr->sequence);
			printf("Command size: %d\r\n\r\n", cmdPtr->len);
			#endif
			checkPayload = 0;
			cmdPtr = (tdm_command_t *)&buffer[HEADER_BYTES+LEN_BYTES];
			return cmdPtr->len;
		}
	}
	return 0;
}

int generatePacket(uint8_t *pDst, tdm_command_t *pSrc)
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