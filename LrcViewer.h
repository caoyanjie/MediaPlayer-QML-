#ifndef LRCVIEWER_H
#define LRCVIEWER_H

#include <QObject>
#include <QMap>

class LrcViewer : public QObject
{
     Q_OBJECT
public:
    explicit LrcViewer(QObject *parent = 0);
    Q_INVOKABLE bool resolveLrc(const QString &musicFileFullPath);
    Q_INVOKABLE QString getFrontLinesLrc(int linesNum);
    Q_INVOKABLE QString getAfterLinesLrc(qint64 currentPosition, int linesNum);
    Q_INVOKABLE QString getCurrentLrc(qint64 currentPosition);
    Q_INVOKABLE qint64 getCurrentLrcDuration(qint64 currentPosition);

private:
    QMap<qint64, QString> lrcMap;
};

#endif // LRCVIEWER_H
