#ifndef NETWORK_H
#define NETWORK_H
//#include <QWidget>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class NetWork : public QObject
{
    Q_OBJECT

public:
    NetWork();
    ~NetWork();

    Q_INVOKABLE void downloadLrc(QString musicFileFullPath);
    ////void searchMusic(QString musicName);

private:
    QNetworkAccessManager *manager;
    QNetworkAccessManager *managerDownloadLrc;
    QString lrcFileName;
    QString musicName;
    int a;

signals:
    void lrcDownloadFinished();
    ////void getMusicUrlsFinished(QMap<QString, QStringList>);

private slots:
    void replayFinished(QNetworkReply *replay);
    void replayLrcFile(QNetworkReply *replay);
    ////void getMusicUrlFinished(QNetworkReply *replay);
};

#endif // NETWORK_H
