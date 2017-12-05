import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: id_musicBottomToolArea
    property real dp: 1
    readonly property real btnSize: 20 * dp
    readonly property color btnColor: "white"
    color: Qt.rgba(0, 0, 0, 0.5)

    signal sglSetMusicPosition(real position)

    function setMusicTitle(musicTitle) {
        id_musicName.text = qsTr("歌曲：") + musicTitle;
    }

    function setMusicAuthor(musicAuthor) {
        id_musicAuthor.text = qsTr("歌手：") + musicAuthor;
    }

    function setMusicDuration(musicDuration) {
        id_musicProgress.to = musicDuration;

        var totalSecondses = parseInt(musicDuration / 1000);
        var mins = parseInt(totalSecondses / 60);
        var secondses = parseInt(totalSecondses % 60);

        var minsStr = mins > 9 ? mins.toString() : "0" + mins.toString();
        var secondsesStr = secondses > 9 ? secondses.toString() : "0" + secondses.toString();

        id_musicTotalTime.text = "/" + minsStr + ":" + secondsesStr;
    }

    function updateMusicPlayingPosition(currentPosition) {
        if (currentPosition <= id_musicProgress.to) {
            id_musicProgress.value = currentPosition;
        }
    }

    function musicPlayingEnd() {
        id_musicName.text = qsTr("歌曲：");
        id_musicAuthor.text = qsTr("歌手：");

        id_musicProgress.value = 0;
        id_musicCurrentTime.text = "00:00";
        id_musicTotalTime.text = "/00:00";
        id_musicProgress.to = 0;
    }

    ToolButton {
        id: id_previusMusic
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 20 * dp }
        width: btnSize
        height: width
        background: Canvas {
            anchors { fill: parent }
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = btnColor;
                ctx.fillStyle = btnColor;
                ctx.width = 2 * dp

                ctx.beginPath();

                ctx.moveTo(2*dp, 0);
                ctx.lineTo(2*dp, height);
                ctx.stroke();

                ctx.moveTo(2*dp, height/2);
                ctx.lineTo(width-2*dp, 0);
                ctx.lineTo(width-2*dp, height);
                ctx.closePath();

                ctx.fill();
            }
        }
    }

    ToolButton {
        id: id_playPause
        anchors { left: id_previusMusic.right; verticalCenter: parent.verticalCenter; leftMargin: 30*dp }
        width: btnSize
        height: width
        background: Canvas {
            anchors { fill: parent }
            onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = btnColor;

                ctx.beginPath();
                ctx.moveTo(2*dp, 0);
                ctx.lineTo(width-2*dp, height/2);
                ctx.lineTo(2*dp, height);
                ctx.closePath();
                ctx.fill();
            }
        }
    }

    ToolButton {
        id: id_nextMusic
        anchors { left: id_playPause.right; verticalCenter: parent.verticalCenter; leftMargin: id_playPause.anchors.leftMargin }
        width: btnSize
        height: width
        background: Canvas {
            anchors { fill: parent }
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = btnColor;
                ctx.fillStyle = btnColor;

                ctx.beginPath();

                ctx.moveTo(2*dp, 0);
                ctx.lineTo(2*dp, height);
                ctx.lineTo(width-2*dp, height/2);
                ctx.closePath();
                ctx.fill();

                ctx.moveTo(width-2*dp, 0);
                ctx.lineTo(width-2*dp, height);
                ctx.stroke();
            }
        }
    }

    Rectangle {
        id: id_musicPlayingProgress
        anchors { left: id_nextMusic.left; verticalCenter: parent.verticalCenter; right: id_checkMusicLrc.left; leftMargin: 50*dp; rightMargin: 30*dp }
        height: parent.height - 15*dp
        color: Qt.rgba(0, 0, 0, 0.5)
        radius: 5*dp

        Image {
            id: id_cdImg
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: 5*dp }
            width: parent.height-anchors.margins*2;
            height: width
            source: "/Images/cd.png"

            Timer {
                id: id_cdTimer
                interval: 100
                repeat: true
                running: true
                onTriggered: {
                    parent.rotation += 10;
                }
            }
        }

        Text {
            id: id_musicName
            anchors { left: id_cdImg.right; top: parent.top; margins: 5*dp }
            color: "white"
            text: qsTr("歌曲：")
        }

        Text {
            id: id_musicAuthor
            anchors { left: id_cdImg.right; top: id_musicName.bottom; margins: id_musicName.anchors.margins }
            color: "white"
            text: qsTr("歌手：")
        }

        CustomSlider {
            id: id_musicProgress
            anchors { left: id_cdImg.right; top: id_musicAuthor.bottom; right: parent.right }
            height: 16 * dp
            toolTipVisible: true
            toolTipText: id_musicCurrentTime.text

            onValueChanged: {
                var totalSecondses = parseInt(value / 1000);
                var mins = parseInt(totalSecondses  / 60);
                var secondses = parseInt(totalSecondses % 60);

                var minsStr = mins > 9 ? mins.toString() : "0" + mins.toString();
                var secondsesStr = secondses > 9 ? secondses.toString() : "0" + secondses.toString();

                id_musicCurrentTime.text = minsStr + ":" + secondsesStr;
            }

            onPositionChanged: {
                if (pressed && (position*to).toFixed() != value) {     // 不能用 !==
                    sglSetMusicPosition(parseInt(position*to));
                }
            }

            onSglValueTo: {
                sglSetMusicPosition(value);
            }
        }

        Text {
            id: id_musicCurrentTime
            anchors { right: id_musicTotalTime.left; bottom: id_musicProgress.top }
            color: "white"
            text: qsTr("00:00")
        }

        Text {
            id: id_musicTotalTime
            anchors { right: parent.right; bottom: id_musicProgress.top; rightMargin: 5*dp }
            color: "white"
            text: qsTr("/00:00");
        }
    }

    CustomCheckBox {
        id: id_checkMusicLrc
        dp: id_musicBottomToolArea.dp
        anchors { verticalCenter: parent.verticalCenter; right: id_musicVolume.left; margins: 30*dp }
        text: qsTr("歌词滚动")
        textColor: "white"
        checked: true
    }

    Image {
        id: id_musicVolume
        anchors { verticalCenter: parent.verticalCenter; right: id_musicPlayingMode.left; margins: 30*dp }
        width: 20 * dp
        height: width
        source: "/Images/volume.png"
    }

    Image {
        id: id_musicPlayingMode
        anchors { verticalCenter: parent.verticalCenter; right: parent.right; margins: 30*dp }
        width: 20 * dp
        height: width
        source: "/Images/playMode_loop.png"
    }
}
