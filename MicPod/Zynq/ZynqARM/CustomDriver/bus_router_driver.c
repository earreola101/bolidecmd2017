#include "bus_router_driver.h"
//#define DEBUG_BUS
#ifdef DEBUG_BUS
#include "stdio.h"
#endif

//initialization
void bus_router_init(bus_router_t * inst, u32 base_addr)
{
	inst->reg = (u32*)base_addr;
	inst->current_value = 0;
	inst->reg[0]=0;
}




void bus_router_set_tx0(bus_router_t * inst, uint8_t sel)
{
	inst->current_value &= ~(TX0_SEL_MASK<<TX0_SEL_SHIFT);
	inst->current_value |= ((sel&TX0_SEL_MASK)<<TX0_SEL_SHIFT);
	inst->reg[0] = inst->current_value ;
#ifdef DEBUG_BUS
	switch(sel)
	{
	case (BUS_ROUTER_TX_HUB):
		printf("TX 0 out <= TX HUB\n");
		break;
	case (BUS_ROUTER_RX_0):
		printf("TX 0 out <= RX 0\n");
		break;
	case (BUS_ROUTER_RX_1):
		printf("TX 0 out <= RX 1\n");
		break;
	case (BUS_ROUTER_SILENT):
		printf("TX 0 out <= 0\n");
		break;
	default:
		printf("TX 0 out <= invalid\n");
		break;

	}
#endif
}

void bus_router_set_tx1(bus_router_t * inst, uint8_t sel)
{
	inst->current_value &= ~(TX1_SEL_MASK<<TX1_SEL_SHIFT);
	inst->current_value |= ((sel&TX1_SEL_MASK)<<TX1_SEL_SHIFT);
	inst->reg[0] = inst->current_value ;
#ifdef DEBUG_BUS
	switch(sel)
	{
	case (BUS_ROUTER_TX_HUB):
		printf("TX 1 out <= TX HUB\n");
		break;
	case (BUS_ROUTER_RX_0):
		printf("TX 1 out <= RX 0\n");
		break;
	case (BUS_ROUTER_RX_1):
		printf("TX 1 out <= RX 1\n");
		break;
	case (BUS_ROUTER_SILENT):
		printf("TX 1 out <= 0\n");
		break;
	default:
		printf("TX 1 out <= invalid\n");
		break;

	}
#endif
}



void bus_router_set_hub_sel(bus_router_t * inst, uint8_t hub_sel)
{
	inst->current_value &= ~(1<<HUB_SEL_SHIFT);
	inst->current_value |= ((hub_sel&0x1)<<HUB_SEL_SHIFT);
	inst->reg[0] = inst->current_value ;
}
