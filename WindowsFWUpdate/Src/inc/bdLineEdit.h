#ifndef BD_LINE_EDIT_H
#define BD_LINE_EDIT_H

#include <qlineedit.h>
#include <qevent.h>

class bdLineEdit : public QLineEdit
{
	Q_OBJECT
public:     
    bdLineEdit(const QString &, QWidget* parent=0){  isRed = false; };
    void setDefaultDiff(char *string1, char *string2)
    {
        QString str1(string1);
        QString str2(string2);

        isRed = false;
        if(str1.compare(str2)!=0)
        {
            isRed = true;
            this->setStyleSheet("QLineEdit{color: red;}");
        }
        else
            this->setStyleSheet("QLineEdit{color: black;}");

        if(!this->isEnabled())
        {
            style = this->styleSheet();
            if(isRed)
                this->setStyleSheet("QLineEdit {color: red;}");
            else
                this->setStyleSheet("QLineEdit {color: grey;}");
        }
    }

    void setRed()
    {
        isRed = true;
        this->setStyleSheet("QLineEdit{color: red;}");

        if(!this->isEnabled())
        {
            style = this->styleSheet();
            if(isRed)
                this->setStyleSheet("QLineEdit {color: red;}");
            else
                this->setStyleSheet("QLineEdit {color: grey;}");
        }
    }

    void setBlack()
    {
        isRed = false;
        this->setStyleSheet("QLineEdit{color: black;}");

        if(!this->isEnabled())
        {
            style = this->styleSheet();
            if(isRed)
                this->setStyleSheet("QLineEdit {color: red;}");
            else
                this->setStyleSheet("QLineEdit {color: grey;}");
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
                        this->setStyleSheet("QLineEdit {color: red;}");
                    else
                        this->setStyleSheet("QLineEdit {color: grey;}");
                }
			}
		}
};

#endif //BD_LINE_EDIT_H