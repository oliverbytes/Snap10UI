#include <bb/cascades/Application>

#include "applicationui.hpp"
#include <QtCore/QtCore>

#include "WebImageView/WebImageView.hpp"
#include "PictureEditor/PictureEditor.h"
#include "MyContactPicker/MyContactPicker.h"
#include <bb/ApplicationInfo>
#include "VideoEditor/VideoEditor.h"
#include "Snap2ChatAPI/Snap2ChatAPISimple.hpp"
#include "Downloader/Downloader.hpp"
#include "SelfaceAPI/SelfaceAPI.hpp"
#include <SSmaatoAdView.h>
#include <SSmaatoAPI.h>

#include "VirtualKeyboardHandler/VirtualKeyboardHandler.hpp"
#include "Flurry.h"

using namespace bb::cascades;

const QString AUTHOR     = "NEMORY";
const QString APPNAME    = "SNAP2CHAT";

static QString getSetting(const QString &objectName, const QString &defaultValue)
{
    QSettings _settings(AUTHOR, APPNAME);

    if (_settings.value(objectName).isNull() || _settings.value(objectName) == "")
    {
        return defaultValue;
    }

    return _settings.value(objectName).toString();
}

Q_DECL_EXPORT int main(int argc, char **argv)
{
    //log();

    qputenv("CASCADES_THEME", getSetting("colortheme", "bright").toUtf8());

	#if !defined(QT_NO_DEBUG)
		Flurry::Analytics::SetDebugLogEnabled(false);
	#endif

	Flurry::Analytics::SetAppVersion(bb::ApplicationInfo().version());
	Flurry::Analytics::StartSession("GRVB4GH29FRWW6KJF7RK");

	qmlRegisterType<SSmaatoAdView>("smaatosdk", 1, 0, "SSmaatoAdView");
    qmlRegisterType<SSmaatoAPI>("smaatoapi", 1, 0, "SSmaatoAPI");
	qmlRegisterType<SelfaceAPI>("nemory.SelfaceAPI", 1, 0, "SelfaceAPI");
	qmlRegisterType<Snap2ChatAPISimple>("nemory.Snap2ChatAPISimple", 1, 0, "Snap2ChatAPISimple");
	qmlRegisterType<MyContactPicker>("nemory.MyContactPicker", 1, 0, "MyContactPicker");
	qmlRegisterType<PictureEditor>("nemory.PictureEditor", 1, 0, "PictureEditor");
	qmlRegisterType<VideoEditor>("nemory.VideoEditor", 1, 0, "VideoEditor");
	qmlRegisterType<WebImageView>("org.labsquare", 1, 0, "WebImageView");
	qmlRegisterType<Downloader>("nemory.Downloader", 1, 0, "Downloader");
	qmlRegisterType<VirtualKeyboardHandler>("com.knobtviker.Helpers", 1, 0, "VirtualKeyboardHandler");

    Application app(argc, argv);
    new ApplicationUI(&app);
    return Application::exec();
}

//static void log()
//{
//    if(getSetting("allowLogging", "true") == "true")
//    {
//        qDebug() << "LOGS COPIED ON START";
//
//        QString sharedLogsPath = QDir::currentPath() + "/shared/misc/Snap2ChatStart";
//
//        QDir dir1;
//        dir1.mkpath(sharedLogsPath);
//
//        QString devLogsPath = QDir::currentPath() + "/logs";
//
//        QDir dir(devLogsPath);
//
//        if (dir.exists(devLogsPath))
//        {
//            Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files | QDir::AllEntries | QDir::Writable, QDir::DirsFirst))
//            {
//                if (info.isDir())
//                {
//                   qDebug() << "DIR IGNORE: " << info.absoluteFilePath();
//                }
//                else
//                {
//                    qDebug() << "FILE COPY: " << info.absoluteFilePath();
//
//                    QString from    = info.absoluteFilePath();
//                    QString to      = sharedLogsPath + "/" + info.fileName();
//
//                    if(QFile::exists(to))
//                    {
//                        QFile::remove(to);
//                    }
//
//                    if(!QFile::copy(from, to))
//                    {
//                        qDebug() << "COPY: " << from << " FAILED TO COPY TO " << to;
//                    }
//                    else
//                    {
//                        QFile copiedFile(to);
//                        copiedFile.open(QIODevice::ReadWrite);
//                        copiedFile.setPermissions(QFile::WriteOther | QFile::ReadOther | QFile::WriteGroup | QFile::ReadGroup | QFile::WriteUser | QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner | QFile::ExeGroup | QFile::ExeOther | QFile::ExeOther | QFile::ExeUser);
//                        copiedFile.close();
//                    }
//                }
//            }
//        }
//    }
//}
