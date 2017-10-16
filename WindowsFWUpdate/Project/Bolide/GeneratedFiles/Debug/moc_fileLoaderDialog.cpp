/****************************************************************************
** Meta object code from reading C++ file 'fileLoaderDialog.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/fileLoaderDialog.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'fileLoaderDialog.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_fileLoaderDialog_t {
    QByteArrayData data[6];
    char stringdata[121];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_fileLoaderDialog_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_fileLoaderDialog_t qt_meta_stringdata_fileLoaderDialog = {
    {
QT_MOC_LITERAL(0, 0, 16), // "fileLoaderDialog"
QT_MOC_LITERAL(1, 17, 26), // "slot_openFileButtonClicked"
QT_MOC_LITERAL(2, 44, 0), // ""
QT_MOC_LITERAL(3, 45, 24), // "slot_updateButtonClicked"
QT_MOC_LITERAL(4, 70, 25), // "slot_fileTransferComplete"
QT_MOC_LITERAL(5, 96, 24) // "slot_increaseProgressBar"

    },
    "fileLoaderDialog\0slot_openFileButtonClicked\0"
    "\0slot_updateButtonClicked\0"
    "slot_fileTransferComplete\0"
    "slot_increaseProgressBar"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_fileLoaderDialog[] = {

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
       1,    0,   34,    2, 0x08 /* Private */,
       3,    0,   35,    2, 0x08 /* Private */,
       4,    0,   36,    2, 0x08 /* Private */,
       5,    1,   37,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    2,

       0        // eod
};

void fileLoaderDialog::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        fileLoaderDialog *_t = static_cast<fileLoaderDialog *>(_o);
        switch (_id) {
        case 0: _t->slot_openFileButtonClicked(); break;
        case 1: _t->slot_updateButtonClicked(); break;
        case 2: _t->slot_fileTransferComplete(); break;
        case 3: _t->slot_increaseProgressBar((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject fileLoaderDialog::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_fileLoaderDialog.data,
      qt_meta_data_fileLoaderDialog,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *fileLoaderDialog::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *fileLoaderDialog::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_fileLoaderDialog.stringdata))
        return static_cast<void*>(const_cast< fileLoaderDialog*>(this));
    return QDialog::qt_metacast(_clname);
}

int fileLoaderDialog::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
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
struct qt_meta_stringdata_sendFwThread_t {
    QByteArrayData data[4];
    char stringdata[69];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_sendFwThread_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_sendFwThread_t qt_meta_stringdata_sendFwThread = {
    {
QT_MOC_LITERAL(0, 0, 12), // "sendFwThread"
QT_MOC_LITERAL(1, 13, 27), // "signal_fileTransferComplete"
QT_MOC_LITERAL(2, 41, 0), // ""
QT_MOC_LITERAL(3, 42, 26) // "signal_increaseProgressBar"

    },
    "sendFwThread\0signal_fileTransferComplete\0"
    "\0signal_increaseProgressBar"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_sendFwThread[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   24,    2, 0x06 /* Public */,
       3,    1,   25,    2, 0x06 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    2,

       0        // eod
};

void sendFwThread::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        sendFwThread *_t = static_cast<sendFwThread *>(_o);
        switch (_id) {
        case 0: _t->signal_fileTransferComplete(); break;
        case 1: _t->signal_increaseProgressBar((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (sendFwThread::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&sendFwThread::signal_fileTransferComplete)) {
                *result = 0;
            }
        }
        {
            typedef void (sendFwThread::*_t)(int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&sendFwThread::signal_increaseProgressBar)) {
                *result = 1;
            }
        }
    }
}

const QMetaObject sendFwThread::staticMetaObject = {
    { &QThread::staticMetaObject, qt_meta_stringdata_sendFwThread.data,
      qt_meta_data_sendFwThread,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *sendFwThread::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *sendFwThread::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_sendFwThread.stringdata))
        return static_cast<void*>(const_cast< sendFwThread*>(this));
    return QThread::qt_metacast(_clname);
}

int sendFwThread::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QThread::qt_metacall(_c, _id, _a);
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

// SIGNAL 0
void sendFwThread::signal_fileTransferComplete()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void sendFwThread::signal_increaseProgressBar(int _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_END_MOC_NAMESPACE
