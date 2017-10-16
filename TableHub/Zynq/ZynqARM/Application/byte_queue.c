#include "byte_queue.h"

//update index value with the next position in the queue
void byte_queue_check_index(int * index)
{
	(*index)++;
	if((*index)>=RX_QUEUE_LEN)
		(*index)=0;
}

//increments the index value and returns the updated value
int byte_queue_incr_index(int index)
{
	index++;
	if(index>=RX_QUEUE_LEN)
		index=0;
	return index;
}

//returns how many bytes are available for consuming
int byte_queue_get_avail_bytes(int indexR, int indexW)
{
	if(indexW>=indexR)
		return indexW-indexR;
	else
		return RX_QUEUE_LEN+indexW-indexR;

}
