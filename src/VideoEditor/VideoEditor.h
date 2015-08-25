
#ifndef VIDEOEDITOR_H_
#define VIDEOEDITOR_H_

#include <QtCore/QObject>
#include <bb/system/CardDoneMessage>
#include <bb/system/InvokeManager>

using bb::system::InvokeManager;

namespace bb
{
    namespace cascades
    {
        namespace system
		{
			class InvokeManager;
		}
    }
}

class VideoEditor : public QObject
{
    Q_OBJECT

public:
    VideoEditor(QObject* parent = 0);

    Q_INVOKABLE void invokeVideoEditor(QString filePath);

Q_SIGNALS:
    void complete(QString videoSource);
    void canceled();

private Q_SLOTS:
    void onChildCardDone(const bb::system::CardDoneMessage &message);

private:
    InvokeManager* invokeManager;

};

#endif
