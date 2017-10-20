#ifndef SERIAL_PORT_CL
#define SERIAL_PORT_CL

#include <windows.h>
#include "tchar.h"
#include <stdio.h>
#include <string.h>

#define MAX_COMPORT 60
#define CLOCK_TIME_MS 0.001f

class serialPortCl
{
private:
    wchar_t szComPort[8];  
    HANDLE hCom;

	HANDLE Cport[MAX_COMPORT];

	COMMTIMEOUTS Cptimeouts;

	char baudr[64];

	int comport_number;

public:
	serialPortCl(void);
	~serialPortCl(void);

	void getNumPortAvailable(int *numPort, int *portAvailable);
	int open(int portNumber, int baudrate, int readTimeoutMs, int writeTimeoutMs);
	int read(char *buf, int size);
	int writeByte(char byte);
	int write(char *buf, int size);
	void close();
	void cPuts(const char *text); /* sends a string to serial port */
	
	void flush();

	int isCTSEnabled();
	int isDSREnabled();
	void enableDTR();
	void disableDTR();
	void enableRTS();
	void disableRTS();
};	

#endif // SERIAL_PORT_CL