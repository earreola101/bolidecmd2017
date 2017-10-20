#include "bolideCmdAccess.h"
#include <qsemaphore.h>
#include <qtextstream.h>
#include "bdSerialPort.h"
#include "commands.h"
#include "command_queue.h"

#include "status.h"


class recvThread;

typedef struct FWackWait_t
{
	QSemaphore waitAckSem;
	int seqNum;
	int ackStatus;
	bool nackWait;
	int rollBackBytes;
	int rollBackSeqN;

} FWackWait_t;

void bolideCmdAccess::Run(char *command)
{


}

bolideCmdAccess::bolideCmdAccess()
{
	QString endmessage;
	endmessage.append("end");

	bdSerialPort *bdserial;

	recvThread *recvTh;
	FWackWait_t ackStruct;



}


bolideCmdAccess::~bolideCmdAccess()
{
}



class recvThread : public QThread
{
	Q_OBJECT

public:
	recvThread(bdSerialPort *serialPort, FWackWait_t * FWackWait)
	{
		serialPortPtr = serialPort;
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

signals:
	void signal_packetReceived(bool timeout);
	void signal_updateMicLabels(system_status_t * sys_status);
	void signal_devStatusRefresh(system_status_t * sys_status);
	void signal_updateConsole(int sender, QString string);
	void signal_updateProgressPerc(int perc);
	void signal_updateProgressInfo(char *buf);
	void signal_flashUpdateComplete(bool success);
	void signal_resetAliveHubCnt();
	void signal_tooManyDevError(int devType);
	void signal_updateCpu(int id, int cpu);


	private slots:
	void slot_startThread(bool start);
};
