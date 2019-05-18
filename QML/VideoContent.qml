import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtAV 1.7         // third party
import QtCPlusPlus.Application 1.0

Rectangle {
    id: id_windowContent
    color: "transparent"
    property real dp: 1

    signal sglSetWindowTitleVisible(bool visible)
    signal sglSwitchFullScreen()
    signal sglShowNormalScreen()
    signal sglVideoPlaying()
    signal sglVideoStopped()

    function setLeftToolAreaVisible(visible) {
        if (visible) {
            if (id_leftToolArea.state === "showLeftToolArea") {
                return;
            }
            id_leftToolArea.state = "showLeftToolArea";
            id_bottomToolArea.state = "showBottomToolArea";
            id_hideTimer.restart();
        }
        else {
            id_leftToolArea.state = "hideLeftToolArea";
            id_bottomToolArea.state = "hideBottomToolArea";
        }

        sglSetWindowTitleVisible(visible);
    }

    function showLeftToolArea() {
        setLeftToolAreaVisible(true);
    }

    function setLeftToolAreaAlwaysVisible(always) {
        if (always) {
            id_hideTimer.stop();
        }
        else {
            id_hideTimer.start();
        }
    }

    function playMedia(fileUrl) {
        if (fileUrl === id_mediaPlayer.source) {
            id_mediaPlayer.seek(100);		// 不能 seek(0)，不会暂停到 0 处
        }
        else {
            id_mediaPlayer.source = fileUrl;
        }
        id_leftToolArea.updatePlaylist(fileUrl);
        id_bottomToolArea.forceActiveFocus();
    }

    function setVideoPlayingRate(rate) {
        id_mediaPlayer.playbackRate = rate;
    }

    Component.onCompleted: {
        id_bottomToolArea.sglSwitchFullScreen.connect(sglSwitchFullScreen);
        id_bottomToolArea.sglShowNormalScreen.connect(sglShowNormalScreen);

        var commandArg = id_application.getFileUrl();
        if (commandArg != "") {				// 不能用 !==
            playMedia(commandArg);
        }
    }

    Application {
        id: id_application
    }

    AVPlayer {
        id: id_mediaPlayer
        autoPlay: true
        volume: 0.5

        onPlaying: {
            id_videoOutput.visible = true;
            sglVideoPlaying();
            id_bottomToolArea.setVideoPlayingState();
        }

        onPaused: {
            id_bottomToolArea.setVideoPauseState();
        }

        onStopped: {
            id_videoOutput.visible = false;
            id_bottomToolArea.videoPlayingEnd();
            id_bottomToolArea.setVideoPauseState();
        }

        onPositionChanged: {
            id_bottomToolArea.setVideoProgress(position);
            if (duration-position < 500) {
                if (id_leftToolArea.isLastVideo(source.toString())) {
                    sglVideoStopped();
                }
                else {
                    id_leftToolArea.playNextVideo(source.toString());
                }
            }
        }

        onError: {
            switch (error) {
            case AVPlayer.NoError:
                id_errText.text = ''
                break;
            case AVPlayer.ResourceError:
                console.log('ResourceError');
                break;
            case AVPlayer.FormatError:
                id_errText.text = '视频格式错误，无法渲染！@_@!';
                break;
            case AVPlayer.NetworkError:
                console.log('网络错误！');
                break;
            case AVPlayer.AccessDenied:
                console.log('AccessDenied');
                break;
            case AVPlayer.ServiceMissing:
                console.log('ServiceMissing');
                break;
            }
        }
    }

    VideoOutput {
        id: id_videoOutput
        anchors { fill: parent }
        source: id_mediaPlayer
        visible: false

        // 触屏手势触摸事件，左右划 快退快进
        MultiPointTouchArea {
            id: id_touchArea
            anchors { fill: parent; margins: 100 }
            mouseEnabled: false
            property real videoStartPosition: 0
            property int startX: 0
            property int clickedTimes: 0
            //touchPoints: [
            //    TouchPoint { id: point1 },
            //    TouchPoint { id: point2 }
            //]

            onPressed: {
                startX = touchPoints[0].x;
            }

            onTouchUpdated: {
                if (touchPoints[0] === undefined) {
                    return;
                }

                var currentX = touchPoints[0].x;

                // 没有滑动，只是点击
                var totalOffset = currentX - startX;
                if (Math.abs(totalOffset) < 5) {
                    return;
                }

                // 第一次 onTouchUpdate,之所以不写在 onPressed 里是因为考虑到点一下就松开而不是滑动的那种情况
                if (!id_videoPreview.visible) {
                    id_videoPreview.anchors.horizontalCenter = id_videoOutput.horizontalCenter;
                    id_videoPreview.anchors.bottom = undefined;
                    id_videoPreview.anchors.top = id_videoOutput.top;
                    id_videoPreview.visible = true;
                    videoStartPosition = id_mediaPlayer.position;
                }

                // 设置视频预览窗口的视频进度
                var videoTargetPosition = videoStartPosition + totalOffset * 20;
                id_videoPreview.timestamp = videoTargetPosition;
            }

            onReleased: {
                var endX = touchPoints[0].x;
                var offset = endX - startX;

                // 没有滑动，只是点击
                if (offset < 5 && offset > -5) {
                    clickedTimes += 1;
                    id_timerDoubleClick.start();

                    // 双击（在一定时间内连续点击2次）
                    if (clickedTimes === 2) {
                        sglSwitchFullScreen();
                        clickedTimes = 0;
                    }
                    return;
                }

                // 手指滑动结束，视频跳到快进/快退位置，隐藏视频预览小窗口
                id_mediaPlayer.seek(id_videoPreview.timestamp);
                id_videoPreview.visible = false;
            }

            Timer {
                id: id_timerDoubleClick
                repeat: false
                interval: 500
                triggeredOnStart: false
                onTriggered: {
                    id_touchArea.clickedTimes = 0;
                }
            }
        }

        onSourceRectChanged: {
            if (sourceRect.width <=0 || sourceRect.height <= 0) {
                return;
            }

            // resize window
            if (id_bottomToolArea.isWindowAutoResize()) {
                var desWidth = sourceRect.width * id_windowFrame.dp * 0.8;
                var desHeight = sourceRect.height * id_windowFrame.dp * 0.8;

                if (desWidth <= Screen.width && desHeight <= Screen.height) {
                    id_rootWindow.width = desWidth;
                    id_rootWindow.height = desHeight;
                }
                else {
                    var ratio = sourceRect.width / sourceRect.height;
                    if (ratio > 1) {
                        id_rootWindow.width = desWidth > Screen.width ? Screen.width : desWidth;
                        id_rootWindow.height = id_rootWindow.width / ratio;

                    }
                    else {
                        id_rootWindow.height = desHeight > Screen.height ? Screen.height : desHeight;
                        id_rootWindow.width = id_rootWindow.height * ratio;
                    }
                }

                // move window
                id_rootWindow.x = (Screen.width-id_rootWindow.width)/2;
                id_rootWindow.y = (Screen.height-id_rootWindow.height)/2;
            }

            // set video total time
            id_bottomToolArea.setVideoTotalTime(source.metaData.duration);

            // video information
            console.log(id_mediaPlayer.metaData.audioBitRate);
            console.log(id_mediaPlayer.metaData.audioCodec);
            console.log(id_mediaPlayer.metaData.channelCount);
            console.log(id_mediaPlayer.metaData.mediaType);
            //console.log(id_mediaPlayer.metaData.albumArtist);		// undefined
            //console.log(id_mediaPlayer.metaData.albumTitle);		// undefined
            //console.log(id_mediaPlayer.metaData.author);
            //console.log(id_mediaPlayer.metaData.averageLevel);
            //console.log(id_mediaPlayer.metaData.category);
        }
    }

    VideoPreview {
        id: id_videoPreview
        width: 256 * dp
        height: 192 * dp
        file: id_mediaPlayer.source
        visible: false
        property int lastTime: 0

        onTimestampChanged: {
            // 视频预览窗口显示当前快进到的时间
            var totalSecondses = parseInt(timestamp / 1000);
            var hours = parseInt(totalSecondses / 3600);
            var mins = parseInt(totalSecondses % 3600 / 60);
            var secondses = parseInt(totalSecondses % 60);

            var hoursStr = hours > 9 ? hours.toString() : "0" + hours.toString();
            var minsStr = mins > 9 ? mins.toString() : "0" + mins.toString();
            var secondsesStr = secondses > 9 ? secondses.toString() : "0" + secondses.toString();

            id_videoPreviewTime.text = hoursStr + ":" + minsStr + ":" + secondsesStr;

            // 更新太快，视频预览窗口是黑的，qtav库的问题
            if (lastTime-timestamp < 200) {
                return;
            }

            lastTime = timestamp;
        }

        Text {
            id: id_videoPreviewTime
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
            color: "white"
        }
    }

    // hide error tip
    Text {
        id: id_errText
        anchors { horizontalCenter: parent.horizontalCenter; bottom: id_videoOpenerImg.top }
        font { pointSize: 13 }
        color: 'red'

        Rectangle {
            anchors { centerIn: parent }
            width: parent.width ? parent.width + 20*dp : 0
            height: parent.height ? parent.height + 8*dp : 0
            color: 'transparent'
            radius: height / 2
            border { color: Qt.rgba(1, 0, 0, 0.5); width: 2*dp }
        }
    }

    Image {
        id: id_videoOpenerImg
        anchors { centerIn: parent }
        width: 170 * dp
        height: width
        source: "/Images/videoOpener.png"
        visible: !id_videoOutput.visible // !id_mediaPlayer.playbackState || id_mediaPlayer.playbackState === AVPlayer.StoppedState

        Button {
            id: id_playlistChoose
            //anchors { top: id_videoOpenerImg.bottom; horizontalCenter: parent.horizontalCenter }
            x: 100 * dp
            y: 120 * dp
            width: 80 * dp
            height: 20 * dp

            background: Rectangle {
                color: Qt.rgba(0, 0, 0, 0.5)
                radius: 50
            }

            contentItem: Text {
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                color: "#58a0a8"
                font { pointSize: 11 }
                text: qsTr("放入视频")
            }
        }

        MouseArea {
            anchors { fill: parent }
            onClicked: {
                id_fileDialog.visible = true;
            }
        }

        FileDialog {
            id: id_fileDialog
            folder: "file:///E:/电影"

            onAccepted: {
                playMedia(fileUrl);
            }
        }
    }

    VideoLeftToolArea {
        id: id_leftToolArea
        dp: id_windowContent.dp
        width: parent.width / 4
        height: parent.height - id_bottomToolArea.height - 30 * dp
        y: 30 * dp
        state: "hideLeftToolArea"

        states: [
            State {
                name: "showLeftToolArea"
                PropertyChanges {
                    target: id_leftToolArea
                    x: 1
                }
            },
            State {
                name: "hideLeftToolArea"
                PropertyChanges {
                    target: id_leftToolArea
                    x: -width-1
                }
            }
        ]

        transitions: Transition {
            NumberAnimation {
                properties: "x"
                duration: 300
            }
        }

        onSglMouseEntered: {
            setLeftToolAreaAlwaysVisible(true);
        }

        onSglMouseLeaved: {
            setLeftToolAreaAlwaysVisible(false);
        }

        onSglItemDoubleClicked: {
            playMedia(fileUrl);
        }
    }

    VideoBottomToolArea {
        id: id_bottomToolArea
        dp: id_windowContent.dp
        width: parent.width - 2
        height: 50 * dp;
        x: 1
        state: "hideBottomToolArea"
        focus: true
        property real lastTime: 0

        states: [
            State {
                name: "showBottomToolArea"
                PropertyChanges {
                    target: id_bottomToolArea
                    y: parent.height - height - 1
                }
            },
            State {
                name: "hideBottomToolArea"
                PropertyChanges {
                    target: id_bottomToolArea
                    y: parent.height + 1
                }
            }
        ]

        transitions: Transition {
            NumberAnimation {
                properties: "y"
                duration: 300
            }
        }

        onSglMouseEntered: {
            setLeftToolAreaAlwaysVisible(true);
        }

        onSglMouseLeaved: {
            setLeftToolAreaAlwaysVisible(false);
        }

        onSglMouseEnterSlider: {
            id_videoPreview.anchors.top = undefined;
            id_videoPreview.anchors.horizontalCenter = undefined;
            id_videoPreview.anchors.bottom = id_bottomToolArea.top;
        }

        onSglMouseLeaveSlider: {
            id_videoPreview.visible = false;
        }

        onSglMouseXOnSliderChanged: {
            if (AVPlayer.PlayingState != id_mediaPlayer.playbackState) {
                return;
            }

            var leftPos = x - id_videoPreview.width / 2;
            if (leftPos < 0) {
                leftPos = 0;
            }
            else if (leftPos + id_videoPreview.width > id_videoOutput.width) {
                leftPos = id_videoOutput - id_videoPreview.width;
            }

            id_videoPreview.x = leftPos;
            var date = new Date();
            var currentTime = date.getTime();
            if (currentTime - lastTime < 300) {
                return;
            }
            id_videoPreview.timestamp = videoPosition;
            lastTime = currentTime;

            id_videoPreview.visible = true;
        }

        onSglSetVideoPosition: {
            if (value !== id_mediaPlayer.position) {
                id_mediaPlayer.seek(value);
            }
        }

        onSglStopVideo: {
            id_mediaPlayer.stop();
            id_windowContent.sglVideoStopped();
        }

        onSglPreviousVideo: {

        }

        onSglPlayPauseVideo: {
            if (id_mediaPlayer.playbackState === AVPlayer.PlayingState) {
                id_mediaPlayer.pause();
            }
            else {
                id_mediaPlayer.play();
            }
        }

        onSglAddVideoPosition: {
            id_mediaPlayer.seek(id_mediaPlayer.position + 5000);
        }

        onSglSubstractVideoPosition: {
            id_mediaPlayer.seek(id_mediaPlayer.position - 3000);
        }

        onSglAddVideoVolume: {
            id_mediaPlayer.volume += 0.1
        }

        onSglSubtractVideoVolume: {
            id_mediaPlayer.volume -= 0.1
        }
    }

    Timer {
        id: id_hideTimer
        interval: 2000
        onTriggered: {
            setLeftToolAreaVisible(false);
        }
    }
}
