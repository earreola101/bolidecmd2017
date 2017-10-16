#include "bolide.h"
#include <QtWidgets/QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    Bolide w;
    w.show();
    return a.exec();
}
