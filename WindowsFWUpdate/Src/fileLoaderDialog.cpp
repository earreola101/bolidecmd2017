#define NOMINMAX
#include <windows.h>
#include "fileLoaderDialog.h"
#include "command_parser.h"
#include "command_queue.h"
#include "command_gen_dec.h"
#include "md5.h"
#include "qdebug.h"
#include <QDateTime>
#include <qstring.h>
#include <QTimeZone>
#include <qdate>
fileLoaderDialog::fileLoaderDialog(bdSerialPort *serialPort, FWackWait_t * FWackWait, QWidget *parent)
	: QDialog(parent)
{
    serialPortPtr = serialPort;
	ackStruct = FWackWait;
	
    mainGridLayout = new QGridLayout();
    this->setLayout(mainGridLayout);
	this->setMinimumWidth(500);

	updateTypeLabel = new QLabel("<b>Select the device type: </b>");
	updateTypeLabel->setFixedWidth(135);
	//deviceIDLabel = new QLabel();
	devTypeBox = new QComboBox();
	QStringList devList;
	devList.append("MicPod");
	devList.append("MicPod HUB");
	devList.append("Table HUB Core");
	devList.append("TV HUB Core");
	devList.append("STM32");
	devTypeBox->addItems(devList);
	devTypeBox->setMaximumWidth(100);
	
	QBoxLayout * labelLayout = new QHBoxLayout();
	labelLayout->setAlignment(Qt::AlignLeft);

	labelLayout->addWidget(updateTypeLabel);
	labelLayout->addWidget(devTypeBox);
		
	QWidget *topArea = new QWidget();
	topArea->setLayout(labelLayout);

	// Progress Bar
	progressBar = new QProgressBar(this);
	progressBar->setAlignment(Qt::AlignCenter);
	progressBar->setTextVisible(true);
	progressBar->setMinimumHeight(25);

	idxValue = 0;

	progressBar->setMinimum(0);
	
	QColor c(255,178,102);
	QPalette pal;
	pal.setColor(QPalette::Normal, QPalette::Highlight, c);
	pal.setColor(QPalette::Inactive, QPalette::Highlight, c);
	progressBar->setPalette(pal);

	// Open File
	
	fileLineEdit = new QLineEdit();
	fileLineEdit->setAlignment(Qt::AlignLeft);
	fileDirPath = "C:\\Project\\zynq_array\\Doc\\Boot_gen\\output\\";
	//fileLineEdit->setReadOnly(true);
	fileLineEdit->setPlaceholderText("Click on the Open button to select the bin file.");
	//fileLineEdit->setText("C:\\Project\\zynq_array\\Doc\\Boot_gen\\boot_mic_pod.bin.208_192_0_0.md5.zip");
	openFileButton = new QPushButton("Open File");

	// Start/stop Update Button
	updateButton = new QPushButton("Start Download");
	updateButton->setFixedWidth(150);

	mainGridLayout->addWidget(topArea,0,0);
	mainGridLayout->addWidget(fileLineEdit,1,0);
	mainGridLayout->addWidget(openFileButton,1,1);
	mainGridLayout->addWidget(updateButton,2,0);
	mainGridLayout->addWidget(progressBar,3,0);


	fwGenerated = false;
}

fileLoaderDialog::~fileLoaderDialog()
{

}


void fileLoaderDialog::connectQtSignals()
{
    bool res = connect(openFileButton,SIGNAL(clicked()),this,SLOT(slot_openFileButtonClicked()));
	res = connect(updateButton,SIGNAL(clicked()),this,SLOT(slot_updateButtonClicked()));
}

void fileLoaderDialog::disconnectQtSignals()
{
    disconnect(openFileButton,SIGNAL(clicked()),this,SLOT(slot_openFileButtonClicked()));
	disconnect(updateButton,SIGNAL(clicked()),this,SLOT(slot_updateButtonClicked()));
}

void fileLoaderDialog::setLabels(uint8_t updateType, uint8_t deviceId)
{
	/*fwUpdateParamsTX.updateType=updateType;
	fwUpdateParamsTX.deviceId=deviceId;

	if(deviceId!=DEFAULT_BROADCAST_ID)
		deviceIDLabel->setText("<b>Device ID:</b> "+QString::number(deviceId));
	else
	{
		if(updateType==MICPOD_HUB_DEVICE_TYPE)
			deviceIDLabel->setText("<b>Device ID:</b> The update will affect all the MicPod HUBs ");
		else if(updateType==MICPOD_DEVICE_TYPE)
			deviceIDLabel->setText("<b>Device ID:</b> The update will affect all the MicPods ");
	}

	switch(updateType)
	{
		case TABLE_HUB_DEVICE_TYPE:
			updateTypeLabel->setText("<b>Device Type:</b> Table HUB Core");
			break;
		case TV_HUB_DEVICE_TYPE:
			updateTypeLabel->setText("<b>Device Type:</b> TV HUB Core");
			break;
		case MICPOD_HUB_DEVICE_TYPE:
			updateTypeLabel->setText("<b>Device Type:</b> MicPod HUB");
			break;
		case MICPOD_DEVICE_TYPE:
			updateTypeLabel->setText("<b>Device Type:</b> MicPod");
			break;
		case STM32_DEVICE_TYPE:
			if(deviceId==DEFAULT_TABLE_HUB_ID)
				updateTypeLabel->setText("<b>Device Type:</b> STM32 on Table HUB");
			else
				updateTypeLabel->setText("<b>Device Type:</b> STM32 on TV HUB");
			break;
		default:
			break;
	}	*/
}
 
 /****************************
  * [SLOT] Open FIle
  */
void fileLoaderDialog::slot_openFileButtonClicked()
{
	QString filePath = QFileDialog::getOpenFileName(this,
						tr("Open Save Directory"), fileDirPath,
						tr("FW files (*.zip)"));

	if (filePath.isEmpty())
	{
		return;
	}
	else
	{
		fileLineEdit->setText(filePath);
	}
}

/******************************************************************
 * [SLOT] Update Button Clicked
 ******************************************************************/
void fileLoaderDialog::slot_updateButtonClicked()
{
	if(!serialPortPtr->isConnected())
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please open the COM port first.");
		messageBox.setFixedSize(100,100);
		return;
	}

	if(fileLineEdit->text().isEmpty())
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select the FW file to be downloaded.");
		messageBox.setFixedSize(100,100);
		return;
	}
	
	uint8_t devType = devTypeBox->currentIndex();


	switch(devType)
	{
		case 0:
			fwUpdateParamsTX.updateType = MICPOD_DEVICE_TYPE;
		break;
		case 1:
			fwUpdateParamsTX.updateType = MICPOD_HUB_DEVICE_TYPE;
		break;
		case 2:
			fwUpdateParamsTX.updateType = TABLE_HUB_DEVICE_TYPE;
		break;
		case 3:
			fwUpdateParamsTX.updateType = TV_HUB_DEVICE_TYPE;
		break;
		case 4:
			fwUpdateParamsTX.updateType = STM32_DEVICE_TYPE;
		break;
		
	}

	sendFwTh = new sendFwThread(this,fileLineEdit->text(), &fwUpdateParamsTX, ackStruct);
	bool res = QThread::connect(sendFwTh,SIGNAL(finished()), sendFwTh, SLOT(deleteLater()));
	res = QThread::connect(sendFwTh,SIGNAL(signal_fileTransferComplete()), this, SLOT(slot_fileTransferComplete()));
	res = QThread::connect(sendFwTh,SIGNAL(signal_increaseProgressBar(int)), this, SLOT(slot_increaseProgressBar(int)));
	sendFwTh->start();
	
	fwGenerated = false;
}


/******************************************************************
 * Send FW Thread
 ******************************************************************/
void sendFwThread::run()
{
	quint64 idx = 0;
	ackStruct->seqNum = 0;
	ackStruct->nackWait = false;
	ackStruct->rollBackBytes = 0;

	char sendBuf[MAX_PACKET_LEN];
	uint8_t auxBuf[MAX_PACKET_LEN];
	char md5File[MD5_LENGTH];
	tdm_command_t command;
	char * md5Computed;
	int len;

	QByteArray fileName = path.toLocal8Bit();
	char * rFileName = new char[std::strlen(fileName.data())+1];
	std::strcpy(rFileName,fileName.data());
	
	//get md5
	FILE *pRFile = fopen(rFileName, "rb");
	fseek(pRFile, -MD5_LENGTH, SEEK_END);
	fread(md5File, sizeof(char), MD5_LENGTH,pRFile);
	fclose(pRFile);

	//get file len
	pRFile = fopen(rFileName, "rb");
	fseek(pRFile, 0L, SEEK_END);
	int fileSize = ftell(pRFile);
	fclose(pRFile);

	int totLen = fileSize-MD5_LENGTH;

	uint8_t *fileBuf;
	fileBuf = (uint8_t *)malloc(totLen);
	pRFile = fopen(rFileName, "rb");

	for(int i=0; i<totLen; i++)
		fread(&fileBuf[i], sizeof(uint8_t), 1,pRFile);
	fclose(pRFile);
	//MD5 md5;
	//md5Computed = md5.digestMemory(fileBuf,totLen);
	//
	//int err=0, i;
	//for(i=0; i<MD5_LENGTH; i++)
	//{
	//	if(md5File[i]!=md5Computed[i])
	//	{
	//		err=1;
	//		break;
	//	}
	//}


	//if(err)
	//{
	//	QMessageBox messageBox;
	//	messageBox.information(0,"Error!","MD5 error. Please select a different file.");
	//	messageBox.setFixedSize(100,100);
	//	return;
	//}

	
	QFile file(rFileName);
	if(!file.open(QIODevice::ReadOnly))
		return;
	fwWidget->totalSize = fileSize;

	//fwWidget->progressBar->setMaximum(fwWidget->totalSize);
	fwWidget->progressBar->setMaximum(100);

	// Start sending data
	bool firstMsg = true;

	cmd_gen_fw_down_start(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, (fwWidget->totalSize/FW_UPDATE_PKT_SIZE)+1, FW_UPDATE_PKT_SIZE, fwUpdateParamsPtr->updateType, &command);
	generatePacket((uint8_t*)sendBuf, &command);
	fwWidget->serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);

	// Wait for ACK
	ackStruct->ackStatus = ACK_KO;
	//qDebug() << "Wainting for ack";
	ackStruct->waitAckSem.acquire();
	//qDebug() << "Wainting ack aquired";
	if(ackStruct->ackStatus==ACK_KO)	
		return;	//error!
	emit signal_increaseProgressBar(0);
	ackStruct->seqNum++;
	QDateTime local(QDateTime::currentDateTime());
	while(!exitThread)
	{
		if(ackStruct->nackWait)
			continue;

		if(ackStruct->rollBackBytes)
		{
			file.seek(file.pos()-ackStruct->rollBackBytes);
			ackStruct->seqNum= ackStruct->rollBackSeqN - ackStruct->rollBackBytes/FW_UPDATE_PKT_SIZE;
			idx-=ackStruct->rollBackBytes;
			ackStruct->rollBackBytes=0;
		}
		//local= QDateTime::currentDateTime();
		//qDebug() << local.toString("ss.zzz") << ": Before file read";
		len= file.read((char*)auxBuf,FW_UPDATE_PKT_SIZE);
		//local= QDateTime::currentDateTime();
		//qDebug() << local.toString("ss.zzz") << ": After file read";

		cmd_gen_fw_update_packet(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, auxBuf, len, ackStruct->seqNum, &command);
		generatePacket((uint8_t*)sendBuf, &command);
		
		//local= QDateTime::currentDateTime();
		//qDebug() << local.toString("ss.zzz") << ": Send FW packet" << ackStruct->seqNum;
		fwWidget->serialPortPtr->sendBuffer((quint8*)sendBuf, PACKET_OVERHEAD+command.len+COMMAND_OVERHEAD);
		//local= QDateTime::currentDateTime();
		//qDebug() << local.toString("ss.zzz") << ": Packet sent" << ackStruct->seqNum;
		//qDebug() << "Sended FW packet" << ackStruct->seqNum;

		idx+=len;
		if(ackStruct->seqNum%20==0)
		{
			emit signal_increaseProgressBar((idx*100/fwWidget->totalSize)+1);
		}
		//msleep(1);
		ackStruct->seqNum++;
		if(idx>=fwWidget->totalSize)
		{
			
			cmd_gen_fw_update_end(DEFAULT_PC_ID, DEFAULT_TABLE_HUB_ID, &command);
			generatePacket((uint8_t*)sendBuf, &command);
			fwWidget->serialPortPtr->sendBuffer((quint8*)sendBuf,  PACKET_OVERHEAD+command.len+COMMAND_OVERHEAD);
			
			// Wait for ACK
			ackStruct->ackStatus = ACK_KO;
			ackStruct->waitAckSem.acquire();
			emit signal_fileTransferComplete();

			exitThread = true;
			file.close();
			//file.remove();
		}
	}
}


uint8_t fileLoaderDialog::crcCalc(uint8_t * pSrc, int len)
{
	uint8_t auxByte=0;
	int i;
	for(i=0; i<len; i++)
		auxByte^=pSrc[i];
	return auxByte;
}


/******************************************************************
 * Increase progress bar idx
 ******************************************************************/
void fileLoaderDialog::slot_fileTransferComplete()
{
	QMessageBox messageBox;
	if(ackStruct->ackStatus==ACK_OK)
		messageBox.information(0,"Information","MD5 check passed.\n\r Transfer success!");
	else
		messageBox.information(0,"Error!","MD5 error. Please try again");
	
	messageBox.setFixedSize(100,100);

	resetView();
}

void fileLoaderDialog::resetView()
{
	progressBar->reset();
	idxValue = 0;
	progressBar->setMinimum(0);
	
	QColor c(255,178,102);
	QPalette pal;
	pal.setColor(QPalette::Normal, QPalette::Highlight, c);
	pal.setColor(QPalette::Inactive, QPalette::Highlight, c);
	progressBar->setPalette(pal);

	fileLineEdit->clear();
}

/******************************************************************
 * Increase progress bar idx
 ******************************************************************/
void fileLoaderDialog::slot_increaseProgressBar(int perc)
{
	progressBar->setValue(perc);
}
