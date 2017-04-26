#include "network.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QRegExp>
//#include <QtXml>
//#include <QXmlReader>
//#include <QXmlStreamReader>

NetWork::NetWork()
{
    manager = new QNetworkAccessManager;
    managerDownloadLrc = new QNetworkAccessManager;
}

NetWork::~NetWork()
{
    manager->deleteLater();
    managerDownloadLrc->deleteLater();
}

void NetWork::downloadLrc(QString musicFileFullPath)
{
    QString musicFileFullPathNoExt = musicFileFullPath.remove(musicFileFullPath.right(4));
    if (musicFileFullPathNoExt.isEmpty())
    {
        return;
    }

    QString lrcName = QFileInfo(musicFileFullPathNoExt).baseName();
    QString lrcUrl = "http://music.baidu.com/search/lrc?key=" + lrcName;
    manager->get(QNetworkRequest(QUrl(lrcUrl)));
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replayFinished(QNetworkReply*)));

    lrcFileName = musicFileFullPathNoExt + ".lrc";
}

// 搜索在线音乐
////void NetWork::searchMusic(QString musicName)
////{
////    if (musicName.isEmpty())
////    {
////        return;
////    }
////
////    this->musicName = musicName;
////    QString musicUrl = tr("http://box.zhangmen.baidu.com/x?op=12&&count=1&&title=%1$$").arg(musicName);
////    manager->get(QNetworkRequest(QUrl(musicUrl)));
////    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(getMusicUrlFinished(QNetworkReply*)));
////}

void NetWork::replayFinished(QNetworkReply *replay)
{
    QString htmlContent = replay->readAll();
    replay->deleteLater();
//    QRegExp regexp("(<a class=\"down-lrc-btn \\{ 'href':'/data2/lrc/\\d+/\\d+\\.lrc' \\}\" href=\"#\">下载LRC歌词</a>')");
    QRegExp regexp("(/data2/lrc/\\d+/\\d+\\.lrc)");
    QStringList list;
    int pos = 0;

    while ((pos = regexp.indexIn(htmlContent, pos)) != -1) {

        list << regexp.cap(1);
        pos += regexp.matchedLength();
    }
    if (!list.isEmpty())
    {
        QString urlDownLrc = "http://music.baidu.com" + list[0];        //下载百度歌词的第一个

        managerDownloadLrc->get(QNetworkRequest(QUrl(urlDownLrc)));
        connect(managerDownloadLrc, SIGNAL(finished(QNetworkReply*)), this, SLOT(replayLrcFile(QNetworkReply*)));
    }
}

//下载 lrc 文件
void NetWork::replayLrcFile(QNetworkReply *replay)
{
    QString lrcLines = replay->readAll();
    if (lrcLines.isEmpty())
        return;

    QFile file(tr("%1").arg(lrcFileName));
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(lrcLines.toUtf8());
    file.close();
    emit lrcDownloadFinished();

    replay->deleteLater();
}

// 获得在线音乐播放地址
////void NetWork::getMusicUrlFinished(QNetworkReply *replay)
////{
////    // QDomDocument dom(replay->readAll());
////    // qDebug() << dom.elementsByTagName("count").at(0).localName();
////    // qDebug() << dom.elementsByTagName("encode").length();
////
////    QXmlStreamReader reader(replay->readAll());
////    // int musicCount = 0;
////    QString head;
////    QString tail;
////    QStringList musicUrls;
////    while(!reader.atEnd())
////    {
////        reader.readNext();
////        // if (reader.name() == "count"){musicCount = reader.readElementText().toInt();} // API 返回多少首音乐
////        if (reader.name() == "encode")
////        {
////            QString text = reader.readElementText();            // 获得前半部分
////            int index = text.lastIndexOf("/");
////            head = text.left(index + 1);
////        }
////        else if (reader.name() == "decode")
////        {
////            tail = reader.readElementText();                    // 获得后半部分
////            musicUrls.append(head + tail);                      // 组合完整的 URL 添加到列表
////        }
////    }
////    QMap<QString, QStringList> result;
////    result.insert(musicName, musicUrls);
////    emit getMusicUrlsFinished(result);
////
////    replay->deleteLater();
////}


