#ifndef BOLIDE_H
#define BOLIDE_H

#include <QtWidgets/QMainWindow>
#include <qtabwidget.h>
#include <qmenu.h>
#include <qmenubar.h>
#include "cmdGridWidget.h"
#include "bdSerialPort.h"
#include "comWidget.h"
#include "debugWidget.h"
#include "consoleWidget.h"
#include "fwUpdateWidget.h"
#include "fileLoaderDialog.h"
#include "updateTrackingDialog.h"
#include "bdAboutWidget.h"
#include "bdRecvAudioProcTabWidget.h"
#include "ecCommandLogTabWidget.h"

class recvThread;

class Bolide : public QMainWindow
{
    Q_OBJECT

public:
    Bolide(QWidget *parent = 0);
    ~Bolide();

    bdSerialPort *serialPort;
	recvThread *recvTh;
	FWackWait_t ackStruct;

    cmdGridWidget * cmdGridW;
	comWidget * comW;
	debugWidget * debugW;
	consoleWidget * consoleW;
	fwUpdateWidget * fwUpdateW;
	fileLoaderDialog *fileLoaderPtr;
	updateTrackingDialog *updateTrackingPtr;
	bdAboutWidget *aboutWidget;

    bdRecvAudioProcTabWidget *recvAudioProcTab;

    ecCommandLogTabWidget *ecCommandLogTab;

	//Menu bar
	QMenuBar    *pMenuBar;
	QMenu		*infoMenu;
	QAction		*aboutAction;

	QTabWidget *mainTabWidget;

private slots:
	void slot_tooManyDevError(int devType);
    void slot_devStatusRefresh(system_status_t *sys_status);
};

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

#endif // BOLIDE_H
