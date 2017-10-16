#ifndef FW_UPDATE_WIDGET_H
#define FW_UPDATE_WIDGET_H

#include <QtWidgets/QWidget>
#include <qgridlayout.h>
#include <qpushbutton.h>
#include <qlineedit.h>
#include <qcombobox.h>
#include <qlabel.h>
#include <qmessagebox.h>
#include <qstandardpaths.h>
#include <qfiledialog.h>
#include <qprogressdialog.h>
#include <qprogressbar.h>
#include <qpalette.h>
#include <QDebug.h>
#include <qsemaphore.h>
#include "bdSerialPort.h"
#include "commands.h"
#include "status.h"
#include "updateTrackingDialog.h"
#include "shortIdList.h"

#include <cstdint>


class fwUpdateWidget : public QWidget
{
    Q_OBJECT

public:
	fwUpdateWidget(bdSerialPort *serialPort, updateTrackingDialog *updateTracking,  QWidget *parent = 0);
    ~fwUpdateWidget();

    bdSerialPort *serialPortPtr;
	updateTrackingDialog *updateTrackingPtr;
		
	void connectQtSignals();
    void disconnectQtSignals();

public slots:
    void slot_updateMicPodLabels(system_status_t * sys_status);
	void slot_updateMicPodHUBLabels(system_status_t * sys_status);
    void slot_updateTVHUBLabels(system_status_t * sys_status);
    void slot_updateTableHUBLabels(system_status_t * sys_status);

private:
	shortIdList shortIdClass;
	QLabel *IDLabel;
	QLabel *uniqueIDLabel;
	QLabel *swVersionLabel;
	QLabel *fpgaVersionLabel;
	QLabel *fpgaIDLabel;

	QLabel *micPod_IDLabels[MICPOD_MAX_N];
	QLabel *micPod_UniqueIDLabels[MICPOD_MAX_N];
	QLabel *micPod_swVerLabels[MICPOD_MAX_N];
	QLabel *micPod_fpgaVerLabels[MICPOD_MAX_N];
	QLabel *micPod_fpgaIDLabels[MICPOD_MAX_N];
	QPushButton *micPod_updtBtn[MICPOD_MAX_N];
	QPushButton *micPod_updateAll;

	QLabel *micPodHUB_IDLabel;
	QLabel *micPodHUB_uniqueIDLabel;
	QLabel *micPodHUB_swVersionLabel;
	QLabel *micPodHUB_fpgaVersionLabel;
	QLabel *micPodHUB_fpgaIDLabel;

	QLabel *micPodHUB_IDLabels[MICPOD_MAX_N];
	QLabel *micPodHUB_UniqueIDLabels[MICPOD_MAX_N];
	QLabel *micPodHUB_swVerLabels[MICPOD_MAX_N];
	QLabel *micPodHUB_fpgaVerLabels[MICPOD_MAX_N];
	QLabel *micPodHUB_fpgaIDLabels[MICPOD_MAX_N];
	QPushButton *micPodHUB_updtBtn[MICPOD_MAX_N];
	QPushButton *micPodHUB_updateAll;

	QLabel *tableHUB_IDLabel;
	QLabel *tableHUB_uniqueIDLabel;
	QLabel *tableHUB_swVersionLabel;
	QLabel *tableHUB_linuxVersionLabel;
	QLabel *tableHUB_stmVersionLabel;
	QLabel *tableHUB_fpgaVersionLabel;
	QLabel *tableHUB_fpgaIDLabel;

	QLabel *tableHUB_IDLabels;
	QLabel *tableHUB_UniqueIDLabels;
	QLabel *tableHUB_swVerLabels;
	QLabel *tableHUB_linuxVersionLabels;
	QLabel *tableHUB_stmVersionLabels;
	QLabel *tableHUB_fpgaVerLabels;
	QLabel *tableHUB_fpgaIDLabels;
	QPushButton *tableHUB_updtAppBtn;
	QPushButton *tableHUB_updtSTM32Btn;

	QLabel *tvHUB_IDLabel;
	QLabel *tvHUB_uniqueIDLabel;
	QLabel *tvHUB_swVersionLabel;
	QLabel *tvHUB_linuxVersionLabel;
	QLabel *tvHUB_stmVersionLabel;
	QLabel *tvHUB_fpgaVersionLabel;
	QLabel *tvHUB_fpgaIDLabel;

	QLabel *tvHUB_IDLabels;
	QLabel *tvHUB_UniqueIDLabels;
	QLabel *tvHUB_swVerLabels;
	QLabel *tvHUB_linuxVersionLabels;
	QLabel *tvHUB_stmVersionLabels;
	QLabel *tvHUB_fpgaVerLabels;
	QLabel *tvHUB_fpgaIDLabels;
	QPushButton *tvHUB_updtAppBtn;
	QPushButton *tvHUB_updtSTM32Btn;
	
	QBoxLayout *mainLayout;
	QGridLayout *micpods_gridLayout;
	QGridLayout *micpod_HUB_gridLayout;
	QGridLayout *table_HUB_gridLayout;
	QGridLayout *tv_HUB_gridLayout;

	system_status_t fw_updt_system_status;
	
	
private slots:
	void slot_sendStartUpdateCmd();
};



#endif // SERIAL_COMMAND_WIDGET_H
