#ifndef CONSOLE_WIDGET_H
#define CONSOLE_WIDGET_H

#include <QtWidgets/QWidget>
#include <qapplication.h>
#include <qgridlayout.h>
#include <qboxlayout.h>
#include <qpushbutton.h>
#include <qradiobutton.h>
#include <qcombobox.h>
#include <qgroupbox.h>
#include <qplaintextedit.h>
#include <qcheckbox.h>
#include <qformlayout.h>
#include <qlineedit.h>
#include <qlabel.h>
#include <qspinbox.h>
#include <qmessagebox.h>
#include <QDebug.h>
#include <QSpacerItem>
#include <QSlider>
#include "bdSerialPort.h"
#include "command_parser.h"
#include "fileLoaderDialog.h"
#include <cstdint>

class consoleWidget : public QWidget
{
    Q_OBJECT

public:
    consoleWidget(bdSerialPort *serialPort, fileLoaderDialog *fileLoader, QWidget *parent = 0);
    ~consoleWidget();

    bdSerialPort *serialPortPtr;
	fileLoaderDialog * fileLoaderPtr;

	void connectQtSignals();
    void disconnectQtSignals();
	
public slots:
    void slot_update(system_status_t * system_status);

private:
	bool sysMute;
	bool recordOn;

	QBoxLayout *mainLayout;
	
	QLabel *muteSysLabel;
	QPushButton *muteSysButton;

	QLabel *downloadFWLabel;
	QPushButton *downloadFWButton;

	QGridLayout *usbLayout;
	QLabel *recordLabel;
	QLineEdit *filePathLineEdit;
	QPushButton *recordStopButton;

	QLabel *tvHubUsbLabel;
	QLabel *tableHubUsbLabel;
	QLabel *playDebugLabel;
	QLabel *sineWaveLabel;
	QRadioButton *usbRadioButtons[4];
	
	QSpinBox * playChBox;

	QButtonGroup *usbBtnGroup;
	QLabel *usbLabel;

	QLabel * signalGenLabel;
	QComboBox * signalGenMenu;

	//QSlider * volumeSlide;
	//QLabel * volumeLbl;
private slots:
	void slot_muteSysSlot();
	void slot_openNewWindow();
	void slot_startStopRecord();
	void slot_sendUsbAudioSrc();
	void slot_sendSignalGenerator(int sgn);
	//void slot_volumeChangsleep_ms(500);ed(int val);
};

#endif // COMMAND_GRID_WIDGET_H
