/****************************************************************************
** Meta object code from reading C++ file 'ecCommandLogTabWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/ecCommandLogTabWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ecCommandLogTabWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_ecCommandLogTabWidget_t {
    QByteArrayData data[8];
    char stringdata[99];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_ecCommandLogTabWidget_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_ecCommandLogTabWidget_t qt_meta_stringdata_ecCommandLogTabWidget = {
    {
QT_MOC_LITERAL(0, 0, 21), // "ecCommandLogTabWidget"
QT_MOC_LITERAL(1, 22, 19), // "slot_printOnConsole"
QT_MOC_LITERAL(2, 42, 0), // ""
QT_MOC_LITERAL(3, 43, 6), // "sender"
QT_MOC_LITERAL(4, 50, 6), // "string"
QT_MOC_LITERAL(5, 57, 17), // "slot_updateStatus"
QT_MOC_LITERAL(6, 75, 16), // "system_status_t*"
QT_MOC_LITERAL(7, 92, 6) // "status"

    },
    "ecCommandLogTabWidget\0slot_printOnConsole\0"
    "\0sender\0string\0slot_updateStatus\0"
    "system_status_t*\0status"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_ecCommandLogTabWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    2,   24,    2, 0x0a /* Public */,
       5,    1,   29,    2, 0x0a /* Public */,

 // slots: parameters
    QMetaType::Void, QMetaType::Int, QMetaType::QString,    3,    4,
    QMetaType::Void, 0x80000000 | 6,    7,

       0        // eod
};

void ecCommandLogTabWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        ecCommandLogTabWidget *_t = static_cast<ecCommandLogTabWidget *>(_o);
        switch (_id) {
        case 0: _t->slot_printOnConsole((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 1: _t->slot_updateStatus((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject ecCommandLogTabWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_ecCommandLogTabWidget.data,
      qt_meta_data_ecCommandLogTabWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *ecCommandLogTabWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ecCommandLogTabWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_ecCommandLogTabWidget.stringdata))
        return static_cast<void*>(const_cast< ecCommandLogTabWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int ecCommandLogTabWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 2)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 2)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 2;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
