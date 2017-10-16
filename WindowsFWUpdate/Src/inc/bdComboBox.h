#ifndef BD_COMBO_BOX_H
#define BD_COMBO_BOX_H

#include <QComboBox>
#include <qevent.h>

class bdComboBox : public QComboBox
{
	Q_OBJECT

public:
    bdComboBox(QWidget *parent = 0){
        isRed = false;
	};


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
                    style = this->styleSheet();
					if(isRed)
                        this->setStyleSheet("QComboBox {color: black;}");
                    else
                        this->setStyleSheet("QComboBox {color: grey;}");
                }
			}
		}

};

#endif // BD_COMBO_BOX_H
