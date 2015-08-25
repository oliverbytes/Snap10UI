#include "Snap2ChatAPISimple.hpp"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QtNetwork/QtNetwork>
#include <QtCore/QtCore>

const QString HOST 					= "feelinsonice-hrd.appspot.com";
const QString PROTOCOL 				= "https://";
//const QString USER_AGENT 			= "Snapchat/6.1.2 (iPhone6,2; iOS 7.0.4; gzip)";
const QString USER_AGENT 			= "Snapchat/4.1.07 (SAMSUNG-SGH-I747; Android 19; gzip)";
const QString ACCEPT_LANGUAGE 		= "en;q=1, en;q=0.9";
const QString ACCEPT_LOCALE 		= "en_US";
const QString CONNECTION 			= "Keep-Alive";
const QString CONTENT_TYPE 			= "application/x-www-form-urlencoded";

Snap2ChatAPISimple::Snap2ChatAPISimple(QObject* parent)
    : QObject(parent)
{

}

void Snap2ChatAPISimple::request(QVariant params)
{
	// /ph/find_friends
	// /bq/bests

	QUrl dataToSend;

	QVariantMap paramsMap = params.toMap();

	const QString endpoint		= paramsMap.value("endpoint").toString();
	const QString username		= paramsMap.value("username").toString();
	const QString timestamp		= paramsMap.value("timestamp").toString();
	const QString req_token		= paramsMap.value("req_token").toString();

	dataToSend.addQueryItem("username", username);
	dataToSend.addQueryItem("timestamp", timestamp);
	dataToSend.addQueryItem("req_token", req_token);

	if(endpoint == "/ph/send")
	{
		dataToSend.addQueryItem("recipient", paramsMap.value("recipient").toString());
		dataToSend.addQueryItem("media_id", paramsMap.value("media_id").toString());
		dataToSend.addQueryItem("time", paramsMap.value("time").toString());
		dataToSend.addQueryItem("zipped", paramsMap.value("zipped").toString());
	}
	else if(endpoint == "/bq/update_snaps")
	{
		dataToSend.addQueryItem("events", paramsMap.value("events").toString());
		dataToSend.addQueryItem("json", paramsMap.value("json").toString());
		dataToSend.addQueryItem("added_friends_timestamp", paramsMap.value("added_friends_timestamp").toString());
	}
	else if(endpoint == "/ph/find_friends")
	{
		dataToSend.addQueryItem("numbers", paramsMap.value("numbers").toString());
		dataToSend.addQueryItem("countryCode", paramsMap.value("countryCode").toString());
	}
	else if(endpoint == "/bq/set_num_best_friends")
	{
		dataToSend.addQueryItem("num_best_friends", paramsMap.value("num_best_friends").toString());
	}
	else if(endpoint == "/bq/friend")
	{
		dataToSend.addQueryItem("action", paramsMap.value("action").toString());
		dataToSend.addQueryItem("friend", paramsMap.value("friend").toString());

		const QString action = paramsMap.value("action").toString();

		if(action == "display")
		{
			dataToSend.addQueryItem("display", paramsMap.value("display").toString());
		}
	}
	else if(endpoint == "/bq/bests")
	{
		dataToSend.addQueryItem("friend_usernames", paramsMap.value("friend_usernames").toString());
	}
	else if(endpoint == "/ph/settings")
	{
		dataToSend.addQueryItem("action", paramsMap.value("action").toString());

		const QString action = paramsMap.value("action").toString();

		if(action == "updateBirthday")
		{
			dataToSend.addQueryItem("birthday", paramsMap.value("birthday").toString());
		}
		else if(action == "updateStoryPrivacy" || action == "updatePrivacy")
		{
			dataToSend.addQueryItem("privacySetting", paramsMap.value("privacySetting").toString());
		}
		else if(action == "updateEmail")
		{
			dataToSend.addQueryItem("email", paramsMap.value("email").toString());
		}
		else if(action == "updatePhoneNumberWithCall" || action == "updatePhoneNumber")
		{
			dataToSend.addQueryItem("countryCode", paramsMap.value("countryCode").toString());
			dataToSend.addQueryItem("phoneNumber", paramsMap.value("phoneNumber").toString());
		}
		else if(action == "verifyPhoneNumber")
		{
			dataToSend.addQueryItem("code", paramsMap.value("code").toString());
		}
	}
	else if(endpoint == "/bq/login")
	{
		dataToSend.addQueryItem("password", paramsMap.value("password").toString());
	}
	else if(endpoint == "/bq/register")
	{
		dataToSend.removeQueryItem("username");

		dataToSend.addQueryItem("email", paramsMap.value("email").toString());
		dataToSend.addQueryItem("age", paramsMap.value("age").toString());
		dataToSend.addQueryItem("birthday", paramsMap.value("birthday").toString());
		dataToSend.addQueryItem("password", paramsMap.value("password").toString());
	}
	else if(endpoint == "/bq/solve_captcha")
	{
		dataToSend.addQueryItem("captcha_solution", paramsMap.value("captcha_solution").toString());
		dataToSend.addQueryItem("captcha_id", paramsMap.value("captcha_id").toString());
	}
	else if(endpoint == "/bq/register_username")
	{
		dataToSend.addQueryItem("username", paramsMap.value("username").toString()); // EMAIL USERNAME
		dataToSend.addQueryItem("selected_username", paramsMap.value("selected_username").toString());
	}
	else if(endpoint == "/bq/post_story")
	{
		dataToSend.addQueryItem("media_id", paramsMap.value("media_id").toString());
		dataToSend.addQueryItem("client_id", paramsMap.value("client_id").toString());
		dataToSend.addQueryItem("time", paramsMap.value("time").toString());
		dataToSend.addQueryItem("zipped", paramsMap.value("zipped").toString());
		dataToSend.addQueryItem("type", paramsMap.value("type").toString());
	}
	else if(endpoint == "/bq/delete_story")
	{
		dataToSend.addQueryItem("story_id", paramsMap.value("story_id").toString());
	}

	QNetworkRequest request;
	request.setUrl(QUrl(PROTOCOL + HOST + endpoint));
	request.setHeader(QNetworkRequest::ContentTypeHeader, CONTENT_TYPE);
	request.setRawHeader("User-Agent", USER_AGENT.toAscii());
	request.setRawHeader("Accept-Language", ACCEPT_LANGUAGE.toAscii());
	request.setRawHeader("Accept-Locale", ACCEPT_LOCALE.toAscii());
	request.setRawHeader("Connection", CONNECTION.toAscii());
	request.setRawHeader("Host", HOST.toAscii());

	QNetworkReply* reply = m_manager.post(request, dataToSend.encodedQuery());
	reply->setProperty("endpoint", endpoint);
	connect (reply, SIGNAL(finished()), this, SLOT(onComplete()));
}

void Snap2ChatAPISimple::upload(QVariant params)
{
	QVariantMap paramsMap 	= params.toMap();

	const QString endpoint		= paramsMap.value("endpoint").toString();
	const QString username		= paramsMap.value("username").toString();
	const QString timestamp		= paramsMap.value("timestamp").toString();
	const QString req_token		= paramsMap.value("req_token").toString();

	const QString media_id		= paramsMap.value("media_id").toString();
	const QString type			= paramsMap.value("type").toString();
	const QString fileLocation	= paramsMap.value("fileLocation").toString();

	QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

	QHttpPart media_idPart;
	media_idPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"media_id\""));
	media_idPart.setBody(media_id.toAscii());
	multiPart->append(media_idPart);

	QHttpPart typePart;
	typePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"type\""));
	typePart.setBody(type.toAscii());
	multiPart->append(typePart);

	QHttpPart imagePart;
	imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"data\"; filename=\"data\""));
	imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/octet-stream"));
	QFile *file = new QFile(fileLocation);
	file->open(QIODevice::ReadOnly);
	imagePart.setBodyDevice(file);
	file->setParent(multiPart);
	multiPart->append(imagePart);

	QHttpPart usernamePart;
	usernamePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"username\""));
	usernamePart.setBody(username.toAscii());
	multiPart->append(usernamePart);

	QHttpPart timestampPart;
	timestampPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"timestamp\""));
	timestampPart.setBody(timestamp.toAscii());
	multiPart->append(timestampPart);

	QHttpPart req_tokenPart;
	req_tokenPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"req_token\""));
	req_tokenPart.setBody(req_token.toAscii());
	multiPart->append(req_tokenPart);

	QUrl url(PROTOCOL + HOST + endpoint);
	QNetworkRequest request(url);
	request.setRawHeader("User-Agent", USER_AGENT.toAscii());

	request.setRawHeader("Accept-Language", ACCEPT_LANGUAGE.toAscii());
	request.setRawHeader("Accept-Locale", ACCEPT_LOCALE.toAscii());
	request.setRawHeader("Connection", CONNECTION.toAscii());
	request.setRawHeader("Host", HOST.toAscii());

	QNetworkReply *reply = m_manager.post(request, multiPart);
	reply->setProperty("endpoint", endpoint);
	multiPart->setParent(reply);
	connect (reply, SIGNAL(finished()), this, SLOT(onComplete()));
}

void Snap2ChatAPISimple::download(QVariant params)
{
	QVariantMap paramsMap 	= params.toMap();

	const QByteArray username	= paramsMap.value("username").toString().toAscii().toPercentEncoding();
	const QByteArray timestamp	= paramsMap.value("timestamp").toString().toAscii().toPercentEncoding();
	const QByteArray req_token	= paramsMap.value("req_token").toString().toAscii().toPercentEncoding();
	const QByteArray id			= paramsMap.value("id").toString().toAscii().toPercentEncoding();

	const QString fileLocation	= paramsMap.value("fileLocation").toString();
	const QString endpoint		= paramsMap.value("endpoint").toString();

	if(QFile::exists(fileLocation))
	{
		QFile snapFile(fileLocation);

		if(snapFile.open(QIODevice::ReadOnly))
		{
			if(snapFile.size() > 0)
			{
				QVariantMap resultObject;
				resultObject.insert("response", "ALREADY DOWNLOADED: " + QString::number(snapFile.size()));
				resultObject.insert("httpcode", "200");

				QVariantMap passedParams;
				passedParams.insert("endpoint", endpoint);
				passedParams.insert("fileLocation", fileLocation);
				passedParams.insert("done", true);
				resultObject.insert("passedParams", passedParams);

				emit completeSnap(resultObject);

				snapFile.close();

				return;
			}
		}

		snapFile.close();
	}

	QString dataToSend = "?id=" + id + "&username=" + username  + "&timestamp=" + timestamp + "&req_token=" + req_token;

	QNetworkRequest request;
	request.setUrl(QUrl(PROTOCOL + HOST + endpoint + dataToSend));
	request.setHeader(QNetworkRequest::ContentTypeHeader, CONTENT_TYPE);
	request.setRawHeader("User-Agent", USER_AGENT.toAscii());
	request.setRawHeader("Accept-Language", ACCEPT_LANGUAGE.toAscii());
	request.setRawHeader("Accept-Locale", ACCEPT_LOCALE.toAscii());
	request.setRawHeader("Connection", CONNECTION.toAscii());
	request.setRawHeader("Host", HOST.toAscii());

	QNetworkReply* reply = m_manager.get(request);
	QVariantMap passedParams;
	passedParams.insert("endpoint", endpoint);
	passedParams.insert("fileLocation", fileLocation);
	reply->setProperty("passedParams", passedParams);
    connect(reply, SIGNAL(finished()), SLOT(onDownloadCompleted()));
}

void Snap2ChatAPISimple::onDownloadCompleted()
{
	QNetworkReply* reply 	= qobject_cast<QNetworkReply*>(sender());
	int status 				= reply->attribute( QNetworkRequest::HttpStatusCodeAttribute).toInt();
	QString reason 			= reply->attribute( QNetworkRequest::HttpReasonPhraseAttribute ).toString();

	QVariantMap passedParams = reply->property("passedParams").toMap();

	QString response;

	int available = 0;

	if (reply)
	{
		if (reply->error() == QNetworkReply::NoError)
		{
			available = reply->bytesAvailable();

			if (available > 0)
			{
				if(status == 200)
				{
					QFile snapFile(passedParams["fileLocation"].toString());

					if (!snapFile.open(QIODevice::WriteOnly))
					{
						qDebug() << "PROBLEM OPENING FILE: " + passedParams["fileLocation"].toString();
						return;
					}

					snapFile.write(reply->readAll());
					snapFile.close();
				}

				const QByteArray buffer(reply->readAll());
				response = QString::fromUtf8(buffer);
			}
		}
		else
		{
			response = "error";
		}

		reply->deleteLater();
	}

	if (response.trimmed().isEmpty())
	{
		response = "error";
	}

	QVariantMap resultObject;
	resultObject.insert("response", response);
	resultObject.insert("httpcode", status);
	resultObject.insert("passedParams", passedParams);

	emit completeSnap(resultObject);
}

void Snap2ChatAPISimple::downloadStory(QVariant params)
{
	QVariantMap paramsMap 	= params.toMap();

	const QByteArray username	= paramsMap.value("username").toString().toAscii().toPercentEncoding();
	const QByteArray timestamp	= paramsMap.value("timestamp").toString().toAscii().toPercentEncoding();
	const QByteArray req_token	= paramsMap.value("req_token").toString().toAscii().toPercentEncoding();
	const QByteArray id			= paramsMap.value("id").toString().toAscii().toPercentEncoding();

	const QString endpoint		= paramsMap.value("endpoint").toString();

	const QString media_iv		= paramsMap.value("media_iv").toString();
	const QString media_key		= paramsMap.value("media_key").toString();
	const QString media_type	= paramsMap.value("media_type").toString();
	const QString time			= paramsMap.value("time").toString();

	const QString fileLocation	= paramsMap.value("fileLocation").toString();

	if(QFile::exists(fileLocation))
	{
		QFile storyFile(fileLocation);

		if(storyFile.open(QIODevice::ReadOnly))
		{
			if(storyFile.size() > 0)
			{
				QVariantMap resultObject;
				resultObject.insert("response", "ALREADY DOWNLOADED: " + QString::number(storyFile.size()));
				resultObject.insert("httpcode", "200");

				QVariantMap passedParams;
				passedParams.insert("endpoint", endpoint);
				passedParams.insert("fileLocation", fileLocation);
				passedParams.insert("media_key", media_key);
				passedParams.insert("media_iv", media_iv);
				passedParams.insert("media_type", media_type);
				passedParams.insert("time", time);
				passedParams.insert("done", true);
				passedParams.insert("id", id);
				resultObject.insert("passedParams", passedParams);

				emit completeStory(resultObject);

				storyFile.close();

				qDebug() << "#### ALREADY DOWNLOADED ####";

				return;
			}
		}

		storyFile.close();
	}

	QString dataToSend = "?story_id=" + id;
	//QString dataToSend = "?story_id=" + id + "&username=" + username  + "&timestamp=" + timestamp + "&req_token=" + req_token;

	QNetworkRequest request;
	request.setUrl(QUrl(PROTOCOL + HOST + endpoint + dataToSend));
	request.setHeader(QNetworkRequest::ContentTypeHeader, CONTENT_TYPE);
	request.setRawHeader("User-Agent", USER_AGENT.toAscii());
	request.setRawHeader("Accept-Language", ACCEPT_LANGUAGE.toAscii());
	request.setRawHeader("Accept-Locale", ACCEPT_LOCALE.toAscii());
	request.setRawHeader("Connection", CONNECTION.toAscii());
	request.setRawHeader("Host", HOST.toAscii());

	qDebug() << "#### REQUEST: " << dataToSend;

	QNetworkReply* reply = m_manager.get(request);

	QVariantMap passedParams;
	passedParams.insert("endpoint", endpoint);
	passedParams.insert("fileLocation", fileLocation);
	passedParams.insert("media_key", media_key);
	passedParams.insert("media_iv", media_iv);
	passedParams.insert("media_type", media_type);
	passedParams.insert("time", time);
	passedParams.insert("id", id);

	reply->setProperty("passedParams", passedParams);
    connect(reply, SIGNAL(finished()), SLOT(onDownloadCompletedStory()));
}

void Snap2ChatAPISimple::onDownloadCompletedStory()
{
	QNetworkReply* reply 	= qobject_cast<QNetworkReply*>(sender());
	int status 				= reply->attribute( QNetworkRequest::HttpStatusCodeAttribute).toInt();
	QString reason 			= reply->attribute( QNetworkRequest::HttpReasonPhraseAttribute ).toString();

	QVariantMap passedParams = reply->property("passedParams").toMap();

	QString response;

	int available = 0;

	if (reply)
	{
		if (reply->error() == QNetworkReply::NoError)
		{
			available = reply->bytesAvailable();

			if (available > 0)
			{
				if(status == 200)
				{
					QFile storyFile(passedParams["fileLocation"].toString());

					if (!storyFile.open(QIODevice::WriteOnly))
					{
						qDebug() << "PROBLEM OPENING FILE: " + passedParams["fileLocation"].toString();
						return;
					}

					storyFile.write(reply->readAll());
					storyFile.close();
				}

				const QByteArray buffer(reply->readAll());
				response = QString::fromUtf8(buffer);
			}
		}
		else
		{
			response = "error";
		}

		reply->deleteLater();
	}

	if (response.trimmed().isEmpty())
	{
		response = "error";
	}

	qDebug() << "#### HTTPCODE: " << status << ", response" << response;

	QVariantMap resultObject;
	resultObject.insert("response", response);
	resultObject.insert("httpcode", status);
	resultObject.insert("passedParams", passedParams);

	emit completeStory(resultObject);
}

void Snap2ChatAPISimple::downloadCaptcha(QVariant params)
{
	QVariantMap paramsMap 	= params.toMap();
	QString endpoint	= paramsMap["endpoint"].toString();

    QUrl dataToSend;

	dataToSend.addQueryItem("username", paramsMap.value("username").toString());
	dataToSend.addQueryItem("timestamp", paramsMap.value("timestamp").toString());
	dataToSend.addQueryItem("req_token", paramsMap.value("req_token").toString());

	QNetworkRequest request;
	request.setUrl(QUrl(PROTOCOL + HOST + endpoint));
	request.setHeader(QNetworkRequest::ContentTypeHeader, CONTENT_TYPE);
	request.setRawHeader("User-Agent", USER_AGENT.toAscii());
	request.setRawHeader("Accept-Language", ACCEPT_LANGUAGE.toAscii());
	request.setRawHeader("Accept-Locale", ACCEPT_LOCALE.toAscii());
	request.setRawHeader("Connection", CONNECTION.toAscii());
	request.setRawHeader("Host", HOST.toAscii());

	QNetworkReply* reply = m_manager.post(request, dataToSend.encodedQuery());
	reply->setProperty("endpoint", endpoint);
    connect(reply, SIGNAL(finished()), SLOT(downloadFinished()));
}

void Snap2ChatAPISimple::downloadFinished()
{
	QNetworkReply* reply 	= qobject_cast<QNetworkReply*>(sender());
	int status 				= reply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt();
	QString reason 			= reply->attribute( QNetworkRequest::HttpReasonPhraseAttribute ).toString();

	QString response;
	int available = 0;
	QString realFileName = "";

	if (reply)
	{
		if (reply->error() == QNetworkReply::NoError)
		{
			available = reply->bytesAvailable();

			if (available > 0)
			{
				realFileName = reply->rawHeader("Content-Disposition");

				QFile* captchaFile = new QFile("data/files/captcha/captcha.zip");

				if (!captchaFile->open(QIODevice::WriteOnly))
				{
					qDebug() << "PROBLEM OPENING FILE: data/files/captcha/captcha.zip";
					return;
				}

				captchaFile->write(reply->readAll());
				captchaFile->close();

				const QByteArray buffer(reply->readAll());
				response = QString::fromUtf8(buffer);
			}
		}
		else
		{
			response = "error";
		}

		reply->deleteLater();
	}

	if (response.trimmed().isEmpty())
	{
		response = "error";
	}

	qDebug() << "HTTP: " + QString::number(status);

	emit downloadDone(realFileName);
}

void Snap2ChatAPISimple::onComplete()
{
	QNetworkReply* reply 	= qobject_cast<QNetworkReply*>(sender());
	int status 				= reply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt();
	QString reason 			= reply->attribute( QNetworkRequest::HttpReasonPhraseAttribute ).toString();

	QString response;

	if (reply)
	{
		if (reply->error() == QNetworkReply::NoError)
		{
			const int available = reply->bytesAvailable();

			if (available > 0)
			{
				const QByteArray buffer(reply->readAll());
				response = QString::fromUtf8(buffer);
			}
		}
		else
		{
			response = "error";
		}

		reply->deleteLater();
	}

	if (response.trimmed().isEmpty())
	{
		response = "error";
	}

	if(QString::number(status) == "200")
	{
		response = ((response.length() > 0 && response != "error") ? response : QString::number(status));
	}
	else
	{
		response = QString::number(status);
	}

	emit complete(response, QString::number(status), reply->property("endpoint").toString());
}

void Snap2ChatAPISimple::kellyGetRequest(QVariant params)
{
	QVariantMap paramsMap = params.toMap();

	QNetworkRequest request;
	request.setUrl(QUrl(paramsMap["url"].toString()));
	request.setHeader(QNetworkRequest::ContentTypeHeader, CONTENT_TYPE);
	request.setRawHeader("User-Agent", USER_AGENT.toAscii());
	request.setRawHeader("Accept-Language", ACCEPT_LANGUAGE.toAscii());
	request.setRawHeader("Accept-Locale", ACCEPT_LOCALE.toAscii());

	QNetworkReply* reply = m_manager.get(request);
	reply->setProperty("endpoint", paramsMap["endpoint"].toString());
	connect (reply, SIGNAL(finished()), this, SLOT(onComplete()));
}

void Snap2ChatAPISimple::kellyUploadProfile(QVariant params)
{
	QVariantMap paramsMap 	= params.toMap();

	const QString endpoint		= paramsMap.value("endpoint").toString();
	const QString id			= paramsMap.value("id").toString();
	const QString username		= paramsMap.value("username").toString();
	const QString name			= paramsMap.value("name").toString();
	const QString age			= paramsMap.value("age").toString();
	const QString gender		= paramsMap.value("gender").toString();
	const QString about			= paramsMap.value("about").toString();
	const QString fileLocation	= paramsMap.value("fileLocation").toString();

	QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

	QHttpPart idPart;
	idPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"id\""));
	idPart.setBody(id.toAscii());
	multiPart->append(idPart);

	QHttpPart usernamePart;
	usernamePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"username\""));
	usernamePart.setBody(username.toAscii());
	multiPart->append(usernamePart);

	QHttpPart namePart;
	namePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"name\""));
	namePart.setBody(name.toAscii());
	multiPart->append(namePart);

	QHttpPart agePart;
	agePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"age\""));
	agePart.setBody(age.toAscii());
	multiPart->append(agePart);

	QHttpPart genderPart;
	genderPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"gender\""));
	genderPart.setBody(gender.toAscii());
	multiPart->append(genderPart);

	QHttpPart aboutPart;
	aboutPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"about\""));
	aboutPart.setBody(about.toAscii());
	multiPart->append(aboutPart);

	QHttpPart imagePart;
	imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"picture\"; filename=\"picture\""));
	QFile *file = new QFile(fileLocation);
	file->open(QIODevice::ReadOnly);
	imagePart.setBodyDevice(file);
	file->setParent(multiPart);
	multiPart->append(imagePart);

	QNetworkRequest request(QUrl(paramsMap["url"].toString()));

	QNetworkReply *reply = m_manager.post(request, multiPart);
	reply->setProperty("endpoint", endpoint);
	multiPart->setParent(reply);
	connect (reply, SIGNAL(finished()), this, SLOT(onComplete()));
}

void Snap2ChatAPISimple::kellyUploadShout(QVariant params)
{
	QVariantMap paramsMap 	= params.toMap();

	const QString endpoint		= paramsMap.value("endpoint").toString();
	const QString username		= paramsMap.value("username").toString();
	const QString message		= paramsMap.value("message").toString();
	const QString fileLocation	= paramsMap.value("fileLocation").toString();

	QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

	QHttpPart usernamePart;
	usernamePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"username\""));
	usernamePart.setBody(username.toAscii());
	multiPart->append(usernamePart);

	QHttpPart messagePart;
	messagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"message\""));
	messagePart.setBody(message.toAscii());
	multiPart->append(messagePart);

	QHttpPart imagePart;
	imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"picture\"; filename=\"picture\""));
	QFile *file = new QFile(fileLocation);
	file->open(QIODevice::ReadOnly);
	imagePart.setBodyDevice(file);
	file->setParent(multiPart);
	multiPart->append(imagePart);

	QNetworkRequest request(QUrl(paramsMap["url"].toString()));

	QNetworkReply *reply = m_manager.post(request, multiPart);
	reply->setProperty("endpoint", endpoint);
	multiPart->setParent(reply);
	connect (reply, SIGNAL(finished()), this, SLOT(onComplete()));
}
