#ifndef FILE_LOADER_DIALOG_H
#define FILE_LOADER_DIALOG_H

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
#include "cmdGridWidget.h"
#include "fw_update_def.h"

class sendFwThread;
class recvFwThread;

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


typedef struct fwUpdateParams_t
{
	char filePath[FW_UPDATE_PKT_SIZE];

	uint8_t updateType;
	uint8_t deviceId;

	uint32_t packetsNumber;
	uint32_t packetSize;

	uint32_t sequenceNumber;

}fwUpdateParams_t;

class fileLoaderDialog : public QDialog
{
    Q_OBJECT

public:
    fileLoaderDialog(bdSerialPort *serialPort, FWackWait_t * FWackWait, QWidget *parent = 0);
    ~fileLoaderDialog();

	void setLabels(uint8_t updateType, uint8_t deviceId);

    bdSerialPort *serialPortPtr;
	
    QGridLayout *mainGridLayout;
	QGridLayout *cmdGridLayout;
    
	QLabel *updateTypeLabel;
	QLabel *deviceIDLabel;

	QComboBox *devTypeBox;
        
	// Open File
	QString fileDirPath;
	QLineEdit *fileLineEdit;
	QPushButton *openFileButton;

	// Start/stop Update Button
	QPushButton *updateButton;

	QProgressDialog *fwProgressDialog;

	sendFwThread *sendFwTh;
	
	FWackWait_t *ackStruct;
	
	// Progress Bar
	QProgressBar *progressBar;
	QPalette pal;

	int idxValue;
	int totalSize;


    void connectQtSignals();
    void disconnectQtSignals();
	uint8_t crcCalc(uint8_t * pSrc, int len);

private:
	fwUpdateParams_t fwUpdateParamsTX;
	QString fwPath;
	bool fwGenerated;
	void resetView();

private slots:
	void slot_openFileButtonClicked();
	void slot_updateButtonClicked();
	void slot_fileTransferComplete();
	void slot_increaseProgressBar(int);
};

class sendFwThread : public QThread
{
    Q_OBJECT

public:
	sendFwThread(fileLoaderDialog *auxWidg, QString filePath, fwUpdateParams_t * fwUpdateParams, FWackWait_t * FWackWait)
	{
		fwWidget = auxWidg;
		path = filePath;
		exitThread = false;
		ackStruct = FWackWait;
		fwUpdateParamsPtr = fwUpdateParams;
	}
	~sendFwThread(){};
	void stop()
	{
		exitThread = true;
	}

	void run();

private:
	fileLoaderDialog *fwWidget;
	FWackWait_t * ackStruct;
	fwUpdateParams_t * fwUpdateParamsPtr;
	
	QString path;
	bool exitThread;

signals:
	void signal_fileTransferComplete();
	void signal_increaseProgressBar(int);
};


#endif // SERIAL_COMMAND_WIDGET_H
