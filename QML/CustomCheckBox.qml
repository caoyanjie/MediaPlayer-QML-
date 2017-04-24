import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0

CheckBox {
    id: id_customCheckBox
    property real           dpScale:    1.5
    readonly property real  dp:         Math.max(Screen.pixelDensity * 25.4 / 160 * dpScale, 1)
    property color          textColor:  "black"

    indicator: Rectangle {
        id: id_indicator
        implicitWidth: 11 * id_customCheckBox.dp
        implicitHeight: implicitWidth
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: 3 * id_customCheckBox.dp }

        Canvas {
            anchors { fill: parent }
            visible: parent.parent.checked
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = parent.border.color;

                ctx.beginPath();

                ctx.moveTo(3*id_customCheckBox.dp, height*5/9);
                ctx.lineTo(width*4/9, height-3*id_customCheckBox.dp);
                ctx.lineTo(width-3*id_customCheckBox.dp, 2*id_customCheckBox.dp);

                ctx.stroke();
            }
        }
    }

    contentItem: Text {
        id: id_contentItem
        anchors { left: id_indicator.right; verticalCenter: parent.verticalCenter; margins: 3 * id_customCheckBox.dp; leftMargin: id_customCheckBox.spacing }
        verticalAlignment: Qt.AlignVCenter
        color: id_customCheckBox.textColor
        text: id_customCheckBox.text
        font: id_customCheckBox.font
    }
}
