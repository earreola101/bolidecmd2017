#include "cs2000.h"

//#define CS2000_USE_INTERNAL


#define CS2000_REG_DEVICE_CONTROL			0x02
#define CS2000_REG_DEVICE_CONFIGURATION_1	0x03
#define CS2000_REG_DEVICE_CONFIGURATION_2	0x04
#define CS2000_REG_GLOBAL_CONFIGURATION		0x05
#define CS2000_REG_RATIO					0x06
#define CS2000_REG_FUNCTION_CONFIGURATION_1	0x16
#define CS2000_REG_FUNCTION_CONFIGURATION_2	0x17
#define CS2000_REG_FUNCTION_CONFIGURATION_3	0x1E


//INTERNAL
//CS2000_REG_DEVICE_CONTROL
#define CS2000_AUX_OUT_DIS			0 	//per disabilitare l'uscita aux
#define CS2000_CLK_OUT_DIS			0	//Per disabilitare l'uscita del clock

//CS2000_REG_DEVICE_CONFIGURATION_1
#define CS2000_R_MOD_SEL			0x0 	//x 8 (Pag 20)

#define CS2000_AUX_OUT_SRC			0x3 	//PLL lock sull'aux pin
//#define CS2000_AUX_OUT_SRC			0x2 	//PLL lock sull'aux pin

//CS2000_REG_DEVICE_CONFIGURATION_2
#define CS2000_X1_R_SEL				0x0 	//Selezioniamo il ratio (0 1 2 3)
#define CS2000_X2_R_SEL				0x2 	//Selezioniamo il ratio (0 1 2 3)

#define CS2000_X1_LOCK_CLK			0x0 	//Select Ratio for Dynamic mode
#define CS2000_X2_LOCK_CLK			0x2 	//Select Ratio for Dynamic mode

#define CS2000_WCLK_FRAC_N_SRC		0x1 	//0 Static Ration - 1 Dynamic Ratio
#define CS2000_INTERNAL_FRAC_N_SRC	0x0		//0 Static Ration - 1 Dynamic Ratio

//CS2000_REG_RATIO
//#define CS2000_RATIO_0				(0x0017384E) //16.9344 / 2
#define CS2000_INTERNAL_RATIO_0		0x00100000 //16.9344 / 2
#define CS2000_RATIO_1				0x00100000
#define CS2000_RATIO_2				0x00200000
#define CS2000_RATIO_3				0x00200000

#define CS2000_WCLK_RATIO_0			0x20000000 //16.9344 / 2


//CS2000_REG_FUNCTION_CONFIGURATION_1
#define CS2000_CLK_SKIP_EN			1	//0 normale 1 anche se l'ingresso salta lui rimane a dare quella frequenza
#define CS2000_AUX_LOCK_CFG			0	//0 Push pull (0 locked, 1 unlocked) 1 open drain (0 unlocked, open drain locked)
#define CS2000_REF_CLK_DIV			2	//00 (32 - 56 MHz), 01 (16 - 28 MHz), 10 (8 - 14 MHz), 11 reserved

//CS2000_REG_FUNCTION_CONFIGURATION_2
#define CS2000_CLK_OUT_UNL			0	//0 se unlocked va a 0, 1 impredicibile
#define CS2000_LF_RATIO_CFG			1 	//0 20.12, 1 12.20

//CS2000_REG_FUNCTION_CONFIGURATION_3
#define CS2000_CLK_IN_BW			0 	//Pag17


int cs2000_write_reg(spi_driver_t* bdSpiInst, u8 regNum, u8 value)
{
	u8 buf[3];
	buf[0]=0x9E;
	buf[1]=regNum;
	buf[2]=value;
	return spi_driver_send(bdSpiInst, buf, 3);
}


//multiplier 1 44.1/48 kHz, 2 88.2/96 kHz
int cs2000_change_source(spi_driver_t* commInstUsed,cs2000_source_e source)
{
	int CS2000_FRAC_N_SRC	 = CS2000_INTERNAL_FRAC_N_SRC;
	u32  CS2000_RATIO_0		 = CS2000_INTERNAL_RATIO_0;
	int CS2000_LOCK_CLK = CS2000_X1_LOCK_CLK;


	if(source==CS2000_EXTERNAL)
	{
		CS2000_FRAC_N_SRC	 = 	CS2000_WCLK_FRAC_N_SRC;
		CS2000_RATIO_0		 = CS2000_WCLK_RATIO_0;
	}
	//Freeze the configuration
	cs2000_write_reg(commInstUsed,
			CS2000_REG_GLOBAL_CONFIGURATION,
			(1 						<< 3));
	//RATIO 0
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO,
			(CS2000_RATIO_0>>24) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+1,
			(CS2000_RATIO_0>>16) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+2,
			(CS2000_RATIO_0>>8) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+3,
			CS2000_RATIO_0 & 0xFF);

	cs2000_write_reg(commInstUsed,
			CS2000_REG_DEVICE_CONFIGURATION_2,
			(CS2000_LOCK_CLK 		<< 1) 	|
			(CS2000_FRAC_N_SRC 		<< 0));

	//Unfreeze the configuration
	cs2000_write_reg(commInstUsed,
			CS2000_REG_GLOBAL_CONFIGURATION,
			(1						<< 0));
	return 0;
}



int cs2000_init(spi_driver_t* commInstUsed,cs2000_source_e source, int multiplier)
{
	int CS2000_FRAC_N_SRC	 = 	CS2000_INTERNAL_FRAC_N_SRC;
	u32  CS2000_RATIO_0		 =  CS2000_INTERNAL_RATIO_0;

	if(source==CS2000_EXTERNAL)
	{
		CS2000_FRAC_N_SRC	 = 	CS2000_WCLK_FRAC_N_SRC;
		CS2000_RATIO_0		 =  CS2000_WCLK_RATIO_0;
	}
	int CS2000_R_SEL = CS2000_X1_R_SEL;
	int CS2000_LOCK_CLK = CS2000_X1_LOCK_CLK;

	if(multiplier==2)
	{
		CS2000_R_SEL = CS2000_X2_R_SEL;
		CS2000_LOCK_CLK = CS2000_X2_LOCK_CLK;
	}


	//Freeze the configuration
	cs2000_write_reg(commInstUsed,
			CS2000_REG_GLOBAL_CONFIGURATION,
			(1 						<< 3));
	cs2000_write_reg(commInstUsed,
			CS2000_REG_DEVICE_CONTROL,
			(CS2000_AUX_OUT_DIS 	<< 1) 	|
			(CS2000_CLK_OUT_DIS 	<< 0));
	cs2000_write_reg(commInstUsed,
			CS2000_REG_DEVICE_CONFIGURATION_1,
			(CS2000_R_MOD_SEL 		<< 5) 	|
			(CS2000_R_SEL 			<< 3) 	|
			(CS2000_AUX_OUT_SRC 	<< 1) 	|
			(1 						<< 0));

	cs2000_write_reg(commInstUsed,
			CS2000_REG_DEVICE_CONFIGURATION_2,
			(CS2000_LOCK_CLK 		<< 1) 	|
			(CS2000_FRAC_N_SRC 		<< 0));

	//RATIO 0
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO,
			(CS2000_RATIO_0>>24) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+1,
			(CS2000_RATIO_0>>16) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+2,
			(CS2000_RATIO_0>>8) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+3,
			CS2000_RATIO_0 & 0xFF);

	//RATIO 1
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 4,
			(CS2000_RATIO_1>>24) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 5,
			(CS2000_RATIO_1>>16) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 6,
			(CS2000_RATIO_1>>8) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 7,
			CS2000_RATIO_1 & 0xFF);
	//RATIO 2
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 8,
			(CS2000_RATIO_2>>24) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 9,
			(CS2000_RATIO_2>>16) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 10,
			(CS2000_RATIO_2>>8) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 11,
			CS2000_RATIO_2 & 0xFF);
	//RATIO 3
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 12,
			(CS2000_RATIO_3>>24) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 13,
			(CS2000_RATIO_3>>16) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 14,
			(CS2000_RATIO_3>>8) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO + 15,
			CS2000_RATIO_3 & 0xFF);



	cs2000_write_reg(commInstUsed,
			CS2000_REG_FUNCTION_CONFIGURATION_1,
			(CS2000_CLK_SKIP_EN 	<< 7) 	|
			(CS2000_AUX_LOCK_CFG	<< 6) 	|
			(CS2000_REF_CLK_DIV 	<< 3));

	cs2000_write_reg(commInstUsed,
			CS2000_REG_FUNCTION_CONFIGURATION_2,
			(CS2000_CLK_OUT_UNL 	<< 4) 	|
			(CS2000_LF_RATIO_CFG	<< 3));

	cs2000_write_reg(commInstUsed,
			CS2000_REG_FUNCTION_CONFIGURATION_3,
			(CS2000_CLK_IN_BW 	<< 4));

	//Unfreeze the configuration
	cs2000_write_reg(commInstUsed,
			CS2000_REG_GLOBAL_CONFIGURATION,
			(1						<< 0));


	return XST_SUCCESS;
}

int cs2000_set_mult(spi_driver_t* commInstUsed, u32 ratio)
{
	cs2000_write_reg(commInstUsed,
			CS2000_REG_GLOBAL_CONFIGURATION,
			(1 						<< 3));

	//RATIO 0
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO,
			(ratio>>24) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+1,
			(ratio>>16) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+2,
			(ratio>>8) & 0xFF);
	cs2000_write_reg(commInstUsed,
			CS2000_REG_RATIO+3,
			ratio & 0xFF);

	cs2000_write_reg(commInstUsed,
			CS2000_REG_GLOBAL_CONFIGURATION,
			(1						<< 0));
	return XST_SUCCESS;
}



