#ifndef TDM_BUS_DRIVER_H__
#define TDM_BUS_DRIVER_H__
#include "xil_types.h"
#include "xparameters.h"



typedef struct tdm_bus_t
{
	u8 * tx;
	u8 * rx;
	u32 * comm;
	u32 intr_id;
}tdm_bus_t;





//General command manager definition
#define LEN_SHIFT			0
#define LEN_MASK			0xFFFF
#define VALID_SHIFT			16
#define HUB_LOCKED_SHIFT	17
#define HUB_1_LOCKED_SHIFT	18
#define MIC_0_LOCKED_SHIFT	19
#define MIC_1_LOCKED_SHIFT	20
#define GOT_SHIFT			0

//RX register command manager definition
#define RX_REG_LEN		0
#define RX_REG_VALID	0
#define RX_REG_GOT		1

//TX register command manager definition
#define TX_REG_LEN		2
#define TX_REG_VALID	2
#define TX_REG_GOT		3


//initialization
void tdm_bus_init_intr(tdm_bus_t * inst, u32 tx_base_addr, u32 rx_base_addr, u32 comm_base_addr, u32 intr_id, void * callback_rx);

//return the busy status of the send peripheral
int tdm_bus_send_is_busy(tdm_bus_t * inst);
//if peripheral busy wait till it free
int tdm_bus_send_blocking(tdm_bus_t * inst, uint8_t *pSrc, int len);
//if peripheral busy don't send anything and retur 0
int tdm_bus_send_non_blocking(tdm_bus_t * inst, uint8_t *pSrc, int len);

//return 0 if no message is to be recieved, len if a message is present
int tdm_bus_receive_poll(tdm_bus_t * inst);
//return 0 if no message has been received, len if a message has been recived
int tdm_bus_receive(tdm_bus_t * inst, uint8_t *pDst);

int tdm_bus_is_hub_locked(tdm_bus_t * inst);
int tdm_bus_is_slave_locked(tdm_bus_t * inst, int slaveNum);




#endif
