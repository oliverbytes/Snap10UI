/****************************************************************************
** Meta object code from reading C++ file 'SelfaceAPI.hpp'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.5)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/SelfaceAPI/SelfaceAPI.hpp"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'SelfaceAPI.hpp' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.5. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_SelfaceAPI[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: signature, parameters, type, tag, flags
      39,   12,   11,   11, 0x05,

 // slots: signature, parameters, type, tag, flags
      73,   11,   11,   11, 0x0a,

 // methods: signature, parameters, type, tag, flags
      93,   86,   11,   11, 0x02,
     107,   86,   11,   11, 0x02,

       0        // eod
};

static const char qt_meta_stringdata_SelfaceAPI[] = {
    "SelfaceAPI\0\0response,httpcode,endpoint\0"
    "complete(QString,QString,QString)\0"
    "onComplete()\0params\0get(QVariant)\0"
    "post(QVariant)\0"
};

void SelfaceAPI::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        SelfaceAPI *_t = static_cast<SelfaceAPI *>(_o);
        switch (_id) {
        case 0: _t->complete((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2])),(*reinterpret_cast< QString(*)>(_a[3]))); break;
        case 1: _t->onComplete(); break;
        case 2: _t->get((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 3: _t->post((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData SelfaceAPI::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject SelfaceAPI::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_SelfaceAPI,
      qt_meta_data_SelfaceAPI, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &SelfaceAPI::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *SelfaceAPI::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *SelfaceAPI::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_SelfaceAPI))
        return static_cast<void*>(const_cast< SelfaceAPI*>(this));
    return QObject::qt_metacast(_clname);
}

int SelfaceAPI::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    }
    return _id;
}

// SIGNAL 0
void SelfaceAPI::complete(QString _t1, QString _t2, QString _t3)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
