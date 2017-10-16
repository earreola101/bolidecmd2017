#ifndef GPIOS_H__
#define GPIOS_H__

#include "xil_types.h"
int gpios_init(int peripheral_id);
void leds_init(int offset);
void leds_set(int led_num, int val);
void leds_set_mask(uint8_t mask);
void leds_set_beam(int beam);

void reset_n_adc_init(int offset);
void reset_n_set(int val);
void mute_button_init(int offset);
int mute_button_get();

#endif
