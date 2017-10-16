#ifndef SERIAL_RECV_THREAD_H
#define SERIAL_RECV_THREAD_H

#include <QtWidgets/QWidget>
#include <qgridlayout.h>
#include <qpushbutton.h>
#include <qlineedit.h>
#include <qcombobox.h>
#include <qlabel.h>
#include <qmessagebox.h>
#include <qstandardpaths.h>
#include <qfiledialog.h>
#include <QDebug.h>
#include <qsemaphore.h>
#include "bdSerialPort.h"
#include "commands.h"
#include "command_queue.h"
#include <cstdint>

#define ACK_OK	0	
#define ACK_KO	(-1)

typedef struct FWackWait_t
{
	QSemaphore waitAckSem;
	int seqNum;
	int ackStatus;
	bool nackWait;
	int rollBackBytes;
	int rollBackSeqN;

} FWackWait_t;


class recvThread : public QThread
{
    Q_OBJECT

public:
	recvThread(bdSerialPort *serialPortP, FWackWait_t * FWackWait)
	{
		serialPortPtr = serialPortP;
		exitThread = false;
		ackStruct = FWackWait;
	}
	~recvThread(){};
	void stop()
	{
		exitThread = true;
	}

	void run();
private:
	bdSerialPort *serialPortPtr;
	FWackWait_t * ackStruct;

	bool exitThread;

	char recvBuf[RX_QUEUE_LEN];
	int indexW;
	int indexR;

	command_queue_t queue;

};

#endif // SERIAL_RECV_THREAD_H
