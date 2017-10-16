#ifndef INTERRUPT_CONTROLLER_H__
#define INTERRUPT_CONTROLLER_H__

#include "xil_types.h"

#define RISING_EDGE 0x3

int interrupt_init();


int interrupt_connect(u32 intr_id, void * callback, void * user_data, u8 priority, u8 trigger);

void interrupt_enable(u32 intr_id);
void interrupt_disable(u32 intr_id);




#endif
