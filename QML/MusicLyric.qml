import QtQuick 2.7
import QtGraphicalEffects 1.0

Item {
    property real dp: 1
    readonly property color textColor: "white"
    readonly property real maskOneStepWidth: 10
    readonly property real normalFontSize: 16
    readonly property real biggerFontSize: 18

    function getCurrentLrc() {
        return id_currentLrc.text;
    }

    function setCurrentLrc(currentLrc, currentLrcDuration) {
        id_maskTiemr.stop();
        id_previousLrc.text += (id_currentLrc.text == "正在下载歌词......" ? "" : id_currentLrc.text + "\n");
        id_currentLrc.text = currentLrc;
        id_maskTiemr.interval = currentLrcDuration * maskOneStepWidth / id_currentLrcMask.contentWidth;
        id_maskTiemr.start();
    }

    function setAfterLrc(afterLrc) {
        id_afterLrc.text = afterLrc;
    }

    // 之前的歌词
    Text {
        id: id_previousLrc
        anchors { top: parent.top; bottom: id_currentLrc.top; horizontalCenter: parent.horizontalCenter; topMargin: 10*dp }
        color: textColor
        font { pointSize: normalFontSize }
        horizontalAlignment: Qt.AlignCenter
        verticalAlignment: Qt.AlignBottom
        bottomPadding: 0
        padding: 0
        clip: true
    }

    // 当前歌词
    Text {
        id: id_currentLrc
        anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
        color: "red"
        font { pointSize: biggerFontSize }
    }

    // 歌词遮罩
    Text {
        id: id_currentLrcMask
        anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
        color: "purple"
        font { pointSize: biggerFontSize }
        text: id_currentLrc.text
        visible: false
    }

    // 后续歌词
    Text {
        id: id_afterLrc
        anchors { top: id_currentLrc.bottom; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 15*dp }
        color: textColor
        font { pointSize: normalFontSize }
        horizontalAlignment: Qt.AlignCenter
    }

    // 透明遮罩
    OpacityMask {
        anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
        width: id_currentLrcMask.contentWidth;
        height: id_currentLrcMask.contentHeight
        source: id_currentLrcMask
        maskSource: id_lineGradient
    }

    // 线性渐变
    LinearGradient {
        id: id_lineGradient
        width: id_currentLrcMask.contentWidth
        height: id_currentLrcMask.contentHeight
        visible: false
        start: Qt.point(0, height/2)
        end: Qt.point(0.1, height/2)
        gradient: Gradient {
            GradientStop { position: 0.99; color: Qt.rgba(1, 1, 1, 1) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }
        Timer {
            id: id_maskTiemr
            repeat: true
            onTriggered: {
                id_lineGradient.end = Qt.point(id_lineGradient.end.x+maskOneStepWidth, id_lineGradient.height/2);
                if (id_lineGradient.end.x > id_lineGradient.width) {
                    stop();
                    id_lineGradient.end = Qt.point(0.1, height/2);
                }
            }
        }
    }
}
