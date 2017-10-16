#ifndef BUS_ROUTER_DRIVER_H__
#define BUS_ROUTER_DRIVER_H__



#include "xil_types.h"
#include "xparameters.h"



typedef struct bus_router_t
{
	u32 * reg;
	u32 current_value;
}bus_router_t;




#define TX0_SEL_SHIFT  	0
#define TX0_SEL_MASK  	0x7

#define TX1_SEL_SHIFT  	4
#define TX1_SEL_MASK  	0x7

#define HUB_SEL_SHIFT	8

#define BUS_ROUTER_TX_HUB		2
#define BUS_ROUTER_RX_0			4
#define BUS_ROUTER_RX_1			5
#define BUS_ROUTER_SILENT		0

#define BUS_ROUTER_HUB_0		0
#define BUS_ROUTER_HUB_1		1


//initialization
void bus_router_init(bus_router_t * inst, u32 base_addr);
//
//TX_0_out <= TX_hub  	when tx0_sel 	= "010" else
//			RX_0        when tx0_sel	= "100" else
//			RX_1		when tx0_sel	= "101"	else
//			'0';
//
//TX_1_out <= TX_hub  	when tx1_sel 	= "010" else
//            RX_0        when tx1_sel    = "100" else
//            RX_1        when tx1_sel    = "101" else
//            '0';
//
//RX_hub_out <= 	RX_0    when rx_hub_sel = '0' else
//                RX_1;
//
//RX_mic_out <= 	RX_1    when rx_hub_sel = '0' else
//                RX_0;
					

void bus_router_set_tx0(bus_router_t * inst, uint8_t sel);
void bus_router_set_tx1(bus_router_t * inst, uint8_t sel);



void bus_router_set_hub_sel(bus_router_t * inst, uint8_t hub_sel);











#endif
