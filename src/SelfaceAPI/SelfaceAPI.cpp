#include "SelfaceAPI.hpp"
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QtNetwork/QtNetwork>
#include <bb/PackageInfo>

using bb::PackageInfo;

// ------------------------------------- CONSTANTS ------------------------------------- //

const QString APP_KEY 			    = "IQBMRrNqJdwEvA5m0ZqPXpEk1QfbPHehwk0VckPB";
const QString CLIENT_KEY 		    = "X6TdqbDNhSx6dQp2mmAxzVw9hgPgHB5BYg4NSkqj";
const QString RESTAPI_KEY           = "PdFPhzZ2c2bpBmv7eW5qoWJ2x5FPlVnSgUeUEBPD";
const QString MASTER_KEY            = "Yez7uoU8hV4n8ulrsb0LM4ov17ryFPqoP0FmLnX6";

const QString HTTP_PROTOCOL 		= "http://";
const QString HTTPS_PROTOCOL 		= "https://";

const QString API_VERSION           = "1";
const QString API_HOST              = "api.parse.com";
const QString API_URL               = HTTPS_PROTOCOL + API_HOST + "/" + API_VERSION + "/";

const QString CONTENT_TYPE_JSON     = "application/json";
const QString CONTENT_TYPE_FORM     = "application/x-www-form-urlencoded";

const QString HEADER_APPLICATION_ID = "X-Parse-Application-Id";
const QString HEADER_API_KEY        = "X-Parse-REST-API-Key";
const QString HEADER_CONTENT_TYPE   = "Content-Type";

const QString APP_PLATFORM          = "BlackBerry";

QString APP_VERSION                 = "";

// ------------------------------------- CONSTANTS ------------------------------------- //

SelfaceAPI::SelfaceAPI(QObject* parent) : QObject(parent)
{
    PackageInfo packageInfo;
    APP_VERSION = packageInfo.version();
}

void SelfaceAPI::get(QVariant params)
{
	QVariantMap paramsMap 	= params.toMap();

	QString data            = paramsMap.value("data").toString();
	QString endpoint		= paramsMap.value("endpoint").toString();
	QString appDetails      = "?platform=BlackBerry&version=" + APP_VERSION;

	QString fullURL         = API_URL + endpoint + appDetails + data;

	qDebug() << "FULL URL: " + fullURL;

	QNetworkRequest request;
	request.setUrl(QUrl(fullURL));
	request.setRawHeader(HEADER_API_KEY.toUtf8(), RESTAPI_KEY.toUtf8());
    request.setRawHeader(HEADER_APPLICATION_ID.toUtf8(), APP_KEY.toUtf8());
    request.setRawHeader(HEADER_CONTENT_TYPE.toUtf8(), CONTENT_TYPE_JSON.toUtf8());

	QNetworkReply* reply = networkAccessManager.get(request);
	reply->setProperty("endpoint", endpoint);
	connect (reply, SIGNAL(finished()), this, SLOT(onComplete()));
}

void SelfaceAPI::post(QVariant params)
{
	QVariantMap paramsMap 	= params.toMap();

	QString data            = paramsMap.value("data").toString();
	QString endpoint		= paramsMap.value("endpoint").toString();
	QString appDetails      = "?platform=BlackBerry&version=" + APP_VERSION;

    QString fullURL         = API_URL + endpoint;

	qDebug() << "FULL URL: " + fullURL;
	qDebug() << "DATA JSON: " + data;

	QNetworkRequest request;
	request.setUrl(QUrl(fullURL));
	request.setRawHeader(HEADER_API_KEY.toUtf8(), RESTAPI_KEY.toUtf8());
    request.setRawHeader(HEADER_APPLICATION_ID.toUtf8(), APP_KEY.toUtf8());
    request.setRawHeader(HEADER_CONTENT_TYPE.toUtf8(), CONTENT_TYPE_JSON.toUtf8());

	QNetworkReply* reply = networkAccessManager.post(request, data.toAscii());
	reply->setProperty("endpoint", endpoint);
	connect (reply, SIGNAL(finished()), this, SLOT(onComplete()));
}

void SelfaceAPI::onComplete()
{
	QNetworkReply* reply 	= qobject_cast<QNetworkReply*>(sender());
	int status 				= reply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt();
	QString reason 			= reply->attribute( QNetworkRequest::HttpReasonPhraseAttribute ).toString();

	QString response;

	if (reply)
	{
	    const int available = reply->bytesAvailable();

        if (available > 0)
        {
            const QByteArray buffer(reply->readAll());
            response = QString::fromUtf8(buffer);
        }

		reply->deleteLater();
	}

	if (response.trimmed().isEmpty())
	{
		response = "empty response error";
	}

	if(QString::number(status) == "200")
	{
		response = ((response.length() > 0 && response != "error") ? response : QString::number(status));
	}

	emit complete(response, QString::number(status), reply->property("endpoint").toString());
}
