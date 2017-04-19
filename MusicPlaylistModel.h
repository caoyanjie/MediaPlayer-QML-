#ifndef MUSICPLAYLISTMODEL_H
#define MUSICPLAYLISTMODEL_H

#include <QStandardItemModel>

class MusicPlaylistModel : public QStandardItemModel
{
    Q_OBJECT
public:
    explicit MusicPlaylistModel(QObject *parent = 0);
    virtual ~MusicPlaylistModel() = default;

    Q_INVOKABLE void addMusic(const QString &musicListName, const QString &musicName);

    QHash<int, QByteArray> roleNames() const override;

private:
    QStandardItem* createMusicListItem(const QString &musicListName);
    QStandardItem* getMusicListItem(const QString &musicListName);

    QHash<int, QByteArray> m_roleNameMapping;
};

#endif // MUSICPLAYLISTMODEL_H
