import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls 2.0
import QtQuick.controls.Private 1.0
import QtQuick.Controls.Styles 1.4
import QtMultimedia 5.7
import QtQuick.Dialogs 1.2
import QtCPlusPlus.MusicPlaylistModel 1.0

Item {
    id: id_musicContent
    property real dp: 1

    function getFileNameFromFileUrl(url) {
        var fen = url.lastIndexOf("/");
        var result = url.substring(fen+1);
        return result;
    }

    MediaPlayer {
        id: id_musicPlayer
        autoPlay: true

        onDurationChanged: {
            id_musicBottomToolArea.setMusicTitle(metaData.title);
            id_musicBottomToolArea.setMusicAuthor(metaData.author);
            id_musicBottomToolArea.setMusicDuration(duration);
        }

        onPositionChanged: {
            id_musicBottomToolArea.updateMusicPlayingPosition(position);
        }

        onStopped: {
            id_musicBottomToolArea.musicPlayingEnd();
        }
    }

    Playlist {
        id: id_musicPlaylist
    }

    // 占位
    Item {
        id: id_windowTitle
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 35 * dp;
    }

    // tools
    Rectangle {
        id: id_tools
        anchors { left: parent.left; top: id_windowTitle.bottom; right: parent.right }
        height: 30 * dp
        color: Qt.rgba(0, 0, 0, 0.5)
    }

    // music playlist ui
    Rectangle {
        id: id_musicPlaylistUi
        anchors { left: parent.left; top: id_tools.bottom }
        width: parent.width / 4
        height: parent.height - id_windowTitle.height - id_tools.height - id_musicBottomToolArea.height
        color: "transparent"
        border { color: "white"; width: 1 }

        // music playlist title
        Rectangle {
            id: id_musicPlaylistTitle
            anchors { left: parent.left; top: parent.top; right: parent.right }
            height: 25 * dp
            color: "transparent"

            // music playlist title text
            Text {
                id: id_musicPlaylistTitleText
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 10*dp; rightMargin: 20*dp }
                color: "white"
                text: qsTr("播放列表")
            }

            // music add button
            CustomComboBox {
                id: id_addMusic
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; margins: 20*dp }
                width: 75 * dp
                height: 20 * dp
                model: ["添加音乐", "添加目录"]
                property bool inited: false

                onActivated: {
                    switch (currentIndex) {
                    case 0:
                        id_openFileDialog.visible = true;
                        break;
                    case 1:
                        break;
                    default:
                        break;
                    }
                }

                FileDialog {
                    id: id_openFileDialog
                    selectMultiple: true
                    visible: false
                    onAccepted: {
                        for (var i in fileUrls) {
                            id_musicPlaylitModel.addMusic("默认列表", fileUrls[i].toString());
                        }
                        id_musicList.expand(id_musicPlaylitModel.getMusicListIndex("默认列表"));
                    }
                }
            }

            // mysic create list button
            Rectangle {
                id: id_createMusicPlaylist
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 20*dp; rightMargin: 10*dp }
                width: id_addMusic.width
                height: id_addMusic.height
                color: Qt.rgba(0, 0, 0, 0.5)

                ToolButton {
                    id: id_add_icon
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 5*dp }
                    width: parent.height * 2.5 / 5
                    height: width
                    background: Canvas {
                        anchors { fill: parent }
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.lineWidth = dp;
                            ctx.strokeStyle = "white";

                            ctx.beginPath();
                            ctx.moveTo(0, height/2-ctx.lineWidth/2);
                            ctx.lineTo(width-ctx.lineWidth/2, height/2-ctx.lineWidth/2);
                            ctx.moveTo(width/2-ctx.lineWidth/2, 0);
                            ctx.lineTo(width/2-ctx.lineWidth/2, height-ctx.lineWidth/2);
                            ctx.stroke();
                        }
                    }
                }

                Text {
                    anchors { left: id_add_icon.right; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 5*dp }
                    color: "white"
                    text: qsTr("新建列表")
                }

                MouseArea {
                    anchors { fill: parent }
                    hoverEnabled: true
                    onEntered: {

                    }
                    onExited: {

                    }
                    onClicked: {

                    }
                }
            }
        }

        TreeView {
            id: id_musicList
            anchors { left: parent.left; top: id_musicPlaylistTitle.bottom; right: parent.right; bottom: parent.bottom }
            headerVisible: false
            alternatingRowColors: false
            backgroundVisible: false
            model: id_musicPlaylitModel

            TableViewColumn {
                role: "music_name"
            }

            rowDelegate: Item {
                height: 20 * dp
            }

            itemDelegate: Rectangle {
                color: styleData.pressed ? "red" : (styleData.containsMouse ? "gray" : "transparent")
                height: 30*dp
                Text {
                    anchors { verticalCenter: parent.verticalCenter }
                    color: "white"
                    elide: styleData.elideMode
                    text: getFileNameFromFileUrl(styleData.value)
                }
                MouseArea {
                    anchors { fill: parent }
                    hoverEnabled: true
                    onEntered: {
                        parent.color = Qt.rgba(1, 1, 1, 0.3);
                    }
                    onExited: {
                        parent.color = "transparent";
                    }
                    onPressed: {
                        parent.color = Qt.rgba(1, 1, 1, 0.5);
                    }
                    onReleased: {
                        parent.color = "gray";
                    }
                    onDoubleClicked: {
                        if (styleData.depth === 0) {
                            if (styleData.isExpanded) {
                                id_musicList.collapse(styleData.index);
                            }
                            else {
                                id_musicList.expand(styleData.index);
                            }
                            return;
                        }

                        id_musicPlayer.source = styleData.value;
                        console.log("row: " + styleData.row);
                        console.log("index: " + styleData.index);
                        console.log("depth: " + styleData.depth);
                    }
                }
            }

            //selection: ItemSelectionModel {
            //    model: id_musicPlaylitModel
            //}
        }

        MusicPlaylistModel {
            id: id_musicPlaylitModel
        }
    }

    MusicBottomToolArea {
        id: id_musicBottomToolArea
        dp: id_musicContent.dp
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 70 * dp

        onSglSetMusicPosition: {
            if (position !== id_musicPlayer.position) {
                id_musicPlayer.seek(position);
            }
        }
    }
}
