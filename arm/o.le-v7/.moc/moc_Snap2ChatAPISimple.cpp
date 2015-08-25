/****************************************************************************
** Meta object code from reading C++ file 'Snap2ChatAPISimple.hpp'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.5)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/Snap2ChatAPI/Snap2ChatAPISimple.hpp"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'Snap2ChatAPISimple.hpp' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.5. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_Snap2ChatAPISimple[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      17,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       5,       // signalCount

 // signals: signature, parameters, type, tag, flags
      33,   20,   19,   19, 0x05,
      82,   55,   19,   19, 0x05,
     129,  116,   19,   19, 0x05,
     152,  116,   19,   19, 0x05,
     176,   19,   19,   19, 0x05,

 // slots: signature, parameters, type, tag, flags
     183,   19,   19,   19, 0x08,
     196,   19,   19,   19, 0x08,
     218,   19,   19,   19, 0x08,
     245,   19,   19,   19, 0x08,

 // methods: signature, parameters, type, tag, flags
     271,  264,   19,   19, 0x02,
     289,  264,   19,   19, 0x02,
     306,  264,   19,   19, 0x02,
     325,  264,   19,   19, 0x02,
     349,  264,   19,   19, 0x02,
     375,  264,   19,   19, 0x02,
     401,  264,   19,   19, 0x02,
     430,  264,   19,   19, 0x02,

       0        // eod
};

static const char qt_meta_stringdata_Snap2ChatAPISimple[] = {
    "Snap2ChatAPISimple\0\0realFileName\0"
    "downloadDone(QString)\0response,httpcode,endpoint\0"
    "complete(QString,QString,QString)\0"
    "resultObject\0completeSnap(QVariant)\0"
    "completeStory(QVariant)\0test()\0"
    "onComplete()\0onDownloadCompleted()\0"
    "onDownloadCompletedStory()\0"
    "downloadFinished()\0params\0request(QVariant)\0"
    "upload(QVariant)\0download(QVariant)\0"
    "downloadStory(QVariant)\0"
    "downloadCaptcha(QVariant)\0"
    "kellyGetRequest(QVariant)\0"
    "kellyUploadProfile(QVariant)\0"
    "kellyUploadShout(QVariant)\0"
};

void Snap2ChatAPISimple::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        Snap2ChatAPISimple *_t = static_cast<Snap2ChatAPISimple *>(_o);
        switch (_id) {
        case 0: _t->downloadDone((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 1: _t->complete((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2])),(*reinterpret_cast< QString(*)>(_a[3]))); break;
        case 2: _t->completeSnap((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 3: _t->completeStory((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 4: _t->test(); break;
        case 5: _t->onComplete(); break;
        case 6: _t->onDownloadCompleted(); break;
        case 7: _t->onDownloadCompletedStory(); break;
        case 8: _t->downloadFinished(); break;
        case 9: _t->request((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 10: _t->upload((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 11: _t->download((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 12: _t->downloadStory((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 13: _t->downloadCaptcha((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 14: _t->kellyGetRequest((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 15: _t->kellyUploadProfile((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 16: _t->kellyUploadShout((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData Snap2ChatAPISimple::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject Snap2ChatAPISimple::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Snap2ChatAPISimple,
      qt_meta_data_Snap2ChatAPISimple, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &Snap2ChatAPISimple::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *Snap2ChatAPISimple::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *Snap2ChatAPISimple::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_Snap2ChatAPISimple))
        return static_cast<void*>(const_cast< Snap2ChatAPISimple*>(this));
    return QObject::qt_metacast(_clname);
}

int Snap2ChatAPISimple::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 17)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 17;
    }
    return _id;
}

// SIGNAL 0
void Snap2ChatAPISimple::downloadDone(QString _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void Snap2ChatAPISimple::complete(QString _t1, QString _t2, QString _t3)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void Snap2ChatAPISimple::completeSnap(QVariant _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void Snap2ChatAPISimple::completeStory(QVariant _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void Snap2ChatAPISimple::test()
{
    QMetaObject::activate(this, &staticMetaObject, 4, 0);
}
QT_END_MOC_NAMESPACE
