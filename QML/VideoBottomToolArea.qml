import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: id_videoBottomToolArea

    property real dp: 1
    readonly property real btnSize: 11 * dp
    readonly property real btnSpacing: 50 * dp
    readonly property real btnTopMargin: 9 * dp
    readonly property color btnColor: Qt.rgba(0.78, 1, 1, 1)
    //readonly property color btnColor: Qt.rgba(0.29, 0.78, 1, 1)
    //readonly property color btnColor: Qt.rgba(0.18, 0.79, 0.97, 1)
    //readonly property color btnColor1: "#2ec9f9"

    signal sglMouseEntered()
    signal sglMouseLeaved()
    signal sglStopVideo()
    signal sglPlayPauseVideo()
    signal sglPreviousVideo()
    signal sglNextVideo()
    signal sglAddVideoPosition()
    signal sglSubstractVideoPosition()
    signal sglSetVideoPosition(real value)
    signal sglAddVideoVolume()
    signal sglSubtractVideoVolume()
    signal sglSetVideoVolume(real volumn)
    signal sglSwitchFullScreen()
    signal sglShowNormalScreen()

    function setVideoTotalTime(ms) {
        id_videoProgress.to = ms;

        var totalSecondses = parseInt(ms / 1000);
        var hours = parseInt(totalSecondses / 3600);
        var mins = parseInt(totalSecondses % 3600 / 60);
        var secondses = parseInt(totalSecondses % 60);

        var hoursStr = hours > 9 ? hours.toString() : "0" + hours.toString();
        var minsStr = mins > 9 ? mins.toString() : "0" + mins.toString();
        var secondsesStr = secondses > 9 ? secondses.toString() : "0" + secondses.toString();

        id_videoTotalTime.text = "/" + hoursStr + ":" + minsStr + ":" + secondsesStr;
    }

    function setVideoProgress(ms) {
        if (ms <= id_videoProgress.to) {
            id_videoProgress.value = ms;
        }
    }

    function videoPlayingEnd() {
        id_videoProgress.value = 0;
        id_videoCurrentTime.text = "00:00:00";
        id_videoTotalTime.text = "/00:00:00";
        id_videoProgress.to = 0;
    }

    color: Qt.rgba(0, 0, 0, 0.55)

    Component.onCompleted: {
        id_videoProgress.sglMouseEntered.connect(sglMouseEntered);
        id_stopVideo.clicked.connect(sglStopVideo);
        id_previousVideo.clicked.connect(sglPreviousVideo);
        id_playPauseVideo.clicked.connect(sglPlayPauseVideo);
        id_nextVideo.clicked.connect(sglNextVideo);
        //id_videoVolume.clicked.connect(sglVideoVolumnChanged)
    }

    MouseArea {
        anchors { fill: parent; leftMargin: 5*dp; rightMargin: 5*dp; bottomMargin: 5*dp }
        hoverEnabled: true
        onEntered: {
            sglMouseEntered();
        }
        onExited: {
            sglMouseLeaved();
        }
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Space:
            sglPlayPauseVideo();
            break;
        case Qt.Key_Left:
            sglSubstractVideoPosition();
            break;
        case Qt.Key_Right:
            sglAddVideoPosition();
            break;
        case Qt.Key_Up:
            sglAddVideoVolume();
            break;
        case Qt.Key_Down:
            sglSubtractVideoVolume();
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            sglSwitchFullScreen();
            break;
        case Qt.Key_Escape:
            sglShowNormalScreen();
            break;
        }
    }

    CustomSlider {
        id: id_videoProgress
        dp: id_videoBottomToolArea.dp
        orientation: Qt.Horizontal
        anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: btnTopMargin; rightMargin: btnTopMargin }
        toolTipVisible: true
        toolTipText: id_videoCurrentTime.text
        backColor: Qt.rgba(0.5, 0.5, 0.5, 1)
        //backColor: Qt.rgba(0.33, 0.33, 0.33, 1)
        //sliderClor: Qt.rgba(0.45, 0.6, 0.1, 1)

        onPositionChanged: {
            if (pressed && (position*to).toFixed() != value) {     // 不能用 !==
                sglSetVideoPosition(parseInt(position*to));
            }
        }

        onSglValueTo: {
            //if (pressed && (position*to).toFixed() != value) {     // 不能用 !==
            //    sglSetVideoPosition(parseInt(position*to));
            //}
            sglSetVideoPosition(value);
        }

        onValueChanged: {
            var totalSecondses = parseInt(value / 1000);
            var hours = parseInt(totalSecondses / 3600);
            var mins = parseInt(totalSecondses % 3600 / 60);
            var secondses = parseInt(totalSecondses % 60);

            var hoursStr = hours > 9 ? hours.toString() : "0" + hours.toString();
            var minsStr = mins > 9 ? mins.toString() : "0" + mins.toString();
            var secondsesStr = secondses > 9 ? secondses.toString() : "0" + secondses.toString();

            id_videoCurrentTime.text = hoursStr + ":" + minsStr + ":" + secondsesStr;
        }
    }

    ToolButton {
        id: id_stopVideo
        anchors { top: id_videoProgress.bottom; right: id_previousVideo.left; topMargin: btnTopMargin; rightMargin: btnSpacing }
        width: btnSize
        height: btnSize
        background: Canvas {
            onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = btnColor;
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.fillRect(0, 0, parent.width, parent.height);
                ctx.stroke();
            }
        }
    }

    ToolButton {
        id: id_previousVideo
        anchors { top: id_videoProgress.bottom; right: id_playPauseVideo.left; topMargin: btnTopMargin; rightMargin: btnSpacing }
        width: btnSize
        height: btnSize
        background: Canvas {
            onPaint: {
                var ctx = getContext("2d");
                ctx.lineWidth = 3 * dp;
                ctx.strokeStyle = btnColor;
                ctx.fillStyle = btnColor;

                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(0, parent.height);
                ctx.stroke();

                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.moveTo(2, parent.height/2);
                ctx.lineTo(parent.width, 0);
                ctx.lineTo(parent.width, parent.height);
                ctx.closePath();
                ctx.fill();
            }
        }
    }

    ToolButton {
        id: id_playPauseVideo
        anchors { top: id_videoProgress.bottom; topMargin: btnTopMargin; horizontalCenter: parent.horizontalCenter }
        width: btnSize
        height: btnSize
        background: Canvas {
            onPaint: {
                const linePadding = 5 * dp;
                var ctx = getContext("2d");
                ctx.strokeStyle = btnColor;
                ctx.lineWidth = 5*dp;
                ctx.beginPath();
                ctx.moveTo(parent.width/2-linePadding, 0);
                ctx.lineTo(parent.width/2-linePadding, parent.height);
                ctx.moveTo(parent.width/2+linePadding, 0);
                ctx.lineTo(parent.width/2+linePadding, parent.height);
                ctx.stroke();
            }
        }
    }

    ToolButton {
        id: id_nextVideo
        anchors { top: id_videoProgress.bottom; left: id_playPauseVideo.right; topMargin: btnTopMargin; leftMargin: btnSpacing }
        width: btnSize
        height: btnSize
        background: Canvas {
            onPaint: {
                var ctx = getContext("2d");
                ctx.lineWidth = 1;
                ctx.strokeStyle = btnColor;
                ctx.fillStyle = btnColor;

                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(0, parent.height);
                ctx.lineTo(parent.width-2, parent.height/2);
//                ctx.moveTo(2, parent.height/2);
//                ctx.lineTo(parent.width, 0);
//                ctx.lineTo(parent.width, parent.height);
                ctx.closePath();
                ctx.fill();

                ctx.lineWidth = 3 * dp;
                ctx.beginPath();
                ctx.moveTo(parent.width-2, 0);
                ctx.lineTo(parent.width-2, parent.height);
                ctx.stroke();
            }
        }
    }

    ToolButton {
        id: id_videoVolume
        anchors { top: id_videoProgress.bottom; left: id_nextVideo.right; topMargin: btnTopMargin; leftMargin: btnSpacing }
        width: btnSize + 2*dp
        height: btnSize
        background: Canvas {
            onPaint: {
                const recS = 4 * dp;
                var ctx = getContext("2d");
                ctx.strokeStyle = btnColor;
                ctx.fillStyle = btnColor;

                ctx.beginPath();
                ctx.moveTo(0, parent.height/2-recS/2);
                ctx.lineTo(recS, parent.height/2-recS/2);
                ctx.lineTo(parent.height-recS/2, 0);
                ctx.lineTo(parent.height-recS/2, parent.height);
                ctx.lineTo(recS, parent.height/2+recS/2);
                ctx.lineTo(0, parent.height/2+recS/2);
                ctx.closePath();
                ctx.fill();

                ctx.lineWidth = 1 * dp;
                ctx.beginPath();
                ctx.arc(parent.width/2, parent.height/2, parent.width/2-ctx.lineWidth/2, -Math.PI/5, Math.PI/5, false);
                ctx.stroke();
            }
        }
    }

    Text {
        id: id_videoCurrentTime
        anchors { verticalCenter: id_videoTotalTime.verticalCenter; right: id_videoTotalTime.left }
        color: "white"
        font { pointSize: 10 }
        text: "00:00:00"
    }

    Text {
        id: id_videoTotalTime
        anchors { top: id_videoProgress.bottom; right: parent.right; topMargin: btnTopMargin; rightMargin: 7*dp }
        color: "white"
        font { pointSize: 10 }
        text: "/00:00:00"
    }

//    ToolButton {
//        id: id_windowMenuMore
//        anchors { top: parent.top; right: id_windowMini.left; margins: 1 }
//        width: id_windowTitle.btnWidth
//        height: id_windowTitle.btnHeight
//        hoverEnabled: true

//        background: Loader {
//            anchors { fill: parent }
//            sourceComponent: com_btnBg
//            property bool hovered: parent.hovered
//        }

//        onHoveredChanged: {
//            sglWindowTitleBtnHoverd(hovered);
//        }

//        Loader {
//            anchors { centerIn: parent }
//            width: parent.height / 2 + 1 * dp
//            height: parent.height / 2
//            property color iconLineColor: parent.hovered ? id_windowTitle.iconHoveredColor : id_windowTitle.iconColor
//            sourceComponent: parent.hovered ? com_windowMenuMoreHover : com_windowMenuMore
//        }

//        Component {
//            id: com_windowMenuMore
//            Loader { sourceComponent: com_windowMenuMorePub }
//        }

//        Component {
//            id: com_windowMenuMoreHover
//            Loader { sourceComponent: com_windowMenuMorePub }
//        }

//        Component {
//            id: com_windowMenuMorePub
//            Canvas {
//                anchors { fill: parent }
//                onPaint: {
//                    var ctx = getContext("2d");
//                    ctx.strokeStyle = parent.parent.iconLineColor
//                    ctx.lineWidth = id_windowTitle.iconLineWidth;

//                    ctx.beginPath();

//                    ctx.moveTo(0, ctx.lineWidth/2);
//                    ctx.lineTo(width, ctx.lineWidth/2);

//                    ctx.moveTo(0, height/2);
//                    ctx.lineTo(width, height/2);

//                    ctx.moveTo(0, height-ctx.lineWidth/2);
//                    ctx.lineTo(width, height-ctx.lineWidth/2);

//                    ctx.stroke();
//                }
//            }
//        }
//    }
}
