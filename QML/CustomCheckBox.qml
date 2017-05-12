import QtQuick 2.0
import QtQuick.Controls 2.0

CheckBox {
    id: id_customCheckBox
    property real dp: 1
    property color textColor: "black"
    property real indicatorSize: 11 * dp

    indicator: Rectangle {
        id: id_indicator
        implicitWidth: indicatorSize
        implicitHeight: implicitWidth
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: 3 * dp }

        Canvas {
            anchors { fill: parent }
            visible: parent.parent.checked
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = parent.border.color;

                ctx.beginPath();

                ctx.moveTo(3*dp, height*5/9);
                ctx.lineTo(width*4/9, height-3*dp);
                ctx.lineTo(width-3*dp, 2*dp);

                ctx.stroke();
            }
        }
    }

    contentItem: Text {
        id: id_contentItem
        anchors { left: id_indicator.right; verticalCenter: parent.verticalCenter; margins: 3 * dp; leftMargin: id_customCheckBox.spacing }
        verticalAlignment: Qt.AlignVCenter
        color: id_customCheckBox.textColor
        text: id_customCheckBox.text
        font: id_customCheckBox.font
    }
}
