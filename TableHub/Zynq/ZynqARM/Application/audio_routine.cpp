#include "audio_routine.h"

#include "utility.h"
#include "circular_buffer.h"
#include "status.h"

//#define PLAY_FILE_TEST
#define SAVE_AUDIO_FILE


#define PLAY_FOLDER_PATH "/media/rootfs/"
#define PLAY_FILE_NAME "sine_5000Hz_32000Hz_1ch.wav"
bdWavFile * playFile=NULL;


bdWavFile * recFile=NULL;
int debug_en = 0;


int audio_end=0;
pthread_t * cap_thread_inst;
pthread_t * play_thread_inst;
bd_circBuf_t circ_buf;

void * cap_thread(void * data)
{
	printf("cap_thread begin\n");
	int cap_buf[AUDIO_TO_PS_SAMPLE_PER_BUF_MAX];
	int play_buf[AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX];

	int cap_int[AUDIO_TO_PS_SAMPLE_PER_BUF_MAX];

//	int index =0;
	while(!audio_end)
	{
		int listen[7];
		int listenNum=0;
		//Automatic Listen selection
		if(!system_status_get_sys_mute())
		{
			if(system_status_get_listen_micpod()==0)
			{
				for(int i=0; i<MICPOD_MAX_N; i++)
				{
					listen[listenNum]=14;
					listenNum =1;
					//listen[listenNum] = system_status_get_channel_from_id(DEFAULT_MICPOD_ID+1+i);
					//if(listen[listenNum]!=-1)
					//	listenNum++;
				}
			}
			else
			{
				listen[0] = system_status_get_channel_from_id(system_status_get_listen_micpod());
				if(listen[0]!=-1)
					listenNum =1;

			}
		}
//		index++;
//		if(index%125==0)
//		{
//			printf("Channel out\n");
//			for(int i=0; i<listenNum; i++)
//				printf("%d ",listen[i]);
//			printf("\n");
//		}
		int play0 = system_status_get_channel_to_play();

		//get captured audio samples from peripheral
		audio_driver_read(cap_buf);
    	int avail = circBuf_availableSpace(&circ_buf);

    	if(avail>=AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX)
    	{
    		//There's room enough in the play buffer, so copy stereo captured buffer and listen micpod samples

    		float auxSPKin[AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX];
    		float auxSPKout[AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX];
 			for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX;i++)
 			{
				auxSPKin[i]=((float)cap_buf[AUDIO_TO_PS_CH_NUM*i+play0])/256.0f;
 			}
 			//Uncomment to enable speaker process
   			system_status_spp_process(auxSPKin, auxSPKout);
   			//Comment when speaker process is enabled
  			for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX;i++)
 			{
				if(auxSPKout[i]>32766.0)
					auxSPKout[i]=32766.0;
				else if(auxSPKout[i]<-32766.0)
					auxSPKout[i]=-32766.0;
 			}

    		for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX; i++)
    		{
    			//Send to USB SPK
    			play_buf[AUDIO_FROM_PS_CH_NUM*i+0]=(int)(auxSPKout[i]*256.0f);//cap_buf[AUDIO_TO_PS_CH_NUM*i+play0];
    			play_buf[AUDIO_FROM_PS_CH_NUM*i+1]=(int)(auxSPKout[i]*256.0f);//cap_buf[AUDIO_TO_PS_CH_NUM*i+play0+1];

    			int auxSig=0;
    			for(int j = 0; j<listenNum; j++)
    			{
    				auxSig+=cap_buf[AUDIO_TO_PS_CH_NUM*i+listen[j]];
    			}
    			//Send to USB MIC
				play_buf[AUDIO_FROM_PS_CH_NUM*i+2]=auxSig;
				play_buf[AUDIO_FROM_PS_CH_NUM*i+3]=auxSig;
				


    		}
       		//Push the local buffer into the circular buffer
	   		circBufPushI(&circ_buf,play_buf,AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX);
    	}
    	uint8_t new_debug = system_status_get_debug_en();
    	if(new_debug!=debug_en)
    	{
    		printf("Debug changed\n");
    		if(new_debug)
    		{
    			//Setup and open file for debug recording on file system
    			char file_name[DEBUG_FILE_MAX_LEN];
    			system_status_get_debug_file_name(file_name);
				bdWavFile_settings record_file_settings;
				record_file_settings.frameSizeMax = AUDIO_TO_PS_FRAME_PER_BUF_MAX;

				record_file_settings.folderPath = "";
				record_file_settings.fileName = file_name;
				recFile = new bdWavFile();
				if(recFile!=NULL)
				{
					recFile->setBytePerSample(4);
					recFile->openFile(&record_file_settings,BD_WAV_FILE_TYPE_WRITE);
					recFile->setSampleRate(32000);
					recFile->setNumberChannels(16);
				}
				else
				{
					printf("Error: cannot open debug file\n");
					system_status_set_debug_file(0,file_name);
				}
    		}
    		else
    		{
    			recFile->closeFile();
    			delete(recFile);
    		}
    		debug_en=new_debug;
    	}
    	if(debug_en)
    	{
    		//Writing debug file, adapting 32bit to 24bit
			for(int i=0; i<AUDIO_TO_PS_SAMPLE_PER_BUF_MAX; i++)
			{
				cap_int[i]=cap_buf[i]<<8;
			}
			recFile->writeData(cap_int,AUDIO_TO_PS_FRAME_PER_BUF_MAX);
    	}
	}

	printf("cap_thread end\n");
	return 0;
}

void * play_thread(void * data)
{
	printf("play_thread begin\n");
	int play_buf[AUDIO_TO_PS_SAMPLE_PER_BUF_MAX];

	int index=0;
	short play_short[AUDIO_TO_PS_SAMPLE_PER_BUF_MAX];
	while(!audio_end)
	{
		int avail = circBuf_availableSamples(&circ_buf);

		//Checking if there's enough samples into the circular buffer to be played.
		if(avail>=AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX)
			circBufPopI(&circ_buf,play_buf,AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX);
		else
			memset(play_buf,0,sizeof(int32_t)*AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX);

		if(system_status_get_play_wave())
		{
//			printf("Passo di qua\n");
			if(playFile->readData(play_short,AUDIO_FROM_PS_FRAME_PER_BUF_MAX)!=0)
			{
				playFile->closeFile();
				bdWavFile_settings play_file_settings;
				play_file_settings.frameSizeMax = AUDIO_FROM_PS_FRAME_PER_BUF_MAX;
				play_file_settings.folderPath = PLAY_FOLDER_PATH;
				play_file_settings.fileName = PLAY_FILE_NAME;
				playFile = new bdWavFile();
				if(playFile!=NULL)
				{
					playFile->openFile(&play_file_settings,BD_WAV_FILE_TYPE_READ);
				}
				else
				{
					printf("Cannot open play file test\n");
				}

			}
			for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX; i++)
			{
				play_buf[AUDIO_FROM_PS_CH_NUM*i+0]=play_short[i]<<8;
				play_buf[AUDIO_FROM_PS_CH_NUM*i+1]=play_short[i]<<8;
			}

		}
		for(int i=0; i<AUDIO_FROM_PS_FRAME_PER_BUF_MAX; i++)
		{
			int randNoise = -(rand()%2);
			play_buf[AUDIO_FROM_PS_CH_NUM*i+0]+=randNoise;
			play_buf[AUDIO_FROM_PS_CH_NUM*i+1]+=randNoise;
		}
		audio_driver_write(play_buf);
	}
	printf("play_thread end\n");
	return 0;
}

int audio_routine_init()
{

	audio_end=0;

	//Init audio peripheral. Audio engine not yet started.

	audio_driver_init();
	//Init audio samples buffer
	circBuf_init(&circ_buf);

	//Loading sinewave wave file. Used for debug/test purpose. Triggered from a GUI command.
	bdWavFile_settings play_file_settings;
	play_file_settings.frameSizeMax = AUDIO_FROM_PS_FRAME_PER_BUF_MAX;
	play_file_settings.folderPath = PLAY_FOLDER_PATH;
	play_file_settings.fileName = PLAY_FILE_NAME;
	playFile = new bdWavFile();
	if(playFile!=NULL)
	{
		playFile->openFile(&play_file_settings,BD_WAV_FILE_TYPE_READ);
		printf("Sinewave file %s%s opened\n", PLAY_FOLDER_PATH,PLAY_FILE_NAME);
	}
	else
	{
		printf("Cannot open play file test\n");
	}


	//Start peripheral audio play&capture
	audio_driver_start();

	//Creating audio capture and play threads.
	thread_create(&cap_thread_inst, cap_thread, 0, "cap_th");
	thread_create(&play_thread_inst, play_thread, 0,"play_th");
	return 0;
}
void audio_routine_deinit()
{
	audio_end=1;
	//Stopping audio capture and play threads.
	thread_join(cap_thread_inst);
	thread_join(play_thread_inst);
	audio_driver_stop();
	audio_driver_deinit();
#ifdef PLAY_FILE_TEST
	playFile->closeFile();
	delete(playFile);
#endif
	if(debug_en)
	{
		recFile->closeFile();
		delete(recFile);
	}
}

//Returns audio engine running status.
int audio_routine_get_running()
{
	if(audio_end)
		return 0;
	else
		return 1;
}

int audio_routine_set ()
{
	
}