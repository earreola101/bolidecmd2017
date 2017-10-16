#ifndef EC_COMMAND_WIDGET_H
#define EC_COMMAND_WIDGET_H

#include "bdDefineAudioProc.h"
#include "bdGroupBox.h"

// QT includes
#include <QtWidgets/qlayout.h>
#include <QtWidgets/qwidget.h>
#include <QtWidgets/qgroupbox.h>
#include <QtWidgets/qlabel.h>
#include <qlineedit.h>
#include "qformlayout.h"
#include "qpushbutton.h"
#include "bdSerialPort.h"
#include "qcombobox.h"
#include "qmessagebox.h"

class ecCommandWidget : public bdGroupBox
{
	Q_OBJECT

public:
	ecCommandWidget(bdSerialPort *serialPort, system_status_t *status, QWidget *parent = 0);

public slots:
    void slot_updateList();

private:

    system_status_t *sys_status; 

    bdSerialPort *serialPortPtr;

	// Main Layout
    QHBoxLayout *mainHLayout;
    QFormLayout *mainFormLayout;

    QLineEdit *sendCmdStringLineEdit;
	QPushButton *sendCmdStringButton;
    QComboBox *receiverComboBox;

    QStringList recvList;
    	
    void connectSignals();
    void disconnectSignals();

private slots:
    void slot_sendCmdStringSlot();
};

#endif // EC_COMMAND_WIDGET_H