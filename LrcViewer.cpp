#include "LrcViewer.h"
#include <QFileInfo>
#include <QDebug>

LrcViewer::LrcViewer(QObject *parent) : QObject(parent)
{
}

bool LrcViewer::resolveLrc(const QString &musicFileFullPath)
{
    lrcMap.clear();

    if(musicFileFullPath.isEmpty())
    {
        return false;
    }

    QString fileFullPath = musicFileFullPath;
    QString lrcFileFullPath = fileFullPath.remove(fileFullPath.right(3)) + "lrc";

    if(!QFileInfo(lrcFileFullPath).exists())
    {
        return false;
    }

    QFile file(lrcFileFullPath);
    if (! file.open(QIODevice::ReadOnly))
    {
        return false;
    }

    QString allText = QString(file.readAll());
    file.close();

    QStringList lines = allText.split("\n");
    QRegExp rx("\\[\\d{2}:\\d{2}\\.\\d{2}\\]");
    foreach(QString oneLine, lines)
    {
        QString temp = oneLine;
        temp.replace(rx, "");
        int pos = rx.indexIn(oneLine, 0);
        while (pos != -1)
        {
            QString cap = rx.cap(0);
            QRegExp regexp;
            regexp.setPattern("\\d{2}(?=:)");
            regexp.indexIn(cap);
            int minute = regexp.cap(0).toInt();
            regexp.setPattern("\\d{2}(?=\\.)");
            regexp.indexIn(cap);
            int second = regexp.cap(0).toInt();
            regexp.setPattern("\\d{2}(?=\\])");
            regexp.indexIn(cap);
            int millisecond = regexp.cap(0).toInt();
            qint64 totalTime = minute * 60000 + second * 1000 + millisecond * 10;

            lrcMap.insert(totalTime, temp);
            pos += rx.matchedLength();
            pos = rx.indexIn(oneLine, pos);
        }
    }

    if (lrcMap.isEmpty())
    {
        return false;
    }
    return true;
}

QString LrcViewer::getFrontLinesLrc(int linesNum)
{
    QString linesLrc;
    int i = 0;
    foreach (qint64 time, lrcMap.keys())
    {
        linesLrc += lrcMap.value(time) + "\n";
        i ++;
        if (i > linesNum)
        {
            break;
        }
    }
    return linesLrc;
}

QString LrcViewer::getCurrentLrc(qint64 currentPosition)
{
    if (lrcMap.isEmpty())
    {
        return QString("");
    }

    qint64 previous = 0;
    qint64 later = 0;
    foreach (qint64 value, lrcMap.keys())
    {
        if (value <= currentPosition)
        {
            previous = value;
        }
        else
        {
            later = value;
            break;
        }
    }

    return lrcMap.value(previous);
}

qint64 LrcViewer::getCurrentLrcDuration(qint64 currentPosition)
{
    if (lrcMap.isEmpty())
    {
        return 0;
    }

    qint64 previous = 0;
    qint64 later = 0;
    foreach (qint64 value, lrcMap.keys())
    {
        if (value <= currentPosition)
        {
            previous = value;
        }
        else
        {
            later = value;
            break;
        }
    }
    return later - previous;
}

QString LrcViewer::getAfterLinesLrc(qint64 currentPosition, int linesNum)
{
    if (lrcMap.isEmpty())
    {
        return QString("");
    }

    QString afterLinesLrc;
    int i = -1;
    foreach (qint64 value, lrcMap.keys())
    {
        if (value >= currentPosition)
        {
            i += 1;
        }

        if (i >= 0)
        {
            afterLinesLrc += lrcMap.value(value) + "\n";
        }
        if (i > linesNum)
        {
            break;
        }
    }

    return afterLinesLrc;
}
