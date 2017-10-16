/****************************************************************************
** Meta object code from reading C++ file 'ecCommandWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/ecCommandWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ecCommandWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_ecCommandWidget_t {
    QByteArrayData data[4];
    char stringdata[56];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_ecCommandWidget_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_ecCommandWidget_t qt_meta_stringdata_ecCommandWidget = {
    {
QT_MOC_LITERAL(0, 0, 15), // "ecCommandWidget"
QT_MOC_LITERAL(1, 16, 15), // "slot_updateList"
QT_MOC_LITERAL(2, 32, 0), // ""
QT_MOC_LITERAL(3, 33, 22) // "slot_sendCmdStringSlot"

    },
    "ecCommandWidget\0slot_updateList\0\0"
    "slot_sendCmdStringSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_ecCommandWidget[] = {

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
       1,    0,   24,    2, 0x0a /* Public */,
       3,    0,   25,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void ecCommandWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        ecCommandWidget *_t = static_cast<ecCommandWidget *>(_o);
        switch (_id) {
        case 0: _t->slot_updateList(); break;
        case 1: _t->slot_sendCmdStringSlot(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

const QMetaObject ecCommandWidget::staticMetaObject = {
    { &bdGroupBox::staticMetaObject, qt_meta_stringdata_ecCommandWidget.data,
      qt_meta_data_ecCommandWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *ecCommandWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ecCommandWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_ecCommandWidget.stringdata))
        return static_cast<void*>(const_cast< ecCommandWidget*>(this));
    return bdGroupBox::qt_metacast(_clname);
}

int ecCommandWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
