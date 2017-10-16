#ifndef CS2000_H__
#define CS2000_H__
#include "spi.h"



#define BD_PLL_INTERNAL 0
#define BD_PLL_EXTERNAL 1

typedef struct pll_info_t
{
	uint32_t source;
	uint32_t multiplier;
}pll_info_t;



int cs2000_init(uint32_t source, int multiplier);
void cs2000_deinit();
int cs2000_set_source(uint32_t source);
int cs2000_set_mul(uint32_t ratio);

#endif


