#ifndef SNAP2CHATAPIDATA_H_
#define SNAP2CHATAPIDATA_H_

#include <QtCore/QObject>
#include <bb/cascades/ArrayDataModel>
#include <bb/cascades/GroupDataModel>
#include <QtCore/QFile>

#include <huctx.h>
#include <hugse56.h>
#include <huseed.h>
#include <husha2.h>
#include "huctx.h"
#include "sbdef.h"
#include "sbreturn.h"
#include "sbmem.h"

using bb::cascades::ArrayDataModel;

class Snap2ChatAPIData : public QObject
{
    Q_OBJECT

    // INT
    Q_PROPERTY (qint64 addedFriendsTimestamp READ getAddedFriendsTimestamp WRITE setAddedFriendsTimestamp NOTIFY addedFriendsTimestampChanged)

    Q_PROPERTY (int friendRequests READ getFriendRequests WRITE setFriendRequests NOTIFY friendRequestsChanged)
    Q_PROPERTY (int unopenedSnaps READ getUnopenedSnaps WRITE setUnopenedSnaps NOTIFY unopenedSnapsChanged)

    Q_PROPERTY (int tempID READ getTempID WRITE setTempID NOTIFY tempIDChanged)
    Q_PROPERTY (int uploadingSize READ getUploadingSize WRITE setUploadingSize NOTIFY uploadingSizeChanged)
    Q_PROPERTY (int score READ getScore WRITE setScore NOTIFY scoreChanged)
    Q_PROPERTY (int bestfriendsCount READ getBestFriendsCount WRITE setBestFriendsCount NOTIFY bestfriendsCountChanged)
    Q_PROPERTY (int snap_p READ getSnap_p WRITE setSnap_p NOTIFY snap_pChanged)
    Q_PROPERTY (int sentSnapsCount READ getSentSnapsCount WRITE setSentSnapsCount NOTIFY sentSnapsCountChanged)
	Q_PROPERTY (int receivedSnapsCount READ getReceivedSnapsCount WRITE setReceivedSnapsCount NOTIFY receivedSnapsCountChanged)
	Q_PROPERTY (int unopenedSnapsCount READ getUnopenedSnapsCount WRITE setUnopenedSnapsCount NOTIFY unopenedSnapsCountChanged)

    // BOOL
	Q_PROPERTY (bool isInFriendChooser READ getIsInFriendChooser WRITE setIsInFriendChooser NOTIFY isInFriendChooserChanged)
	Q_PROPERTY (bool isInCamera READ getIsInCamera WRITE setIsInCamera NOTIFY isInCameraChanged)
    Q_PROPERTY (bool logged READ getLogged WRITE setLogged NOTIFY loggedChanged)
    Q_PROPERTY (bool loading READ getLoading WRITE setLoading NOTIFY loadingChanged)
    Q_PROPERTY (bool loadingStories READ getLoadingStories WRITE setLoadingStories NOTIFY loadingStoriesChanged)
    Q_PROPERTY (bool loadingShoutbox READ getLoadingShoutbox WRITE setLoadingShoutbox NOTIFY loadingShoutboxChanged)
    Q_PROPERTY (bool searchableByPhoneNumber READ getSearchableByPhoneNumber WRITE setSearchableByPhoneNumber NOTIFY searchableByPhoneNumberChanged)
    Q_PROPERTY (bool imageCaption READ getImageCaption WRITE setImageCaption NOTIFY imageCaptionChanged)
    Q_PROPERTY (bool canViewMatureContent READ getCanViewMatureContent WRITE setCanViewMatureContent NOTIFY canViewMatureContentChanged)

    // STRING
    Q_PROPERTY (QString static_token READ getStaticToken WRITE setStaticToken NOTIFY static_tokenChanged)

    Q_PROPERTY (QString username READ getUsername WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY (QString auth_token READ getAuth_token WRITE setAuth_token NOTIFY auth_tokenChanged)
    Q_PROPERTY (QString mobileNumber READ getMobileNumber WRITE setMobileNumber NOTIFY mobileNumberChanged)
    Q_PROPERTY (QString snapchatNumber READ getSnapchatNumber WRITE setSnapchatNumber NOTIFY snapchatNumberChanged)
    Q_PROPERTY (QString email READ getEmail WRITE setEmail NOTIFY emailChanged)
    Q_PROPERTY (QString notificationSoundSetting READ getNotificationSoundSetting WRITE setNotificationSoundSetting NOTIFY notificationSoundSettingChanged)
    Q_PROPERTY (QString storyPrivacy READ getStoryPrivacy WRITE setStoryPrivacy NOTIFY storyPrivacyChanged)
    Q_PROPERTY (QString hostName READ getHostName WRITE setHostName NOTIFY hostNameChanged)
    Q_PROPERTY (QString titleBarColor READ getTitleBarColor WRITE setTitleBarColor NOTIFY titleBarColorChanged)
    Q_PROPERTY (QString birthday READ getBirthday WRITE setBirthday NOTIFY birthdayChanged)

    // ARRAY DATA MODEL
	Q_PROPERTY (bb::cascades::ArrayDataModel* feedsDataModel READ getFeedsDataModel NOTIFY feedsDataModelChanged)
	Q_PROPERTY (bb::cascades::ArrayDataModel* uploadingDataModel READ getUploadingDataModel NOTIFY uploadingDataModelChanged)
	Q_PROPERTY (bb::cascades::GroupDataModel* storiesDataModel READ getStoriesDataModel NOTIFY storiesDataModelChanged)
	Q_PROPERTY (bb::cascades::GroupDataModel* friendsDataModel READ getFriendsDataModel NOTIFY friendsDataModelChanged)
	Q_PROPERTY (bb::cascades::GroupDataModel* addedFriendsDataModel READ getAddedFriendsDataModel NOTIFY addedFriendsDataModelChanged)
	Q_PROPERTY (bb::cascades::GroupDataModel* friendRequestsDataModel READ getFriendRequestsDataModel NOTIFY friendRequestsDataModelChanged)
	Q_PROPERTY (bb::cascades::ArrayDataModel* shoutboxDataModel READ getShoutboxDataModel NOTIFY shoutboxDataModelChanged)
	Q_PROPERTY (bb::cascades::ArrayDataModel* currentStoriesOverViewModel READ getCurrentStoriesOverViewModel NOTIFY currentStoriesOverViewModelChanged)
	Q_PROPERTY (bb::cascades::ArrayDataModel* currentStoryNotesDataModel READ getCurrentStoryNotesDataModel NOTIFY currentStoryNotesDataModelChanged)

public:
    Snap2ChatAPIData(QObject* parent = 0);

    Q_INVOKABLE void replaceFeedItem(QString id, QVariant newItem);
    Q_INVOKABLE void filterFriends(QString keyword, QString json);

    Q_INVOKABLE QString getSetting(const QString &objectName, const QString &defaultValue);
	Q_INVOKABLE void setSetting(const QString &objectName, const QString &inputValue);
    Q_INVOKABLE void addToSendQueue(QVariant snapObject);
    Q_INVOKABLE void addToSendQueueFeeds(QVariant snapObject);
    Q_INVOKABLE void clearFeedsLocally();
    Q_INVOKABLE QString timeSince(qint64 time);
    Q_INVOKABLE bool contains(QString text, QString find);
    Q_INVOKABLE void resetAll();
    Q_INVOKABLE void parseUpdatesJSON(QString jsonString);
	Q_INVOKABLE void parseStoriesJSON(QString jsonString);
	Q_INVOKABLE void parseShoutboxJSON(QString jsonString);

	Q_INVOKABLE qint64 getCurrentTimestamp();
	Q_INVOKABLE QString generateRequestToken(quint64 timestamp, QString token);
	Q_INVOKABLE int init();
	Q_INVOKABLE void end();
	Q_INVOKABLE QString intToHex(int decimal);
	Q_INVOKABLE int hash(const QString input_data, unsigned char* messageDigest);
	Q_INVOKABLE QString generateUUID();

	Q_INVOKABLE void uploadingSizeChanged();
	Q_INVOKABLE void clearUploadingWhenZero();

Q_SIGNALS:

    // INT
    void addedFriendsTimestampChanged(qint64);

    void unopenedSnapsChanged(int);
	void friendRequestsChanged(int);

    void tempIDChanged(int);
    void uploadingSizeChanged(int);
	void scoreChanged(int);
	void bestfriendsCountChanged(int);
	void snap_pChanged(int);
	void sentSnapsCountChanged(int);
	void receivedSnapsCountChanged(int);
	void unopenedSnapsCountChanged(int);

	// BOOL
	void isInFriendChooserChanged(bool);
	void isInCameraChanged(bool);
	void loggedChanged(bool);
	void loadingChanged(bool);
	void loadingStoriesChanged(bool);
	void loadingShoutboxChanged(bool);
	void searchableByPhoneNumberChanged(bool);
	void imageCaptionChanged(bool);
	void canViewMatureContentChanged(bool);

	// STRING
	void static_tokenChanged(QString);

	void usernameChanged(QString);
	void auth_tokenChanged(QString);
	void mobileNumberChanged(QString);
	void snapchatNumberChanged(QString);
	void emailChanged(QString);
	void notificationSoundSettingChanged(QString);
	void storyPrivacyChanged(QString);
	void hostNameChanged(QString);
	void titleBarColorChanged(QString);
	void birthdayChanged(QString);

	// ARRAY DATA MODEL
	void feedsDataModelChanged(bb::cascades::ArrayDataModel*);
	void uploadingDataModelChanged(bb::cascades::ArrayDataModel*);
	void storiesDataModelChanged(bb::cascades::GroupDataModel*);
	void friendsDataModelChanged(bb::cascades::GroupDataModel*);
	void addedFriendsDataModelChanged(bb::cascades::GroupDataModel*);
	void friendRequestsDataModelChanged(bb::cascades::GroupDataModel*);
	void shoutboxDataModelChanged(bb::cascades::ArrayDataModel*);
	void currentStoriesOverViewModelChanged(bb::cascades::ArrayDataModel*);
	void currentStoryNotesDataModelChanged(bb::cascades::ArrayDataModel*);

private Q_SLOTS:



private :

    // INT
    void setAddedFriendsTimestamp(qint64 value);

    void setFriendRequests(int value);
	void setUnopenedSnaps(int value);

    void setTempID(int value);
    void setUploadingSize(int value);
	void setScore(int value);
	void setBestFriendsCount(int value);
	void setSnap_p(int value);
	void setSentSnapsCount(int value);
	void setReceivedSnapsCount(int value);
	void setUnopenedSnapsCount(int value);

	// BOOL
	void setIsInFriendChooser(bool value);
	void setIsInCamera(bool value);
	void setLogged(bool value);
	void setLoading(bool value);
	void setLoadingStories(bool value);
	void setLoadingShoutbox(bool value);
	void setSearchableByPhoneNumber(bool value);
	void setImageCaption(bool value);
	void setCanViewMatureContent(bool value);

	// STRING
	void setStaticToken(QString value);

	void setUsername(QString value);
	void setAuth_token(QString value);
	void setMobileNumber(QString value);
	void setSnapchatNumber(QString value);
	void setEmail(QString value);
	void setNotificationSoundSetting(QString value);
	void setStoryPrivacy(QString value);
	void setHostName(QString value);
	void setTitleBarColor(QString value);
	void setBirthday(QString value);

	// GET

	// INT
	qint64 getAddedFriendsTimestamp();

	int getUnopenedSnaps();
	int getFriendRequests();

	int getTempID();
	int getUploadingSize();
	int getScore();
	int getBestFriendsCount();
	int getSnap_p();
	int getSentSnapsCount();
	int getReceivedSnapsCount();
	int getUnopenedSnapsCount();

	// BOOL
	bool getIsInFriendChooser();
	bool getIsInCamera();
	bool getLogged();
	bool getLoading();
	bool getLoadingStories();
	bool getLoadingShoutbox();
	bool getSearchableByPhoneNumber();
	bool getImageCaption();
	bool getCanViewMatureContent();

	// STRING
	QString getStaticToken();

	QString getUsername();
	QString getAuth_token();
	QString getMobileNumber();
	QString getSnapchatNumber();
	QString getEmail();
	QString getNotificationSoundSetting();
	QString getStoryPrivacy();
	QString getHostName();
	QString getTitleBarColor();
	QString getBirthday();

	// ARRAY DATA MODEL
	bb::cascades::ArrayDataModel* getFeedsDataModel();
	bb::cascades::ArrayDataModel* getUploadingDataModel();
	bb::cascades::GroupDataModel* getStoriesDataModel();
	bb::cascades::GroupDataModel* getAddedFriendsDataModel();
	bb::cascades::GroupDataModel* getFriendRequestsDataModel();
	bb::cascades::GroupDataModel* getFriendsDataModel();
	bb::cascades::ArrayDataModel* getShoutboxDataModel();
	bb::cascades::ArrayDataModel* getCurrentStoriesOverViewModel();
	bb::cascades::ArrayDataModel* getCurrentStoryNotesDataModel();

	qint64 _added_friends_timestamp;

	int _friendRequests;
	int _unopenedSnaps;

	int _uploadingSize;
	int _tempID;
    int _score;
    int _bestfriendsCount;
    int _snap_p;
    int _sentSnapsCount;
	int _receivedSnapsCount;
	int _unopenedSnapsCount;

	bool _isInFriendChooser;
	bool _isInCamera;
    bool _logged;
    bool _loading;
    bool _loadingStories;
    bool _loadingShoutbox;
    bool _searchableByPhoneNumber;
    bool _imageCaption;
    bool _canViewMatureContent;

    QString _static_token;

    QString _username;
	QString _auth_token;
    QString _mobileNumber;
    QString _snapchatNumber;
    QString _email;
    QString _notificationSoundSetting;
    QString _storyPrivacy;
    QString _hostName;
    QString _titleBarColor;
    QString _birthday;

    // MINE
    QVariantList _boxsnaps;

    bb::cascades::ArrayDataModel* _feedsDataModel;
    bb::cascades::ArrayDataModel* _uploadingDataModel;
    bb::cascades::GroupDataModel* _storiesDataModel;
    bb::cascades::GroupDataModel* _addedFriendsDataModel;
    bb::cascades::GroupDataModel* _friendRequestsDataModel;
    bb::cascades::GroupDataModel* _friendsDataModel;
    bb::cascades::ArrayDataModel* _shoutboxDataModel;

    bb::cascades::ArrayDataModel* _currentStoriesOverViewModel;
    bb::cascades::ArrayDataModel* _currentStoryNotesDataModel;

    QStringList _vipHardcores;

    sb_GlobalCtx sbCtx;
	sb_Context sha256Context;
};

#endif /* Snap2ChatAPIData_H_ */
