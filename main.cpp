#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "Application.h"
#include "MusicPlaylistModel.h"
#include "Network.h"
#include "LrcViewer.h"
#include "XmlProcess.h"

#ifdef Q_OS_WIN
#include <Windows.h>
#endif

int main(int argc, char *argv[])
{
#ifdef Q_OS_WIN
    ::SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED);
#endif

    QGuiApplication app(argc, argv);

    Application application;
    if (argc > 1)
    {
        application.setCommandArg(argv[1]);
    }
    qmlRegisterType<Application>("QtCPlusPlus.Application", 1, 0, "Application");

    qmlRegisterType<MusicPlaylistModel>("QtCPlusPlus.MusicPlaylistModel", 1, 0, "MusicPlaylistModel");
    qmlRegisterType<NetWork>("QtCPlusPlus.Network", 1, 0, "Network");
    qmlRegisterType<LrcViewer>("QtCPlusPlus.LrcViewer", 1, 0, "LrcViewer");
    qmlRegisterType<XmlProcess>("QtCPlusPlus.XmlProcess", 1, 0, "XmlProcess");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/QML/main.qml")));

    return app.exec();
}
