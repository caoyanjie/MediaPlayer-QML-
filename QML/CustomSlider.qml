import QtQuick 2.0
import QtQuick.Controls 2.0

Slider {
    id: id_customSlider
    property real dp: 1
    property bool toolTipVisible: true
    property string toolTipText: ""
    property color sliderColor: "green"
    property color backColor: "white"

    signal sglMouseEntered()
    signal sglValueTo(real value)

    hoverEnabled: true
    Keys.forwardTo: [parent]

    background: Rectangle {
        x: orientation === Qt.Horizontal ? id_customSlider.leftPadding : (id_customSlider.leftPadding + id_customSlider.availableWidth / 2 - width / 2)
        y: orientation === Qt.Horizontal ? (id_customSlider.topPadding+id_customSlider.availableHeight/2-height/2) : id_customSlider.topPadding
        width: orientation === Qt.Horizontal ? id_customSlider.availableWidth : 4 * dp
        height: orientation === Qt.Horizontal ? 4 * dp : id_customSlider.availableHeight
        radius: 2
        color: id_customSlider.backColor

        Rectangle {
            anchors { bottom: parent.bottom }
            width: orientation === Qt.Horizontal ? id_customSlider.visualPosition*parent.width : parent.width
            height: orientation === Qt.Horizontal ? parent.height: (parent.height - id_customSlider.visualPosition * parent.height)
            color: id_customSlider.sliderColor
            radius: 2
        }

        MouseArea {
            id: id_sliderArea
            anchors { fill: parent }
            hoverEnabled: true
            cursorShape: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor

            onHoveredChanged: {
                if (hovered) {
                    sglMouseEntered();
                }
            }
//            onMouseXChanged: {
//                sglMouseEntered();
//                mouse.accepted = false;
//            }

            onPressed: {
                sglValueTo(mouse.x / parent.width * to);
                mouse.accepted = false;
            }
        }
    }

    handle: Rectangle {
        x: orientation === Qt.Horizontal ? (id_customSlider.leftPadding+id_customSlider.visualPosition*(id_customSlider.availableWidth-width)) : (id_customSlider.leftPadding + id_customSlider.availableWidth / 2 - width / 2)
        y: orientation === Qt.Horizontal ? (id_customSlider.topPadding+id_customSlider.availableHeight/2-height/2) : (id_customSlider.topPadding + id_customSlider.visualPosition * (id_customSlider.availableHeight - height))
        implicitWidth:  10 * dp
        implicitHeight: implicitWidth
        radius: implicitWidth / 2
        //color: sliderColor
        color: "red"

        ToolTip {
            text: toolTipText === "" ? id_customSlider.position.toFixed(1) : id_customSlider.toolTipText
            visible: toolTipVisible ? id_customSlider.pressed : false
        }
    }
}
