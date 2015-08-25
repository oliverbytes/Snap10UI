#include "VideoEditor.h"

#include <QDebug>
#include <bb/system/CardDoneMessage>

VideoEditor::VideoEditor(QObject* parent)
    : QObject(parent)
{
	invokeManager = new InvokeManager();
}

void VideoEditor::invokeVideoEditor(QString filePath)
{
	bb::system::InvokeRequest request;
	QUrl invokeUri = QUrl::fromLocalFile(filePath);
	invokeUri.setScheme("videoeditor");
	invokeUri.setQueryDelimiters('=', ';');
	request.setTarget("sys.video_editor.card");
	request.setAction("bb.action.EDIT");
	request.setUri(invokeUri);
	request.setMimeType("video/mp4");
	invokeManager->invoke(request);

	bool connected = connect(invokeManager, SIGNAL(childCardDone(const bb::system::CardDoneMessage&)),
	this, SLOT(onChildCardDone(const bb::system::CardDoneMessage&)));

	if(connected)
	{
		qDebug() << "CONNECTED: " + filePath;
	}
}

void VideoEditor::onChildCardDone(const bb::system::CardDoneMessage &message)
{
	if(message.reason() != "Canceled")
	{
		emit complete(message.data());
	}
	else
	{
		emit canceled();
	}
}
