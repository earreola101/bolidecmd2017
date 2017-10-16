#include "version_driver.h"
#include "xparameters.h"

uint32_t sw_get_version()
{

	return SW_VERSION;
}

uint32_t fpga_get_version()
{
	uint32_t * reg = (uint32_t*)XPAR_VERSION_IP_BASEADDR;
	return reg[0];
}
uint64_t fpga_get_dna()
{
	uint32_t * reg = (uint32_t*)XPAR_VERSION_IP_BASEADDR;
	uint64_t auxVal = reg[2];
	auxVal = (auxVal << 32)&0xFFFFFFFF00000000;
	auxVal |= reg[1];
	return auxVal;
}

void get_version_struct(dev_info_t * ver)
{
	ver->sw_version = sw_get_version();
	ver->fpga_version = fpga_get_version();
	ver->fpga_unique_id = fpga_get_dna();
}
