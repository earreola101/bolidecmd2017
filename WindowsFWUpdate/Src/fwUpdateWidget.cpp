#include "fwUpdateWidget.h"
#include "fw_update_def.h"

fwUpdateWidget::fwUpdateWidget(bdSerialPort *serialPort, updateTrackingDialog *updateTracking, QWidget *parent)
    : QWidget(parent)
{
    serialPortPtr = serialPort;
	updateTrackingPtr = updateTracking;
		
    mainLayout = new QVBoxLayout();
	micpods_gridLayout = new QGridLayout();
	micpod_HUB_gridLayout = new QGridLayout();
	table_HUB_gridLayout = new QGridLayout();
	tv_HUB_gridLayout = new QGridLayout();
    
	

	this->setLayout(mainLayout);
	this->setMaximumWidth(850);
	int rowNumber=1;

/******************************************************************
 * MICPODs
 ******************************************************************/	

	/*Table Header*/
	IDLabel = new QLabel("MicPod ID:");
	IDLabel->setStyleSheet("QLabel { font-weight: bold; }");
	IDLabel->setFixedHeight(18);
	micpods_gridLayout->addWidget(IDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		micPod_IDLabels[i]= new QLabel("#");
		micPod_IDLabels[i]->setAlignment(Qt::AlignCenter);
		micPod_IDLabels[i]->setStyleSheet("QLabel {font-weight: bold; }");
		micPod_IDLabels[i]->setFixedHeight(18);
		micpods_gridLayout->addWidget(micPod_IDLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* Unique ID */
	uniqueIDLabel = new QLabel("Short ID:");
	uniqueIDLabel->setFixedHeight(18);
	micpods_gridLayout->addWidget(uniqueIDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		micPod_UniqueIDLabels[i]= new QLabel("-");
		micPod_UniqueIDLabels[i]->setAlignment(Qt::AlignCenter);
		micpods_gridLayout->addWidget(micPod_UniqueIDLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* SW Version */
	swVersionLabel = new QLabel("SW Version:");
	swVersionLabel->setFixedHeight(18);
	micpods_gridLayout->addWidget(swVersionLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		micPod_swVerLabels[i]= new QLabel("-");
		micPod_swVerLabels[i]->setAlignment(Qt::AlignCenter);
		micpods_gridLayout->addWidget(micPod_swVerLabels[i],rowNumber,i+1);
	}
	micPod_updateAll = new QPushButton("Update All");
	micpods_gridLayout->addWidget(micPod_updateAll,rowNumber,MICPOD_MAX_N+1);

	rowNumber++;

	/* FPGA Version */
	fpgaVersionLabel = new QLabel("FPGA Version:");
	fpgaVersionLabel->setFixedHeight(18);
	micpods_gridLayout->addWidget(fpgaVersionLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		micPod_fpgaVerLabels[i]= new QLabel("-");
		micPod_fpgaVerLabels[i]->setAlignment(Qt::AlignCenter);
		micpods_gridLayout->addWidget(micPod_fpgaVerLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* FPGA ID */
	fpgaIDLabel = new QLabel("FPGA ID:");
	fpgaIDLabel->setFixedHeight(18);
	micpods_gridLayout->addWidget(fpgaIDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		micPod_fpgaIDLabels[i]= new QLabel("-");
		micPod_fpgaIDLabels[i]->setAlignment(Qt::AlignCenter);
		micpods_gridLayout->addWidget(micPod_fpgaIDLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* Update single micpod buttons */
	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		micPod_updtBtn[i]= new QPushButton("Update");
		micpods_gridLayout->addWidget(micPod_updtBtn[i],rowNumber,i+1);
	}
	rowNumber++;
	
	QWidget *topArea = new QWidget();
	topArea->setLayout(micpods_gridLayout);
	topArea->setMaximumHeight(150);
	mainLayout->addWidget(topArea);

/******************************************************************
 * MICPOD HUB
 ******************************************************************/	

	rowNumber=1;

	/*Table Header*/
	micPodHUB_IDLabel = new QLabel("MicPod HUB ID:");
	micPodHUB_IDLabel->setStyleSheet("QLabel { font-weight: bold; }");
	micPodHUB_IDLabel->setFixedHeight(18);
	micpod_HUB_gridLayout->addWidget(micPodHUB_IDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		micPodHUB_IDLabels[i]= new QLabel("#");
		micPodHUB_IDLabels[i]->setAlignment(Qt::AlignCenter);
		micPodHUB_IDLabels[i]->setStyleSheet("QLabel {font-weight: bold; }");
		micPodHUB_IDLabels[i]->setFixedHeight(18);
		micpod_HUB_gridLayout->addWidget(micPodHUB_IDLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* Unique ID */
	micPodHUB_uniqueIDLabel = new QLabel("Short ID:");
	micPodHUB_uniqueIDLabel->setFixedHeight(18);
	micpod_HUB_gridLayout->addWidget(micPodHUB_uniqueIDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		micPodHUB_UniqueIDLabels[i]= new QLabel("-");
		micPodHUB_UniqueIDLabels[i]->setAlignment(Qt::AlignCenter);
		micpod_HUB_gridLayout->addWidget(micPodHUB_UniqueIDLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* SW Version */
	micPodHUB_swVersionLabel = new QLabel("SW Version:");
	micPodHUB_swVersionLabel->setFixedHeight(18);
	micpod_HUB_gridLayout->addWidget(micPodHUB_swVersionLabel,rowNumber,0);
	for(int i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		micPodHUB_swVerLabels[i]= new QLabel("-");
		micPodHUB_swVerLabels[i]->setAlignment(Qt::AlignCenter);
		micpod_HUB_gridLayout->addWidget(micPodHUB_swVerLabels[i],rowNumber,i+1);
	}
	micPodHUB_updateAll = new QPushButton("Update All");
	micpod_HUB_gridLayout->addWidget(micPodHUB_updateAll,rowNumber,MICPOD_HUB_MAX_N+1);
	rowNumber++;

	/* FPGA Version */
	micPodHUB_fpgaVersionLabel = new QLabel("FPGA Version:");
	micPodHUB_fpgaVersionLabel->setFixedHeight(18);
	micpod_HUB_gridLayout->addWidget(micPodHUB_fpgaVersionLabel,rowNumber,0);
	for(int i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		micPodHUB_fpgaVerLabels[i]= new QLabel("-");
		micPodHUB_fpgaVerLabels[i]->setAlignment(Qt::AlignCenter);
		micpod_HUB_gridLayout->addWidget(micPodHUB_fpgaVerLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* FPGA ID */
	micPodHUB_fpgaIDLabel = new QLabel("FPGA ID:");
	micPodHUB_fpgaIDLabel->setFixedHeight(18);
	micpod_HUB_gridLayout->addWidget(micPodHUB_fpgaIDLabel,rowNumber,0);
	for(int i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		micPodHUB_fpgaIDLabels[i]= new QLabel("-");
		micPodHUB_fpgaIDLabels[i]->setAlignment(Qt::AlignCenter);
		micpod_HUB_gridLayout->addWidget(micPodHUB_fpgaIDLabels[i],rowNumber,i+1);
	}
	rowNumber++;

	/* Update single micpod buttons */
	for(int i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		micPodHUB_updtBtn[i]= new QPushButton("Update");
		micpod_HUB_gridLayout->addWidget(micPodHUB_updtBtn[i],rowNumber,i+1);
	}
	rowNumber++;
	
	QWidget *midTopArea = new QWidget();
	midTopArea->setMaximumHeight(150);
	midTopArea->setLayout(micpod_HUB_gridLayout);
	mainLayout->addWidget(midTopArea);

/******************************************************************
 * TABLE HUB
 ******************************************************************/	

	rowNumber=1;

	/*Table Header*/
	tableHUB_IDLabel = new QLabel("Table HUB ID:	");
	tableHUB_IDLabel->setStyleSheet("QLabel { font-weight: bold; }");
	tableHUB_IDLabel->setFixedHeight(18);
	table_HUB_gridLayout->addWidget(tableHUB_IDLabel,rowNumber,0);
	tableHUB_IDLabels= new QLabel("#");
	tableHUB_IDLabels->setAlignment(Qt::AlignCenter);
	tableHUB_IDLabels->setStyleSheet("QLabel {font-weight: bold; }");
	tableHUB_IDLabels->setFixedHeight(18);
	table_HUB_gridLayout->addWidget(tableHUB_IDLabels,rowNumber,1);

	QWidget* empty = new QWidget();
	//empty->setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Preferred);
	empty->setMinimumWidth(300);
	table_HUB_gridLayout->addWidget(empty,rowNumber,4);

	rowNumber++;

	/* Unique ID */
	tableHUB_uniqueIDLabel = new QLabel("Short ID:");
	tableHUB_uniqueIDLabel->setFixedHeight(18);
	table_HUB_gridLayout->addWidget(tableHUB_uniqueIDLabel,rowNumber,0);
	tableHUB_UniqueIDLabels= new QLabel("-");
	tableHUB_UniqueIDLabels->setAlignment(Qt::AlignCenter);
	table_HUB_gridLayout->addWidget(tableHUB_UniqueIDLabels,rowNumber,1);
	
	rowNumber++;

	/* SW Version */
	tableHUB_swVersionLabel = new QLabel("SW Version:");
	tableHUB_swVersionLabel->setFixedHeight(18);
	table_HUB_gridLayout->addWidget(tableHUB_swVersionLabel,rowNumber,0);
	
	tableHUB_swVerLabels= new QLabel("-");
	tableHUB_swVerLabels->setAlignment(Qt::AlignCenter);
	table_HUB_gridLayout->addWidget(tableHUB_swVerLabels,rowNumber,1);

	tableHUB_updtAppBtn = new QPushButton("Update Linux APP");
	table_HUB_gridLayout->addWidget(tableHUB_updtAppBtn,rowNumber,2);
	
	tableHUB_updtSTM32Btn = new QPushButton("Update STM32 Firmware");
	table_HUB_gridLayout->addWidget(tableHUB_updtSTM32Btn,rowNumber,3);

	rowNumber++;

	/* Linux Version */
	tableHUB_linuxVersionLabel = new QLabel("Linux Version:");
	tableHUB_linuxVersionLabel->setFixedHeight(18);
	table_HUB_gridLayout->addWidget(tableHUB_linuxVersionLabel,rowNumber,0);
	
	tableHUB_linuxVersionLabels= new QLabel("-");
	tableHUB_linuxVersionLabels->setAlignment(Qt::AlignCenter);
	table_HUB_gridLayout->addWidget(tableHUB_linuxVersionLabels,rowNumber,1);

	rowNumber++;

	/* STM32 Version */
	tableHUB_stmVersionLabel = new QLabel("STM32 Version:");
	tableHUB_stmVersionLabel->setFixedHeight(18);
	table_HUB_gridLayout->addWidget(tableHUB_stmVersionLabel,rowNumber,0);
	
	tableHUB_stmVersionLabels= new QLabel("-");
	tableHUB_stmVersionLabels->setAlignment(Qt::AlignCenter);
	table_HUB_gridLayout->addWidget(tableHUB_stmVersionLabels,rowNumber,1);

	rowNumber++;

	/* FPGA Version */
	tableHUB_fpgaVersionLabel = new QLabel("FPGA Version:");
	tableHUB_fpgaVersionLabel->setFixedHeight(18);
	table_HUB_gridLayout->addWidget(tableHUB_fpgaVersionLabel,rowNumber,0);
	tableHUB_fpgaVerLabels= new QLabel("-");
	tableHUB_fpgaVerLabels->setAlignment(Qt::AlignCenter);
	table_HUB_gridLayout->addWidget(tableHUB_fpgaVerLabels,rowNumber,1);
	
	rowNumber++;

	/* FPGA ID */
	tableHUB_fpgaIDLabel = new QLabel("FPGA ID:");
	tableHUB_fpgaIDLabel->setFixedHeight(18);
	table_HUB_gridLayout->addWidget(tableHUB_fpgaIDLabel,rowNumber,0);
	
	tableHUB_fpgaIDLabels= new QLabel("-");
	tableHUB_fpgaIDLabels->setAlignment(Qt::AlignCenter);
	table_HUB_gridLayout->addWidget(tableHUB_fpgaIDLabels,rowNumber,1);
	
	rowNumber++;

	QWidget *midBottomArea = new QWidget();
	midBottomArea->setMaximumHeight(200);
	midBottomArea->setLayout(table_HUB_gridLayout);
	mainLayout->addWidget(midBottomArea);

/******************************************************************
 * TV HUB
 ******************************************************************/	

	rowNumber=1;

	/*Table Header*/
	tvHUB_IDLabel = new QLabel("TV HUB ID:	");
	tvHUB_IDLabel->setStyleSheet("QLabel { font-weight: bold; }");
	tvHUB_IDLabel->setFixedHeight(18);
	tv_HUB_gridLayout->addWidget(tvHUB_IDLabel,rowNumber,0);
	tvHUB_IDLabels= new QLabel("#");
	tvHUB_IDLabels->setAlignment(Qt::AlignCenter);
	tvHUB_IDLabels->setStyleSheet("QLabel {font-weight: bold; }");
	tvHUB_IDLabels->setFixedHeight(18);
	tv_HUB_gridLayout->addWidget(tvHUB_IDLabels,rowNumber,1);

	QWidget* empty1 = new QWidget();
	empty1->setMinimumWidth(300);
	tv_HUB_gridLayout->addWidget(empty1,rowNumber,4);

	rowNumber++;

	/* Unique ID */
	tvHUB_uniqueIDLabel = new QLabel("Short ID:");
	tvHUB_uniqueIDLabel->setFixedHeight(18);
	tv_HUB_gridLayout->addWidget(tvHUB_uniqueIDLabel,rowNumber,0);
	tvHUB_UniqueIDLabels= new QLabel("-");
	tvHUB_UniqueIDLabels->setAlignment(Qt::AlignCenter);
	tv_HUB_gridLayout->addWidget(tvHUB_UniqueIDLabels,rowNumber,1);
	
	rowNumber++;

	/* SW Version */
	tvHUB_swVersionLabel = new QLabel("SW Version:");
	tvHUB_swVersionLabel->setFixedHeight(18);
	tv_HUB_gridLayout->addWidget(tvHUB_swVersionLabel,rowNumber,0);
	
	tvHUB_swVerLabels= new QLabel("-");
	tvHUB_swVerLabels->setAlignment(Qt::AlignCenter);
	tv_HUB_gridLayout->addWidget(tvHUB_swVerLabels,rowNumber,1);

	tvHUB_updtAppBtn = new QPushButton("Update Linux APP");
	tv_HUB_gridLayout->addWidget(tvHUB_updtAppBtn,rowNumber,2);
	
	tvHUB_updtSTM32Btn = new QPushButton("Update STM32 Firmware");
	tv_HUB_gridLayout->addWidget(tvHUB_updtSTM32Btn,rowNumber,3);

	rowNumber++;


	/* Linux Version */
	tvHUB_linuxVersionLabel = new QLabel("Linux Version:");
	tvHUB_linuxVersionLabel->setFixedHeight(18);
	tv_HUB_gridLayout->addWidget(tvHUB_linuxVersionLabel,rowNumber,0);
	
	tvHUB_linuxVersionLabels= new QLabel("-");
	tvHUB_linuxVersionLabels->setAlignment(Qt::AlignCenter);
	tv_HUB_gridLayout->addWidget(tvHUB_linuxVersionLabels,rowNumber,1);

	rowNumber++;

	/* STM32 Version */
	tvHUB_stmVersionLabel = new QLabel("STM32 Version:");
	tvHUB_stmVersionLabel->setFixedHeight(18);
	tv_HUB_gridLayout->addWidget(tvHUB_stmVersionLabel,rowNumber,0);
	
	tvHUB_stmVersionLabels= new QLabel("-");
	tvHUB_stmVersionLabels->setAlignment(Qt::AlignCenter);
	tv_HUB_gridLayout->addWidget(tvHUB_stmVersionLabels,rowNumber,1);

	rowNumber++;

	/* FPGA Version */
	tvHUB_fpgaVersionLabel = new QLabel("FPGA Version:");
	tvHUB_fpgaVersionLabel->setFixedHeight(18);
	tv_HUB_gridLayout->addWidget(tvHUB_fpgaVersionLabel,rowNumber,0);
	tvHUB_fpgaVerLabels= new QLabel("-");
	tvHUB_fpgaVerLabels->setAlignment(Qt::AlignCenter);
	tv_HUB_gridLayout->addWidget(tvHUB_fpgaVerLabels,rowNumber,1);
	
	rowNumber++;

	/* FPGA ID */
	tvHUB_fpgaIDLabel = new QLabel("FPGA ID:");
	tvHUB_fpgaIDLabel->setFixedHeight(18);
	tv_HUB_gridLayout->addWidget(tvHUB_fpgaIDLabel,rowNumber,0);
	
	tvHUB_fpgaIDLabels= new QLabel("-");
	tvHUB_fpgaIDLabels->setAlignment(Qt::AlignCenter);
	tv_HUB_gridLayout->addWidget(tvHUB_fpgaIDLabels,rowNumber,1);
	
	rowNumber++;

	QWidget *bottomArea = new QWidget();
	bottomArea->setMaximumHeight(200);
	bottomArea->setLayout(tv_HUB_gridLayout);
	mainLayout->addWidget(bottomArea);
}

fwUpdateWidget::~fwUpdateWidget()
{
	
}


void fwUpdateWidget::connectQtSignals()
{
   for(int i=0; i<MICPOD_MAX_N; i++)
		connect(micPod_updtBtn[i], SIGNAL(clicked()), this, SLOT(slot_sendStartUpdateCmd()));
   
	for(int i=0; i<MICPOD_HUB_MAX_N; i++)
		connect(micPodHUB_updtBtn[i], SIGNAL(clicked()), this, SLOT(slot_sendStartUpdateCmd()));
   
	connect(tableHUB_updtAppBtn, SIGNAL(clicked()), this, SLOT(slot_sendStartUpdateCmd()));
	connect(tableHUB_updtSTM32Btn, SIGNAL(clicked()), this, SLOT(slot_sendStartUpdateCmd()));
	
	connect(tvHUB_updtAppBtn, SIGNAL(clicked()), this, SLOT(slot_sendStartUpdateCmd()));
	connect(tvHUB_updtSTM32Btn, SIGNAL(clicked()), this, SLOT(slot_sendStartUpdateCmd()));

	connect(micPod_updateAll, SIGNAL(clicked()), this, SLOT(slot_sendStartUpdateCmd()));
	connect(micPodHUB_updateAll, SIGNAL(clicked()), this, SLOT(slot_sendStartUpdateCmd()));
}

void fwUpdateWidget::disconnectQtSignals()
{
   
}

void fwUpdateWidget::slot_sendStartUpdateCmd()
{
	uint8_t updateType, deviceId;
	
	if(serialPortPtr->isConnected())
	{
		for(int i=0; i<MICPOD_MAX_N; i++)
		{
			if(micPod_updtBtn[i] == qobject_cast<QPushButton*>(sender()))
			{
				deviceId = fw_updt_system_status.micpods[i].id;
				updateType =  fw_updt_system_status.micpods[i].type;
				break;
			}
		}

		for(int i=0; i<MICPOD_HUB_MAX_N; i++)
		{
			if(micPodHUB_updtBtn[i] == qobject_cast<QPushButton*>(sender()))
			{
				deviceId = fw_updt_system_status.micpod_hubs[i].id;
				updateType = fw_updt_system_status.micpod_hubs[i].type;
				break;
			}
		}

		if(tableHUB_updtAppBtn==qobject_cast<QPushButton*>(sender()))
		{
			deviceId = fw_updt_system_status.table_hub.id;
			updateType = fw_updt_system_status.table_hub.type;
		}
		else if(tableHUB_updtSTM32Btn==qobject_cast<QPushButton*>(sender()))
		{
			deviceId = fw_updt_system_status.table_hub.id;
			updateType = STM32_DEVICE_TYPE;
		}
		else if(tvHUB_updtAppBtn==qobject_cast<QPushButton*>(sender()))
		{
			deviceId = fw_updt_system_status.tv_hub.id;
			updateType = fw_updt_system_status.tv_hub.type;
		}
		else if(tvHUB_updtSTM32Btn==qobject_cast<QPushButton*>(sender()))
		{
			deviceId = fw_updt_system_status.tv_hub.id;
			updateType = STM32_DEVICE_TYPE;
		}
		else if(micPod_updateAll==qobject_cast<QPushButton*>(sender()))
		{
			deviceId = DEFAULT_BROADCAST_ID;
			updateType = MICPOD_DEVICE_TYPE;
		}
		else if(micPodHUB_updateAll==qobject_cast<QPushButton*>(sender()))
		{
			deviceId = DEFAULT_BROADCAST_ID;
			updateType = MICPOD_HUB_DEVICE_TYPE;
		}

		/*fileLoaderPtr->setLabels(updateType, deviceId);
		fileLoaderPtr->show();*/
		updateTrackingPtr->setUpdateTypeDev(updateType, deviceId);

		updateTrackingPtr->startUpdate();
		updateTrackingPtr->show();
		
	}
	else
	{
		QMessageBox messageBox;
		messageBox.information(0,"Information","Please select and open the COM port first.");
		messageBox.setFixedSize(100,100);
	}
	
	
}

void fwUpdateWidget::slot_updateMicPodLabels(system_status_t * sys_status)
{
	QString s;
	memcpy(&fw_updt_system_status,sys_status, sizeof(system_status_t));

	for(int i=0; i<MICPOD_MAX_N; i++)
	{
		s = QString::number(fw_updt_system_status.micpods[i].id);
		micPod_IDLabels[i]->setText(s);
		
		QString shrtId = shortIdClass.getShortID(fw_updt_system_status.micpods[i].dev_info.fpga_unique_id);

		if(fw_updt_system_status.micpods[i].alive)
		{
			micPod_IDLabels[i]->setStyleSheet("color: green;font-weight: bold;");
			micPod_UniqueIDLabels[i]->setText(shrtId);
			micPod_swVerLabels[i]->setText(QString::number(fw_updt_system_status.micpods[i].dev_info.sw_version));
			micPod_fpgaVerLabels[i]->setText(QString::number(fw_updt_system_status.micpods[i].dev_info.fpga_version));
			micPod_fpgaIDLabels[i]->setText("0x"+QString::number(fw_updt_system_status.micpods[i].dev_info.fpga_unique_id,16));
			micPod_updtBtn[i]->setEnabled(true);
		}
		else
		{
			micPod_IDLabels[i]->setStyleSheet("color: red; font-weight: bold;");
			micPod_UniqueIDLabels[i]->setText(" - ");
			micPod_swVerLabels[i]->setText(" - ");
			micPod_fpgaVerLabels[i]->setText(" - ");
			micPod_fpgaIDLabels[i]->setText(" - ");
			micPod_updtBtn[i]->setEnabled(false);

		}
	}
}

void fwUpdateWidget::slot_updateMicPodHUBLabels(system_status_t * sys_status)
{
	QString s;
	memcpy(&fw_updt_system_status,sys_status, sizeof(system_status_t));

	for(int i=0; i<MICPOD_HUB_MAX_N; i++)
	{
		s = QString::number(fw_updt_system_status.micpod_hubs[i].id);
		micPodHUB_IDLabels[i]->setText(s);
		
		QString shrtId = shortIdClass.getShortID(fw_updt_system_status.micpod_hubs[i].dev_info.fpga_unique_id);

		if(fw_updt_system_status.micpod_hubs[i].alive)
		{
			micPodHUB_IDLabels[i]->setStyleSheet("color: green;font-weight: bold;");
			micPodHUB_UniqueIDLabels[i]->setText(shrtId);
			micPodHUB_swVerLabels[i]->setText(QString::number(fw_updt_system_status.micpod_hubs[i].dev_info.sw_version));
			micPodHUB_fpgaVerLabels[i]->setText(QString::number(fw_updt_system_status.micpod_hubs[i].dev_info.fpga_version));
			micPodHUB_fpgaIDLabels[i]->setText("0x"+QString::number(fw_updt_system_status.micpod_hubs[i].dev_info.fpga_unique_id,16));
			micPodHUB_updtBtn[i]->setEnabled(true);
		}
		else
		{
			micPodHUB_IDLabels[i]->setStyleSheet("color: red; font-weight: bold;");
			micPodHUB_UniqueIDLabels[i]->setText(" - ");
			micPodHUB_swVerLabels[i]->setText(" - ");
			micPodHUB_fpgaVerLabels[i]->setText(" - ");
			micPodHUB_fpgaIDLabels[i]->setText(" - ");
			micPodHUB_updtBtn[i]->setEnabled(false);
		}
	}
}

void fwUpdateWidget::slot_updateTableHUBLabels(system_status_t * sys_status)
{
	QString s;
	memcpy(&fw_updt_system_status,sys_status, sizeof(system_status_t));

	s = QString::number(fw_updt_system_status.table_hub.id);
	tableHUB_IDLabels->setText(s);

	QString shrtId = shortIdClass.getShortID(fw_updt_system_status.table_hub.dev_info.fpga_unique_id);
		
	tableHUB_IDLabels->setStyleSheet("color: green;font-weight: bold;");
	tableHUB_UniqueIDLabels->setText(shrtId);
	tableHUB_swVerLabels->setText(QString::number(fw_updt_system_status.table_hub.dev_info.sw_version));
	tableHUB_linuxVersionLabels->setText(QString::number(fw_updt_system_status.table_hub.dev_info.linux_version));
	tableHUB_stmVersionLabels->setText(QString::number(fw_updt_system_status.table_hub.dev_info.stm_version));
	tableHUB_fpgaVerLabels->setText(QString::number(fw_updt_system_status.table_hub.dev_info.fpga_version));
	tableHUB_fpgaIDLabels->setText("0x"+QString::number(fw_updt_system_status.table_hub.dev_info.fpga_unique_id,16));
}


void fwUpdateWidget::slot_updateTVHUBLabels(system_status_t * sys_status)
{
	QString s;
	memcpy(&fw_updt_system_status,sys_status, sizeof(system_status_t));

	s = QString::number(fw_updt_system_status.tv_hub.id);
	tvHUB_IDLabels->setText(s);

	if(fw_updt_system_status.tv_hub.alive)
	{
		QString shrtId = shortIdClass.getShortID(fw_updt_system_status.tv_hub.dev_info.fpga_unique_id);

		tvHUB_IDLabels->setStyleSheet("color: green;font-weight: bold;");
		tvHUB_UniqueIDLabels->setText(shrtId);
		tvHUB_swVerLabels->setText(QString::number(fw_updt_system_status.tv_hub.dev_info.sw_version));
		tvHUB_linuxVersionLabels->setText(QString::number(fw_updt_system_status.tv_hub.dev_info.linux_version));
		tvHUB_stmVersionLabels->setText(QString::number(fw_updt_system_status.tv_hub.dev_info.stm_version));
		tvHUB_fpgaVerLabels->setText(QString::number(fw_updt_system_status.tv_hub.dev_info.fpga_version));
		tvHUB_fpgaIDLabels->setText("0x"+QString::number(fw_updt_system_status.tv_hub.dev_info.fpga_unique_id,16));

		tvHUB_updtAppBtn->setEnabled(true);
		tvHUB_updtSTM32Btn->setEnabled(true);
	}
	else
	{
		tvHUB_IDLabels->setStyleSheet("color: red; font-weight: bold;");
		tvHUB_UniqueIDLabels->setText(" - ");
		tvHUB_swVerLabels->setText(" - ");
		tvHUB_linuxVersionLabels->setText(" - ");
		tvHUB_stmVersionLabels->setText(" - ");
		tvHUB_fpgaVerLabels->setText(" - ");
		tvHUB_fpgaIDLabels->setText(" - ");

		tvHUB_updtAppBtn->setEnabled(false);
		tvHUB_updtSTM32Btn->setEnabled(false);
	}
}


