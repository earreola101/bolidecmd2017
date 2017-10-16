#ifndef GPIOS_MICPOD_HUB_H__
#define GPIOS_MICPOD_HUB_H__

#include "xil_types.h"
int gpios_micpodhub_init(int peripheral_id);
void leds_micpodhub_init(int offset);
void leds_micpodhub_set(int led_num, int val);
void leds_micpodhub_set_mask(uint8_t mask);


#endif
