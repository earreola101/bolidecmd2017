#ifndef BUS_ROUTER_DRIVER_H__
#define BUS_ROUTER_DRIVER_H__



#include "xil_types.h"
#include "xparameters.h"



typedef struct bus_router_t
{
	u32 * reg;
	u32 current_value;
}bus_router_t;

//tx_bus_0_sel               	<= slv_regs_r(0)(1 downto 0);
//bus_0_dir					<= slv_regs_r(0)(2);
//bus_1_dir					<= slv_regs_r(0)(3);
//tx_bus_1_sel               	<= slv_regs_r(0)(5 downto 4);
//bus_2_dir					<= slv_regs_r(0)(6);
//bus_3_dir					<= slv_regs_r(0)(7);
//
//rx_hub_sel               	<= slv_regs_r(0)(8);
//rx_0_mux					<= slv_regs_r(0)(9);
//rx_1_mux					<= slv_regs_r(0)(10);
//tx_cc_0_sel               	<= slv_regs_r(0)(13 downto 12);
//tx_cc_1_sel               	<= slv_regs_r(0)(15 downto 14);


#define TX_BUS_0_SEL_SHIFT  	0
#define TX_BUS_0_SEL_MASK  		0x3
#define DIR_BUS_0_SHIFT			2
#define DIR_BUS_1_SHIFT			3

#define TX_BUS_1_SEL_SHIFT  	4
#define TX_BUS_1_SEL_MASK  		0x3
#define DIR_BUS_2_SHIFT			6
#define DIR_BUS_3_SHIFT			7

#define RX_HUB_SEL_SHIFT	  	8
#define RX_0_SEL_SHIFT		  	9
#define RX_1_SEL_SHIFT		  	10

#define TX_CC_0_SEL_SHIFT		12
#define TX_CC_0_SEL_MASK		0x3
#define TX_CC_1_SEL_SHIFT		14
#define TX_CC_1_SEL_MASK		0x3

#define BUS_SILENT				0
#define CONNECT_TX_HUB			1
#define CONNECT_RX_0			2
#define CONNECT_RX_1			3

#define SEL_HUB_0				0
#define SEL_HUB_1				1

#define SEL_RJ_0				0
#define SEL_RJ_1				1
#define SEL_RJ_2				0
#define SEL_RJ_3				1

#define DIR_RX					0
#define DIR_TX					1

//initialization
void bus_router_init(bus_router_t * inst, u32 base_addr);


//DIR_RJ_0 	<= 	bus_0_dir;
//DIR_RJ_1 	<= 	bus_1_dir;
//
//DIR_RJ_2 	<= 	bus_2_dir;
//DIR_RJ_3 	<= 	bus_3_dir;
//
//
//RX_BUS_0 	<= 	RX_RJ_0 when rx_0_mux = '0' else
//				RX_RJ_1;
//
//RX_BUS_1 	<= 	RX_RJ_2 when rx_1_mux = '0' else
//				RX_RJ_3;
//
//TX_RJ_0 	<= TX_BUS_0;
//TX_RJ_1 	<= TX_BUS_0;
//
//TX_RJ_2 	<= TX_BUS_1;
//TX_RJ_3 	<= TX_BUS_1;
//
//
//TX_BUS_0 	<= 	TX_hub_0  	when tx_bus_0_sel 	= "01" else
//				RX_BUS_0	when tx_bus_0_sel	= "10" else
//				RX_BUS_1	when tx_bus_0_sel	= "11" else
//				'0';
//
//TX_BUS_1 	<= 	TX_hub_0  	when tx_bus_1_sel 	= "01" else
//				RX_BUS_0	when tx_bus_1_sel	= "10" else
//				RX_BUS_1	when tx_bus_1_sel	= "11" else
//				'0';
//
//RX_hub_0 	<= 	RX_BUS_0	when rx_hub_sel = '0' else
//                RX_BUS_1;
//
//RX_hub_1 	<= 	RX_BUS_1   	when rx_hub_sel = '0' else
//                RX_BUS_0;
//
//TX_CC_0	    <= 	RX_BUS_0    when tx_cc_0_sel    = "10" else
//				RX_BUS_1	when tx_cc_0_sel    = "11" else
//				'0';
//
//TX_CC_1	    <= 	RX_BUS_0	when tx_cc_1_sel    = "10" else
//				RX_BUS_1	when tx_cc_1_sel    = "11" else
//				'0';

void bus_router_set_dir0(bus_router_t * inst, uint8_t dir);
void bus_router_set_dir1(bus_router_t * inst, uint8_t dir);
void bus_router_set_dir2(bus_router_t * inst, uint8_t dir);
void bus_router_set_dir3(bus_router_t * inst, uint8_t dir);

void bus_router_set_rx0_sel(bus_router_t * inst, uint8_t sel);
void bus_router_set_rx1_sel(bus_router_t * inst, uint8_t sel);

void bus_router_set_tx0(bus_router_t * inst, uint8_t sel);
void bus_router_set_tx1(bus_router_t * inst, uint8_t sel);
void bus_router_set_tx2(bus_router_t * inst, uint8_t sel);
void bus_router_set_tx3(bus_router_t * inst, uint8_t sel);



void bus_router_set_hub_sel(bus_router_t * inst, uint8_t hub_sel);











#endif
