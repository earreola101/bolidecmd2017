#ifndef DEBUG_WIDGET_H
#define DEBUG_WIDGET_H

#include <QtWidgets/QWidget>
#include <qapplication.h>
#include <qgridlayout.h>
#include <qboxlayout.h>
#include <qpushbutton.h>
#include <qradiobutton.h>
#include <qcombobox.h>
#include <qgroupbox.h>
#include <qcheckbox.h>
#include <qformlayout.h>
#include <qlineedit.h>
#include <qlabel.h>
#include <qmessagebox.h>
#include <QDebug.h>
#include <QSpacerItem>
#include "bdSerialPort.h"
#include "status.h"
#include "command_parser.h"
#include <cstdint>

#define CMD_BYTES_DISPLAYED_N	21 //(5+16)
#define DEFAULT_BYTE_CELL_SIZE	20
#define ROW_1_CELL_N			5
#define OTHER_ROWS_CELL_N		4
#define OTHER_ROWS_N			4
#define DEBUG_CMD_BYTES			(OTHER_ROWS_N*OTHER_ROWS_CELL_N)

#define CMD_LABEL_1		"Default template"
#define CMD_LABEL_LED	"Set MicPod LED"

class debugWidget : public QWidget
{
    Q_OBJECT

public:
    debugWidget(bdSerialPort *serialPort, QWidget *parent = 0);
    ~debugWidget();

    bdSerialPort *serialPortPtr;
	
	QGroupBox * cmdHeadGroupBox;
	QGroupBox * cmdPayloadGroupBox;
	
	QBoxLayout *mainLayout;
	QFormLayout *headerLayout;
	QFormLayout *payloadLayout;
    
	QLabel *selectCmdLabel;
	QComboBox * selectCmdComboBox;
	QPushButton *sendCmdButton;

    void connectQtSignals();
    void disconnectQtSignals();

private:
	QLineEdit *cmdFields[CMD_BYTES_DISPLAYED_N];
	QStringList get_commandList();

private slots:
	void slot_setCmdTemplate(const QString);
	void slot_sendCmdTemplate();
};

#endif // COMMAND_GRID_WIDGET_H
