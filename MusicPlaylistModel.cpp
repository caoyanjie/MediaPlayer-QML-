#include "MusicPlaylistModel.h"

MusicPlaylistModel::MusicPlaylistModel(QObject *parent) : QStandardItemModel(parent)
{
    m_roleNameMapping[Qt::DisplayRole] = "music_name";

    createMusicListItem(tr("默认列表"));
}

void MusicPlaylistModel::addMusic(const QString &musicListName, const QString &musicName)
{
    auto music = new QStandardItem(musicName);

    QStandardItem *musicList = getMusicListItem(musicListName);
    musicList->appendRow(music);
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
