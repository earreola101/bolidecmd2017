#include "mediator.h"
#include "audio_routine.h"
#include <stdio.h>
#include "utility.h"
#include "version_module.h"
#include "tdm_bus.h"
#include <signal.h>
#include "status.h"

static volatile int keepRunning = 1;

void intHandler(int dummy) {
    keepRunning = 0;
}


int main(void)
{
	signal(SIGINT, intHandler);
	printf("\n\n\n\n\nTable Hub app started\n");
	printf("SW version %lu\n",sw_get_version());
	printf("FPGA version %lu\n",fpga_get_version());
	printf("FPGA unique id 0x%llx\n",fpga_get_dna());
	printf("LINUX version %lu\n",linux_get_version());


	if(sizeof(generic_device_t)>1000)
	{
		printf("Error: generic_device_t too large: %d, max 1000\n",sizeof(system_status_t));
		return -1;
	}
	//printf("Jiffy %d\n", sysconf(_SC_CLK_TCK));
	init_table_hub_mediator();
	audio_routine_init();



	keepRunning = 1;
	while(keepRunning){
//		char q = getchar();
//		if(q=='q')
//		{
//			break;
//		}
//		if(!audio_routine_get_running())
//		{
//			break;
//		}
		sleep_ms(10);

	}
	audio_routine_deinit();
	deinit_table_hub_mediator();
	printf("Exiting main\n");
	return 0;
}


