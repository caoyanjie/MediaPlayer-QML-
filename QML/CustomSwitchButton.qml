import QtQuick 2.0
import QtQuick.Controls 2.0

Item {
    id: id_customSwitchButton
    property real   dp: 1
    property string leftText: qsTr("On")
    property string rightText: qsTr("Off")
    property color  backgroundColor: Qt.rgba(0, 0.5, 0.8, 0.4)
    property color  btnColor: Qt.rgba(0, 0.5, 0.8, 0.6)
    property color  arrowColor: btnColor
    property real   btnRadius: height / 2
    property color  textColor: "white"
    property color  inactiveTextColor: Qt.rgba(1, 1, 1, 0.6)
    property int    active: leftActive
    property bool   bottomArrow: false
    property bool   btnIcon: false

    // enum
    readonly property int leftActive: 0
    readonly property int rightActive: 1

    // signals
    signal sglLeftBtnActived()
    signal sglRightBtnActived()
    signal sglLeftButtonIconClicked()
    signal sglRightButtonIconClicked()
    signal sglButtonIconHovered()

    // functions
    function switchChanged() {
        if (id_customSwitchButton.active == id_customSwitchButton.leftActive) {
            id_activeSlider.state = "onRight";
            id_inactiveSlider.state = "onLeft";
            sglRightBtnActived();
        }
        else {
            id_activeSlider.state = "onLeft";
            id_inactiveSlider.state = "onRight";
            sglLeftBtnActived();
        }
        id_customSwitchButton.active = !id_customSwitchButton.active;
    }

    // design ui
    width: 100 * dp
    height: 18 * dp

    Component.onCompleted: {
        id_activeSliderText.text = id_customSwitchButton.leftText;
        id_inactiveSliderText.text = id_customSwitchButton.rightText;
    }

    Rectangle {
        anchors { fill: parent }
        radius: btnRadius
        color: backgroundColor

        ToolButton {
            id: id_activeSlider
            anchors { left: parent.left; right: parent.horizontalCenter; top: parent.top; bottom: parent.bottom; margins: 1 }
            //state: "onLeft"

            background: Rectangle {
                anchors { fill: parent }
                radius: btnRadius
                color: btnColor
            }

            Text {
                id: id_activeSliderText
                anchors { fill: parent }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                color: textColor
            }

            // bottom arrow
            Loader {
                anchors { horizontalCenter: parent.horizontalCenter; top: parent.bottom }
                width: parent.height/2
                height: parent.height/3
                sourceComponent: bottomArrow ? com_bottomArrow : undefined
            }

            Button {
                anchors { right: id_activeSliderText.right; verticalCenter: parent.verticalCenter; margins: 7*dp }
                height: parent.height/2
                width: height
                hoverEnabled: true
                visible: btnIcon

                ToolTip {
                    text: parent.parent.state === "onLeft" ? qsTr("清空历史") : qsTr("添加排队视频")
                    visible: parent.hovered
                }

                background: Rectangle {
                    color: Qt.rgba(0, 0, 0, 0.5)
                    visible: parent.hovered
                }

                Loader {
                    anchors { centerIn: parent }
                    height: parent.parent.height*2/5
                    width: height
                    sourceComponent: btnIcon ? (parent.parent.state === "onLeft" ? com_leftBtnIcon : com_rightBtnIcon) : undefined
                }

                onHoveredChanged: {
                    if (hovered) {
                        sglButtonIconHovered();
                    }
                }

                onClicked: {
                    if (parent.parent.state === "onLeft") {
                        sglLeftButtonIconClicked();
                    }
                    else {
                        sglRightButtonIconClicked();
                    }
                }
            }

            Component {
                id: com_bottomArrow
                Canvas {
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.fillStyle = arrowColor;
                        ctx.beginPath();

                        ctx.moveTo(0, 0);
                        ctx.lineTo(width, 0);
                        ctx.lineTo(width/2, height);
                        ctx.closePath();

                        ctx.fill();
                    }
                }
            }

            Component {
                id: com_leftBtnIcon
                Canvas {
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.lineWidth = 1*dp;
                        ctx.strokeStyle = "white";
                        ctx.beginPath();

                        ctx.moveTo(ctx.lineWidth, ctx.lineWidth);
                        ctx.lineTo(width-ctx.lineWidth, height-ctx.lineWidth);

                        ctx.moveTo(width-ctx.lineWidth, ctx.lineWidth);
                        ctx.lineTo(ctx.lineWidth, height-ctx.lineWidth);

                        ctx.stroke();
                    }
                }
            }

            Component {
                id: com_rightBtnIcon
                Canvas {
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.lineWidth = 1*dp;
                        ctx.strokeStyle = "white";
                        ctx.beginPath();

                        ctx.moveTo(ctx.lineWidth/2, height/2);
                        ctx.lineTo(width-ctx.lineWidth/2, height/2);

                        ctx.moveTo(width/2, ctx.lineWidth/2);
                        ctx.lineTo(width/2, height-ctx.lineWidth/2);

                        ctx.stroke();
                    }
                }
            }

            states: [
                State {
                    name: "onLeft"
                    AnchorChanges {
                        target: id_activeSlider
                        anchors { left: parent.left; right: parent.horizontalCenter }
                    }
                    PropertyChanges {
                        target: id_activeSliderText
                        text: id_customSwitchButton.leftText
                    }
                },
                State {
                    name: "onRight"
                    AnchorChanges {
                        target: id_activeSlider
                        anchors { left: parent.horizontalCenter; right: parent.right }
                    }
                    PropertyChanges {
                        target: id_activeSliderText
                        text: id_customSwitchButton.rightText
                    }
                }
            ]

            transitions: Transition {
                AnchorAnimation {
                    duration: 100
                }
            }

            onClicked: {
                switchChanged();
            }
        }

        ToolButton {
            id: id_inactiveSlider
            anchors { left: parent.horizontalCenter; right: parent.right; top: parent.top; bottom: parent.bottom }
            //state: "onRight"

            background: Rectangle {
                anchors { fill: parent }
                radius: btnRadius
                color: "transparent"
            }

            Text {
                id: id_inactiveSliderText
                anchors { fill: parent }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                color: inactiveTextColor
            }

            states: [
                State {
                    name: "onRight"
                    AnchorChanges {
                        target: id_inactiveSlider
                        anchors { left: parent.horizontalCenter; right: parent.right }
                    }
                    PropertyChanges {
                        target: id_inactiveSliderText
                        text: id_customSwitchButton.rightText
                    }
                },
                State {
                    name: "onLeft"
                    AnchorChanges {
                        target: id_inactiveSlider
                        anchors { left: parent.left; right: parent.horizontalCenter }
                    }
                    PropertyChanges {
                        target: id_inactiveSliderText
                        text: id_customSwitchButton.leftText
                    }
                }
            ]

            onClicked: {
                switchChanged();
            }
        }
    }
}
