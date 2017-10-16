#include "spi_driver.h"

u8 bufAux[69]={0};
/*
 * The following variables are shared between non-interrupt processing and
 * interrupt processing such that they must be global.
 */
volatile int TransferInProgress;

/*
 * The following variable tracks any errors that occur during interrupt
 * processing
 */
int Error;




int spi_driver_init(spi_driver_t* spi_inst)
{
	/*
	 * Initialize the SPI driver so that it is  ready to use.
	 */
	XSpiPs_Config *ConfigPtr;
	int Status;
	ConfigPtr = XSpiPs_LookupConfig(XPAR_PS7_SPI_0_DEVICE_ID);
	if (ConfigPtr == NULL) {
		return XST_DEVICE_NOT_FOUND;
	}
	Status = XSpiPs_CfgInitialize(&spi_inst->spiInst, ConfigPtr,
				  ConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	/*
	 * Set the SPI device as a master and in manual slave select mode such
	 * that the slave select signal does not toggle for every byte of a
	 * transfer, this must be done before the slave select is set
*/
	Status = XSpiPs_SetOptions(&spi_inst->spiInst,  XSPIPS_MASTER_OPTION |
			   XSPIPS_FORCE_SSELECT_OPTION);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	XSpiPs_SetClkPrescaler(&spi_inst->spiInst, XSPIPS_CLK_PRESCALE_128);
	/*
	 * Select the slave on the SPI bus, the EEPROM device so that it can be
	 * read and written using the SPI bus
	 */
//	Status = XSpiPs_SetSlaveSelect(&spi_inst->spiInst, 1);
//	if (Status != XST_SUCCESS) {
//		return XST_FAILURE;
//	}


	XSpiPs_SetSlaveSelect(&spi_inst->spiInst, 1);
	return XST_SUCCESS;
}

void spi_driver_deinit(spi_driver_t* spi_inst)
{
	/*
	 * Disable the Spi interrupt.
	 */
//	bdSpiDisableIntrSystem(bdSpiInst->IntcInstancePtr, bdSpiInst->intId);
}

int spi_driver_send(spi_driver_t* spi_inst, u8 * buf, int len)
{

	XSpiPs_SetSlaveSelect(&spi_inst->spiInst, 0);
//	sleep_ms(1);
	XSpiPs_PolledTransfer(&spi_inst->spiInst, buf, NULL, len);
//	sleep_ms(1);
	XSpiPs_SetSlaveSelect(&spi_inst->spiInst, 1);

	return XST_SUCCESS;
}



int spi_driver_receive(spi_driver_t* spi_inst, u8* buf, int len)
{

	return -1;
}



unsigned int ByteCountMem = 0;

