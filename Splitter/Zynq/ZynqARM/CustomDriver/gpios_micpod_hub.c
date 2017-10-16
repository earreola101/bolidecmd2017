#include "gpios_micpod_hub.h"
#include "xparameters.h"
#include "xgpiops.h"
#include "stdio.h"
XGpioPs gpio_inst;
int leds_offset = 0;



int gpios_micpodhub_init(int peripheral_id)
{
	int Status;

	XGpioPs_Config *ConfigPtr;


	/* Initialize the GPIO driver. */
	ConfigPtr = XGpioPs_LookupConfig(peripheral_id);
	Status = XGpioPs_CfgInitialize(&gpio_inst, ConfigPtr,ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
		printf("Init gpio fail\n");
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}



void leds_micpodhub_init(int offset)
{
	leds_offset=offset;
	int i=0;
	for(i=0; i<4; i++)
	{
		XGpioPs_SetDirectionPin(&gpio_inst, i+leds_offset, 1);
		XGpioPs_SetOutputEnablePin(&gpio_inst, i+leds_offset, 1);
		XGpioPs_WritePin(&gpio_inst, i+leds_offset, 0x0);
	}
}

void leds_micpodhub_set(int led_num, int val)
{
	XGpioPs_WritePin(&gpio_inst, led_num+leds_offset, val);
}

void leds_micpodhub_set_mask(uint8_t mask)
{
	int i=0;
	for(i=0; i<4; i++)
		XGpioPs_WritePin(&gpio_inst, i+leds_offset, (mask>>i)&0x1);
}






