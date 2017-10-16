#ifndef BD_SERIAL_PORT_H
#define BD_SERIAL_PORT_H


#include "serialPortCl.h"

// Qt Includes
#include <qwidget.h>
#include <qthread.h>
#include <qtimer.h>

typedef enum bdIODeviceError {
	BD_IO_DEVICE_ERR_HOST_CLOSE_CONNECTION	= 0,
	BD_IO_DEVICE_ERR_HOST_NOT_FOUND			= 1
} bdIODeviceError;
#define BAUD_RATE 115200
//#define BAUD_RATE 230400
//#define BAUD_RATE 1000000 //115200 //9600	//1000000
#define READ_TIMEOUT_MS 1
#define WRITE_TIMEOUT_MS 200

class receiveConnectedMsgThread;

class bdSerialPort : public QObject
{
	Q_OBJECT
public:
	bdSerialPort();
	virtual ~bdSerialPort();

	QStringList availableDevices();

	// ConnectionString -> comName ("COM1")
	bool open(QString connectionString);
	void close();

	bool isConnected();

	int sendBuffer(quint8 *buffer, int size);

	// return < 0 serialPort disconnected
	int recvBuffer(quint8 *buffer, int size);

signals:
	void errorSignal(int err);
	void connectedSignal();
	void disconnectedSignal();
	void signal_startRecvThread(bool start);
	void signal_startPollingMicpods(bool start);

private:
	// Serial port	
	serialPortCl serialPort;
	int portNumber;
	bool connected;
	int portAvailableNum[MAX_COMPORT];
	QStringList nameAvailablePort;

	//bool isSending;
	QMutex *sendMutex;
	bool closeSerialPort;
	
	int recvFirstTimeAlive(quint8 *buffer, int size);

	friend class receiveConnectedMsgThread;
};


class receiveConnectedMsgThread : public QThread
{
    Q_OBJECT

public:
	receiveConnectedMsgThread(bdSerialPort *pSerialPort)
	{
		serialPort = pSerialPort;
	}
	~receiveConnectedMsgThread(){};
	void run();
private:
	bdSerialPort *serialPort;
};


#endif // BD_SERIAL_PORT_H