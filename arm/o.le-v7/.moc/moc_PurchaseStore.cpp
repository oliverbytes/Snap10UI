/****************************************************************************
** Meta object code from reading C++ file 'PurchaseStore.hpp'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.5)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/InAppPurchase/PurchaseStore.hpp"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'PurchaseStore.hpp' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.5. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_PurchaseStore[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: signature, parameters, type, tag, flags
      15,   14,   14,   14, 0x05,
      55,   40,   14,   14, 0x05,

 // slots: signature, parameters, type, tag, flags
      82,   14,   14,   14, 0x0a,
     106,   40,   14,   14, 0x0a,
     129,   14,   14,   14, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_PurchaseStore[] = {
    "PurchaseStore\0\0purchaseRecordsDeleted()\0"
    "digitalGoodSku\0purchaseRetrieved(QString)\0"
    "deletePurchaseRecords()\0storePurchase(QString)\0"
    "retrieveLocalPurchases()\0"
};

void PurchaseStore::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        PurchaseStore *_t = static_cast<PurchaseStore *>(_o);
        switch (_id) {
        case 0: _t->purchaseRecordsDeleted(); break;
        case 1: _t->purchaseRetrieved((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 2: _t->deletePurchaseRecords(); break;
        case 3: _t->storePurchase((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 4: _t->retrieveLocalPurchases(); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData PurchaseStore::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject PurchaseStore::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_PurchaseStore,
      qt_meta_data_PurchaseStore, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &PurchaseStore::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *PurchaseStore::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *PurchaseStore::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_PurchaseStore))
        return static_cast<void*>(const_cast< PurchaseStore*>(this));
    return QObject::qt_metacast(_clname);
}

int PurchaseStore::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }
    return _id;
}

// SIGNAL 0
void PurchaseStore::purchaseRecordsDeleted()
{
    QMetaObject::activate(this, &staticMetaObject, 0, 0);
}

// SIGNAL 1
void PurchaseStore::purchaseRetrieved(const QString & _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_END_MOC_NAMESPACE
