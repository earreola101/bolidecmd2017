#ifndef UTILITY_H__
#define UTILITY_H__

#include "xtime_l.h"

void enable_caches();
void disable_caches();

uint8_t crcCalc(uint8_t * pSrc, int len);

void sleep_ms(int ms);
void sleep_s(int s);

typedef struct cust_timer_t
{
	XTime start;
	XTime stop;
	double elapsedS;
	int running;
}cust_timer_t;

void timer_init(cust_timer_t* timer);
void timer_reset(cust_timer_t* timer);
void timer_start(cust_timer_t* timer);
void timer_stop(cust_timer_t* timer);
int timer_get_elapsed_ms(cust_timer_t* timer);
int timer_get_elapsed_s(cust_timer_t* timer);

#endif

