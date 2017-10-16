#ifndef SPI_H__
#define SPI_H__
#include "stdint.h"



//////////
// Init SPIdev
//////////
int spi_init();
void spi_deinit();
void spi_write(uint8_t add, uint8_t regNum, uint8_t value);


#endif
