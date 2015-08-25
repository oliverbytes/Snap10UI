#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/system/InvokeManager>
#include <bb/cascades/multimedia/CameraUnit>
#include <bb/cascades/NavigationPane>
#include <bb/cascades/Page>
#include <bb/cascades/QmlDocument>
#include <bb/data/JsonDataAccess>
#include <bb/system/CardDoneMessage.hpp>

//#include <QFileSystemWatcher>

// AES

#include "Encryption/GlobalContext.hpp"

//BEST CAM

#include <QThread>
#include <camera/camera_api.h>
#include <bb/cascades/DisplayDirection>
#include <bb/cascades/UIOrientation>
#include <QRectF>

//BEST CAM

using bb::system::InvokeManager;
using bb::system::InvokeRequest;
using namespace bb::system;
using namespace bb::cascades;
using namespace bb::data;


//using namespace QtMobilitySubset;

namespace bb
{
    namespace cascades
    {
        class Application;
        class ForeignWindowControl;

        namespace system
		{
			class InvokeManager;
		}
    }
}

// BEST CAM

namespace QtMobility
{
    class QOrientationSensor;
}

class ApplicationUI;

class QTcpServer;
class QTcpSocket;

class StatusThread : public QThread
{
    Q_OBJECT

public:

    StatusThread(ApplicationUI* cam);
    void run();
    void cleanShutdown();

signals:

    void statusChanged(camera_devstatus_t, uint16_t);

private:

    ApplicationUI* mCam;
    camera_handle_t mHandle;
    bool mStop;
    int mChId;
    int mCoId;
    struct sigevent mEvent;
    static const int mPulseId = 123;
};

// BEST CAM

class QTranslator;

class ApplicationUI : public QObject
{
    Q_OBJECT

public:
    ApplicationUI(bb::cascades::Application *app);
    virtual ~ApplicationUI();

    void listen();

    static const QString AUTHOR;
	static const QString APPNAME;

	Q_INVOKABLE void writeLogToFile(QString log);

	Q_INVOKABLE void backUpCache();

	Q_INVOKABLE void log();

	Q_INVOKABLE void socketSend(QString data);

	Q_SLOT void cardResizeRequested(const bb::system::CardResizeMessage& resizeMessage);
	Q_SLOT void closeCard();

    Q_PROPERTY (int tempID READ getTempID WRITE setTempID NOTIFY tempIDChanged)
	Q_PROPERTY(bool purchasedAds READ getPurchasedAds WRITE setPurchasedAds NOTIFY purchasedAdsChanged)

    // AES

	Q_INVOKABLE QString getEncryptionKey();

	Q_INVOKABLE bool encrypt(QString filename, QString newfilename);
	Q_INVOKABLE void decrypt(QString filename, QString newfilename, QString encryptionMode, QString key, QString iv);

	Q_PROPERTY (bool cryptoAvailable READ isCryptoAvailable NOTIFY cryptoAvailableChanged);

	Q_INVOKABLE bool isCryptoAvailable()
	{
		return globalContext.isValid();
	}

    // BEST CAM

    friend class StatusThread;

	Q_ENUMS(VfMode);
	Q_ENUMS(CameraUnit);

	// an enum we can expose to QML
	enum CameraUnit
	{
		UnitNone = CAMERA_UNIT_NONE,
		UnitFront = CAMERA_UNIT_FRONT,
		UnitRear = CAMERA_UNIT_REAR
	};

	enum VfMode
	{
		ModeNone = 0,
		ModePhoto,
		ModeVideo,
	};

	enum CamState
	{
		StateIdle = 0,
		StateStartingPhotoVf,
		StatePhotoVf,
		StatePhotoCapture,
		StateStartingVideoVf,
		StateVideoVf,
		StateVideoCapture,
		StatePowerDown,
		StateMinimized
	};

	Q_PROPERTY(CameraUnit cameraUnit READ cameraUnit NOTIFY cameraUnitChanged);
	CameraUnit cameraUnit() const { return (CameraUnit)mUnit; }

	Q_PROPERTY(VfMode vfMode READ vfMode NOTIFY vfModeChanged);
	VfMode vfMode() const { return mVfMode; }

	Q_PROPERTY(bool hasFrontCamera READ hasFrontCamera NOTIFY hasFrontCameraChanged)
	bool hasFrontCamera() const { return mHasFrontCamera; }

	Q_PROPERTY(bool hasRearCamera READ hasRearCamera NOTIFY hasRearCameraChanged)
	bool hasRearCamera() const { return mHasRearCamera; }

	Q_PROPERTY(bool canDoPhoto READ canDoPhoto NOTIFY canDoPhotoChanged)
	bool canDoPhoto() const { return mCanDoPhoto; }

	Q_PROPERTY(bool canDoVideo READ canDoVideo NOTIFY canDoVideoChanged)
	bool canDoVideo() const { return mCanDoVideo; }

	Q_PROPERTY(bool canCapture READ canCapture NOTIFY canCaptureChanged)
	bool canCapture() const { return mCanCapture; }

	Q_PROPERTY(bool capturing READ capturing NOTIFY capturingChanged)
	bool capturing() const { return mCapturing; }

	Q_INVOKABLE
	int setCameraUnit(CameraUnit unit);

	Q_INVOKABLE
	int openCamera(camera_unit_t unit);

	Q_INVOKABLE
	int closeCamera();

	bool getPurchasedAds();
    void setPurchasedAds(bool value);

	Q_INVOKABLE void setFlashMode(bool onOff);
	Q_INVOKABLE void setFocusMode(camera_focusmode_t mode);
	Q_INVOKABLE void setVideoLight(bool onOff);

	Q_INVOKABLE void minimizeCamera();
	Q_INVOKABLE void maximizeCamera();

	Q_INVOKABLE
	int setVfMode(VfMode mode);

	Q_INVOKABLE
	int windowAttached();

	Q_INVOKABLE
	int capture();

    // BEST CAM

	Q_INVOKABLE void checkSharedFilesPermission();

	Q_INVOKABLE qint64 getCacheSize();

	Q_INVOKABLE void initializeCamera();

    Q_INVOKABLE void flurrySetUserID(QString value);
    Q_INVOKABLE void flurryLogError(QString value);
    Q_INVOKABLE void flurryLogEvent(QString value);

    Q_INVOKABLE void extractZippedVideo(QString id);
    Q_INVOKABLE void zip(QString filename, QString folder);
    Q_INVOKABLE void unzip(QString zipfile, QString folder);

    Q_INVOKABLE void openTheCamera();
    Q_INVOKABLE void openCameraTab(QVariant parameters);
    Q_INVOKABLE void openLoginSheet();
    Q_INVOKABLE void loadUpdates();
    Q_INVOKABLE void loadStories();
    Q_INVOKABLE void openSettings();
    Q_INVOKABLE void openAboutSheet();
    Q_INVOKABLE void redrawTabs();
    Q_INVOKABLE void scrollBeginningFeeds();

    Q_INVOKABLE void sendSMS(QString recipientNumber, QString message);

    Q_INVOKABLE void write_bitmap_header(int nbytes, QByteArray& ba, const int size[]);
	Q_INVOKABLE void captureScreen(int orientation);

	Q_INVOKABLE bool contains(QString text, QString find);

	Q_INVOKABLE int getDisplayHeight();
	Q_INVOKABLE int getDisplayWidth();

	Q_INVOKABLE QString getContactPhoneNumber(int id);
	Q_INVOKABLE QString getContactEmail(int id);

	Q_INVOKABLE QString getCurrentPublicPath();

	Q_INVOKABLE void invokeSMSCompose(QString to, QString body, bool send);
	Q_INVOKABLE void invokeEmail(QString email, QString subject, QString body);
	Q_INVOKABLE void invokeBBWorld(QString appurl);
	Q_INVOKABLE void invokeBrowser(QString url);

	Q_INVOKABLE qreal getImageRotation(QUrl _url);
	Q_INVOKABLE void preProcess(QString imagePath, bool mirror);
	Q_INVOKABLE void rotateCorrectly(QString imagePath);

	Q_INVOKABLE void notify(QString title, QString body);
	Q_INVOKABLE void clearNotifications();
	Q_INVOKABLE void clearNotificationEffects();

	Q_INVOKABLE QString getHomePath();
	Q_INVOKABLE QString getTempPath();

	Q_INVOKABLE void deletePhoto(QString fileName);
	Q_INVOKABLE void copy(QString from, QString to);
	Q_INVOKABLE void copyAndRemove(QString from, QString to);

	Q_INVOKABLE void showToast(const QString &text);
	Q_INVOKABLE void showDialog(const QString &title, const QString &text);

	Q_INVOKABLE QString getSetting(const QString &objectName, const QString &defaultValue);
	Q_INVOKABLE void setSetting(const QString &objectName, const QString &inputValue);

	Q_INVOKABLE bool wipeFolder(const QString &folder);
	Q_INVOKABLE bool wipeFolderContents(const QString &folder);

	Q_INVOKABLE QString getContacts(int limit);

	Q_INVOKABLE void invokeOpenWithMediaPlayer(QString file);

	Q_INVOKABLE void initializeUploadingItems();

	Q_INVOKABLE int getFileSize(QString filename);
	Q_INVOKABLE bool validFileSize(QString filename);

signals:

	void startLoadingSignal();
	void stopLoadingSignal();

	void invokedExtendedSearch(QString data);
	void invokedCompose();
	void invokedOpenConversation(QVariant data);
	void cameraErrorSignal(QString error);
	void socketReceived(QString data);
	void initializeUploadingItemsSignal();
	void tempIDChanged(int);
	void cryptoAvailableChanged();
	void openCameraTabSignal(QVariant parameters);
	void openSnapEditorSignal(QString fileLocation, bool mirror, bool attached);
	void openLoginSheetSignal();
	void parseUpdatesJSONSignal(QVariant parameters);
	void openSettingsSignal();
	void openAboutSheetSignal();
	void loadUpdatesSignal();
	void loadStoriesSignal();
	void redrawTabsSignal();
	void scrollBeginningFeedsSignal();
	void purchasedAdsChanged(bool);

	// BEST CAM

	void cameraUnitChanged(CameraUnit);
	void vfModeChanged(VfMode);
	void hasFrontCameraChanged(bool);
	void hasRearCameraChanged(bool);
	void canDoPhotoChanged(bool);
	void canDoVideoChanged(bool);
	void canCaptureChanged(bool);
	void suppressStartChanged(bool);
	void captureComplete(int);
	void capturingChanged(bool);

public slots:

	//void changesTimerTimeOut();

	void onInvoked(const bb::system::InvokeRequest& invokeRequest);

	void onCaptureComplete(int err);
	void onStatusChanged(camera_devstatus_t status, uint16_t extra);
	void onFullscreen();
	void onThumbnail();
	void onInvisible();
	void onDisplayDirectionChanging(bb::cascades::DisplayDirection::Type displayDirection, bb::cascades::UIOrientation::Type orientation);
	void onOrientationReadingChanged();
	void onVfParentLayoutFrameChanged(QRectF frame);

	// BEST CAM

public Q_SLOTS:

	//void settingsChanged(const QString & path);

	void newConnection();
    void readyRead();
    void connected();
    void disconnected();

	void cardDone(const QString& msg);

private Q_SLOTS:

	void resized(const bb::system::CardResizeMessage&);
	void pooled(const bb::system::CardDoneMessage&);

//	void onMessageAdded(bb::pim::account::AccountKey accountId, bb::pim::message::ConversationKey conversationId, bb::pim::message::MessageKey messageId);
//	void onMessageUpdated(bb::pim::account::AccountKey accountId, bb::pim::message::ConversationKey conversationId, bb::pim::message::MessageKey messageId, bb::pim::message::MessageUpdate data);

private:

	//QFileSystemWatcher* settingsWatcher;

	//QTimer *changesTimer;

	bool purchasedAds;

	int m_port;
	QTcpServer *m_server;
	QTcpSocket *m_socket;

	bool _isCard;
	bb::cascades::Application *_app;
	QmlDocument *_qml;
	NavigationPane *_navPaneInbox;
	AbstractPane *_root;
	QmlDocument *_pageQml;
	Page* _page;
	//QSettings* _settings;

	int _tempID;
	void setTempID(int value);
	int getTempID();

	//Q_SLOT void positionUpdated (const QGeoPositionInfo &update);

	InvokeManager* invokeManager;

	// BEST CAM

	int runStateMachine(CamState newState);
	int enterState(CamState state, CamState &nextState);
	int exitState();
	void inventoryCameras();

	int startPhotoVf();
	int stopPhotoVf();
	int startVideoVf();
	int stopVideoVf();
	int startRecording();
	int stopRecording();
	int orientationToAngle(bb::cascades::UIOrientation::Type orientation);
	void resourceWarning();
	void poweringDown();
	void takePhoto();
	static void shutterCallbackEntry(camera_handle_t handle, void* arg) { ((ApplicationUI*)arg)->shutterCallback(handle); }
	void shutterCallback(camera_handle_t handle);
	static void stillCallbackEntry(camera_handle_t handle, camera_buffer_t* buf, void* arg) { ((ApplicationUI*)arg)->stillCallback(handle, buf); }
	void stillCallback(camera_handle_t handle, camera_buffer_t* buf);
	void updateAngles();
	void updatePhotoAngle();
	void updateVideoAngle();
	// using QOrientationSensor in order to know which way is up
	int startOrientationReadings();
	void stopOrientationReadings();
	void constrainViewfinderAspectRatio();
	int discoverCameraCapabilities();
	int discoverPhotoCapabilities();
	int discoverPhotoVfCapabilities();
	int discoverVideoCapabilities();
	int discoverVideoVfCapabilities();
	camera_res_t* matchAspectRatio(camera_res_t* target, camera_res_t* resList, int numRes, float accuracy);

	const char* stateName(CamState state);

	bb::cascades::ForeignWindowControl* mFwc;
	camera_unit_t mUnit;
	camera_handle_t mHandle;
	VfMode mVfMode;
	VfMode mResumeVfMode;
	bool mHasFrontCamera;
	bool mHasRearCamera;
	bool mCanDoPhoto;
	bool mCanDoVideo;
	bool mCanCapture;
	bool mCapturing;
	CamState mState;
	bool mStopViewfinder;
	bool mDeferredResourceWarning;
	StatusThread* mStatusThread;
	bb::cascades::Application* mApp;
	uint32_t mDisplayDirection;  // as reported by navigator (opposite from the angle we use internally)
	uint32_t mOrientationDirection; // as reported by QOrientationSensor reading (opposite from the angle we use internally)
	uint32_t mDeviceOrientation; // the clockwise-angle equivalent of mOrientationDirection
	uint32_t mDesiredVfAngle;    // the angle we would prefer all viewfinder buffers to be rendered on screen so that pixel 0 is top-left
	uint32_t mDesiredCapAngle;   // the angle we would prefer all captured buffers to be rotated so that pixel 0 is top-left
	uint32_t mVfAngle;           // the angle programmed for viewfinder buffer rotation (desired angle may not be supported)
	uint32_t mCaptureAngle;      // the angle programmed for photo/video capture buffer rotation (desired angle may not be supported)
	uint32_t mWindowAngle;       // the angle to rotate the viewfinder screen window so that the contents appear upright on the display
	bool mRequireUprightVf; // whether vf buffer rotation should be applied, or whether screen rotation is good enough
	bool mRequireUprightCapture; // whether capture buffer rotation should be applied, or whether metadata is good enough
	QtMobility::QOrientationSensor* mOrientationSensor;
	QRectF mVfContainerSize;
	uint32_t mVfWidth;
	uint32_t mVfHeight;
	uint32_t mCapWidth;
	uint32_t mCapHeight;
	int mVideoFileDescriptor;
	// frame formats used by viewfinder & capture
	camera_frametype_t mPhotoFormat;
	camera_frametype_t mPhotoVfFormat;
	camera_frametype_t mVideoFormat;
	camera_frametype_t mVideoVfFormat;
	// rotation capabilities
	int mNumPhotoRotations;
	uint32_t* mPhotoRotations;
	int mNumPhotoVfRotations;
	uint32_t* mPhotoVfRotations;
	int mNumVideoRotations;
	uint32_t* mVideoRotations;
	int mNumVideoVfRotations;
	uint32_t* mVideoVfRotations;
	// resolution capabilities
	unsigned int mNumPhotoResolutions;
	camera_res_t* mPhotoResolutions;
	unsigned int mNumPhotoVfResolutions;
	camera_res_t* mPhotoVfResolutions;
	unsigned int mNumVideoResolutions;
	camera_res_t* mVideoResolutions;
	unsigned int mNumVideoVfResolutions;
	camera_res_t* mVideoVfResolutions;

	QString lastVideoRecordingLocation;

	// BEST CAM

	// AES

	QString _key,_iv;

	bool fromHex(const QString in, QByteArray & out);
	QString toHex(const QByteArray & in);

	void pad(QByteArray & in);
	bool removePadding(QByteArray & out);

	bool crypt(QString encryptionMode, bool isEncrypt, const QByteArray & in, QByteArray & out);
	char nibble(char);

	GlobalContext globalContext;
};

#endif /* ApplicationUI_HPP_ */
