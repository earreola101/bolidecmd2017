#include "bdRecvAudioProcTabWidget.h"
#include <qpalette.h>

bdRecvAudioProcTabWidget::bdRecvAudioProcTabWidget(bdSerialPort *serialPort, QWidget *parent) 
	: QWidget(parent)
{
	mainGroupBox = new bdGroupBox();
	mainGroupBox->setStyleSheet("QGroupBox { font-weight: bold;}");

	mainGroupBox->setTitle("Speaker Process Params");

    boxVlayout = new QVBoxLayout();
    this->setLayout(boxVlayout);
    boxVlayout->addWidget(mainGroupBox);

    boxGridLayout = new QGridLayout();

    // High Pass 
    highPassWidget = new bdHighPassWidget(serialPort);
    widgetList.append(highPassWidget);

	// Parametric Equalizer
	parametricEqualizerWidget = new bdParametricEqualizerWidget(serialPort);
	widgetList.append(parametricEqualizerWidget);

	// Limiter
	limiterWidget = new bdLimiterWidget(serialPort);
    widgetList.append(limiterWidget);

	// Add widget
    boxGridLayout->addWidget(highPassWidget,0,0);
    boxGridLayout->addWidget(parametricEqualizerWidget,1,0);
    boxGridLayout->addWidget(limiterWidget,2,0);

    boxGridLayout->addItem(new QSpacerItem(0,0,QSizePolicy::Minimum,QSizePolicy::Expanding),3,0);
	//boxGridLayout->addItem(new QSpacerItem(0,0,QSizePolicy::Minimum,QSizePolicy::Expanding),3,1);

    mainGroupBox->setLayout(boxGridLayout);
}

void bdRecvAudioProcTabWidget::slot_updateFromStruct(system_status_t *status)
{
    for(int i=0;i<widgetList.count();i++)
        widgetList[i]->updateFromStruct(status);
}

