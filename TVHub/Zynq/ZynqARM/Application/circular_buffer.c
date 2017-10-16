#include "circular_buffer.h"
#include "stdio.h"

int circBuf_availableSpace(bd_circBuf_t *c)
{
	int idxR = c->idxR;
	int idxW = c->idxW;
	if(idxW>=idxR)
		return CIRCULAR_SAMPLE_MAX-idxW+idxR;
	else
		return idxR-idxW;

}
int circBuf_availableSamples(bd_circBuf_t *c)
{
	int idxW = c->idxW;
	int idxR = c->idxR;

	if(idxW>=idxR)
		return idxW-idxR;
	else
		return CIRCULAR_SAMPLE_MAX-idxR+idxW;
}

void circBuf_init(bd_circBuf_t *c)
{
	c->started = 0;
	c->idxR = 0;
	c->idxW = 0;
}

int circBufPushI(bd_circBuf_t *c, int32_t *data, int size)
{
	int i;
	c->started = 1;

	if (circBuf_availableSpace(c)== 0)
	{
		printf("Circular buffer full 1\n");
		return 0;
	}

	for(i=0; i<size; i++)
	{
		int idxW=c->idxW;
		c->buffer[idxW]=data[i];

		idxW++;
		if (idxW >= CIRCULAR_SAMPLE_MAX)
			idxW = 0;
		c->idxW = idxW;

//		if (circBuf_availableSpace(c)== 0 && ((i+1)!=size))
//		{
//
//			printf("Circular buffer full 2\n");
//			return i;
//		}
	}

	return size;
}

int circBufPopI(bd_circBuf_t *c, int32_t *data, int size)
{
	int i;
	//memset(data,0,size);
	if (circBuf_availableSamples(c)== 0)
	{
		printf("[S2C-CAPT] Circular buffer empty 1\n");
		return 0;
	}
	for(i=0; i<size; i++)
	{
		int idxR=c->idxR;
		data[i]= c->buffer[idxR];

		idxR++;
		if (idxR >= CIRCULAR_SAMPLE_MAX)
			idxR = 0;
		c->idxR=idxR;

//		if (circBuf_availableSamples(c)== 0 && ((i+1)!=size))
//		{
//			printf("[S2C-CAPT] Circular buffer empty 2 [idxR=%d - idxW=%d]\n",c->idxR,c->idxW);
//			return i;
//		}
	}
	return 0;
}
int circBufPushF(bd_circBuf_t *c, float *data, int size)
{
	int i;
	c->started = 1;

	if (circBuf_availableSpace(c)== 0)
	{
		printf("Circular buffer full 1\n");
		return 0;
	}

	for(i=0; i<size; i++)
	{
		int idxW=c->idxW;
		c->buffer[idxW]=(int)(data[i]);//*256.0f);

		idxW++;
		if (idxW >= CIRCULAR_SAMPLE_MAX)
			idxW = 0;
		c->idxW = idxW;

//		if (circBuf_availableSpace(c)== 0 && ((i+1)!=size))
//		{
//			printf("Circular buffer full 2\n");
//			return i;
//		}
	}

	return size;
}

int circBufPopF(bd_circBuf_t *c, float *data, int size)
{
	int i;
	//memset(data,0,size);
	if (circBuf_availableSamples(c)== 0)
	{
		printf("[S2C-CAPT] Circular buffer empty 1\n");
		return 0;
	}
	for(i=0; i<size; i++)
	{
		int idxR=c->idxR;
		data[i]= ((float)c->buffer[idxR]);///256.0f;

		idxR++;
		if (idxR >= CIRCULAR_SAMPLE_MAX)
			idxR = 0;
		c->idxR=idxR;

//		if (circBuf_availableSamples(c)== 0 && ((i+1)!=size))
//		{
//			printf("[S2C-CAPT] Circular buffer empty 2 [idxR=%d - idxW=%d]\n",c->idxR,c->idxW);
//			return i;
//		}
	}
	return 0;
}
