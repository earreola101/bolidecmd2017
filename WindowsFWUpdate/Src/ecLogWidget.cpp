#include "ecLogWidget.h"
#include "status.h"
#include "command_gen_dec.h"
#include "command_parser.h"

#define FILTER_MICPOD_BROADCAST   "MicPod BroadCast"
#define FILTER_MICPOD(x)          QString("MicPod %1").arg(x)
#define FILTER_TABLE_HUB          "TableHub"
#define FILTER_ALL                "All"

ecLogWidget::ecLogWidget(system_status_t *status, QWidget *parent) 
	: bdGroupBox(parent)
{
    sys_status = status; 

    // GroupBox Option
	this->setTitle("EC Logs");

	// Main Layout
    mainVLayout = new QVBoxLayout();

    // Filter by sender
    filterHLayout = new QHBoxLayout();
    filterLabel = new QLabel("Filter by sender:");
    filterComboBox = new QComboBox();

    filterComboBox->addItem(FILTER_ALL);
    filterList.append(FILTER_ALL);

    filterComboBox->setFixedWidth(130);

    filterHLayout->addWidget(filterLabel);
    filterHLayout->addWidget(filterComboBox);
    filterHLayout->setAlignment(Qt::AlignRight);

    // Text Edit Log
    consoleTextEdit = new QPlainTextEdit();
    QFont font;
    font.setFamily("Courier");
    font.setStyleHint(QFont::Monospace);
    font.setFixedPitch(true);
    font.setPointSize(10);
    consoleTextEdit->setFont(font);
    QFontMetrics metrics(font);
    consoleTextEdit->setTabStopWidth(4 * metrics.width(' '));
    consoleTextEdit->setReadOnly(true);

    // Clear Console Button
    clearConsoleButton = new QPushButton("Clear Logs");
    clearConsoleButton->setFixedWidth(90);

    mainVLayout->addLayout(filterHLayout);
    mainVLayout->addWidget(consoleTextEdit);
    mainVLayout->addWidget(clearConsoleButton);

    mainVLayout->setAlignment(Qt::AlignRight);
	this->setLayout(mainVLayout);
    
    
    // Connect Qt Signal
	connectSignals();

    slot_updateList();
}

/******************************************************************
 * Connect QT Signals
 ******************************************************************/
void ecLogWidget::connectSignals()
{
	bool res = connect(filterComboBox,SIGNAL(currentTextChanged(const QString)),this,SLOT(slot_filterChanged(const QString)));
    res = connect(clearConsoleButton,SIGNAL(clicked()),this,SLOT(slot_clearConsole()));
}

/******************************************************************
 * Disconnect QT Signals
 ******************************************************************/
void ecLogWidget::disconnectSignals()
{
    disconnect(filterComboBox,SIGNAL(currentTextChanged(const QString)),this,SLOT(slot_filterChanged(const QString)));
    disconnect(clearConsoleButton,SIGNAL(clicked()),this,SLOT(slot_clearConsole()));
}


/******************************************************************
 * [SLOT] Update list
 ******************************************************************/
void ecLogWidget::slot_updateList()
{
    QString curTex = filterComboBox->currentText();

    bool atLeastOneMicPodAvail = false;
    for(int i=0;i<MICPOD_MAX_N;i++)
    {
        QString micPod = FILTER_MICPOD(sys_status->micpods[i].id);
        if(sys_status->micpods[i].alive)
        {
            if(!filterList.contains(micPod))
                filterList.append(micPod);
            atLeastOneMicPodAvail =true;
        }
    }
    
    if(sys_status->table_hub.alive && !filterList.contains(FILTER_TABLE_HUB))
         filterList.insert(1,FILTER_TABLE_HUB);

    if(atLeastOneMicPodAvail && !filterList.contains(FILTER_MICPOD_BROADCAST))
        filterList.insert(2,FILTER_MICPOD_BROADCAST);

    filterComboBox->clear();
    filterComboBox->addItems(filterList);

    if(filterList.contains(curTex))
        filterComboBox->setCurrentText(curTex);
}

/******************************************************************
 * [SLOT] Add log
 ******************************************************************/
void ecLogWidget::slot_addLog(int sender, QString log)
{
    QString logStr = log;
    logStr.prepend("] ");
    if(sender==DEFAULT_TABLE_HUB_ID)
        logStr.prepend(FILTER_TABLE_HUB);            
    else
        logStr.prepend(FILTER_MICPOD(sender));
    logStr.prepend("[");
    logStr.remove("\n");
    
    logList.append(logStr);

    // Print on console
    QString filterString = filterComboBox->currentText();
    if((filterString.compare(FILTER_ALL)==0) ||
        (sender==DEFAULT_TABLE_HUB_ID && filterString.compare(FILTER_TABLE_HUB)==0) ||
        (sender!=DEFAULT_TABLE_HUB_ID && filterString.compare(FILTER_MICPOD_BROADCAST)==0))
        consoleTextEdit->appendPlainText(logStr);

    slot_filterChanged("");
}

/******************************************************************
 * [SLOT] Clear Console
 ******************************************************************/
void ecLogWidget::slot_clearConsole()
{
    consoleTextEdit->clear();
    logList.clear();
    filterList.clear();
    bool atLeastOneMicPodAvail = false;
    for(int i=0;i<MICPOD_MAX_N;i++)
    {
        QString micPod = FILTER_MICPOD(sys_status->micpods[i].id);
        if(sys_status->micpods[i].alive)
        {
            if(!filterList.contains(micPod))
                filterList.append(micPod);
            atLeastOneMicPodAvail =true;
        }
    }
    if(atLeastOneMicPodAvail)
        filterList.prepend(FILTER_MICPOD_BROADCAST);
    if(sys_status->table_hub.alive)
         filterList.prepend(FILTER_TABLE_HUB);
    filterList.prepend(FILTER_ALL);

    filterComboBox->clear();
    filterComboBox->addItems(filterList);
}

/******************************************************************
 * [SLOT] Filter Changed
 ******************************************************************/
void ecLogWidget::slot_filterChanged(const QString sender)
{
    consoleTextEdit->clear();
    QString filterString = filterComboBox->currentText();
    if(filterString.compare(FILTER_ALL)!=0)
    {
        if(filterString.compare(FILTER_MICPOD_BROADCAST)==0)
            filterString = FILTER_MICPOD("");
        else
            filterString.append("]");
        
        filterString.prepend("[");

        QStringList result = logList.filter(filterString);
        for(int i=0;i<result.count();i++)
            consoleTextEdit->appendPlainText(result[i]);
    }
    else
    {
        for(int i=0;i<logList.count();i++)
            consoleTextEdit->appendPlainText(logList[i]);
    }
}
