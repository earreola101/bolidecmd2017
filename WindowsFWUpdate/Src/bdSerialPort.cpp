
#include "bdSerialPort.h"

//#include "command_parser.h"

bdSerialPort::bdSerialPort(void)
	: QObject()
{
	closeSerialPort = false;
	connected = false;
	sendMutex = new QMutex();
	//isSending = false;
}

bdSerialPort::~bdSerialPort(void)
{
	if(isConnected())
		close();
}

QStringList bdSerialPort::availableDevices()
{
	int numPort = 0;

	nameAvailablePort.clear();
	serialPort.getNumPortAvailable(&numPort,portAvailableNum);
	for(int i=0;i<numPort;i++)
	{
		nameAvailablePort << QString("COM%1").arg(portAvailableNum[i]);
	}

	return nameAvailablePort;
}

// ConnectionString -> comName ("COM1")
bool bdSerialPort::open(QString connectionString)
{
	connected = false;
	portNumber = 0;
	//isSending = false;

	QString portString = connectionString;

	portNumber = portString.remove("COM").toInt()-1;

	int status = serialPort.open(portNumber,BAUD_RATE,READ_TIMEOUT_MS,WRITE_TIMEOUT_MS);
	if(status!=0)
	{
		bdIODeviceError err = BD_IO_DEVICE_ERR_HOST_NOT_FOUND;
		emit errorSignal((int)err);
		return false;
	}

	serialPort.flush();

	connected = true;
	
	closeSerialPort = false;

	// Thread receive connected msg
	//receiveConnectedMsgThread *recvThread = new receiveConnectedMsgThread(this);
	//QThread::connect(recvThread,SIGNAL(finished()), recvThread, SLOT(deleteLater()));
	//recvThread->start();

	//// Send a msg to check if host is connected
	//command_t command;
	//command.commandType = BD_COMMAND_HOST_CONNECTED;
	//command.customDataLen = 0;
	//command.isAudioContent = 0;

	//quint8 buffer[COMM_MAX_LENGTH];

	//int size = generateSendBuffer(buffer,&command);

	//int res = sendBuffer(buffer,size);
	//emit signal_startRecvThread(true);
	//emit signal_startPollingMicpods(true);

	return true;
}

void bdSerialPort::close()
{
	if(connected)
	{
		closeSerialPort = true;
		connected = false;
		serialPort.flush();
		serialPort.close();
		//emit signal_startRecvThread(false);
		//emit signal_startPollingMicpods(false);
	}
}

bool bdSerialPort::isConnected()
{
	return connected;
}

int bdSerialPort::sendBuffer(quint8 *buffer, int size)
{
	int numBytes;
	int status;

	//QDateTime local(QDateTime::currentDateTime());
	//qDebug() << local.toString("ss.zzz") << ": send before mutex";
	sendMutex->lock();
	//isSending = true;
	//local= QDateTime::currentDateTime();
	//qDebug() << local.toString("ss.zzz")  << ": send after mutex";
	serialPort.flush();
	//local= QDateTime::currentDateTime();
	//qDebug() << local.toString("ss.zzz")  << ": flush finished";
	numBytes = serialPort.write((char*)buffer,size);
	//isSending = false;
	sendMutex->unlock();
	//local= QDateTime::currentDateTime();
	//qDebug() << local.toString("ss.zzz")  << ": send finished";
	return numBytes;
}

// return < 0 serialPort disconnected
int bdSerialPort::recvBuffer(quint8 *buffer, int size)
{
	//if(isSending)
	//	return 0;
	sendMutex->lock();
	int numBytes = 0;
	numBytes = serialPort.read((char*)buffer,size);
	sendMutex->unlock();
	if(closeSerialPort)
		return -100;
	return numBytes;
}

int bdSerialPort::recvFirstTimeAlive(quint8 *buffer, int size)
{
	QByteArray byteArray;
	int numBytes = 0;
	int maxTimeout = 3000/READ_TIMEOUT_MS;
	int idxTimeout=0;
	int res;
	bool commandStarted=false;
	int commandLen;
	int idxW = 0;
	bool commandReceived = false;

	serialPort.flush();

	while(!closeSerialPort && idxTimeout<maxTimeout && !commandReceived)
	{
		res = serialPort.read((char*)&buffer[idxW],1);
		if(res>0)
		{
			//// Check if command start
			//if(!commandStarted)
			//{
			//	if(buffer[0]==(COMM_START_BYTE))
			//	{
			//		commandStarted = 1;
			//		commandLen = COMM_MAX_LENGTH;
			//	}
			//	else
			//	{
			//		// Error receiveng Command
			//		return -1;
			//	}
			//}

			//if(commandStarted)
			//{
			//	if(idxW==COMM_LENGTH_BYTE_POS)
			//		commandLen = getReceivedBufferLength(buffer);

			//	idxW++;

			//	if(idxW>=commandLen)
			//	{
			//		numBytes = commandLen;
			//		commandReceived = true;
			//		break;
			//	}
			//}
			maxTimeout += 100;
		}
		else
		{
			idxTimeout++;
		}
	}

	return numBytes;
}

