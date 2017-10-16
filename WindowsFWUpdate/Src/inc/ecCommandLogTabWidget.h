#ifndef EC_COMMAND_LOG_TAB_WIDGET_H
#define EC_COMMAND_LOG_TAB_WIDGET_H

// QT includes
#include <QLayout>
#include <QGroupBox>
#include <QList>
#include <QScrollArea>
#include "bdGroupBox.h"
#include "ecCommandWidget.h"
#include "ecLogWidget.h"

class ecCommandLogTabWidget : public QWidget
{
	Q_OBJECT

public:
	ecCommandLogTabWidget(bdSerialPort *serialPort, system_status_t *status, QWidget *parent = 0);

public slots:
    void slot_printOnConsole(int sender, QString string);
    void slot_updateStatus(system_status_t *status);

private:
    QVBoxLayout *mainVLayout;

    QList<bdGroupBox*> widgetList;

    // EC Command Widget
    ecCommandWidget *ecCommandWgt;

    // EC Logs
    ecLogWidget *ecLogWgt;
};

#endif // EC_COMMAND_LOG_TAB_WIDGET_H