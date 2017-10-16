#include "bus_router_driver_micpod_hub.h"
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


void bus_router_set_dir0(bus_router_t * inst, uint8_t dir)
{
	inst->current_value &= ~(1<<DIR_BUS_0_SHIFT);
	inst->current_value |= ((dir&0x1)<<DIR_BUS_0_SHIFT);
	inst->reg[0] = inst->current_value;
#ifdef DEBUG_BUS
	if(dir)
		printf("RJ0 dir sel: TX\n");
	else
		printf("RJ0 dir sel: RX\n");
#endif
}

void bus_router_set_dir1(bus_router_t * inst, uint8_t dir)
{
	inst->current_value &= ~(1<<DIR_BUS_1_SHIFT);
	inst->current_value |= ((dir&0x1)<<DIR_BUS_1_SHIFT);
	inst->reg[0] = inst->current_value;
#ifdef DEBUG_BUS
	if(dir)
		printf("RJ1 dir sel: TX\n");
	else
		printf("RJ1 dir sel: RX\n");
#endif
}

void bus_router_set_dir2(bus_router_t * inst, uint8_t dir)
{
	inst->current_value &= ~(1<<DIR_BUS_2_SHIFT);
	inst->current_value |= ((dir&0x1)<<DIR_BUS_2_SHIFT);
	inst->reg[0] = inst->current_value;
#ifdef DEBUG_BUS
	if(dir)
		printf("RJ2 dir sel: TX\n");
	else
		printf("RJ2 dir sel: RX\n");
#endif
}

void bus_router_set_dir3(bus_router_t * inst, uint8_t dir)
{
	inst->current_value &= ~(1<<DIR_BUS_3_SHIFT);
	inst->current_value |= ((dir&0x1)<<DIR_BUS_3_SHIFT);
	inst->reg[0] = inst->current_value;
#ifdef DEBUG_BUS
	if(dir)
		printf("RJ3 dir sel: TX\n");
	else
		printf("RJ3 dir sel: RX\n");
#endif
}


void bus_router_set_rx0_sel(bus_router_t * inst, uint8_t sel)
{
	inst->current_value &= ~(1<<RX_0_SEL_SHIFT);
	inst->current_value |= ((sel&0x1)<<RX_0_SEL_SHIFT);
	inst->reg[0] = inst->current_value;
#ifdef DEBUG_BUS
	if(sel==SEL_RJ_0)
		printf("RX_BUS_0 <= RX_RJ_0\n");
	else
		printf("RX_BUS_0 <= RX_RJ_1\n");
#endif
}

void bus_router_set_rx1_sel(bus_router_t * inst, uint8_t sel)
{
	inst->current_value &= ~(1<<RX_1_SEL_SHIFT);
	inst->current_value |= ((sel&0x1)<<RX_1_SEL_SHIFT);
	inst->reg[0] = inst->current_value;
#ifdef DEBUG_BUS
	if(sel==SEL_RJ_0)
		printf("RX_BUS_1 <= RX_RJ_2\n");
	else
		printf("RX_BUS_1 <= RX_RJ_3\n");
#endif
}



void bus_router_set_tx0(bus_router_t * inst, uint8_t sel)
{
	inst->current_value &= ~(TX_BUS_0_SEL_MASK<<TX_BUS_0_SEL_SHIFT);
	inst->current_value |= ((sel&TX_BUS_0_SEL_MASK)<<TX_BUS_0_SEL_SHIFT);
	inst->reg[0] = inst->current_value ;
#ifdef DEBUG_BUS
	switch(sel)
	{
	case (CONNECT_TX_HUB):
		printf("TX 0 out <= TX HUB\n");
		break;
	case (CONNECT_RX_0):
		printf("TX 0 out <= RX 0\n");
		break;
	case (CONNECT_RX_1):
		printf("TX 0 out <= RX 1\n");
		break;
	case (BUS_SILENT):
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
	inst->current_value &= ~(TX_BUS_1_SEL_MASK<<TX_BUS_1_SEL_SHIFT);
	inst->current_value |= ((sel&TX_BUS_1_SEL_MASK)<<TX_BUS_1_SEL_SHIFT);
	inst->reg[0] = inst->current_value ;
#ifdef DEBUG_BUS
	switch(sel)
	{
	case (CONNECT_TX_HUB):
		printf("TX 1 out <= TX HUB\n");
		break;
	case (CONNECT_RX_0):
		printf("TX 1 out <= RX 0\n");
		break;
	case (CONNECT_RX_1):
		printf("TX 1 out <= RX 1\n");
		break;
	case (BUS_SILENT):
		printf("TX 1 out <= 0\n");
		break;
	default:
		printf("TX 1 out <= invalid\n");
		break;

	}
#endif
}

void bus_router_set_tx2(bus_router_t * inst, uint8_t sel)
{
	inst->current_value &= ~(TX_CC_0_SEL_MASK<<TX_CC_0_SEL_SHIFT);
	inst->current_value |= ((sel&TX_CC_0_SEL_MASK)<<TX_CC_0_SEL_SHIFT);
	inst->reg[0] = inst->current_value ;
#ifdef DEBUG_BUS
	switch(sel)
	{
	case (CONNECT_RX_0):
		printf("TX 2 out <= RX 0\n");
		break;
	case (CONNECT_RX_1):
		printf("TX 2 out <= RX 1\n");
		break;
	case (BUS_SILENT):
		printf("TX 2 out <= 0\n");
		break;
	default:
		printf("TX 2 out <= invalid\n");
		break;

	}
#endif
}

void bus_router_set_tx3(bus_router_t * inst, uint8_t sel)
{
	inst->current_value &= ~(TX_CC_1_SEL_MASK<<TX_CC_1_SEL_SHIFT);
	inst->current_value |= ((sel&TX_CC_1_SEL_MASK)<<TX_CC_1_SEL_SHIFT);
	inst->reg[0] = inst->current_value ;
#ifdef DEBUG_BUS
	switch(sel)
	{
	case (CONNECT_RX_0):
		printf("TX 3 out <= RX 0\n");
		break;
	case (CONNECT_RX_1):
		printf("TX 3 out <= RX 1\n");
		break;
	case (BUS_SILENT):
		printf("TX 3 out <= 0\n");
		break;
	default:
		printf("TX 3 out <= invalid\n");
		break;

	}
#endif
}



void bus_router_set_hub_sel(bus_router_t * inst, uint8_t hub_sel)
{
	inst->current_value &= ~(1<<RX_HUB_SEL_SHIFT);
	inst->current_value |= ((hub_sel&0x1)<<RX_HUB_SEL_SHIFT);
	inst->reg[0] = inst->current_value;
#ifdef DEBUG_BUS
	printf("Hub selected: %d\n",hub_sel);
#endif
}
