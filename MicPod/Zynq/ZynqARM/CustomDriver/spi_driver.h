#ifndef SPI_DRIVER_H__
#define SPI_DRIVER_H__


#include "xil_types.h"
#include "xspips.h"

typedef struct
{

	XSpiPs spiInst;
}spi_driver_t;

int spi_driver_init(spi_driver_t* spi_inst);
void spi_driver_deinit(spi_driver_t* spi_inst);
int spi_driver_send(spi_driver_t* spi_inst, u8 * buf, int len);
int spi_driver_receive(spi_driver_t* spi_inst, u8* buf, int len);



#endif
