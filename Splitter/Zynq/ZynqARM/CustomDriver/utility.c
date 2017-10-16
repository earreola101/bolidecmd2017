#include "utility.h"
#include "xparameters.h"
#include "xscutimer.h"
#include "xil_printf.h"
#include "xtime_l.h"
#include "xil_cache.h"

void enable_caches()
{

    Xil_ICacheEnable();
    Xil_DCacheEnable();

}
void disable_caches()
{
    Xil_DCacheDisable();
    Xil_ICacheDisable();
}


uint8_t crcCalc(uint8_t * pSrc, int len)
{
	uint8_t auxByte=0;
	int i;
	for(i=0; i<len; i++)
		auxByte^=pSrc[i];
	return auxByte;
}


void sleep_ms(int ms)
{
	XTime tStart, tEnd;
	XTime_GetTime(&tStart);
	double sD = ((double)ms)/1000.0;
	while(1)
	{
		 XTime_GetTime(&tEnd);
		 double elapsedS = 1.0 * (tEnd - tStart) / (COUNTS_PER_SECOND);
		 if(elapsedS>=sD)
			 break;
	}
}

void sleep_s(int s)
{
	XTime tStart, tEnd;
	XTime_GetTime(&tStart);
	double sD = ((double)s);
	while(1)
	{
		 XTime_GetTime(&tEnd);
		 double elapsedS = 1.0 * (tEnd - tStart) / (COUNTS_PER_SECOND);
		 if(elapsedS>=sD)
			 break;
	}
}
void timer_init(cust_timer_t* timer)
{
	timer->elapsedS=0;
	timer->start=0;
	timer->stop=0;
	timer->running=0;

}

void timer_reset(cust_timer_t* timer)
{
	timer_init(timer);
}

void timer_start(cust_timer_t* timer)
{
	if(timer->running)
		return;
	XTime_GetTime(&timer->start);
	timer->running=1;
}

void timer_stop(cust_timer_t* timer)
{
	if(!timer->running)
		return;

	XTime_GetTime(&timer->stop);
	timer->running=0;
	timer->elapsedS += 1.0 * (timer->stop - timer->start) / (COUNTS_PER_SECOND);
}

int timer_get_elapsed_ms(cust_timer_t* timer)
{
	if(timer->running)
	{
		XTime auxTime;
		double elapsedS;
		XTime_GetTime(&auxTime);
		elapsedS=timer->elapsedS+(1.0 * (auxTime - timer->start) / (COUNTS_PER_SECOND));
		return (int)(elapsedS*1000.0);
	}
	else
		return (int)(timer->elapsedS*1000.0);
}

int timer_get_elapsed_s(cust_timer_t* timer)
{
	if(timer->running)
	{
		XTime auxTime;
		double elapsedS;
		XTime_GetTime(&auxTime);
		elapsedS=timer->elapsedS+(1.0 * (auxTime - timer->start) / (COUNTS_PER_SECOND));
		return (int)(elapsedS);
	}
	else
		return (int)(timer->elapsedS);
}

