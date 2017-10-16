#include "updateTrackingDialog.h"
#include "command_gen_dec.h"
#include "command_parser.h"


updateTrackingDialog::updateTrackingDialog(bdSerialPort *serialPort, QWidget *parent)
	: QDialog(parent)
{
    serialPortPtr = serialPort;
		
    mainGridLayout = new QGridLayout();
    this->setLayout(mainGridLayout);
	this->setMinimumWidth(500);

	statusLabel = new QLabel("Waiting");

	// Progress Bar
	progressBar = new QProgressBar(this);
	progressBar->setAlignment(Qt::AlignCenter);
	progressBar->setTextVisible(true);
	progressBar->setMinimumHeight(25);

	progressBar->setMinimum(0);
	progressBar->setMaximum(100);
	
	QColor c(255,178,102);
	QPalette pal;
	pal.setColor(QPalette::Normal, QPalette::Highlight, c);
	pal.setColor(QPalette::Inactive, QPalette::Highlight, c);
	progressBar->setPalette(pal);

	mainGridLayout->addWidget(statusLabel,0,0);
	mainGridLayout->addWidget(progressBar,1,0);
}

updateTrackingDialog::~updateTrackingDialog()
{

}


void updateTrackingDialog::connectQtSignals()
{
  
}

void updateTrackingDialog::disconnectQtSignals()
{
   
}

void updateTrackingDialog::slot_updateProgressPerc(int perc)
{
	progressBar->setValue(perc);
	if(perc>=progressBar->maximum())
	{
		progressBar->setValue(progressBar->maximum());
		QColor c(0,154,0);
		pal.setColor(QPalette::Normal, QPalette::Highlight, c);
		pal.setColor(QPalette::Inactive, QPalette::Highlight, c);
		progressBar->setPalette(pal);
	}
}

void updateTrackingDialog::slot_updateProgressInfo(char * info)
{
	statusLabel->setText(info);
}


/******************************************************************
 * Increase progress bar idx
 ******************************************************************/
void updateTrackingDialog::slot_flashUpdateComplete(bool success)
{
	QMessageBox messageBox;
	if(success)
		messageBox.information(0,"Information","Update Complete!");
	else
		messageBox.information(0,"Error!","Update fail. Please try again.");
	messageBox.setFixedSize(100,100);

	resetView();
	this->hide();
}


void updateTrackingDialog::resetView()
{
	progressBar->reset();
	progressBar->setMinimum(0);
	
	QColor c(255,178,102);
	QPalette pal;
	pal.setColor(QPalette::Normal, QPalette::Highlight, c);
	pal.setColor(QPalette::Inactive, QPalette::Highlight, c);
	progressBar->setPalette(pal);
}


void updateTrackingDialog::startUpdate()
{
	tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];
	uint8_t updateType,deviceId;

	getUpdateTypeDev(&updateType, &deviceId);
	cmd_gen_fw_update_start(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, updateType, deviceId, &command);
	generatePacket((uint8_t*)sendBuf, &command);
	serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
}

void updateTrackingDialog::setUpdateTypeDev(uint8_t updateT, uint8_t dev_Id)
{
	updateType = updateT; 
	deviceId = dev_Id;
}

void updateTrackingDialog::getUpdateTypeDev(uint8_t *updateT, uint8_t *dev_Id)
{
	 *updateT = updateType; 
	 *dev_Id = deviceId;
}
