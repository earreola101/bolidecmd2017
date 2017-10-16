#ifndef VERSION_DRIVER_H__
#define VERSION_DRIVER_H__



#include "version.h"


void get_version_struct(dev_info_t * ver);

uint32_t sw_get_version();
uint32_t fpga_get_version();
uint64_t fpga_get_dna();


#endif
