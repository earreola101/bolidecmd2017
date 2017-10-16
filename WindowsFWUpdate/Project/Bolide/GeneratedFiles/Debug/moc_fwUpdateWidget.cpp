/****************************************************************************
** Meta object code from reading C++ file 'fwUpdateWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/fwUpdateWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'fwUpdateWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_fwUpdateWidget_t {
    QByteArrayData data[9];
    char stringdata[168];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_fwUpdateWidget_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_fwUpdateWidget_t qt_meta_stringdata_fwUpdateWidget = {
    {
QT_MOC_LITERAL(0, 0, 14), // "fwUpdateWidget"
QT_MOC_LITERAL(1, 15, 23), // "slot_updateMicPodLabels"
QT_MOC_LITERAL(2, 39, 0), // ""
QT_MOC_LITERAL(3, 40, 16), // "system_status_t*"
QT_MOC_LITERAL(4, 57, 10), // "sys_status"
QT_MOC_LITERAL(5, 68, 26), // "slot_updateMicPodHUBLabels"
QT_MOC_LITERAL(6, 95, 22), // "slot_updateTVHUBLabels"
QT_MOC_LITERAL(7, 118, 25), // "slot_updateTableHUBLabels"
QT_MOC_LITERAL(8, 144, 23) // "slot_sendStartUpdateCmd"

    },
    "fwUpdateWidget\0slot_updateMicPodLabels\0"
    "\0system_status_t*\0sys_status\0"
    "slot_updateMicPodHUBLabels\0"
    "slot_updateTVHUBLabels\0slot_updateTableHUBLabels\0"
    "slot_sendStartUpdateCmd"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_fwUpdateWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   39,    2, 0x0a /* Public */,
       5,    1,   42,    2, 0x0a /* Public */,
       6,    1,   45,    2, 0x0a /* Public */,
       7,    1,   48,    2, 0x0a /* Public */,
       8,    0,   51,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void,

       0        // eod
};

void fwUpdateWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        fwUpdateWidget *_t = static_cast<fwUpdateWidget *>(_o);
        switch (_id) {
        case 0: _t->slot_updateMicPodLabels((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 1: _t->slot_updateMicPodHUBLabels((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 2: _t->slot_updateTVHUBLabels((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 3: _t->slot_updateTableHUBLabels((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 4: _t->slot_sendStartUpdateCmd(); break;
        default: ;
        }
    }
}

const QMetaObject fwUpdateWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_fwUpdateWidget.data,
      qt_meta_data_fwUpdateWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *fwUpdateWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *fwUpdateWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_fwUpdateWidget.stringdata))
        return static_cast<void*>(const_cast< fwUpdateWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int fwUpdateWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 5;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
