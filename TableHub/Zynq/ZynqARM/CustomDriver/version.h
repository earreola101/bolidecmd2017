#ifndef VERSION_H__
#define VERSION_H__
#include "stdint.h"
#include "repo_version.h"



typedef struct dev_info_t
{
	uint32_t sw_version;
	uint32_t fpga_version;
	uint64_t fpga_unique_id;
	uint32_t stm_version;
	uint32_t linux_version;

}dev_info_t;

#endif
