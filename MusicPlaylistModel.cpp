#include "MusicPlaylistModel.h"
#include <QDebug>

MusicPlaylistModel::MusicPlaylistModel(QObject *parent) : QStandardItemModel(parent)
{
    m_roleNameMapping[Qt::DisplayRole] = "music_name";

    createMusicListItem(tr("默认列表"));
}

void MusicPlaylistModel::addMusic(const QString &musicListName, const QString &musicFullPath)
{
    auto music = new QStandardItem(musicFullPath);

    QStandardItem *musicList = getMusicListItem(musicListName);
    musicList->appendRow(music);
}

QModelIndex MusicPlaylistModel::getMusicListIndex(const QString &musicListName)
{
    const QStandardItem *item = this->findItems(musicListName).at(0);
    return indexFromItem(item);
}

QHash<int, QByteArray> MusicPlaylistModel::roleNames() const
{
    return m_roleNameMapping;
}

QStandardItem *MusicPlaylistModel::createMusicListItem(const QString &musicListName)
{
    QStandardItem *musicListItem = new QStandardItem(musicListName);
    this->appendRow(musicListItem);
    return musicListItem;
}

QStandardItem *MusicPlaylistModel::getMusicListItem(const QString &musicListName)
{
    QStandardItem *musicListItem;

    auto musicListItems = this->findItems(musicListName);
    if (musicListItems.size() > 0)
    {
        musicListItem = musicListItems.at(0);
    }
    else
    {
        musicListItem = createMusicListItem(musicListName);
    }

    return musicListItem;
}
