#ifndef SELFACEAPI_H_
#define SELFACEAPI_H_

#include <QtCore/QObject>
#include <QtNetwork/QNetworkAccessManager>
#include <QtCore/QVariant>

class SelfaceAPI : public QObject
{
    Q_OBJECT

public:
    SelfaceAPI(QObject* parent = 0);

    Q_INVOKABLE void get(QVariant params);
    Q_INVOKABLE void post(QVariant params);

Q_SIGNALS:

    void complete(QString response, QString httpcode, QString endpoint);

public slots:

	void onComplete();

private :

    QNetworkAccessManager networkAccessManager;
};

#endif /* NEMAPI_H_ */

