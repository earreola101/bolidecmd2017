#ifndef VERSION_MODULE_H__
#define VERSION_MODULE_H__



#include "version.h"


void get_version_struct(dev_info_t * ver);

uint32_t sw_get_version();
uint32_t fpga_get_version();
uint64_t fpga_get_dna();
uint32_t linux_get_version();
void set_stm_version(uint32_t ver);
#endif
