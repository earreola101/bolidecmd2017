#ifndef BD_DOUBLE_SPIN_BOX_H
#define BD_DOUBLE_SPIN_BOX_H

#include <QDoubleSpinBox>
#include <qevent.h>
#include <qlineedit.h>

class bdDoubleSpinBox : public QDoubleSpinBox
{
	Q_OBJECT

public:
    bdDoubleSpinBox(QWidget* parent=0){ isRed = false; };
    void setDefaultDiff(int different)
    {
        isRed = false;
        if(different)
        {
            isRed = true;
            this->setStyleSheet("QDoubleSpinBox{color: red;}");
        }
        else
            this->setStyleSheet("QDoubleSpinBox{color: black;}");

        if(!this->isEnabled())
        {
            style = this->styleSheet();
            if(isRed)
                this->setStyleSheet("QDoubleSpinBox {color: red;}");
            else
                this->setStyleSheet("QDoubleSpinBox {color: grey;}");
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
                style = this->styleSheet();
                if(isRed)
                    this->setStyleSheet("QDoubleSpinBox {color: red;}");
                else
                    this->setStyleSheet("QDoubleSpinBox {color: grey;}");
            }
		}
	}
};

#endif // BD_DOUBLE_SPIN_BOX_H