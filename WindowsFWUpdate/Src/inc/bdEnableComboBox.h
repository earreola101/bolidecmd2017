#ifndef BD_ENABLE_COMBO_BOX_H
#define BD_ENABLE_COMBO_BOX_H

#include <QComboBox>
#include <qevent.h>
#define QT_STRING_ENABLE    "Enable"
#define QT_STRING_DISABLE   "Disable"

class bdEnableComboBox : public QComboBox
{
	Q_OBJECT

public:
    bdEnableComboBox(QWidget *parent = 0){
        QStringList enableList;
        enableList << QT_STRING_ENABLE << QT_STRING_DISABLE;
        this->addItems(enableList);
        this->setMaximumWidth(80);
        isRed = false;
	};

    virtual void setEnableAllWidgets(bool enable){};

    int getEnableStatus() {
        if(this->currentText().compare(QT_STRING_ENABLE)==0)
            return 1;
        return 0;
    }

    void setEnableStatus(int enable)
    {
        if(enable)
            this->setCurrentText(QT_STRING_ENABLE);
        else
            this->setCurrentText(QT_STRING_DISABLE);
    }

    void setDefaultDiff(int different)
    {
        isRed = false;
        if(different)
        {
            isRed = true;
            this->setStyleSheet("QComboBox{color: red;}");
        }
        else
            this->setStyleSheet("QComboBox{color: black;}");

        if(!this->isEnabled())
        {
            style = this->styleSheet();
            if(isRed)
                this->setStyleSheet("QComboBox {color: red;}");
            else
                this->setStyleSheet("QComboBox {color: grey;}");
        }
    }

private:
    QString style;
    bool isRed;

protected slots:
		virtual void changeEvent(QEvent * event)
		{
			if(event->type()==QEvent::EnabledChange)
			{
				if(this->isEnabled())
				{
					this->setStyleSheet(style);
				}
				else
                {
                    if(isRed)
                        this->setStyleSheet("QComboBox {color: red;}");
                    else
                        this->setStyleSheet("QComboBox {color: grey;}");
                }
			}
		}

};

#endif // BD_ENABLE_COMBO_BOX_H
