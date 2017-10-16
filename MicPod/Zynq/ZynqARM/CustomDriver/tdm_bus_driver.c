#include "interrupt_controller.h"
#include "tdm_bus_driver.h"
#include "stdio.h"


void tdm_bus_init_intr(tdm_bus_t * inst, u32 tx_base_addr, u32 rx_base_addr, u32 comm_base_addr, u32 intr_id, void * callback_rx)
{
	inst->comm = (u32*)comm_base_addr;
	inst->rx = (u8 *)rx_base_addr;
	inst->tx = (u8 *)tx_base_addr;
	inst->intr_id = intr_id;

	interrupt_connect(inst->intr_id, callback_rx, inst, 248, RISING_EDGE);

	interrupt_enable(inst->intr_id);
	inst->comm[TX_REG_VALID]=0;
	inst->comm[RX_REG_GOT]=0x1;
}



//return the busy status of the send peripheral
int tdm_bus_send_is_busy(tdm_bus_t * inst)
{
	return (inst->comm[TX_REG_VALID]>>VALID_SHIFT)&0x01;
}

//if peripheral busy wait till it free
int tdm_bus_send_blocking(tdm_bus_t * inst, uint8_t *pSrc, int len)
{
	int i;

	while(tdm_bus_send_is_busy(inst))
	{

	}
	for(i=0; i<len; i++)
	{
		inst->tx[i]=pSrc[i];
	}
	inst->comm[TX_REG_LEN]=(len&LEN_MASK)<<LEN_SHIFT;
	inst->comm[TX_REG_VALID]|=(1<<VALID_SHIFT);
	return len;
}

//if peripheral busy don't send anything and retur 0
int tdm_bus_send_non_blocking(tdm_bus_t * inst, uint8_t *pSrc, int len)
{
	int i;
	if(tdm_bus_send_is_busy(inst))
	{
		printf("Send busy\n");
		return 0;

	}
	for(i=0; i<len; i++)
	{
		inst->tx[i]=pSrc[i];
	}
	inst->comm[TX_REG_LEN]=(len&LEN_MASK)<<LEN_SHIFT;
	inst->comm[TX_REG_VALID]|=(1<<VALID_SHIFT);
	return len;
}

//return 0 if no message is to be recieved, len if a message is present
int tdm_bus_receive_poll(tdm_bus_t * inst)
{


	if((inst->comm[RX_REG_VALID]>>VALID_SHIFT)&0x01)
	{
		int len = (inst->comm[RX_REG_LEN]>>LEN_SHIFT)&LEN_MASK;
//		printf("poll len %d\n",len);
		return len;
	}
	else
		return 0;
}

//return 0 if no message has been received, len if a message has been recived
int tdm_bus_receive(tdm_bus_t * inst, uint8_t *pDst)
{
	int i;

	int len= tdm_bus_receive_poll(inst);
	if(len==0)
		return 0;

	for(i=0; i<len; i++)
	{
		pDst[i]=inst->rx[i];
	}

	inst->comm[RX_REG_GOT]=0x1<<GOT_SHIFT;

	return len;
}

int tdm_bus_is_hub_locked(tdm_bus_t * inst)
{
	return (inst->comm[RX_REG_VALID]>>HUB_LOCKED_SHIFT)&0x01;
}
int tdm_bus_is_slave_locked(tdm_bus_t * inst, int slaveNum)
{
	return (inst->comm[RX_REG_VALID]>>HUB_1_LOCKED_SHIFT+slaveNum)&0x01;
}

