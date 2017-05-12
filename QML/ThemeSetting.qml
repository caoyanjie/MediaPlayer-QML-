import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: id_themeSetting

    // variable need overwrite
    property var handleId: null

    // const variable
    property real dp: 1
    readonly property real btnSize: 50 * dp

    // define signals
    signal sglChooseWindowColor(color bgColor)
    signal sglChooseWindowBorderColor(color borderColor)
    signal sglChooseBackgroundImg(url fileUrl)
    signal sglSetWindowBorderVisible(bool isVisible)
    signal sglSetWindowAlpha(real alhpa)
    signal sglRestoreDefaultSetting()

    // functions
    function chooseColor(color) {
        if (id_loaderColorDialog.componentId == id_chooseColor) {
            sglChooseWindowColor(color);
        }
        else {
            sglChooseWindowBorderColor(color);
        }
    }

    function setWindowAlphaSlider(value) {
        id_transparentSlider.value = value;
    }

    // design ui
    width: 230 * dp
    height: width
    color: Qt.rgba(0, 0, 0, 0.4)
    border { width: 1; color: "white" }

    // handle wheel
    MouseArea {
        id: mouseArea
        anchors { fill: parent }
        acceptedButtons: Qt.MiddleButton
        onWheel: {
            id_transparentSlider.value += (wheel.angleDelta.y > 0 ? 0.1 : -0.1)
        }
    }

    // choose window background color
    ToolButton {
        id: id_chooseColor
        anchors { left: parent.left; top: parent.top; margins: 25 * dp }
        width: id_themeSetting.btnSize
        height: width
        hoverEnabled: true
        // tooltip: qsTr("选择背景颜色")
        background: Rectangle {
            border { width: 1; color: "white" }
            color: "transparent"
        }

        Image {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; margins: 5 * dp }
            width: parent.width / 2
            height: width
            source: "/Images/choose_color.png"
        }

        Text {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: 5 * dp }
            color: "white"
            font { pointSize: 9 }
            text: qsTr("背景颜色")
        }

        onClicked: {
            id_loaderColorDialog.sourceComponent = null
            id_loaderColorDialog.sourceComponent = id_componentColorDiaglog;
            id_loaderColorDialog.componentId = id_chooseColor
            id_loaderColorDialog.item.currentColor = Qt.rgba(handleId.color.r, handleId.color.g, handleId.color.b, 1);
        }
    }

    // choose window background picture
    ToolButton {
        id: id_choosePic
        anchors { left: id_chooseColor.right; top: parent.top; margins: 25 * dp }
        width: id_themeSetting.btnSize
        height: width
        // tooltip: qsTr("选择背景图片")
        background: Rectangle {
            border { width: 1; color: "white" }
            color: "transparent"
        }

        Image {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; margins: 5 * dp }
            width: parent.width / 2
            height: width
            source: "/Images/choose_picture.png"
        }

        Text {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: 5 * dp }
            color: "white"
            font { pointSize: 9 }
            text: qsTr("背景图片")
        }

        onClicked: {
            id_loaderFileDialog.sourceComponent = null;
            id_loaderFileDialog.sourceComponent = id_componentFileDialog;
        }
    }

    // switch window border visible
    CustomCheckBox {
        id: id_checkbox
        dp: id_themeSetting.dp
        anchors { left: parent.left; top: id_chooseColor.bottom; leftMargin: 25 * dp; topMargin: 5 * dp }
        indicatorSize: 13 * dp
        checked: handleId.border.width
        font { pointSize: 12 }
        textColor: "white"
        text: qsTr("主窗体边框线")
        spacing: 3 * dp

        onCheckedChanged: {
            sglSetWindowBorderVisible(checked);
        }
    }

    // choose window border color
    ToolButton {
        id: id_chooseBorderColor
        anchors { left: id_checkbox.left; top: id_checkbox.bottom; leftMargin: 22 * dp }
        width: id_themeSetting.btnSize * 2
        height: id_themeSetting.btnSize
        // tooltip: qsTr("选择背景图片")
        enabled: id_checkbox.checked
        background: Rectangle {
            border { width: 1; color: enabled ? "white" : "gray" }
            color: "transparent"
        }

        Image {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; margins: 5 * dp }
            width: parent.height / 2
            height: width
            source: "/Images/choose_color.png"
        }

        Text {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: 5 * dp }
            color: parent.enabled ? "white" : "gray"
            font { pointSize: 9 }
            text: qsTr("边框线颜色")
        }

        onClicked: {
            id_loaderColorDialog.sourceComponent = null
            id_loaderColorDialog.sourceComponent = id_componentColorDiaglog;
            id_loaderColorDialog.componentId = id_chooseBorderColor
            id_loaderColorDialog.item.currentColor = handleId.border.color;
        }
    }

    // restore default setting
    Button {
        id: id_restoreDefault
        width: 80 * dp;
        height: 20 * dp;
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: 20 * dp }
        font { pointSize: 10 }
        text: qsTr("恢复默认")

        onClicked: {
            sglRestoreDefaultSetting();
        }
    }

    // change window alpha
    CustomSlider {
        id: id_transparentSlider
        dp: id_themeSetting.dp
        orientation: Qt.Vertical
        anchors { top: parent.top; right: parent.right; bottom: id_transparentSliderDes.top; topMargin: 25 * dp; rightMargin: 25 * dp; bottomMargin: 5 * dp }
        wheelEnabled: true
        from: 0.0
        to: 1.1
        stepSize: 0.1
        onPositionChanged: {
            sglSetWindowAlpha(position);
        }
    }

    // slider describe
    Text {
        id: id_transparentSliderDes
        anchors { bottom: id_chooseBorderColor.bottom; horizontalCenter: id_transparentSlider.horizontalCenter }
        color: "white"
        text: qsTr("不透明度")
    }

    // color dialog loader
    Loader {
        id: id_loaderColorDialog
        sourceComponent: null
        property var componentId: null
    }

    // file dialog loader
    Loader {
        id: id_loaderFileDialog
        sourceComponent: null
    }

    // color dialog component
    Component {
        id: id_componentColorDiaglog
        ColorDialog {
            id: id_colorDialog
            visible: true
            width: 300 * dp
            height: 300 * dp
            title: qsTr("Please choose a color")

            onAccepted: {
                chooseColor(color);
            }

            Component.onCompleted: {
                visible = true;
            }
        }
    }

    // file dialog component
    Component {
        id: id_componentFileDialog
        FileDialog {
            id: id_fileDialog
            width: 300 * dp
            height: 300 * dp
            folder: shortcuts.pictures
            nameFilters: [ "所有图片 (*.jpg *.png)" ]
            title: qsTr("Please choose a picture")

            onAccepted: {
                sglChooseBackgroundImg(fileUrl);
            }

            Component.onCompleted: {
                visible = true;
            }
        }
    }
}
