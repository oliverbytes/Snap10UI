/****************************************************************************
** Meta object code from reading C++ file 'VideoEditor.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.5)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/VideoEditor/VideoEditor.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'VideoEditor.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.5. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_VideoEditor[] = {

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
      25,   13,   12,   12, 0x05,
      43,   12,   12,   12, 0x05,

 // slots: signature, parameters, type, tag, flags
      62,   54,   12,   12, 0x08,

 // methods: signature, parameters, type, tag, flags
     116,  107,   12,   12, 0x02,

       0        // eod
};

static const char qt_meta_stringdata_VideoEditor[] = {
    "VideoEditor\0\0videoSource\0complete(QString)\0"
    "canceled()\0message\0"
    "onChildCardDone(bb::system::CardDoneMessage)\0"
    "filePath\0invokeVideoEditor(QString)\0"
};

void VideoEditor::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        VideoEditor *_t = static_cast<VideoEditor *>(_o);
        switch (_id) {
        case 0: _t->complete((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 1: _t->canceled(); break;
        case 2: _t->onChildCardDone((*reinterpret_cast< const bb::system::CardDoneMessage(*)>(_a[1]))); break;
        case 3: _t->invokeVideoEditor((*reinterpret_cast< QString(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData VideoEditor::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject VideoEditor::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_VideoEditor,
      qt_meta_data_VideoEditor, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &VideoEditor::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *VideoEditor::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *VideoEditor::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_VideoEditor))
        return static_cast<void*>(const_cast< VideoEditor*>(this));
    return QObject::qt_metacast(_clname);
}

int VideoEditor::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
void VideoEditor::complete(QString _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void VideoEditor::canceled()
{
    QMetaObject::activate(this, &staticMetaObject, 1, 0);
}
QT_END_MOC_NAMESPACE
