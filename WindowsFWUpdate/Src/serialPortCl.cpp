#include "serialPortCl.h"


serialPortCl::serialPortCl(void)
{
}


serialPortCl::~serialPortCl(void)
{
}


void serialPortCl::getNumPortAvailable(int *numPort, int *portAvailable)
{
	hCom = NULL;
	numPort[0] = 0;
	
	for (int i = 1; i <= MAX_COMPORT; ++i)  
    {  
        if (i < 10)
          wsprintf(szComPort, L"COM%d", i);
        else
          wsprintf(szComPort, L"\\\\.\\COM%d", i); 

 
        hCom = CreateFile(szComPort,  
            GENERIC_READ|GENERIC_WRITE, // desired access should be read&write  
            0,                          // COM port must be opened in non-sharing mode  
            NULL,                       // don't care about the security  
            OPEN_EXISTING,              // IMPORTANT: must use OPEN_EXISTING for a COM port  
            0,                          // usually overlapped but non-overlapped for existance test  
            NULL);                      // always NULL for a general purpose COM port  

        if (INVALID_HANDLE_VALUE != hCom)
        {   // COM port exist  
			portAvailable[numPort[0]] = i;
            numPort[0]++;
            CloseHandle(hCom);  
        }  
    }
}

int serialPortCl::open(int portNumber, int baudrate, int readTimeoutMs, int writeTimeoutMs)
{
	if((portNumber>MAX_COMPORT)||(portNumber<0))
	{
		printf("illegal comport number\n");
		return(-1);
	}
	
	comport_number = portNumber;

	switch(baudrate)
	{
		case     110 : strcpy(baudr, "baud=110 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case     300 : strcpy(baudr, "baud=300 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case     600 : strcpy(baudr, "baud=600 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case    1200 : strcpy(baudr, "baud=1200 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case    2400 : strcpy(baudr, "baud=2400 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case    4800 : strcpy(baudr, "baud=4800 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case    9600 : strcpy(baudr, "baud=9600 data=8 parity=N stop=1 dtr=off rts=off");
						break;
		case   19200 : strcpy(baudr, "baud=19200 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case   38400 : strcpy(baudr, "baud=38400 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case   57600 : strcpy(baudr, "baud=57600 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case  115200 : strcpy(baudr, "baud=115200 data=8 parity=N stop=1 dtr=off rts=off");
						break;
		case  128000 : strcpy(baudr, "baud=128000 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case  230400 : strcpy(baudr, "baud=230400 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case  256000 : strcpy(baudr, "baud=256000 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case  500000 : strcpy(baudr, "baud=500000 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		case 1000000 : strcpy(baudr, "baud=1000000 data=8 parity=N stop=1 dtr=on rts=on");
						break;
		default      : printf("invalid baudrate\n");
						return(1);
						break;
	}

	char comports[MAX_COMPORT][10]={
		"\\\\.\\COM1",  "\\\\.\\COM2",  "\\\\.\\COM3",  "\\\\.\\COM4",
		"\\\\.\\COM5",  "\\\\.\\COM6",  "\\\\.\\COM7",  "\\\\.\\COM8",
		"\\\\.\\COM9",  "\\\\.\\COM10", "\\\\.\\COM11", "\\\\.\\COM12",
		"\\\\.\\COM13", "\\\\.\\COM14", "\\\\.\\COM15", "\\\\.\\COM16",  
		"\\\\.\\COM17", "\\\\.\\COM18", "\\\\.\\COM19", "\\\\.\\COM20", 
		"\\\\.\\COM21", "\\\\.\\COM22",	"\\\\.\\COM23", "\\\\.\\COM24", 
		"\\\\.\\COM25", "\\\\.\\COM26",	"\\\\.\\COM27", "\\\\.\\COM28", 
		"\\\\.\\COM29", "\\\\.\\COM30", "\\\\.\\COM31",  "\\\\.\\COM32",  
		"\\\\.\\COM33", "\\\\.\\COM34", "\\\\.\\COM35", "\\\\.\\COM36",  
		"\\\\.\\COM37", "\\\\.\\COM38", "\\\\.\\COM39", "\\\\.\\COM40", 
		"\\\\.\\COM41", "\\\\.\\COM42",	"\\\\.\\COM43", "\\\\.\\COM44", 
		"\\\\.\\COM45", "\\\\.\\COM46", "\\\\.\\COM47", "\\\\.\\COM48", 
		"\\\\.\\COM49", "\\\\.\\COM50", "\\\\.\\COM51", "\\\\.\\COM52",	
		"\\\\.\\COM53", "\\\\.\\COM54", "\\\\.\\COM55", "\\\\.\\COM56",	
		"\\\\.\\COM57", "\\\\.\\COM58", "\\\\.\\COM59", "\\\\.\\COM60"
	};

	Cport[comport_number] = CreateFileA(comports[comport_number],
						GENERIC_READ|GENERIC_WRITE,
						0,                          /* no share  */
						NULL,                       /* no security */
						OPEN_EXISTING,
						0,                          /* no threads */
						NULL);                      /* no templates */

	if(Cport[comport_number]==INVALID_HANDLE_VALUE)
	{
		printf("unable to open comport\n");
		return(-1);
	}

	DCB port_settings;
	memset(&port_settings, 0, sizeof(port_settings));  /* clear the new struct  */
	port_settings.DCBlength = sizeof(port_settings);

	if(!BuildCommDCBA(baudr, &port_settings))
	{
		printf("unable to set comport dcb settings\n");
		CloseHandle(Cport[comport_number]);
		return(-1);
	}

	if(!SetCommState(Cport[comport_number], &port_settings))
	{
		printf("unable to set comport cfg settings\n");
		CloseHandle(Cport[comport_number]);
		return(-1);
	}

	Cptimeouts.ReadIntervalTimeout         = 0;
	Cptimeouts.ReadTotalTimeoutMultiplier  = 0;
	Cptimeouts.ReadTotalTimeoutConstant    = readTimeoutMs;
	Cptimeouts.WriteTotalTimeoutMultiplier = 0;
	Cptimeouts.WriteTotalTimeoutConstant   = writeTimeoutMs;

	if(!SetCommTimeouts(Cport[comport_number], &Cptimeouts))
	{
		printf("unable to set comport time-out settings\n");
		CloseHandle(Cport[comport_number]);
		return(-1);
	}

	return(0);
}


int serialPortCl::read(char *buf, int size)
{
	int n;

	/* added the void pointer cast, otherwise gcc will complain about */
	/* "warning: dereferencing type-punned pointer will break strict aliasing rules" */

	if(size>4096)  
		size = 4096;	
	
	ReadFile(Cport[comport_number], buf, size, (LPDWORD)((void *)&n), NULL);

	return(n);
}


int serialPortCl::writeByte(char byte)
{
	int n;

	WriteFile(Cport[comport_number], &byte, 1, (LPDWORD)((void *)&n), NULL);

	if(n<0)  
		return(1);

	return(0);
}


int serialPortCl::write(char *buf, int size)
{
	int n;

	if(WriteFile(Cport[comport_number], buf, size, (LPDWORD)((void *)&n), NULL))
		return(n);

	return(-1);
}


void serialPortCl::close()
{
	CloseHandle(Cport[comport_number]);
}


int serialPortCl::isCTSEnabled()
{
	int status;

	GetCommModemStatus(Cport[comport_number], (LPDWORD)((void *)&status));

	if(status&MS_CTS_ON) 
		return(1);
	else 
		return(0);
}


int serialPortCl::isDSREnabled()
{
	int status;

	GetCommModemStatus(Cport[comport_number], (LPDWORD)((void *)&status));

	if(status&MS_DSR_ON) 
		return(1);
	else 
		return(0);
}


void serialPortCl::enableDTR()
{
	EscapeCommFunction(Cport[comport_number], SETDTR);
}


void serialPortCl::disableDTR()
{
	EscapeCommFunction(Cport[comport_number], CLRDTR);
}


void serialPortCl::enableRTS()
{
	EscapeCommFunction(Cport[comport_number], SETRTS);
}


void serialPortCl::disableRTS()
{
	EscapeCommFunction(Cport[comport_number], CLRRTS);
}

void serialPortCl::cPuts(const char *text)  /* sends a string to serial port */
{
	while(*text != 0)   
		writeByte(*(text++));
}

void serialPortCl::flush()
{
	FlushFileBuffers(Cport[comport_number]);
}