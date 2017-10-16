#ifndef CS2000_H__
#define CS2000_H__
#include "spi_driver.h"


typedef enum
{
	CS2000_INTERNAL = 0,
	CS2000_EXTERNAL = 1
}cs2000_source_e;
#define BD_PLL_USE_SPI
//int bdPllInit(bdSpi_t* spiInst);
int cs2000_change_source(spi_driver_t* commInstUsed,cs2000_source_e source);
int cs2000_init(spi_driver_t* commInstUsed,cs2000_source_e source, int multiplier);
int cs2000_set_mult(spi_driver_t* commInstUsed, u32 ratio);

#endif


