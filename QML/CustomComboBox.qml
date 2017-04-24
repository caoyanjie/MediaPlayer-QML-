import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0

ComboBox {
    id: id_customComboBox
    property real dpScale:  1.5
    readonly property real dp: Math.max(Screen.pixelDensity * 25.4 / 160 * dpScale, 1)
    width: id_indicator.width + id_indicator.anchors.margins * 4 + id_contentItem.contentWidth
    height: 20 * dp

    background: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.5)
    }

    indicator: Canvas {
        id: id_indicator
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; margins: 4 * id_customComboBox.dp }
        height: parent.height - 8 * id_customComboBox.dp
        width: height * 7 / 10
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "white"
            ctx.lineWidth = 0.5 * dp;

            ctx.beginPath();

            ctx.moveTo(ctx.lineWidth/2, height/2 - 2*dp);
            ctx.lineTo(width/2, ctx.lineWidth/2);
            ctx.lineTo(width-ctx.lineWidth/2, height/2 - 2*dp);

            ctx.moveTo(ctx.lineWidth/2, height/2 + 2*dp);
            ctx.lineTo(width/2, height - ctx.lineWidth/2);
            ctx.lineTo(width - ctx.lineWidth/2, height/2 + 2*dp);

            ctx.stroke();
        }
    }

    contentItem: Text {
        id: id_contentItem
        anchors { leftMargin: 5*dp }
        color: "white"
        text: parent.currentText
        font: parent.font
        verticalAlignment: Qt.AlignVCenter
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; margins: 3 * dp }
    }

    delegate: ItemDelegate {
        height: 25*dp
        text: modelData
        font.pointSize: id_customComboBox.font.pointSize
        font.weight: id_customComboBox.currentIndex === index ? Font.DemiBold : Font.Normal
        highlighted: id_customComboBox.highlightedIndex == index
    }
}
