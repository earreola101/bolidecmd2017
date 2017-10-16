#ifndef UTILITY_H__
#define UTILITY_H__

#include <sys/time.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
void log_init();
uint8_t crcCalc(uint8_t * pSrc, int len);
void sleep_ms(int ms);
void sleep_us(int us);

//void printTimeMs();
void thread_create(pthread_t** threahHndl, void* threadCode(void*), void* parameters, char * threadName);
void thread_join(pthread_t* threahHndl);
int thread_set_priority(void* threahHndl, int policy, int priority);
void thread_exit(pthread_t* threahHndl);
int mutex_init(pthread_mutex_t** mutex);
void mutex_deinit(pthread_mutex_t* mutex);
void mutex_lock(pthread_mutex_t* mutex);
void mutex_unlock(pthread_mutex_t* mutex);

int semaphore_init(sem_t **sem);
void semaphore_deinit(sem_t *sem);
void semaphore_post(sem_t * sem);
void semaphore_wait(sem_t * sem);
void printTimeMs();
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
class bdTime
{
    protected:
        double startTime;
        double stopTime;
        double totalTime;
        bool started;

    public:

        bdTime(void);
        virtual ~ bdTime (void);
        int start (void);
        int stop (void);
        int reset (void);
        double getTimeNs (void);
        double getTimeUs (void);
        double getTimeMs (void);
        double getTimeS (void);
};



typedef enum {
	BD_WAV_FILE_TYPE_WRITE	= false,
	BD_WAV_FILE_TYPE_READ	= true
} bdWavFile_type;


typedef struct bdWavFile_settings
{
	const char * folderPath;
	const char * fileName;
	int frameSizeMax;
} bdWavFile_settings;

int bdWavFile_getLengthFromHeader(unsigned char *header);
void bdWavFile_updateFileLengthHeader(unsigned char *header, int length);

class bdWavFile{
private:
	FILE * pFile;
	long lSize;
	short * buffer;
	size_t result;

	bool isReadFile;
	bool opened;

	int _sampleRate;
	int nChannels;
	int length;
	int frameSizeMax;
	int bytePerSample;
	 char filePath[300];
public:
	bdWavFile();
	virtual ~bdWavFile();

	int openFile(bdWavFile_settings *settings,bdWavFile_type type);
	void closeFile();
	int removeFile();

	/*
	 * READ File
	 */
    int getFrameOfFile(int frameSize);
    int getSampleRate();
    int getBytePerSample();
    int getNumberChannels();
    int getTotalSampleLength();
    int getLeghtMs();

//    int readData (float * pDst, int frameSize);
    int readData (short * pDst, int frameSize);
    int readData (int * pDst, int frameSize);
	/*
	 * WRITE File
	 */
	void setSampleRate(int sampleRate);
	void setNumberChannels(int nCh);
	void setBytePerSample(int bytePerChannels);

	//bdStatus writeDataC (float Src, int frameSize);
	int writeDataC (short Src, int frameSize);
//	int writeData (const float * pSrc, int frameSize);
	int writeData (const short * pSrc, int frameSize);
	int writeData (const int * pSrc, int frameSize);
protected:
	void writeHeader(unsigned char *pHeadBuf);
	int getFileInfo(unsigned char * header, int *length, int *sampleRate, int *nChannel, int * bytePerSample);
};

#endif

#endif
