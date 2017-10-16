#ifndef BD_HIGH_PASS_WIDGET_H
#define BD_HIGH_PASS_WIDGET_H

#include "bdDefineAudioProc.h"
#include "bdGroupBox.h"

// QT includes
#include <QtWidgets/qlayout.h>
#include <QtWidgets/qwidget.h>
#include <QtWidgets/qgroupbox.h>
#include <QtWidgets/qlabel.h>
#include <QDoubleSpinBox>
#include "qformlayout.h"
#include "bdComboBox.h"
#include "bdSerialPort.h"

class bdHighPassWidget : public bdGroupBox
{
	Q_OBJECT

public:
	bdHighPassWidget(bdSerialPort *serialPort, QWidget *parent = 0);

private:

    bdSerialPort *serialPortPtr;

	// Main Layout
    QHBoxLayout *mainHLayout;
    QFormLayout *mainFormLayout;

	QLabel *hpFcLabel;
	bdComboBox *hpFcComboBox;

    void connectSignals();
    void disconnectSignals();

    // Update all values of the Widget from the struct
	void updateFromStruct(system_status_t *status);

private slots:

	// [SLOT] HP Mode
	void slot_hpMode(int mode);
};

#endif // BD_HIGH_PASS_WIDGET_H