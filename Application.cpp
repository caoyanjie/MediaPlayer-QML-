#include "application.h"
#include <QDebug>
#include <QUrl>

const char* Application::commandArg;

Application::Application(QObject *parent) : QObject(parent)
{
}

QString Application::getCommandArg()
{
    return QString::fromLocal8Bit(commandArg);
}

QUrl Application::getFileUrl()
{
    return QUrl::fromLocalFile(QString::fromLocal8Bit(commandArg));
}

void Application::setCommandArg(const char *commandArg)
{
    this->commandArg = commandArg;
}
