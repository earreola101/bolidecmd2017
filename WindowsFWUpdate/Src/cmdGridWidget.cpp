#include "cmdGridWidget.h"
#include "command_gen_dec.h"

#define LOOPACK_COMMAND_CHECKBOX 1 // 0 Postfilter - 1 Loopback

cmdGridWidget::cmdGridWidget(bdSerialPort *serialPort, QWidget *parent)
    : QWidget(parent)
{
    serialPortPtr = serialPort;

    memset(&cmd_grid_system_status,0,sizeof(cmd_grid_system_status));

	mainLayout = new QVBoxLayout();
	gridLayout = new QGridLayout();
    
	this->setLayout(mainLayout);
	this->setMinimumWidth(850);
	this->setMinimumHeight(400);
	int rowNumber=1;

	/*Table Header*/
	IDLabel = new QLabel("MicPod ID:");
	IDLabel->setStyleSheet("QLabel { font-weight: bold; }");
	IDLabel->setFixedHeight(18);
	gridLayout->addWidget(IDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		micPodLabels[i]= new QLabel("#");
		micPodLabels[i]->setAlignment(Qt::AlignCenter);
		micPodLabels[i]->setStyleSheet("QLabel {font-weight: bold; }");
		micPodLabels[i]->setFixedHeight(18);
		gridLayout->addWidget(micPodLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* Unique ID */
	uniqueIDLabel = new QLabel("Unique ID:");
	uniqueIDLabel->setFixedHeight(18);
	gridLayout->addWidget(uniqueIDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		uniqueIDLabels[i]= new QLabel("-");
		uniqueIDLabels[i]->setAlignment(Qt::AlignCenter);
		gridLayout->addWidget(uniqueIDLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* Short ID */
	shortIDLabel = new QLabel("Short ID:");
	shortIDLabel->setFixedHeight(18);



	gridLayout->addWidget(shortIDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		shortIDLabels[i]= new QLabel("-");
		shortIDLabels[i]->setAlignment(Qt::AlignCenter);
		gridLayout->addWidget(shortIDLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* CPU Load */
	CPULoadLabel = new QLabel("CPU Load:");
	CPULoadLabel->setFixedHeight(18);
	gridLayout->addWidget(CPULoadLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		micPodCPULabels[i]= new QLabel("-");
		micPodCPULabels[i]->setAlignment(Qt::AlignCenter);
		gridLayout->addWidget(micPodCPULabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/*LED Status ROW*/
	ledStatusLabel = new QLabel("LED Status:");
	gridLayout->addWidget(ledStatusLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		ledStatusButtons[i]= new QPushButton("OFF");
		gridLayout->addWidget(ledStatusButtons[i],rowNumber,i+1);
	}
	rowNumber++;

	/*Mute Channel ROW*/
	muteLabel = new QLabel("Mute:");
	gridLayout->addWidget(muteLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		muteCheckBoxes[i]= new QCheckBox();
		gridLayout->addWidget(muteCheckBoxes[i],rowNumber,i+1);
	}
	rowNumber++;

	/*Post Filter ROW*/
#if LOOPACK_COMMAND_CHECKBOX
	postFilterLabel = new QLabel("Loopback:");
#else
    postFilterLabel = new QLabel("Post Filter:");
#endif
	gridLayout->addWidget(postFilterLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		postFilterCkBoxes[i]= new QCheckBox();
		gridLayout->addWidget(postFilterCkBoxes[i],rowNumber,i+1);
	}
	rowNumber++;
		

	/*Channel Listen ROW*/
	listenLabel = new QLabel("Listen:");
	listenBtnGroup = new QButtonGroup();
	gridLayout->addWidget(listenLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		listenRadioButtons[i]= new QRadioButton();
		listenBtnGroup->addButton(listenRadioButtons[i]);
		gridLayout->addWidget(listenRadioButtons[i],rowNumber,i+1);
	}

	listenRadioButtons[MICPOD_MAX_NUM]= new QRadioButton("automatic");
	listenBtnGroup->addButton(listenRadioButtons[MICPOD_MAX_NUM]);
	gridLayout->addWidget(listenRadioButtons[MICPOD_MAX_NUM],rowNumber,MICPOD_MAX_NUM+1);

	rowNumber++;

	/*Debug device ROW*/
	micDebugLabel = new QLabel("Debug:");
	debugBtnGroup = new QButtonGroup();
	gridLayout->addWidget(micDebugLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		micDebugButtons[i] = new QRadioButton();
		debugBtnGroup->addButton(micDebugButtons[i]);
		gridLayout->addWidget(micDebugButtons[i],rowNumber,i+1);
	}
	
	resetDebugBtn = new QPushButton("Clear");
	gridLayout->addWidget(resetDebugBtn,rowNumber,MICPOD_MAX_NUM+1);

	QWidget *topArea = new QWidget();
	topArea->setLayout(gridLayout);
	topArea->setMaximumWidth(850);
	mainLayout->addWidget(topArea);

	devTreeTextEdit = new QPlainTextEdit();
	mainLayout->addWidget(devTreeTextEdit);

	/*Start Polling for MicPods*/
	//pollMics = new pollMicPodsThread(this);
}

cmdGridWidget::~cmdGridWidget()
{

}


void cmdGridWidget::connectQtSignals()
{
	bool res;

	for(int i=0; i<MICPOD_MAX_NUM; i++)
	{
		res = connect(ledStatusButtons[i],SIGNAL(clicked()),this,SLOT(slot_ledStatusAction()));
		res = connect(muteCheckBoxes[i],SIGNAL(clicked()),this,SLOT(slot_muteAction()));
		res = connect(postFilterCkBoxes[i],SIGNAL(clicked()),this,SLOT(slot_postFilterAction()));
		res = connect(listenRadioButtons[i],SIGNAL(clicked()),this,SLOT(slot_listenAction())); 
		res = connect(micDebugButtons[i],SIGNAL(clicked()),this,SLOT(slot_setMicPodDebug()));			
	}
	res = connect(listenRadioButtons[MICPOD_MAX_NUM],SIGNAL(clicked()),this,SLOT(slot_listenAction())); 
	res = connect(resetDebugBtn,SIGNAL(clicked()),this,SLOT(slot_clearDebug())); 
}

void cmdGridWidget::disconnectQtSignals()
{
    
}

void cmdGridWidget::scanComPort(void)
{

}

system_status_t* cmdGridWidget::getSystemStatus() 
{ 
    return &cmd_grid_system_status; 
}

/*********************************************************
 * SLOTS
 **********************************************************/
 /****************************
  * [SLOT] Start/stop micpod polling thread
 ****************************/
void cmdGridWidget::slot_startStopPolling(bool start)
{
	/*if(start)
		pollMics->start();
	else
		pollMics->stop();*/
}


/******************************************************************
 * [SLOT]	Led ON/OFF Push Button Slot
 ******************************************************************/
void cmdGridWidget::slot_ledStatusAction()
{
	system_status_get_all(&cmd_grid_system_status);
	if(serialPortPtr->isConnected())
	{
		QPushButton *selectedBtn;
	
		int micpodId;
		for(int i=0; i<MICPOD_MAX_NUM; i++)
		{
			if(ledStatusButtons[i] == qobject_cast<QPushButton*>(sender()))
			{
				selectedBtn=ledStatusButtons[i];
				micpodId = cmd_grid_system_status.micpods[i].id;
				break;
			}
		}
	
		command.command=CMD_SET_LED_MICPOD;
		command.sequence=0;
		command.sender=0x77;
		command.receiver=micpodId;
		command.len=2;
		memset(command.data,0,MAX_DATA_LEN);

		int res = QString::compare(selectedBtn->text(), "ON", Qt::CaseInsensitive);
		if(!res)
		{
			selectedBtn->setText("OFF");
			command.data[0]=MICPOD_LED_OFF;
		}
		else
		{
			selectedBtn->setText("ON");
			command.data[0]=MICPOD_LED_ON;
		}

		generatePacket((uint8_t*)sendBuf, &command);
		
		serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
	}
	else
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
	}
}


/******************************************************************
 * [SLOT]	Mute channel checkBox Slot
 ******************************************************************/
void cmdGridWidget::slot_muteAction()
{
	uint8_t micpodId;
	QCheckBox *selectedCheckBox;
	system_status_get_all(&cmd_grid_system_status);
	
	if(serialPortPtr->isConnected())
	{
		for(int i=0; i<MICPOD_MAX_NUM; i++)
		{
			if(muteCheckBoxes[i] == qobject_cast<QCheckBox*>(sender()))
			{
				selectedCheckBox=muteCheckBoxes[i];
				micpodId = cmd_grid_system_status.micpods[i].id;
				break;
			}
		}
	
		uint8_t mute_sts;

		if(selectedCheckBox->isChecked())
			mute_sts=MICPOD_MUTE;
		else
			mute_sts=MICPOD_UNMUTE;

		cmd_gen_set_mute_micpod(micpodId, DEFAULT_PC_ID, mute_sts, &command);		
	
		generatePacket((uint8_t*)sendBuf, &command);
		serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
	}
	else
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);

		selectedCheckBox = qobject_cast<QCheckBox*>(sender());
		selectedCheckBox->setChecked(false);
	}
	
}

/******************************************************************
 * [SLOT]	Post Filter toggle checkBox Slot
 ******************************************************************/
void cmdGridWidget::slot_postFilterAction()
{
	uint8_t micpodId;
	QCheckBox *selectedCheckBox;
	system_status_get_all(&cmd_grid_system_status);
	
	if(serialPortPtr->isConnected())
	{
		for(int i=0; i<MICPOD_MAX_NUM; i++)
		{
			if(postFilterCkBoxes[i] == qobject_cast<QCheckBox*>(sender()))
			{
				selectedCheckBox=postFilterCkBoxes[i];
				micpodId = cmd_grid_system_status.micpods[i].id;
				break;
			}
		}
	
		uint8_t post_filter_sts;

		if(selectedCheckBox->isChecked())
			post_filter_sts=MICPOD_POSTFILTER_ON;
		else
			post_filter_sts=MICPOD_POSTFILTER_OFF;

#if LOOPACK_COMMAND_CHECKBOX
        cmd_gen_set_loopback_en(micpodId, DEFAULT_PC_ID, post_filter_sts, &command);		
#else
		cmd_gen_set_postfilter_en(micpodId, DEFAULT_PC_ID, post_filter_sts, &command);		
#endif
		generatePacket((uint8_t*)sendBuf, &command);
		serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
	}
	else
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);

		selectedCheckBox = qobject_cast<QCheckBox*>(sender());
		selectedCheckBox->setChecked(false);
	}
}

/******************************************************************
 * [SLOT]	Channel listen radio button Slot
 ******************************************************************/
void cmdGridWidget::slot_listenAction()
{

	if(serialPortPtr->isConnected())
	{
		for(int i=0; i<MICPOD_MAX_NUM+1; i++)
		{
			if(listenRadioButtons[i] == qobject_cast<QRadioButton*>(sender()))
			{
				uint8_t listenId=0; 
				if(i!=MICPOD_MAX_NUM)
				{
					listenId = cmd_grid_system_status.micpods[i].id;
				}
				
				cmd_gen_set_listen_micpod(DEFAULT_PC_ID,listenId, &command);
				generatePacket((uint8_t*)sendBuf, &command);
				serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);

				break;
			}
		}
	}
	else
	{
		QRadioButton *selectedRadioBtn;
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
		selectedRadioBtn = qobject_cast<QRadioButton*>(sender());
		selectedRadioBtn->setAutoExclusive(false);
		selectedRadioBtn->setChecked(false);
		selectedRadioBtn->setAutoExclusive(true);
	}
}

void cmdGridWidget::slot_setMicPodDebug()
{
	QRadioButton *selectedRadioBtn;
	uint8_t micpodId;
	uint8_t sendBuf[MAX_PACKET_LEN];
	if(serialPortPtr->isConnected())
	{
		for(int i=0; i<MICPOD_MAX_NUM; i++)
		{
			if(micDebugButtons[i] == qobject_cast<QRadioButton*>(sender()))
			{
				selectedRadioBtn=micDebugButtons[i];
				micpodId = cmd_grid_system_status.micpods[i].id;

				uint8_t debug;
				if(selectedRadioBtn->isChecked())
					debug=MICPOD_DEBUG_ON;
				else
					debug=MICPOD_DEBUG_OFF;

				cmd_gen_set_debug_micpod(DEFAULT_PC_ID, debug, micpodId, &command);
				generatePacket(sendBuf, &command);
				serialPortPtr->sendBuffer((quint8*)sendBuf,  PACKET_OVERHEAD+command.len+COMMAND_OVERHEAD);
				break;
			}
		}
	}
	else
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
		selectedRadioBtn = qobject_cast<QRadioButton*>(sender());
		selectedRadioBtn->setAutoExclusive(false);
		selectedRadioBtn->setChecked(false);
		selectedRadioBtn->setAutoExclusive(true);
	}
}


void cmdGridWidget::slot_clearDebug()
{
	uint8_t sendBuf[MAX_PACKET_LEN];
	if(serialPortPtr->isConnected())
	{
		for(int i=0; i<MICPOD_MAX_NUM; i++)
		{
			micDebugButtons[i]->setAutoExclusive(false);
			micDebugButtons[i]->setChecked(false);
			micDebugButtons[i]->setAutoExclusive(true);
		}
		cmd_gen_set_debug_micpod(DEFAULT_PC_ID, MICPOD_DEBUG_OFF, DEFAULT_UNINIT_ID, &command);
		generatePacket(sendBuf, &command);
		serialPortPtr->sendBuffer((quint8*)sendBuf,  PACKET_OVERHEAD+command.len+COMMAND_OVERHEAD);
	}
	else
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
		QRadioButton *selectedRadioBtn = qobject_cast<QRadioButton*>(sender());
		selectedRadioBtn->setAutoExclusive(false);
		selectedRadioBtn->setChecked(false);
		selectedRadioBtn->setAutoExclusive(true);
	}
}

generic_device_t * cmdGridWidget::system_status_get_device_addr_from_id(uint8_t id, system_status_t * status)
{
	int i;
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		if(status->micpods[i].id==id)
		{
			if(status->micpods[i].alive>0)
				return &status->micpods[i];
		}
	}
	for(i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		if(status->micpod_hubs[i].id==id)
		{
			if(status->micpod_hubs[i].alive>0)
				return &status->micpod_hubs[i];
		}
	}
	if(status->table_hub.id==id)
	{
		return &status->table_hub;
	}
	if(status->tv_hub.id==id)
	{
		return &status->tv_hub;
	}
	return 0;
}

void cmdGridWidget::system_status_rebuild_dependencies(system_status_t * status)
{
	int i,j;
	uint8_t int_Id;
	for(i=0; i<MICPOD_MAX_N; i++)
	{
		for(j=0; j<3; j++)
		{
			int_Id = status->micpods[i].intId[j];
			status->micpods[i].intDevice[j] = system_status_get_device_addr_from_id(int_Id, status);
		}
		int_Id = status->micpods[i].parentId;
		status->micpods[i].parent = system_status_get_device_addr_from_id(int_Id, status);
	}

	for(i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		for(j=0; j<3; j++)
		{
			int_Id = status->micpod_hubs[i].intId[j];
			status->micpod_hubs[i].intDevice[j] = system_status_get_device_addr_from_id(int_Id, status);
		}
		int_Id = status->micpod_hubs[i].parentId;
		status->micpod_hubs[i].parent = system_status_get_device_addr_from_id(int_Id, status);
	}

	for(j=0; j<3; j++)
	{
		int_Id = status->table_hub.intId[j];
		status->table_hub.intDevice[j] = system_status_get_device_addr_from_id(int_Id, status);
	}
	int_Id = status->table_hub.parentId;
	status->table_hub.parent = system_status_get_device_addr_from_id(int_Id, status);

	for(j=0; j<3; j++)
	{
		int_Id = status->tv_hub.intId[j];
		status->tv_hub.intDevice[j] = system_status_get_device_addr_from_id(int_Id, status);
	}
	int_Id = status->tv_hub.parentId;
	status->tv_hub.parent = system_status_get_device_addr_from_id(int_Id, status);
}

void cmdGridWidget::slot_updateMicLabels(system_status_t * sys_status)
{
	QString s;
	memcpy(&cmd_grid_system_status,sys_status, sizeof(system_status_t));

	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		if(cmd_grid_system_status.micpods[i].alive)
		{

			if(cmd_grid_system_status.table_hub.table_hub_specific.listenId==cmd_grid_system_status.micpods[i].id)
				listenRadioButtons[i]->setChecked(true);
			else
				listenRadioButtons[i]->setChecked(false);
		
			s = QString::number(cmd_grid_system_status.micpods[i].id);
			micPodLabels[i]->setText(s);

			if(cmd_grid_system_status.micpods[i].micpod_specific.ledOn)
				ledStatusButtons[i]->setText("ON");
			else
				ledStatusButtons[i]->setText("OFF");

			if(cmd_grid_system_status.micpods[i].micpod_specific.mute)
				muteCheckBoxes[i]->setChecked(true);
			else
				muteCheckBoxes[i]->setChecked(false);

            if(cmd_grid_system_status.micpods[i].micpod_specific.postFilter)
				postFilterCkBoxes[i]->setChecked(true);
			else
				postFilterCkBoxes[i]->setChecked(false);
		
			if(cmd_grid_system_status.micpods[i].debug_mode)
				micDebugButtons[i]->setChecked(true);
			else
			{
				debugBtnGroup->setExclusive(false);
				micDebugButtons[i]->setChecked(false);
				debugBtnGroup->setExclusive(true);
			}


			micPodLabels[i]->setStyleSheet("color: green;font-weight: bold;");
			ledStatusButtons[i]->setEnabled(true);
			muteCheckBoxes[i]->setEnabled(true);
			postFilterCkBoxes[i]->setEnabled(true);
			listenRadioButtons[i]->setEnabled(true);
			micDebugButtons[i]->setEnabled(true);
			micPodCPULabels[i]->setText(QString::number(cmd_grid_system_status.micpods[i].micpod_specific.cpuLoad)+"%");
			uniqueIDLabels[i]->setText("0x"+QString::number(cmd_grid_system_status.micpods[i].dev_info.fpga_unique_id,16));
			
			
			QString shrtId = shortIdClass.getShortID(cmd_grid_system_status.micpods[i].dev_info.fpga_unique_id);
				
				//shortIdMap[cmd_grid_system_status.micpods[i].dev_info.fpga_unique_id];
			if(shrtId.length()>0)
				shortIDLabels[i]->setText(shrtId);
			else
				shortIDLabels[i]->setText("Unmapped ID");

		}
		else
		{
			micPodLabels[i]->setStyleSheet("color: red; font-weight: bold;");
			ledStatusButtons[i]->setEnabled(false);
			muteCheckBoxes[i]->setEnabled(false);
			postFilterCkBoxes[i]->setEnabled(false);
			listenRadioButtons[i]->setEnabled(false);
			micPodCPULabels[i]->setText("-");
			uniqueIDLabels[i]->setText("-");
			shortIDLabels[i]->setText("-");
			micDebugButtons[i]->setEnabled(false);
		}
	}
}


void cmdGridWidget::slot_updateCpu(int id, int cpu)
{
	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		if(cmd_grid_system_status.micpods[i].id == id)
		{
			micPodCPULabels[i]->setText(QString::number(cpu)+"%");
			break;
		}
	}
}

void cmdGridWidget::append_single_device(generic_device_t * device, QString tabs)
{
	QString fontColor;
	QString typeS;
	QString idS;
	if(device->type==TABLE_HUB_DEVICE_TYPE)
	{
		fontColor = "<font color=blue>";
		typeS = "<b>Table HUB</b> ";
	}
	else if(device->type==MICPOD_DEVICE_TYPE)
	{
		fontColor = "<font color=green>";
		typeS = "<b>Micpod</b> ";
	}
	else if(device->type==MICPOD_HUB_DEVICE_TYPE)
	{
		fontColor = "<font color=purple>";
		typeS = "<b>Micpod HUB</b> ";
	}
	else if(device->type==TV_HUB_DEVICE_TYPE)
	{
		fontColor = "<font color=orange>";
		typeS = "<b>TV HUB</b> ";
	}

	QString shrtId = shortIdClass.getShortID(device->dev_info.fpga_unique_id);
		//shortIdMap[device->dev_info.fpga_unique_id];
	if(shrtId.length()>0)
		idS = ", short_id: "+ shrtId;
	else
		idS = ", unique_id: 0x"+ QString::number(device->dev_info.fpga_unique_id,16);
	
	
	devTreeTextEdit->appendHtml(fontColor + tabs + typeS +QString::number(device->id)+ idS +"</font><br/>");

	for(int i=0; i<ROUTING_TABLE_LEN_BYTES; i++)
	{
		if(device->audio_tag[i]!=AUDIO_TAG_INVALID)
		{

			switch (device->audio_tag[i])
			{
				case(AUDIO_TAG_SOUT):
					devTreeTextEdit->appendHtml(fontColor+tabs+"CH "+QString::number(i)+": SOUT "+QString::number(device->audio_id[i])+" : ["+QString::number(device->audio_table[i])+"]</font>");
					break;													 
				case(AUDIO_TAG_SIN0):										 
					devTreeTextEdit->appendHtml(fontColor+tabs+"CH "+QString::number(i)+": MIC2   0° "+QString::number(device->audio_id[i])+" : ["+QString::number(device->audio_table[i])+"]</font>");
					break;													 
				case(AUDIO_TAG_SIN1):										 
					devTreeTextEdit->appendHtml(fontColor+tabs+"CH "+QString::number(i)+": MIC1  90° "+QString::number(device->audio_id[i])+" : ["+QString::number(device->audio_table[i])+"]</font>");
					break;													 
				case(AUDIO_TAG_SIN2):										 
					devTreeTextEdit->appendHtml(fontColor+tabs+"CH "+QString::number(i)+": MIC4 180° "+QString::number(device->audio_id[i])+" : ["+QString::number(device->audio_table[i])+"]</font>");
					break;													 
				case(AUDIO_TAG_SIN3):										 
					devTreeTextEdit->appendHtml(fontColor+tabs+"CH "+QString::number(i)+": MIC3 270° "+QString::number(device->audio_id[i])+" : ["+QString::number(device->audio_table[i])+"]</font>");
					break;													 
				case(AUDIO_TAG_ROUT):										 
					devTreeTextEdit->appendHtml(fontColor+tabs+"CH "+QString::number(i)+": SPK "+QString::number(device->audio_id[i])+" : ["+QString::number(device->audio_table[i])+"]</font>");
					break;													 
				case(AUDIO_TAG_SPK_L):										 
					devTreeTextEdit->appendHtml(fontColor+tabs+"CH "+QString::number(i)+": SPK_IN_L "+QString::number(device->audio_id[i])+" : ["+QString::number(device->audio_table[i])+"]</font>");
					break;													 
				case(AUDIO_TAG_SPK_R):										 
					devTreeTextEdit->appendHtml(fontColor+tabs+"CH "+QString::number(i)+": SPK_IN_R "+QString::number(device->audio_id[i])+" : ["+QString::number(device->audio_table[i])+"]</font>");
					break;
				default:
					devTreeTextEdit->appendHtml("Unknown");
			}
		}
	}
}

void cmdGridWidget::append_child_device_tree(generic_device_t * device, int tabNum)
{
	int i=0,j=0;
	QString tabs="";

	for(j=0; j<tabNum; j++)
		tabs+="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	append_single_device(device,tabs);
	for(i=0; i<device->int_num; i++)
	{
		if(device->intDevice[i]!=0)
		{
			if(device->type==TABLE_HUB_DEVICE_TYPE)
				devTreeTextEdit->appendHtml("<font color=blue>"+tabs+"Interface "+QString::number(i)+"</font><br/>");
			else if(device->type==MICPOD_DEVICE_TYPE)
				devTreeTextEdit->appendHtml("<font color=green>"+tabs+"Interface "+QString::number(i)+"</font><br/>");
			else if(device->type==MICPOD_HUB_DEVICE_TYPE)
				devTreeTextEdit->appendHtml("<font color=purple>"+tabs+"Interface "+QString::number(i)+"</font><br/>");
			else if(device->type==TV_HUB_DEVICE_TYPE)
				devTreeTextEdit->appendHtml("<font color=orange>"+tabs+"Interface "+QString::number(i)+"</font><br/>");

			append_child_device_tree(device->intDevice[i],tabNum+1);
		}
	}
}


void cmdGridWidget::slot_printDeviceTree(system_status_t * sys_status)
{
	memcpy(&cmd_grid_system_status,sys_status, sizeof(system_status_t));
	devTreeTextEdit->clear();
	devTreeTextEdit->appendHtml("<br/><b> Device tree </b><br/><br/>");
	append_child_device_tree(&cmd_grid_system_status.table_hub,0);
	devTreeTextEdit->appendHtml("<br/><b> End </b><br/>");
}

void pollMicPodsThread::run()
{
	/*uint8_t sendBuf[MAX_PACKET_LEN];
	tdm_command_t command;
	while(!exitThread)
	{
		cmd_gen_get_sys_status(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, &command);
		generatePacket(sendBuf, &command);
		cmdWidget->serialPortPtr->sendBuffer((quint8*)sendBuf,  PACKET_OVERHEAD+command.len+COMMAND_OVERHEAD);
		msleep(SYSTEM_POLL_INTERVAL_MS);
	}*/
}
