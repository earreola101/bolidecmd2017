#include "recvThread.h"
#include "command_parser.h"
#include "command_queue.h"
#include "fw_update.h"


/******************************************************************
 * RECV FW Thread
 ******************************************************************/
void recvThread::run()
{
	command_queue_initQueue(&queue);
	indexW=0;indexR=0;
	int diff;
	while(!exitThread)
	{
		int auxIndexW = indexW;
		int recvBytes = serialPortPtr->recvBuffer((quint8*)&recvBuf[auxIndexW], 1);
		if(recvBytes)
		{
			auxIndexW++;
			if(auxIndexW>=RX_QUEUE_LEN)
				auxIndexW=0;
			indexW = auxIndexW;			
			int packet = decodePacket((uint8_t*)recvBuf,&indexW,&indexR,&queue);
		}
				
		if(command_queue_getAvailableCmds(&queue))
		{
			tdm_command_t cmd;
			command_queue_getCmd(&queue, &cmd);
			switch(cmd.command)
			{
				case CMD_FW_UPDATE_ACK:
					if(ackStruct->seqNum == cmd.sequenceNum)
						ackStruct->ackStatus = ACK_OK;
					ackStruct->waitAckSem.release();
					break;
				case CMD_FW_UPDATE_NACK:
					ackStruct->nackWait=true;
					ackStruct->rollBackSeqN = ackStruct->seqNum;
					diff = ackStruct->rollBackSeqN - cmd.sequenceNum;
					ackStruct->rollBackBytes = diff*FW_UPDATE_PKT_SIZE;
					ackStruct->nackWait=false;
					break;
				case CMD_FW_UPDATE_END:
					if(cmd.data[0]==DATA_FW_UPDATE_SUCC)
						ackStruct->ackStatus = ACK_OK;
					ackStruct->waitAckSem.release();
					break;
				default:
					break;
			}
		}
	}	
}
