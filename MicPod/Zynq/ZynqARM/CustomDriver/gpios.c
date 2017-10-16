#include "gpios.h"
#include "xparameters.h"
#include "xgpiops.h"

XGpioPs gpio_inst;
int leds_offset = 54;
int rst_offset = 62;
int mute_offset = 64;


int gpios_init(int peripheral_id)
{
	int Status;

	XGpioPs_Config *ConfigPtr;


	/* Initialize the GPIO driver. */
	ConfigPtr = XGpioPs_LookupConfig(peripheral_id);
	Status = XGpioPs_CfgInitialize(&gpio_inst, ConfigPtr,ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}



void leds_init(int offset)
{
	leds_offset=offset;
	int i=0;
	for(i=0; i<8; i++)
	{
		XGpioPs_SetDirectionPin(&gpio_inst, i+leds_offset, 1);
		XGpioPs_SetOutputEnablePin(&gpio_inst, i+leds_offset, 1);
		XGpioPs_WritePin(&gpio_inst, i+leds_offset, 0x0);
	}
}

void leds_set(int led_num, int val)
{
	XGpioPs_WritePin(&gpio_inst, led_num+leds_offset, val);
}

void leds_set_mask(uint8_t mask)
{
	int i=0;
	for(i=0; i<8; i++)
		XGpioPs_WritePin(&gpio_inst, i+leds_offset, (mask>>i)&0x1);
}

void leds_set_beam(int beam)
{
	leds_set_mask(0xFF);
	switch(beam)
	{
	case 0:
		leds_set(6, 0);
		break;
	case 1:
		leds_set(4, 0);
		break;
	case 2:
		leds_set(2, 0);
		break;
	case 3:
		leds_set(0, 0);
		break;
	case 4:
		leds_set(5, 0);
		break;
	case 5:
		leds_set(7, 0);
		break;
	case 6:
		leds_set(3, 0);
		break;
	case 7:
		leds_set(1, 0);
		break;
	default:
		break;
	}
}
void reset_n_adc_init(int offset)
{
	rst_offset=offset;
	XGpioPs_SetDirectionPin(&gpio_inst, 0+rst_offset, 1);
	XGpioPs_SetOutputEnablePin(&gpio_inst, 0+rst_offset, 1);
	XGpioPs_WritePin(&gpio_inst, 0+rst_offset, 0x0);
	XGpioPs_SetDirectionPin(&gpio_inst, 1+rst_offset, 1);
	XGpioPs_SetOutputEnablePin(&gpio_inst, 1+rst_offset, 1);
	XGpioPs_WritePin(&gpio_inst, 1+rst_offset, 0x0);
}
void reset_n_set(int val)
{
	XGpioPs_WritePin(&gpio_inst, 0+rst_offset, val);
	XGpioPs_WritePin(&gpio_inst, 1+rst_offset, val);
}

void mute_button_init(int offset)
{
	mute_offset=offset;
	XGpioPs_SetDirectionPin(&gpio_inst, mute_offset, 1);
}
int mute_button_get()
{
	return XGpioPs_ReadPin(&gpio_inst,mute_offset);
}





