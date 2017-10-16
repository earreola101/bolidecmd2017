#include "bdLimiterWidget.h"
#include "status.h"
#include "command_gen_dec.h"
#include "command_parser.h"

#include "MCHP_API.hpp"

bdLimiterWidget::bdLimiterWidget(bdSerialPort *serialPort, QWidget *parent) 
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
	this->setTitle(LIMITER_WIDGET_NAME);

	// Enable Box
    QLabel *statusLabel = new QLabel("Limiter Status");
    QFont font;
    font.setBold(true);
    statusLabel->setFont(font);
    mainFormLayout->addRow(statusLabel,enableComboBox);

	// Target RMS value [dB]
	thresholdLevLabel = new QLabel(LIMITER_TH_LEVEL_DB_NAME);
	//thresholdLevLabel->setFixedWidth(LIMITER_TH_LEVEL_DB_LABEL_WIDTH);
	thresholdLevSpinBox = new bdDoubleSpinBox();
	thresholdLevSpinBox->setDecimals(1);
	thresholdLevSpinBox->setMaximum(BD_AP_LIMITER_LEVEL_DB_MAX);
	thresholdLevSpinBox->setMinimum(BD_AP_LIMITER_LEVEL_DB_MIN);
	thresholdLevSpinBox->setAlignment(Qt::AlignRight);
	thresholdLevSpinBox->setFixedSize(LIMITER_BOX_WIDTH,LIMITER_BOX_HEIGHT);

	mainFormLayout->addRow(thresholdLevLabel,thresholdLevSpinBox);

    this->setMaximumHeight(LIMITER_WIDGET_HEIGHT);

	// Connect Qt Signal
	connectSignals();
}

/******************************************************************
 * Connect QT Signals
 ******************************************************************/
void bdLimiterWidget::connectSignals()
{
	// Enable 
	connect(enableComboBox,SIGNAL(currentIndexChanged(QString)),this,SLOT(slot_enableProcess(QString)));
	// Threshold
	connect(thresholdLevSpinBox,SIGNAL(valueChanged(double)),this,SLOT(slot_threshold(double)),Qt::QueuedConnection);
}

/******************************************************************
 * Disconnect QT Signals
 ******************************************************************/
void bdLimiterWidget::disconnectSignals()
{
	// Enable 
	disconnect(enableComboBox,SIGNAL(currentIndexChanged(QString)),this,SLOT(slot_enableProcess(QString)));
	// Threshold
	disconnect(thresholdLevSpinBox,SIGNAL(valueChanged(double)),this,SLOT(slot_threshold(double)));
}

/******************************************************************
 * Update Values From Struct
 ******************************************************************/
void bdLimiterWidget::updateFromStruct(system_status_t *status)
{
	disconnectSignals();

    enableComboBox->setEnableStatus(status->table_hub.table_hub_specific.spp_status.lim_enable);
    setEnableAllWidgets(status->table_hub.table_hub_specific.spp_status.lim_enable);

    thresholdLevSpinBox->setValue(status->table_hub.table_hub_specific.spp_status.lim_threshold);

	connectSignals();
}

/******************************************************************
 * Enable All Widget
 ******************************************************************/
void bdLimiterWidget::setEnableAllWidgets(bool enable)
{
    thresholdLevSpinBox->setEnabled(enable);
    thresholdLevLabel->setEnabled(enable);
}

/************************************************************************************************************************************/

/******************************************************************
 * [Send] Enable Process
 ******************************************************************/
void bdLimiterWidget::slot_enableProcess(QString enable)
{
    int on = (int)enableComboBox->getEnableStatus();

    setEnableAllWidgets(on);
	
    QString cmd("enable");
    cmd.append(QString(" %1").arg(RX_LIMITER_ENABLE));
    cmd.append(QString(" %1").arg(on));

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

/******************************************************************
 * [SLOT] Threshold
 ******************************************************************/
void bdLimiterWidget::slot_threshold(double value)
{       
    QString cmd("rxpeak");
    cmd.append(QString(" %1").arg(value));

     if(!serialPortPtr->isConnected())
        return;

    tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];
    QByteArray ba = cmd.toLatin1();
	char *cmdString = ba.data();
	cmd_gen_debug_msg(DEFAULT_PC_ID,DEFAULT_TABLE_HUB_ID, cmdString, &command); //START REC
	generatePacket((uint8_t*)sendBuf, &command);
	bool success = serialPortPtr->sendBuffer((quint8*)sendBuf, command.len+PACKET_OVERHEAD+COMMAND_OVERHEAD);

    thresholdLevSpinBox->findChild<QLineEdit*>()->deselect();
}