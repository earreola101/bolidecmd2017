#ifndef BD_GROUP_BOX_H
#define BD_GROUP_BOX_H

#include <qgroupbox.h>
#include <qevent.h>
#include "bdEnableComboBox.h"

#include "status.h"

class bdGroupBox : public QGroupBox
{
	Q_OBJECT
public:
	bdGroupBox(QWidget *parent = 0){
		this->setStyleSheet("QGroupBox { font-weight: bold;}");
        
        // Enable Combo Box
        enableComboBox = new bdEnableComboBox();
		connect(enableComboBox, SIGNAL(currentIndexChanged(QString)), this, SLOT(my_toggled(QString)));
	};

    bdEnableComboBox *enableComboBox;

    // Update all values of the Widget from the struct
    virtual void updateFromStruct(system_status_t *status){};

protected slots:
		virtual void changeEvent(QEvent * event)
		{
			if(event->type()==QEvent::EnabledChange)
			{
				if(this->isEnabled())
				{
					this->setStyleSheet("QGroupBox {color: black; font-weight: bold;}");
				}
				else
					this->setStyleSheet("QGroupBox {color: grey; font-weight: bold;}");
			}
		}

private:
	virtual void connectSignals(){};
	virtual void disconnectSignals(){};

private slots:
    void my_toggled(QString enable)
    {
        if(enableComboBox->getEnableStatus())
			this->setStyleSheet("QGroupBox {color: black; font-weight: bold;}");
		else
			this->setStyleSheet("QGroupBox {color: grey; font-weight: bold;}");
	}
};

#endif //BD_GROUP_BOX_H