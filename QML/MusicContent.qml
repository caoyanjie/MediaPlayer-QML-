import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.controls.Private 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

import QtAV 1.7

import QtCPlusPlus.MusicPlaylistModel 1.0
import QtCPlusPlus.Network 1.0
import QtCPlusPlus.LrcViewer 1.0
import QtCPlusPlus.XmlProcess 1.0

Item {
    id: id_musicContent
    property real dp: 1

    function getFileNameFromFileUrl(url) {
        var fen = url.lastIndexOf("/");
        var result = url.substring(fen+1);
        return result;
    }

    function getFileFullPathFromFileUrl(url) {
        return url.toString().substring(8);
    }

    function loadMusicFromMusicListName(musicListName) {
        var musicList = id_xmlProcess.getElementChildrenText("MusicList", "url");
        for (var i=0; i<musicList.length; ++i) {
            id_musicPlaylitModel.addMusic(musicListName, musicList[i]);
        }
        id_musicList.expand(id_musicPlaylitModel.getMusicListIndex(musicListName));
    }

    function writeAddingMusicToConfigFile(filename) {
        id_xmlProcess.writeMusicToConfigFile(filename);
    }

    Network {
        id: id_network
        onLrcDownloadFinished: {
            id_lrcViewer.resolveLrc(getFileFullPathFromFileUrl(id_musicPlayer.source));
        }
    }

    XmlProcess {
        id: id_xmlProcess
        Component.onCompleted: {
            loadMusicFromMusicListName("默认列表");
        }
    }

    LrcViewer {
        id: id_lrcViewer
    }

    AVPlayer {
        id: id_musicPlayer
        autoPlay: true

        onDurationChanged: {
            id_musicBottomToolArea.setMusicTitle(metaData.title);
            id_musicBottomToolArea.setMusicAuthor(metaData.author);
            id_musicBottomToolArea.setMusicDuration(duration);

            var musicFileFullPath = getFileFullPathFromFileUrl(source);
            if (!id_lrcViewer.resolveLrc(musicFileFullPath)) {
                id_musicLyric.setCurrentLrc("正在下载歌词......");
                id_network.downloadLrc(musicFileFullPath);
            }
        }

        onPositionChanged: {
            id_musicBottomToolArea.updateMusicPlayingPosition(position);
            var currentLrc = id_lrcViewer.getCurrentLrc(position);
            if (currentLrc !== '' && currentLrc !== id_musicLyric.getCurrentLrc()) {
                var currentLrcDuration = id_lrcViewer.getCurrentLrcDuration(position);
                var afterLinesLrc = id_lrcViewer.getAfterLinesLrc(position, 5);
                id_musicLyric.setCurrentLrc(currentLrc, currentLrcDuration);
                id_musicLyric.setAfterLrc(afterLinesLrc);
            }
        }

        onStopped: {
            id_musicBottomToolArea.musicPlayingEnd();
        }
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
        width: parent.width * 2 / 7
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
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 10*dp }
                color: "white"
                text: qsTr("播放列表")
            }

            // music add button
            CustomComboBox {
                id: id_addMusic
                dp: id_musicContent.dp
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                width: 70 * dp
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
                            writeAddingMusicToConfigFile(fileUrls[i].toString());
                        }
                        id_musicList.expand(id_musicPlaylitModel.getMusicListIndex("默认列表"));
                    }
                }
            }

            // mysic create list button
            Rectangle {
                id: id_createMusicPlaylist
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 10*dp }
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

    MusicLyric {
        id: id_musicLyric
        anchors { left: id_musicPlaylistUi.right; right: parent.right; top: id_tools.bottom; bottom: id_musicBottomToolArea.top }
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
