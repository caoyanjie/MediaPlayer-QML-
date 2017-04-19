#ifndef APPLICATION_H
#define APPLICATION_H

#include <QObject>
#include <QUrl>

class Application : public QObject
{
    Q_OBJECT
public:
    explicit Application(QObject *parent = 0);
    Q_INVOKABLE QString getCommandArg();
    Q_INVOKABLE QUrl getFileUrl();
    void setCommandArg(const char* arg);

private:
    static const char* commandArg;

signals:

public slots:
};

#endif // APPLICATION_H
