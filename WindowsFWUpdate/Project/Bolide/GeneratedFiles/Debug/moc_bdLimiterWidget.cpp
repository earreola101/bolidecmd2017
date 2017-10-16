/****************************************************************************
** Meta object code from reading C++ file 'bdLimiterWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/bdLimiterWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'bdLimiterWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_bdLimiterWidget_t {
    QByteArrayData data[6];
    char stringdata[64];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_bdLimiterWidget_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_bdLimiterWidget_t qt_meta_stringdata_bdLimiterWidget = {
    {
QT_MOC_LITERAL(0, 0, 15), // "bdLimiterWidget"
QT_MOC_LITERAL(1, 16, 18), // "slot_enableProcess"
QT_MOC_LITERAL(2, 35, 0), // ""
QT_MOC_LITERAL(3, 36, 6), // "enable"
QT_MOC_LITERAL(4, 43, 14), // "slot_threshold"
QT_MOC_LITERAL(5, 58, 5) // "value"

    },
    "bdLimiterWidget\0slot_enableProcess\0\0"
    "enable\0slot_threshold\0value"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_bdLimiterWidget[] = {

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
       1,    1,   24,    2, 0x08 /* Private */,
       4,    1,   27,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void, QMetaType::Double,    5,

       0        // eod
};

void bdLimiterWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        bdLimiterWidget *_t = static_cast<bdLimiterWidget *>(_o);
        switch (_id) {
        case 0: _t->slot_enableProcess((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 1: _t->slot_threshold((*reinterpret_cast< double(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject bdLimiterWidget::staticMetaObject = {
    { &bdGroupBox::staticMetaObject, qt_meta_stringdata_bdLimiterWidget.data,
      qt_meta_data_bdLimiterWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *bdLimiterWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *bdLimiterWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_bdLimiterWidget.stringdata))
        return static_cast<void*>(const_cast< bdLimiterWidget*>(this));
    return bdGroupBox::qt_metacast(_clname);
}

int bdLimiterWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = bdGroupBox::qt_metacall(_c, _id, _a);
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
