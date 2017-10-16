#ifndef UPDATE_TRACKING_DIALOG_H
#define UPDATE_TRACKING_DIALOG_H

#include <QtWidgets/QWidget>
#include <qdialog.h>
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
#include "fw_update_def.h"

#include <cstdint>

#define ACK_OK	0	
#define ACK_KO	(-1)

class updateTrackingDialog : public QDialog
{
    Q_OBJECT

public:
    updateTrackingDialog(bdSerialPort *serialPort, QWidget *parent = 0);
    ~updateTrackingDialog();

	bdSerialPort *serialPortPtr;
	
    QGridLayout *mainGridLayout;
	
	QLabel *updateTypeLabel;
	QLabel *deviceIDLabel;
	QLabel *statusLabel;

	QComboBox *devTypeBox;
	
	QProgressDialog *fwProgressDialog;

	// Progress Bar
	QProgressBar *progressBar;
	QPalette pal;

	uint8_t updateType; 
	uint8_t deviceId;
	
    void connectQtSignals();
    void disconnectQtSignals();

	void setUpdateTypeDev(uint8_t updateT, uint8_t dev_Id);
	void getUpdateTypeDev(uint8_t *updateT, uint8_t *dev_Id);
	void startUpdate();

private:
	void resetView();

private slots:
	void slot_updateProgressPerc(int perc);
	void slot_updateProgressInfo(char * info);
	void slot_flashUpdateComplete(bool success);
};



#endif // SERIAL_COMMAND_WIDGET_H
