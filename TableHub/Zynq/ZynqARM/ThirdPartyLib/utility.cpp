#include "utility.h"
#include <string.h>
void sleep_us(int us)
{
	if(us>1000000)
	{
		sleep_ms(us/1000);
	}
	if(us>0)
	{
		struct timespec sleepTime;

		sleepTime.tv_sec=0;
		sleepTime.tv_nsec=us*1000;
		nanosleep(&sleepTime,NULL);
	}

}

void sleep_ms(int ms)
{
	if(ms>0)
	{
		struct timespec sleepTime;

		sleepTime.tv_sec=ms/1000;
		sleepTime.tv_nsec=(ms%1000)*1000000;
		nanosleep(&sleepTime,NULL);
	}
}

uint8_t crcCalc(uint8_t * pSrc, int len)
{
	uint8_t auxByte=0;
	int i;
	for(i=0; i<len; i++)
		auxByte^=pSrc[i];
	return auxByte;
}
void printTimeMs()
{
	struct timeval tp;
	gettimeofday(&tp, NULL);
	long int ms = tp.tv_sec * 1000 + tp.tv_usec / 1000;

	printf("%d:\n",ms);
}

bdTime::bdTime(void)
{
    totalTime=0.0;
    startTime=0.0;
    stopTime=0.0;
    started=false;
}

bdTime::~bdTime(void)
{
}

int bdTime::start (void)
{
    if (started==true)
    	return -1;
    struct timespec res;
    started=true;
	clock_gettime(CLOCK_REALTIME, &res);
    startTime=1e9*res.tv_sec + (double)res.tv_nsec;
    return 0;
}

int bdTime::stop(void)
{
    if (started==false)
    	return -1;
	struct timespec res;
    started=false;
	clock_gettime(CLOCK_REALTIME, &res);
    stopTime=1e9*res.tv_sec + (double)res.tv_nsec;
    totalTime=stopTime-startTime;
    return 0;
}

int bdTime::reset(void)
{
    started = false;
    totalTime=0.0;
    startTime=0.0;
    stopTime=0.0;
    return 0;
}

double bdTime::getTimeNs(void)
{
    if (started==true)
    {
    	struct timespec res;
		clock_gettime(CLOCK_REALTIME, &res);
		stopTime=1e9*res.tv_sec + (double)res.tv_nsec;
        totalTime=stopTime-startTime;
    }
    return (totalTime);
}

double bdTime::getTimeUs(void)
{
    if (started==true)
    {
    	struct timespec res;
		clock_gettime(CLOCK_REALTIME, &res);
		stopTime=1e9*res.tv_sec + (double)res.tv_nsec;
        totalTime=stopTime-startTime;
    }
    return (totalTime/1e3);
}


double bdTime::getTimeMs(void)
{
    if (started==true)
    {
    	struct timespec res;
		clock_gettime(CLOCK_REALTIME, &res);
		stopTime=1e9*res.tv_sec + (double)res.tv_nsec;
        totalTime=stopTime-startTime;
    }
    return (totalTime/1e6);
}


double bdTime::getTimeS(void)
{
    if (started==true)
    {
    	struct timespec res;
		clock_gettime(CLOCK_REALTIME, &res);
		stopTime=1e9*res.tv_sec + (double)res.tv_nsec;
        totalTime=stopTime-startTime;
    }
    return (totalTime/1e9);
}



bdWavFile::bdWavFile()
{
	pFile=NULL;
	buffer=NULL;
	lSize=0;
	result=0;
	opened = false;
	_sampleRate = 16000;
	nChannels = 1;
	bytePerSample = 2;
	frameSizeMax = 160;
//	scaleFactor = 32768.0f;
	memset(filePath,0,sizeof(char)*300);
    length = 44;
}

bdWavFile::~bdWavFile()
{
	closeFile();
}

int bdWavFile::openFile(bdWavFile_settings *settings, bdWavFile_type type)
{
	isReadFile = type;
	memset(filePath,0,sizeof(char)*300);
	strcpy (filePath,settings->folderPath);
	strcat (filePath,settings->fileName);
	frameSizeMax = settings->frameSizeMax;

	unsigned char header[44];
	for (int i=0; i<44; i++)
		header[i]=0;

	if(isReadFile)
	{
		pFile = fopen ( filePath , "rb" );
		if (pFile==NULL)
			return -1;

		fread(header, sizeof(unsigned char), 44, pFile);

		int res = this->getFileInfo(header, &length, &_sampleRate, &nChannels, &bytePerSample);

		if (res != 0)
		{
			printf("Error while parsing header data, error code -> %d\n", res);
			return -1;
		}
	}
	else
	{
		pFile = fopen ( filePath , "wb" );
		if (pFile==NULL)
			return -1;

		unsigned char header[44];
		for (int i=0; i<44; i++)
			header[i]=0;
		writeHeader(header);
	}

	buffer = NULL;
	buffer = (short*)malloc(sizeof(short)*frameSizeMax*2);

	opened = true;
	return -1;
}

void bdWavFile::closeFile()
{
	if(pFile!=NULL)
	{
		// Write Header File
		if (!isReadFile)
        {
            unsigned char pHeadBuf[44];
			writeHeader(pHeadBuf);
        }

		fclose(pFile);
		opened = false;
	}
	pFile=NULL;

	if (buffer!=NULL)
		free (buffer);
	buffer=NULL;
}


/*
 * READ File
 */

//int bdWavFile::readData (float * pDst, int frameSize)
//{
//	if (isReadFile)
//	{
//		result = fread (buffer,sizeof(short),frameSize*nChannels,pFile);
//		if (result!=frameSize*nChannels)
//		{
//			return -1;
//		}
//		for (int i=0; i<frameSize*nChannels; i++)
//		{
//			pDst[i]=((float) buffer[i])/scaleFactor;
//		}
//		return 0;
//	}
//	else
//	{
//		return -1;
//	}
//}

int bdWavFile::readData (short * pDst, int frameSize)
{
	if (isReadFile)
	{
		result = fread (pDst,sizeof(short),frameSize*nChannels,pFile);
		if (result!=frameSize*nChannels)
		{
			return -1;
		}

		return 0;
	}
	else
	{
		return -1;
	}
}

int bdWavFile::readData (int * pDst, int frameSize)
{
	if (isReadFile)
	{
		result = fread (pDst,sizeof(int),frameSize*nChannels,pFile);
		if (result!=frameSize*nChannels)
		{
			return -1;
		}

		return 0;
	}
	else
	{
		return -1;
	}
}

int bdWavFile::getBytePerSample() {
	if (!opened && isReadFile)
		return -1;
	return bytePerSample;
}


int bdWavFile::getSampleRate() {
	if (!opened && isReadFile)
		return -1;
	return _sampleRate;
}

int bdWavFile::getNumberChannels() {
	if (!opened && isReadFile)
		return -1;
	return nChannels;
}

int bdWavFile::getTotalSampleLength() {
	if (!opened && isReadFile)
		return -1;
	if(!isReadFile)
		return -1;

	return length/(sizeof(short)*nChannels);
}

int bdWavFile::getLeghtMs()
{
	return getTotalSampleLength()/(_sampleRate/1000);
}

int bdWavFile::getFrameOfFile(int frameSize)
{
	if (!opened && isReadFile)
		return -1;
	if(!isReadFile)
		return -1;

	return (length/(sizeof(short)*frameSize*nChannels));
}


/*
 * WRITE File
 */
void bdWavFile::setSampleRate(int sampleRate)
{
	_sampleRate = sampleRate;
}

void bdWavFile::setNumberChannels(int nCh)
{
	nChannels = nCh;
}

void bdWavFile::setBytePerSample(int bPs)
{
	bytePerSample = bPs;
}

//int bdWavFile::writeData (const float * pSrc, int frameSize)
//{
//	if (!isReadFile)
//	{
//		for (unsigned int i=0; i<frameSize*nChannels; i++)
//		{
//			buffer[i]=(short)(pSrc[i]*scaleFactor);
//		}
//		result = fwrite (buffer , sizeof(short), frameSize*nChannels, pFile );
//
//		if (result!=frameSize*nChannels)
//		{
//			return -1;
//		}
//
//		return 0;
//	}
//	else
//	{
//		return -1;
//	}
//}

int bdWavFile::writeData (const short * pSrc, int frameSize)
{
	if (!isReadFile)
	{

		result = fwrite (pSrc , sizeof(short) , frameSize*nChannels, pFile );

		if (result!=frameSize*nChannels)
		{
			return -1;
		}

		return 0;
	}
	else
	{
		return -1;
	}
}
int bdWavFile::writeData (const int * pSrc, int frameSize)
{
	if (!isReadFile)
	{

		result = fwrite (pSrc , sizeof(int) , frameSize*nChannels, pFile );

		if (result!=frameSize*nChannels)
		{
			return -1;
		}

		return 0;
	}
	else
	{
		return -1;
	}
}

/*
bdStatus bdWavFile::writeDataC (float pSrc, int frameSize)
{
	if (!isReadFile)
	{
		for (int i=0; i<frameSize*nChannels; i++)
		{
			buffer[i]=(short)(pSrc*scaleFactor);
		}
		result = fwrite (buffer, sizeof(short), frameSize*nChannels, pFile );

		if (result!=frameSize*nChannels)
		{
			return BD_ERROR_FILE_ENDED;
		}

		return BD_OK;
	}
	else
	{
		return BD_ERROR_FILE_NOT_WRITE_MODE;
	}
}*/

//int bdWavFile::writeDataC (short pSrc, int frameSize)
//{
//	if (!isReadFile)
//	{
//		for (int i=0; i<frameSize*nChannels; i++)
//		{
//			buffer[i]= pSrc;
//		}
//		result = fwrite (buffer , sizeof(short) , frameSize*nChannels, pFile );
//
//		if (result!=frameSize*nChannels)
//		{
//			return -1;
//		}
//
//		return 0;
//	}
//	else
//	{
//		return -1;
//	}
//}

int bdWavFile::removeFile()
{
	result = remove(filePath);

    if (result!=0) {
        return -1;
    }

    return 0;
}

int bdWavFile::getFileInfo(unsigned char * pHeadBuf, int *length,
		int *sampleRate, int *nChannel,int * bytePerSample) {
	/* read chunkID, must be 'RIFF'  ------------------------------------------*/
	if (pHeadBuf[0] != 'R' || pHeadBuf[1] != 'I' || pHeadBuf[2] != 'F'
			|| pHeadBuf[3] != 'F')
		return 1;

	/* read the file length */
	/* The sampling time 8000 Hz To recorde 10s we need 8000 x 10 x 2 (16-Bit data) */

	*length = (pHeadBuf[4] | (pHeadBuf[5] << 8) | (pHeadBuf[6] << 16)
			| (pHeadBuf[7] << 24));

	/* read the file format, must be 'WAVE' */
	if (pHeadBuf[8] != 'W' || pHeadBuf[9] != 'A' || pHeadBuf[10] != 'V'
			|| pHeadBuf[11] != 'E')
		return 2;

	/* read the format chunk, must be'fmt ' */
	if (pHeadBuf[12] != 'f' || pHeadBuf[13] != 'm' || pHeadBuf[14] != 't'
			|| pHeadBuf[15] != ' ')
		return 3;

	/* read the length of the 'fmt' data, must be 0x10 */
	if (pHeadBuf[16] != 0x10 || pHeadBuf[17] != 0x00 || pHeadBuf[18] != 0x00
			|| pHeadBuf[19] != 0x00)
		return 4;

	/* read the audio format, must be 0x01 (PCM) */
	if (pHeadBuf[20] != 0x01 || pHeadBuf[21] != 0x00)
		return 5;

	/* read the number of channels, must be 0x01 (Mono) or 0x02 (Stereo) */
	if (pHeadBuf[22] == 0x01 && pHeadBuf[23] == 0x00)
		*nChannel = pHeadBuf[22];
	else if (pHeadBuf[22] == 0x02 && pHeadBuf[23] == 0x00)
		*nChannel = 2;
	else
		return 6;

	//pHeadBuf[23] == 0x00;


	*sampleRate = (pHeadBuf[24] | (pHeadBuf[25] << 8) | (pHeadBuf[26] << 16)
			| (pHeadBuf[27] << 24));

	*bytePerSample = (pHeadBuf[34] | (pHeadBuf[35]<<8))/8;

	/* read the Data chunk, must be 'data' */
	if (pHeadBuf[36] != 'd' || pHeadBuf[37] != 'a' || pHeadBuf[38] != 't'
			|| pHeadBuf[39] != 'a')
		return 7;

	return 0;
}

void bdWavFile_updateFileLengthHeader(unsigned char *header, int length)
{
    /* Write the file length */
    /* The sampling time 8000 Hz
    To recorde 10s we need 8000 x 10 x 2 (16-Bit data) */
    int chunkSize = length+36;
    header[4] = (unsigned char)(chunkSize&0xFF);
    header[5] = (unsigned char)((chunkSize >> 8)&0xFF);
    header[6] = (unsigned char)((chunkSize >> 16)&0xFF);
    header[7] = (unsigned char)((chunkSize >> 24)&0xFF);

    /* Write the number of sample data */
    header[40] = (unsigned char)(length&0xFF);
    header[41] = (unsigned char)((length >> 8)&0xFF);
    header[42] = (unsigned char)((length >> 16)&0xFF);
    header[43] = (unsigned char)((length >> 24)&0xFF);
}

int bdWavFile_getLengthFromHeader(unsigned char *header)
{
    /* read the file length */
	/* The sampling time 8000 Hz To recorde 10s we need 8000 x 10 x 2 (16-Bit data) */

	int length = (header[40] | (header[41] << 8) | (header[42] << 16)
			| (header[43] << 24));

    return length;
}

void bdWavFile::writeHeader(unsigned char *pHeadBuf)
{
    fseek(pFile, 0, SEEK_END);
    length = ftell(pFile)-44;
    if(length<0)
        length = 0;
	rewind(pFile);

    /* write chunkID, must be 'RIFF'  ------------------------------------------*/
    pHeadBuf[0] = 'R';
    pHeadBuf[1] = 'I';
    pHeadBuf[2] = 'F';
    pHeadBuf[3] = 'F';

    /* Write the file length */
    /* The sampling time 8000 Hz
    To recorde 10s we need 8000 x 10 x 2 (16-Bit data) */
    int chunkSize = length+36;
    pHeadBuf[4] = (unsigned char)(chunkSize&0xFF);
    pHeadBuf[5] = (unsigned char)((chunkSize >> 8)&0xFF);
    pHeadBuf[6] = (unsigned char)((chunkSize >> 16)&0xFF);
    pHeadBuf[7] = (unsigned char)((chunkSize >> 24)&0xFF);


    /* Write the file format, must be 'WAVE' */
    pHeadBuf[8]  = 'W';
    pHeadBuf[9]  = 'A';
    pHeadBuf[10] = 'V';
    pHeadBuf[11] = 'E';

    /* Write the format chunk, must be'fmt ' */
    pHeadBuf[12]  = 'f';
    pHeadBuf[13]  = 'm';
    pHeadBuf[14]  = 't';
    pHeadBuf[15]  = ' ';

    /* Write the length of the 'fmt' data, must be 0x10 */
    pHeadBuf[16]  = 0x10;
    pHeadBuf[17]  = 0x00;
    pHeadBuf[18]  = 0x00;
    pHeadBuf[19]  = 0x00;

    /* Write the audio format, must be 0x01 (PCM) */
    pHeadBuf[20]  = 0x01;
    pHeadBuf[21]  = 0x00;

    /* Write the number of channels, must be 0x01 (Mono) or 0x02 (Stereo) */
    pHeadBuf[22]  = nChannels;
    pHeadBuf[23]  = 0x00;

    /* Write the Sample Rate 8000 Hz */
    pHeadBuf[24]  = (unsigned char)((_sampleRate & 0xFF));
    pHeadBuf[25]  = (unsigned char)((_sampleRate >> 8) & 0xFF);
    pHeadBuf[26]  = (unsigned char)((_sampleRate >> 16) & 0xFF);
    pHeadBuf[27]  = (unsigned char)((_sampleRate >> 24) & 0xFF);

    /* Write the Byte Rate */
    int byteRate = _sampleRate*nChannels*bytePerSample;
    pHeadBuf[28]  = (unsigned char)((byteRate & 0xFF));
    pHeadBuf[29]  = (unsigned char)((byteRate >> 8) & 0xFF);
    pHeadBuf[30]  = (unsigned char)((byteRate >> 16) & 0xFF);
    pHeadBuf[31]  = (unsigned char)((byteRate >> 24) & 0xFF);

    /* Write the block alignment */
    int blockAlign = nChannels*bytePerSample;
    pHeadBuf[32]  = (unsigned char) (blockAlign & 0xFF);/*0x02*/
    pHeadBuf[33]  = (unsigned char) ((blockAlign >> 8) &0xFF);

    /* Write the number of bits per sample */
    int bitsPerSample = bytePerSample*8;
    pHeadBuf[34]  = (unsigned char) (bitsPerSample & 0xFF);/*0x02*/
    pHeadBuf[35]  = (unsigned char) ((bitsPerSample >> 8) &0xFF);

    /* Write the Data chunk, must be 'data' */
    pHeadBuf[36]  = 'd';
    pHeadBuf[37]  = 'a';
    pHeadBuf[38]  = 't';
    pHeadBuf[39]  = 'a';

    /* Write the number of sample data */
    pHeadBuf[40] = (unsigned char)(length&0xFF);
    pHeadBuf[41] = (unsigned char)((length >> 8)&0xFF);
    pHeadBuf[42] = (unsigned char)((length >> 16)&0xFF);
    pHeadBuf[43] = (unsigned char)((length >> 24)&0xFF);

    fwrite(pHeadBuf, 1, 44, pFile);
}

void thread_create(pthread_t** threahHndl, void* threadCode(void*), void* parameters, char * threadName)
{
    pthread_attr_t thread_attr;
	pthread_attr_init(&thread_attr);
	threahHndl[0] = (pthread_t*)malloc(sizeof(pthread_t));
	pthread_create((pthread_t*)threahHndl[0], &thread_attr, threadCode, parameters);
	pthread_attr_destroy(&thread_attr);
	pthread_setname_np(((pthread_t*)threahHndl[0])[0], threadName);
}

void thread_join(pthread_t* threahHndl)
{
	if(threahHndl!=NULL)
	{	
		void *ret;
		pthread_join(*threahHndl, &ret);
		free(threahHndl);
	}
}

void thread_exit(pthread_t* threahHndl)
{
	if(threahHndl!=NULL)
	{

		pthread_exit(threahHndl);
	}
}

int thread_set_priority(void* threahHndl, int policy, int priority)
{
 struct sched_param param;
 param.sched_priority= priority;
 int poly = policy;
 int result = pthread_setschedparam (((pthread_t*)threahHndl)[0], poly, &param);
// if(result)
//  BERROR << "Thread set sched error %d\n" << result;
// else
//	 BINFO<< "Thread set sched OK\n";

 return result;
}

int mutex_init(pthread_mutex_t** mutex)
{

	mutex[0] = (pthread_mutex_t*)malloc(sizeof(pthread_mutex_t));
	pthread_mutexattr_t attr;
	pthread_mutexattr_init(&attr);

	pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE_NP);

	// Initialize the mutex
	pthread_mutex_init(mutex[0], &attr);
	pthread_mutexattr_destroy(&attr);


	return 0;
}

void mutex_deinit(pthread_mutex_t* mutex)
{
	int rc = pthread_mutex_destroy(mutex);
	if (rc != 0) {
		if (rc == EBUSY) {
			pthread_mutex_unlock(mutex);
			rc = pthread_mutex_destroy(mutex);
		}
	}
	// Destroy the mutex struct
	if (mutex != NULL)
		free(mutex);
}

void mutex_lock(pthread_mutex_t* mutex)
{
	pthread_mutex_lock(mutex);

}

void mutex_unlock(pthread_mutex_t* mutex)
{
	pthread_mutex_unlock(mutex);
}



int semaphore_init(sem_t **sem)
{
	sem[0] = (sem_t*)malloc(sizeof(sem_t));
    int res = sem_init(sem[0], 0, 0);
	if(res != 0)
 	{
		free(sem[0]);
		sem[0]=NULL;
		return -1;
	}
	return 0;
}

void semaphore_deinit(sem_t *sem)
{
	sem_destroy(sem);
	free(sem);
}


void semaphore_post(sem_t * sem)
{
	sem_post(sem);
}

void semaphore_wait(sem_t * sem)
{
	sem_wait(sem);
}

