#include "consoleWidget.h"
#include "command_gen_dec.h"

#define SPACER_CUSTOM_HEIGHT 20
#define DEFAULT_RECORD_FILE_PATH	"/media/rootfs/record.wav"

consoleWidget::consoleWidget(bdSerialPort *serialPort, fileLoaderDialog *fileLoader, QWidget *parent)
    : QWidget(parent)
{
    serialPortPtr = serialPort;
	fileLoaderPtr = fileLoader;

	mainLayout = new QVBoxLayout();
	this->setMinimumHeight(100);
	this->setLayout(mainLayout);
	
	muteSysButton = new QPushButton("MUTE System");


	downloadFWLabel = new QLabel("FW Download:");
	downloadFWLabel->setStyleSheet("QLabel { font-weight: bold; }");
	downloadFWLabel->setFixedHeight(20);

	downloadFWButton = new QPushButton("Download to Table HUB");

	mainLayout->setAlignment(Qt::AlignTop);

	QWidget *spacer = new QWidget();
	spacer->setFixedHeight(SPACER_CUSTOM_HEIGHT);
	muteSysLabel = new QLabel("System Mute:");
	muteSysLabel->setStyleSheet("QLabel { font-weight: bold; }");
	muteSysLabel->setFixedHeight(20);

	mainLayout->addWidget(spacer);
	mainLayout->addWidget(muteSysLabel);
	mainLayout->addWidget(muteSysButton);

	QWidget *spacer1 = new QWidget();
	spacer1->setFixedHeight(SPACER_CUSTOM_HEIGHT);
	
	//volumeSlide = new QSlider(Qt::Horizontal);
	//volumeSlide->setMaximum(100);
	//volumeSlide->setValue(100);
	//volumeLbl = new QLabel("Volume: " +QString::number(100));
	//volumeLbl->setStyleSheet("QLabel { font-weight: bold; }");
	//mainLayout->addWidget(volumeLbl);
	//mainLayout->addWidget(volumeSlide);


	mainLayout->addWidget(spacer1);
	mainLayout->addWidget(downloadFWLabel);
	mainLayout->addWidget(downloadFWButton);

	recordLabel = new QLabel("Record to file:");
	recordLabel->setStyleSheet("QLabel { font-weight: bold; }");
	recordLabel->setFixedHeight(20);
	recordStopButton = new QPushButton("START Record");
	filePathLineEdit = new QLineEdit();
	filePathLineEdit->setText(DEFAULT_RECORD_FILE_PATH);

	QWidget *spacer2 = new QWidget();
	spacer2->setFixedHeight(SPACER_CUSTOM_HEIGHT);
	
	mainLayout->addWidget(spacer2);
	mainLayout->addWidget(recordLabel);
	mainLayout->addWidget(filePathLineEdit);
	mainLayout->addWidget(recordStopButton);

	QWidget *spacer3 = new QWidget();
	spacer3->setFixedHeight(SPACER_CUSTOM_HEIGHT);

	usbLabel = new QLabel("USB audio source:");
	usbLabel->setStyleSheet("QLabel { font-weight: bold; }");
	usbLabel->setFixedHeight(20);

	usbLayout = new QGridLayout();
	usbBtnGroup = new QButtonGroup();
	tvHubUsbLabel = new QLabel("TV HUB Audio USB: ");
	tableHubUsbLabel = new QLabel("TABLE HUB Audio USB: ");
	playDebugLabel = new QLabel("Custom CH: ");
	sineWaveLabel = new QLabel("Play sinewave: ");
	usbRadioButtons[0] = new QRadioButton();
	usbRadioButtons[1] = new QRadioButton();
	usbRadioButtons[2] = new QRadioButton();
	usbRadioButtons[3] = new QRadioButton();
		

	playChBox = new QSpinBox();
	playChBox->setMinimum(0);
	playChBox->setMaximum(15);

	mainLayout->addWidget(spacer3);
	
	usbBtnGroup->addButton(usbRadioButtons[0]);
	usbBtnGroup->addButton(usbRadioButtons[1]);
	usbBtnGroup->addButton(usbRadioButtons[2]);
	usbBtnGroup->addButton(usbRadioButtons[3]);


	usbLayout->addWidget(tableHubUsbLabel, 0, 0);
	usbLayout->addWidget(usbRadioButtons[0], 0, 1);
	usbLayout->addWidget(tvHubUsbLabel, 1, 0);
	usbLayout->addWidget(usbRadioButtons[1], 1, 1);
	usbLayout->addWidget(playDebugLabel, 2, 0);
	usbLayout->addWidget(usbRadioButtons[2], 2, 1);
	usbLayout->addWidget(playChBox, 2, 2);
	usbLayout->addWidget(sineWaveLabel, 3, 0);
	usbLayout->addWidget(usbRadioButtons[3], 3, 1);

	mainLayout->addWidget(usbLabel);
	mainLayout->addLayout(usbLayout);
		
	signalGenLabel = new QLabel("Signal generator:");
	signalGenLabel->setStyleSheet("QLabel { font-weight: bold; }");
	signalGenLabel->setFixedHeight(20);

	signalGenMenu = new QComboBox();
	signalGenMenu->addItem("Normal Mode");
	signalGenMenu->addItem("Ramp");
	signalGenMenu->addItem("Sine Wave");
	
	mainLayout->addWidget(signalGenLabel);
	mainLayout->addWidget(signalGenMenu);


	QWidget *spacer4 = new QWidget();
	spacer4->setSizePolicy(QSizePolicy ::Expanding , QSizePolicy ::Expanding );
	mainLayout->addWidget(spacer4);

	sysMute = false;
	recordOn = false;
}

consoleWidget::~consoleWidget()
{

}


void consoleWidget::slot_openNewWindow()
{
	uint8_t updateType, deviceId;
	
	if(serialPortPtr->isConnected())
	{
		fileLoaderPtr->show();
		
	}
	else
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
	}
	
	
}

void consoleWidget::connectQtSignals()
{
	bool res = connect(muteSysButton,SIGNAL(clicked()),this,SLOT(slot_muteSysSlot()));
	res = connect(downloadFWButton,SIGNAL(clicked()),this,SLOT(slot_openNewWindow()));
	res = connect(recordStopButton,SIGNAL(clicked()),this,SLOT(slot_startStopRecord()));
	res = connect(usbRadioButtons[0],SIGNAL(clicked()),this,SLOT(slot_sendUsbAudioSrc()));
	res = connect(usbRadioButtons[1],SIGNAL(clicked()),this,SLOT(slot_sendUsbAudioSrc()));
	res = connect(usbRadioButtons[2],SIGNAL(clicked()),this,SLOT(slot_sendUsbAudioSrc()));
	res = connect(usbRadioButtons[3],SIGNAL(clicked()),this,SLOT(slot_sendUsbAudioSrc()));
	res = connect(signalGenMenu,SIGNAL(currentIndexChanged(int)),this,SLOT(slot_sendSignalGenerator(int)));
	//res = connect(volumeSlide,SIGNAL(valueChanged(int)),this,SLOT(slot_volumeChanged(int)));
	if(!res)
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Signal not connected");
		messageBox.setFixedSize(100,100);
	}

}

void consoleWidget::disconnectQtSignals()
{
    
}


/*********************************************************
 * SLOTS
 **********************************************************

 /****************************
  * [SLOT] Mute System
 ****************************/
void consoleWidget::slot_muteSysSlot()
{
	tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];


	if(!serialPortPtr->isConnected())
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
		return;
	}
		
	if(!sysMute)
	{
		cmd_gen_set_mute_sys(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID,SYSTEM_MUTE, &command); //MUTE
		generatePacket((uint8_t*)sendBuf, &command);
		bool res = serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
		if(res)
			muteSysButton->setText("UNMUTE System");

		sysMute = true;
	}
	else
	{
		cmd_gen_set_mute_sys(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID,SYSTEM_UNMUTE, &command);	//UNMUTE
		generatePacket((uint8_t*)sendBuf, &command);
		bool res = serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
		if(res)
			muteSysButton->setText("MUTE System");
		sysMute = false;
	}
}

void consoleWidget::slot_startStopRecord()
{
	tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];


	if(!serialPortPtr->isConnected())
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
		return;
	}

	if(filePathLineEdit->text().isEmpty())
	{
		QMessageBox messageBox;
		messageBox.information(0,"Error","Empty file path is not allowed.");
		messageBox.setFixedSize(100,100);
		return;
	}

	QByteArray ba = filePathLineEdit->text().toLatin1();
	char *file_name = ba.data();
	if(!recordOn)
	{
		cmd_gen_set_debug_file(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID,1, file_name, &command); //START REC
		generatePacket((uint8_t*)sendBuf, &command);
		bool success = serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
		if(success)
		{
			recordStopButton->setText("STOP Record");
			filePathLineEdit->setEnabled(false);
			recordOn = true;
		}
	}
	else
	{
		cmd_gen_set_debug_file(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID,0, file_name, &command); //STOP REC
		generatePacket((uint8_t*)sendBuf, &command);
		bool success = serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
		if(success)
		{
			recordStopButton->setText("START Record");
			filePathLineEdit->setEnabled(true);
			recordOn = false;
		}
	}
}

void consoleWidget::slot_update(system_status_t * system_status)
{
	filePathLineEdit->setText(system_status->table_hub.table_hub_specific.debug_file);
	recordOn = system_status->table_hub.table_hub_specific.debug_enabled;
	if(recordOn)
	{
		recordStopButton->setText("STOP Record");
		filePathLineEdit->setEnabled(false);
	}
	else
	{
		recordStopButton->setText("START Record");
		filePathLineEdit->setEnabled(true);
	}

	if(system_status->table_hub.table_hub_specific.usb_connected)
	{
		usbRadioButtons[0]->setEnabled(true);
		if(system_status->table_hub.table_hub_specific.usb_source == USB_SRC_TABLE_HUB)
			usbRadioButtons[0]->setChecked(true);
	}
	else
		usbRadioButtons[0]->setEnabled(false);

	if(system_status->tv_hub.tv_hub_specific.usb_connected)
	{
		usbRadioButtons[1]->setEnabled(true);
		if(system_status->table_hub.table_hub_specific.usb_source == USB_SRC_TV_HUB)
			usbRadioButtons[1]->setChecked(true);
	}
	else
		usbRadioButtons[1]->setEnabled(false);

	if(system_status->table_hub.table_hub_specific.mute)
	{

		muteSysButton->setText("UNMUTE System");
		sysMute = true;
	}
	else
	{
		muteSysButton->setText("MUTE System");
		sysMute = false;
	}
	//volumeSlide->setValue(system_status->table_hub.table_hub_specific.volume);
}



void consoleWidget::slot_sendUsbAudioSrc()
{
	tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];
	
	if(!serialPortPtr->isConnected())
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
		return;
	}
	
	if(usbRadioButtons[0]==qobject_cast<QRadioButton*>(sender()))
		cmd_gen_usb_audio_src(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID, USB_SRC_TABLE_HUB, &command); 
	else if(usbRadioButtons[1]==qobject_cast<QRadioButton*>(sender()))
		cmd_gen_usb_audio_src(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID, USB_SRC_TV_HUB, &command); 
	else if(usbRadioButtons[2]==qobject_cast<QRadioButton*>(sender()))
	{
		cmd_gen_usb_audio_src(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID, USB_SRC_DEBUG, &command); 	
		generatePacket((uint8_t*)sendBuf, &command);
		serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
		cmd_gen_ch_to_play(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID, playChBox->value(),&command);
	}
	else if(usbRadioButtons[3]==qobject_cast<QRadioButton*>(sender()))
		cmd_gen_usb_audio_src(DEFAULT_TABLE_HUB_ID,DEFAULT_PC_ID, USB_SRC_SINEWAVE, &command); 	

	generatePacket((uint8_t*)sendBuf, &command);
	serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
}


void consoleWidget::slot_sendSignalGenerator(int sgn)
{
	tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];
	uint8_t sgn_send = sgn;
	cmd_gen_set_signal_gen(0,DEFAULT_PC_ID,sgn_send,&command);
	generatePacket((uint8_t*)sendBuf, &command);
	serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
}

//void consoleWidget::slot_volumeChanged(int val)
//{
//	tdm_command_t command;
//	char sendBuf[MAX_PACKET_LEN];
//	volumeLbl->setText("Volume: " +QString::number(val));
//	uint8_t valAux = val;
//	cmd_gen_set_volume(0, DEFAULT_PC_ID,valAux,&command);
//	int res = generatePacket((uint8_t*)sendBuf, &command);
//	serialPortPtr->sendBuffer((quint8*)sendBuf, res);
//}
