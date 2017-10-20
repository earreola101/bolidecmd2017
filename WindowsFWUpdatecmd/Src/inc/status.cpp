#include "status.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "commands.h"
#include "command_gen_dec.h"

#ifdef __linux
#include "gain_module.h"
#include "version_module.h"
#include "utility.h"
#endif

#ifndef WIN32
// SPP
//#include "I_SPP.hpp"
#include "MCHP_API.hpp"
I_MCHP *spp;
#endif

command_queue_t * pSend_receive_RXqueue;


//#define TEST_STATUS
#ifdef __linux
pthread_mutex_t *alive_mutex;
#endif

system_status_t system_status;
#define DEBUG_STATUS

//this function updates the specified device parameters
int system_status_update_dev_struct(generic_device_t * dev, uint8_t dev_count)
{
	switch(dev->type)
	{
		case MICPOD_DEVICE_TYPE:
			memcpy(&system_status.micpods[dev_count],dev, sizeof(generic_device_t));
			break;
		case TV_HUB_DEVICE_TYPE:
			memcpy(&system_status.tv_hub,dev, sizeof(generic_device_t));
			break;
		case TABLE_HUB_DEVICE_TYPE:
			memcpy(&system_status.table_hub,dev, sizeof(generic_device_t));
			break;
		case MICPOD_HUB_DEVICE_TYPE:
			memcpy(&system_status.micpod_hubs[dev_count],dev, sizeof(generic_device_t));
			break;
		case STM32_DEVICE_TYPE:
		case PC_DEVICE_TYPE:
		default:
			break;
	}
	return 0;
}

//this function returns the micpod index from specifie id, if alive.
int system_status_get_micpod_index_from_id(uint8_t id)
{
	int i;
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		if(system_status.micpods[i].id==id)
		{
			if(system_status.micpods[i].alive>0)
				return i;
		}
	}
	return -1;
}

//this function returns the device parameters from specifie id.
generic_device_t * system_status_get_device_from_id(uint8_t id)
{
	int i;
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		if(system_status.micpods[i].id==id)
		{
			if(system_status.micpods[i].alive>0)
				return &system_status.micpods[i];
		}
	}
	for(i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		if(system_status.micpod_hubs[i].id==id)
		{
			if(system_status.micpod_hubs[i].alive>0)
				return &system_status.micpod_hubs[i];
		}
	}
	if(system_status.table_hub.id==id)
	{
		return &system_status.table_hub;
	}
	if(system_status.tv_hub.id==id)
	{
		return &system_status.tv_hub;
	}
	return 0;
}

//this function initializes any connectable device
void system_init_device(generic_device_t * device, uint8_t type, uint8_t id)
{
	int i;

	device->id = id;
	device->alive = 0;
	device->type = type;

	device->debug_mode=0;
	device->dev_info.sw_version = 0;
	device->dev_info.fpga_version = 0;
	device->dev_info.fpga_unique_id= 0;
	switch(type)
	{
		case TABLE_HUB_DEVICE_TYPE:
		{
			device->int_num = 3;
			device->micCh = 0;
			device->spkCh = 2;
			device->table_hub_specific.ch_to_listen = 13;

			device->table_hub_specific.listenId=0;
			strcpy(device->table_hub_specific.debug_file, "/media/rootfs/record.wav");
			device->table_hub_specific.debug_enabled=0;
			device->table_hub_specific.volume=100;
			device->table_hub_specific.mute=0;
			break;
		}
		case MICPOD_DEVICE_TYPE:
		{
			device->int_num = 1;
			device->micCh = 1;
			device->spkCh = 0;
			device->micpod_specific.cpuLoad = 0;
			device->micpod_specific.ledOn = 0;
			device->micpod_specific.mute = 0;
			device->micpod_specific.postFilter = 0;

			break;
		}
		case TV_HUB_DEVICE_TYPE:
		{
			device->int_num = 2;
			device->micCh = 0;
			device->spkCh = 2;
			device->tv_hub_specific.usb_connected=0;


			break;
		}
		case MICPOD_HUB_DEVICE_TYPE:
		{
			device->int_num = 3;
			device->micCh = 0;
			device->spkCh = 0;
			device->micpod_hub_specific.ledOn=0;
			break;
		}

	}
	for(i=0; i<ROUTING_TABLE_LEN_BYTES; i++)
		device->audio_table[i]=0;
	for(i=0; i<ROUTING_TABLE_LEN_BYTES; i++)
		device->audio_id[i]=DEFAULT_UNINIT_ID;
	for(i=0; i<ROUTING_TABLE_LEN_BYTES; i++)
			device->audio_tag[i]=AUDIO_TAG_INVALID;

	for(i=0; i<3; i++)
	{
		device->intLocked[i]=0;
		device->intEnabled[i]=0;
		device->intDevice[i]=0;
		device->intId[i]=0xFF;
	}

	device->parent=0;
	device->parentId=0xFF;
	device->parentIntNum=0;
	device->tag=0;
}

void system_status_init(command_queue_t *queue)
{
	int i;
#ifndef WIN32
	mutex_init(&alive_mutex);
#endif
	system_init_device(&system_status.table_hub, TABLE_HUB_DEVICE_TYPE,DEFAULT_TABLE_HUB_ID);
	system_init_device(&system_status.tv_hub, TV_HUB_DEVICE_TYPE,DEFAULT_TV_HUB_ID);

	for(i=0; i<MICPOD_MAX_N; i++)
		system_init_device(&system_status.micpods[i], MICPOD_DEVICE_TYPE, DEFAULT_MICPOD_ID |(i+1));

	for(i=0; i<MICPOD_HUB_MAX_N; i++)
		system_init_device(&system_status.micpod_hubs[i], MICPOD_HUB_DEVICE_TYPE,DEFAULT_MICPOD_HUB_ID |(i+1));

	system_status.table_hub.alive=ALIVE_RESET_COUNT;
	system_status.table_hub.intEnabled[0]=1;
	system_status.table_hub.intEnabled[1]=1;
	system_status.table_hub.intEnabled[2]=1;
	system_status.system_spec.reset_candidates=0;
#ifndef WIN32
	get_version_struct(&system_status.table_hub.dev_info);
#endif
	system_status_set_usb_connected(DEFAULT_STM32_ID, 0);
	system_status_set_usb_connected(DEFAULT_STM32_ID+1, 0);
	system_status_set_volume(DEFAULT_STM32_ID,0);
	system_status_set_volume(DEFAULT_STM32_ID+1,0);

#ifdef TEST_STATUS
	generic_device_t *mic_hub_0=0;
	generic_device_t *mic_hub_1=0;
	generic_device_t *mic_pod_0=0;
	generic_device_t *mic_pod_1=0;
	generic_device_t *mic_pod_2=0;

	int assigned = system_status_assign_device_id(MICPOD_HUB_DEVICE_TYPE, 0x123, TAG_BUS_SPLITTER,&mic_hub_0);
	printf("Bus spliter 0 id assinged %d\n",assigned);

	mic_hub_0->intEnabled[0]=1;
	mic_hub_0->intLocked[0]=1;

	assigned = system_status_assign_device_id(MICPOD_HUB_DEVICE_TYPE, 0x124, TAG_BUS_SPLITTER,&mic_hub_1);
	printf("Bus spliter 1 assinged %d\n",assigned);

	mic_hub_0->intEnabled[1]=1;
	mic_hub_0->intLocked[1]=1;

	assigned = system_status_assign_device_id(MICPOD_DEVICE_TYPE, 0x125, TAG_BUS_SPLITTER,&mic_pod_0);
	printf("Mic pod 0 assinged %d\n",assigned);

	mic_hub_0->intEnabled[2]=1;
	mic_hub_1->intEnabled[0]=1;
	mic_hub_1->intEnabled[1]=1;
	mic_hub_1->intEnabled[2]=1;
	mic_hub_1->intLocked[2]=1;
	assigned = system_status_assign_device_id(MICPOD_DEVICE_TYPE, 0x126, TAG_BUS_SPLITTER,&mic_pod_1);
	printf("Mic pod 1 assinged %d\n",assigned);
	mic_pod_0->intEnabled[0]=1;
	mic_pod_1->intEnabled[0]=1;
	mic_pod_1->intLocked[0]=1;
	assigned = system_status_assign_device_id(MICPOD_DEVICE_TYPE, 0x127, TAG_BUS_SPLITTER,&mic_pod_2);
	printf("Mic pod 2 assinged %d\n",assigned);
#endif

	// Cmd Queue
	pSend_receive_RXqueue = queue;
 #ifndef WIN32
	// SPP
	spp = new I_MCHP(32000,32000);

	spp->OverrideTextOut(system_status_spp_printf);

	// PEQ
	system_status_spp_init_peq();
	system_status_spp_get_status();

#endif
	/*test only!!*/
}

//this function decrements the alive cunter for the connected devices.
//if the counter reaches 0, the device is considered disconnected (dead).
void system_status_alive_dec()
{
#ifndef TEST_STATUS
#ifdef __linux
	mutex_lock(alive_mutex);
#endif
	int i;
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		if(system_status.micpods[i].alive>0)
		{
			system_status.micpods[i].alive--;
			if(system_status.micpods[i].alive==0)
			{
				printf("Micpod 0x%x died\n",system_status.micpods[i].id);
				system_status.micpods[i].parent->intDevice[system_status.micpods[i].parentIntNum]=0;
				system_status.micpods[i].parent->intId[system_status.micpods[i].parentIntNum]=0xFF;
				system_status_print_device_tree();
			}
		}
	}
	for(i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		if(system_status.micpod_hubs[i].alive>0)
		{
			system_status.micpod_hubs[i].alive--;
			if(system_status.micpod_hubs[i].alive==0)
			{
				printf("Micpod hub 0x%x died\n",system_status.micpod_hubs[i].id);
				system_status.micpod_hubs[i].parent->intDevice[system_status.micpod_hubs[i].parentIntNum]=0;
				system_status.micpod_hubs[i].parent->intId[system_status.micpod_hubs[i].parentIntNum]=0xFF;
				system_status_print_device_tree();
			}
		}
	}

	if(system_status.tv_hub.alive>0)
	{
		system_status.tv_hub.alive--;
		if(system_status.tv_hub.alive==0)
		{
			printf("TV hub 0x%x died\n",system_status.tv_hub.id);
			system_status.tv_hub.parent->intDevice[system_status.tv_hub.parentIntNum]=0;
			system_status.tv_hub.parent->intId[system_status.tv_hub.parentIntNum]=0xFF;
			system_status_set_usb_connected(system_status.tv_hub.id, 0);
			system_status_print_device_tree();
		}
	}
#ifdef __linux
	mutex_unlock(alive_mutex);
#endif
#endif
}

//this function returns the alive devices and total number for the specified type
void system_status_get_alive_list(uint8_t dev_type, uint8_t * dev_id_list, int * dev_num)
{
	int i;
	int dev_num_int=0;
	if(dev_type==MICPOD_DEVICE_TYPE)
	{
		for(i=0; i<MICPOD_MAX_N; i++)
		{
			if(system_status.micpods[i].alive>0)
			{
				dev_id_list[dev_num_int]=system_status.micpods[i].id;
				dev_num_int++;
			}
		}
	}
	else if(dev_type==MICPOD_HUB_DEVICE_TYPE)
	{
		for(i=0; i<MICPOD_HUB_MAX_N; i++)
		{
			if(system_status.micpod_hubs[i].alive>0)
			{
				dev_id_list[dev_num_int]=system_status.micpod_hubs[i].id;
				dev_num_int++;
			}
		}
	}

	*dev_num = dev_num_int;
}

//this function returns the device parameters from the specifed id, if alive.
generic_device_t * system_status_get_device_addr_from_id(uint8_t id, system_status_t * status)
{
	int i;
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		if(status->micpods[i].id==id)
		{
			if(status->micpods[i].alive>0)
				return &status->micpods[i];
		}
	}
	for(i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		if(status->micpod_hubs[i].id==id)
		{
			if(status->micpod_hubs[i].alive>0)
				return &status->micpod_hubs[i];
		}
	}
	if(status->table_hub.id==id)
	{
		return &status->table_hub;
	}
	if(status->tv_hub.id==id)
	{
		return &status->tv_hub;
	}
	return 0;
}

//this function checks for all the possible interface connections and rebuild 
//the dependency tree for all the devices
void system_status_rebuild_dependencies(system_status_t * status)
{
	int i,j;
	uint8_t int_Id;
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		for(j=0; j<3; j++)
		{
			int_Id = status->micpods[i].intId[j];
			status->micpods[i].intDevice[j] = system_status_get_device_addr_from_id(int_Id, status);
		}
		int_Id = status->micpods[i].parentId;
		status->micpods[i].parent = system_status_get_device_addr_from_id(int_Id, status);
	}

	for(i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		for(j=0; j<3; j++)
		{
			int_Id = status->micpod_hubs[i].intId[j];
			status->micpod_hubs[i].intDevice[j] = system_status_get_device_addr_from_id(int_Id, status);
		}
		int_Id = status->micpod_hubs[i].parentId;
		status->micpod_hubs[i].parent = system_status_get_device_addr_from_id(int_Id, status);
	}

	for(j=0; j<3; j++)
	{
		int_Id = status->table_hub.intId[j];
		status->table_hub.intDevice[j] = system_status_get_device_addr_from_id(int_Id, status);
	}
	int_Id = status->table_hub.parentId;
	status->table_hub.parent = system_status_get_device_addr_from_id(int_Id, status);

	for(j=0; j<3; j++)
	{
		int_Id = status->tv_hub.intId[j];
		status->tv_hub.intDevice[j] = system_status_get_device_addr_from_id(int_Id, status);
	}
	int_Id = status->tv_hub.parentId;
	status->tv_hub.parent = system_status_get_device_addr_from_id(int_Id, status);
}

//returns the whole system status
void system_status_get_all(system_status_t * status)
{

	memcpy(status, &system_status, sizeof(system_status_t));

	system_status_rebuild_dependencies(status);
}

//this function looks for a new candidate device to be connected
int system_status_get_candidate(uint8_t tag,  uint8_t deviceType, generic_device_t ** device_list, int *intNum)
{
	int number_of_candidate=0;
	int i;
	int j;
	//table hub
	if(tag==TAG_BUS_SPLITTER)
		i=0;
	else if(tag==TAG_BUS_TV)
		i=1;
	else
		i=2;


	if(system_status.table_hub.intDevice[i]==0)
	{
		device_list[number_of_candidate]=&system_status.table_hub;
		intNum[number_of_candidate]=i;
		number_of_candidate++;
	}

	//micpod
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		if(system_status.micpods[i].alive)
			if(system_status.micpods[i].tag==tag)
				if(system_status.micpods[i].intEnabled[0])
					if(system_status.micpods[i].intLocked[0])
						if(system_status.micpods[i].intDevice[0]==0)
						{
							device_list[number_of_candidate]=&system_status.micpods[i];
							intNum[number_of_candidate]=0;
							number_of_candidate++;
						}
	}

	//micpod hub
	for(i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		if(system_status.micpod_hubs[i].alive)
			if(system_status.micpod_hubs[i].tag==tag)
			{
				for(j=0; j<3; j++)
				if(system_status.micpod_hubs[i].intEnabled[j])
					if(system_status.micpod_hubs[i].intLocked[j])
						if(system_status.micpod_hubs[i].intDevice[j]==0)
						{
							device_list[number_of_candidate]=&system_status.micpod_hubs[i];
							intNum[number_of_candidate]=j;
							number_of_candidate++;
						}
			}
	}

	//tv hub
	if(system_status.tv_hub.alive)
	{
		if(system_status.tv_hub.tag==tag)
		{
			for(j=0; j<2; j++)
			if(system_status.tv_hub.intEnabled[j])
				if(system_status.tv_hub.intLocked[j])
					if(system_status.tv_hub.intDevice[j]==0)
					{
						device_list[number_of_candidate]=&system_status.tv_hub;
						intNum[number_of_candidate]=j;
						number_of_candidate++;
					}
		}
	}
	return number_of_candidate;
}

void system_status_print_device(generic_device_t * device)
{
	if(device->type==TABLE_HUB_DEVICE_TYPE)
		printf("Table HUB %d, unique_id: 0x%llx\n",device->id, device->dev_info.fpga_unique_id);
	else if(device->type==MICPOD_DEVICE_TYPE)
		printf("Micpod %d, unique_id: 0x%llx\n",device->id, device->dev_info.fpga_unique_id);
	else if(device->type==MICPOD_HUB_DEVICE_TYPE)
		printf("Micpod HUB %d, unique_id: 0x%llx\n",device->id, device->dev_info.fpga_unique_id);
	else if(device->type==TV_HUB_DEVICE_TYPE)
		printf("TV HUB %d, unique_id: 0x%llx\n",device->id, device->dev_info.fpga_unique_id);
}

void system_status_print_child(generic_device_t * device, int tabNum)
{
	int i=0;
	int j=0;

	system_status_print_device(device);

	for(i=0; i<device->int_num; i++)
	{
		if(device->intDevice[i]!=0)
		{
			for(j=0; j<tabNum; j++)
				printf("\t");
			printf("Interface %d\n", i);
			for(j=0; j<tabNum+1; j++)
				printf("\t");
			system_status_print_child(device->intDevice[i],tabNum+1);
		}
	}
}


void system_status_print_device_tree()
{
	printf("##########################\n");
	printf("Device tree\n");
	system_status_print_child(&system_status.table_hub,0);
	printf("End\n");
	printf("##########################\n");
}

uint8_t system_status_assign_device_id(uint8_t device_type, uint64_t unique_id, uint8_t tag, generic_device_t ** device_assigned)
{
	int i;
	generic_device_t * device_list[MICPOD_MAX_N+MICPOD_HUB_MAX_N+2];
	int intNum[MICPOD_MAX_N+MICPOD_HUB_MAX_N+2];
	switch(device_type)
	{
		case MICPOD_DEVICE_TYPE:
		{
			//find if there is a candidate to be connected
			int candNum = system_status_get_candidate(tag,  device_type, device_list, intNum);
			int index =-1;
			if(candNum==0)
			{
				system_status.system_spec.reset_candidates=1;
				printf("Error: no candidate available for new id request\n");
				return -1;
			}
			if(candNum>1)
			{
				system_status.system_spec.reset_candidates=1;
				printf("Error: too much candidate available for new id request\n");
				return -1;
			}
			//Assign id
			
			for(i=0; i<MICPOD_MAX_N; i++)
			{
				if(system_status.micpods[i].alive==0)
				{
					index= i;
					break;
				}
			}
			if(index==-1)
			{
				printf("Error: max num of micpod connected\n");
				//TODO:
				//send info to gui
				return 0;
			}
			system_init_device(&system_status.micpods[index], MICPOD_DEVICE_TYPE, system_status.micpods[index].id);
			system_status.micpods[index].alive=ALIVE_RESET_COUNT;
			system_status.micpods[index].dev_info.fpga_unique_id=unique_id;

			//TODO:
			//send id to device
			device_list[0]->intDevice[intNum[0]]=&system_status.micpods[index];
			device_list[0]->intId[intNum[0]]=system_status.micpods[index].id;
			system_status.micpods[index].parent = device_list[0];
			system_status.micpods[index].parentId = device_list[0]->id;

			system_status.micpods[index].parentIntNum = intNum[0];
			system_status.micpods[index].tag = tag;

			//TODO:
			//assign audio table

			//TODO:
			//enable interface -> spostare fuori quando faccio gli alive

			system_status_print_device_tree();
			device_assigned[0] = &system_status.micpods[index];
			return system_status.micpods[index].id;

		}
		case MICPOD_HUB_DEVICE_TYPE:
		{
			//find if there is a candidate to be connected
			int candNum = system_status_get_candidate(tag,  device_type, device_list, intNum);
			int index=-1;
			if(candNum==0)
			{
				system_status.system_spec.reset_candidates=1;
				printf("Error: no candidate available for new id request\n");
				return -1;
			}
			if(candNum>1)
			{
				system_status.system_spec.reset_candidates=1;
				printf("Error: too much candidate available for new id request\n");
				return -1;
			}
			//Assign id
			
			for(i=0; i<MICPOD_HUB_MAX_N; i++)
			{
				if(system_status.micpod_hubs[i].alive==0)
				{
					index= i;
					break;
				}
			}
			if(index==-1)
			{
				printf("Error: max num of micpod hub connected\n");
				//TODO:
				//send info to gui
				return 0;
			}
			system_init_device(&system_status.micpod_hubs[index], MICPOD_HUB_DEVICE_TYPE, system_status.micpod_hubs[index].id);
			system_status.micpod_hubs[index].alive=ALIVE_RESET_COUNT;
			system_status.micpod_hubs[index].dev_info.fpga_unique_id=unique_id;

			//TODO:
			//send id to device

			device_list[0]->intDevice[intNum[0]]=&system_status.micpod_hubs[index];
			device_list[0]->intId[intNum[0]]=system_status.micpod_hubs[index].id;
			system_status.micpod_hubs[index].parent = device_list[0];
			system_status.micpod_hubs[index].parentIntNum = intNum[0];
			system_status.micpod_hubs[index].tag = tag;

			//TODO:
			//enable interface -> spostare fuori quando faccio gli alive

			system_status_print_device_tree();

			device_assigned[0] = &system_status.micpod_hubs[index];
			return system_status.micpod_hubs[index].id;

		}
		case TV_HUB_DEVICE_TYPE:
		{
			//find if there is a candidate to be connected
			int candNum = system_status_get_candidate(tag,  device_type, device_list, intNum);
			if(candNum==0)
			{
				system_status.system_spec.reset_candidates=1;
				printf("Error: no candidate available for new id request\n");
				return -1;
			}
			if(candNum>1)
			{
				system_status.system_spec.reset_candidates=1;
				printf("Error: too much candidate available for new id request\n");
				return -1;
			}

			system_init_device(&system_status.tv_hub, TV_HUB_DEVICE_TYPE, system_status.tv_hub.id);
			system_status.tv_hub.alive=ALIVE_RESET_COUNT;
			system_status.tv_hub.dev_info.fpga_unique_id=unique_id;

			//TODO:
			//send id to device

			device_list[0]->intDevice[intNum[0]]=&system_status.tv_hub;
			device_list[0]->intId[intNum[0]]=system_status.tv_hub.id;
			system_status.tv_hub.parent = device_list[0];
			system_status.tv_hub.parentIntNum = intNum[0];
			system_status.tv_hub.tag = tag;

			//TODO:
			//enable interface -> spostare fuori quando faccio gli alive

			system_status_print_device_tree();
			system_status_set_usb_connected(system_status.tv_hub.id, 1);
			device_assigned[0] = &system_status.tv_hub;
			return system_status.tv_hub.id;

		}
	}

	//print device tree

	return 0;
}

void system_status_print_device_audio_table(generic_device_t * device)
{
	int i;

	if(device->type==TABLE_HUB_DEVICE_TYPE)
		printf("\nTable hub %d\n",device->id);
	else if(device->type==MICPOD_DEVICE_TYPE)
		printf("\nMicpod %d\n",device->id);
	else if(device->type==MICPOD_HUB_DEVICE_TYPE)
		printf("\nMicpod hub %d\n",device->id);
	else if(device->type==TV_HUB_DEVICE_TYPE)
		printf("\nTV hub %d\n",device->id);

	for(i=0; i<ROUTING_TABLE_LEN_BYTES; i++)
	{
		if(device->audio_tag[i]!=AUDIO_TAG_INVALID)
		{
			printf("\tCH %d: ",i);
			switch (device->audio_tag[i])
			{
				case(AUDIO_TAG_SOUT):
					printf("SOUT");
					break;
				case(AUDIO_TAG_SIN0):
					printf("MIC0");
					break;
				case(AUDIO_TAG_SIN1):
					printf("MIC1");
					break;
				case(AUDIO_TAG_SIN2):
					printf("MIC2");
					break;
				case(AUDIO_TAG_SIN3):
					printf("MIC3");
					break;
				case(AUDIO_TAG_ROUT):
					printf("SPK");
					break;
				case(AUDIO_TAG_SPK_L):
					printf("SPK_IN_L");
					break;
				case(AUDIO_TAG_SPK_R):
					printf("SPK_IN_R");
					break;
				default:
					printf("Unknown");
			}
			printf(" %d ",device->audio_id[i]);
			printf(": [%d]\n",device->audio_table[i]);
		}
	}

}
void system_status_update_audio_child(generic_device_t * device)
{
	int i=0;
	int j=0;
	int adder_int=0;
	int chCount=0;
	for(j=0; j<device->micCh; j++)
	{
		device->audio_table[chCount]=j;
		device->audio_id[chCount]=device->id;
		device->audio_tag[chCount]=j;
		chCount++;
	}

	if(device->micCh>0)
		adder_int=1;

	for(i=0; i<device->int_num; i++)
	{
		if(device->intDevice[i]!=0)
		{

			system_status_update_audio_child(device->intDevice[i]);
			for(j=0; j<ROUTING_TABLE_LEN_BYTES; j++)
			{
				if(device->intDevice[i]->audio_tag[j]!=AUDIO_TAG_INVALID)
				{
					device->audio_table[chCount]=j+(i+adder_int)*ROUTING_TABLE_LEN_BYTES;
					device->audio_tag[chCount]=device->intDevice[i]->audio_tag[j];
					device->audio_id[chCount]=device->intDevice[i]->audio_id[j];
					chCount++;
				}
			}
		}

	}
	if(chCount>ROUTING_TABLE_LEN_BYTES)
	{
		printf("\n\n\nError: channel count exceded maximum capacity\n\n\n");
	}

	//Muting unconnected channels
	while(chCount<ROUTING_TABLE_LEN_BYTES)
	{
		device->audio_tag[chCount]=AUDIO_TAG_INVALID;
		device->audio_id[chCount]=DEFAULT_UNINIT_ID;
		device->audio_table[chCount]=AUDIO_INVALID_ROUTING;

		chCount++;
	}

	//Speaker for table hub
	if(device->type==TABLE_HUB_DEVICE_TYPE)
	{
		if(device->table_hub_specific.usb_source==1)
		{
			device->audio_tag[13]=AUDIO_TAG_SPK_L;
			device->audio_id[13]=device->id;
			device->audio_table[13]=AUDIO_TABLE_HUB_SPK_L;
			device->audio_tag[14]=AUDIO_TAG_SPK_R;
			device->audio_id[14]=device->id;
			device->audio_table[14]=AUDIO_TABLE_HUB_SPK_R;
		}
		else if(device->table_hub_specific.usb_source==2)
		{
			device->audio_tag[13]=AUDIO_TAG_SPK_L;
			device->audio_id[13]=device->intDevice[1]->id;
			device->audio_table[13]=AUDIO_TV_HUB_SPK_L;
			device->audio_tag[14]=AUDIO_TAG_SPK_R;
			device->audio_id[14]=device->intDevice[1]->id;
			device->audio_table[14]=AUDIO_TV_HUB_SPK_R;
		}
		else
		{
			device->audio_tag[13]=AUDIO_TAG_INVALID;
			device->audio_id[13]=DEFAULT_UNINIT_ID;
			device->audio_table[13]=AUDIO_INVALID_ROUTING;
			device->audio_tag[14]=AUDIO_TAG_SPK_R;
			device->audio_id[14]=DEFAULT_UNINIT_ID;
			device->audio_table[14]=AUDIO_INVALID_ROUTING;
		}

	}
	system_status_print_device_audio_table(device);
}

//this function checks what's the current USB spk setup and apply the current configuration to the sys status
void system_status_update_audio_spk()
{
	if(system_status.table_hub.table_hub_specific.usb_source==USB_SRC_TABLE_HUB)
	{
		if(!system_status.table_hub.table_hub_specific.usb_connected)
		{
			if(system_status.tv_hub.tv_hub_specific.usb_connected)
				system_status.table_hub.table_hub_specific.usb_source=USB_SRC_TV_HUB;
			else
				system_status.table_hub.table_hub_specific.usb_source=0;

		}
	}
	else if(system_status.table_hub.table_hub_specific.usb_source==USB_SRC_TV_HUB)
	{
		if(!system_status.tv_hub.tv_hub_specific.usb_connected)
		{
			if(system_status.table_hub.table_hub_specific.usb_connected)
				system_status.table_hub.table_hub_specific.usb_source=USB_SRC_TABLE_HUB;
			else
				system_status.table_hub.table_hub_specific.usb_source=0;

		}
	}
	else if((system_status.table_hub.table_hub_specific.usb_source!=USB_SRC_DEBUG)&(system_status.table_hub.table_hub_specific.usb_source!=USB_SRC_SINEWAVE))
	{
		if(system_status.table_hub.table_hub_specific.usb_connected)
		{
			system_status.table_hub.table_hub_specific.usb_source=1;
		}
		else if(system_status.tv_hub.tv_hub_specific.usb_connected)
		{
			system_status.table_hub.table_hub_specific.usb_source=2;
		}
	}

}
void system_status_update_audio_tables()
{
	printf("\nUpdate audio table start\n");
	system_status_update_audio_spk();
	system_status_update_audio_child(&system_status.table_hub);

	printf("Update audio table end\n\n");
}

int system_status_get_rebuild_audio()
{
	return system_status.system_spec.rebuild_audio;
}

void system_status_set_rebuild_audio(int val)
{
	system_status.system_spec.rebuild_audio=val;
}

//this function creates a fresh poll list to track the connected devices
void system_status_create_poll_new_list(uint8_t **listDev, uint8_t **listInt, int *listLen)
{
	int i;
	int j;
	for(i=0; i<3; i++)
		listLen[i]=0;
	if(system_status.tv_hub.alive)
	{
		int listPort = 2;
		if(system_status.tv_hub.tag==TAG_BUS_SPLITTER)
			listPort = 0;
		else if(system_status.tv_hub.tag==TAG_BUS_TV)
			listPort = 1;

		for(i=0; i<2; i++)
			if(system_status.tv_hub.intDevice[i]==0)
			{
				listDev[listPort][listLen[listPort]]=system_status.tv_hub.id;
				listInt[listPort][listLen[listPort]]=i;
				listLen[listPort]++;
			}
	}

	for(j=0; j<MICPOD_HUB_MAX_N; j++)
	{
		if(system_status.micpod_hubs[j].alive)
		{
			int listPort = 2;
			if(system_status.micpod_hubs[j].tag==TAG_BUS_SPLITTER)
				listPort = 0;
			else if(system_status.micpod_hubs[j].tag==TAG_BUS_TV)
				listPort = 1;

			for(i=0; i<3; i++)
				if(system_status.micpod_hubs[j].intDevice[i]==0)
				{
					listDev[listPort][listLen[listPort]]=system_status.micpod_hubs[j].id;
					listInt[listPort][listLen[listPort]]=i;
					listLen[listPort]++;
				}
		}
	}

	for(j=0; j<MICPOD_MAX_N; j++)
	{
		if(system_status.micpods[j].alive)
		{
			int listPort = 2;
			if(system_status.micpods[j].tag==TAG_BUS_SPLITTER)
				listPort = 0;
			else if(system_status.micpods[j].tag==TAG_BUS_TV)
				listPort = 1;


			if(system_status.micpods[j].intDevice[0]==0)
			{
				listDev[listPort][listLen[listPort]]=system_status.micpods[j].id;
				listInt[listPort][listLen[listPort]]=0;
				listLen[listPort]++;
			}
		}
	}
}

//this function returns the difference in connected/disconnected devices in comparing old&new system statuses
int system_status_get_alive_death_diff(system_status_t * oldSystem, system_status_t * newSystem)
{
	int i;
	//check for alive that became dead
	for(i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		if(oldSystem->micpod_hubs[i].alive>0)
			if(newSystem->micpod_hubs[i].alive==0)
				return 1;
		if(oldSystem->micpod_hubs[i].alive==0)
			if(newSystem->micpod_hubs[i].alive>0)
				return 1;
	}
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		if(oldSystem->micpods[i].alive>0)
			if(newSystem->micpods[i].alive==0)
				return 1;
		if(oldSystem->micpods[i].alive==0)
			if(newSystem->micpods[i].alive>0)
				return 1;
	}
	if(oldSystem->tv_hub.alive>0)
		if(newSystem->tv_hub.alive==0)
			return 1;
	if(oldSystem->tv_hub.alive==0)
		if(newSystem->tv_hub.alive>0)
			return 1;

	return 0;
}

void system_status_set_micpod_led(uint8_t micId, uint8_t status)
{

	int index = system_status_get_micpod_index_from_id(micId);
	if(index<0)
	{
		printf("System status set micpod led: id %d is not alive\n", micId);
		return;
	}
	system_status.micpods[index].micpod_specific.ledOn=status;
}

uint8_t system_status_get_micpod_led(uint8_t micId)
{
	int index = system_status_get_micpod_index_from_id(micId);
	if(index<0)
	{
		printf("System status get micpod led: id %d is not alive\n", micId);
		return 0xFF;
	}
	return  system_status.micpods[index].micpod_specific.ledOn;
}


void system_status_set_micpod_mute(uint8_t micId, uint8_t status)
{
	int index = system_status_get_micpod_index_from_id(micId);
	if(index<0)
	{

		printf("System status set micpod mute: id %d is not alive\n", micId);
		return;
	}
	system_status.micpods[index].micpod_specific.mute=status;
}


uint8_t system_status_get_micpod_mute(uint8_t micId)
{
	int index = system_status_get_micpod_index_from_id(micId);
	if(index<0)
	{
		printf("System status get micpod mute: id %d is not alive\n", micId);
		return 0xFF;
	}
	return  system_status.micpods[index].micpod_specific.mute;
}

void system_status_set_sys_mute(uint8_t mute)
{
	system_status.table_hub.table_hub_specific.mute = mute;
}

uint8_t system_status_get_sys_mute()
{
	return system_status.table_hub.table_hub_specific.mute;
}

void system_status_set_debug_micpod(uint8_t en, uint8_t micId)
{
	int i;
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		system_status.micpods[i].debug_mode=0;
		system_status.micpods[i].micCh=1;
	}
	if(micId!=DEFAULT_UNINIT_ID)
	{
		if(en)
		{
			generic_device_t *dev= system_status_get_device_from_id(micId);
			dev->debug_mode=1;
			dev->micCh=6;
		}
	}
	system_status.system_spec.rebuild_audio=1;
}

void system_status_set_listen_micpod(uint8_t micId)
{

	printf("Listen id changed to %d\n",micId);
	system_status.table_hub.table_hub_specific.listenId=micId;
}

uint8_t system_status_get_listen_micpod()
{
	return system_status.table_hub.table_hub_specific.listenId;
}

int system_status_get_listen_ch()
{
	return system_status.table_hub.table_hub_specific.listenId;
}
void system_status_set_postfilter_micpod(uint8_t en, uint8_t micId)
{
	int index = system_status_get_micpod_index_from_id(micId);
	if(index<0)
	{
		printf("System status set micpod post filter: id %d is not alive\n", micId);
		return;
	}
	system_status.micpods[index].micpod_specific.postFilter=en;
}

uint8_t system_status_get_micpod_postfilter(uint8_t micId)
{
	int index = system_status_get_micpod_index_from_id(micId);
	if(index<0)
	{
		printf("System status get micpod post filter: id %d is not alive\n", micId);
		return 0xFF;
	}
	return  system_status.micpods[index].micpod_specific.postFilter;
}


void system_status_set_alive(uint8_t id)
{
	generic_device_t * dev = system_status_get_device_from_id(id);
	if(dev==0)
	{
		printf("Received alive from not existent id\n");
		return;
	}
#ifdef __linux
	mutex_lock(alive_mutex);
#endif
	if(dev->alive==0)
	{
		//TODO: handle some device which was dead and now it's alive again
		printf("Warning: device was dead and now is alive again\n");

	}
	dev->alive=ALIVE_RESET_COUNT;
#ifdef __linux
	mutex_unlock(alive_mutex);
#endif
}


void system_status_set_cpu_load(uint8_t cpu, uint8_t micId)
{
	generic_device_t * dev = system_status_get_device_from_id(micId);
	if(dev==0)
	{
		printf("Received alive from not existent id\n");
		return;
	}
#ifdef __linux
	mutex_lock(alive_mutex);
#endif
	if(dev->alive==0)
	{
		//TODO: gestire se uno torna alive dopo che era morto
		printf("Warning: device was dead and now is alive again\n");

	}
	dev->alive=ALIVE_RESET_COUNT;
#ifdef __linux
	mutex_unlock(alive_mutex);
#endif
	dev->micpod_specific.cpuLoad=cpu;
}

int system_status_set_slave_interface(uint8_t id, uint8_t intNum, uint8_t en)
{
	generic_device_t * dev = system_status_get_device_from_id(id);
	if(dev==0)
		return -1;
	if(intNum>=dev->int_num)

		return -2;
	dev->intEnabled[intNum]=en;
	return 0;
}

int system_status_info_interface_lock(uint8_t id, uint8_t intNum, uint8_t locked)
{
	generic_device_t * dev = system_status_get_device_from_id(id);
	if(dev==0)
		return -1;
	if(intNum>=dev->int_num)

		return -2;
	dev->intLocked[intNum]=locked;
	return 0;
}
void system_status_print_dev_info(generic_device_t * dev)
{
	if(dev->type==MICPOD_DEVICE_TYPE)
	{
		printf("Micpod %d\n",dev->id);
	}
	else if(dev->type==MICPOD_HUB_DEVICE_TYPE)
	{
		printf("Micpod hub %d\n",dev->id);
	}
	printf("SW version %d\n", dev->dev_info.sw_version);
	printf("FPGA version %d\n", dev->dev_info.fpga_version);
	printf("FPGA unique id %llx\n", dev->dev_info.fpga_unique_id);
}
int system_status_ret_dev_info(uint8_t id, dev_info_t * info)
{
	generic_device_t * dev = system_status_get_device_from_id(id);
	if(dev==0)
		return -1;
	memcpy(&dev->dev_info, info, sizeof(dev_info_t));

	system_status_print_dev_info(dev);
	return 0;
}

void system_status_ret_stm_ver(uint32_t ver)
{
	system_status.table_hub.dev_info.stm_version = ver;
}
int system_status_get_channel_from_id(uint8_t id)
{
	int i;
	if(id==0)
	{
		return -1;
	}
	for(i=0; i<ROUTING_TABLE_LEN_BYTES; i++)
	{
		if(system_status.table_hub.audio_id[i]==id)
		{
			if(system_status.table_hub.audio_tag[i]==AUDIO_TAG_SOUT)
			{
				return i;
			}
		}
	}
	return -1;
}


int system_status_set_debug_file(uint8_t en, char * file_name)
{
	if(en)
	{
		printf("Debug file enabled\n");
		if(system_status.table_hub.table_hub_specific.debug_enabled)
		{
			printf("Error: debug file already enabled\n");
			return -1;
		}
		strcpy(system_status.table_hub.table_hub_specific.debug_file,file_name);
		system_status.table_hub.table_hub_specific.debug_enabled = 1;
	}
	else
	{
		printf("Debug file disabled\n");
		if(!system_status.table_hub.table_hub_specific.debug_enabled)
		{
			printf("Error: debug file already disabled\n");
			return -1;
		}
		system_status.table_hub.table_hub_specific.debug_enabled = 0;
	}
	return 0;
}


uint8_t system_status_get_debug_en()
{
	return system_status.table_hub.table_hub_specific.debug_enabled;
}
void system_status_get_debug_file_name(char * file_name)
{
	strcpy(file_name, system_status.table_hub.table_hub_specific.debug_file);
}


void system_status_set_usb_src(uint8_t usb_src)
{
	system_status.table_hub.table_hub_specific.usb_source=usb_src;
}

uint8_t system_status_get_usb_src(void)
{
	return system_status.table_hub.table_hub_specific.usb_source;
}


void system_status_set_usb_connected(uint8_t id, uint8_t status)
{
	if(id==DEFAULT_STM32_ID)
	{
		system_status.table_hub.table_hub_specific.usb_connected=status;
	}
	else if(id==DEFAULT_STM32_ID+1)
	{
		system_status.tv_hub.tv_hub_specific.usb_connected=status;
	}
	else
	{
		printf("Error system_status_set_usb_connected: unknown id %x\n",id);
	}

	system_status_set_rebuild_audio(1);
}

int system_status_get_usb_connected(uint8_t id)
{
	if(id==DEFAULT_STM32_ID)
	{
		return system_status.table_hub.table_hub_specific.usb_connected;
	}
	else if(id==system_status.tv_hub.id)
	{
		return system_status.tv_hub.tv_hub_specific.usb_connected;
	}
	printf("Error system_status_get_usb_connected: unknown id %d\n",id);
	return -1;
}

int system_status_get_channel_to_play()
{
	return system_status.table_hub.table_hub_specific.ch_to_listen;
}

void system_status_set_channel_to_play(int ch)
{
	system_status.table_hub.table_hub_specific.ch_to_listen = ch;
}

int system_status_get_play_wave()
{
	if(system_status.table_hub.table_hub_specific.usb_source==USB_SRC_SINEWAVE)
		return 1;
	return 0;
}

int system_status_set_volume(uint8_t id, uint8_t vol)
{
#ifdef __linux
	if(id==DEFAULT_STM32_ID)
	{
		printf("Volume from STM32 Table %d\n",vol);
		system_status.table_hub.table_hub_specific.volume = vol;
		if(system_status.table_hub.table_hub_specific.usb_source==USB_SRC_TABLE_HUB)
		{
			float volF = ((float)vol)/100.0f;
			set_gain(volF);
			return vol;
		}
	}
	else if(id==DEFAULT_STM32_ID+1)
	{

		printf("Volume from STM32 Tv %d\n",vol);
		system_status.tv_hub.tv_hub_specific.volume= vol;
		if(system_status.table_hub.table_hub_specific.usb_source==USB_SRC_TV_HUB)
		{
			float volF = ((float)vol)/100.0f;
			set_gain(volF);
			return vol;
		}
	}
	

#endif
	return -1;
}
#ifndef WIN32

/********************************
 * SPP
 ********************************/

// Process SPK
void system_status_spp_process(float *pSrc, float *pDst)
{
	spp->ProcessSpkFrame(pSrc, pDst);
}

// Set CMD
int system_status_spp_set_cmd_string(char* CommandString)
{
	return (int)spp->ParseCommand (CommandString);
}

// Printf SPP
int system_status_spp_printf(const char *commandString)
{
	tdm_command_t TXcmd;

	cmd_gen_debug_msg(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, (char*)commandString, &TXcmd);

	command_queue_putCmd(pSend_receive_RXqueue, &TXcmd, TAG_PROGRAM);

	return 0;
}

void system_status_spp_init_peq()
{
	// Initialization aligned to GUI
	// NumStages-1 -> Peak Band Filters
	for(int i=0; i<SPP_PEQ_NUM_BANDS-1; i++)
	{
		system_status.table_hub.table_hub_specific.spp_status.peq_types[i] = PEQ_PB;
		system_status.table_hub.table_hub_specific.spp_status.peq_frequencies[i] = 100.0f*(i+1);
		system_status.table_hub.table_hub_specific.spp_status.peq_gains[i] = 0.0f;	
		system_status.table_hub.table_hub_specific.spp_status.peq_Qs[i] = 4.36f;
	}
	// Last PEQ Stage -> High Shelving Filter
	system_status.table_hub.table_hub_specific.spp_status.peq_types[SPP_PEQ_NUM_BANDS-1] = PEQ_HS;
	system_status.table_hub.table_hub_specific.spp_status.peq_frequencies[SPP_PEQ_NUM_BANDS-1] = 3400.0f;
	system_status.table_hub.table_hub_specific.spp_status.peq_gains[SPP_PEQ_NUM_BANDS-1] = 0.0f;
	system_status.table_hub.table_hub_specific.spp_status.peq_Qs[SPP_PEQ_NUM_BANDS-1] = 1.0f;

	// Set Initial Settings
	for(int i=0; i<SPP_PEQ_NUM_BANDS; i++)
	{
		spp->PEQ_SetStage(i,
			system_status.table_hub.table_hub_specific.spp_status.peq_types[i],
			system_status.table_hub.table_hub_specific.spp_status.peq_frequencies[i],
	        system_status.table_hub.table_hub_specific.spp_status.peq_Qs[i],
	        system_status.table_hub.table_hub_specific.spp_status.peq_gains[i]
	    );
	}
}

void system_status_spp_get_status()
{
	// PEQ
	system_status.table_hub.table_hub_specific.spp_status.peq_enable = spp->GetEnable(RX_PEQ_ENABLE);

	for(int i=0; i<SPP_PEQ_NUM_BANDS; i++)
	{
		spp->PEQ_GetStage(i,
			system_status.table_hub.table_hub_specific.spp_status.peq_types[i],
			system_status.table_hub.table_hub_specific.spp_status.peq_frequencies[i],
	        system_status.table_hub.table_hub_specific.spp_status.peq_Qs[i],
	        system_status.table_hub.table_hub_specific.spp_status.peq_gains[i]
	    );
	}

    // High Pass Mode
	system_status.table_hub.table_hub_specific.spp_status.high_pass_mode = spp->GetHighPassMode();

    // Limiter 
    system_status.table_hub.table_hub_specific.spp_status.lim_enable = spp->GetEnable(RX_LIMITER_ENABLE);
    system_status.table_hub.table_hub_specific.spp_status.lim_threshold = spp->GetLimiterRef_dB();
}

#endif