/****************************************************************************
** Meta object code from reading C++ file 'ecLogWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/ecLogWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ecLogWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_ecLogWidget_t {
    QByteArrayData data[8];
    char stringdata[89];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_ecLogWidget_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_ecLogWidget_t qt_meta_stringdata_ecLogWidget = {
    {
QT_MOC_LITERAL(0, 0, 11), // "ecLogWidget"
QT_MOC_LITERAL(1, 12, 15), // "slot_updateList"
QT_MOC_LITERAL(2, 28, 0), // ""
QT_MOC_LITERAL(3, 29, 11), // "slot_addLog"
QT_MOC_LITERAL(4, 41, 6), // "sender"
QT_MOC_LITERAL(5, 48, 3), // "log"
QT_MOC_LITERAL(6, 52, 18), // "slot_filterChanged"
QT_MOC_LITERAL(7, 71, 17) // "slot_clearConsole"

    },
    "ecLogWidget\0slot_updateList\0\0slot_addLog\0"
    "sender\0log\0slot_filterChanged\0"
    "slot_clearConsole"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_ecLogWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   34,    2, 0x0a /* Public */,
       3,    2,   35,    2, 0x0a /* Public */,
       6,    1,   40,    2, 0x08 /* Private */,
       7,    0,   43,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int, QMetaType::QString,    4,    5,
    QMetaType::Void, QMetaType::QString,    4,
    QMetaType::Void,

       0        // eod
};

void ecLogWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        ecLogWidget *_t = static_cast<ecLogWidget *>(_o);
        switch (_id) {
        case 0: _t->slot_updateList(); break;
        case 1: _t->slot_addLog((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 2: _t->slot_filterChanged((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 3: _t->slot_clearConsole(); break;
        default: ;
        }
    }
}

const QMetaObject ecLogWidget::staticMetaObject = {
    { &bdGroupBox::staticMetaObject, qt_meta_stringdata_ecLogWidget.data,
      qt_meta_data_ecLogWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *ecLogWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ecLogWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_ecLogWidget.stringdata))
        return static_cast<void*>(const_cast< ecLogWidget*>(this));
    return bdGroupBox::qt_metacast(_clname);
}

int ecLogWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = bdGroupBox::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 4)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 4;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
