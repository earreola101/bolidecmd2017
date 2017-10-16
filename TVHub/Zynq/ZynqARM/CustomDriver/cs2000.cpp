#include "cs2000.h"
#include "stdio.h"
#include "utility.h"
//#define BD_PLL_USE_INTERNAL
//#define CS2100

#define BD_PLL_REG_DEVICE_CONTROL			0x02
#define BD_PLL_REG_DEVICE_CONFIGURATION_1	0x03
#define BD_PLL_REG_DEVICE_CONFIGURATION_2	0x04
#define BD_PLL_REG_GLOBAL_CONFIGURATION		0x05
#define BD_PLL_REG_RATIO					0x06
#define BD_PLL_REG_FUNCTION_CONFIGURATION_1	0x16
#define BD_PLL_REG_FUNCTION_CONFIGURATION_2	0x17
#define BD_PLL_REG_FUNCTION_CONFIGURATION_3	0x1E


//INTERNAL
//BD_PLL_REG_DEVICE_CONTROL
#define BD_PLL_AUX_OUT_DIS			1 	//per disabilitare l'uscita aux
#define BD_PLL_CLK_OUT_DIS			0	//Per disabilitare l'uscita del clock

//BD_PLL_REG_DEVICE_CONFIGURATION_1
#define BD_PLL_R_MOD_SEL			0x0 	//x 8 (Pag 20)

#define BD_PLL_AUX_OUT_SRC			0x3 	//PLL lock sull'aux pin

//BD_PLL_REG_DEVICE_CONFIGURATION_2
#define BD_PLL_X1_R_SEL				0x0 	//Selezioniamo il ratio (0 1 2 3)
#define BD_PLL_X2_R_SEL				0x2 	//Selezioniamo il ratio (0 1 2 3)

#define BD_PLL_X1_LOCK_CLK			0x0 	//Select Ratio for Dynamic mode
#define BD_PLL_X2_LOCK_CLK			0x2 	//Select Ratio for Dynamic mode

#define BD_PLL_WCLK_FRAC_N_SRC		0x1 	//0 Static Ration - 1 Dynamic Ratio
#define BD_PLL_INTERNAL_FRAC_N_SRC	0x0		//0 Static Ration - 1 Dynamic Ratio

//BD_PLL_REG_RATIO
//#define BD_PLL_RATIO_0				(0x0017384E) //16.9344 / 2
#define BD_PLL_INTERNAL_RATIO_0		0x00100000 //16.9344 / 2
#define BD_PLL_RATIO_1				0x00100000
#define BD_PLL_RATIO_2				0x00200000
#define BD_PLL_RATIO_3				0x00200000

//#define BD_PLL_WCLK_RATIO_0			0x10000000 //
//#define BD_PLL_WCLK_RATIO_1			0x08000000 //

#define BD_PLL_WCLK_RATIO_48k			0x00100000 //
#define BD_PLL_WCLK_RATIO_96k			0x00080000 //
#define BD_PLL_WCLK_RATIO_960			0x03200000 //

#define BD_PLL_WCLK_RATIO_0			0x20000000 //16.9344 / 2

//BD_PLL_REG_FUNCTION_CONFIGURATION_1
#define BD_PLL_CLK_SKIP_EN			1	//0 normale 1 anche se l'ingresso salta lui rimane a dare quella frequenza
#define BD_PLL_AUX_LOCK_CFG			0	//0 Push pull (0 locked, 1 unlocked) 1 open drain (0 unlocked, open drain locked)
#define BD_PLL_REF_CLK_DIV			2	//00 (32 - 56 MHz), 01 (16 - 28 MHz), 10 (8 - 14 MHz), 11 reserved

//BD_PLL_REG_FUNCTION_CONFIGURATION_2
#define BD_PLL_CLK_OUT_UNL			0	//0 se unlocked va a 0, 1 impredicibile
#define CS2000_LF_RATIO_CFG			1 	//0 20.12, 1 12.20

//BD_PLL_REG_FUNCTION_CONFIGURATION_3
#define BD_PLL_CLK_IN_BW			0 	//Pag17



int cs2000_init(uint32_t source, int multiplier)
{



	int res = spi_init();
	if(res!=0)
		printf("[cs2000] SPI init error\n");

	if(source==BD_PLL_INTERNAL)
		printf("[cs2000] Initializing pll internal\n");
	else
		printf("[cs2000] Initializing pll external x %d\n", multiplier);

	int BD_PLL_FRAC_N_SRC	 = 	BD_PLL_INTERNAL_FRAC_N_SRC;
	uint32_t  BD_PLL_RATIO_0		 =  BD_PLL_INTERNAL_RATIO_0;

	if(source==BD_PLL_EXTERNAL)
	{
		BD_PLL_FRAC_N_SRC	 = 	BD_PLL_WCLK_FRAC_N_SRC;
		printf("External clock 48k\n");
		BD_PLL_RATIO_0		 = BD_PLL_WCLK_RATIO_0;

	}

	int BD_PLL_R_SEL = BD_PLL_X1_R_SEL;
	int BD_PLL_LOCK_CLK = BD_PLL_X1_LOCK_CLK;

	if(multiplier==2)
	{
		BD_PLL_R_SEL = BD_PLL_X2_R_SEL;
		//BD_PLL_LOCK_CLK = BD_PLL_X2_LOCK_CLK;
	}


	//Freeze the configuration
	spi_write(0x9E,
			BD_PLL_REG_GLOBAL_CONFIGURATION,
			(1 						<< 3));
	spi_write(0x9E,
			BD_PLL_REG_DEVICE_CONTROL,
			//AUX_OUT enabled
			(BD_PLL_AUX_OUT_DIS 	<< 1) 	|
			//Clock out enabled
			(BD_PLL_CLK_OUT_DIS 	<< 0));

	spi_write(0x9E,
			BD_PLL_REG_DEVICE_CONFIGURATION_1,
			//Left shift R value by 0
			(BD_PLL_R_MOD_SEL 		<< 5) 	|
			//Select ratio in static frequency synth
			(BD_PLL_R_SEL 			<< 3) 	|
			//Aux out pll lock
			(BD_PLL_AUX_OUT_SRC 	<< 1) 	|
			//Enable device configuration 2 register
			(1 						<< 0));
#ifndef CS2100
	spi_write(0x9E,
			BD_PLL_REG_DEVICE_CONFIGURATION_2,
			//Select ratio in dynamic mode
			(BD_PLL_LOCK_CLK 		<< 1) 	|
			//Select between static and dynamic mode (auto clock switching need to be disabled)
			(BD_PLL_FRAC_N_SRC 		<< 0));
#endif
	//RATIO 0
	spi_write(0x9E,
			BD_PLL_REG_RATIO,
			(BD_PLL_RATIO_0>>24) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO+1,
			(BD_PLL_RATIO_0>>16) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO+2,
			(BD_PLL_RATIO_0>>8) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO+3,
			BD_PLL_RATIO_0 & 0xFF);
#ifndef CS2100
	//RATIO 1
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 4,
			(BD_PLL_RATIO_1>>24) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 5,
			(BD_PLL_RATIO_1>>16) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 6,
			(BD_PLL_RATIO_1>>8) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 7,
			BD_PLL_RATIO_1 & 0xFF);
	//RATIO 2
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 8,
			(BD_PLL_RATIO_2>>24) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 9,
			(BD_PLL_RATIO_2>>16) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 10,
			(BD_PLL_RATIO_2>>8) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 11,
			BD_PLL_RATIO_2 & 0xFF);
	//RATIO 3
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 12,
			(BD_PLL_RATIO_3>>24) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 13,
			(BD_PLL_RATIO_3>>16) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 14,
			(BD_PLL_RATIO_3>>8) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO + 15,
			BD_PLL_RATIO_3 & 0xFF);
#endif


	spi_write(0x9E,
			BD_PLL_REG_FUNCTION_CONFIGURATION_1,
			(BD_PLL_CLK_SKIP_EN 	<< 7) 	|
			(BD_PLL_AUX_LOCK_CFG	<< 6) 	|
			(BD_PLL_REF_CLK_DIV 	<< 3));

	spi_write(0x9E,
			BD_PLL_REG_FUNCTION_CONFIGURATION_2,
			(BD_PLL_CLK_OUT_UNL 	<< 4) 	|
			(CS2000_LF_RATIO_CFG	<< 3));

	spi_write(0x9E,
			BD_PLL_REG_FUNCTION_CONFIGURATION_3,
			(BD_PLL_CLK_IN_BW 	<< 4));

	//Unfreeze the configuration
	spi_write(0x9E,
			BD_PLL_REG_GLOBAL_CONFIGURATION,
			(1						<< 0));


	return 0;
}

void cs2000_deinit()
{
	 spi_deinit();
}
////multiplier 1 44.1/48 kHz, 2 88.2/96 kHz
//int cs2000_set_source(uint32_t source)
//{
//	pll->source = source;
//
//	if(source==BD_PLL_INTERNAL)
//		BINFO << "[cs2000] Set pll internal";
//	else
//		BINFO << "[cs2000] Set pll external";
//
//	int BD_PLL_FRAC_N_SRC	 = 	BD_PLL_INTERNAL_FRAC_N_SRC;
//	uint32_t  BD_PLL_RATIO_0		 = BD_PLL_INTERNAL_RATIO_0;
//	int BD_PLL_LOCK_CLK = BD_PLL_X1_LOCK_CLK;
//
//
//	if(source==BD_PLL_EXTERNAL)
//	{
//		BD_PLL_FRAC_N_SRC	 = 	BD_PLL_WCLK_FRAC_N_SRC;
//		BD_PLL_RATIO_0		 = BD_PLL_WCLK_RATIO_0;
//	}
//	//Freeze the configuration
//	spi_write(0x9E,
//			BD_PLL_REG_GLOBAL_CONFIGURATION,
//			(1 						<< 3));
//	//RATIO 0
//	spi_write(0x9E,
//			BD_PLL_REG_RATIO,
//			(BD_PLL_RATIO_0>>24) & 0xFF);
//	spi_write(0x9E,
//			BD_PLL_REG_RATIO+1,
//			(BD_PLL_RATIO_0>>16) & 0xFF);
//	spi_write(0x9E,
//			BD_PLL_REG_RATIO+2,
//			(BD_PLL_RATIO_0>>8) & 0xFF);
//	spi_write(0x9E,
//			BD_PLL_REG_RATIO+3,
//			BD_PLL_RATIO_0 & 0xFF);
//
//	spi_write(0x9E,
//			BD_PLL_REG_DEVICE_CONFIGURATION_2,
//			(BD_PLL_LOCK_CLK 		<< 1) 	|
//			(BD_PLL_FRAC_N_SRC 		<< 0));
//
//	//Unfreeze the configuration
//	spi_write(0x9E,
//			BD_PLL_REG_GLOBAL_CONFIGURATION,
//			(1						<< 0));
//	return 0;
//}

int cs2000_set_mul(uint32_t ratio)
{

	printf("[cs2000] Set pll x %d\n", ratio);
	spi_write(0x9E,
			BD_PLL_REG_GLOBAL_CONFIGURATION,
			(1 						<< 3));

	//RATIO 0
	spi_write(0x9E,
			BD_PLL_REG_RATIO,
			(ratio>>24) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO+1,
			(ratio>>16) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO+2,
			(ratio>>8) & 0xFF);
	spi_write(0x9E,
			BD_PLL_REG_RATIO+3,
			ratio & 0xFF);

	spi_write(0x9E,
			BD_PLL_REG_GLOBAL_CONFIGURATION,
			(1						<< 0));
	return 0;
}



