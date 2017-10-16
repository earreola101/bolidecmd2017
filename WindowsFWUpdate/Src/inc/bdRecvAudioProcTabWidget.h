#ifndef BD_RECV_AUDIO_PROC_TAB_WIDGET_H
#define BD_RECV_AUDIO_PROC_TAB_WIDGET_H

// QT includes
#include <QLayout>
#include <QGroupBox>
#include <QList>
#include <QScrollArea>
#include "bdGroupBox.h"
#include "bdLimiterWidget.h"
#include "bdParametricEqualizerWidget.h"
#include "bdHighPassWidget.h"

class bdRecvAudioProcTabWidget : public QWidget
{
	Q_OBJECT

public:
	bdRecvAudioProcTabWidget(bdSerialPort *serialPort, QWidget *parent = 0);

public slots:
    void slot_updateFromStruct(system_status_t *status);

private:
    QVBoxLayout *boxVlayout;
    bdGroupBox *mainGroupBox;
    QGridLayout *boxGridLayout;

    QList<bdGroupBox*> widgetList;

	// High Pass Widget
	bdHighPassWidget *highPassWidget;

	// Parametric Equalizer
	bdParametricEqualizerWidget *parametricEqualizerWidget;

	// Limiter
	bdLimiterWidget *limiterWidget;

};

#endif // BD_RECV_AUDIO_PROC_TAB_WIDGET_H