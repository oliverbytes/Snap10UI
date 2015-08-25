/****************************************************************************
** Meta object code from reading C++ file 'applicationui.hpp'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.5)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/applicationui.hpp"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'applicationui.hpp' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.5. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_StatusThread[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: signature, parameters, type, tag, flags
      16,   14,   13,   13, 0x05,

       0        // eod
};

static const char qt_meta_stringdata_StatusThread[] = {
    "StatusThread\0\0,\0"
    "statusChanged(camera_devstatus_t,uint16_t)\0"
};

void StatusThread::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        StatusThread *_t = static_cast<StatusThread *>(_o);
        switch (_id) {
        case 0: _t->statusChanged((*reinterpret_cast< camera_devstatus_t(*)>(_a[1])),(*reinterpret_cast< uint16_t(*)>(_a[2]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData StatusThread::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject StatusThread::staticMetaObject = {
    { &QThread::staticMetaObject, qt_meta_stringdata_StatusThread,
      qt_meta_data_StatusThread, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &StatusThread::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *StatusThread::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *StatusThread::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_StatusThread))
        return static_cast<void*>(const_cast< StatusThread*>(this));
    return QThread::qt_metacast(_clname);
}

int StatusThread::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QThread::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}

// SIGNAL 0
void StatusThread::statusChanged(camera_devstatus_t _t1, uint16_t _t2)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
static const uint qt_meta_data_ApplicationUI[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
     121,   14, // methods
      11,  619, // properties
       2,  663, // enums/sets
       0,    0, // constructors
       0,       // flags
      31,       // signalCount

 // signals: signature, parameters, type, tag, flags
      15,   14,   14,   14, 0x05,
      36,   14,   14,   14, 0x05,
      61,   56,   14,   14, 0x05,
      92,   14,   14,   14, 0x05,
     109,   56,   14,   14, 0x05,
     149,  143,   14,   14, 0x05,
     176,   56,   14,   14, 0x05,
     200,   14,   14,   14, 0x05,
     233,   14,   14,   14, 0x05,
     252,   14,   14,   14, 0x05,
     288,  277,   14,   14, 0x05,
     347,  318,   14,   14, 0x05,
     387,   14,   14,   14, 0x05,
     410,  277,   14,   14, 0x05,
     443,   14,   14,   14, 0x05,
     464,   14,   14,   14, 0x05,
     487,   14,   14,   14, 0x05,
     507,   14,   14,   14, 0x05,
     527,   14,   14,   14, 0x05,
     546,   14,   14,   14, 0x05,
     575,   14,   14,   14, 0x05,
     601,   14,   14,   14, 0x05,
     631,   14,   14,   14, 0x05,
     653,   14,   14,   14, 0x05,
     681,   14,   14,   14, 0x05,
     708,   14,   14,   14, 0x05,
     732,   14,   14,   14, 0x05,
     756,   14,   14,   14, 0x05,
     780,   14,   14,   14, 0x05,
     807,   14,   14,   14, 0x05,
     828,   14,   14,   14, 0x05,

 // slots: signature, parameters, type, tag, flags
     865,  851,   14,   14, 0x0a,
     916,   14,   14,   14, 0x0a,
     942,  928,   14,   14, 0x0a,
     983,  979,   14,   14, 0x0a,
    1019, 1006,   14,   14, 0x0a,
    1064,   14,   14,   14, 0x0a,
    1079,   14,   14,   14, 0x0a,
    1093,   14,   14,   14, 0x0a,
    1136, 1107,   14,   14, 0x0a,
    1235,   14,   14,   14, 0x0a,
    1271, 1265,   14,   14, 0x0a,
    1308,   14,   14,   14, 0x0a,
    1324,   14,   14,   14, 0x0a,
    1336,   14,   14,   14, 0x0a,
    1348,   14,   14,   14, 0x0a,
    1367, 1363,   14,   14, 0x0a,
    1385,   14,   14,   14, 0x08,
    1424,   14,   14,   14, 0x08,

 // methods: signature, parameters, type, tag, flags
    1464, 1460,   14,   14, 0x02,
    1488,   14,   14,   14, 0x02,
    1502,   14,   14,   14, 0x02,
    1508,   56,   14,   14, 0x02,
    1536,   14, 1528,   14, 0x02,
    1581, 1560, 1555,   14, 0x02,
    1649, 1606,   14,   14, 0x02,
    1698,   14, 1555,   14, 0x02,
    1727, 1722, 1718,   14, 0x02,
    1753, 1722, 1718,   14, 0x02,
    1779,   14, 1718,   14, 0x02,
    1799, 1793,   14,   14, 0x02,
    1823, 1818,   14,   14, 0x02,
    1856, 1793,   14,   14, 0x02,
    1876,   14,   14,   14, 0x02,
    1893,   14,   14,   14, 0x02,
    1910, 1818, 1718,   14, 0x02,
    1928,   14, 1718,   14, 0x02,
    1945,   14, 1718,   14, 0x02,
    1955,   14,   14,   14, 0x02,
    1991,   14, 1984,   14, 0x02,
    2006,   14,   14,   14, 0x02,
    2031, 2025,   14,   14, 0x02,
    2056, 2025,   14,   14, 0x02,
    2080, 2025,   14,   14, 0x02,
    2107, 2104,   14,   14, 0x02,
    2151, 2135,   14,   14, 0x02,
    2187, 2172,   14,   14, 0x02,
    2210,   14,   14,   14, 0x02,
    2226,  277,   14,   14, 0x02,
    2250,   14,   14,   14, 0x02,
    2267,   14,   14,   14, 0x02,
    2281,   14,   14,   14, 0x02,
    2295,   14,   14,   14, 0x02,
    2310,   14,   14,   14, 0x02,
    2327,   14,   14,   14, 0x02,
    2340,   14,   14,   14, 0x02,
    2387, 2363,   14,   14, 0x02,
    2427, 2412,   14,   14, 0x02,
    2488, 2476,   14,   14, 0x02,
    2517, 2507, 1555,   14, 0x02,
    2543,   14, 1718,   14, 0x02,
    2562,   14, 1718,   14, 0x02,
    2580, 2104, 1528,   14, 0x02,
    2607, 2104, 1528,   14, 0x02,
    2628,   14, 1528,   14, 0x02,
    2664, 2651,   14,   14, 0x02,
    2722, 2703,   14,   14, 0x02,
    2766, 2759,   14,   14, 0x02,
    2793, 2789,   14,   14, 0x02,
    2827, 2822, 2816,   14, 0x02,
    2867, 2850,   14,   14, 0x02,
    2902, 2892,   14,   14, 0x02,
    2938, 2927,   14,   14, 0x02,
    2962,   14,   14,   14, 0x02,
    2983,   14,   14,   14, 0x02,
    3010,   14, 1528,   14, 0x02,
    3024,   14, 1528,   14, 0x02,
    3047, 3038,   14,   14, 0x02,
    3076, 3068,   14,   14, 0x02,
    3098, 3068,   14,   14, 0x02,
    3134, 3129,   14,   14, 0x02,
    3164, 3153,   14,   14, 0x02,
    3216, 3192, 1528,   14, 0x02,
    3266, 3244,   14,   14, 0x02,
    3301, 3294, 1555,   14, 0x02,
    3321, 3294, 1555,   14, 0x02,
    3355, 3349, 1528,   14, 0x02,
    3377, 3372,   14,   14, 0x02,
    3412,   14,   14,   14, 0x02,
    3448, 3439, 1718,   14, 0x02,
    3469, 3439, 1555,   14, 0x02,

 // properties: name, type, flags
    3492, 1718, 0x02495103,
    3499, 1555, 0x01495103,
    3512, 1555, 0x01495001,
    3539, 3528, 0x00495009,
    3557, 3550, 0x00495009,
    3564, 1555, 0x01495001,
    3579, 1555, 0x01495001,
    3593, 1555, 0x01495001,
    3604, 1555, 0x01495001,
    3615, 1555, 0x01495001,
    3626, 1555, 0x01495001,

 // properties: notify_signal_id
       8,
      20,
       9,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      30,

 // enums: name, flags, count, data
    3528, 0x0,    3,  671,
    3550, 0x0,    3,  677,

 // enum data: key, value
    3636, uint(ApplicationUI::UnitNone),
    3645, uint(ApplicationUI::UnitFront),
    3655, uint(ApplicationUI::UnitRear),
    3664, uint(ApplicationUI::ModeNone),
    3673, uint(ApplicationUI::ModePhoto),
    3683, uint(ApplicationUI::ModeVideo),

       0        // eod
};

static const char qt_meta_stringdata_ApplicationUI[] = {
    "ApplicationUI\0\0startLoadingSignal()\0"
    "stopLoadingSignal()\0data\0"
    "invokedExtendedSearch(QString)\0"
    "invokedCompose()\0invokedOpenConversation(QVariant)\0"
    "error\0cameraErrorSignal(QString)\0"
    "socketReceived(QString)\0"
    "initializeUploadingItemsSignal()\0"
    "tempIDChanged(int)\0cryptoAvailableChanged()\0"
    "parameters\0openCameraTabSignal(QVariant)\0"
    "fileLocation,mirror,attached\0"
    "openSnapEditorSignal(QString,bool,bool)\0"
    "openLoginSheetSignal()\0"
    "parseUpdatesJSONSignal(QVariant)\0"
    "openSettingsSignal()\0openAboutSheetSignal()\0"
    "loadUpdatesSignal()\0loadStoriesSignal()\0"
    "redrawTabsSignal()\0scrollBeginningFeedsSignal()\0"
    "purchasedAdsChanged(bool)\0"
    "cameraUnitChanged(CameraUnit)\0"
    "vfModeChanged(VfMode)\0hasFrontCameraChanged(bool)\0"
    "hasRearCameraChanged(bool)\0"
    "canDoPhotoChanged(bool)\0canDoVideoChanged(bool)\0"
    "canCaptureChanged(bool)\0"
    "suppressStartChanged(bool)\0"
    "captureComplete(int)\0capturingChanged(bool)\0"
    "resizeMessage\0"
    "cardResizeRequested(bb::system::CardResizeMessage)\0"
    "closeCard()\0invokeRequest\0"
    "onInvoked(bb::system::InvokeRequest)\0"
    "err\0onCaptureComplete(int)\0status,extra\0"
    "onStatusChanged(camera_devstatus_t,uint16_t)\0"
    "onFullscreen()\0onThumbnail()\0onInvisible()\0"
    "displayDirection,orientation\0"
    "onDisplayDirectionChanging(bb::cascades::DisplayDirection::Type,bb::ca"
    "scades::UIOrientation::Type)\0"
    "onOrientationReadingChanged()\0frame\0"
    "onVfParentLayoutFrameChanged(QRectF)\0"
    "newConnection()\0readyRead()\0connected()\0"
    "disconnected()\0msg\0cardDone(QString)\0"
    "resized(bb::system::CardResizeMessage)\0"
    "pooled(bb::system::CardDoneMessage)\0"
    "log\0writeLogToFile(QString)\0backUpCache()\0"
    "log()\0socketSend(QString)\0QString\0"
    "getEncryptionKey()\0bool\0filename,newfilename\0"
    "encrypt(QString,QString)\0"
    "filename,newfilename,encryptionMode,key,iv\0"
    "decrypt(QString,QString,QString,QString,QString)\0"
    "isCryptoAvailable()\0int\0unit\0"
    "setCameraUnit(CameraUnit)\0"
    "openCamera(camera_unit_t)\0closeCamera()\0"
    "onOff\0setFlashMode(bool)\0mode\0"
    "setFocusMode(camera_focusmode_t)\0"
    "setVideoLight(bool)\0minimizeCamera()\0"
    "maximizeCamera()\0setVfMode(VfMode)\0"
    "windowAttached()\0capture()\0"
    "checkSharedFilesPermission()\0qint64\0"
    "getCacheSize()\0initializeCamera()\0"
    "value\0flurrySetUserID(QString)\0"
    "flurryLogError(QString)\0flurryLogEvent(QString)\0"
    "id\0extractZippedVideo(QString)\0"
    "filename,folder\0zip(QString,QString)\0"
    "zipfile,folder\0unzip(QString,QString)\0"
    "openTheCamera()\0openCameraTab(QVariant)\0"
    "openLoginSheet()\0loadUpdates()\0"
    "loadStories()\0openSettings()\0"
    "openAboutSheet()\0redrawTabs()\0"
    "scrollBeginningFeeds()\0recipientNumber,message\0"
    "sendSMS(QString,QString)\0nbytes,ba,size\0"
    "write_bitmap_header(int,QByteArray&,const int[])\0"
    "orientation\0captureScreen(int)\0text,find\0"
    "contains(QString,QString)\0getDisplayHeight()\0"
    "getDisplayWidth()\0getContactPhoneNumber(int)\0"
    "getContactEmail(int)\0getCurrentPublicPath()\0"
    "to,body,send\0invokeSMSCompose(QString,QString,bool)\0"
    "email,subject,body\0"
    "invokeEmail(QString,QString,QString)\0"
    "appurl\0invokeBBWorld(QString)\0url\0"
    "invokeBrowser(QString)\0qreal\0_url\0"
    "getImageRotation(QUrl)\0imagePath,mirror\0"
    "preProcess(QString,bool)\0imagePath\0"
    "rotateCorrectly(QString)\0title,body\0"
    "notify(QString,QString)\0clearNotifications()\0"
    "clearNotificationEffects()\0getHomePath()\0"
    "getTempPath()\0fileName\0deletePhoto(QString)\0"
    "from,to\0copy(QString,QString)\0"
    "copyAndRemove(QString,QString)\0text\0"
    "showToast(QString)\0title,text\0"
    "showDialog(QString,QString)\0"
    "objectName,defaultValue\0"
    "getSetting(QString,QString)\0"
    "objectName,inputValue\0setSetting(QString,QString)\0"
    "folder\0wipeFolder(QString)\0"
    "wipeFolderContents(QString)\0limit\0"
    "getContacts(int)\0file\0"
    "invokeOpenWithMediaPlayer(QString)\0"
    "initializeUploadingItems()\0filename\0"
    "getFileSize(QString)\0validFileSize(QString)\0"
    "tempID\0purchasedAds\0cryptoAvailable\0"
    "CameraUnit\0cameraUnit\0VfMode\0vfMode\0"
    "hasFrontCamera\0hasRearCamera\0canDoPhoto\0"
    "canDoVideo\0canCapture\0capturing\0"
    "UnitNone\0UnitFront\0UnitRear\0ModeNone\0"
    "ModePhoto\0ModeVideo\0"
};

void ApplicationUI::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        ApplicationUI *_t = static_cast<ApplicationUI *>(_o);
        switch (_id) {
        case 0: _t->startLoadingSignal(); break;
        case 1: _t->stopLoadingSignal(); break;
        case 2: _t->invokedExtendedSearch((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 3: _t->invokedCompose(); break;
        case 4: _t->invokedOpenConversation((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 5: _t->cameraErrorSignal((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 6: _t->socketReceived((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 7: _t->initializeUploadingItemsSignal(); break;
        case 8: _t->tempIDChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 9: _t->cryptoAvailableChanged(); break;
        case 10: _t->openCameraTabSignal((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 11: _t->openSnapEditorSignal((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 12: _t->openLoginSheetSignal(); break;
        case 13: _t->parseUpdatesJSONSignal((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 14: _t->openSettingsSignal(); break;
        case 15: _t->openAboutSheetSignal(); break;
        case 16: _t->loadUpdatesSignal(); break;
        case 17: _t->loadStoriesSignal(); break;
        case 18: _t->redrawTabsSignal(); break;
        case 19: _t->scrollBeginningFeedsSignal(); break;
        case 20: _t->purchasedAdsChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 21: _t->cameraUnitChanged((*reinterpret_cast< CameraUnit(*)>(_a[1]))); break;
        case 22: _t->vfModeChanged((*reinterpret_cast< VfMode(*)>(_a[1]))); break;
        case 23: _t->hasFrontCameraChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 24: _t->hasRearCameraChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 25: _t->canDoPhotoChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 26: _t->canDoVideoChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 27: _t->canCaptureChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 28: _t->suppressStartChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 29: _t->captureComplete((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 30: _t->capturingChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 31: _t->cardResizeRequested((*reinterpret_cast< const bb::system::CardResizeMessage(*)>(_a[1]))); break;
        case 32: _t->closeCard(); break;
        case 33: _t->onInvoked((*reinterpret_cast< const bb::system::InvokeRequest(*)>(_a[1]))); break;
        case 34: _t->onCaptureComplete((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 35: _t->onStatusChanged((*reinterpret_cast< camera_devstatus_t(*)>(_a[1])),(*reinterpret_cast< uint16_t(*)>(_a[2]))); break;
        case 36: _t->onFullscreen(); break;
        case 37: _t->onThumbnail(); break;
        case 38: _t->onInvisible(); break;
        case 39: _t->onDisplayDirectionChanging((*reinterpret_cast< bb::cascades::DisplayDirection::Type(*)>(_a[1])),(*reinterpret_cast< bb::cascades::UIOrientation::Type(*)>(_a[2]))); break;
        case 40: _t->onOrientationReadingChanged(); break;
        case 41: _t->onVfParentLayoutFrameChanged((*reinterpret_cast< QRectF(*)>(_a[1]))); break;
        case 42: _t->newConnection(); break;
        case 43: _t->readyRead(); break;
        case 44: _t->connected(); break;
        case 45: _t->disconnected(); break;
        case 46: _t->cardDone((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 47: _t->resized((*reinterpret_cast< const bb::system::CardResizeMessage(*)>(_a[1]))); break;
        case 48: _t->pooled((*reinterpret_cast< const bb::system::CardDoneMessage(*)>(_a[1]))); break;
        case 49: _t->writeLogToFile((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 50: _t->backUpCache(); break;
        case 51: _t->log(); break;
        case 52: _t->socketSend((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 53: { QString _r = _t->getEncryptionKey();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 54: { bool _r = _t->encrypt((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        case 55: _t->decrypt((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2])),(*reinterpret_cast< QString(*)>(_a[3])),(*reinterpret_cast< QString(*)>(_a[4])),(*reinterpret_cast< QString(*)>(_a[5]))); break;
        case 56: { bool _r = _t->isCryptoAvailable();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        case 57: { int _r = _t->setCameraUnit((*reinterpret_cast< CameraUnit(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 58: { int _r = _t->openCamera((*reinterpret_cast< camera_unit_t(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 59: { int _r = _t->closeCamera();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 60: _t->setFlashMode((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 61: _t->setFocusMode((*reinterpret_cast< camera_focusmode_t(*)>(_a[1]))); break;
        case 62: _t->setVideoLight((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 63: _t->minimizeCamera(); break;
        case 64: _t->maximizeCamera(); break;
        case 65: { int _r = _t->setVfMode((*reinterpret_cast< VfMode(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 66: { int _r = _t->windowAttached();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 67: { int _r = _t->capture();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 68: _t->checkSharedFilesPermission(); break;
        case 69: { qint64 _r = _t->getCacheSize();
            if (_a[0]) *reinterpret_cast< qint64*>(_a[0]) = _r; }  break;
        case 70: _t->initializeCamera(); break;
        case 71: _t->flurrySetUserID((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 72: _t->flurryLogError((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 73: _t->flurryLogEvent((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 74: _t->extractZippedVideo((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 75: _t->zip((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 76: _t->unzip((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 77: _t->openTheCamera(); break;
        case 78: _t->openCameraTab((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 79: _t->openLoginSheet(); break;
        case 80: _t->loadUpdates(); break;
        case 81: _t->loadStories(); break;
        case 82: _t->openSettings(); break;
        case 83: _t->openAboutSheet(); break;
        case 84: _t->redrawTabs(); break;
        case 85: _t->scrollBeginningFeeds(); break;
        case 86: _t->sendSMS((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 87: _t->write_bitmap_header((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< QByteArray(*)>(_a[2])),(*reinterpret_cast< const int(*)[]>(_a[3]))); break;
        case 88: _t->captureScreen((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 89: { bool _r = _t->contains((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        case 90: { int _r = _t->getDisplayHeight();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 91: { int _r = _t->getDisplayWidth();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 92: { QString _r = _t->getContactPhoneNumber((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 93: { QString _r = _t->getContactEmail((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 94: { QString _r = _t->getCurrentPublicPath();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 95: _t->invokeSMSCompose((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 96: _t->invokeEmail((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2])),(*reinterpret_cast< QString(*)>(_a[3]))); break;
        case 97: _t->invokeBBWorld((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 98: _t->invokeBrowser((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 99: { qreal _r = _t->getImageRotation((*reinterpret_cast< QUrl(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< qreal*>(_a[0]) = _r; }  break;
        case 100: _t->preProcess((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2]))); break;
        case 101: _t->rotateCorrectly((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 102: _t->notify((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 103: _t->clearNotifications(); break;
        case 104: _t->clearNotificationEffects(); break;
        case 105: { QString _r = _t->getHomePath();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 106: { QString _r = _t->getTempPath();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 107: _t->deletePhoto((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 108: _t->copy((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 109: _t->copyAndRemove((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 110: _t->showToast((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 111: _t->showDialog((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 112: { QString _r = _t->getSetting((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 113: _t->setSetting((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 114: { bool _r = _t->wipeFolder((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        case 115: { bool _r = _t->wipeFolderContents((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        case 116: { QString _r = _t->getContacts((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 117: _t->invokeOpenWithMediaPlayer((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 118: _t->initializeUploadingItems(); break;
        case 119: { int _r = _t->getFileSize((*reinterpret_cast< QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        case 120: { bool _r = _t->validFileSize((*reinterpret_cast< QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        default: ;
        }
    }
}

const QMetaObjectExtraData ApplicationUI::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject ApplicationUI::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_ApplicationUI,
      qt_meta_data_ApplicationUI, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &ApplicationUI::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *ApplicationUI::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *ApplicationUI::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_ApplicationUI))
        return static_cast<void*>(const_cast< ApplicationUI*>(this));
    return QObject::qt_metacast(_clname);
}

int ApplicationUI::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 121)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 121;
    }
#ifndef QT_NO_PROPERTIES
      else if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< int*>(_v) = getTempID(); break;
        case 1: *reinterpret_cast< bool*>(_v) = getPurchasedAds(); break;
        case 2: *reinterpret_cast< bool*>(_v) = isCryptoAvailable(); break;
        case 3: *reinterpret_cast< CameraUnit*>(_v) = cameraUnit(); break;
        case 4: *reinterpret_cast< VfMode*>(_v) = vfMode(); break;
        case 5: *reinterpret_cast< bool*>(_v) = hasFrontCamera(); break;
        case 6: *reinterpret_cast< bool*>(_v) = hasRearCamera(); break;
        case 7: *reinterpret_cast< bool*>(_v) = canDoPhoto(); break;
        case 8: *reinterpret_cast< bool*>(_v) = canDoVideo(); break;
        case 9: *reinterpret_cast< bool*>(_v) = canCapture(); break;
        case 10: *reinterpret_cast< bool*>(_v) = capturing(); break;
        }
        _id -= 11;
    } else if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: setTempID(*reinterpret_cast< int*>(_v)); break;
        case 1: setPurchasedAds(*reinterpret_cast< bool*>(_v)); break;
        }
        _id -= 11;
    } else if (_c == QMetaObject::ResetProperty) {
        _id -= 11;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 11;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 11;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 11;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 11;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 11;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void ApplicationUI::startLoadingSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 0, 0);
}

// SIGNAL 1
void ApplicationUI::stopLoadingSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 1, 0);
}

// SIGNAL 2
void ApplicationUI::invokedExtendedSearch(QString _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void ApplicationUI::invokedCompose()
{
    QMetaObject::activate(this, &staticMetaObject, 3, 0);
}

// SIGNAL 4
void ApplicationUI::invokedOpenConversation(QVariant _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void ApplicationUI::cameraErrorSignal(QString _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void ApplicationUI::socketReceived(QString _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}

// SIGNAL 7
void ApplicationUI::initializeUploadingItemsSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 7, 0);
}

// SIGNAL 8
void ApplicationUI::tempIDChanged(int _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 8, _a);
}

// SIGNAL 9
void ApplicationUI::cryptoAvailableChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 9, 0);
}

// SIGNAL 10
void ApplicationUI::openCameraTabSignal(QVariant _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 10, _a);
}

// SIGNAL 11
void ApplicationUI::openSnapEditorSignal(QString _t1, bool _t2, bool _t3)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 11, _a);
}

// SIGNAL 12
void ApplicationUI::openLoginSheetSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 12, 0);
}

// SIGNAL 13
void ApplicationUI::parseUpdatesJSONSignal(QVariant _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 13, _a);
}

// SIGNAL 14
void ApplicationUI::openSettingsSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 14, 0);
}

// SIGNAL 15
void ApplicationUI::openAboutSheetSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 15, 0);
}

// SIGNAL 16
void ApplicationUI::loadUpdatesSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 16, 0);
}

// SIGNAL 17
void ApplicationUI::loadStoriesSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 17, 0);
}

// SIGNAL 18
void ApplicationUI::redrawTabsSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 18, 0);
}

// SIGNAL 19
void ApplicationUI::scrollBeginningFeedsSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 19, 0);
}

// SIGNAL 20
void ApplicationUI::purchasedAdsChanged(bool _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 20, _a);
}

// SIGNAL 21
void ApplicationUI::cameraUnitChanged(CameraUnit _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 21, _a);
}

// SIGNAL 22
void ApplicationUI::vfModeChanged(VfMode _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 22, _a);
}

// SIGNAL 23
void ApplicationUI::hasFrontCameraChanged(bool _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 23, _a);
}

// SIGNAL 24
void ApplicationUI::hasRearCameraChanged(bool _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 24, _a);
}

// SIGNAL 25
void ApplicationUI::canDoPhotoChanged(bool _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 25, _a);
}

// SIGNAL 26
void ApplicationUI::canDoVideoChanged(bool _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 26, _a);
}

// SIGNAL 27
void ApplicationUI::canCaptureChanged(bool _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 27, _a);
}

// SIGNAL 28
void ApplicationUI::suppressStartChanged(bool _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 28, _a);
}

// SIGNAL 29
void ApplicationUI::captureComplete(int _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 29, _a);
}

// SIGNAL 30
void ApplicationUI::capturingChanged(bool _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 30, _a);
}
QT_END_MOC_NAMESPACE
