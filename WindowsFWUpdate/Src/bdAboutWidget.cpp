#include "bdAboutWidget.h"
#include "version.h"

#include <qicon.h>

bdAboutWidget::bdAboutWidget(QWidget *parent) 
	: QWidget(parent)
{
	QIcon icon("images/bolide.ico");
	this->setWindowIcon(icon);

	mainBox = new QGroupBox();
	mainLayout = new QHBoxLayout(this);
	mainLayout->addWidget(mainBox);

	boxLayout = new QVBoxLayout();
	mainBox->setLayout(boxLayout);

	this->setWindowTitle("About Bolide GUI");

	// Title 
	titleLabel = new QLabel("Bolide GUI");
	QFont titleFont;
	titleFont.setBold(true);
	titleFont.setPointSize(12);
	titleLabel->setFont(titleFont);

	titleLabel->setAlignment(Qt::AlignCenter);

	boxLayout->addWidget(titleLabel);

	logoBolide = new QPixmap("images/bolide.png");
	
	logoLabelBolide = new QLabel();
	logoLabelBolide->setPixmap(*logoBolide);

	logoLabelBolide->setAlignment(Qt::AlignCenter);

	boxLayout->addWidget(logoLabelBolide);

	// Version
	versionLabel = new QLabel();

	QString version;
	version.append("Version ");
	version.append(QString::number(SW_VERSION));

	versionLabel->setText(version);

	versionLabel->setAlignment(Qt::AlignCenter);

	boxLayout->addWidget(versionLabel);

	QFont versionFont;
	versionFont.setBold(true);
	versionFont.setPointSize(10);
	versionLabel->setFont(versionFont);

	// Version
	/*dateBuildVerLabel = new QLabel();

	QString dateBuildVer;
	dateBuildVer.append("(Build rev. ");
	dateBuildVer.append("111");
	dateBuildVer.append(" - ");
	dateBuildVer.append("29 MAY 2017");
	dateBuildVer.append(")");

	dateBuildVerLabel->setText(dateBuildVer);

	dateBuildVerLabel->setAlignment(Qt::AlignCenter);

	boxLayout->addWidget(dateBuildVerLabel);

	QFont dateBuildFont;
	dateBuildFont.setBold(false);
	dateBuildFont.setPointSize(9);
	dateBuildVerLabel->setFont(dateBuildFont);*/
	
	// Copyright
	copyrightLabel = new QLabel("Copyright (c) 2017 bdSound srl");
	
	QFont font;
	font.setBold(false);
	font.setItalic(true);
	font.setPointSize(8);
	copyrightLabel->setFont(font);

	copyrightLabel->setAlignment(Qt::AlignCenter);

	boxLayout->addWidget(copyrightLabel);

	// Url 
	urlLabel = new QLabel("<a href=\"http://www.bdsound.com/\">www.bdsound.com</a>");
	urlLabel->setTextFormat(Qt::RichText);
	urlLabel->setTextInteractionFlags(Qt::TextBrowserInteraction);
	urlLabel->setOpenExternalLinks(true);

	QFont urlFont;
	urlFont.setBold(true);
	urlFont.setPointSize(9);
	urlLabel->setFont(urlFont);

	urlLabel->setAlignment(Qt::AlignCenter);

	boxLayout->addWidget(urlLabel);

	// Logo
	logo = new QPixmap("images/bdLogo.png");
	*logo = logo->scaled(125,30,Qt::KeepAspectRatio,Qt::SmoothTransformation);

	logoLabel = new QLabel();
	logoLabel->setPixmap(*logo);

	logoLabel->setAlignment(Qt::AlignLeft);

	boxLayout->addWidget(logoLabel);

	this->setFixedSize(400,250);
	this->setWindowModality(Qt::ApplicationModal);
}

bdAboutWidget::~bdAboutWidget()
{
}