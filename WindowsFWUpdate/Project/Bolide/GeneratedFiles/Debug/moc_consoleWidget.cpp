/****************************************************************************
** Meta object code from reading C++ file 'consoleWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/consoleWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'consoleWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_consoleWidget_t {
    QByteArrayData data[11];
    char stringdata[165];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_consoleWidget_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_consoleWidget_t qt_meta_stringdata_consoleWidget = {
    {
QT_MOC_LITERAL(0, 0, 13), // "consoleWidget"
QT_MOC_LITERAL(1, 14, 11), // "slot_update"
QT_MOC_LITERAL(2, 26, 0), // ""
QT_MOC_LITERAL(3, 27, 16), // "system_status_t*"
QT_MOC_LITERAL(4, 44, 13), // "system_status"
QT_MOC_LITERAL(5, 58, 16), // "slot_muteSysSlot"
QT_MOC_LITERAL(6, 75, 18), // "slot_openNewWindow"
QT_MOC_LITERAL(7, 94, 20), // "slot_startStopRecord"
QT_MOC_LITERAL(8, 115, 20), // "slot_sendUsbAudioSrc"
QT_MOC_LITERAL(9, 136, 24), // "slot_sendSignalGenerator"
QT_MOC_LITERAL(10, 161, 3) // "sgn"

    },
    "consoleWidget\0slot_update\0\0system_status_t*\0"
    "system_status\0slot_muteSysSlot\0"
    "slot_openNewWindow\0slot_startStopRecord\0"
    "slot_sendUsbAudioSrc\0slot_sendSignalGenerator\0"
    "sgn"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_consoleWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   44,    2, 0x0a /* Public */,
       5,    0,   47,    2, 0x08 /* Private */,
       6,    0,   48,    2, 0x08 /* Private */,
       7,    0,   49,    2, 0x08 /* Private */,
       8,    0,   50,    2, 0x08 /* Private */,
       9,    1,   51,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,   10,

       0        // eod
};

void consoleWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        consoleWidget *_t = static_cast<consoleWidget *>(_o);
        switch (_id) {
        case 0: _t->slot_update((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 1: _t->slot_muteSysSlot(); break;
        case 2: _t->slot_openNewWindow(); break;
        case 3: _t->slot_startStopRecord(); break;
        case 4: _t->slot_sendUsbAudioSrc(); break;
        case 5: _t->slot_sendSignalGenerator((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject consoleWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_consoleWidget.data,
      qt_meta_data_consoleWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *consoleWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *consoleWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_consoleWidget.stringdata))
        return static_cast<void*>(const_cast< consoleWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int consoleWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 6)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 6;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
