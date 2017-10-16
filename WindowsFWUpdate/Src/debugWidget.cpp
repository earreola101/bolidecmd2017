#include "debugWidget.h"

debugWidget::debugWidget(bdSerialPort *serialPort, QWidget *parent)
    : QWidget(parent)
{
    serialPortPtr = serialPort;

    mainLayout = new QHBoxLayout();
	headerLayout = new QFormLayout();
	headerLayout->setLabelAlignment(Qt::AlignRight);

	cmdHeadGroupBox = new QGroupBox();
	cmdPayloadGroupBox = new QGroupBox();
	this->setLayout(mainLayout);
	this->setMinimumWidth(500);

	// Select command Label
	selectCmdLabel = new QLabel("Select command:");
	
	// Command Box
    selectCmdComboBox = new QComboBox();
    QStringList cmdList;
	cmdList = get_commandList();
	
	selectCmdComboBox->addItems(cmdList);
	selectCmdComboBox->setFixedWidth(150);

	headerLayout->addRow(selectCmdLabel, selectCmdComboBox);
	
    // Send command button
    sendCmdButton = new QPushButton("Send");
	sendCmdButton->setFixedWidth(150);
	headerLayout->addWidget(sendCmdButton);

	for(int i=0; i<CMD_BYTES_DISPLAYED_N; i++)
		cmdFields[i] = new QLineEdit();
	
	cmdFields[0]->setInputMask("HH HH");
	cmdFields[0]->setText("");
	cmdFields[0]->setFixedWidth(DEFAULT_BYTE_CELL_SIZE*2);
	cmdFields[0]->setCursorPosition(0);

	QBoxLayout *cmdbytesL = new QHBoxLayout();
	cmdbytesL->addWidget(cmdFields[0]);

	headerLayout->addRow(new QLabel("command:"),cmdFields[0]);

	cmdFields[1]->setInputMask("HH");
	cmdFields[1]->setText("");
	cmdFields[1]->setFixedWidth(DEFAULT_BYTE_CELL_SIZE);
	cmdFields[1]->setCursorPosition(0);

	headerLayout->addRow(new QLabel("sender:"),cmdFields[1]);

	cmdFields[2]->setInputMask("HH");
	cmdFields[2]->setText("");
	cmdFields[2]->setFixedWidth(DEFAULT_BYTE_CELL_SIZE);
	cmdFields[2]->setCursorPosition(0);

	headerLayout->addRow(new QLabel("receiver:"),cmdFields[2]);

	cmdFields[3]->setInputMask("HH HH HH HH");
	cmdFields[3]->setText("");
	cmdFields[3]->setFixedWidth(DEFAULT_BYTE_CELL_SIZE *4);
	cmdFields[3]->setCursorPosition(0);

	headerLayout->addRow(new QLabel("sequence N:"),cmdFields[3]);

	cmdFields[4]->setInputMask("HH HH");
	cmdFields[4]->setText("");
	cmdFields[4]->setFixedWidth(DEFAULT_BYTE_CELL_SIZE *2);
	cmdFields[4]->setCursorPosition(0);

	headerLayout->addRow(new QLabel("data lenght:"),cmdFields[4]);
	
	cmdHeadGroupBox->setLayout(headerLayout);
	
	mainLayout->addWidget(cmdHeadGroupBox);

	int k=5;

	payloadLayout = new QFormLayout();

	QStringList dataLabels;
	dataLabels << QString("data[0..3]");
	dataLabels << QString("data[4..7]");
	dataLabels << QString("data[8..11]");
	dataLabels << QString("data[12..15]");
	
	for(int i=0; i<OTHER_ROWS_N; i++)
	{
		QHBoxLayout * tempLayout = new QHBoxLayout();
		QWidget *container = new QWidget();
		for(int j=0; j<OTHER_ROWS_CELL_N; j++)
		{
			cmdFields[k]->setInputMask("HH");
			cmdFields[k]->setText("");
			cmdFields[k]->setFixedWidth(DEFAULT_BYTE_CELL_SIZE);
			cmdFields[k]->setCursorPosition(0);
			tempLayout->addWidget(cmdFields[k]);//,i,j);
			k++;
		}
		container->setLayout(tempLayout);
		payloadLayout->addRow(dataLabels[i],container);
	}

	cmdPayloadGroupBox->setLayout(payloadLayout);
	cmdPayloadGroupBox->setFixedWidth(300);
	mainLayout->addWidget(cmdPayloadGroupBox);
}

debugWidget::~debugWidget()
{

}


void debugWidget::connectQtSignals()
{
	bool res = connect(selectCmdComboBox,SIGNAL(currentIndexChanged(const QString)),this,SLOT(slot_setCmdTemplate(const QString)));
	res = connect(sendCmdButton,SIGNAL(clicked()),this,SLOT(slot_sendCmdTemplate()));
}

void debugWidget::disconnectQtSignals()
{
    
}

QStringList debugWidget::get_commandList()
{
	QStringList cmdList;
	cmdList << QString(CMD_LABEL_1);
	cmdList << QString(CMD_LABEL_LED);

	return cmdList;
}

/*********************************************************
 * SLOTS
 **********************************************************

 /****************************
  * [SLOT] Update cmd template
 ****************************/
void debugWidget::slot_setCmdTemplate(const QString cmd)
{
	QString s;

	for(int i=0; i<CMD_BYTES_DISPLAYED_N; i++)
		cmdFields[i]->setText("");
	
			
	if(!QString::compare(cmd, CMD_LABEL_1, Qt::CaseSensitive))  // if strings are equal x should return 0
	{
		for(int i=0; i<CMD_BYTES_DISPLAYED_N; i++)
		{
			cmdFields[i]->setText("FF");
		}
	}
	else if(!QString::compare(cmd, CMD_LABEL_LED, Qt::CaseSensitive))
	{
		s.sprintf("%04X", CMD_SET_LED_MICPOD);
		cmdFields[0]->setText(s);

		s.sprintf("%02X", DEFAULT_PC_ID);
		cmdFields[1]->setText(s);

		s.sprintf("%02X", DEFAULT_TABLE_HUB_ID);
		cmdFields[2]->setText(s);
		
		s.sprintf("%08X", 0);
		cmdFields[3]->setText(s);

		s.sprintf("%04X", 2);
		cmdFields[4]->setText(s);

		s.sprintf("%02X", 1);
		cmdFields[5]->setText(s);

		s.sprintf("%02X", 1);
		cmdFields[6]->setText(s);
	}
}

 /****************************
  * [SLOT] Send cmd button
 ****************************/
void debugWidget::slot_sendCmdTemplate()
{
	tdm_command_t command;
	char sendBuf[MAX_PACKET_LEN];

	if(!serialPortPtr->isConnected())
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
		return;
	}
	
	/*Parse COMMAND*/
	QString str = cmdFields[0]->text();
	str.replace( " ", "" );
	bool ok;
	uint16_t parsedValue16 = str.toUInt(&ok, 16);
	if (!ok) {
		QMessageBox messageBox;
		messageBox.information(0,"Error!","Please check the input data.");
		messageBox.setFixedSize(100,100);
		return;
	}
	command.command=parsedValue16;

	/*Parse SENDER*/
	str = cmdFields[1]->text();
	str.replace( " ", "" );
	uint8_t parsedValue8 = str.toUInt(&ok, 16);
	if (!ok) {
		QMessageBox messageBox;
		messageBox.information(0,"Error!","Please check the input data.");
		messageBox.setFixedSize(100,100);
		return;
	}
	command.sender=parsedValue8;

	/*Parse RECEIVER*/
	str = cmdFields[2]->text();
	str.replace( " ", "" );
	parsedValue8 = str.toUInt(&ok, 16);
	if (!ok) {
		QMessageBox messageBox;
		messageBox.information(0,"Error!","Please check the input data.");
		messageBox.setFixedSize(100,100);
		return;
	}
	command.receiver=parsedValue8;

	/*Parse SEQUENCE N*/
	str = cmdFields[3]->text();
	str.replace( " ", "" );
	uint32_t parsedValue32 = str.toUInt(&ok, 16);
	if (!ok) {
		QMessageBox messageBox;
		messageBox.information(0,"Error!","Please check the input data.");
		messageBox.setFixedSize(100,100);
		return;
	}
	command.sequence=parsedValue32;

	/*Parse LENGTH*/
	str = cmdFields[4]->text();
	str.replace( " ", "" );
	parsedValue16 = str.toUInt(&ok, 16);
	if (!ok) {
		QMessageBox messageBox;
		messageBox.information(0,"Error!","Please check the input data.");
		messageBox.setFixedSize(100,100);
		return;
	}
	command.len=parsedValue16;

	if(command.len>DEBUG_CMD_BYTES)
	{
		QMessageBox messageBox;
		messageBox.information(0,"Error!","Your input data len exceed the GUI max allowed size.");
		messageBox.setFixedSize(100,100);
		return;
	}

	memset(command.data, 0, MAX_DATA_LEN);
		
	for(int i=0; i<command.len; i++)
	{
		/*Parse PAYLOAD*/
		str = cmdFields[i+5]->text();
		str.replace( " ", "" );
		parsedValue8 = str.toUInt(&ok, 16);
		if (!ok) {
			QMessageBox messageBox;
			messageBox.information(0,"Error!","Please check the input data.");
			messageBox.setFixedSize(100,100);
			return;
		}
		command.data[i]=parsedValue8;
	}

	generatePacket((uint8_t*)sendBuf, &command);
	serialPortPtr->sendBuffer((quint8*)sendBuf, PACKET_OVERHEAD+command.len+COMMAND_OVERHEAD);
}
