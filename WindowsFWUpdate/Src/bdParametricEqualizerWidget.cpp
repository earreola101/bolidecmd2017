#include "bdParametricEqualizerWidget.h"
#include "status.h"
#include "command_gen_dec.h"
#include "command_parser.h"
#include "MCHP_API.hpp"

#define PEQ_SAMPLE_FREQUENCY 32000
#define PEQ_Q_FACTOR 4.36f

#define SLIDER_GAIN_HEIGHT 22
#define SLIDER_GAIN_WIDTH 40

#define SLIDER_Q_FACTOR_HEIGHT 22

bdParametricEqualizerWidget::bdParametricEqualizerWidget(bdSerialPort *serialPort, QWidget *parent) 
	: bdGroupBox(parent)
{
	QString title = " [Recv]";

    serialPortPtr = serialPort;

	// Number of bands
	numBands = SPP_PEQ_NUM_BANDS-1;

	// Main Layout
    mainVLayout = new QVBoxLayout();
    formLayout = new QFormLayout();
	mainHLayout =  new QHBoxLayout();

    mainVLayout->addLayout(formLayout);
	this->setLayout(mainVLayout);

	peqVLayout = new QVBoxLayout();
	mainVLayout->addLayout(mainHLayout);
    mainHLayout->addLayout(peqVLayout);

    // Enable Box
    QLabel *statusLabel = new QLabel("PEQ Status");
    QFont font;
    font.setBold(true);
    statusLabel->setFont(font);
    formLayout->addRow(statusLabel,enableComboBox);

	// Sliders Layout
	slidersHLayout = new QHBoxLayout();
	peqVLayout->addLayout(slidersHLayout);

	// GroupBox Option
	title.prepend(PARAMETRIC_EQUALIZER_WIDGET_NAME);
	this->setTitle(title);

	// Create Sliders
	createSliders(numBands);

	slidersHLayout->setAlignment(Qt::AlignCenter);

	// Bottom buttons
	bottomHLayout = new QHBoxLayout();
	peqVLayout->addLayout(bottomHLayout);
	
	// Reset gains
	resetGainButton = new QPushButton(PARAMETRIC_EQUALIZER_RESET_GAIN_NAME);
	resetGainButton->setFixedWidth(80);

	connect(resetGainButton,SIGNAL(clicked()),this,SLOT(slot_resetGains()));

	bottomHLayout->addWidget(resetGainButton);
	bottomHLayout->setAlignment(Qt::AlignRight);

	mainHLayout->addSpacerItem(new QSpacerItem(20,0,QSizePolicy::Fixed,QSizePolicy::Fixed));

	// Filter Layour
	filterVLayout = new QVBoxLayout();
	filterVLayout->setSpacing(15);
	mainHLayout->addLayout(filterVLayout);

	// High Shelving
	hshelvGroupBox = new bdGroupBox();
	hshelvGroupBox->setTitle("High Pass Shelving Filter");
	filterVLayout->addWidget(hshelvGroupBox);

	hsFormLayout = new QFormLayout();
	hsFormLayout->setHorizontalSpacing(20);
	hshelvGroupBox->setLayout(hsFormLayout);

	hsFcLabel = new QLabel("Cut-off Frequency [Hz]");
	hsFcSpinBox = new bdSpinBox();
	hsFcSpinBox->setMaximum(PEQ_SAMPLE_FREQUENCY/2);
	hsFcSpinBox->setMinimum(25);
	hsFcSpinBox->setAlignment(Qt::AlignRight);
	hsFormLayout->addRow(hsFcLabel,hsFcSpinBox);
    hsFcSpinBox->setFixedWidth(60);

    hsFcSpinBox->setValue(3400);

	hsGainLabel = new QLabel("Gain [dB]");
	hsGainSpinBox = new bdDoubleSpinBox();
	hsGainSpinBox->setMaximum(BD_AP_PEQ_GAIN_DB_MAX);
	hsGainSpinBox->setMinimum(BD_AP_PEQ_GAIN_DB_MIN);
	hsGainSpinBox->setDecimals(1);
	hsGainSpinBox->setAlignment(Qt::AlignRight);
	hsFormLayout->addRow(hsGainLabel,hsGainSpinBox);

	filterVLayout->addSpacerItem(new QSpacerItem(0,0,QSizePolicy::Minimum,QSizePolicy::Expanding));

	mainHLayout->addSpacerItem(new QSpacerItem(0,0,QSizePolicy::Expanding,QSizePolicy::Minimum));
	//this->setFixedHeight(PARAMETRIC_EQUALIZER_WIDGET_HEIGHT);

	// Connect QT Signals
	connectSignals();
}

/******************************************************************
 * Update Values From Struct
 ******************************************************************/
void bdParametricEqualizerWidget::updateFromStruct(system_status_t *status)
{
	blockSignalsEqSliders(true);
	disconnectSignals();

    hsFcSpinBox->setMaximum(RECV_SAMPLE_FREQUENCY/2-1);
	QList<int> tmpList;
	for(int i=0;i<numBands;i++)
		sliderList[i]->setMaxFreq(RECV_SAMPLE_FREQUENCY/2-1);

	// Update
	for(int i=0;i<numBands;i++)
		sliderList[i]->updateFromStruct(status);

    enableComboBox->setEnableStatus(status->table_hub.table_hub_specific.spp_status.peq_enable);
    setEnableAllWidgets(status->table_hub.table_hub_specific.spp_status.peq_enable);

	// High Shelving
	hsFcSpinBox->setValue(status->table_hub.table_hub_specific.spp_status.peq_frequencies[SPP_PEQ_NUM_BANDS-1]);
	hsGainSpinBox->setValue(status->table_hub.table_hub_specific.spp_status.peq_gains[SPP_PEQ_NUM_BANDS-1]);

	connectSignals();
	blockSignalsEqSliders(false);
}

/******************************************************************
 * Update Sliders
 ******************************************************************/
void bdParametricEqualizerWidget::createSliders(int numBand)
{
	if(!sliderList.isEmpty())
	{
		for(int i=0;i<sliderList.count();i++)
		{
			slidersHLayout->removeWidget(sliderList[i]);
			delete sliderList[i];
		}
		sliderList.clear();
	}
	for(int i=0;i<numBand;i++)
	{
        sliderList.append(new bdPeqSlider(serialPortPtr,i,this));

		slidersHLayout->addWidget(sliderList[i]);
	}

	// Hide Slider
    for(int i=numBand;i<SPP_PEQ_NUM_BANDS-1;i++)
		sliderList[i]->hide();

}

/******************************************************************
 * Block Eq Sliders Signal
 ******************************************************************/
void bdParametricEqualizerWidget::blockSignalsEqSliders(bool block)
{
	for(int i=0;i<sliderList.count();i++)
		sliderList[i]->blockSignals(block);
}

/******************************************************************
 * Connect QT Signals
 ******************************************************************/
void bdParametricEqualizerWidget::connectSignals()
{
	bool res = connect(enableComboBox,SIGNAL(currentIndexChanged(QString)),this,SLOT(slot_enableProcess(QString)));
	// High Shelving
	res = connect(hsFcSpinBox,SIGNAL(valueChanged(int)),this,SLOT(slot_hsFc(int)),Qt::QueuedConnection);
	res = connect(hsGainSpinBox,SIGNAL(valueChanged(double)),this,SLOT(slot_hsGain(double)),Qt::QueuedConnection);
}

/******************************************************************
 * Disconnect QT Signals
 ******************************************************************/
void bdParametricEqualizerWidget::disconnectSignals()
{
	disconnect(enableComboBox,SIGNAL(currentIndexChanged(QString)),this,SLOT(slot_enableProcess(QString)));
	// High Shelving
	disconnect(hsFcSpinBox,SIGNAL(valueChanged(int)),this,SLOT(slot_hsFc(int)));
	disconnect(hsGainSpinBox,SIGNAL(valueChanged(double)),this,SLOT(slot_hsGain(double)));
}

/******************************************************************
 * Enable All Widget
 ******************************************************************/
void bdParametricEqualizerWidget::setEnableAllWidgets(bool enable)
{
    hshelvGroupBox->setEnabled(enable);
    for(int i=0;i<sliderList.count();i++)
        sliderList[i]->setEnabled(enable);
    resetGainButton->setEnabled(enable);
}


/************************************************************************************************************************************/

/******************************************************************
 * [SLOT] Enable Process
 ******************************************************************/
void bdParametricEqualizerWidget::slot_enableProcess(QString enable)
{
    int on = (int)enableComboBox->getEnableStatus();

    setEnableAllWidgets(on);

    QString cmd("enable");
    cmd.append(QString(" %1").arg(RX_PEQ_ENABLE));
    cmd.append(QString(" %1").arg(on));
    
    sendCmd(cmd);
}

/******************************************************************
 * [SLOT] Reset Gains
 ******************************************************************/
void bdParametricEqualizerWidget::slot_resetGains()
{
	for(int i=0;i<sliderList.count();i++)
	{
		sliderList[i]->setGain(0.0f);
        sliderList[i]->slot_gainValue(sliderList[i]->gainValueSpinBox->value());
	}
}

/******************************************************************
 * [SLOT] High Shelving Fc
 ******************************************************************/
void bdParametricEqualizerWidget::slot_hsFc(int fc)
{
    QString cmd("peq");
    cmd.append(QString(" %1").arg(SPP_PEQ_NUM_BANDS-1));
    cmd.append(" hs");
    cmd.append(QString(" %1").arg(fc));
    cmd.append(QString(" %1").arg(1.0f));
    cmd.append(QString(" %1").arg(hsGainSpinBox->value()));

    sendCmd(cmd);

    hsFcSpinBox->findChild<QLineEdit*>()->deselect();
}

/******************************************************************
 * [SLOT] High Shelving Gain
 ******************************************************************/
void bdParametricEqualizerWidget::slot_hsGain(double gain)
{
    QString cmd("peq");
    cmd.append(QString(" %1").arg(SPP_PEQ_NUM_BANDS-1));
    cmd.append(" hs");
    cmd.append(QString(" %1").arg(hsFcSpinBox->value()));
    cmd.append(QString(" %1").arg(1.0f));
    cmd.append(QString(" %1").arg(gain));

    sendCmd(cmd);

    hsGainSpinBox->findChild<QLineEdit*>()->deselect();
}

void bdParametricEqualizerWidget::sendCmd(QString cmd)
{
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

/************************************************************************************************************************************/

/******************************************************************
 * Slider Equalizer
 ******************************************************************/
bdPeqSlider::bdPeqSlider(bdSerialPort *serialPort, int idx, bdParametricEqualizerWidget *peq, QWidget *parent)
	: QWidget(parent)
{
    this->peq = peq;
    
    serialPortPtr = serialPort;

	noBand = idx;

	mainGridLayout = new QGridLayout();
	this->setLayout(mainGridLayout);
	mainGridLayout->setContentsMargins(0,0,0,0);
	
	// Slider
	eqSlider = new QSlider(Qt::Vertical);

	eqSlider->setMaximum(BD_AP_PEQ_GAIN_DB_MAX*10);
	eqSlider->setMinimum(BD_AP_PEQ_GAIN_DB_MIN*10);

	eqSlider->setTickInterval(BD_AP_PEQ_GAIN_DB_MAX*10/2);
	eqSlider->setTickPosition(QSlider::TicksBothSides);

	// Frequency	
	freqValueSpinBox = new bdSpinBox();
	freqValueSpinBox->setAlignment(Qt::AlignHCenter);
	freqValueSpinBox->setButtonSymbols(QAbstractSpinBox::NoButtons);
	freqValueSpinBox->setFixedSize(PARAMETRIC_EQUALIZER_SLIDER_WIDTH,SLIDER_Q_FACTOR_HEIGHT);
	freqValueSpinBox->setMinimum(0);
	freqValueSpinBox->setMaximum(PEQ_SAMPLE_FREQUENCY/2-1);
	freqValueSpinBox->setValue(100*idx);

	// Gain
	gainValueSpinBox = new bdDoubleSpinBox();
	gainValueSpinBox->setAlignment(Qt::AlignHCenter);
	gainValueSpinBox->setFixedSize(SLIDER_GAIN_WIDTH,SLIDER_GAIN_HEIGHT);
	gainValueSpinBox->setDecimals(1);
	gainValueSpinBox->setMaximum(BD_AP_PEQ_GAIN_DB_MAX);
	gainValueSpinBox->setMinimum(BD_AP_PEQ_GAIN_DB_MIN);
	gainValueSpinBox->setButtonSymbols(QAbstractSpinBox::NoButtons);

	gainValueSpinBox->setValue(0);
	eqSlider->setValue(0);

#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
	// Q Factor
	QFactorSpinBox = new bdDoubleSpinBox();
	QFactorSpinBox->setDecimals(2);
	QFactorSpinBox->setMaximum(BD_AP_GEQ_Q_FACT_MAX);
	QFactorSpinBox->setMinimum(BD_AP_GEQ_Q_FACT_MIN);
	QFactorSpinBox->setValue(4.36);
	QFactorSpinBox->setAlignment(Qt::AlignCenter);
	QFactorSpinBox->setButtonSymbols(QAbstractSpinBox::NoButtons);
	QFactorSpinBox->setFixedSize(SLIDER_GAIN_WIDTH,SLIDER_Q_FACTOR_HEIGHT);
    connect(QFactorSpinBox,SIGNAL(valueChanged(double)),this,SLOT(slot_qFactor(double)),Qt::QueuedConnection);
#endif

	// Enable
	enableCheckBox = new QCheckBox();
	 
	// Connect Qt Signals
	bool res = connect(eqSlider,SIGNAL(valueChanged(int)),this,SLOT(slot_sliderValue(int)),Qt::QueuedConnection);
	res = connect(gainValueSpinBox,SIGNAL(valueChanged(double)),this,SLOT(slot_gainValue(double)),Qt::QueuedConnection);
	res = connect(freqValueSpinBox,SIGNAL(valueChanged(int)),this,SLOT(slot_freqValue(int)),Qt::QueuedConnection);
	res = connect(enableCheckBox,SIGNAL(stateChanged(int)),this,SLOT(slot_enable(int)));

	int col = 0;
	int w=0;
	if(idx==0)
	{
		col = 1;
		QString maxGain = QString::number(BD_AP_PEQ_GAIN_DB_MAX,'f',1);
		QString minGain = QString::number(BD_AP_PEQ_GAIN_DB_MIN,'f',1);

		freqLabel = new QLabel();
		freqLabel->setText("Freq [Hz]");
		freqLabel->setAlignment(Qt::AlignRight);

		maxLabel = new QLabel();
		maxLabel->setText(maxGain);
		maxLabel->setAlignment(Qt::AlignRight);

		zeroLabel = new QLabel();
		zeroLabel->setText("0.0");
		zeroLabel->setAlignment(Qt::AlignRight);

		minLabel = new QLabel();
		minLabel->setText(minGain);
		minLabel->setAlignment(Qt::AlignRight);

		gainLabel = new QLabel();
		gainLabel->setText("Gain [dB]");
		gainLabel->setAlignment(Qt::AlignRight);

#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
		QFactorLabel = new QLabel();
		QFactorLabel->setText("Q Factor");
		QFactorLabel->setAlignment(Qt::AlignRight);
#endif
		enableLabel = new QLabel();
		enableLabel->setText("Enable");
		enableLabel->setAlignment(Qt::AlignRight);

		mainGridLayout->addWidget(freqLabel,0,0,Qt::AlignRight | Qt::AlignVCenter);
		mainGridLayout->addWidget(maxLabel,1,0,Qt::AlignRight | Qt::AlignTop);
		mainGridLayout->addWidget(zeroLabel,1,0,Qt::AlignRight | Qt::AlignVCenter);
		mainGridLayout->addWidget(minLabel,1,0,Qt::AlignRight | Qt::AlignBottom);
		mainGridLayout->addWidget(gainLabel,2,0,Qt::AlignRight | Qt::AlignVCenter);
#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
		mainGridLayout->addWidget(QFactorLabel,3,0,Qt::AlignRight | Qt::AlignVCenter);
#endif
		mainGridLayout->addWidget(enableLabel,3,0,Qt::AlignRight | Qt::AlignVCenter);

		w = 59;
	}

	mainGridLayout->addWidget(freqValueSpinBox,0,col,Qt::AlignHCenter);
	mainGridLayout->addWidget(eqSlider,1,col,Qt::AlignHCenter);
	mainGridLayout->addWidget(gainValueSpinBox,2,col,Qt::AlignHCenter);
#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
	mainGridLayout->addWidget(QFactorSpinBox,3,col,Qt::AlignHCenter);
#endif
	mainGridLayout->addWidget(enableCheckBox,3,col,Qt::AlignHCenter);

	mainGridLayout->setVerticalSpacing(5);
	enableCheckBox->setChecked(1);

	// Color
	QPalette palette;
	palette.setColor(QPalette::Normal, QPalette::Highlight, QColor(71,141,205));
	palette.setColor(QPalette::Inactive, QPalette::Highlight, QColor(71,141,205));
	palette.setColor(QPalette::Disabled, QPalette::Highlight, QColor(187,200,213));

	eqSlider->setPalette(palette);

	this->setFixedSize(PARAMETRIC_EQUALIZER_SLIDER_WIDTH+w,PARAMETRIC_EQUALIZER_SLIDER_HEIGHT);
}

/******************************************************************
 * Get Q
 ******************************************************************/
#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
float bdPeqSlider::getQ()
{
	float Q = QFactorSpinBox->value();
	if(Q<BD_AP_GEQ_Q_FACT_MIN)
		Q = BD_AP_GEQ_Q_FACT_MIN;
	return Q;
}
#endif

/******************************************************************
 * Set Enable
 ******************************************************************/
void bdPeqSlider::setEnable(bool on)
{
	enableCheckBox->blockSignals(true);
	enableCheckBox->setChecked(on);
	enableCheckBox->blockSignals(false);

	eqSlider->setEnabled(on);
	freqValueSpinBox->setEnabled(on);
	gainValueSpinBox->setEnabled(on);
#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
	QFactorSpinBox->setEnabled(on);
#endif
}

/******************************************************************
 * Set Frequency
 ******************************************************************/
void bdPeqSlider::setFrequency(int value)
{
	freqValueSpinBox->blockSignals(true);
	freqValueSpinBox->setValue(value);
	freqValueSpinBox->blockSignals(false);
}

/******************************************************************
 * Set Gain
 ******************************************************************/
void bdPeqSlider::setGain(float value)
{
    updateGain(value);
}

/******************************************************************
 * Update Gain
 ******************************************************************/
void bdPeqSlider::updateGain(float value)
{
	gainValueSpinBox->blockSignals(true);
	gainValueSpinBox->setValue(value);
	gainValueSpinBox->blockSignals(false);

	eqSlider->blockSignals(true);
	eqSlider->setValue(value*10);
	eqSlider->blockSignals(false);
}

/******************************************************************
 * Set Q
 ******************************************************************/
#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
void bdPeqSlider::setQ(float Q)
{
	QFactorSpinBox->blockSignals(true);
	QFactorSpinBox->setValue(Q);
	QFactorSpinBox->blockSignals(false);

	peq->peqStruct->Q[noBand] = Q;
}
#endif

/******************************************************************
 * Send Configuration
 ******************************************************************/
void bdPeqSlider::sendConfiguration()
{
   
}

void bdPeqSlider::updateFromStruct(system_status_t *status)
{
    setEnable(status->table_hub.table_hub_specific.spp_status.peq_gains[noBand]!=0.0f);
	setFrequency(status->table_hub.table_hub_specific.spp_status.peq_frequencies[noBand]);
	updateGain(status->table_hub.table_hub_specific.spp_status.peq_gains[noBand]);
}

/************************************************************************************************************************************/

/******************************************************************
 * [SLOT] Slider Value
 ******************************************************************/
void bdPeqSlider::slot_sliderValue(int value) 
{
	float auxValue = ((float)value)/10.0f;
	gainValueSpinBox->setValue(auxValue);
}

/******************************************************************
 * [SLOT] Enable
 ******************************************************************/
void bdPeqSlider::slot_enable(int value)
{
	setEnable(enableCheckBox->isChecked());
    
    if(value)
        slot_gainValue(gainValueSpinBox->value());
    else
    {
        QString cmd("peq");
        cmd.append(QString(" %1").arg(noBand));
        cmd.append(" pb");
        cmd.append(QString(" %1").arg(freqValueSpinBox->value()));
        cmd.append(QString(" %1").arg(PEQ_Q_FACTOR));
        cmd.append(QString(" %1").arg(0.0));

        peq->sendCmd(cmd);
    }
}

/******************************************************************
 * [SLOT] Gain Value
 ******************************************************************/
void bdPeqSlider::slot_gainValue(double value) 
{
	setGain(value);
    
    QString cmd("peq");
    cmd.append(QString(" %1").arg(noBand));
    cmd.append(" pb");
    cmd.append(QString(" %1").arg(freqValueSpinBox->value()));
    cmd.append(QString(" %1").arg(PEQ_Q_FACTOR));
    cmd.append(QString(" %1").arg(gainValueSpinBox->value()));

    peq->sendCmd(cmd);

    gainValueSpinBox->findChild<QLineEdit*>()->deselect();
}


/******************************************************************
 * [SLOT] Frequency Value
 ******************************************************************/
void bdPeqSlider::slot_freqValue(int value) 
{
	setFrequency(value);

    QString cmd("peq");
    cmd.append(QString(" %1").arg(noBand));
    cmd.append(" pb");
    cmd.append(QString(" %1").arg(freqValueSpinBox->value()));
    cmd.append(QString(" %1").arg(PEQ_Q_FACTOR));
    cmd.append(QString(" %1").arg(gainValueSpinBox->value()));

    peq->sendCmd(cmd);

    freqValueSpinBox->findChild<QLineEdit*>()->deselect();
}

#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
/******************************************************************
 * [SLOT] Q Factor
 ******************************************************************/
void bdPeqSlider::slot_qFactor(double value) 
{
	setQ(value);

	sendConfiguration(peq->s2c_mode, peq->middleEndPtr->mainStruct.sampleFrequency);

    peq->checkDefaultDiff();
}
#endif