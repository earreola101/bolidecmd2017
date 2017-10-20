#include <QtCore/QCoreApplication>
#include <bolideCmdAccess.h>

int main(int argc, char *argv[])
{
	QCoreApplication a(argc, argv);
	bolideCmdAccess *bolideAcc;
	bolideAcc->Run(*argv);
	return a.exec();
}

