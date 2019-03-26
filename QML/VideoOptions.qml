import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: id_videoOptions

    // variable need overwrite
    property var handleId: null

    // const variable
    property real dp: 1

    // define signals
    signal sglChangeVideoRate(int rate)

    width: 230 * dp
    height: width
    color: Qt.rgba(0, 0, 0, 0.4)

    Text {
        id: id_videoRateTitle
        anchors { left: parent.left; top: parent.top; margins: 10 * dp }
        text: qsTr("播放速度: ")
        color: "white"
    }

    SpinBox {
        id: id_videoRateValue
        anchors { left: id_videoRateTitle.right; verticalCenter: id_videoRateTitle.verticalCenter }
        editable: true
        width: 100 * dp
        height: 20 * dp
        value: 1

        onValueChanged: {
            sglChangeVideoRate(value);
        }
    }

    Text {
        id: id_videoRateTitle1
        anchors { left: id_videoRateValue.right; verticalCenter: id_videoRateValue.verticalCenter }
        text: qsTr(" 倍速播放")
        color: "white"
    }
}
