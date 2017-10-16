#ifndef COMMAND_GRID_WIDGET_H
#define COMMAND_GRID_WIDGET_H

#include <QtWidgets/QWidget>
#include <qapplication.h>
#include <qgridlayout.h>
#include <qmessagebox.h>
#include <qpushbutton.h>
#include <qradiobutton.h>
#include <qplaintextedit.h>
#include <qcombobox.h>
#include <qbuttongroup.h>
#include <qcheckbox.h>
#include <qlabel.h>
#include <QDebug.h>
#include <QSpacerItem>
#include "bdSerialPort.h"
#include "status.h"
#include "command_parser.h"
#include <cstdint>
#include "shortIdList.h"

#define MICPOD_MAX_NUM			7
#define SYSTEM_POLL_INTERVAL_MS	500

class pollMicPodsThread;

class cmdGridWidget : public QWidget
{
    Q_OBJECT

public:
    cmdGridWidget(bdSerialPort *serialPort, QWidget *parent = 0);
    ~cmdGridWidget();

    bdSerialPort *serialPortPtr;

	pollMicPodsThread * pollMics;

	QBoxLayout *mainLayout;
	QGridLayout *gridLayout;

    system_status_t* getSystemStatus();

    
    void connectQtSignals();
    void disconnectQtSignals();
	void scanComPort();

public slots:
    void slot_printDeviceTree(system_status_t * sys_status);
    void slot_updateMicLabels(system_status_t * sys_status);

private:
	shortIdList shortIdClass;
	system_status_t cmd_grid_system_status;
	char sendBuf[MAX_PACKET_LEN];
	tdm_command_t command;

	QLabel *ledStatusLabel;
	QLabel *muteLabel;
	QLabel *postFilterLabel;
	QLabel *listenLabel;
	QLabel *IDLabel;
	QLabel *CPULoadLabel;
	QLabel *uniqueIDLabel;
	QLabel *shortIDLabel;
	QLabel *micDebugLabel;

	QLabel *micPodLabels[MICPOD_MAX_NUM];
	QLabel *uniqueIDLabels[MICPOD_MAX_NUM];
	QLabel *shortIDLabels[MICPOD_MAX_NUM];
	QLabel *micPodCPULabels[MICPOD_MAX_NUM];
	QPushButton *ledStatusButtons[MICPOD_MAX_NUM];
	QCheckBox *muteCheckBoxes[MICPOD_MAX_NUM];
	QCheckBox *postFilterCkBoxes[MICPOD_MAX_NUM];
	QButtonGroup *listenBtnGroup;
	QRadioButton *listenRadioButtons[MICPOD_MAX_NUM+1];
	QButtonGroup *debugBtnGroup;
	QRadioButton *micDebugButtons[MICPOD_MAX_NUM];
	QPlainTextEdit *devTreeTextEdit;
	QPushButton * resetDebugBtn;
	
	void append_child_device_tree(generic_device_t * device, int tabNum);
	void append_single_device(generic_device_t * device, QString tabs);
	void system_status_rebuild_dependencies(system_status_t * status);
	generic_device_t * system_status_get_device_addr_from_id(uint8_t id, system_status_t * status);

private slots:
	void slot_ledStatusAction();
	void slot_muteAction();
	void slot_postFilterAction();
	void slot_listenAction();
	void slot_clearDebug();
	void slot_setMicPodDebug();
	void slot_startStopPolling(bool start);
	void slot_updateCpu(int id, int cpu);
};

class pollMicPodsThread : public QThread
{
    Q_OBJECT

public:
	pollMicPodsThread(cmdGridWidget *auxWidg)
	{
		cmdWidget = auxWidg;
		exitThread = false;
	}
	~pollMicPodsThread(){};
	void stop()
	{
		exitThread = true;
	}

	void run();
private:
	cmdGridWidget *cmdWidget;
	bool exitThread;

};

#endif // COMMAND_GRID_WIDGET_H
