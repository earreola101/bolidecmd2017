#include "byte_queue.h"


void byte_queue_check_index(int * index)
{
	(*index)++;
	if((*index)>=RX_QUEUE_LEN)
		(*index)=0;
}

int byte_queue_incr_index(int index)
{
	index++;
	if(index>=RX_QUEUE_LEN)
		index=0;
	return index;
}

int byte_queue_get_avail_bytes(int indexR, int indexW)
{
	if(indexW>=indexR)
		return indexW-indexR;
	else
		return RX_QUEUE_LEN+indexW-indexR;

}
