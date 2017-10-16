#include "bdHighPassWidget.h"
#include "status.h"
#include "command_gen_dec.h"
#include "command_parser.h"

bdHighPassWidget::bdHighPassWidget(bdSerialPort *serialPort, QWidget *parent) 
	: bdGroupBox(parent)
{
    serialPortPtr = serialPort;
	// Main Layout
    mainHLayout = new QHBoxLayout();
    mainFormLayout = new QFormLayout();
    mainHLayout->addLayout(mainFormLayout);
    mainHLayout->addSpacerItem(new QSpacerItem(0,0,QSizePolicy::Expanding,QSizePolicy::Minimum));
	this->setLayout(mainHLayout);

	// GroupBox Option
	this->setTitle(HIGH_PASS_WIDGET_NAME);

	hpFcLabel = new QLabel("Cut-off Frequency [Hz]");
	hpFcComboBox = new bdComboBox();
	QStringList hpFreqList;
	hpFreqList BD_AP_PEQ_HIGH_PASS_MODES_LIST;
	hpFcComboBox->addItems(hpFreqList);

	mainFormLayout->addRow(hpFcLabel,hpFcComboBox);

    this->setMaximumHeight(LIMITER_WIDGET_HEIGHT);

	// Connect Qt Signal
	connectSignals();
}

/******************************************************************
 * Connect QT Signals
 ******************************************************************/
void bdHighPassWidget::connectSignals()
{
	// Enable 
	bool res = connect(hpFcComboBox,SIGNAL(currentIndexChanged(int)),this,SLOT(slot_hpMode(int)));
}

/******************************************************************
 * Disconnect QT Signals
 ******************************************************************/
void bdHighPassWidget::disconnectSignals()
{
    disconnect(hpFcComboBox,SIGNAL(currentIndexChanged(int)),this,SLOT(slot_hpMode(int)));
}

/******************************************************************
 * Update Values From Struct
 ******************************************************************/
void bdHighPassWidget::updateFromStruct(system_status_t *status)
{
	disconnectSignals();

	hpFcComboBox->setCurrentIndex(status->table_hub.table_hub_specific.spp_status.high_pass_mode);

	connectSignals();
}

/************************************************************************************************************************************/

/******************************************************************
 * [Send] Enable Process
 ******************************************************************/
void bdHighPassWidget::slot_hpMode(int mode)
{
    QString cmd("highpass");
    cmd.append(QString(" %1").arg(mode));

    if(!serialPortPtr->isConnected())
        return;

    tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];
    QByteArray ba = cmd.toLatin1();
	char *cmdString = ba.data();
	cmd_gen_debug_msg(DEFAULT_PC_ID,DEFAULT_TABLE_HUB_ID, cmdString, &command); //START REC
	generatePacket((uint8_t*)sendBuf, &command);
	bool success = serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);
}