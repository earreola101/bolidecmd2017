/****************************************************************************
** Meta object code from reading C++ file 'bolide.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/bolide.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'bolide.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_Bolide_t {
    QByteArrayData data[7];
    char stringdata[87];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Bolide_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Bolide_t qt_meta_stringdata_Bolide = {
    {
QT_MOC_LITERAL(0, 0, 6), // "Bolide"
QT_MOC_LITERAL(1, 7, 20), // "slot_tooManyDevError"
QT_MOC_LITERAL(2, 28, 0), // ""
QT_MOC_LITERAL(3, 29, 7), // "devType"
QT_MOC_LITERAL(4, 37, 21), // "slot_devStatusRefresh"
QT_MOC_LITERAL(5, 59, 16), // "system_status_t*"
QT_MOC_LITERAL(6, 76, 10) // "sys_status"

    },
    "Bolide\0slot_tooManyDevError\0\0devType\0"
    "slot_devStatusRefresh\0system_status_t*\0"
    "sys_status"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Bolide[] = {

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
    QMetaType::Void, QMetaType::Int,    3,
    QMetaType::Void, 0x80000000 | 5,    6,

       0        // eod
};

void Bolide::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Bolide *_t = static_cast<Bolide *>(_o);
        switch (_id) {
        case 0: _t->slot_tooManyDevError((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 1: _t->slot_devStatusRefresh((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject Bolide::staticMetaObject = {
    { &QMainWindow::staticMetaObject, qt_meta_stringdata_Bolide.data,
      qt_meta_data_Bolide,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *Bolide::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Bolide::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_Bolide.stringdata))
        return static_cast<void*>(const_cast< Bolide*>(this));
    return QMainWindow::qt_metacast(_clname);
}

int Bolide::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QMainWindow::qt_metacall(_c, _id, _a);
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
struct qt_meta_stringdata_recvThread_t {
    QByteArrayData data[26];
    char stringdata[356];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_recvThread_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_recvThread_t qt_meta_stringdata_recvThread = {
    {
QT_MOC_LITERAL(0, 0, 10), // "recvThread"
QT_MOC_LITERAL(1, 11, 21), // "signal_packetReceived"
QT_MOC_LITERAL(2, 33, 0), // ""
QT_MOC_LITERAL(3, 34, 7), // "timeout"
QT_MOC_LITERAL(4, 42, 22), // "signal_updateMicLabels"
QT_MOC_LITERAL(5, 65, 16), // "system_status_t*"
QT_MOC_LITERAL(6, 82, 10), // "sys_status"
QT_MOC_LITERAL(7, 93, 23), // "signal_devStatusRefresh"
QT_MOC_LITERAL(8, 117, 20), // "signal_updateConsole"
QT_MOC_LITERAL(9, 138, 6), // "sender"
QT_MOC_LITERAL(10, 145, 6), // "string"
QT_MOC_LITERAL(11, 152, 25), // "signal_updateProgressPerc"
QT_MOC_LITERAL(12, 178, 4), // "perc"
QT_MOC_LITERAL(13, 183, 25), // "signal_updateProgressInfo"
QT_MOC_LITERAL(14, 209, 5), // "char*"
QT_MOC_LITERAL(15, 215, 3), // "buf"
QT_MOC_LITERAL(16, 219, 26), // "signal_flashUpdateComplete"
QT_MOC_LITERAL(17, 246, 7), // "success"
QT_MOC_LITERAL(18, 254, 23), // "signal_resetAliveHubCnt"
QT_MOC_LITERAL(19, 278, 22), // "signal_tooManyDevError"
QT_MOC_LITERAL(20, 301, 7), // "devType"
QT_MOC_LITERAL(21, 309, 16), // "signal_updateCpu"
QT_MOC_LITERAL(22, 326, 2), // "id"
QT_MOC_LITERAL(23, 329, 3), // "cpu"
QT_MOC_LITERAL(24, 333, 16), // "slot_startThread"
QT_MOC_LITERAL(25, 350, 5) // "start"

    },
    "recvThread\0signal_packetReceived\0\0"
    "timeout\0signal_updateMicLabels\0"
    "system_status_t*\0sys_status\0"
    "signal_devStatusRefresh\0signal_updateConsole\0"
    "sender\0string\0signal_updateProgressPerc\0"
    "perc\0signal_updateProgressInfo\0char*\0"
    "buf\0signal_flashUpdateComplete\0success\0"
    "signal_resetAliveHubCnt\0signal_tooManyDevError\0"
    "devType\0signal_updateCpu\0id\0cpu\0"
    "slot_startThread\0start"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_recvThread[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      11,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
      10,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   69,    2, 0x06 /* Public */,
       4,    1,   72,    2, 0x06 /* Public */,
       7,    1,   75,    2, 0x06 /* Public */,
       8,    2,   78,    2, 0x06 /* Public */,
      11,    1,   83,    2, 0x06 /* Public */,
      13,    1,   86,    2, 0x06 /* Public */,
      16,    1,   89,    2, 0x06 /* Public */,
      18,    0,   92,    2, 0x06 /* Public */,
      19,    1,   93,    2, 0x06 /* Public */,
      21,    2,   96,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      24,    1,  101,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void, QMetaType::Bool,    3,
    QMetaType::Void, 0x80000000 | 5,    6,
    QMetaType::Void, 0x80000000 | 5,    6,
    QMetaType::Void, QMetaType::Int, QMetaType::QString,    9,   10,
    QMetaType::Void, QMetaType::Int,   12,
    QMetaType::Void, 0x80000000 | 14,   15,
    QMetaType::Void, QMetaType::Bool,   17,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,   20,
    QMetaType::Void, QMetaType::Int, QMetaType::Int,   22,   23,

 // slots: parameters
    QMetaType::Void, QMetaType::Bool,   25,

       0        // eod
};

void recvThread::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        recvThread *_t = static_cast<recvThread *>(_o);
        switch (_id) {
        case 0: _t->signal_packetReceived((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 1: _t->signal_updateMicLabels((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 2: _t->signal_devStatusRefresh((*reinterpret_cast< system_status_t*(*)>(_a[1]))); break;
        case 3: _t->signal_updateConsole((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 4: _t->signal_updateProgressPerc((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 5: _t->signal_updateProgressInfo((*reinterpret_cast< char*(*)>(_a[1]))); break;
        case 6: _t->signal_flashUpdateComplete((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 7: _t->signal_resetAliveHubCnt(); break;
        case 8: _t->signal_tooManyDevError((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 9: _t->signal_updateCpu((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2]))); break;
        case 10: _t->slot_startThread((*reinterpret_cast< bool(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (recvThread::*_t)(bool );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_packetReceived)) {
                *result = 0;
            }
        }
        {
            typedef void (recvThread::*_t)(system_status_t * );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_updateMicLabels)) {
                *result = 1;
            }
        }
        {
            typedef void (recvThread::*_t)(system_status_t * );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_devStatusRefresh)) {
                *result = 2;
            }
        }
        {
            typedef void (recvThread::*_t)(int , QString );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_updateConsole)) {
                *result = 3;
            }
        }
        {
            typedef void (recvThread::*_t)(int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_updateProgressPerc)) {
                *result = 4;
            }
        }
        {
            typedef void (recvThread::*_t)(char * );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_updateProgressInfo)) {
                *result = 5;
            }
        }
        {
            typedef void (recvThread::*_t)(bool );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_flashUpdateComplete)) {
                *result = 6;
            }
        }
        {
            typedef void (recvThread::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_resetAliveHubCnt)) {
                *result = 7;
            }
        }
        {
            typedef void (recvThread::*_t)(int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_tooManyDevError)) {
                *result = 8;
            }
        }
        {
            typedef void (recvThread::*_t)(int , int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&recvThread::signal_updateCpu)) {
                *result = 9;
            }
        }
    }
}

const QMetaObject recvThread::staticMetaObject = {
    { &QThread::staticMetaObject, qt_meta_stringdata_recvThread.data,
      qt_meta_data_recvThread,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *recvThread::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *recvThread::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_recvThread.stringdata))
        return static_cast<void*>(const_cast< recvThread*>(this));
    return QThread::qt_metacast(_clname);
}

int recvThread::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QThread::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 11)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 11)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 11;
    }
    return _id;
}

// SIGNAL 0
void recvThread::signal_packetReceived(bool _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void recvThread::signal_updateMicLabels(system_status_t * _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void recvThread::signal_devStatusRefresh(system_status_t * _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void recvThread::signal_updateConsole(int _t1, QString _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void recvThread::signal_updateProgressPerc(int _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void recvThread::signal_updateProgressInfo(char * _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void recvThread::signal_flashUpdateComplete(bool _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}

// SIGNAL 7
void recvThread::signal_resetAliveHubCnt()
{
    QMetaObject::activate(this, &staticMetaObject, 7, Q_NULLPTR);
}

// SIGNAL 8
void recvThread::signal_tooManyDevError(int _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 8, _a);
}

// SIGNAL 9
void recvThread::signal_updateCpu(int _t1, int _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 9, _a);
}
QT_END_MOC_NAMESPACE
