#include "ecCommandLogTabWidget.h"
#include <qpalette.h>

ecCommandLogTabWidget::ecCommandLogTabWidget(bdSerialPort *serialPort, system_status_t *status, QWidget *parent) 
	: QWidget(parent)
{
       mainVLayout = new QVBoxLayout();
    this->setLayout(mainVLayout);

    
    // EC Command Widget
    ecCommandWgt = new ecCommandWidget(serialPort,status);
    widgetList.append(ecCommandWgt);

    // EC Logs
    ecLogWgt = new ecLogWidget(status);
    widgetList.append(ecLogWgt);

	// Add widget
    mainVLayout->addWidget(ecCommandWgt);
    mainVLayout->addWidget(ecLogWgt);

   // mainVLayout->addSpacerItem(new QSpacerItem(0,0,QSizePolicy::Minimum,QSizePolicy::Expanding));
}

void ecCommandLogTabWidget::slot_printOnConsole(int sender, QString string)
{
    ecLogWgt->slot_addLog(sender,string);
}

void ecCommandLogTabWidget::slot_updateStatus(system_status_t *status)
{
    ecCommandWgt->slot_updateList();
    ecLogWgt->slot_updateList();
}

