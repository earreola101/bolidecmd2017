#include "byte_queue.h"

//index progression, unless it reaches the end of the queue, by pointer
void byte_queue_check_index(int * index)
{
	(*index)++;
	if((*index)>=RX_QUEUE_LEN)
		(*index)=0;
}

//index progression, unless it reaches the end of the queue, by value
int byte_queue_incr_index(int index)
{
	index++;
	if(index>=RX_QUEUE_LEN)
		index=0;
	return index;
}

//returns how many bytes are available for usage (filled with data)
int byte_queue_get_avail_bytes(int indexR, int indexW)
{
	if(indexW>=indexR)
		return indexW-indexR;
	else
		return RX_QUEUE_LEN+indexW-indexR;

}
