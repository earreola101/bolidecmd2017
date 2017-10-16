/****************************************************************************
** Meta object code from reading C++ file 'bdParametricEqualizerWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.4.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../Src/inc/bdParametricEqualizerWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'bdParametricEqualizerWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.4.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_bdParametricEqualizerWidget_t {
    QByteArrayData data[9];
    char stringdata[101];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_bdParametricEqualizerWidget_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_bdParametricEqualizerWidget_t qt_meta_stringdata_bdParametricEqualizerWidget = {
    {
QT_MOC_LITERAL(0, 0, 27), // "bdParametricEqualizerWidget"
QT_MOC_LITERAL(1, 28, 18), // "slot_enableProcess"
QT_MOC_LITERAL(2, 47, 0), // ""
QT_MOC_LITERAL(3, 48, 6), // "enable"
QT_MOC_LITERAL(4, 55, 15), // "slot_resetGains"
QT_MOC_LITERAL(5, 71, 9), // "slot_hsFc"
QT_MOC_LITERAL(6, 81, 2), // "fc"
QT_MOC_LITERAL(7, 84, 11), // "slot_hsGain"
QT_MOC_LITERAL(8, 96, 4) // "gain"

    },
    "bdParametricEqualizerWidget\0"
    "slot_enableProcess\0\0enable\0slot_resetGains\0"
    "slot_hsFc\0fc\0slot_hsGain\0gain"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_bdParametricEqualizerWidget[] = {

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
       1,    1,   34,    2, 0x08 /* Private */,
       4,    0,   37,    2, 0x08 /* Private */,
       5,    1,   38,    2, 0x08 /* Private */,
       7,    1,   41,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    6,
    QMetaType::Void, QMetaType::Double,    8,

       0        // eod
};

void bdParametricEqualizerWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        bdParametricEqualizerWidget *_t = static_cast<bdParametricEqualizerWidget *>(_o);
        switch (_id) {
        case 0: _t->slot_enableProcess((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 1: _t->slot_resetGains(); break;
        case 2: _t->slot_hsFc((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 3: _t->slot_hsGain((*reinterpret_cast< double(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject bdParametricEqualizerWidget::staticMetaObject = {
    { &bdGroupBox::staticMetaObject, qt_meta_stringdata_bdParametricEqualizerWidget.data,
      qt_meta_data_bdParametricEqualizerWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *bdParametricEqualizerWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *bdParametricEqualizerWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_bdParametricEqualizerWidget.stringdata))
        return static_cast<void*>(const_cast< bdParametricEqualizerWidget*>(this));
    return bdGroupBox::qt_metacast(_clname);
}

int bdParametricEqualizerWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
struct qt_meta_stringdata_bdPeqSlider_t {
    QByteArrayData data[7];
    char stringdata[78];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_bdPeqSlider_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_bdPeqSlider_t qt_meta_stringdata_bdPeqSlider = {
    {
QT_MOC_LITERAL(0, 0, 11), // "bdPeqSlider"
QT_MOC_LITERAL(1, 12, 16), // "slot_sliderValue"
QT_MOC_LITERAL(2, 29, 0), // ""
QT_MOC_LITERAL(3, 30, 5), // "value"
QT_MOC_LITERAL(4, 36, 11), // "slot_enable"
QT_MOC_LITERAL(5, 48, 14), // "slot_gainValue"
QT_MOC_LITERAL(6, 63, 14) // "slot_freqValue"

    },
    "bdPeqSlider\0slot_sliderValue\0\0value\0"
    "slot_enable\0slot_gainValue\0slot_freqValue"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_bdPeqSlider[] = {

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
       1,    1,   34,    2, 0x0a /* Public */,
       4,    1,   37,    2, 0x0a /* Public */,
       5,    1,   40,    2, 0x0a /* Public */,
       6,    1,   43,    2, 0x0a /* Public */,

 // slots: parameters
    QMetaType::Void, QMetaType::Int,    3,
    QMetaType::Void, QMetaType::Int,    3,
    QMetaType::Void, QMetaType::Double,    3,
    QMetaType::Void, QMetaType::Int,    3,

       0        // eod
};

void bdPeqSlider::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        bdPeqSlider *_t = static_cast<bdPeqSlider *>(_o);
        switch (_id) {
        case 0: _t->slot_sliderValue((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 1: _t->slot_enable((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 2: _t->slot_gainValue((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 3: _t->slot_freqValue((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject bdPeqSlider::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_bdPeqSlider.data,
      qt_meta_data_bdPeqSlider,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *bdPeqSlider::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *bdPeqSlider::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_bdPeqSlider.stringdata))
        return static_cast<void*>(const_cast< bdPeqSlider*>(this));
    return QWidget::qt_metacast(_clname);
}

int bdPeqSlider::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
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
