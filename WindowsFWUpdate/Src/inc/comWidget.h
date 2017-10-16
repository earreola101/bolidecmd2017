#ifndef COM_WIDGET_H
#define COM_WIDGET_H

#include <QtWidgets/QWidget>
#include <qapplication.h>
#include <qgridlayout.h>
#include <qpushbutton.h>
#include <qradiobutton.h>
#include <qcombobox.h>
#include <qcheckbox.h>
#include <qlabel.h>
#include <QDebug.h>
#include <QSpacerItem>
#include "bdSerialPort.h"
#include "status.h"
#include "command_parser.h"
#include <cstdint>
#include <QLabel>
#include <QPixmap>
#include <qsize.h>

#define ALIVE_CHECK_INTERVAL_MS		500
#define TABLE_HUB_RESET_VAL_CNT		4

class checkAliveThread;

class comWidget : public QWidget
{
    Q_OBJECT

public:
    comWidget(bdSerialPort *serialPort, QWidget *parent = 0);
    ~comWidget();

    bdSerialPort *serialPortPtr;
	checkAliveThread *checkAliveThreadPtr;

	QGridLayout *mainGridLayout;
	QLabel *connLabel;
	
	int tableHubAliveCnt;
    
    void connectQtSignals();
    void disconnectQtSignals();
	
	void setResetCnt(int val);
	int  getResetCnt();

private:
	bool comPortOpen;
	QPushButton *openComButton;
	QComboBox * comComboBox;
    QLabel *comLabel;
	

private slots:
	void slot_openComButton();
	void slot_resetAliveCnt();
	void slot_setHubConnection(bool connected);
};

class checkAliveThread : public QThread
{
    Q_OBJECT

public:
	checkAliveThread(comWidget *auxWidg)
	{
		comWidgetPtr = auxWidg;
		exitThread = false;
	}
	~checkAliveThread(){};
	void stop()
	{
		exitThread = true;
	}

	void run();
private:
	comWidget *comWidgetPtr;
	bool exitThread;
	int tableHubAliveCnt;
	uint8_t currentConnSts;

signals:
	void signal_setHubConnection(bool connected);

};

#endif // COMMAND_GRID_WIDGET_H
