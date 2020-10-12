import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

Rectangle {
    id: id_videoLeftToolArea

    property real dp: 1

    signal sglMouseEntered()
    signal sglMouseLeaved()
    signal sglItemDoubleClicked(url fileUrl)

    // 若播放列表中已存在则返回index，否则返回-1
    function isPlaylistExists(fileUrl/*type: string*/) {
        for (var index = 0; index < id_playlistModel.count; ++index) {
            var existsFilePath = id_playlistModel.get(index)["mediaName"];
            if (fileUrl === existsFilePath) {
                return index;
            }
        }
        return -1;
    }

    // 若历史播放列表中已存在则返回index，否则返回-1
    function isPlaylistHistoryExists(fileUrl/*type: string*/) {
        for (var index = 0; index < id_playlistHistoryModel.count; ++index) {
            var existsFilePath = id_playlistHistoryModel.get(index)["mediaName"];
            if (fileUrl === existsFilePath) {
                return index;
            }
        }
        return -1;
    }

    // 是否是播放列表中的最后一个视频
    function isLastVideo(fileUrl/*type: string*/) {
        return id_playlistModel.get(id_playlistModel.count-1)["mediaName"] === fileUrl;
    }

    // 播放 播放列表中的下一个视频
    function playNextVideo(currentFileUrl/*type: string*/) {
        for (var index = 0; index < id_playlistModel.count; ++index) {
            var existsFilePath = id_playlistModel.get(index)["mediaName"];
            if (currentFileUrl === existsFilePath && index+1 < id_playlistModel.count) {
                sglItemDoubleClicked(id_playlistModel.get(index+1)["mediaName"]);
                return;
            }
        }
    }

    // 向播放队列中添加视频
    function addMediaToPlaylist(fileUrl/*type: string*/) {
        var newFilePath = fileUrl.toString().replace(/\\/g, "/");
        var index = isPlaylistExists(newFilePath);
        if (index > -1) {
            id_playlist.currentIndex = index;
        }
        else if (index === -1) {
            id_playlistModel.append( {"mediaName": newFilePath} );
            id_playlist.currentIndex = id_playlist.count - 1;
        }
    }

    function addMediaToPlaylistHistory(fileUrl/*type: string*/) {
        var newFilePath = fileUrl.toString().replace(/\\/g, "/");
        var index = isPlaylistHistoryExists(newFilePath);
        if (index > -1) {
            id_playlistHistoryModel.move(index, 0, 1);
        }
        else if (index === -1) {
            id_playlistHistoryModel.insert(0, {"mediaName": newFilePath});
        }
    }

    function updatePlaylist(fileUrl/*type: string*/) {
        // playlist model
        addMediaToPlaylist(fileUrl);

        // playlist history model
        addMediaToPlaylistHistory(fileUrl);
    }

    //
    color: Qt.rgba(0, 0, 0, 0.55)

    MouseArea {
        anchors { fill: parent }
        hoverEnabled: true
        onEntered: {
            sglMouseEntered();
        }
        onExited: {
            sglMouseLeaved();
        }
    }

    CustomSwitchButton {
        id: id_playlistTitle
        anchors { left: parent.left; top: parent.top; right: parent.right; bottomMargin: 10; margins: 5 * dp }
        dp: id_videoLeftToolArea.dp
        leftText: qsTr("播放历史")
        rightText: qsTr("播放列表")
        backgroundColor: Qt.rgba(0.5, 0.5, 0.5, 0.5)
        btnColor: Qt.rgba(0.78, 1, 1, 0.5)
        btnRadius: 2 * dp
        bottomArrow: true
        btnIcon: true

        onSglLeftBtnActived: {
			
        }

        onSglRightBtnActived: {

        }

        onSglLeftButtonIconClicked: {

        }

        onSglRightButtonIconClicked: {
            id_addVideo.visible = true;
        }

        onSglMouseEntered: {
            id_videoLeftToolArea.sglMouseEntered();
        }

        onSglButtonIconHovered: {
            id_videoLeftToolArea.sglMouseEntered();
        }

        FileDialog {
            id: id_addVideo
            selectMultiple: true
            nameFilters: [ "Video files (*.avi *.mp4 *.rmvb *.rm *.flv *.wmv *.asf *.mov *.mpg)", "All files (*)" ]
            onAccepted: {
                for (var index in fileUrls) {
                    addMediaToPlaylist(fileUrls[index]);
                }
            }
        }
    }

    ListView {
        id: id_playlist
        anchors { left: parent.left; top: id_playlistTitle.bottom; right: parent.right; bottom: parent.bottom; topMargin: 6*dp }
        model: id_playlistTitle.active === id_playlistTitle.leftActive ? id_playlistHistoryModel : id_playlistModel

        ScrollIndicator.vertical: ScrollIndicator {

        }

        delegate: ItemDelegate {
            id: control
            width: parent.width
            //highlighted: ListView.isCurrentItem
            hoverEnabled: true
            text: getFileNameFromFileUrl(mediaName);
            property url fileUrl: mediaName

            function getFileNameFromFileUrl(url) {
                var fen = url.lastIndexOf("/");
                var result = url.substring(fen+1);
                return result;
            }

            contentItem: Text {
                color: "white"
                text: parent.text
                elide: Text.ElideRight

                ToolTip {
                    visible: parent.parent.hovered && parent.truncated
                    text: parent.text
                }
            }

            background: Rectangle {
                color: parent.down ? "gray" : ((parent.hovered || id_playlist.currentItem===parent) ? Qt.rgba(1,1,1,0.2) : "transparent")
            }

            onHoveredChanged: {
                if (hovered) {
                    sglMouseEntered();
                }
                else {
                    sglMouseLeaved();
                }
            }

            onClicked: {
                id_playlist.currentIndex = index;
            }

            onDoubleClicked: {
                sglItemDoubleClicked(fileUrl);
            }
        }
    }

    ListModel {
        id: id_playlistModel
    }

    ListModel {
        id: id_playlistHistoryModel
    }
}
