#ifndef SNAP2CHATAPISIMPLE_H_
#define SNAP2CHATAPISIMPLE_H_

#include <QtCore/QObject>
#include <QtNetwork/QNetworkAccessManager>
#include <QtCore/QVariant>
#include <QtCore/QFile>

class Snap2ChatAPISimple : public QObject
{
    Q_OBJECT

public:
    Snap2ChatAPISimple(QObject* parent = 0);

    Q_INVOKABLE void request(QVariant params);
    Q_INVOKABLE void upload(QVariant params);
    Q_INVOKABLE void download(QVariant params);
    Q_INVOKABLE void downloadStory(QVariant params);
    Q_INVOKABLE void downloadCaptcha(QVariant params);
    Q_INVOKABLE void kellyGetRequest(QVariant params);
    Q_INVOKABLE void kellyUploadProfile(QVariant params);
    Q_INVOKABLE void kellyUploadShout(QVariant params);

Q_SIGNALS:

	void downloadDone(QString realFileName);
    void complete(QString response, QString httpcode, QString endpoint);
    void completeSnap(QVariant resultObject);
    void completeStory(QVariant resultObject);

    void test();

private Q_SLOTS:

	void onComplete();
	void onDownloadCompleted();
	void onDownloadCompletedStory();
	void downloadFinished();

private :

    QNetworkAccessManager m_manager;

    QFile* downloadedFile;
};

#endif /* SNAP2CHATAPI_H_ */
