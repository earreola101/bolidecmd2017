#ifndef BD_ABOUT_WIDGET_H
#define BD_ABOUT_WIDGET_H

// QT includes
#include <QtWidgets/qlayout.h>
#include <QtWidgets/qwidget.h>
#include <QtWidgets/qlabel.h>
#include <QtWidgets/qgroupbox.h>

class bdAboutWidget : public QWidget
{
	Q_OBJECT

public:
	bdAboutWidget(QWidget *parent = 0);
	~bdAboutWidget();

private:
	QHBoxLayout *mainLayout;
	QGroupBox *mainBox;

	QVBoxLayout *boxLayout;

	QPixmap *logo;
	QLabel *logoLabel;

	QPixmap *logoBolide;
	QLabel *logoLabelBolide;

	QLabel *titleLabel;
	QLabel *versionLabel;

	QLabel *dateBuildVerLabel;

	QLabel *copyrightLabel;

	QLabel *urlLabel;
	
};

#endif // BD_ABOUT_WIDGET_H