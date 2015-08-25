#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

#include <bb/system/InvokeRequest>
#include <bb/cascades/Invocation>
#include <bb/system/SystemDialog>
#include <bb/system/SystemToast>
#include <QList>
#include <bb/PackageInfo>
#include <bb/PpsObject>

#include <libexif/exif-data.h>
#include <libexif/exif-tag.h>

#include <QtCore/QtCore>
#include <bb/device/DisplayInfo>
#include <bb/cascades/SceneCover>
#include <bb/device/HardwareInfo>

#include <screen/screen.h>
#include <bb/cascades/Window>

#include "math.h"

#include <bb/platform/Notification>
#include "ActiveFrame/ActiveFrameCover.h"

//#include <bb/pim/contacts/Contact>
//#include <bb/pim/contacts/ContactService.hpp>
//#include <bb/pim/account/AccountService>
//#include <bb/pim/account/Account>
//#include <bb/pim/account/Provider>
//#include <bb/pim/message/MessageSearchFilter>
//#include <bb/pim/message/MessageService>
//#include <bb/pim/message/MessageBuilder>
//#include <bb/pim/message/ConversationBuilder>
//#include <bb/pim/message/Attachment>

#include <bb/cascades/multimedia/CameraUnit>

#include "QuaZip/quazip.h"
#include "QuaZip/quazipfile.h"
#include "QuaZip/JlCompress.h"

//10.2
#include <bb/platform/NotificationDefaultApplicationSettings>

//using namespace bb::pim::account;
//using namespace bb::pim::message;

using namespace bb::platform;
using namespace bb::cascades;
using namespace bb::device;
using namespace bb::system;

using bb::PackageInfo;
using bb::PpsObject;
//using bb::pim::contacts::Contact;
//using bb::pim::contacts::ContactService;

#define DELTA(x, y) (x>y?(x-y):(y-x))

// BEST CAM

#include <bb/cascades/Window>
#include <bb/cascades/ForeignWindowControl>
#include <bb/cascades/OrientationSupport>
#include <bb/cascades/LayoutUpdateHandler>
#include <bps/soundplayer.h>
#include <fcntl.h>
#include <QtSensors/QOrientationSensor>
#include <camera/camera_h264avc.h>
#include <camera/camera_encoder.h>
#include <camera/camera_api.h>
//#include <bb/pim/contacts/ContactListFilters>
//#include <bb/pim/contacts/ContactAttribute>

#include <bb/system/CardResizeMessage>
#include <bb/system/CardDoneMessage>

// AES

#include <huaes.h>
#include <sbreturn.h>
#include <hurandom.h>
#include <string.h>

#include "Encryption/AESParams.hpp"
#include "Encryption/AESKey.hpp"
#include "Encryption/DRBG.hpp"
#include "Encryption/SBError.hpp"
#include "Snap2ChatAPI/Snap2ChatAPIData.hpp"

#include <QtNetwork/QTcpSocket>
#include <QtNetwork/QTcpServer>

#include <bb/system/InvokeRequest>
#include <bb/system/InvokeTargetReply>

#include "Flurry.h"

using namespace QtMobility;
//using bb::pim::contacts::ContactListFilters;
//using bb::pim::contacts::ContactAttribute;

#define RETRY_MS    1000
#define RETRY_DELAY (RETRY_MS/10)

#define Q10_W 720
#define Q10_H 720

#define Z10_W 768
#define Z10_H 1280

#define Z30_W 720
#define Z30_H 1280

#define PHONE_W Q10_W
#define PHONE_H Q10_W

// BEST CAM

const QString BLOB_ENCRYPTION_KEY 		= "M02cnQ51Ji97vwT4";
const QString ApplicationUI::AUTHOR 	= "NEMORY";
const QString ApplicationUI::APPNAME 	= "SNAP2CHAT";

bool socketConnected = false;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
    QObject(app),
	mUnit(CAMERA_UNIT_NONE),
	mHandle(CAMERA_HANDLE_INVALID),
	mState(StateIdle),
	mDeferredResourceWarning(false),
	mStatusThread(NULL),
	mApp(app),
	mRequireUprightVf(false),
	mRequireUprightCapture(false),
	mOrientationSensor(NULL),
	mVideoFileDescriptor(-1),
	mPhotoRotations(NULL),
	mPhotoVfRotations(NULL),
	mVideoRotations(NULL),
	mVideoVfRotations(NULL),
	mPhotoResolutions(NULL),
	mPhotoVfResolutions(NULL),
	mVideoResolutions(NULL),
	mVideoVfResolutions(NULL),
	invokeManager(new InvokeManager(this)),
	_app(app)
	,m_port(9876)
{
    m_server = new QTcpServer(this);
    connect(m_server, SIGNAL(newConnection()), this, SLOT(newConnection()));
    listen();

	_qml = QmlDocument::create("qrc:/assets/main.qml").parent(this);
	_qml->setContextProperty("_app", this);

    Snap2ChatAPIData *_snap2chatAPIData = new Snap2ChatAPIData();
    _qml->setContextProperty("_snap2chatAPIData", _snap2chatAPIData);

    ActiveFrameCover *activeFrame = new ActiveFrameCover();
	Application::instance()->setCover(activeFrame);
	_qml->setContextProperty("_activeFrame", activeFrame);

	PackageInfo packageInfo;
	QDeclarativePropertyMap* map = new QDeclarativePropertyMap(this);
	map->setProperty("version", packageInfo.version());
	map->setProperty("author", packageInfo.author());
	_qml->setContextProperty("_packageInfo", map);

	_root = _qml->createRootObject<AbstractPane>();
    app->setScene(_root);

    mFwc = _root->findChild<ForeignWindowControl*>("vfForeignWindow");

    // -------------------- PRO USERS -------------------- //

    //setSetting("purchasedAds", "true");

    // -------------------- PRO USERS -------------------- //

    purchasedAds        = getSetting("purchasedAds", "false") == "true";
    //purchasedAds    = true;
    setPurchasedAds(purchasedAds);

    QDir dir;
    dir.mkpath("data/files");
    dir.mkpath("data/files/captcha");
    dir.mkpath("data/files/blobs");
    dir.mkpath("data/files/sent");
}

void ApplicationUI::writeLogToFile(QString log)
{
    QFile file("data/LOGFILE.txt");
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out << log;
    file.close();
}

bool ApplicationUI::validFileSize(QString filename)
{
    bool valid = false;

    double maxFileSize = 1153433.6;
    double minFileSize = 10;
    double fileSize    = getFileSize(filename);

    qDebug() << "SIZE: " << fileSize << ", MAX: " << maxFileSize << ", FILE: " << filename;

    if(fileSize <= maxFileSize && fileSize > minFileSize)
    {
        valid = true;
    }

    return valid;
}

int ApplicationUI::getFileSize(QString filename)
{
    QFile file(filename);
    int fileSize = file.size();
    file.close();

    qDebug() << "FILE SIZE: " << fileSize;

    return fileSize;
}

bool ApplicationUI::getPurchasedAds()
{
    return purchasedAds;
}

void ApplicationUI::setPurchasedAds(bool value)
{
    purchasedAds = value;
    emit purchasedAdsChanged(value);
}

void ApplicationUI::initializeCamera()
{
    _tempID = 0;
    emit tempIDChanged(_tempID);

    // BEST CAM

    //qmlRegisterUncreatableType<ApplicationUI>("nemory.Camera", 1, 0, "NemCamera", "NemCamera is uncreatable");
    qRegisterMetaType<camera_devstatus_t>("camera_devstatus_t");
    qRegisterMetaType<uint16_t>("uint16_t");

    LayoutUpdateHandler::create((bb::cascades::Control*)(mFwc->parent())).onLayoutFrameChanged(this, SLOT(onVfParentLayoutFrameChanged(QRectF)));

    if (!QObject::connect(this, SIGNAL(captureComplete(int)), this, SLOT(onCaptureComplete(int))))
    {
        qDebug() << "failed to connect captureComplete signal";
    }

    if (!QObject::connect(OrientationSupport::instance(),
                          SIGNAL(displayDirectionAboutToChange(bb::cascades::DisplayDirection::Type, \
                                                               bb::cascades::UIOrientation::Type)), this,
                          SLOT(onDisplayDirectionChanging(bb::cascades::DisplayDirection::Type, \
                                                          bb::cascades::UIOrientation::Type))))
    {
        qDebug() << "failed to connect displayDirectionAboutToChange signal";
    }

    if (startOrientationReadings() != EOK)
    {
        qDebug() << "failed to connect to orientation sensor?";
    }

    OrientationSupport::instance()->setSupportedDisplayOrientation(SupportedDisplayOrientation::All);
    mDisplayDirection = OrientationSupport::instance()->displayDirection();
    mOrientationDirection = mDisplayDirection;

    updateAngles();

//    if(getSetting("enhanceVideoRecorderFix", "true") == "true")
//    {
//        setSetting("enhanceVideoRecorder", "false");
//        setSetting("enhanceVideoRecorderFix", "false");
//    }
//
//    if(getSetting("enhanceVideoRecorder", "false") == "true")
//    {
//        camera_init_video_encoder();
//    }

    inventoryCameras();
    emit canCaptureChanged(mCanCapture = false);
    emit capturingChanged(mCapturing = false);

    if (mHasRearCamera)
    {
        mUnit = CAMERA_UNIT_REAR;
    }
    else if (mHasFrontCamera)
    {
        mUnit = CAMERA_UNIT_FRONT;
    }
    else
    {
        mUnit = CAMERA_UNIT_NONE;
    }

    mResumeVfMode = ModePhoto;
    setCameraUnit((CameraUnit)mUnit);
    setVfMode(ModePhoto);

    // BEST CAM

    // 10.2
    bb::platform::NotificationDefaultApplicationSettings notificationSettings;
    notificationSettings.setPreview(bb::platform::NotificationPriorityPolicy::Allow);
    notificationSettings.apply();

    if (!isCryptoAvailable())
    {
       qDebug() << "Need to double check our code - crypto isn't available...";
    }

    camera_error_t error = camera_config_focus_assist(mHandle, false);

    qDebug() << "CAMERA FOCUS ASSIST ERROR: " << error;

    connect(invokeManager, SIGNAL(invoked(const bb::system::InvokeRequest&)),this, SLOT(onInvoked(const bb::system::InvokeRequest&)));

    connect(invokeManager,
                    SIGNAL(cardResizeRequested(const bb::system::CardResizeMessage&)),
                    this, SLOT(resized(const bb::system::CardResizeMessage&)));

    connect(invokeManager,
                    SIGNAL(cardPooled(const bb::system::CardDoneMessage&)), this,
                    SLOT(pooled(const bb::system::CardDoneMessage&)));

    switch(invokeManager->startupMode())
    {
       case ApplicationStartupMode::LaunchApplication:
           //qDebug() << "HubIntegration: Regular application launch";
           break;

       case ApplicationStartupMode::InvokeApplication:
           //qDebug() << "HubIntegration: Launching app from invoke";

           _isCard = false;
           break;

       case ApplicationStartupMode::InvokeCard:
           //qDebug() << "HubIntegration: Launching card from invoke";

           _isCard = true;
           break;

       default:
           //qDebug() << "HubIntegration: other launch";
           break;
    }

    setFlashMode(false);

    wipeFolderContents(getHomePath() + "/files/captcha/");

    if(getSetting("autoWipeCache", "false") == "true")
    {
        wipeFolderContents(getHomePath() + "/files/blobs/");
        wipeFolderContents(getHomePath() + "/files/sent/");
    }

    QDir dir;

    dir.mkpath("data/files");
    dir.mkpath("data/files/captcha");
    dir.mkpath("data/files/blobs");
    dir.mkpath("data/files/sent");

    if (!QObject::connect(mApp, SIGNAL(fullscreen()), this, SLOT(onFullscreen())))
    {
        qDebug() << "failed to connect fullscreen signal";
    }

    if (!QObject::connect(mApp, SIGNAL(invisible()), this, SLOT(onInvisible())))
    {
        qDebug() << "failed to connect invisible signal";
    }

    if (!QObject::connect(mApp, SIGNAL(thumbnail()), this, SLOT(onThumbnail())))
    {
        qDebug() << "failed to connect thumbnail signal";
    }
    else
    {
        qDebug() << "*********** THUMBNAILED CONNECTED ****************";
    }
}

void ApplicationUI::backUpCache()
{
    QString sharedLogsPath = QDir::currentPath() + "/shared/misc/Snap2ChatCache";

    QDir dir1;
    dir1.mkpath(sharedLogsPath);

    QString devLogsPath = QDir::currentPath() + "/data/files/blobs";

    QDir dir(devLogsPath);

    if (dir.exists(devLogsPath))
    {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files | QDir::AllEntries | QDir::Writable, QDir::DirsFirst))
        {
            if (!info.isDir())
            {
                QString from    = info.absoluteFilePath();
                QString to      = sharedLogsPath + "/" + info.fileName();

                if(!contains(".zip", info.fileName()))
                {
                    if(!QFile::copy(from, to))
                    {
                        qDebug() << "COPY: " << from << " FAILED TO COPY TO " << to;
                    }
                    else
                    {
                       QFile copiedFile(to);
                       copiedFile.open(QIODevice::ReadWrite);
                       copiedFile.setPermissions(QFile::WriteOther | QFile::ReadOther | QFile::WriteGroup | QFile::ReadGroup | QFile::WriteUser | QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner | QFile::ExeGroup | QFile::ExeOther | QFile::ExeOther | QFile::ExeUser);
                       copiedFile.close();
                    }
                }
            }
        }
    }
}

void ApplicationUI::log()
{
    qDebug() << "LOGS COPIED ON STOP";

    if(getSetting("allowLogging", "true") == "true")
    {
        QString sharedLogsPath = QDir::currentPath() + "/shared/misc/Snap2ChatStop";

        QDir dir1;
        dir1.mkpath(sharedLogsPath);

        QString devLogsPath = QDir::currentPath() + "/logs";

        QDir dir(devLogsPath);

        if (dir.exists(devLogsPath))
        {
            Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files | QDir::AllEntries | QDir::Writable, QDir::DirsFirst))
            {
                if (info.isDir())
                {
                   qDebug() << "DIR IGNORE: " << info.absoluteFilePath();
                }
                else
                {
                    qDebug() << "FILE COPY: " << info.absoluteFilePath();

                    QString from    = info.absoluteFilePath();
                    QString to      = sharedLogsPath + "/" + info.fileName();

                    if(QFile::exists(to))
                    {
                        QFile::remove(to);
                    }

                    if(!QFile::copy(from, to))
                    {
                        qDebug() << "COPY: " << from << " FAILED TO COPY TO " << to;
                    }
                    else
                    {
                       QFile copiedFile(to);
                       copiedFile.open(QIODevice::ReadWrite);
                       copiedFile.setPermissions(QFile::WriteOther | QFile::ReadOther | QFile::WriteGroup | QFile::ReadGroup | QFile::WriteUser | QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner | QFile::ExeGroup | QFile::ExeOther | QFile::ExeOther | QFile::ExeUser);
                       copiedFile.close();
                    }
                }
            }
        }
    }
}

void ApplicationUI::socketSend(QString data)
{
	bb::system::InvokeRequest request;
	request.setTarget("com.nemory.Snap2ChatHeadlessService");
	request.setAction("bb.action.CHOICE");
	request.setMimeType("text/plain");
	request.setData(data.toUtf8());
	bb::system::InvokeTargetReply *reply = invokeManager->invoke(request);

	if (!reply)
	{
		//qDebug() << "OOOOOOOO UI Failed to Invoke " << reply->errorCode();
		reply->deleteLater();
	}

	if(!socketConnected)
	{
		//qDebug() << "OOOOOOOO CAUTION: " << socketConnected;

		QString jsonCommand = "{\"action\":\"connect\", \"data\":\"data\"}";

		bb::system::InvokeRequest request2;
		request2.setTarget("com.nemory.Snap2ChatHeadlessService");
		request2.setAction("bb.action.CHOICE");
		request2.setMimeType("text/plain");
		request2.setData(jsonCommand.toUtf8());
		bb::system::InvokeTargetReply *reply2 = invokeManager->invoke(request2);

		if (!reply2)
		{
			//qDebug() << "OOOOOOOO UI Failed to Invoke " << reply2->errorCode();
			reply2->deleteLater();
		}
	}
}

ApplicationUI::~ApplicationUI()
{
    m_server->close();
    m_server->deleteLater();
}

void ApplicationUI::listen()
{
    m_server->listen(QHostAddress::LocalHost, m_port);
}

void ApplicationUI::newConnection()
{
    m_socket = m_server->nextPendingConnection();

    if (!m_socket->isOpen())
	{
    	m_socket->connectToHost(QHostAddress::LocalHost, m_port);
		connect(m_socket, SIGNAL(disconnected()), this, SLOT(disconnected()));
	}
	else
	{
		connected();
	}

    connect(m_socket, SIGNAL(connected()), this, SLOT(connected()));
	connect(m_socket, SIGNAL(readyRead()), this, SLOT(readyRead()));

    if (m_socket->state() == QTcpSocket::ConnectedState)
    {
        qDebug() << "OOOOOOOO UI CONNECTED";
    }
}

void ApplicationUI::readyRead()
{
    QByteArray ba = m_socket->read(90000);

    QString dataString = QString(ba);

	if(dataString.length() > 0)
	{
		emit socketReceived(dataString);
	}
}

void ApplicationUI::connected()
{
	socketConnected = true;

	qDebug() << "OOOOOOOO UI CONNECTED(): " << socketConnected;
}

void ApplicationUI::disconnected()
{
	socketConnected = false;

	qDebug() << "OOOOOOOO UI DISCONNECTED(): " << socketConnected;

    disconnect(m_socket, SIGNAL(disconnected()));
    disconnect(m_socket, SIGNAL(readyRead()));
    m_socket->deleteLater();
}

void ApplicationUI::pooled(const bb::system::CardDoneMessage& doneMessage)
{
//    m_status = tr("Pooled");
//    m_source = m_target = m_action = m_mimeType = m_uri = m_data = tr("--");
//    emit statusChanged();
//    emit requestChanged();
}

void ApplicationUI::cardDone(const QString& msg)
{
    CardDoneMessage message;
    message.setData(msg);
    message.setDataType("text/plain");
    message.setReason(tr("Success!"));

    invokeManager->sendCardDone(message);
}

void ApplicationUI::resized(const bb::system::CardResizeMessage&)
{

}

void ApplicationUI::cardResizeRequested(const bb::system::CardResizeMessage& resizeMessage)
{
	invokeManager->cardResized(resizeMessage);
}

void ApplicationUI::closeCard()
{
	_app->requestExit();

	if (_isCard)
	{
		CardDoneMessage message;
		message.setData(tr(""));
		message.setDataType("text/plain");
		message.setReason(tr("Success!"));

		// Send message
		invokeManager->sendCardDone(message);
	}
}

void ApplicationUI::onInvoked(const bb::system::InvokeRequest& invokeRequest)
{
//	 m_source =
//	            QString::fromLatin1("%1 (%2)").arg(request.source().installId()).arg(
//					request.source().groupId());
//	m_target = request.target();
//	m_action = request.action();
//	m_mimeType = request.mimeType();
//	m_uri = request.uri().toString();
//	m_data = QString::fromUtf8(request.data());
//
//	if (m_target == "com.example.bb10samples.invocation.sharecomposer") {
//		initComposerUI();
//	} else if (m_target
//			== "com.example.bb10samples.invocation.imagepreviewer") {
//		initPreviewerUI();
//	} else if (m_target == "com.example.bb10samples.invocation.eggpicker") {
//		initPickerUI();
//	}

	qDebug() << "**** UI INVOKED: " << invokeRequest.action();

	if(invokeRequest.action() == "bb.action.SEARCH.EXTENDED")
	{
		QString data = QString::fromLatin1(invokeRequest.data());
		emit invokedExtendedSearch(data);
	}
	else if (invokeRequest.action() == "bb.action.OPEN")
	{
		QByteArray data = invokeRequest.data();
		QString id = QString::fromUtf8(data.data(), data.size());
		qDebug() << "HUB INTEGRATION: " << id;
	}
	else if(invokeRequest.action() == "bb.action.COMPOSE")
	{
		qDebug() << "**** COMPOSE ****";

        emit invokedCompose();
	}
	else if(invokeRequest.action() == "bb.action.VIEW")
	{
		// MARK READ

//		socketSend("{\"action\":\"connect\", \"data\":\"data\"}");
//		socketSend("{\"action\":\"refresh\", \"data\":\"data\"}");socketSend("{\"action\":\"connect\", \"data\":\"data\"}");
//		socketSend("{\"action\":\"refresh\", \"data\":\"data\"}");

		QString dataString(invokeRequest.data());

		qDebug() << "**** VIEW dataString: " << dataString;

		emit invokedOpenConversation(dataString);
	}
	else
	{
		qDebug() << "ApplicationUI: onInvoked: unknown service request " << invokeRequest.action() << " : " << invokeRequest.data();
	}
}

void ApplicationUI::initializeUploadingItems()
{
	emit initializeUploadingItemsSignal();
}

qint64 ApplicationUI::getCacheSize()
{
	qint64 totalFileSize = 0;

	QString blobsFolder = getHomePath() + "/files/blobs/";

	QDir filesDir(blobsFolder);

	if (filesDir.exists(blobsFolder))
	{
		Q_FOREACH(QFileInfo info, filesDir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files | QDir::AllEntries | QDir::Writable, QDir::DirsFirst))
		{
			QFile file(info.absoluteFilePath());

			if(file.open(QIODevice::ReadWrite))
			{
				totalFileSize = totalFileSize + file.size();
			}

			file.close();
		}
	}

	QString sentFolder 	= getHomePath() + "/files/sent/";

	QDir sentfilesDir(sentFolder);

	if (sentfilesDir.exists(sentFolder))
	{
		Q_FOREACH(QFileInfo info, sentfilesDir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files | QDir::AllEntries | QDir::Writable, QDir::DirsFirst))
		{
			QFile sentfile(info.absoluteFilePath());

			if(sentfile.open(QIODevice::ReadWrite))
			{
				totalFileSize = totalFileSize + sentfile.size();
			}

			sentfile.close();
		}
	}

	return totalFileSize;
}

void ApplicationUI::extractZippedVideo(QString id)
{
	QString zipFile 		= getHomePath() + "/files/blobs/" + id + ".zip";
	QString extractFolder 	= getHomePath() + "/files/blobs/" + id;

	unzip(zipFile, extractFolder);

	QDir filesDir(extractFolder);

	if (filesDir.exists(extractFolder))
	{
		Q_FOREACH(QFileInfo info, filesDir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files | QDir::AllEntries | QDir::Writable, QDir::DirsFirst))
		{
			if(contains(info.absoluteFilePath(), "media"))
			{
				QFile file(info.absoluteFilePath());
				file.open(QIODevice::ReadWrite);
				file.rename(extractFolder + "/media.mp4");
				file.close();
			}
			else if(contains(info.absoluteFilePath(), "overlay"))
			{
				QFile file(info.absoluteFilePath());
				file.open(QIODevice::ReadWrite);
				file.rename(extractFolder + "/overlay.png");
				file.close();
			}
		}
	}
}

// AES

QString ApplicationUI::getEncryptionKey()
{
	return BLOB_ENCRYPTION_KEY;
}

void ApplicationUI::pad(QByteArray & in)
{
	int padLength = 16 - (in.length() % 16);

	for (int i = 0; i < padLength; ++i)
	{
		in.append((char) padLength);
	}
}

bool ApplicationUI::encrypt(QString filename, QString newfilename)
{
	QString key = BLOB_ENCRYPTION_KEY;
	_key 	= toHex(key.toUtf8());

	QByteArray buffer(16, 0);
	_iv = toHex(buffer);

	QFile file(filename);

	if(!file.open(QIODevice::ReadOnly))
	{
		qDebug() << "CANT OPEN: " + filename;
		return false;
	}

	QByteArray in(file.readAll());
	pad(in);
	QByteArray out(in.length(), 0);

	if (crypt("ECB", true, in, out))
	{
		QFile newFile(newfilename);

		if (!newFile.open(QIODevice::WriteOnly))
		{
			qDebug() << "PROBLEM OPENING FILE: " + newfilename;
		}
		else
		{
			newFile.write(out);
		}

		newFile.close();
	}

	file.close();

	return false;
}

bool ApplicationUI::crypt(QString encryptionMode, bool isEncrypt, const QByteArray & in,QByteArray & out)
{
	QByteArray key, iv;
	QString fail;

	if (!fromHex(_key, key))
	{
		fail += "Key is not valid hex. ";
	}

	if (!fromHex(_iv, iv))
	{
		fail += "IV is not valid hex. ";
	}

	if (!fail.isEmpty())
	{
		qDebug() << fail;
		return false;
	}

	AESParams params(globalContext, encryptionMode);

	if (!params.isValid())
	{
		qDebug() << QString("Could not create params. %1").arg(SBError::getErrorText(params.lastError()));
		return false;
	}

	AESKey aesKey(params, key);

	if (!aesKey.isValid())
	{
		qDebug() << QString("Could not create a key. %1").arg(SBError::getErrorText(aesKey.lastError()));
		return false;
	}

	int rc;

	if (isEncrypt)
	{
		rc = hu_AESEncryptMsg(params.aesParams(), aesKey.aesKey(), iv.length(),
				(const unsigned char*) iv.constData(), in.length(),
				(const unsigned char *) in.constData(),
				(unsigned char *) out.data(), globalContext.ctx());
	}
	else
	{
		rc = hu_AESDecryptMsg(params.aesParams(), aesKey.aesKey(), iv.length(),
				(const unsigned char*) iv.constData(), in.length(),
				(const unsigned char *) in.constData(),
				(unsigned char *) out.data(), globalContext.ctx());
	}

	if (rc == SB_SUCCESS)
	{
		return true;
	}

	qDebug() << QString("Crypto operation failed. %1").arg(SBError::getErrorText(rc));
	return false;

}

void ApplicationUI::decrypt(QString filename, QString newfilename, QString encryptionMode, QString key, QString iv)
{
	if(encryptionMode == "ECB")
	{
		_key 	= toHex(key.toUtf8());

		QByteArray buffer(16, 0);
		_iv = toHex(buffer);
	}
	else if(encryptionMode == "CBC")
	{
		_key 	= toHex(QByteArray::fromBase64(key.toUtf8()));
		_iv 	= toHex(QByteArray::fromBase64(iv.toUtf8()));
	}

	QFile file(filename);

	if(!file.open(QIODevice::ReadOnly))
	{
		qDebug() << "CANT OPEN: " + filename;
		showToast("Some error occured while downloading.");
	}
	else
	{
		QByteArray in(file.readAll());

		QByteArray out(in.length(), 0);

		if (crypt(encryptionMode, false, in, out))
		{
			if (removePadding(out))
			{
				QString toUse(QString::fromUtf8(out.constData(), out.length()));
				//setRecoveredPlainText(toUse);

				QFile newFile(newfilename);

				if (!newFile.open(QIODevice::WriteOnly))
				{
					qDebug() << "PROBLEM OPENING FILE: " + newfilename;
				}
				else
				{
					//qDebug() << "SUCCESS OVERWRITTEN: " + newfilename;

					newFile.write(out);
				}

				newFile.close();
			}
		}
	}

	file.close();
}

bool ApplicationUI::removePadding(QByteArray & out)
{
	char paddingLength = out[out.length() - 1];

	if (paddingLength < 1 || paddingLength > 16)
	{
		qDebug() << "Invalid padding length. Were the keys good?";
		out.clear();
		return false;
	}

	if (paddingLength > out.length())
	{
		qDebug() << "Padding is claiming to be longer than the buffer!";
		out.clear();
		return false;
	}

	for (int i = 1; i < paddingLength; ++i)
	{
		char next = out[out.length() - 1 - i];

		if (next != paddingLength)
		{
			qDebug() << "Not all padding bytes are correct!";
			out.clear();
			return false;
		}
	}

	out.remove(out.length() - paddingLength, paddingLength);
	return true;
}

QString ApplicationUI::toHex(const QByteArray & in)
{
	static char hexChars[] = "0123456789abcdef";

	const char * c = in.constData();
	QString toReturn;

	for (int i = 0; i < in.length(); ++i)
	{
		toReturn += hexChars[(c[i] >> 4) & 0xf];
		toReturn += hexChars[(c[i]) & 0xf];
	}

	return toReturn;
}

bool ApplicationUI::fromHex(const QString in, QByteArray & toReturn)
{
	QString temp(in);
	temp.replace(" ","");
	temp.replace(":","");
	temp.replace(".","");

	QByteArray content(temp.toLocal8Bit());

	const char * c(content.constData());

	if (content.length() == 0 || ((content.length() % 2) != 0))
	{
		return false;
	}

	for (int i = 0; i < content.length(); i += 2)
	{
		char a = c[i];
		char b = c[i + 1];
		a = nibble(a);
		b = nibble(b);

		if (a < 0 || b < 0)
		{
			toReturn.clear();
			return false;
		}

		toReturn.append((a << 4) | b);
	}

	return true;
}

char ApplicationUI::nibble(char c) {
	if (c >= '0' && c <= '9') {
		return c - '0';
	} else if (c >= 'a' && c <= 'f') {
		return c - 'a' + 10;
	} else if (c >= 'A' && c <= 'F') {
		return c - 'A' + 10;
	}
	return -1;
}

// AES

void ApplicationUI::zip(QString filename, QString folder)
{
	JlCompress::compressDir(filename + "BACKUP_WHERESMYPHONE.zip", folder, true);
}

void ApplicationUI::unzip(QString zipfile, QString folder)
{
	//qDebug() << "ZIP: " + zipfile + ", FOLDER: " + folder;

	JlCompress::extractDir(zipfile, folder);
}

// BEST CAM

int ApplicationUI::capture()
{
	camera_error_t error = camera_config_focus_assist(mHandle, false);

	//qDebug() << "CAMERA FOCUS ASSIST ERROR: " << error;

    int err = EOK;

    switch (mState)
    {
		case StateVideoVf:
			mStopViewfinder = false;
			err = runStateMachine(StateVideoCapture);
			break;
		case StateVideoCapture:
			mStopViewfinder = false;
			err = runStateMachine(StateVideoVf);
			break;
		case StatePhotoVf:
			mStopViewfinder = false;
			err = runStateMachine(StatePhotoCapture);
			break;
		default:
			qDebug() << "error, cannot capture in state" << stateName(mState);
			err = EINVAL;
			break;
    }

    return err;
}

int ApplicationUI::openCamera(camera_unit_t unit)
{
    if (mHandle != CAMERA_HANDLE_INVALID)
    {
        qDebug() << "already have a camera open";
        return CAMERA_EALREADY;
    }

    int err;

    for (int retry=RETRY_MS; retry; retry-=RETRY_DELAY)
    {
        err = camera_open((camera_unit_t)unit, CAMERA_MODE_RW | CAMERA_MODE_ROLL, &mHandle);
        if (err == EOK) break;
        qDebug() << "****** failed to open camera unit" << unit << ": error" << err << "(will retry)";
        usleep(RETRY_DELAY * 1000);

        emit cameraErrorSignal("Please make sure no other apps uses the camera at the same time, and you must have accepted Microphone, Shared Files and Camera permission during installation. \n\nTo re enable permissions, please go to Settings App, App Manager, Permissions, Snap2Chat, enable all the permissions possible for Snap2Chat work perfectly. Please restart Snap2Chat after.\n\n for further support please don't hesitate to contact us snap2chat@gmail.com \n\nThank you so much");
    }

    if (err)
    {
        qDebug() << "****** could not open camera unit" << unit << ": error" << err;

        mHandle = CAMERA_HANDLE_INVALID;
        mUnit = CAMERA_UNIT_NONE;
    }
    else
    {
        ////qDebug() << "opened camera unit" << unit;
        mUnit = (camera_unit_t)unit;
        err = discoverCameraCapabilities();

        if (err)
        {
            ////qDebug() << "failed to query camera capabilities.";
            closeCamera();
            return err;
        }

        mStatusThread = new StatusThread(this);

        if (!mStatusThread)
        {
            err = errno;
            ////qDebug() << "failed to attach status thread";
        }
        else
        {
            if (!QObject::connect(mStatusThread, SIGNAL(statusChanged(camera_devstatus_t, uint16_t)), this, SLOT(onStatusChanged(camera_devstatus_t, uint16_t))))
            {
                ////qDebug() << "failed to connect statusChanged";
            }
            else
            {
                mStatusThread->start();
            }
        }
    }

    return err;
}

void ApplicationUI::openTheCamera()
{
	onFullscreen();
}

int ApplicationUI::closeCamera()
{
    if (mHandle == CAMERA_HANDLE_INVALID)
    {
        ////qDebug() << "no camera to close. ignoring.";
    }
    else
    {
        if (mStatusThread)
        {
            mStatusThread->cleanShutdown();
            mStatusThread->wait();
            delete mStatusThread;
            mStatusThread = NULL;
        }

        ////qDebug() << "closing camera";
        camera_close(mHandle);
        mHandle = CAMERA_HANDLE_INVALID;
    }

    return EOK;
}

int ApplicationUI::setCameraUnit(CameraUnit unit)
{
    int err = EOK;

    if ((mState == StateStartingPhotoVf) || (mState == StateStartingVideoVf))
    {
        return EINVAL;
    }

    err = runStateMachine(StateIdle);
    closeCamera();

    if (err == EOK)
    {
        err = openCamera((camera_unit_t)unit);
        err = camera_set_videoencoder_parameter(mHandle,
        		CAMERA_H264AVC_BITRATE, 830000,
        		CAMERA_H264AVC_KEYFRAMEINTERVAL, 60,
        		CAMERA_H264AVC_RATECONTROL, CAMERA_H264AVC_RATECONTROL_CBR,
        		CAMERA_H264AVC_PROFILE, CAMERA_H264AVC_PROFILE_HIGH,
        		CAMERA_H264AVC_LEVEL, CAMERA_H264AVC_LEVEL_4);

        if (err)
        {
            qDebug() << "****** 1 failed to open camera" << unit;
        }
        else
        {
            err = setVfMode(mVfMode);
        }

        emit cameraUnitChanged((CameraUnit)mUnit);
    }

    return err;
}

int ApplicationUI::setVfMode(VfMode mode)
{
    int err = EOK;

    switch (mode)
    {
		case ModePhoto:
			mStopViewfinder = true;
			if (err == EOK)
			{
				err = runStateMachine(StateStartingPhotoVf);
			}
			else
			{
				err = CAMERA_EALREADY;
			}
			break;
		case ModeVideo:
			mStopViewfinder = true;
			if (err == EOK)
			{
				err = runStateMachine(StateStartingVideoVf);
			}
			else
			{
				err = CAMERA_EALREADY;
			}
			break;
		default:
			err = runStateMachine(StateIdle);
			break;
	}

	if (err == EOK)
	{
		mVfMode = mode;

		if (mVfMode != ModeNone)
		{
			mResumeVfMode = mVfMode;
		}

		emit vfModeChanged(mVfMode);
	}

    return err;
}

void ApplicationUI::inventoryCameras()
{
    unsigned int num;
    mHasFrontCamera = mHasRearCamera = false;

    if (camera_get_supported_cameras(0, &num, NULL) != EOK)
    {
        ////qDebug() << "failed to query number of supported cameras";
    }
    else
    {
        camera_unit_t units[num];

        if (camera_get_supported_cameras(num, &num, units) != EOK)
        {
            ////qDebug() << "failed to query supported cameras";
        }
        else
        {
            for (unsigned int i=0; i<num; i++)
            {
                if (units[i] == CAMERA_UNIT_FRONT)
                {
                    mHasFrontCamera = true;
                }
                else if (units[i] == CAMERA_UNIT_REAR)
                {
                    mHasRearCamera = true;
                }
            }
        }
    }

    emit hasFrontCameraChanged(mHasFrontCamera);
    emit hasRearCameraChanged(mHasRearCamera);
}

void ApplicationUI::setFocusMode(camera_focusmode_t mode)
{
	camera_set_focus_mode(mHandle, mode);
}

void ApplicationUI::setFlashMode(bool onOff)
{
	if(onOff)
	{
		camera_config_flash(mHandle, CAMERA_FLASH_ON);
	}
	else
	{
		camera_config_flash(mHandle, CAMERA_FLASH_OFF);
	}
}

void ApplicationUI::setVideoLight(bool onOff)
{
	if(onOff)
	{
		camera_config_videolight(mHandle, CAMERA_VIDEOLIGHT_ON);
	}
	else
	{
		camera_config_videolight(mHandle, CAMERA_VIDEOLIGHT_OFF);
	}
}

int ApplicationUI::startPhotoVf()
{
    int err = EOK;

    mRequireUprightVf = false;      // since we are not processing pixels, we don't care which way the vf buffer is oriented
    mRequireUprightCapture = true;  // try our best to orient capture buffers upright, but rely on EXIF if not possible

    // when configuring a viewfinder, the capture and viewfinder resolutions must have the same aspect ratio.
    // let's check what the current (default) photo capture size is...
    err = camera_get_photo_property(mHandle, CAMERA_IMGPROP_WIDTH, &mCapWidth, CAMERA_IMGPROP_HEIGHT, &mCapHeight);

    if (err)
    {
        //qDebug() << "error querying photo resolution";
    }
    else
    {
        //qDebug() << "photo capture resolution is: " << mCapWidth << "x" << mCapHeight;

        camera_res_t capres;
        capres.width = mCapWidth;
        capres.height = mCapHeight;

        camera_res_t* vfres = matchAspectRatio(&capres, mPhotoVfResolutions, mNumPhotoVfResolutions, 0.01);

        if (!vfres)
        {
            //qDebug() << "could not find a matching aspect ratio for the viewfinder";
            err = EINVAL;
        }
        else
        {
            mVfWidth 	= vfres->width;
            mVfHeight 	= vfres->height;

            //qDebug() << "matching viewfinder resolution is" << mVfWidth << "x" << mVfHeight;

            err = camera_set_photovf_property(mHandle,
            		CAMERA_IMGPROP_WIDTH, mVfWidth,
            		CAMERA_IMGPROP_HEIGHT, mVfHeight);

            if (err)
            {
                //qDebug() << "failed to set photovf resolution";
            }
            else
            {
                QByteArray groupBA = mFwc->windowGroup().toLocal8Bit();
                QByteArray winBA = mFwc->windowId().toLocal8Bit();

                err = camera_set_photovf_property(mHandle, CAMERA_IMGPROP_WIN_GROUPID, groupBA.data(), CAMERA_IMGPROP_WIN_ID, winBA.data());

                if (err)
                {
                    //qDebug() << "error setting photovf properties:" << err;
                }
                else
                {
                    err = camera_start_photo_viewfinder(mHandle, NULL, NULL, NULL);

                    if (err)
                    {
                        //qDebug() << "error starting photo viewfinder:" << err;
                    }
                    else
                    {
                        err = camera_register_resource(mHandle);
                    }
                }
            }
        }
    }

    return err;
}


int ApplicationUI::stopPhotoVf()
{
    ////qDebug() << "stopping photo viewfinder";

    int err = camera_deregister_resource(mHandle);

    if (err)
    {
        ////qDebug() << "error trying to deregister resource:" << err;
    }

    err = camera_stop_photo_viewfinder(mHandle);

    if (err)
    {
        ////qDebug() << "error trying to shut down photo viewfinder:" << err;
    }

    return err;
}

int ApplicationUI::startVideoVf()
{
    int err = EOK;

    mRequireUprightVf = false;      // since we are not processing pixels, we don't care which way the vf buffer is oriented.
                                    // however, when it comes time to record video, we will need to change this if the video source is the vf.
    mRequireUprightCapture = true;  // capture buffers must be upright since we don't have a metadata solution at this time

    // find the window group & window id required by the ForeignWindowControl
    QByteArray groupBA = mFwc->windowGroup().toLocal8Bit();
    QByteArray winBA = mFwc->windowId().toLocal8Bit();

    err = camera_set_videovf_property(mHandle,
    		CAMERA_IMGPROP_HWOVERLAY, 1, CAMERA_IMGPROP_FORMAT, CAMERA_FRAMETYPE_NV12,
    		CAMERA_IMGPROP_WIN_GROUPID, groupBA.data(),
    		CAMERA_IMGPROP_WIN_ID, winBA.data(),
    		CAMERA_IMGPROP_WIDTH, mVfWidth,
    		CAMERA_IMGPROP_HEIGHT, mVfHeight,
    		CAMERA_IMGPROP_MAXFOV, 0);

    err = camera_set_video_property(mHandle,
    		CAMERA_IMGPROP_WIDTH, mVfWidth,
    		CAMERA_IMGPROP_HEIGHT, mVfHeight,
    		CAMERA_IMGPROP_AUDIOCODEC, CAMERA_AUDIOCODEC_AAC,
    		CAMERA_IMGPROP_STABILIZATION, 1);

    if (err)
    {
        //qDebug() << "error setting videovf properties:" << err;
    }
    else
    {
        err = camera_start_video_viewfinder(mHandle,NULL,NULL,NULL);

        if (err)
        {
            qDebug() << "****** error starting video viewfinder:" << err;
        }
        else
        {
            mApp->mainWindow()->setScreenIdleMode(ScreenIdleMode::KeepAwake);
            camera_get_videovf_property(mHandle, CAMERA_IMGPROP_WIDTH, &mVfWidth, CAMERA_IMGPROP_HEIGHT, &mVfHeight);
        }
    }

    return err;
}


int ApplicationUI::stopVideoVf()
{
    ////qDebug() << "stopping video viewfinder";
    int err = camera_stop_video_viewfinder(mHandle);

    if (err)
    {
        ////qDebug() << "error trying to shut down video viewfinder:" << err;
    }

    mApp->mainWindow()->setScreenIdleMode(ScreenIdleMode::Normal);

    return err;
}

int ApplicationUI::startRecording()
{
    int err = EOK;

    if (camera_has_feature(mHandle, CAMERA_FEATURE_PREVIEWISVIDEO))
    {
        mRequireUprightVf = mRequireUprightCapture;
        mDesiredVfAngle = mDesiredCapAngle;
    }

    updateVideoAngle();
    screen_window_t win = mFwc->windowHandle();

    if (!win)
    {
        ////qDebug() << "can't get window handle to flush context";
    }
    else
    {
        screen_context_t screen_ctx;
        screen_get_window_property_pv(win, SCREEN_PROPERTY_CONTEXT, (void **)&screen_ctx);
        screen_flush_context(screen_ctx, 0);

        char filename[CAMERA_ROLL_NAMELEN];
        err = camera_roll_open_video(mHandle,
                                     &mVideoFileDescriptor,
                                     filename,
                                     sizeof(filename),
                                     CAMERA_ROLL_VIDEO_FMT_DEFAULT);
        if (err == EOK)
        {
            ////qDebug() << "opened " << filename;

			if(getSetting("shutterSound", "true") == "true")
			{
				soundplayer_play_sound_blocking("event_recording_start");
			}

            err = camera_start_video(mHandle, filename, NULL, NULL, NULL);

            if (err == EOK)
            {
            	lastVideoRecordingLocation = filename;

                ////qDebug() << "started recording";
                return EOK;
            }

            qDebug() << "****** failed to start recording";

            emit cameraErrorSignal("Please make sure no other apps uses the camera at the same time, and you must have accepted Microphone, Shared Files and Camera permission during installation. \n\nTo re enable permissions, please go to Settings App, App Manager, Permissions, Snap2Chat, enable all the permissions possible for Snap2Chat work perfectly. Please restart Snap2Chat after.\n\n for further support please don't hesitate to contact us snap2chat@gmail.com \n\nThank you so much");
        }
    }

    return err;
}

int ApplicationUI::stopRecording()
{
    int err = EOK;

    mRequireUprightVf = false;

    if (mVideoFileDescriptor != -1)
    {
        err = camera_stop_video(mHandle);

        if (err != EOK)
        {
            ////qDebug() << "failed to stop video recording. err " << err;
        }

        camera_roll_close_video(mVideoFileDescriptor);
        mVideoFileDescriptor = -1;
    }

    if(getSetting("shutterSound", "true") == "true")
	{
    	soundplayer_play_sound("event_recording_stop");
	}

    QString newVideoPath = getHomePath() + "/files/sent/temporary-" + QString::number(_tempID) + ".mp4";

	deletePhoto(newVideoPath);
	copyAndRemove(lastVideoRecordingLocation, newVideoPath);

	emit openSnapEditorSignal(newVideoPath, false, false);

    return err;
}

void ApplicationUI::takePhoto()
{
    int err = EOK;

    err = camera_take_photo(mHandle,
                            shutterCallbackEntry,
                            NULL,
                            NULL,
                            stillCallbackEntry,
                            (void*)this,
                            true);

    emit captureComplete(err);
}

int ApplicationUI::runStateMachine(CamState newState)
{
    int err = EOK;
    CamState nextState;

    while (mState != newState)
    {
        ////qDebug() << "exiting state" << stateName(mState);
        err = exitState();

        if (err != EOK)
        {
            return err;
        }

        mState = newState;

        ////qDebug() << "entering state" << stateName(newState);
        err = enterState(newState, nextState);

        if (err != EOK)
        {
            ////qDebug() << "error" << err << "entering state" << stateName(newState);
        }

        if (nextState != newState)
        {
            newState = nextState;
        }
    }

    return err;
}

int ApplicationUI::exitState()
{
    int err = EOK;
    switch(mState)
    {
		case StateIdle:
			// update UI?
			break;

		case StatePhotoCapture:
			emit capturingChanged(mCapturing = false);
			/* no break */
		case StateStartingPhotoVf:
		case StatePhotoVf:
			// update UI
			emit canCaptureChanged(mCanCapture = false);
			if (mStopViewfinder)
			{
				err = stopPhotoVf();
			}
			break;
		case StateVideoCapture:
			// unlock orientation when video recording ends
			OrientationSupport::instance()->setSupportedDisplayOrientation(SupportedDisplayOrientation::All);
			err = stopRecording();
			if (mStopViewfinder)
			{
				err = stopVideoVf();
			}
			emit capturingChanged(mCapturing = false);
			break;
		case StateStartingVideoVf:
		case StateVideoVf:
			// update UI
			emit canCaptureChanged(mCanCapture = false);
			if (mStopViewfinder)
			{
				err = stopVideoVf();
			}
			break;

		default:
			// nothing to do when exiting other states
			break;
    }

    return err;
}

int ApplicationUI::enterState(CamState state, CamState &nextState)
{
    nextState = state;
    int err = EOK;

    switch(state) {
    case StateIdle:
        // update UI
        mCanCapture = false;
        canCaptureChanged(mCanCapture);
        break;
    case StateStartingPhotoVf:
        err = startPhotoVf();
        if (err)
        {
            nextState = StateIdle;
        }
        else
        {
            mStopViewfinder = true;
        }
        break;
    case StatePhotoVf:
        mStopViewfinder = true;
        // update UI
        emit canCaptureChanged(mCanCapture = true);

        break;
    case StatePhotoCapture:
        emit capturingChanged(mCapturing = true);
        QtConcurrent::run(this, &ApplicationUI::takePhoto);
        break;
    case StateStartingVideoVf:
        err = startVideoVf();
        if (err)
        {
            nextState = StateIdle;
        }
        else
        {
            mStopViewfinder = true;
        }
        break;
    case StateVideoVf:
        mStopViewfinder = true;
        updateAngles();
        // update UI
        emit canCaptureChanged(mCanCapture = true);
        break;
    case StateVideoCapture:
        // lock orientation while video recording
        OrientationSupport::instance()->setSupportedDisplayOrientation(SupportedDisplayOrientation::CurrentLocked);
        emit capturingChanged(mCapturing = true);
        err = startRecording();
        if (err)
        {
            nextState = StateVideoVf;
        }
        else
        {
            emit canCaptureChanged(mCanCapture = true);
        }
        break;
    case StatePowerDown:
    case StateMinimized:
        // NOTE: we are combining powerdown and minimized states here for now, as we are treating them the same.
        // We are also going to be closing the camera in this state in order to play nice with other apps.
        closeCamera();
        emit vfModeChanged(mVfMode = ModeNone);
        break;
    default:
        // nothing to do?
        break;
    }

    // if we have just entered a state and resource warning is pending
    // (eg. we were in the middle of a photo capture when the warning was received),
    // then deal with it now
    if (mDeferredResourceWarning) {
        mDeferredResourceWarning = false;
        nextState = StatePowerDown;
    }

    return err;
}

const char* ApplicationUI::stateName(CamState state)
{
    switch(state) {
    case StateIdle:
        return "Idle";
    case StateStartingPhotoVf:
        return "StartingPhotoVf";
    case StatePhotoVf:
        return "PhotoVf";
    case StatePhotoCapture:
        return "PhotoCapture";
    case StateStartingVideoVf:
        return "StartingVideoVf";
    case StateVideoVf:
        return "VideoVf";
    case StateVideoCapture:
        return "VideoCapture";
    case StatePowerDown:
        return "PowerDown";
    case StateMinimized:
        return "Minimized";
    default:
        return "UNKNOWN";
    }
}

int ApplicationUI::windowAttached()
{
    int err = EOK;

    // update window details
    screen_window_t win = mFwc->windowHandle();
    // put the viewfinder window behind the cascades window
    int i = -1;
    screen_set_window_property_iv(win, SCREEN_PROPERTY_ZORDER, &i);

    CamState newState = StateIdle;
    mStopViewfinder = true;
    switch (mState) {
    case StateStartingPhotoVf:
        // ensure we don't stop the viewfinder when transitioning out of StateStartingPhotoVf
        mStopViewfinder = false;
        updateAngles();
        updatePhotoAngle();
        newState = StatePhotoVf;
        break;
    case StateStartingVideoVf:
        // ensure we don't stop the viewfinder when transitioning out of StateStartingVideoVf
        mStopViewfinder = false;
        updateAngles();
        updateVideoAngle();
        newState = StateVideoVf;
        break;
    default:
        ////qDebug() << "unexpected window attach while not waiting for one";
        emit vfModeChanged(mVfMode = ModeNone);
        err = EINVAL;
        break;
    }

    screen_context_t screen_ctx;
    screen_get_window_property_pv(win, SCREEN_PROPERTY_CONTEXT, (void **)&screen_ctx);
    screen_flush_context(screen_ctx, 0);

    err = runStateMachine(newState);
    return err;
}

void ApplicationUI::shutterCallback(camera_handle_t handle)
{
	if(getSetting("shutterSound", "true") == "true")
	{
		soundplayer_play_sound("event_camera_shutter");
	}

    (void)handle;  // silence compiler warning
}

void ApplicationUI::stillCallback(camera_handle_t handle, camera_buffer_t* buf)
{
    ////qDebug() << "still buffer received";
    if (buf->frametype == CAMERA_FRAMETYPE_JPEG) {
        ////qDebug() << "still image size:" << buf->framedesc.jpeg.bufsize;
        int fd;
        char filename[CAMERA_ROLL_NAMELEN];
        int err = camera_roll_open_photo(handle,
                                         &fd,
                                         filename,
                                         sizeof(filename),
                                         CAMERA_ROLL_PHOTO_FMT_JPG);
        if (err)
        {
            ////qDebug() << "error opening camera roll:" << err;
        }
        else
        {
            ////qDebug() << "SAVING:" << filename;
            int index = 0;

            while(index < (int)buf->framedesc.jpeg.bufsize)
            {
                int rc = write(fd, &buf->framebuf[index], buf->framedesc.jpeg.bufsize-index);

                if (rc > 0)
                {
                    index += rc;
                }
                else if (rc == -1)
                {
                    if ((errno == EAGAIN) || (errno == EINTR)) continue;
                    ////qDebug() << "write error:" << errno;
                    break;
                }
            }

            close(fd);

            _tempID = _tempID + 1;

            QString newImagePath = getHomePath() + "/files/sent/temporary-" + QString::number(_tempID) + ".jpg";

            deletePhoto(newImagePath);
            copyAndRemove(filename, newImagePath);

            emit openSnapEditorSignal(newImagePath, true, false);
        }
    }
}

int ApplicationUI::getTempID()
{
	return _tempID;
}

void ApplicationUI::setTempID(int value)
{
	_tempID = value;
	emit tempIDChanged(_tempID);
}

void ApplicationUI::onCaptureComplete(int err)
{
    runStateMachine(StatePhotoVf);
}


StatusThread::StatusThread(ApplicationUI* cam) :
    QThread(),
    mCam(cam),
    mStop(false)
{
    mHandle = mCam->mHandle;
    mChId = ChannelCreate(0);
    mCoId = ConnectAttach(0, 0, mChId, _NTO_SIDE_CHANNEL, 0);
    SIGEV_PULSE_INIT(&mEvent, mCoId, SIGEV_PULSE_PRIO_INHERIT, mPulseId, 0);
}


void StatusThread::run()
{
    int err = EOK;
    int rcvid;
    struct _pulse pulse;
    camera_eventkey_t key;
    camera_devstatus_t status;
    uint16_t extra;
    err = camera_enable_status_event(mHandle, &key, &mEvent);
    if (err) {
        ////qDebug() << "could not enable status event. err =" << err;
    } else {
        ////qDebug() << "status thread running";
        while(!mStop) {
            rcvid = MsgReceive(mChId, &pulse, sizeof(pulse), NULL);
            // not a pulse?
            if (rcvid != 0) continue;
            // not our pulse?
            if (pulse.code != mPulseId) continue;
            // instructed to stop?
            if (mStop) break;
            err = camera_get_status_details(mHandle, pulse.value, &status, &extra);
            if (err) {
                ////qDebug() << "failed to get status event details??";
            } else {
                emit statusChanged(status, extra);
            }
        }
        camera_disable_event(mHandle, key);
    }
    ////qDebug() << "status thread exiting";
}


void StatusThread::cleanShutdown()
{
    mStop = true;
    MsgSendPulse(mCoId, -1, mPulseId, 0);
}


void ApplicationUI::onStatusChanged(camera_devstatus_t status, uint16_t extra)
{
    //////qDebug() << "status event:" << status << "," << extra;
    switch(status) {
    case CAMERA_STATUS_RESOURCENOTAVAIL:
        ////qDebug() << "camera resources are about to become unavailable";
        resourceWarning();
        break;
    case CAMERA_STATUS_POWERDOWN:
        ////qDebug() << "camera powered down";
        poweringDown();
        break;
    case CAMERA_STATUS_POWERUP:
        ////qDebug() << "camera powered up";
        // since the onFullscreen handler will restart the camera for us, there is not much to do here.
        // however, if we were the sort of app that wanted to start running again even if we were backgrounded,
        // then we could consider resuming the viewfinder here.
        break;
    default:
        break;
    }
    // suppress warning
    (void)extra;
}

void ApplicationUI::maximizeCamera()
{
//	runStateMachine(StateIdle);
//	setCameraUnit((CameraUnit)mUnit);
	//setVfMode(mResumeVfMode);
	runStateMachine(StateIdle);
}

void ApplicationUI::minimizeCamera()
{
	runStateMachine(StateMinimized);
}

void ApplicationUI::onFullscreen()
{
    ////qDebug() << "onFullscreen()";
    switch(mState) {
    case StateMinimized:
    case StatePowerDown:
        // coming back to the foreground, resume viewfinder
        runStateMachine(StateIdle);
        setCameraUnit((CameraUnit)mUnit);
        ////qDebug() << "setting vf mode" << mResumeVfMode;
        setVfMode(mResumeVfMode);
        break;
    default:
        // nothing to do
        break;
    }
}


void ApplicationUI::onThumbnail()
{
    ////qDebug() << "onThumbnail()";
    switch (mState) {
    case StateVideoCapture:
        // if we are recording a video when we get minimized, let's keep recording
        ////qDebug() << "ignoring thumbnail signal... keep running!";
        break;
    default:
        runStateMachine(StateMinimized);
        break;
    }
}


void ApplicationUI::onInvisible()
{
    ////qDebug() << "onInsivible()";
    switch (mState) {
    case StateVideoCapture:
        // if we are recording a video when we get covered, let's keep recording.
        // NOTE: since the app is no longer visible on-screen, the ScreenIdleMode::KeepAwake setting
        // will not be enough to keep the device from shutting down.. that's alright, because when the
        // video recorder (or encoder) is active, the OS will prevent the device from going into standby automatically.
        ////qDebug() << "ignoring invisible signal... keep running!";
        break;
    default:
        // not really treating thumbnail/invisible differently.  could have connected both signals to a single slot really.
        runStateMachine(StateMinimized);
        break;
    }
}


void ApplicationUI::resourceWarning()
{
    switch (mState) {
    case StatePhotoCapture:
        // just set a flag that we should handle the resourceWarning after capture completes
        mDeferredResourceWarning = true;
        break;
    default:
        runStateMachine(StatePowerDown);
        break;
    }
}


void ApplicationUI::poweringDown()
{
    runStateMachine(StatePowerDown);
}


void ApplicationUI::onDisplayDirectionChanging(bb::cascades::DisplayDirection::Type displayDirection,
                                         bb::cascades::UIOrientation::Type orientation)
{
    ////qDebug() << "onDisplayOrientationChange()";

    // this will only be called when supported orientations are activated.
    // on the Q10, there is only one official orientation, and on most other devices, 180 degrees
    // is not supported.  we have to also hook into the orientation sensor api in order to cover all angles
    // on all devices.
    ////qDebug() << "display direction change:" << displayDirection;
    // note: this was only a vf orientation change event, so leave the QOrientationSensor reading as its last cached value...
    mDisplayDirection = displayDirection;
    updateAngles();
    // silence compiler warning
    (void)orientation;
}


void ApplicationUI::updateAngles()
{
    // For a camera facing in the same direction as the user (forward), the desired display angle is the complement
    // of the display direction.  This is because the nav display direction signals are reported as:
    // "the edge of the device which is now topmost".  In the camera's space, we report
    // angles as clockwise rotations of a buffer, or of the device.  So if nav reports that "90" is the new
    // display direction, that means that the 90-degree-clockwise edge (or 3-o'clock edge) of the device is
    // now topmost.  that means that the device has actually been rotated 90 degrees counterclockwise.
    // 90 degrees counterclockwise is equivalent to 270 degrees clockwise.  We want our picture to be rotated by
    // the same amount (270 degrees clockwise), therefore we use the complement of navigator's reported "90".
    // Here is an important distinction...
    // For a camera which faces in the opposite direction as the user (eg. backwards - towards the user), the
    // angle that the device is being rotated needs to be reversed.  This is because from the camera's perspective
    // (standing behind the device, facing the user), the device has been rotated in the opposite direction from that which
    // the user would perceive.  Once you understand this distinction, the front/rear decisions below will make more sense.
    // Although confusingly, CAMERA_UNIT_REAR is the camera facing in the same direction as the user (it faces out
    // the rear of the device), and CAMERA_UNIT_FRONT is the camera facing towards the user.

    // here, I will reverse the nav's reported rotation, to bring it in line with the screen and camera's
    // co-ordinate reference.  eg. turning the device clockwise yields a rotation of 90 (nav reports 270)
    int clockwiseDisplayAngle = (360 - mDisplayDirection) % 360;
    int clockwiseOrientationAngle = (360 - mOrientationDirection) % 360;

    // note that the device orientation is not dependent on which camera (front vs rear) we are using when used with
    // camera_set_device_orientation().  the distinction is performed by the camera service.
    mDeviceOrientation = clockwiseOrientationAngle;

    // now account for front/rear-facing camera reversal of rotation direction
    if (mUnit == CAMERA_UNIT_FRONT) {
        mDesiredVfAngle = (360 - clockwiseDisplayAngle) % 360;
        mDesiredCapAngle = (360 - clockwiseOrientationAngle) % 360;
    } else {
        mDesiredVfAngle = clockwiseDisplayAngle;
        mDesiredCapAngle = clockwiseOrientationAngle;
    }

//    //qDebug() << "display direction:" << mDisplayDirection
//             << "orientation direction:" << mOrientationDirection
//             << "desired vf angle:" << mDesiredVfAngle
//             << "desired cap angle:" << mDesiredCapAngle
//             << "device orientation: " << mDeviceOrientation;

    // now that we know which way is up, let's decide if we need to do anything about it.
    switch (mState) {
    case StatePhotoVf:
        updatePhotoAngle();
        break;
    case StateVideoVf:
        updateVideoAngle();
        break;
    default:
        // we can't change the angle while recording, or taking a picture, or starting up, so may as well ignore.
        // could just set a deferred flag and deal with it on a state transition.
        ////qDebug() << "not in a stable viewfinder state, ignoring angle change";
        break;
    }
}


void ApplicationUI::updatePhotoAngle()
{
    int i;
    int err = EOK;
    err = camera_get_photovf_property(mHandle, CAMERA_IMGPROP_ROTATION, &mVfAngle);

    if (mRequireUprightVf) {
        // if required, let's select a physical viewfinder buffer rotation which will result in an upright buffer.
        // if this is not possible, then we have to make up the difference with a screen rotation effect.
        // check whether the desired angle is available...
        for (i=0; i<mNumPhotoVfRotations; i++) {
            if (mPhotoVfRotations[i] == mDesiredVfAngle) break;
        }
        if (i == mNumPhotoVfRotations) {
            ////qDebug() << "desired photovf angle" << mDesiredVfAngle << "is not available";
            // we'll have to rely on screen alone in this case.
        } else {
            err = camera_set_photovf_property(mHandle, CAMERA_IMGPROP_ROTATION, mDesiredVfAngle);
            if (err) {
                ////qDebug() << "failed to set photovf angle" << mDesiredVfAngle << "err:" << err;
            } else {
                mVfAngle = mDesiredVfAngle;
                ////qDebug() << "set photovf rotation" << mVfAngle;
            }
        }
    }

    if (mRequireUprightCapture) {
        // if required, let's select a physical capture buffer rotation which will result in an upright buffer.
        // not all platforms support this, but instead depend on EXIF metadata in order to instruct picture viewers to
        // display the JPEG in the correct orientation.
        // see the note below about EXIF orientation tags...  It's actually arguable whether physically rotating the buffer is
        // necessary if EXIF tags are respected by all photo viewers.  We will try our best in this code to be friendly :)
        // check whether the desired angle is available...
        for (i=0; i<mNumPhotoRotations; i++) {
            if (mPhotoRotations[i] == mDesiredCapAngle) break;
        }
        if (i == mNumPhotoRotations) {
            ////qDebug() << "desired photo output angle" << mDesiredCapAngle << "is not available";
            // we'll have to rely on EXIF alone in this case.
        }
        else
        {
            err = camera_set_photo_property(mHandle,
            		CAMERA_IMGPROP_ROTATION, mDesiredCapAngle,
            		CAMERA_IMGPROP_WIDTH, getDisplayWidth(),
            		CAMERA_IMGPROP_HEIGHT, getDisplayHeight());

            if (err)
            {
                //qDebug() << "failed to set photo output angle" << mDesiredCapAngle << "err:" << err;
            }
            else
            {
                mCaptureAngle = mDesiredCapAngle;
                //qDebug() << "set photo output rotation" << mCaptureAngle;
            }
        }
    }

    // compute screen display angle now that we know how the viewfinder buffers are being rotated.
    // remember: desired angle = viewfinder angle + window angle.  solve for viewfinder angle:
    mWindowAngle = (360 + mDesiredVfAngle - mVfAngle) % 360;  // note +360 to avoid negative numbers in modulo math

    // all we need to do here is update the screen window associated with the viewfinder.
    screen_window_t win = mFwc->windowHandle();
    if (!win)
    {
        ////qDebug() << "no window handle available to update";
    }
    else
    {
        screen_set_window_property_iv(win, SCREEN_PROPERTY_ROTATION, (int*)&mWindowAngle);
        int mirror = 0;
        int flip = 0;

        if (mUnit == CAMERA_UNIT_FRONT)
        {
            // NOTE: since mirroring is applies after rotation in the order-of-operations, it is necessary to
            // decide between a flip or a mirror in order to make the screen behave like a mirror on the front camera.

            if (mWindowAngle % 180)
            {
                flip = 1;
            }
            else
            {
                mirror = 1;
            }

            screen_set_window_property_iv(win, SCREEN_PROPERTY_MIRROR, &mirror);
            screen_set_window_property_iv(win, SCREEN_PROPERTY_FLIP, &flip);
        }
    }

    // always tell camera which way device is oriented. this allows the EXIF orientation tags to be set correctly,
    // so that physically sideways buffers can be displayed correctly in a photo viewer.  telling the camera which way is up
    // also helps to optimize exposure profiles and aids the face detection algorithms (which only detect upright faces).
    // NOTE: If for some reason we want to rely solely on the physical buffer orientation set by CAMERA_IMGPROP_ROTATION above, then
    // the CAMERA_IMGPROP_METAORIENTATIONHINT photo property can be set to 0.  This would cause the EXIF orientation tag to not be
    // written to the JPEG.  Since many devices do not support physical buffer rotation though, we shouldn't do this.
    err = camera_set_device_orientation(mHandle, mDeviceOrientation);
    if (err) {
        ////qDebug() << "failed to set camera device orientation to" << mDeviceOrientation <<" err:" << err;
    } else {
        ////qDebug() << "camera device orientation set to" << mDeviceOrientation;
    }
}


void ApplicationUI::updateVideoAngle()
{
    int i;
    int err = EOK;
    err = camera_get_videovf_property(mHandle, CAMERA_IMGPROP_ROTATION, &mVfAngle);

    if (mRequireUprightVf) {
        // if required, let's select a physical viewfinder buffer rotation which will result in an upright buffer.
        // if this is not possible, then we have to make up the difference with a screen rotation effect.
        // NOTE: that this is only typically required when we are starting video recording and CAMERA_FEATURE_PREVIEWISVIDEO is
        // asserted.  if we were processing viewfinder pixels and expecting the first one to be in the top-left position, then we
        // would also set this flag.
        // check whether the desired angle is available...
        for (i=0; i<mNumVideoVfRotations; i++) {
            if (mVideoVfRotations[i] == mDesiredVfAngle) break;
        }
        if (i == mNumVideoVfRotations) {
            ////qDebug() << "desired videovf angle" << mDesiredVfAngle << "is not available";
            // we'll have to rely on screen alone in this case.
        } else {
            err = camera_set_videovf_property(mHandle, CAMERA_IMGPROP_ROTATION, mDesiredVfAngle);
            if (err) {
                ////qDebug() << "failed to set videovf angle" << mDesiredVfAngle << "err:" << err;
            } else {
                mVfAngle = mDesiredVfAngle;
                ////qDebug() << "set videovf rotation" << mVfAngle;
            }
        }
    }

    if (mRequireUprightCapture) {
        // if required, let's select a physical capture buffer rotation which will result in an upright buffer.
        // today, all platforms support this in video mode, but in the future, we may need to rely on metadata in the video stream.
        err = camera_get_video_property(mHandle, CAMERA_IMGPROP_ROTATION, &mCaptureAngle);
        if (err) {
            ////qDebug() << "failed to query capture angle. err:" << err;
        } else {
            // check whether the desired angle is available...
            for (i=0; i<mNumVideoRotations; i++) {
                if (mVideoRotations[i] == mDesiredCapAngle) break;
            }
            if (i == mNumVideoRotations) {
                ////qDebug() << "desired video output angle" << mDesiredCapAngle << "is not available";
                // we'll have to rely on metadata alone in this case. (which we cannot do today, since there is no standard for mp4)
            } else {
                err = camera_set_video_property(mHandle, CAMERA_IMGPROP_ROTATION, mDesiredCapAngle);
                if (err) {
                    ////qDebug() << "failed to set video output angle" << mDesiredCapAngle << "err:" << err;
                } else {
                    mCaptureAngle = mDesiredCapAngle;
                    ////qDebug() << "set video output rotation" << mCaptureAngle;
                }
            }
        }
    }

    // compute screen display angle now that we know how the viewfinder buffers are being rotated.
    // remember: desired angle = viewfinder angle + window angle.  solve for viewfinder angle:
    mWindowAngle = (360 + mDesiredVfAngle - mVfAngle) % 360;  // note +360 to avoid negative numbers in modulo math

    if (mRequireUprightVf) {
        // NOTE: in the video case, since viewfinder buffers may be required to match the angle of the video buffers, we must apply a
        // correction offset here (which is the difference between the UI angle and the device orientation angle).  this is typically needed
        // when recording with the device held in an orientation where the UI cannot be rotated.  (eg. most angles on a Q10 or upside-down on a Z10).
        // also note that we are only applying this offset in the case where mRequireUprightVf is asserted.  this is to ensure that
        // this adjustment is only made when we are reconfiguring the viewfinder buffers during recording.
        // There is probably a less confusing way to orchestrate this series of corner-case events, but for now, this should be fine.
        uint32_t uiOffsetAngle = (360 + mOrientationDirection - mDisplayDirection) % 360;
        if (mUnit == CAMERA_UNIT_FRONT) {
            uiOffsetAngle = (360 - uiOffsetAngle) % 360;
        }
        mWindowAngle = (mWindowAngle + uiOffsetAngle) % 360;
    }

    // all we need to do here is update the screen window associated with the viewfinder.
    screen_window_t win = mFwc->windowHandle();
    if (!win) {
        ////qDebug() << "no window handle available to update";
    } else {
        screen_set_window_property_iv(win, SCREEN_PROPERTY_ROTATION, (int*)&mWindowAngle);
        int mirror = 0;
        int flip = 0;
        if (mUnit == CAMERA_UNIT_FRONT) {
            // NOTE: since mirroring is applies after rotation in the order-of-operations, it is necessary to
            // decide between a flip or a mirror in order to make the screen behave like a mirror on the front camera.
            if (mWindowAngle % 180) {
                flip = 1;
            } else {
                mirror = 1;
            }
            screen_set_window_property_iv(win, SCREEN_PROPERTY_MIRROR, &mirror);
            screen_set_window_property_iv(win, SCREEN_PROPERTY_FLIP, &flip);
        }
    }

    // always tell camera which way device is oriented.
    // even though we don't have any metadata tags which can be used with video recordings, telling the camera which way is up
    // helps to optimize exposure profiles and aids the face detection algorithms (which only detect upright faces).
    err = camera_set_device_orientation(mHandle, mDeviceOrientation);
    if (err) {
        ////qDebug() << "failed to set camera device orientation to" << mDeviceOrientation <<" err:" << err;
    } else {
        ////qDebug() << "camera device orientation set to" << mDeviceOrientation;
    }
}


int ApplicationUI::startOrientationReadings()
{
    if (!mOrientationSensor) {
        mOrientationSensor = new QOrientationSensor(this);
        if (!mOrientationSensor) {
            qWarning() << "failed to allocate QOrientationSensor.";
            return ENOMEM;
        }
        mOrientationSensor->setSkipDuplicates(true);
        mOrientationSensor->setDataRate(1);
        mOrientationSensor->setAlwaysOn(true);
        if (!QObject::connect(mOrientationSensor, SIGNAL(readingChanged()), this, SLOT(onOrientationReadingChanged()))) {
            qWarning() << "failed to connect readingChanged signal";
            return EIO;
        }
    }
    mOrientationSensor->start();
    return EOK;
}


void ApplicationUI::stopOrientationReadings()
{
    if (mOrientationSensor) {
        mOrientationSensor->stop();
    }
}


void ApplicationUI::onOrientationReadingChanged()
{
    if (!mOrientationSensor) {
        return;
    }
    ////qDebug() << "onOrientationReadingChanged()";
    QOrientationReading* reading = mOrientationSensor->reading();
    if (reading) {
        switch(reading->orientation()) {
        case QOrientationReading::TopUp:
            mOrientationDirection = DisplayDirection::North;
            break;
        case QOrientationReading::TopDown:
            mOrientationDirection = DisplayDirection::South;
            break;
        case QOrientationReading::LeftUp:
            mOrientationDirection = DisplayDirection::West;
            break;
        case QOrientationReading::RightUp:
            mOrientationDirection = DisplayDirection::East;
            break;
        default:
            // this is an unhandled direction (eg. face-up or face-down), so just reuse the last known reading
            break;
        }
        // note: this was only a QOrientationSensor change event, so leave the UI display direction reading at its last known value...
        updateAngles();
    }
}


void ApplicationUI::onVfParentLayoutFrameChanged(QRectF frame)
{
    ////qDebug() << "viewfinder parent size:" << frame;
    // by default, the ForeignWindowControl that houses the viewfinder will scale to fit the available screen real-estate.
    // this will likely lead to it being stretched in one direction.
    // we're going to un-stretch it, and peg it's aspect ratio at 16:9 (or 9:16).
    mVfContainerSize = frame;
    constrainViewfinderAspectRatio();
}


void ApplicationUI::constrainViewfinderAspectRatio()
{
    if ((mVfContainerSize.width() == 0) || (mVfContainerSize.height() == 0))
    {
        // one of the dimensions is a zero, not wise to do math with this yet
        return;
    }

    // first, determine whether we are aiming for a portrait or landscape aspect ratio (eg. 9:16 or 16:9)
    float aspect = (float)mVfWidth / (float)mVfHeight;
    // if window is displayed at 90 or 270 degrees, then flip the target aspect ratio

    if (mDesiredVfAngle % 180)
    {
        aspect = 1 / aspect;
    }

    // until we figure otherwise, fit to max size
    float width = mVfContainerSize.width();
    float height = mVfContainerSize.height();

    if (height * aspect > width)
    {
        // constrain height, since width cannot be increased
        height = width / aspect;
    }
    else
    {
        // constrain width
        width = height * aspect;
    }

    mFwc->setPreferredSize(width, height);

    //qDebug() << "resized viewfinder to" << width << "x" << height <<"to maintain aspect ratio" << aspect;
}


int ApplicationUI::discoverCameraCapabilities()
{
    // In this function, we will query and cache some core camera capabilities to use for later configuration.
    // 1. photo? video?
    // 2. photo format, rotations, resolutions
    // 3. photo viewfinder format, rotations, resolutions
    // 4. video format, rotations, resolutions
    // 5. video viewfinder format, rotations, resolutions


    // first check for photo & video support
    mCanDoPhoto = mCanDoVideo = false;
    if (camera_has_feature(mHandle, CAMERA_FEATURE_PHOTO)) {
        mCanDoPhoto = true;
    }
    if (camera_has_feature(mHandle, CAMERA_FEATURE_VIDEO)) {
        mCanDoVideo = true;
    }
    emit canDoPhotoChanged(mCanDoPhoto);
    emit canDoVideoChanged(mCanDoVideo);

    int err = EOK;
    if (mCanDoPhoto) {
        err = discoverPhotoCapabilities();
        if (err) {
            ////qDebug() << "failed to discover photo capabilities.";
            return err;
        }
        err = discoverPhotoVfCapabilities();
        if (err) {
            ////qDebug() << "failed to discover photovf capabilities.";
            return err;
        }
    }

    if (mCanDoVideo) {
        err = discoverVideoCapabilities();
        if (err) {
            ////qDebug() << "failed to discover video capabilities.";
            return err;
        }
        err = discoverVideoVfCapabilities();
        if (err) {
            ////qDebug() << "failed to discover videovf capabilities.";
            return err;
        }
    }

    return err;
}


int ApplicationUI::discoverPhotoCapabilities()
{
    int err = EOK;
    // clean up any pre-discovered stuff
    delete[] mPhotoRotations;
    delete[] mPhotoResolutions;
    mNumPhotoRotations = 0;
    mNumPhotoResolutions = 0;

    // now query the current format for photo capture.  in this sample, we are not implementing configurable formats,
    // however we should make sure to know what the default is so that we can query some other discovery functions.
    err = camera_get_photo_property(mHandle, CAMERA_IMGPROP_FORMAT, &mPhotoFormat);
    if (err) {
        ////qDebug() << "failed to query photo format";
    } else {
        // log it.
        ////qDebug() << "current photo format is:" << mPhotoFormat;

        // now query which buffer rotations are available for this format.
        // since we don't know how large the list may be (technically it shouldn't be more than 4 entries), we can
        // query the function in pre-sizing mode -- eg. by providing numasked=0 and a NULL array).
        err = camera_get_photo_rotations(mHandle, mPhotoFormat, false, 0, &mNumPhotoRotations, NULL, NULL);
        if (err) {
            ////qDebug() << "failed to query num photo rotations";
        } else {
            // now allocate enough storage to hold the array
            mPhotoRotations = new uint32_t[mNumPhotoRotations];
            if (!mPhotoRotations) {
                ////qDebug() << "failed to allocate storage for photo rotations array";
                err = ENOMEM;
            } else {
                // now fill the array
                err = camera_get_photo_rotations(mHandle,
                                                 mPhotoFormat,
                                                 false,  // we are not asking about burst mode
                                                 mNumPhotoRotations,
                                                 &mNumPhotoRotations,
                                                 mPhotoRotations,
                                                 NULL);
                if (err) {
                    ////qDebug() << "failed to query photo rotations";
                } else {
                    // log the list.
                    ////qDebug() << "supported photo rotations:";
                    for (int i=0; i<mNumPhotoRotations; i++) {
                        ////qDebug() << mPhotoRotations[i];
                    }
                }
            }
        }
    }

    if (err == EOK) {
        // now query the supported photo resolutions
        err = camera_get_photo_output_resolutions(mHandle, mPhotoFormat, 0, &mNumPhotoResolutions, NULL);
        if (err) {
            ////qDebug() << "failed to query num photo resolutions";
        } else {
            // now allocate enough storage to hold the array
            mPhotoResolutions = new camera_res_t[mNumPhotoResolutions];
            if (!mPhotoResolutions) {
                ////qDebug() << "failed to allocate storage for photo resolutions array";
                err = ENOMEM;
            } else {
                // now fill the array
                err = camera_get_photo_output_resolutions(mHandle,
                                                          mPhotoFormat,
                                                          mNumPhotoResolutions,
                                                          &mNumPhotoResolutions,
                                                          mPhotoResolutions);
                if (err)
                {
                    //qDebug() << "failed to query photo resolutions";
                }
                else
                {
                    // log the list
                    //qDebug() << "supported photo resolutions:";
                    for (unsigned int i=0; i<mNumPhotoResolutions; i++)
                    {
                        //qDebug() << "PHOTO: " << mPhotoResolutions[i].width << "x" << mPhotoResolutions[i].height;
                    }
                }
            }
        }
    }

    return err;
}


int ApplicationUI::discoverPhotoVfCapabilities()
{
    int err = EOK;
    // clean up any pre-discovered stuff
    delete[] mPhotoVfRotations;
    delete[] mPhotoVfResolutions;
    mNumPhotoVfRotations = 0;
    mNumPhotoVfResolutions = 0;

    // now query the current format for photo viewfinder.  in this sample, we are not implementing configurable formats,
    // however we should make sure to know what the default is so that we can query some other discovery functions.
    err = camera_get_photovf_property(mHandle, CAMERA_IMGPROP_FORMAT, &mPhotoVfFormat);
    if (err) {
        ////qDebug() << "failed to query photovf format";
    } else {
        // log it.
        ////qDebug() << "current photovf format is:" << mPhotoVfFormat;

        // now query which buffer rotations are available for this format.
        // since we don't know how large the list may be (technically it shouldn't be more than 4 entries), we can
        // query the function in pre-sizing mode -- eg. by providing numasked=0 and a NULL array).
        err = camera_get_photo_vf_rotations(mHandle, mPhotoVfFormat, 0, &mNumPhotoVfRotations, NULL, NULL);
        if (err) {
            ////qDebug() << "failed to query num photovf rotations";
        } else {
            // now allocate enough storage to hold the array
            mPhotoVfRotations = new uint32_t[mNumPhotoVfRotations];
            if (!mPhotoVfRotations) {
                ////qDebug() << "failed to allocate storage for photovf rotations array";
                err = ENOMEM;
            } else {
                // now fill the array
                err = camera_get_photo_vf_rotations(mHandle,
                                                    mPhotoVfFormat,
                                                    mNumPhotoVfRotations,
                                                    &mNumPhotoVfRotations,
                                                    mPhotoVfRotations,
                                                    NULL);
                if (err) {
                    ////qDebug() << "failed to query photovf rotations";
                } else {
                    // log the list.
                    ////qDebug() << "supported photovf rotations:";
                    for (int i=0; i<mNumPhotoVfRotations; i++) {
                        ////qDebug() << mPhotoVfRotations[i];
                    }
                }
            }
        }
    }

    if (err == EOK) {
        // now query the supported photo vf resolutions
        err = camera_get_photo_vf_resolutions(mHandle, 0, &mNumPhotoVfResolutions, NULL);
        if (err) {
            ////qDebug() << "failed to query num photovf resolutions";
        } else {
            // now allocate enough storage to hold the array
            mPhotoVfResolutions = new camera_res_t[mNumPhotoVfResolutions];
            if (!mPhotoVfResolutions) {
                ////qDebug() << "failed to allocate storage for photovf resolutions array";
                err = ENOMEM;
            } else {
                // now fill the array
                err = camera_get_photo_vf_resolutions(mHandle,
                                                      mNumPhotoVfResolutions,
                                                      &mNumPhotoVfResolutions,
                                                      mPhotoVfResolutions);
                if (err)
                {
                    //qDebug() << "failed to query photovf resolutions";
                }
                else
                {
                    // log the list
                    //qDebug() << "supported photovf resolutions:";
                    for (unsigned int i=0; i<mNumPhotoVfResolutions; i++)
                    {
                        //qDebug() << "PHOTO VF: " << mPhotoVfResolutions[i].width << "x" << mPhotoVfResolutions[i].height;
                    }
                }
            }
        }
    }

    return err;
}


int ApplicationUI::discoverVideoCapabilities()
{
    int err = EOK;
    // clean up any pre-discovered stuff
    delete[] mVideoRotations;
    delete[] mVideoResolutions;
    mNumVideoRotations = 0;
    mNumVideoResolutions = 0;

    // now query the current format for video capture.  in this sample, we are not implementing configurable formats,
    // however we should make sure to know what the default is so that we can query some other discovery functions.
    // this is embarrassing.. apparently the video property is not queryable presently. that is okay, since on all
    // current platforms, the video and videovf streams are the same.  we can add a check here and query the videovf as a workaround.
    if (camera_has_feature(mHandle, CAMERA_FEATURE_PREVIEWISVIDEO))
    {
        err = camera_get_videovf_property(mHandle, CAMERA_IMGPROP_FORMAT, &mVideoFormat);
    }
    else
    {
        err = camera_get_video_property(mHandle, CAMERA_IMGPROP_FORMAT, &mVideoFormat);
    }

    if (err)
    {
        ////qDebug() << "failed to query video format";
    }
    else
    {
        // log it.
        ////qDebug() << "current video format is:" << mVideoFormat;

        // now query which buffer rotations are available for this format.
        // since we don't know how large the list may be (technically it shouldn't be more than 4 entries), we can
        // query the function in pre-sizing mode -- eg. by providing numasked=0 and a NULL array).
        err = camera_get_video_rotations(mHandle, mVideoFormat, 0, &mNumVideoRotations, NULL, NULL);

        if (err)
        {
            ////qDebug() << "failed to query num video rotations";
        }
        else
        {
            // now allocate enough storage to hold the array
            mVideoRotations = new uint32_t[mNumVideoRotations];
            if (!mVideoRotations)
            {
                ////qDebug() << "failed to allocate storage for video rotations array";
                err = ENOMEM;
            }
            else
            {
                // now fill the array
                err = camera_get_video_rotations(mHandle,mVideoFormat, mNumVideoRotations,&mNumVideoRotations,mVideoRotations,NULL);

                if (err) {
                    ////qDebug() << "failed to query video rotations";
                } else {
                    // log the list.
                    ////qDebug() << "supported video rotations:";
                    for (int i=0; i<mNumVideoRotations; i++) {
                        ////qDebug() << mVideoRotations[i];
                    }
                }
            }
        }
    }

    if (err == EOK)
    {
        // now query the supported video resolutions
        err = camera_get_video_output_resolutions(mHandle, 0, &mNumVideoResolutions, NULL);

        if (err)
        {
            ////qDebug() << "failed to query num video resolutions";
        }
        else
        {
            // now allocate enough storage to hold the array
            mVideoResolutions = new camera_res_t[mNumVideoResolutions];

            if (!mVideoResolutions)
            {
                ////qDebug() << "failed to allocate storage for video resolutions array";
                err = ENOMEM;
            }
            else
            {
                // now fill the array
                err = camera_get_video_output_resolutions(mHandle, mNumVideoResolutions, &mNumVideoResolutions, mVideoResolutions);

                if (err)
                {
                    //qDebug() << "failed to query video resolutions";
                }
                else
                {
                    //qDebug() << "supported video resolutions:";

                    for (unsigned int i=0; i<mNumVideoResolutions; i++)
                    {
                        //qDebug() << "VIDEO: " << mVideoResolutions[i].width << "x" << mVideoResolutions[i].height;
                    }
                }
            }
        }
    }

    return err;
}


int ApplicationUI::discoverVideoVfCapabilities()
{
    int err = EOK;
    // clean up any pre-discovered stuff
    delete[] mVideoVfRotations;
    delete[] mVideoVfResolutions;
    mNumVideoVfRotations = 0;
    mNumVideoVfResolutions = 0;

    // now query the current format for video viewfinder.  in this sample, we are not implementing configurable formats,
    // however we should make sure to know what the default is so that we can query some other discovery functions.
    err = camera_get_videovf_property(mHandle, CAMERA_IMGPROP_FORMAT, &mVideoVfFormat);
    if (err) {
        ////qDebug() << "failed to query videovf format";
    } else {
        // log it.
        ////qDebug() << "current videovf format is:" << mVideoVfFormat;

        // now query which buffer rotations are available for this format.
        // since we don't know how large the list may be (technically it shouldn't be more than 4 entries), we can
        // query the function in pre-sizing mode -- eg. by providing numasked=0 and a NULL array).
        err = camera_get_video_vf_rotations(mHandle, mVideoVfFormat, 0, &mNumVideoVfRotations, NULL, NULL);
        if (err) {
            ////qDebug() << "failed to query num videovf rotations";
        } else {
            // now allocate enough storage to hold the array
            mVideoVfRotations = new uint32_t[mNumVideoVfRotations];
            if (!mVideoVfRotations) {
                ////qDebug() << "failed to allocate storage for videovf rotations array";
                err = ENOMEM;
            } else {
                // now fill the array
                err = camera_get_video_vf_rotations(mHandle,
                                                    mVideoVfFormat,
                                                    mNumVideoVfRotations,
                                                    &mNumVideoVfRotations,
                                                    mVideoVfRotations,
                                                    NULL);
                if (err) {
                    ////qDebug() << "failed to query videovf rotations";
                } else {
                    // log the list.
                    ////qDebug() << "supported videovf rotations:";
                    for (int i=0; i<mNumVideoVfRotations; i++) {
                        ////qDebug() << mVideoVfRotations[i];
                    }
                }
            }
        }
    }

    if (err == EOK) {
        // now query the supported video vf resolutions
        err = camera_get_video_vf_resolutions(mHandle, 0, &mNumVideoVfResolutions, NULL);
        if (err) {
            ////qDebug() << "failed to query num videovf resolutions";
        } else {
            // now allocate enough storage to hold the array
            mVideoVfResolutions = new camera_res_t[mNumVideoVfResolutions];
            if (!mVideoVfResolutions) {
                ////qDebug() << "failed to allocate storage for videovf resolutions array";
                err = ENOMEM;
            } else {
                // now fill the array
                err = camera_get_video_vf_resolutions(mHandle,
                                                      mNumVideoVfResolutions,
                                                      &mNumVideoVfResolutions,
                                                      mVideoVfResolutions);
                if (err)
                {
                    //qDebug() << "failed to query videovf resolutions";
                }
                else
                {
                    // log the list
                    //qDebug() << "supported videovf resolutions:";
                    for (unsigned int i=0; i<mNumVideoVfResolutions; i++) {
                        //qDebug() << "VIDEO VF: " << mVideoVfResolutions[i].width << "x" << mVideoVfResolutions[i].height;
                    }
                }
            }
        }
    }

    return err;
}


camera_res_t* ApplicationUI::matchAspectRatio(camera_res_t* target, camera_res_t* resList, int numRes, float accuracy)
{
    // this function will scan the list (resList) for resolutions which match the input aspect ratio (target) within
    // a margin of error of accuracy %.  eg. 0% means only match exact aspect ratios.
    camera_res_t* best = NULL;

    if (target && resList && numRes)
    {
        float targetRatio = (float)(target->width) / (float)(target->height);
        float bestError = 0;

        for (int i=0; i<numRes; i++)
        {
            float thisRatio = (float)(resList[i].width) / (float)(resList[i].height);
            float thisError = fabs((thisRatio / targetRatio) - 1.0f);

            if (thisError <= accuracy)
            {
                if (!best || (thisError < bestError))
                {
                    best = &resList[i];
                    bestError = thisError;
                }
            }
        }
    }

    return best;
}

// BEST CAM

//void ApplicationUI::positionUpdated(const QGeoPositionInfo &update)
//{
//	if (!update.isValid())
//	{
//		Flurry::Analytics::LogError("positionUpdated returned invalid location fix");
//		return;
//	}
//
//	QGeoCoordinate coordinate = update.coordinate();
//	Flurry::Analytics::SetLocation(coordinate.latitude(),
//			coordinate.longitude(),
//			update.attribute(QGeoPositionInfo::HorizontalAccuracy),
//			update.attribute(QGeoPositionInfo::VerticalAccuracy));
//}

void ApplicationUI::flurrySetUserID(QString value)
{
	Flurry::Analytics::SetUserID(value);
}

void ApplicationUI::flurryLogError(QString value)
{
	Flurry::Analytics::LogError(value);
}

void ApplicationUI::flurryLogEvent(QString value)
{
	Flurry::Analytics::LogEvent(value);
}

bool ApplicationUI::wipeFolderContents(const QString &folder)
{
	bool result = false;

	if(folder.length() > 0)
	{
		QDir dir(folder);

		if (dir.exists(folder))
		{
			Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files | QDir::AllEntries | QDir::Writable, QDir::DirsFirst))
			{
				if (info.isDir())
				{
					result = wipeFolder(info.absoluteFilePath());
				}
				else
				{
					result = QFile::remove(info.absoluteFilePath());
				}
			}

			//result = dir.rmdir(folder);
		}
	}

    return result;
}

bool ApplicationUI::wipeFolder(const QString &folder)
{
	bool result = false;

	if(folder.length() > 0)
	{
		QDir dir(folder);

		if (dir.exists(folder))
		{
			Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files | QDir::AllEntries | QDir::Writable, QDir::DirsFirst))
			{
				if (info.isDir())
				{
					result = wipeFolder(info.absoluteFilePath());
				}
				else
				{
					result = QFile::remove(info.absoluteFilePath());
				}
			}

			result = dir.rmdir(folder);
		}
	}

    return result;
}

void ApplicationUI::scrollBeginningFeeds()
{
    emit scrollBeginningFeedsSignal();
}

void ApplicationUI::openCameraTab(QVariant parameters)
{
    emit openCameraTabSignal(parameters);
}

void ApplicationUI::redrawTabs()
{
    emit redrawTabsSignal();
}

void ApplicationUI::loadUpdates()
{
    emit loadUpdatesSignal();
}

void ApplicationUI::loadStories()
{
    emit loadStoriesSignal();
}

void ApplicationUI::openLoginSheet()
{
    emit openLoginSheetSignal();
}

void ApplicationUI::openSettings()
{
    emit openSettingsSignal();
}

void ApplicationUI::openAboutSheet()
{
    emit openAboutSheetSignal();
}

void ApplicationUI::invokeOpenWithMediaPlayer(QString file)
{
	InvokeRequest request;
	request.setTarget("sys.mediaplayer.previewer");
	request.setAction("bb.action.OPEN");
	request.setUri(file);

	QVariantMap payload;
	payload["contentTitle"] = "Snap2Chat Video";

	request.setMetadata(payload);
	invokeManager->invoke(request);
}

void ApplicationUI::notify(QString title, QString body)
{
//	if(getSetting("notificationsEnabled", "true") == "true")
//	{
		Notification* notification = new Notification();
		notification->setTitle(title);
		notification->setBody(body);

		// 10.2
		notification->setIconUrl(QUrl("app/native/assets/images/icon.png")) ;

		InvokeRequest invokeRequest;
		invokeRequest.setTarget("com.nemory.snap2chat.invoke.open");
		invokeRequest.setAction("bb.action.OPEN");
		invokeRequest.setMimeType("text/plain");
		notification->setInvokeRequest(invokeRequest);

		notification->notify();
	//}
}

void ApplicationUI::clearNotifications()
{
	Notification* notification = new Notification();
	notification->clearEffectsForAll();
	notification->deleteAllFromInbox();
}

void ApplicationUI::clearNotificationEffects()
{
    Notification* notification = new Notification();
    notification->clearEffectsForAll();
}

QString ApplicationUI::getCurrentPublicPath()
{
	return QString::fromLatin1("file://%1/app/public/").arg(QDir::currentPath());
}

void ApplicationUI::checkSharedFilesPermission()
{
	QString filename = "" + QDir::currentPath() + "/shared/camera/test.txt";

	QFile *testFile = new QFile();
	testFile->setFileName(filename);

	if(testFile->open(QIODevice::ReadWrite))
	{
		testFile->remove();
		testFile->deleteLater();
	}
	else
	{
		emit cameraErrorSignal("Please make sure you have accepted Shared Files Permission during installation. \n\nTo re enable permissions, please go to Settings App, App Manager, Permissions, Snap2Chat, enable all the permissions possible for Snap2Chat work perfectly. Please restart Snap2Chat after. \n\n for further support please don't hesitate to contact us snap2chat@gmail.com \n\nThank you so much");
	}
}

QString ApplicationUI::getContactPhoneNumber(int id)
{
//	Contact contact = ContactService().contactDetails(id);
//
//	if(contact.phoneNumbers().length() > 0)
//	{
//		return contact.phoneNumbers().first().value();
//	}
//	else
//	{
//		return "This contact has no phone number";
//	}

	return "";
}

QString ApplicationUI::getContactEmail(int id)
{
//	Contact contact = ContactService().contactDetails(id);
//
//	if(contact.emails().length() > 0)
//	{
//		return contact.emails().first().value();
//	}
//	else
//	{
//		return "This contact has no email";
//	}

	return "";
}

qreal ApplicationUI::getImageRotation(QUrl _url)
{
	qreal rotation = -1;
	QString url = _url.toLocalFile();

	if (url.endsWith("jpg", Qt::CaseInsensitive) || url.endsWith("png", Qt::CaseInsensitive))
	{
		QByteArray ba = url.toLocal8Bit();
		ExifData* exifData = exif_data_new_from_file(ba.constData());

		if (exifData != NULL)
		{
			ExifEntry* exifEntry = exif_content_get_entry(exifData->ifd[EXIF_IFD_0], EXIF_TAG_ORIENTATION);

			if (exifEntry != NULL)
			{
				char value[256] = { 0, };
				memset(value, 0, sizeof(value));
				exif_entry_get_value(exifEntry, value, sizeof(value));

				QString orient = QString::fromLocal8Bit(value);

				if (orient.compare("bottom-right", Qt::CaseInsensitive) == 0)
				{
					rotation = 180.0;
				}
				else if (orient.compare("right-top", Qt::CaseInsensitive) == 0)
				{
					rotation = 90.0;
				}
				else if (orient.compare("left-bottom", Qt::CaseInsensitive) == 0)
				{
					rotation = 270.0;
				}

				delete exifEntry;
			}

			delete exifData;
		}
	}

	qDebug() << "IMAGE ROTATION: " + QString::number(rotation);

	return rotation;
}

void ApplicationUI::rotateCorrectly(QString imagePath)
{
	QImage image = QImage(imagePath);

	QTransform transform;
	transform.rotate(getImageRotation(QUrl(imagePath)));

	image = image.transformed(transform);

	image.save(imagePath, "JPG");
}

void ApplicationUI::preProcess(QString imagePath, bool mirror)
{
	QImage image = QImage(imagePath);

	QTransform transform;
	transform.rotate(getImageRotation(QUrl(imagePath)));

	if(mUnit == CAMERA_UNIT_REAR)
	{
		transform.scale(0.5, 0.5);
	}

	image = image.transformed(transform);

	if(mUnit == CAMERA_UNIT_FRONT && getSetting("mirrorFront", "true") == "true" && mirror)
	{
		image = image.mirrored(true, false);
	}

	image.save(imagePath, "JPG");
}

int ApplicationUI::getDisplayHeight()
{
	DisplayInfo displayInfo;
	return displayInfo.pixelSize().height();
}

int ApplicationUI::getDisplayWidth()
{
	DisplayInfo displayInfo;
	return displayInfo.pixelSize().width();
}

void ApplicationUI::copy(QString from, QString to)
{
	if(QFile::exists(from))
	{
		if(QFile::exists(to))
		{
			QFile::remove(to);
		}

		if(!QFile::copy(from, to))
		{
			qDebug() << "COPY: " << from << " FAILED TO COPY TO " << to;
		}
	}
	else
	{
		qDebug() << "COPY: " << from << " DOES NOT EXIST";
	}
}

void ApplicationUI::deletePhoto(QString fileName)
{
	if(QFile::exists(fileName))
	{
		QFile::remove(fileName);
	}
}

void ApplicationUI::copyAndRemove(QString from, QString to)
{
	if(QFile::exists(from))
	{
		if(QFile::exists(to))
		{
			QFile::remove(to);
		}

		if(QFile::copy(from, to))
		{
			QFile::remove(from);
		}
	}
}

QString ApplicationUI::getHomePath()
{
	return QDir::homePath();
}

QString ApplicationUI::getTempPath()
{
	return QDir::tempPath();
}

bool ApplicationUI::contains(QString text, QString find)
{
	if(find == "" || find == " " || find == "  " || text == "" || text == " " || text == "  ")
	{
		return false;
	}

	bool result;

	if(getSetting("caseSensitive", "false") == "true")
	{
		result = text.contains(find, Qt::CaseSensitive);
	}
	else if(getSetting("caseSensitive", "false") == "false")
	{
		result = text.contains(find, Qt::CaseInsensitive);
	}

	return result;
}


QString ApplicationUI::getSetting(const QString &objectName, const QString &defaultValue)
{
	QSettings _settings(AUTHOR, APPNAME);

	if (_settings.value(objectName).isNull() || _settings.value(objectName) == "")
	{
		return defaultValue;
	}

	return _settings.value(objectName).toString();
}

void ApplicationUI::setSetting(const QString &objectName, const QString &inputValue)
{
	QSettings _settings(AUTHOR, APPNAME);
	_settings.setValue(objectName, QVariant(inputValue));
}

void ApplicationUI::showToast(const QString &text)
{
	SystemToast *toast = new SystemToast(this);
	toast->setBody(text);
	toast->setPosition(SystemUiPosition::BottomCenter);
	toast->show();
}

void ApplicationUI::showDialog(const QString &title, const QString &text) {
	SystemDialog *dialog = new SystemDialog(this);
	dialog->setTitle(title);
	dialog->setBody(text);
	dialog->setEmoticonsEnabled(true);
	dialog->show();
}

void ApplicationUI::invokeSMSCompose(QString to, QString body, bool send)
{
	InvokeRequest request;
	request.setTarget("sys.pim.text_messaging.composer");
	request.setAction("bb.action.COMPOSE");

	QVariantMap map;
	map.insert("to", to);
	map.insert("body", body);
	map.insert("send", send);
	QByteArray requestData = PpsObject::encode(map, NULL);

	request.setData(requestData);
	invokeManager->invoke(request);
}

void ApplicationUI::invokeEmail(QString email, QString subject, QString body)
{
	InvokeRequest request;
	request.setTarget("sys.pim.uib.email.hybridcomposer");
	request.setAction("bb.action.SENDEMAIL");
	request.setUri(
			"mailto:" + email + "?subject=" + subject.replace(" ", "%20")
					+ "&body=" + body.replace(" ", "%20"));
	invokeManager->invoke(request);
}

void ApplicationUI::invokeBBWorld(QString appurl)
{
	InvokeRequest request;
	request.setMimeType("application/x-bb-appworld");
	request.setAction("bb.action.OPEN");
	request.setUri(appurl);
	invokeManager->invoke(request);
}

void ApplicationUI::invokeBrowser(QString url)
{
	InvokeRequest request;
	request.setTarget("sys.browser");
	request.setAction("bb.action.OPEN");
	request.setUri(url);
	invokeManager->invoke(request);
}

// -------------------------------------------------------------

void ApplicationUI::write_bitmap_header(int nbytes, QByteArray& ba, const int size[])
{
        char header[54];

        /* Set standard bitmap header */
        header[0] = 'B';
        header[1] = 'M';
        header[2] = nbytes & 0xff;
        header[3] = (nbytes >> 8) & 0xff;
        header[4] = (nbytes >> 16) & 0xff;
        header[5] = (nbytes >> 24) & 0xff;
        header[6] = 0;
        header[7] = 0;
        header[8] = 0;
        header[9] = 0;
        header[10] = 54;
        header[11] = 0;
        header[12] = 0;
        header[13] = 0;
        header[14] = 40;
        header[15] = 0;
        header[16] = 0;
        header[17] = 0;
        header[18] = size[0] & 0xff;
        header[19] = (size[0] >> 8) & 0xff;
        header[20] = (size[0] >> 16) & 0xff;
        header[21] = (size[0] >> 24) & 0xff;
        header[22] = -size[1] & 0xff;
        header[23] = (-size[1] >> 8) & 0xff;
        header[24] = (-size[1] >> 16) & 0xff;
        header[25] = (-size[1] >> 24) & 0xff;
        header[26] = 1;
        header[27] = 0;
        header[28] = 32;
        header[29] = 0;
        header[30] = 0;
        header[31] = 0;
        header[32] = 0;
        header[33] = 0;
        header[34] = 0; /* image size*/
        header[35] = 0;
        header[36] = 0;
        header[37] = 0;
        header[38] = 0x9;
        header[39] = 0x88;
        header[40] = 0;
        header[41] = 0;
        header[42] = 0x9l;
        header[43] = 0x88;
        header[44] = 0;
        header[45] = 0;
        header[46] = 0;
        header[47] = 0;
        header[48] = 0;
        header[49] = 0;
        header[50] = 0;
        header[51] = 0;
        header[52] = 0;
        header[53] = 0;

        ba.append(header, sizeof(header));
}


void ApplicationUI::captureScreen(int orientation)
{
	int width = getDisplayWidth();
	int height = getDisplayHeight();

	if(orientation == 1) // landscape
	{
		height = getDisplayWidth();
		width = getDisplayHeight();
	}

	screen_pixmap_t screen_pix;
	screen_buffer_t screenshot_buf;
	screen_context_t context;
	screen_create_context(&context, 0);

	char *screenshot_ptr = NULL;
	int screenshot_stride = 0;

	int usage, format;
	int size[2];

	screen_create_pixmap(&screen_pix, context);

	usage = SCREEN_USAGE_READ | SCREEN_USAGE_NATIVE;
	screen_set_pixmap_property_iv(screen_pix, SCREEN_PROPERTY_USAGE, &usage);

	format = SCREEN_FORMAT_RGBA8888;
	screen_set_pixmap_property_iv(screen_pix, SCREEN_PROPERTY_FORMAT, &format);

	size[0] = width;
	size[1] = height;
	screen_set_pixmap_property_iv(screen_pix, SCREEN_PROPERTY_BUFFER_SIZE, size);

	screen_create_pixmap_buffer(screen_pix);
	screen_get_pixmap_property_pv(screen_pix, SCREEN_PROPERTY_RENDER_BUFFERS,
								  (void**)&screenshot_buf);
	screen_get_buffer_property_pv(screenshot_buf, SCREEN_PROPERTY_POINTER,
								  (void**)&screenshot_ptr);
	screen_get_buffer_property_iv(screenshot_buf, SCREEN_PROPERTY_STRIDE,
								  &screenshot_stride);

	screen_read_window(Application::instance()->mainWindow()->handle(), screenshot_buf, 0, NULL ,0);

	QByteArray array;

	int nbytes = size[0] * size[1] * 4;
	write_bitmap_header(nbytes, array, size);

	for (int i = 0; i < size[1]; i++)
	{
		array.append(screenshot_ptr + i * screenshot_stride, size[0] * 4);
	}

	QImage image = QImage::fromData(array, "BMP");
	QFile outFile(getHomePath() + "/files/sent/temporary-" + QString::number(_tempID) + ".jpg");
	outFile.open(QIODevice::WriteOnly);
	image.save(&outFile, "JPEG");
	outFile.close();

	screen_destroy_pixmap(screen_pix);
}

void ApplicationUI::sendSMS(QString recipientNumber, QString messageText)
{
//	QStringList phoneNumbers;
//	phoneNumbers << recipientNumber;
//
//	bb::pim::account::AccountService accountService;
//	bb::pim::message::MessageService messageService;
//
//	QList<Account> accountListy = accountService.accounts(bb::pim::account::Service::Messages,"sms-mms");
//
//	bb::pim::account::AccountKey smsAccountId = 0;
//
//	if(!accountListy.isEmpty())
//	{
//		smsAccountId = accountListy.first().id();
//		////qDebug() << "SMS-MMS account ID:" << smsAccountId;
//	}
//	else
//	{
//		showToast("Could not find SMS account");
//		return;
//	}
//
//	QList<bb::pim::message::MessageContact> participants;
//
//	foreach(const QString &phoneNumber, phoneNumbers)
//	{
//		bb::pim::message::MessageContact recipient = bb::pim::message::MessageContact(
//			-1, bb::pim::message::MessageContact::To,
//			phoneNumber, phoneNumber);
//		participants.append(recipient);
//	}
//
//	bb::pim::message::ConversationBuilder *conversationBuilder =
//		bb::pim::message::ConversationBuilder::create();
//	conversationBuilder->accountId(smsAccountId);
//	conversationBuilder->participants(participants);
//
//	bb::pim::message::Conversation conversation = *conversationBuilder;
//	bb::pim::message::ConversationKey conversationId = messageService.save(smsAccountId, conversation);
//
//	bb::pim::message::MessageBuilder *builder =
//		bb::pim::message::MessageBuilder::create(smsAccountId);
//	builder->conversationId(conversationId);
//
//	//builder->addAttachment(bb::pim::message::Attachment("text/plain", "", messageText.toUtf8()));
//
//	QByteArray bodyData = messageText.toUtf8();
//
//	builder->body(MessageBody::PlainText, bodyData);
//
//	foreach(const bb::pim::message::MessageContact recipient, participants) {
//		builder->addRecipient(recipient);
//	}
//
//	bb::pim::message::Message message = *builder;
//
//	messageService.send(smsAccountId, message);
//
//	delete builder;
//	delete conversationBuilder;
}

QString ApplicationUI::getContacts(int limit)
{
//	ContactListFilters filters;
//	filters.setLimit(limit);
//
//	QList<Contact> contacts = ContactService().contacts(filters);
//
//	QVariantList theContactList;
//
//	QString contactsJSON = "";
//
//	if(contacts.size() > 0)
//	{
//		int index = 0;
//
//		foreach (Contact contact, contacts)
//		{
//			index++;
//
//			Contact theContact = ContactService().contactDetails(contact.id());
//
//			QString contactName = theContact.firstName() + " " + theContact.lastName();
//			QString contactNumber = "";
//
//			QList<ContactAttribute> phoneNumbersAttributes = theContact.phoneNumbers();
//
//			QVariantList phoneNumbers;
//
//			foreach (ContactAttribute phoneNumberAttribute, phoneNumbersAttributes)
//			{
//				if(phoneNumberAttribute.value().length() > 0)
//				{
//					contactNumber = phoneNumberAttribute.value();
//				}
//			}
//
//			QString jsonObject = "\""+ contactNumber +"\":\""+ contactName +"\"";
//
//			if(index != contacts.size())
//			{
//				jsonObject += ",";
//			}
//
//			contactsJSON += jsonObject;
//		}
//	}
//
//	contactsJSON = "{" + contactsJSON + "}";
//
//	//qDebug() << "CONTACT JSON: " << contactsJSON;
//
//	return contactsJSON;
}
