/****************************************************************************
** Meta object code from reading C++ file 'PictureEditor.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.5)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/PictureEditor/PictureEditor.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'PictureEditor.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.5. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_PictureEditor[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: signature, parameters, type, tag, flags
      27,   15,   14,   14, 0x05,
      45,   14,   14,   14, 0x05,

 // slots: signature, parameters, type, tag, flags
      64,   56,   14,   14, 0x08,

 // methods: signature, parameters, type, tag, flags
     118,  109,   14,   14, 0x02,

       0        // eod
};

static const char qt_meta_stringdata_PictureEditor[] = {
    "PictureEditor\0\0imageSource\0complete(QString)\0"
    "canceled()\0message\0"
    "onChildCardDone(bb::system::CardDoneMessage)\0"
    "filePath\0invokePictureEditor(QString)\0"
};

void PictureEditor::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        PictureEditor *_t = static_cast<PictureEditor *>(_o);
        switch (_id) {
        case 0: _t->complete((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 1: _t->canceled(); break;
        case 2: _t->onChildCardDone((*reinterpret_cast< const bb::system::CardDoneMessage(*)>(_a[1]))); break;
        case 3: _t->invokePictureEditor((*reinterpret_cast< QString(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData PictureEditor::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject PictureEditor::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_PictureEditor,
      qt_meta_data_PictureEditor, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &PictureEditor::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *PictureEditor::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *PictureEditor::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_PictureEditor))
        return static_cast<void*>(const_cast< PictureEditor*>(this));
    return QObject::qt_metacast(_clname);
}

int PictureEditor::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
void PictureEditor::complete(QString _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void PictureEditor::canceled()
{
    QMetaObject::activate(this, &staticMetaObject, 1, 0);
}
QT_END_MOC_NAMESPACE
