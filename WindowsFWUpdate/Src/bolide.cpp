#include "bolide.h"
#include "command_queue.h"
#include "command_parser.h"
#include "command_gen_dec.h"


Bolide::Bolide(QWidget *parent)
    : QMainWindow(parent)
{
    QIcon icon("images/bolide.ico");
	this->setWindowIcon(icon);
	
	// Serial Port
    serialPort = new bdSerialPort();

	cmdGridW = new cmdGridWidget(serialPort);
	cmdGridW->connectQtSignals();
	
	fileLoaderPtr = new fileLoaderDialog(serialPort, &ackStruct);
	fileLoaderPtr->connectQtSignals();

	comW = new comWidget(serialPort);
	comW->connectQtSignals();
	comW->setFixedHeight(80);

	debugW = new debugWidget(serialPort);
	debugW->connectQtSignals();

	consoleW = new consoleWidget(serialPort,fileLoaderPtr);
	consoleW->connectQtSignals();

	updateTrackingPtr = new updateTrackingDialog(serialPort);
	updateTrackingPtr->connectQtSignals();

	fwUpdateW = new fwUpdateWidget(serialPort,updateTrackingPtr);
	fwUpdateW->connectQtSignals();

    // Speaker Process Tab
    recvAudioProcTab = new bdRecvAudioProcTabWidget(serialPort);

    ecCommandLogTab = new ecCommandLogTabWidget(serialPort,cmdGridW->getSystemStatus());

	aboutWidget = new bdAboutWidget();
	
	recvTh = new recvThread(serialPort, &ackStruct);
	bool res = QThread::connect(recvTh,SIGNAL(finished()), recvTh, SLOT(deleteLater()));
	recvTh->start();

	res = QThread::connect(recvTh, SIGNAL(signal_updateConsole(int,QString)), ecCommandLogTab, SLOT(slot_printOnConsole(int,QString)));
	if(!res)
		return;	//error connecting signals
	res = QThread::connect(recvTh, SIGNAL(signal_updateProgressPerc(int)), updateTrackingPtr, SLOT(slot_updateProgressPerc(int)));
	if(!res)
		return;	//error connecting signals
	res = QThread::connect(recvTh, SIGNAL(signal_updateProgressInfo(char *)), updateTrackingPtr, SLOT(slot_updateProgressInfo(char *)));
	if(!res)
		return;	//error connecting signals
	res = QThread::connect(recvTh, SIGNAL(signal_flashUpdateComplete(bool)), updateTrackingPtr, SLOT(slot_flashUpdateComplete(bool)));
	if(!res)
		return;	//error connecting signals
	res = QThread::connect(serialPort, SIGNAL(signal_startPollingMicpods(bool)), cmdGridW, SLOT(slot_startStopPolling(bool)));
	if(!res)
		return;	//error connecting signals
	res = QThread::connect(recvTh, SIGNAL(signal_resetAliveHubCnt()), comW, SLOT(slot_resetAliveCnt()));
	if(!res)
		return;	//error connecting signals
	res = QThread::connect(recvTh, SIGNAL(signal_tooManyDevError(int)), this, SLOT(slot_tooManyDevError(int)));
	if(!res)
		return;	//error connecting signals
    res = QThread::connect(recvTh, SIGNAL(signal_devStatusRefresh(system_status_t *)), this, SLOT(slot_devStatusRefresh(system_status_t *)));
	if(!res)
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Signal not connected");
		messageBox.setFixedSize(100,100);
	}
      

	res = QThread::connect(recvTh, SIGNAL(signal_updateCpu(int, int)), cmdGridW, SLOT(slot_updateCpu(int, int)));
	if(!res)
		return;	//error connecting signals
	
	QGroupBox *centralGroup = new QGroupBox();
	QBoxLayout *centralWLayout = new QVBoxLayout();
	QBoxLayout *centralBottomLayout = new QHBoxLayout();
	
	mainTabWidget = new QTabWidget();
	mainTabWidget->addTab(cmdGridW, "Basic control");
	mainTabWidget->addTab(fwUpdateW, "FW Update");
	//mainTabWidget->addTab(debugW, "Debug Panel");
    mainTabWidget->addTab(recvAudioProcTab, "Speaker Process");
	mainTabWidget->addTab(ecCommandLogTab, "EC - Commands/Logs");
	consoleW->setMaximumWidth(300);

 
  
  

	centralBottomLayout->addWidget(mainTabWidget);
	centralBottomLayout->addWidget(consoleW);

	QWidget *centralBottomW = new QWidget();
	centralBottomW->setLayout(centralBottomLayout);
	
	centralWLayout->addWidget(comW);
	centralWLayout->addWidget(centralBottomW);
	
	centralGroup->setLayout(centralWLayout);

	pMenuBar = new QMenuBar();
	infoMenu = new QMenu("File");
	pMenuBar->addMenu(infoMenu);
	aboutAction = new QAction("About", this);
	res = QObject::connect(aboutAction, SIGNAL(triggered()),aboutWidget,SLOT(show()));
	infoMenu->addAction(aboutAction);
	
	setMenuWidget(pMenuBar);
    setCentralWidget(centralGroup);
	

	this->setWindowTitle("Bolide GUI");
}

Bolide::~Bolide()
{

}

void Bolide::slot_devStatusRefresh(system_status_t *sys_status)
{
    cmdGridW->slot_updateMicLabels(sys_status);
    cmdGridW->slot_printDeviceTree(sys_status);
    fwUpdateW->slot_updateMicPodLabels(sys_status);
    fwUpdateW->slot_updateMicPodHUBLabels(sys_status);
    fwUpdateW->slot_updateTableHUBLabels(sys_status);
    fwUpdateW->slot_updateTVHUBLabels(sys_status);
    consoleW->slot_update(sys_status);
    recvAudioProcTab->slot_updateFromStruct(sys_status);
    ecCommandLogTab->slot_updateStatus(sys_status);
}

void Bolide::slot_tooManyDevError(int devType)
{
	QMessageBox messageBox;
	switch(devType)
	{
		case MICPOD_DEVICE_TYPE:
		{
			messageBox.information(0,"Error!","Too many MicPods connected! Please remove the blinking one.");
			break;
		}
		case TV_HUB_DEVICE_TYPE:
		{
			messageBox.information(0,"Error!","Too many TV HUBs connected! Please remove at least one.");
			break;		
		}
		case TABLE_HUB_DEVICE_TYPE:
		{
			messageBox.information(0,"Error!","Too many Table HUBs connected! Please remove at least one.");
			break;	
		}
		case MICPOD_HUB_DEVICE_TYPE:
		{
			messageBox.information(0,"Error!","Too many Micpod HUBs connected! Please remove at least one.");
			break;
		}
		case STM32_DEVICE_TYPE:
		case PC_DEVICE_TYPE:
		default:
		{
			break;			
		}
	}
	messageBox.setFixedSize(100,100);
}


/******************************************************************
 * RECV Thread
 ******************************************************************/
void recvThread::run()
{
	indexW=0;indexR=0;
	int diff;
	uint8_t devCount = 0;
	generic_device_t dev;
	system_status_t system_status;
	
	command_queue_init(&queue);
	system_status_init(&queue);

	while(!exitThread)
	{
		int auxIndexW = indexW;
		if(!serialPortPtr->isConnected())
		{
			msleep(10);
			continue;
		}
		//int recvBytes = serialPortPtr->recvBuffer((quint8*)&recvBuf[auxIndexW], 1);
		//if(recvBytes)
		//{
		//	auxIndexW++;
		//	if(auxIndexW>=RX_QUEUE_LEN)
		//		auxIndexW=0;
		//	indexW = auxIndexW;			
		//	int packet = decodePacket((uint8_t*)recvBuf,&indexW,&indexR,&queue);
		//}
				
		if(command_queue_getAvailableCmds(&queue))
		{
			tdm_command_t cmd;
			command_queue_getCmd(&queue, &cmd,0);
			
			emit signal_resetAliveHubCnt();

			switch(cmd.command)
			{
				case CMD_FW_DOWNL_ACK_START:
				case CMD_FW_UPDATE_ACK_FILE:
				{
					ackStruct->ackStatus = ACK_OK;
					ackStruct->waitAckSem.release();
					break;
				}
				case CMD_FW_DOWNL_NACK_START:
					//TODO: annullare FW update
					break;
				case CMD_FW_UPDATE_NACK_PACKET:
				{
					ackStruct->nackWait=true;
					ackStruct->rollBackSeqN = ackStruct->seqNum;
					diff = ackStruct->rollBackSeqN - cmd.sequence;
					ackStruct->rollBackBytes = diff*FW_UPDATE_PKT_SIZE;
					ackStruct->nackWait=false;
					break;
				}
				case CMD_FW_UPDATE_ACK_START:
				{
					char label[] = "Update started...";
					emit signal_updateProgressInfo(label);
					break;
				}
				case CMD_FW_UPDATE_NACK_START:
					break;
				case CMD_FW_UPDATE_PERC_FILE:
				{	
					uint8_t perc;
					cmd_dec_fw_file_perc(&perc,&cmd);
					int auxPerc=perc;
					if(perc==100)
						emit signal_updateProgressInfo("Erasing micpod flash...");
					else
						emit signal_updateProgressInfo("Downloading file to micpod...");
					
					emit signal_updateProgressPerc(auxPerc);
					break;
				}
				case CMD_FW_UPDATE_PERC_FLASH:
				{	
					uint8_t perc;
					cmd_dec_fw_file_perc(&perc,&cmd);
					int auxPerc=perc;
					emit signal_updateProgressInfo("Writing micpod flash...");
					emit signal_updateProgressPerc(auxPerc);
					break;
				}
				case CMD_FW_UPDATE_ACK_FLASH:
				{
					emit signal_flashUpdateComplete(true);
					break;
				}
				case CMD_FW_UPDATE_NACK_FLASH:
				{
					emit signal_flashUpdateComplete(false);
					break;
				}
				case CMD_TOO_MANY_DEV_ERROR:
				{
					uint8_t devType;
					cmd_dec_too_many_dev_error(&devType, &cmd);					
					emit signal_tooManyDevError(devType);
					break;
				}
				case CMD_ALIVE:
				{
					break;
				}
				case CMD_DEV_STATUS_ANS:
				{
					cmd_dec_dev_status_ans(&dev, &devCount, &cmd);
					system_status_update_dev_struct(&dev,devCount);
					break;
				}
				case CMD_DEV_STATUS_REFRESH:
				{
					system_status_get_all(&system_status);
                    emit signal_devStatusRefresh(&system_status);
					break;
				}
				case CMD_SEND_DEBUG_MSG:
				{	
					char msgString[MAX_DATA_LEN];
					cmd_dec_debug_msg(msgString,&cmd);
                    QString cmdStr(msgString);
					emit signal_updateConsole(cmd.sender ,cmdStr);
                    break;
				}
				case CMD_SEND_CPU_LOAD:
				{
					uint8_t cpuLoad;
					cmd_dec_cpu_load(&cpuLoad,&cmd);
					uint8_t idMic = cmd.sender;
					emit signal_updateCpu(idMic, cpuLoad);
					
					break;
				}
				default:
					break;
			}
		}
		else
		{	
			
			int recvBytes = serialPortPtr->recvBuffer((quint8*)&recvBuf[auxIndexW], 1);
			if(recvBytes)
			{
				auxIndexW++;
				if(auxIndexW>=RX_QUEUE_LEN)
					auxIndexW=0;
				indexW = auxIndexW;			
				int packet = decodePacket((uint8_t*)recvBuf,&indexW,&indexR,&queue);
			}
			else
			{
				msleep(100);
			}
		}
	}	
}

/******************************************************************
 * SLOT - Start/Stop RECV Thread
 ******************************************************************/
void recvThread::slot_startThread(bool start)
{
	if(start)
		this->start();
	else
		this->stop();
}