/****************************************************************************
** Meta object code from reading C++ file 'cmdGridWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/cmdGridWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'cmdGridWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_cmdGridWidget_t {
    QByteArrayData data[17];
    char stringdata[248];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_cmdGridWidget_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_cmdGridWidget_t qt_meta_stringdata_cmdGridWidget = {
    {
QT_MOC_LITERAL(0, 0, 13), // "cmdGridWidget"
QT_MOC_LITERAL(1, 14, 20), // "slot_printDeviceTree"
QT_MOC_LITERAL(2, 35, 0), // ""
QT_MOC_LITERAL(3, 36, 16), // "system_status_t*"
QT_MOC_LITERAL(4, 53, 10), // "sys_status"
QT_MOC_LITERAL(5, 64, 20), // "slot_updateMicLabels"
QT_MOC_LITERAL(6, 85, 20), // "slot_ledStatusAction"
QT_MOC_LITERAL(7, 106, 15), // "slot_muteAction"
QT_MOC_LITERAL(8, 122, 21), // "slot_postFilterAction"
QT_MOC_LITERAL(9, 144, 17), // "slot_listenAction"
QT_MOC_LITERAL(10, 162, 15), // "slot_clearDebug"
QT_MOC_LITERAL(11, 178, 19), // "slot_setMicPodDebug"
QT_MOC_LITERAL(12, 198, 21), // "slot_startStopPolling"
QT_MOC_LITERAL(13, 220, 5), // "start"
QT_MOC_LITERAL(14, 226, 14), // "slot_updateCpu"
QT_MOC_LITERAL(15, 241, 2), // "id"
QT_MOC_LITERAL(16, 244, 3) // "cpu"

    },
    "cmdGridWidget\0slot_printDeviceTree\0\0"
    "system_status_t*\0sys_status\0"
    "slot_updateMicLabels\0slot_ledStatusAction\0"
    "slot_muteAction\0slot_postFilterAction\0"
    "slot_listenAction\0slot_clearDebug\0"
    "slot_setMicPodDebug\0slot_startStopPolling\0"
    "start\0slot_updateCpu\0id\0cpu"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_cmdGridWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      10,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   64,    2, 0x0a /* Public */,
       5,    1,   67,    2, 0x0a /* Public */,
       6,    0,   70,    2, 0x08 /* Private */,
       7,    0,   71,    2, 0x08 /* Private */,
       8,    0,   72,    2, 0x08 /* Private */,
       9,    0,   73,    2, 0x08 /* Private */,
      10,    0,   74,    2, 0x08 /* Private */,
      11,    0,   75,    2, 0x08 /* Private */,
      12,    1,   76,    2, 0x08 /* Private */,
      14,    2,   79,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Bool,   13,
    QMetaType::Void, QMetaType::Int, QMetaType::Int,   15,   16,

       0        // eod
};

void cmdGridWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        cmdGridWidget *_t = static_cast<cmdGridWidget *>(_o);
        switch (_id) {
        case 0: _t->slot_printDeviceTree((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 1: _t->slot_updateMicLabels((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 2: _t->slot_ledStatusAction(); break;
        case 3: _t->slot_muteAction(); break;
        case 4: _t->slot_postFilterAction(); break;
        case 5: _t->slot_listenAction(); break;
        case 6: _t->slot_clearDebug(); break;
        case 7: _t->slot_setMicPodDebug(); break;
        case 8: _t->slot_startStopPolling((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 9: _t->slot_updateCpu((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2]))); break;
        default: ;
        }
    }
}

const QMetaObject cmdGridWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_cmdGridWidget.data,
      qt_meta_data_cmdGridWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *cmdGridWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *cmdGridWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_cmdGridWidget.stringdata))
        return static_cast<void*>(const_cast< cmdGridWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int cmdGridWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 10)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 10;
    }
    return _id;
}
struct qt_meta_stringdata_pollMicPodsThread_t {
    QByteArrayData data[1];
    char stringdata[18];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_pollMicPodsThread_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_pollMicPodsThread_t qt_meta_stringdata_pollMicPodsThread = {
    {
QT_MOC_LITERAL(0, 0, 17) // "pollMicPodsThread"

    },
    "pollMicPodsThread"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_pollMicPodsThread[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

       0        // eod
};

void pollMicPodsThread::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    Q_UNUSED(_o);
    Q_UNUSED(_id);
    Q_UNUSED(_c);
    Q_UNUSED(_a);
}

const QMetaObject pollMicPodsThread::staticMetaObject = {
    { &QThread::staticMetaObject, qt_meta_stringdata_pollMicPodsThread.data,
      qt_meta_data_pollMicPodsThread,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *pollMicPodsThread::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *pollMicPodsThread::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_pollMicPodsThread.stringdata))
        return static_cast<void*>(const_cast< pollMicPodsThread*>(this));
    return QThread::qt_metacast(_clname);
}

int pollMicPodsThread::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QThread::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    return _id;
}
QT_END_MOC_NAMESPACE
