import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: id_videoLeftToolArea

    property real dp: 1

    signal sglMouseEntered()
    signal sglMouseLeaved()
    signal sglItemDoubleClicked(url fileUrl)

    function updatePlaylist(fileUrl) {
        var newFilePath = fileUrl.toString().replace(/\\/g, "/");
        // playlist model
        var exists = false;
        for (var index = 0; index < id_playlistModel.count; ++index) {
            var existsFilePath = id_playlistModel.get(index)["mediaName"];
            if (newFilePath === existsFilePath) {
                id_playlistModel.move(index, 0, 1);
                exists = true;
                break;
            }
        }
        if (!exists) {
            id_playlistModel.insert(0, {"mediaName": newFilePath} );
        }

        // playlist history model
        exists = false;
        for (index = 0; index < id_playlistHistoryModel.count; ++index) {
            var existFililePath = id_playlistHistoryModel.get(index)["mediaName"];
            if (newFilePath === existsFilePath) {
                id_playlist.currentIndex = index;
                exists = true;
                break;
            }
        }
        if (!exists) {
            id_playlistHistoryModel.append( {"mediaName": newFilePath} );
            id_playlist.currentIndex = id_playlist.count - 1;
        }
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

        }

        onSglButtonIconHovered: {
            sglMouseEntered();
        }
    }

    ListView {
        id: id_playlist
        anchors { left: parent.left; top: id_playlistTitle.bottom; right: parent.right; bottom: parent.bottom; topMargin: 6*dp }
        model: id_playlistTitle.active === id_playlistTitle.leftActive ? id_playlistModel : id_playlistHistoryModel

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
