#include "ecCommandWidget.h"
#include "status.h"
#include "command_gen_dec.h"
#include "command_parser.h"

#define RECEIVER_MICPOD_BROADCAST   "MicPod BroadCast"
#define RECEIVER_MICPOD(x)          QString("MicPod %1").arg(x)
#define RECEIVER_TABLE_HUB                "TableHub"

ecCommandWidget::ecCommandWidget(bdSerialPort *serialPort, system_status_t *status, QWidget *parent) 
	: bdGroupBox(parent)
{
    sys_status = status;
    serialPortPtr = serialPort;

    // GroupBox Option
	this->setTitle("Send EC Commands");

	// Main Layout
    mainHLayout = new QHBoxLayout();

    sendCmdStringLineEdit = new QLineEdit();
    sendCmdStringLineEdit->setPlaceholderText("command string");

	sendCmdStringButton = new QPushButton("Send Command");

    receiverComboBox = new QComboBox();

    receiverComboBox->setFixedWidth(130);

	mainHLayout->addWidget(sendCmdStringLineEdit);
    mainHLayout->addWidget(sendCmdStringButton);
    mainHLayout->addWidget(receiverComboBox);

    mainHLayout->addSpacerItem(new QSpacerItem(0,0,QSizePolicy::Expanding,QSizePolicy::Minimum));
	this->setLayout(mainHLayout);

	// Connect Qt Signal
	connectSignals();

    slot_updateList();
}

/******************************************************************
 * Connect QT Signals
 ******************************************************************/
void ecCommandWidget::connectSignals()
{
	bool res = connect(sendCmdStringButton,SIGNAL(clicked()),this,SLOT(slot_sendCmdStringSlot()));
    res = connect(sendCmdStringLineEdit, SIGNAL(returnPressed()),this,SLOT(slot_sendCmdStringSlot()));
}

/******************************************************************
 * Disconnect QT Signals
 ******************************************************************/
void ecCommandWidget::disconnectSignals()
{
    disconnect(sendCmdStringButton,SIGNAL(clicked()),this,SLOT(slot_sendCmdStringSlot()));
    disconnect(sendCmdStringLineEdit, SIGNAL(returnPressed()),this,SLOT(slot_sendCmdStringSlot()));
}


/******************************************************************
 * [SLOT] Update list
 ******************************************************************/
void ecCommandWidget::slot_updateList()
{
    QString curTex = receiverComboBox->currentText();

    recvList.clear();
    bool atLeastOneMicPodAvail = false;
    for(int i=0;i<MICPOD_MAX_N;i++)
    {
        QString micPod = RECEIVER_MICPOD(sys_status->micpods[i].id);
        if(sys_status->micpods[i].alive)
        {
            if(!recvList.contains(micPod))
                recvList.append(micPod);
            atLeastOneMicPodAvail =true;
        }
    }
    if(atLeastOneMicPodAvail)
        recvList.prepend(RECEIVER_MICPOD_BROADCAST);
    if(sys_status->table_hub.alive)
         recvList.prepend(RECEIVER_TABLE_HUB);
    
    receiverComboBox->clear();
    receiverComboBox->addItems(recvList);

    if(recvList.contains(curTex))
        receiverComboBox->setCurrentText(curTex);
}

/******************************************************************
 * [SLOT] Send Command
 ******************************************************************/
void ecCommandWidget::slot_sendCmdStringSlot()
{
    if(!serialPortPtr->isConnected())
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
		return;
	}

    tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];
    QByteArray ba = sendCmdStringLineEdit->text().toLatin1();
	char *cmdString = ba.data();

    QString curText = receiverComboBox->currentText();
    int receiver = -1;
    if(curText.compare(RECEIVER_TABLE_HUB)==0)
        receiver = DEFAULT_TABLE_HUB_ID;
    else if(curText.compare(RECEIVER_MICPOD_BROADCAST)==0)
            receiver = DEFAULT_BROADCAST_ID;
    else
    {
        QStringList idList = curText.split(RECEIVER_MICPOD(""));
        receiver = idList[1].toInt();
    }

	cmd_gen_debug_msg(DEFAULT_PC_ID,receiver, cmdString, &command);
	generatePacket((uint8_t*)sendBuf, &command);
	bool success = serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
}

