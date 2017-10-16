#include "comWidget.h"
#include "command_gen_dec.h"

#define CONNECTED_TO_DEVICE			1
#define DISCONNECTED_FROM_DEVICE	0

comWidget::comWidget(bdSerialPort *serialPort, QWidget *parent)
    : QWidget(parent)
{
    serialPortPtr = serialPort;

    mainGridLayout = new QGridLayout();
    this->setLayout(mainGridLayout);
	this->setMinimumWidth(500);
	
	QPixmap pic("images/bolide.png");
	QLabel * label = new QLabel();
	label->setPixmap(pic);
	mainGridLayout->addWidget(label,0,0);

	// COM Port Label
	comLabel = new QLabel("Select COM port:");
	comLabel->setAlignment(Qt::AlignRight);
	comLabel->setStyleSheet("margin-top: 20px");
	mainGridLayout->addWidget(comLabel,0,1);

	// COM Ports Box
    comComboBox = new QComboBox();
    QStringList comList;
	comList = serialPort->availableDevices();
	comComboBox->addItems(comList);
	comComboBox->setFixedWidth(150);
	comComboBox->setMinimumWidth(100);
    mainGridLayout->addWidget(comComboBox,0,2);
	
    // Open COM Button
    openComButton = new QPushButton("Open COM");
	openComButton->setFixedWidth(150);
	comComboBox->setMinimumWidth(100);
	mainGridLayout->addWidget(openComButton,0,3);

	connLabel= new QLabel("<b>Disconnected</b>");
	connLabel->setAlignment(Qt::AlignCenter);
	connLabel->setStyleSheet("QLabel { background-color : red;}");
	connLabel->setFixedHeight(20);
	connLabel->setFixedWidth(90);
	mainGridLayout->addWidget(connLabel,0,4);

	comPortOpen = false;
	tableHubAliveCnt = 0;
	checkAliveThreadPtr = new checkAliveThread(this);
	checkAliveThreadPtr->start();
}

comWidget::~comWidget()
{
    checkAliveThreadPtr->stop();
}


void comWidget::connectQtSignals()
{
	bool res = connect(openComButton,SIGNAL(clicked()),this,SLOT(slot_openComButton()));
	if(!res)
		return;	//error connecting signals
	connect(checkAliveThreadPtr,SIGNAL(signal_setHubConnection(bool)),this,SLOT(slot_setHubConnection(bool)));
	if(!res)
		return;	//error connecting signals
}


void comWidget::disconnectQtSignals()
{
    
}

void comWidget::setResetCnt(int val)
{
	tableHubAliveCnt = val;
}

int comWidget::getResetCnt()
{
	return tableHubAliveCnt;
}

void comWidget::slot_setHubConnection(bool connected)
{
	if(connected)
	{
		connLabel->setStyleSheet("QLabel { background-color : #00CC00;}");
		connLabel->setText("<b>Connected</b>");
	}
	else
	{
		connLabel->setStyleSheet("QLabel { background-color : red;}");
		connLabel->setText("<b>Disconnected</b>");
	}
}

/*********************************************************
 * SLOTS
 **********************************************************

 /****************************
  * [SLOT] Open Com BUTTON
 ****************************/
void comWidget::slot_openComButton()
{
	if(!comPortOpen)
	{
		bool success = serialPortPtr->open(comComboBox->currentText());
		if(success)
		{
			openComButton->setText("Close " + comComboBox->currentText());
			comPortOpen = true;
		}
	}
	else
	{
		serialPortPtr->close();
		openComButton->setText("Open COM");
		comPortOpen = false;
	}
}

void comWidget::slot_resetAliveCnt()
{
	tableHubAliveCnt=TABLE_HUB_RESET_VAL_CNT;
}

void checkAliveThread::run()
{
	uint8_t sendBuf[MAX_PACKET_LEN];
	tdm_command_t command;
	currentConnSts = DISCONNECTED_FROM_DEVICE;

	while(!exitThread)
	{
		if(!comWidgetPtr->serialPortPtr->isConnected())
		{
			currentConnSts = DISCONNECTED_FROM_DEVICE;
			emit signal_setHubConnection(false);
			tableHubAliveCnt=0;
			msleep(100);
			continue;
		}

		tableHubAliveCnt = comWidgetPtr->getResetCnt();
		if(tableHubAliveCnt>0)
			tableHubAliveCnt--;

		if(tableHubAliveCnt==0)
		{
			currentConnSts = DISCONNECTED_FROM_DEVICE;
			emit signal_setHubConnection(false);
		}
		else
		{	
			currentConnSts = CONNECTED_TO_DEVICE;
			emit signal_setHubConnection(true);
		}

		if(currentConnSts == DISCONNECTED_FROM_DEVICE)
		{
			cmd_gen_get_sys_status(DEFAULT_TABLE_HUB_ID, DEFAULT_PC_ID, &command);
			generatePacket(sendBuf, &command);
			
			comWidgetPtr->serialPortPtr->sendBuffer((quint8*)sendBuf,  PACKET_OVERHEAD+command.len+COMMAND_OVERHEAD);
		}
		else
		{
			cmd_gen_poll(DEFAULT_PC_ID, DEFAULT_TABLE_HUB_ID, &command);
			generatePacket(sendBuf, &command);
	
			comWidgetPtr->serialPortPtr->sendBuffer((quint8*)sendBuf,  PACKET_OVERHEAD+command.len+COMMAND_OVERHEAD);
		}

		comWidgetPtr->setResetCnt(tableHubAliveCnt);
		msleep(ALIVE_CHECK_INTERVAL_MS);		
	}
}

