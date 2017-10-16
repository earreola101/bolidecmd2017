#ifndef EC_LOG_WIDGET_H
#define EC_LOG_WIDGET_H

#include "bdDefineAudioProc.h"
#include "bdGroupBox.h"

// QT includes
#include <QtWidgets/qlayout.h>
#include <QtWidgets/qwidget.h>
#include <QtWidgets/qgroupbox.h>
#include <QtWidgets/qlabel.h>
#include <qlineedit.h>
#include "qformlayout.h"
#include "qpushbutton.h"
#include "bdSerialPort.h"
#include "qcombobox.h"
#include "qmessagebox.h"
#include <qplaintextedit.h>
#include "qstringlist.h"

class ecLogWidget : public bdGroupBox
{
	Q_OBJECT

public:
	ecLogWidget(system_status_t *status, QWidget *parent = 0);

public slots:
    void slot_updateList();
    void slot_addLog(int sender, QString log);

private:

    system_status_t *sys_status;

	// Main Layout
    QVBoxLayout *mainVLayout;
    QFormLayout *mainFormLayout;

    QHBoxLayout *filterHLayout;
    QLabel *filterLabel;
    QComboBox *filterComboBox;
    QPlainTextEdit *consoleTextEdit;
    QPushButton *clearConsoleButton;

    QStringList filterList;
    QStringList logList;
    	
    void connectSignals();
    void disconnectSignals();

private slots:
    void slot_filterChanged(const QString sender);
    void slot_clearConsole();
};

#endif // EC_LOG_WIDGET_H