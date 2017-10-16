#ifndef BD_SPIN_BOX_H
#define BD_SPIN_BOX_H

#include <QSpinBox>
#include <qevent.h>

class bdSpinBox : public QSpinBox
{
	Q_OBJECT

public:
    bdSpinBox(QWidget* parent=0){ isRed = false; };
 
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
                    this->setStyleSheet("QSpinBox {color: black;}");
                else
                    this->setStyleSheet("QSpinBox {color: grey;}");
            }
		}
	}
};

#endif // BD_SPIN_BOX_H