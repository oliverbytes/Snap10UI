#include "Snap2ChatAPIData.hpp"

#include <bb/data/JsonDataAccess>
#include <QtCore/QtCore>

#include <huctx.h>
#include <hugse56.h>
#include <huseed.h>
#include <husha2.h>
#include "huctx.h"
#include "sbdef.h"
#include "sbreturn.h"
#include "sbmem.h"
#include <bb/cascades/GroupDataModel>
#include <bb/platform/Notification>
#include <bb/system/InvokeRequest>

using bb::data::JsonDataAccess;
using bb::cascades::GroupDataModel;
using bb::platform::Notification;
using bb::system::InvokeRequest;

const int MEDIA_IMAGE 							= 0;
const int MEDIA_VIDEO 							= 1;
const int MEDIA_VIDEO_NOAUDIO 					= 2;
const int MEDIA_VIDEO_ZIPPED 					= 500;
const int MEDIA_FRIEND_REQUEST 					= 3;
const int MEDIA_FRIEND_REQUEST_IMAGE 			= 4;
const int MEDIA_FRIEND_REQUEST_VIDEO 			= 5;
const int MEDIA_FRIEND_REQUEST_VIDEO_NOAUDIO 	= 6;

const int STATUS_NONE 		= -1;
const int STATUS_SENT 		= 0;
const int STATUS_DELIVERED 	= 1;
const int STATUS_UNOPENED 	= 1;
const int STATUS_OPENED 	= 2;
const int STATUS_SCREENSHOT = 3;

const int FRIEND_CONFIRMED 		= 0;
const int FRIEND_UNCONFIRMED 	= 1;
const int FRIEND_BLOCKED 		= 2;
const int FRIEND_DELETED 		= 3;

const int PRIVACY_EVERYONE 	= 0;
const int PRIVACY_FRIENDS 	= 1;

const QString SECRET 				= "iEk21fuwZApXlz93750dmW22pw389dPwOk";
const QString STATIC_TOKEN 			= "m198sOkJEn37DjqZ32lpRu76xmw288xSQ9";
const QString BLOB_ENCRYPTION_KEY 	= "M02cnQ51Ji97vwT4";
const QString HASH_PATTERN 			= "0001110111101110001111010101111011010001001110011000110001000110";

QStringList receivedUnopenedSnaps;
QStringList friendRequestsList;

#define ARRAY_SIZE(arr) ((sizeof(arr))/(sizeof(arr[0])))

Snap2ChatAPIData::Snap2ChatAPIData(QObject* parent)
    : QObject(parent)
{
	_feedsDataModel 				= new ArrayDataModel();
	_shoutboxDataModel 				= new ArrayDataModel();
	_currentStoriesOverViewModel 	= new ArrayDataModel();
	_currentStoryNotesDataModel 	= new ArrayDataModel();

	_storiesDataModel 				= new GroupDataModel();
	_storiesDataModel->setSortingKeys(QStringList() << "username");

	_friendsDataModel 				= new GroupDataModel();
	_friendsDataModel->setSortingKeys(QStringList() << "friendType" << "name");

	_addedFriendsDataModel 			= new GroupDataModel();
	_addedFriendsDataModel->setSortingKeys(QStringList() << "name");

	_friendRequestsDataModel 		= new GroupDataModel();
	_friendRequestsDataModel->setSortingKeys(QStringList() << "sender");

	_uploadingDataModel 			= new ArrayDataModel();

	_vipHardcores << "nemoryoliver" << "teamsnap2chat" << "teamsnapchat" << "tony686" << "toby_clench" << "miguel.montiel" << "tonytraj17";

	setTempID(0);
	setUploadingSize(0);
	setStaticToken(STATIC_TOKEN);

	resetAll();
}

void Snap2ChatAPIData::filterFriends(QString keyword, QString json)
{
//	_friendsDataModel->clear();
//
//	QVariantList filteredList;
//
//	bb::data::JsonDataAccess jda;
//	QVariant jsonVariant 			= jda.loadFromBuffer(json);
//	QVariantList jsonList			= jsonVariant.toMap().value("data").toList();
//
//	foreach(QVariant messageObject, jsonList)
//	{
//		QVariantMap dataMap 		= messageObject.toMap();
//		QVariantList toData 		= dataMap["to"].toMap()["data"].toList();
//
//		bool found = false;
//
//		foreach(QVariant toObject, toData)
//		{
//			QString name = toObject.toMap()["name"].toString();
//
//			if(name.contains(keyword, Qt::CaseInsensitive))
//			{
//				found = true;
//			}
//		}
//
//		if(found)
//		{
//			filteredList.append(messageObject);
//		}
//	}
//
//	_friendsDataModel->insert(0, filteredList);
}

void Snap2ChatAPIData::replaceFeedItem(QString id, QVariant newItem)
{
	if(_feedsDataModel->size() > 0)
	{
		for(int i = 0; i < _feedsDataModel->size(); i++)
		{
			QVariantList parentIndexPath;

			const QVariantList indexPath = (QVariantList(parentIndexPath) << i);

			QVariantMap snapMap = _feedsDataModel->data(indexPath).toMap();

			if(snapMap["id"].toString() == id)
			{
				_feedsDataModel->replace(i, newItem);
				break;
			}
		}
	}
}

void Snap2ChatAPIData::resetAll()
{
	// INT
	_added_friends_timestamp 	= 0;

	_tempID 					= 0;
	_uploadingSize 				= 0;
	_score 						= 0;
	_bestfriendsCount 			= 0;
	_snap_p 					= 0;
	_sentSnapsCount 			= 0;
	_receivedSnapsCount 		= 0;
	_unopenedSnapsCount 		= 0;

	// BOOL
	_isInFriendChooser 			= false;
	_isInCamera 				= false;
	_loading 					= false;
	_loadingStories 			= false;
	_loadingShoutbox			= false;
	_logged 					= false;
	_searchableByPhoneNumber 	= false;
	_imageCaption 				= false;
	_canViewMatureContent 		= false;

	// STRING
	_username 					= "";
	_auth_token 				= "";
	_mobileNumber 				= "";
	_snapchatNumber 			= "";
	_email 						= "";
	_notificationSoundSetting 	= "";
	_storyPrivacy 				= "";

	// ARRAY DATA MODEL
	_feedsDataModel->clear();
	_uploadingDataModel->clear();
	_friendsDataModel->clear();
	_storiesDataModel->clear();
	_addedFriendsDataModel->clear();
	_friendRequestsDataModel->clear();
}

QString Snap2ChatAPIData::timeSince(qint64 time)
{
   QString periods[] = {"second", "minute", "hour", "day", "week", "month", "year", "decade"};

   int lengths[] = {60, 60, 24, 7, 4.35, 12, 10};

   qint64 now = QDateTime::currentMSecsSinceEpoch() / 1000;

   qint64 difference     = now - (time / 1000);
   QString tense         = "ago";

   int j = 0;

   for(j = 0; difference >= lengths[j] && j < ARRAY_SIZE(lengths) - 1; j++)
   {
	   difference /= lengths[j];
   }

   difference = qRound(difference);

   if(difference != 1)
   {
	   periods[j] += "s";
   }

   return QString::number(difference) + " " + periods[j] + " " + tense;
}

void Snap2ChatAPIData::parseUpdatesJSON(QString jsonString)
{
	_unopenedSnaps 	= 0;
	_friendRequests = 0;

	bool hideBlockedDeletedFriends 		= (getSetting("hideBlockedDeletedFriends", "show") == "hide");
	bool notificationsEnabled 			= (getSetting("notificationsEnabled", "true") == "true");
	QString showOnlyMediaType 			= getSetting("showOnlyMediaType", "all");
	QString showOnlyStatus 				= getSetting("showOnlyStatus", "all");
//	QString allLastUnopenedFromSetting 	= getSetting("allLastUnopenedID", "");
//	QString friendRequestsFromSetting 	= getSetting("friendRequestsFromSetting", "");
	bool vipCustomFeedIcons				= (getSetting("vipCustomFeedIcons", "true") == "true");
	bool replayFeature					= (getSetting("replayFeature", "true") == "true");

	JsonDataAccess jda;
	QVariant jsonDATA 			= jda.loadFromBuffer(jsonString);
	jda.deleteLater();

	QVariantMap parentJSONMap 	= jsonDATA.toMap();

	_logged						= parentJSONMap.value("logged").toBool();
	emit loggedChanged(_logged);

	_birthday					= parentJSONMap.value("birthday").toString();
	emit birthdayChanged(_birthday);

	// INT
	_added_friends_timestamp 	= parentJSONMap.value("added_friends_timestamp").toLongLong();
	emit addedFriendsTimestampChanged(_added_friends_timestamp);

	_sentSnapsCount 			= parentJSONMap.value("sent").toInt();
	emit sentSnapsCountChanged(_sentSnapsCount);

	_receivedSnapsCount			= parentJSONMap.value("received").toInt();
	emit receivedSnapsCountChanged(_receivedSnapsCount);

	_score						= parentJSONMap.value("score").toInt();
	emit scoreChanged(_score);

	_snap_p						= parentJSONMap.value("snap_p").toInt(); // privacy
	emit snap_pChanged(_snap_p);

	_bestfriendsCount			= parentJSONMap.value("number_of_best_friends").toInt(); // privacy
	emit bestfriendsCountChanged(_bestfriendsCount);

	// BOOL
	_searchableByPhoneNumber	= parentJSONMap.value("searchable_by_phone_number").toBool();
	emit searchableByPhoneNumberChanged(_searchableByPhoneNumber);

	_imageCaption				= parentJSONMap.value("image_caption").toBool();
	emit imageCaptionChanged(_imageCaption);

	_canViewMatureContent		= parentJSONMap.value("can_view_mature_content").toBool();
	emit canViewMatureContentChanged(_canViewMatureContent);

	// STRING
	_username	 				= parentJSONMap.value("username").toString();
	emit usernameChanged(_username);

	_auth_token 				= parentJSONMap.value("auth_token").toString();
	emit auth_tokenChanged(_auth_token);

	_mobileNumber				= parentJSONMap.value("mobile").toString();
	emit mobileNumberChanged(_mobileNumber);

	_snapchatNumber				= parentJSONMap.value("snapchat_phone_number").toString();
	emit snapchatNumberChanged(_snapchatNumber);

	_email						= parentJSONMap.value("email").toString();
	emit emailChanged(_email);

	_notificationSoundSetting	= parentJSONMap.value("notification_sound_setting").toString();
	emit notificationSoundSettingChanged(_notificationSoundSetting);

	_storyPrivacy				= parentJSONMap.value("story_privacy").toString();
	emit storyPrivacyChanged(_storyPrivacy);

	// LISTS

	// ----------------------------- ADDED FRIENDS -------------------------------- //

	QVariantList _addedFriends 	= parentJSONMap.value("added_friends").toList();
	_addedFriendsDataModel->clear();
	_addedFriendsDataModel->insertList(_addedFriends);
	emit addedFriendsDataModelChanged(_addedFriendsDataModel);

	// ----------------------------- MY STORY -------------------------------- //

	QVariantList _stories;

	QVariantMap storyMap;
	storyMap.insert("type", "mystory");
	storyMap.insert("name", "My Story");
	storyMap.insert("display", "My Story");
	storyMap.insert("friendType", "0");

	_stories.insert(0, storyMap);

	// ----------------------------- FORMAT BEST FRIENDS -------------------------------- //

	QVariantList tempBestFriends = parentJSONMap.value("bests").toList();
	QVariantList _bestFriends;

	if(tempBestFriends.size() > 0)
	{
		foreach(QVariant theFriend, tempBestFriends) // format best friends
		{
			if(theFriend.toString().length() > 0)
			{
				QVariantMap friendMap;
				friendMap.insert("confirmed", false);
				friendMap.insert("type", "bestfriend");
				friendMap.insert("name", theFriend.toString());
				friendMap.insert("display", theFriend.toString());
				friendMap.insert("friendType", "1");

				_bestFriends.insert(0, friendMap);
			}
		}
	}

	// ----------------------------- FORMAT RECENT FRIENDS -------------------------------- //

	QVariantList tempRecentFriends = parentJSONMap.value("recents").toList();
	QVariantList _recentFriends;

	if(tempRecentFriends.size() > 0)
	{
		foreach(QVariant theFriend, tempRecentFriends) // format best friends
		{
			if(theFriend.toString().length() > 0)
			{
				QVariantMap friendMap;
				friendMap.insert("confirmed", false);
				friendMap.insert("type", "recentfriend");
				friendMap.insert("name", theFriend.toString());
				friendMap.insert("display", theFriend.toString());
				friendMap.insert("friendType", "2");

				_recentFriends.insert(0, friendMap);
			}
		}
	}

	// ----------------------------- FORMAT FRIENDS -------------------------------- //

	QVariantList _friends = parentJSONMap.value("friends").toList();

	if(_friends.size() > 0)
	{
		if(hideBlockedDeletedFriends)
		{
			foreach(QVariant theFriend, _friends) // format friends and remove duplicates
			{
				QVariantMap friendMap = theFriend.toMap();
				friendMap.insert("friendType", "3");

				if(friendMap["type"].toString() == "2" || friendMap["type"].toString() == "3")
				{
					_friends.removeOne(theFriend);
				}
			}
		}
	}

	_friendsDataModel->clear();
	_friendsDataModel->insertList(_friends);
	_friendsDataModel->insertList(_recentFriends);
	_friendsDataModel->insertList(_bestFriends);
	_friendsDataModel->insertList(_stories);
	emit friendsDataModelChanged(_friendsDataModel);

	// ----------------------------- FORMAT SNAPS -------------------------------- //

	QVariantList newSnaps 		= parentJSONMap.value("snaps").toList();

	for(int k = 0; k < (newSnaps.size() / 2); k++ ) newSnaps.swap(k, newSnaps.size() - (1 + k));

	_friendRequestsDataModel->clear();
	_feedsDataModel->clear();

	QVariantList formattedSnaps;

	if(newSnaps.size() > 0)
	{
		int indexPath = newSnaps.size() - 1;

		foreach(QVariant thesnap, newSnaps)
		{
			QVariantMap snapMap					= thesnap.toMap();

			const QString id 					= snapMap["id"].toString();

			snapMap.insert("indexPath"			, indexPath);
			indexPath--;

			snapMap.insert("timerrunning"		, false);
			snapMap.insert("sentSnap"			, false);
			snapMap.insert("postedStory"		, false);

			const QString media_id 				= (snapMap.contains("c_id") ? snapMap["c_id"].toString() : "false");
			snapMap.insert("media_id"			, media_id);

			snapMap.insert("upload_media_id"	, "");

			const QString sender 				= (snapMap.contains("sn") ? snapMap["sn"].toString() : _username);
			snapMap.insert("sender"				, sender);

			const QString recipient 			= (snapMap.contains("rp") ? snapMap["rp"].toString() : _username);
			snapMap.insert("recipient"			, recipient);

			QString theUsername 				= "";

			if(sender == _username && recipient == _username)
			{
				theUsername = _username;
			}
			else if(sender == _username)
			{
				theUsername = recipient;
			}
			else if(recipient == _username)
			{
				theUsername = sender;
			}
			else
			{
				theUsername = recipient;
			}

			snapMap.insert("username", theUsername);
			snapMap.insert("displayname", theUsername);

			foreach(QVariant theFriend, _friends)
			{
				QVariantMap friendMap = theFriend.toMap();

				if(friendMap["name"].toString() == theUsername)
				{
					if(friendMap["display"].toString().length() > 0)
					{
						snapMap.insert("displayname", friendMap["display"]);
					}

					break;
				}
			}

			const bool zippedVideo 				= (snapMap.contains("zipped") ? snapMap["zipped"].toBool() : false);
			snapMap.insert("zippedVideo"		, zippedVideo);

			int media_type = (zippedVideo ? 500 : snapMap["m"].toInt());
			snapMap.insert("media_type"			, media_type);

			if(media_type == MEDIA_FRIEND_REQUEST)
			{
				bool friendRequestInFriends = false;

				foreach(QVariant theFriend, _friends)
				{
					QVariantMap friendMap = theFriend.toMap();

					if(friendMap["name"] == sender)
					{
						friendRequestInFriends = true;
						break;
					}
				}

				if(!friendRequestInFriends)
				{
					_friendRequests++;
					_friendRequestsDataModel->insert(snapMap);
				}

				continue;
			}

			const int status 					= snapMap["st"].toInt();
			snapMap.insert("status"				, status);

			// -------------------------------------------- FILTER OPTIONS -------------------------------------------------- //

			if(showOnlyMediaType != "all")
			{
				if(showOnlyMediaType == "photo" && (media_type == MEDIA_VIDEO || media_type == MEDIA_VIDEO_NOAUDIO || media_type == MEDIA_VIDEO_ZIPPED))
				{
					continue;
				}

				if(showOnlyMediaType == "video" && media_type == MEDIA_IMAGE)
				{
					continue;
				}
			}

			if(showOnlyStatus != "all")
			{
				if(showOnlyStatus == "unopened" && status == STATUS_OPENED)
				{
					continue;
				}

				if(showOnlyStatus == "opened" && media_type == STATUS_UNOPENED)
				{
					continue;
				}

				if(showOnlyStatus == "screenshots" && media_type != STATUS_SCREENSHOT)
				{
					continue;
				}
			}

			// ------------------------------- STATUS IMAGE ----------------------------------- //

			bool loaded = true;
			bool candidateForReplay = false;

			QString statusImage = "asset:///images/snapchat/";
			QString hardcores 	= "asset:///images/hardcores/";
			QString statusText 	= "";
			QString actionStatusText = "";

			QString sentReceived = (contains(id, "r") ? "received" : "sent");

			if(status == STATUS_OPENED)
			{
				statusText 	= " - Opened";

				if(sentReceived == "received")
				{
					if(replayFeature)
					{
						QString extension = "";

						if(media_type == 0)
						{
							extension = ".jpg";
						}
						else if(media_type == 1 || media_type == 2)
						{
							extension = ".mp4";
						}
						else if(media_type == 500)
						{
							extension = ".zip";
						}

						QString fileLocation = "data/files/blobs/" + id + extension;

						if(QFile::exists(fileLocation))
						{
							actionStatusText = " - Press and hold to replay";

							candidateForReplay = true;
						}
					}

					if(media_type == MEDIA_IMAGE)
					{
						statusImage += (candidateForReplay ? "aa_feed_icon_opened_photo_replay.png" : "aa_feed_icon_opened_photo.png");
					}
					else if(media_type == MEDIA_VIDEO || media_type == MEDIA_VIDEO_NOAUDIO || media_type == MEDIA_VIDEO_ZIPPED)
					{
						statusImage += (candidateForReplay ? "aa_feed_icon_opened_video_replay.png" : "aa_feed_icon_opened_video.png");
					}
				}
				else if(sentReceived == "sent")
				{
					if(media_type == MEDIA_IMAGE)
					{
						statusImage += "aa_feed_icon_sent_photo_opened.png";
					}
					else if(media_type == MEDIA_VIDEO || media_type == MEDIA_VIDEO_NOAUDIO || media_type == MEDIA_VIDEO_ZIPPED)
					{
						statusImage += "aa_feed_icon_sent_video_opened.png";
					}
				}
			}
			else if(status == STATUS_UNOPENED || status == STATUS_DELIVERED)
			{
				if(sentReceived == "received")
				{
					loaded = false;

					if(media_type == MEDIA_IMAGE)
					{
						statusImage += "aa_feed_icon_unopened_photo.png";

						if(vipCustomFeedIcons)
						{
							foreach(QString vip, _vipHardcores)
							{
								if(sender == vip)
								{
									statusImage = hardcores + sender + "0.png";
								}
							}
						}
					}
					else if(media_type == MEDIA_VIDEO || media_type == MEDIA_VIDEO_NOAUDIO || media_type == MEDIA_VIDEO_ZIPPED)
					{
						statusImage += "aa_feed_icon_unopened_video.png";

						if(vipCustomFeedIcons)
						{
							foreach(QString vip, _vipHardcores)
							{
								if(sender == vip)
								{
									statusImage = hardcores + sender + "1.png";
								}
							}
						}
					}

					_unopenedSnaps++;

//					if(notificationsEnabled && !contains(allLastUnopenedFromSetting, id))
//					{
//						Notification* notification = new Notification();
//						notification->setTitle("snap2chat: " + sender);
//						notification->setBody("New Snap from " + sender + ". Check it out :)");
//						notification->setIconUrl(QUrl("app/native/assets/images/icon.png")) ;
//
//						InvokeRequest invokeRequest;
//						invokeRequest.setTarget("com.nemory.snap2chat.invoke.open");
//						invokeRequest.setAction("bb.action.OPEN");
//						invokeRequest.setMimeType("text/plain");
//						notification->setInvokeRequest(invokeRequest);
//
//						notification->notify();
//					}

					if(!receivedUnopenedSnaps.contains(id, Qt::CaseSensitive))
					{
						receivedUnopenedSnaps << id;
					}
				}
				else if(sentReceived == "sent")
				{
					if(media_type == MEDIA_IMAGE)
					{
						statusImage += "aa_feed_icon_sent_photo_unopened.png";
					}
					else if(media_type == MEDIA_VIDEO || media_type == MEDIA_VIDEO_NOAUDIO || media_type == MEDIA_VIDEO_ZIPPED)
					{
						statusImage += "aa_feed_icon_sent_video_unopened.png";
					}

					statusText 	= " - Sent";
				}
			}
			else if(status == STATUS_SCREENSHOT)
			{
				if(media_type == MEDIA_IMAGE)
				{
					statusImage += "aa_feed_icon_screenshotted_photo.png";
				}
				else if(media_type == MEDIA_VIDEO || media_type == MEDIA_VIDEO_NOAUDIO || media_type == MEDIA_VIDEO_ZIPPED)
				{
					statusImage += "aa_feed_icon_screenshotted_video.png";
				}

				statusText 	= " - Screenshotted";
			}

			if(statusImage == "asset:///images/snapchat/")
			{
				statusImage = "asset:///images/snapchat/aa_feed_icon_opened_photo.png";
			}

			snapMap.insert("statusImage"		, statusImage);

			// ------------------------------- OTHERS ----------------------------------- //

			loaded = (candidateForReplay ? true : loaded);

			snapMap.insert("loaded"				, loaded);
			snapMap.insert("candidateForReplay"	, candidateForReplay);

			const qint64 sent 					= snapMap["sts"].toLongLong();
			snapMap.insert("sent"				, sent);

			const qint64 opened 				= snapMap["ts"].toLongLong();
			snapMap.insert("opened"				, opened);

			const int screenshot_count 			= (snapMap.contains("c") ? snapMap["c"].toInt() : 0);
			snapMap.insert("screenshot_count"	, screenshot_count);

			const bool loading 					= false;
			snapMap.insert("loading"			, loading);

			const bool send 					= false;
			snapMap.insert("send"				, send);

			const bool beingviewed 				= false;
			snapMap.insert("beingviewed"		, beingviewed);

			const bool load 					= false;
			snapMap.insert("load"				, load);

			const QString timeago 				= (status == STATUS_OPENED ? timeSince(opened) : timeSince(sent));
			snapMap.insert("timeago"			, timeago);

			// -------------------------------------------- lOADABLE -------------------------------------------------- //

			bool loadable = false;

			int time 						= 0;
			int timeleft 					= time;

			if(sentReceived == "received" && status == STATUS_UNOPENED && recipient == _username)
			{
				loadable = true;

				if(sender == "teamsnapchat" && time == 0)
				{
					time = 10;
				}
				else
				{
					time = (snapMap.contains("t") ? (snapMap["t"].toInt() == 0 ? 10 : snapMap["t"].toInt()) : 0);
				}

				timeleft = time;
			}

			snapMap.insert("time"				, (candidateForReplay ? 10 : time));
			snapMap.insert("timeleft"			, (candidateForReplay ? 10 : timeleft));
			snapMap.insert("loadable"			, loadable);

			// -------------------------------------------- STATUS TEXT -------------------------------------------------- //

			if(actionStatusText == "")
			{
				actionStatusText = (loadable ? " - Tap to load" : "");
			}

			snapMap.insert("statusText"			, statusText);
			snapMap.insert("actionStatusText"	, actionStatusText);

			formattedSnaps.insert(0, snapMap);
		}
	}

//	QString allLastUnopenedID = receivedUnopenedSnaps.join(",");
//	setSetting("allLastUnopenedID", allLastUnopenedID);
//
//	QString allFriendRequestsID = friendRequestsList.join(",");
//	setSetting("allFriendRequestsID", allFriendRequestsID);

	_feedsDataModel->insert(0, formattedSnaps);

	emit feedsDataModelChanged(_feedsDataModel);
	emit friendRequestsDataModelChanged(_friendRequestsDataModel);

	setUnopenedSnaps(_unopenedSnaps);
	setFriendRequests(_friendRequests);
}

void Snap2ChatAPIData::parseShoutboxJSON(QString jsonString)
{
	_shoutboxDataModel->clear();

	JsonDataAccess jda;
	QVariant jsonDATA 			= jda.loadFromBuffer(jsonString);
	_shoutboxDataModel->insert(0, jsonDATA.toList());
}

void Snap2ChatAPIData::parseStoriesJSON(QString jsonString)
{
	_storiesDataModel->clear();

	JsonDataAccess jda;
	QVariant jsonDATA 			= jda.loadFromBuffer(jsonString);

	QVariantMap parentJSONMap 	= jsonDATA.toMap();

	// ----------------------------- STORIES -------------------------------- //

	QVariantList _stories 		= parentJSONMap.value("friend_stories").toList();
	QVariantList _mystories 	= parentJSONMap.value("my_stories").toList();

	if(_mystories.size() > 0)
	{
		QVariantMap myStoriesMap;
		myStoriesMap.insert("username", _username);
		myStoriesMap.insert("stories", _mystories);
		myStoriesMap.insert("mature_content", false);
		myStoriesMap.insert("storyType", "0");

		_stories.insert(0, myStoriesMap);
	}

	for(int k = 0; k < (_stories.size()/2); k++) _stories.swap(k, _stories.size()-(1+k)); // REVERSE LIST

	QVariantList userStories;

	if(_stories.size() > 0)
	{
		foreach(QVariant userStory, _stories)
		{
			QVariantMap userStoryMap				= userStory.toMap();

			const QString username 					= userStoryMap["username"].toString();
			QVariantList stories 					= userStoryMap["stories"].toList();
			for(int k = 0; k < (stories.size()/2); k++) stories.swap(k, stories.size()-(1+k)); // REVERSE LIST

			QVariantList formattedStories;

			QString lastTimeAgo = "";
			int totalTimeLeft	= 0;

			foreach(QVariant story, stories)
			{
				QVariantMap storyParentMap			= story.toMap();
				QVariantMap storyMap				= storyParentMap["story"].toMap();

				const bool zippedVideo 				= (storyMap.contains("zipped") ? storyMap["zipped"].toBool() : false);
				storyMap.insert("zippedVideo"		, zippedVideo);

				int media_type = (zippedVideo ? 500 : storyMap["media_type"].toInt());
				storyMap.remove("media_type");
				storyMap.insert("media_type"		, media_type);

				const int timeleft 					= storyMap["time"].toInt();
				totalTimeLeft += timeleft;
				storyMap.insert("timeleft"			, timeleft);
				storyMap.insert("backuptimeleft"	, timeleft);

				storyMap.insert("statusText"		, "");
				storyMap.insert("actionStatusText"	, " - Press and hold to view");

				if(media_type == 0)
				{
					storyMap.insert("statusImage"		, "asset:///images/snapchat/aa_feed_icon_unopened_photo.png");
				}
				else
				{
					storyMap.insert("statusImage"		, "asset:///images/snapchat/aa_feed_icon_unopened_video.png");
				}

				const qint64 timestamp 				= storyMap["timestamp"].toLongLong();
				const QString timeago 				= timeSince(timestamp);
				lastTimeAgo 						= timeago;
				storyMap.insert("timeago"			, timeago);

				storyParentMap.remove("story");
				storyParentMap.insert("story", storyMap);

				formattedStories.insert(0, storyParentMap);
			}

			userStoryMap.remove("stories");
			userStoryMap.insert("stories", formattedStories);

			userStoryMap.insert("timeleft"	, totalTimeLeft);
			userStoryMap.insert("timeago"	, lastTimeAgo);

			userStoryMap.insert("statusImage"		, "asset:///images/snapchat/aa_feed_icon_unopened_broadcast.png");
			userStoryMap.insert("statusText"		, "");
			userStoryMap.insert("actionStatusText"	, " - Tap to load");
			userStoryMap.insert("loaded"			, false);
			userStoryMap.insert("loading"			, false);
			userStoryMap.insert("storyType"			, "1");

			userStories.insert(0, userStoryMap);
		}
	}

	_storiesDataModel->insertList(userStories);

	emit storiesDataModelChanged(_storiesDataModel);
}

qint64 Snap2ChatAPIData::getCurrentTimestamp()
{
	return QDateTime::currentMSecsSinceEpoch();
}

void Snap2ChatAPIData::clearFeedsLocally()
{
	_feedsDataModel->clear();
	emit feedsDataModelChanged(_feedsDataModel);
}

QString Snap2ChatAPIData::getSetting(const QString &objectName, const QString &defaultValue)
{
	QSettings settings("NEMORY", "SNAP2CHAT");

	if (settings.value(objectName).isNull() || settings.value(objectName) == "")
	{
		return defaultValue;
	}

	return settings.value(objectName).toString();
}

void Snap2ChatAPIData::setSetting(const QString &objectName, const QString &inputValue)
{
	QSettings settings("NEMORY", "SNAP2CHAT");
	settings.setValue(objectName, QVariant(inputValue));
}

void Snap2ChatAPIData::addToSendQueue(QVariant snapObject)
{
	_uploadingDataModel->insert(0, snapObject);
	emit uploadingDataModelChanged(_uploadingDataModel);

	setUploadingSize(_uploadingSize + 1);
}

void Snap2ChatAPIData::addToSendQueueFeeds(QVariant snapObject)
{
	_feedsDataModel->insert(0, snapObject);
	emit feedsDataModelChanged(_feedsDataModel);
}

void Snap2ChatAPIData::clearUploadingWhenZero()
{
	if(_uploadingSize == 0)
	{
		_uploadingDataModel->clear();
	}
}

void Snap2ChatAPIData::uploadingSizeChanged()
{
	setUploadingSize(_uploadingSize - 1);
}

bool Snap2ChatAPIData::contains(QString text, QString find)
{
	if(find == "" || find == " " || find == "  " || text == "" || text == " " || text == "  ")
	{
		return false;
	}

	bool result = text.contains(find, Qt::CaseInsensitive);

	return result;
}

// GET

qint64 Snap2ChatAPIData::getAddedFriendsTimestamp()
{
	return _added_friends_timestamp;
}

int Snap2ChatAPIData::getSentSnapsCount()
{
	return _sentSnapsCount;
}

int Snap2ChatAPIData::getReceivedSnapsCount()
{
	return _receivedSnapsCount;
}

int Snap2ChatAPIData::getTempID()
{
	return _tempID;
}

int Snap2ChatAPIData::getUnopenedSnaps()
{
	return _unopenedSnaps;
}

int Snap2ChatAPIData::getFriendRequests()
{
	return _friendRequests;
}

int Snap2ChatAPIData::getUploadingSize()
{
	return _uploadingSize;
}

int Snap2ChatAPIData::getScore()
{
	return _score;
}

int Snap2ChatAPIData::getBestFriendsCount()
{
	return _bestfriendsCount;
}

int Snap2ChatAPIData::getSnap_p()
{
	return _snap_p;
}

int Snap2ChatAPIData::getUnopenedSnapsCount()
{
	return _unopenedSnapsCount;
}

// BOOL

bool Snap2ChatAPIData::getIsInFriendChooser()
{
	return _isInFriendChooser;
}

bool Snap2ChatAPIData::getIsInCamera()
{
	return _isInCamera;
}

bool Snap2ChatAPIData::getLogged()
{
	return _logged;
}

bool Snap2ChatAPIData::getLoading()
{
	return _loading;
}

bool Snap2ChatAPIData::getLoadingStories()
{
	return _loadingStories;
}

bool Snap2ChatAPIData::getLoadingShoutbox()
{
	return _loadingShoutbox;
}

bool Snap2ChatAPIData::getSearchableByPhoneNumber()
{
	return _searchableByPhoneNumber;
}

bool Snap2ChatAPIData::getImageCaption()
{
	return _imageCaption;
}

bool Snap2ChatAPIData::getCanViewMatureContent()
{
	return _canViewMatureContent;
}

// STRING

QString Snap2ChatAPIData::getStaticToken()
{
	return _static_token;
}

QString Snap2ChatAPIData::getUsername()
{
	return _username;
}

QString Snap2ChatAPIData::getAuth_token()
{
	return _auth_token;
}

QString Snap2ChatAPIData::getMobileNumber()
{
	return _mobileNumber;
}

QString Snap2ChatAPIData::getSnapchatNumber()
{
	return _snapchatNumber;
}

QString Snap2ChatAPIData::getEmail()
{
	return _email;
}

QString Snap2ChatAPIData::getNotificationSoundSetting()
{
	return _notificationSoundSetting;
}

QString Snap2ChatAPIData::getStoryPrivacy()
{
	return _storyPrivacy;
}

QString Snap2ChatAPIData::getHostName()
{
	return _hostName;
}

QString Snap2ChatAPIData::getTitleBarColor()
{
	return (_titleBarColor.length() > 0 ? _titleBarColor : "#2DA667");
}

QString Snap2ChatAPIData::getBirthday()
{
	return _birthday;
}

// ARRAY DATA MODEL

bb::cascades::ArrayDataModel* Snap2ChatAPIData::getFeedsDataModel()
{
	return _feedsDataModel;
}

bb::cascades::ArrayDataModel* Snap2ChatAPIData::getUploadingDataModel()
{
	return _uploadingDataModel;
}

bb::cascades::GroupDataModel* Snap2ChatAPIData::getStoriesDataModel()
{
	return _storiesDataModel;
}

bb::cascades::GroupDataModel* Snap2ChatAPIData::getFriendsDataModel()
{
	return _friendsDataModel;
}

bb::cascades::GroupDataModel* Snap2ChatAPIData::getAddedFriendsDataModel()
{
	return _addedFriendsDataModel;
}

bb::cascades::GroupDataModel* Snap2ChatAPIData::getFriendRequestsDataModel()
{
	return _friendRequestsDataModel;
}

bb::cascades::ArrayDataModel* Snap2ChatAPIData::getShoutboxDataModel()
{
	return _shoutboxDataModel;
}

bb::cascades::ArrayDataModel* Snap2ChatAPIData::getCurrentStoriesOverViewModel()
{
	return _currentStoriesOverViewModel;
}

bb::cascades::ArrayDataModel* Snap2ChatAPIData::getCurrentStoryNotesDataModel()
{
	return _currentStoryNotesDataModel;
}

//  SET -------------------------------------------------------------------------------------------------------

void Snap2ChatAPIData::setAddedFriendsTimestamp(qint64 value)
{
	_added_friends_timestamp = value;
	emit addedFriendsTimestampChanged(_added_friends_timestamp);
}

void Snap2ChatAPIData::setSentSnapsCount(int value)
{
	_sentSnapsCount = value;
	emit sentSnapsCountChanged(_sentSnapsCount);
}

void Snap2ChatAPIData::setReceivedSnapsCount(int value)
{
	_receivedSnapsCount = value;
	emit receivedSnapsCountChanged(_receivedSnapsCount);
}

void Snap2ChatAPIData::setTempID(int value)
{
	_tempID = value;
	emit tempIDChanged(_tempID);
}

void Snap2ChatAPIData::setUnopenedSnaps(int value)
{
	_unopenedSnaps = value;
	emit unopenedSnapsChanged(_unopenedSnaps);
}

void Snap2ChatAPIData::setFriendRequests(int value)
{
	_friendRequests = value;
	emit friendRequestsChanged(_friendRequests);
}

void Snap2ChatAPIData::setUploadingSize(int value)
{
	_uploadingSize = value;
	emit uploadingSizeChanged(_uploadingSize);
}

void Snap2ChatAPIData::setScore(int value)
{
	_score = value;
	emit scoreChanged(_score);
}

void Snap2ChatAPIData::setBestFriendsCount(int value)
{
	_bestfriendsCount = value;
	emit bestfriendsCountChanged(_bestfriendsCount);
}

void Snap2ChatAPIData::setSnap_p(int value)
{
	_snap_p = value;
	emit snap_pChanged(_snap_p);
}

void Snap2ChatAPIData::setUnopenedSnapsCount(int value)
{
	_unopenedSnapsCount = value;
	emit unopenedSnapsCountChanged(_unopenedSnapsCount);
}

// BOOL

void Snap2ChatAPIData::setIsInFriendChooser(bool value)
{
	_isInFriendChooser = value;
	emit isInFriendChooserChanged(_isInFriendChooser);
}

void Snap2ChatAPIData::setIsInCamera(bool value)
{
	_isInCamera = value;
	emit isInCameraChanged(_isInCamera);
}

void Snap2ChatAPIData::setLogged(bool value)
{
	_logged = value;
	emit loggedChanged(_logged);
}

void Snap2ChatAPIData::setLoading(bool value)
{
	_loading = value;
	emit loadingChanged(_loading);
}

void Snap2ChatAPIData::setLoadingStories(bool value)
{
	_loadingStories = value;
	emit loadingStoriesChanged(_loadingStories);
}

void Snap2ChatAPIData::setLoadingShoutbox(bool value)
{
	_loadingShoutbox = value;
	emit loadingShoutboxChanged(_loadingShoutbox);
}

void Snap2ChatAPIData::setSearchableByPhoneNumber(bool value)
{
	_searchableByPhoneNumber = value;
	emit searchableByPhoneNumberChanged(_searchableByPhoneNumber);
}

void Snap2ChatAPIData::setImageCaption(bool value)
{
	_imageCaption = value;
	emit imageCaptionChanged(_imageCaption);
}

void Snap2ChatAPIData::setCanViewMatureContent(bool value)
{
	_canViewMatureContent = value;
	emit canViewMatureContentChanged(_canViewMatureContent);
}

//

void Snap2ChatAPIData::setStaticToken(QString value)
{
	_static_token = value;
	emit static_tokenChanged(_static_token);
}

void Snap2ChatAPIData::setUsername(QString value)
{
	_username = value;
	emit usernameChanged(_username);
}

void Snap2ChatAPIData::setAuth_token(QString value)
{
	_auth_token = value;
	emit auth_tokenChanged(_auth_token);
}

void Snap2ChatAPIData::setMobileNumber(QString value)
{
	_mobileNumber = value;
	emit mobileNumberChanged(_mobileNumber);
}

void Snap2ChatAPIData::setSnapchatNumber(QString value)
{
	_snapchatNumber = value;
	emit snapchatNumberChanged(_snapchatNumber);
}


void Snap2ChatAPIData::setEmail(QString value)
{
	_email = value;
	emit emailChanged(_email);
}

void Snap2ChatAPIData::setNotificationSoundSetting(QString value)
{
	_notificationSoundSetting = value;
	emit notificationSoundSettingChanged(_notificationSoundSetting);
}

void Snap2ChatAPIData::setStoryPrivacy(QString value)
{
	_storyPrivacy = value;
	emit storyPrivacyChanged(_storyPrivacy);
}

void Snap2ChatAPIData::setHostName(QString value)
{
	_hostName = value;
	emit hostNameChanged(_hostName);
}

void Snap2ChatAPIData::setTitleBarColor(QString value)
{
	_titleBarColor = value;
	emit titleBarColorChanged(_titleBarColor);
}

void Snap2ChatAPIData::setBirthday(QString value)
{
	_birthday = value;
	emit birthdayChanged(_birthday);
}

// ----------------------------------------------

QString Snap2ChatAPIData::generateRequestToken(quint64 timestamp, QString token)
{
	init();

	unsigned char message_digest1[SB_SHA256_DIGEST_LEN];

	QString first = SECRET + token;
	QString second = QString::number(timestamp) + SECRET;

	QString hash1;
	QString hash2;

	int result1 = SB_SUCCESS;

	result1 = hash(first, message_digest1);

	if (result1 == SB_SUCCESS)
	{
		QByteArray hash1data = QByteArray::fromRawData(reinterpret_cast<const char *>(message_digest1), SB_SHA256_DIGEST_LEN);
		hash1 = QString::fromAscii(hash1data.toHex());
	}

	unsigned char message_digest2[SB_SHA256_DIGEST_LEN];

	int result2 = SB_SUCCESS;

	result2 = hash(second, message_digest2);

	if (result2 == SB_SUCCESS)
	{
		QByteArray hash2data = QByteArray::fromRawData(reinterpret_cast<const char *>(message_digest2), SB_SHA256_DIGEST_LEN);
		hash2 = QString::fromAscii(hash2data.toHex());
	}

	QString resultCode = "";

	for (int i = 0; i < HASH_PATTERN.length(); i++)
	{
		QString currentDigit = HASH_PATTERN.at(i);

		if(currentDigit == "1")
		{
			resultCode.append(hash2.at(i));
		}
		else
		{
			resultCode.append(hash1.at(i));
		}
	}

	end();

	return resultCode;
}

QString Snap2ChatAPIData::intToHex(int decimal)
{
	QString hexadecimal;
	hexadecimal.setNum(decimal, 16);
	return hexadecimal;
}

int Snap2ChatAPIData::init()
{
	int returnCode = SB_SUCCESS; /* Return Code */

	returnCode = hu_GlobalCtxCreateDefault(&sbCtx);

	if (returnCode != SB_SUCCESS)
	{
		//qDebug() << "XXXX makeHash ERROR creating SB contexts:" << intToHex(returnCode);
		return returnCode;
	}

	returnCode = hu_RegisterSbg56(sbCtx);

	if (returnCode != SB_SUCCESS)
	{
		//qDebug() << "XXXX makeHash ERROR calling hu_RegisterSbg56:" << intToHex(returnCode);
		return returnCode;
	}

	returnCode = hu_InitSbg56(sbCtx);

	if (returnCode != SB_SUCCESS)
	{
		//qDebug() << "XXXX makeHash ERROR calling hu_InitSbg56:" << intToHex(returnCode);
		return returnCode;
	}

	return returnCode;
}

void Snap2ChatAPIData::end()
{
	(void) hu_SHA256End(&sha256Context, NULL, sbCtx);
	hu_GlobalCtxDestroy(&sbCtx);
}

int Snap2ChatAPIData::hash(const QString input_data, unsigned char* messageDigest)
{
	int returnCode = SB_SUCCESS; /* Return Code */

	QByteArray input_bytes = input_data.toUtf8();
	unsigned char* hash_input = reinterpret_cast<unsigned char*>(input_bytes.data());

	returnCode = hu_SHA256Begin((size_t) SB_SHA256_DIGEST_LEN, NULL, &sha256Context, sbCtx);

	if (returnCode != SB_SUCCESS)
	{
		//qDebug() << "XXXX makeHash ERROR initialising SHA-256 context:" << intToHex(returnCode);
		return returnCode;
	}

	returnCode = hu_SHA256Hash(sha256Context, (size_t) input_bytes.length(), hash_input, sbCtx);

	if (returnCode != SB_SUCCESS)
	{
		//qDebug() << "XXXX makeHash ERROR creating hash:" << intToHex(returnCode);
		return returnCode;
	}

	returnCode = hu_SHA256End(&sha256Context, messageDigest, sbCtx);

	if (returnCode != SB_SUCCESS)
	{
		//qDebug() << "XXXX makeHash ERROR completing hashing" << intToHex(returnCode);
		return returnCode;
	}

	return SB_SUCCESS;
}

QString Snap2ChatAPIData::generateUUID()
{
	return QUuid::createUuid();
}
