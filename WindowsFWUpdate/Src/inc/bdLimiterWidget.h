#ifndef BD_LIMITER_WIDGET_H
#define BD_LIMITER_WIDGET_H

#include "bdDefineAudioProc.h"
#include "bdGroupBox.h"

// QT includes
#include <QtWidgets/qlayout.h>
#include <QtWidgets/qwidget.h>
#include <QtWidgets/qgroupbox.h>
#include <QtWidgets/qlabel.h>
#include <QDoubleSpinBox>
#include "qformlayout.h"
#include "bdDoubleSpinBox.h"
#include "bdSerialPort.h"

class bdLimiterWidget : public bdGroupBox
{
	Q_OBJECT

public:
	bdLimiterWidget(bdSerialPort *serialPort, QWidget *parent = 0);

private:

    bdSerialPort *serialPortPtr;

	// Main Layout
    QHBoxLayout *mainHLayout;
    QFormLayout *mainFormLayout;

	// Threshold Level value [dB]
	bdDoubleSpinBox *thresholdLevSpinBox;
	QLabel *thresholdLevLabel;

    void connectSignals();
    void disconnectSignals();

    // Update all values of the Widget from the struct
	void updateFromStruct(system_status_t *status);

    void setEnableAllWidgets(bool enable);

private slots:

	// [SLOT] Enable process
	void slot_enableProcess(QString enable);

	// [SLOT] Threshold
	void slot_threshold(double value);
};

#endif // BD_LIMITER_WIDGET_H