import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0

Rectangle {
    id: id_windowFrame

    // variable need overwrite
    property var windowLogoImg: undefined
    property var windowLogoText: undefined //"logo text"
    property color logoTextColor: "white"
    property var rootWindow: undefined
    property real rootWindowDefaultWidth: 0
    property real rootWindowDefaultHeight: 0

    // const variable
    property real dpScale:  1.5
    readonly property real dp: Math.max(Screen.pixelDensity * 25.4 / 160 * dpScale, 1)

    // window state flag
    property bool isWindowMaximized: false

    // signals
    signal sglMousePositionChanged
    signal sglWindowTitleBtnHoverd(bool hoverd)
    signal sglThemeSettingVisible(bool visible)

    // functions
    function setWindowColor(color) {
        id_windowBackgroundImg.source = "";
        id_windowFrame.color = Qt.rgba(color.r, color.g, color.b, id_windowFrame.color.a);
    }

    function setWindowBorderColor(color) {
        id_windowFrame.border.color = color;
    }

    function setWindowBackgroundPic(url) {
        id_windowBackgroundImg.source = url;
    }

    function setWindowBorderVisible(visible) {
        //id_windowFrame.border.width = visible ? 1 : 0;

        // 防止绑定循环
        if (visible) {
            if (id_windowFrame.border.width === 0) {
                id_windowFrame.border.width = 1;
            }
        }
        else {
            if (id_windowFrame.border.width === 1) {
                id_windowFrame.border.width = 0;
            }
        }
    }

    function setWindowAlpha(alpha) {
        var r = id_windowFrame.color.r;
        var g = id_windowFrame.color.g;
        var b = id_windowFrame.color.b;
        id_windowFrame.color = Qt.rgba(r, g, b, alpha);
    }

    function hideWindowBorder() {
        setWindowBorderVisible(false);
    }

    function hideWindowTitle() {
        setWindowTitleVisible(false);
    }

    function setWindowTitleVisible(visible) {
        id_windowTitle.visible = visible
        id_windowDrag.cursorShape = visible ? Qt.ArrowCursor : Qt.BlankCursor
    }

    function restoreDefaultSetting() {
        setWindowColor(Qt.rgba(0, 0, 0, 0.4));
        setWindowBorderColor("white");
        setWindowBorderVisible(true);
        setWindowAlpha(0.4);
        id_loaderThemeSetting.item.setWindowAlphaSlider(0.4);
    }

    function showFullScreen() {
        rootWindow.showFullScreen();
    }

    function showNormalScreen() {
        rootWindow.showNormal();
    }

    function switchFullScreen() {
        if (rootWindow.visibility === Window.FullScreen) {
            showNormalScreen();
        }
        else {
            showFullScreen();
        }
    }

    function restoreWindow() {
        if (rootWindow.visibility === Window.FullScreen) {
            showNormalScreen();
        }
        if (rootWindowDefaultWidth != 0 && rootWindowDefaultHeight != 0) {
            rootWindow.width = rootWindowDefaultWidth;
            rootWindow.height = rootWindowDefaultHeight;
            rootWindow.x = (Screen.width-rootWindow.width)/2;
            rootWindow.y = (Screen.height-rootWindow.height)/2;
        }
        setWindowBorderVisible(true);
    }

    // set rootwindow transparent
    onParentChanged: {
        rootWindow.flags = Qt.FramelessWindowHint | Qt.Window | Qt.WindowMinimizeButtonHint;
        rootWindow.color = "transparent";
    }

    anchors { fill: parent }
    color: Qt.rgba(0, 0, 0, 0.4)
    border { width: 1; color: "white" }

    Component.onCompleted: {
        rootWindowDefaultWidth = rootWindow.width;
        rootWindowDefaultHeight = rootWindow.height;

        sglWindowTitleBtnHoverd.connect(id_windowDrag.restoreArrowCursorShape);
    }

    // mosue handle
    MouseArea {
        id: id_windowDrag
        anchors { fill: parent }
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        property point clickedPos: "0,0"
        property rect  clickedRect

        readonly property int _LeftArea:        0
        readonly property int _RightArea:       1
        readonly property int _TopArea:         2
        readonly property int _BottomArea:      4
        readonly property int _TopLeftArea:     5
        readonly property int _TopRightArea:    6
        readonly property int _BottomLeftArea:  7
        readonly property int _BottomRightArea: 8
        readonly property int _CenterArea:      9
        property int mouseArea: _CenterArea

        function restoreArrowCursorShape(isArrow) {
            if (isArrow) {
                cursorShape = Qt.ArrowCursor;
            }
        }

        onPressed: {
            clickedPos = Qt.point(mouse.x, mouse.y);
            clickedRect = Qt.rect(rootWindow.x, rootWindow.y, rootWindow.width, rootWindow.height);
        }

        onPositionChanged: {
            sglMousePositionChanged();

            const margin = 5 * dp;
            if (pressed) {
                var delta = Qt.point(mouse.x-clickedPos.x, mouse.y-clickedPos.y)
                if (cursorShape === Qt.ArrowCursor) {
                    rootWindow.x += delta.x;
                    rootWindow.y += delta.y;
                }
                else {
                    switch (mouseArea) {
                    case _BottomRightArea:
                        rootWindow.width = clickedRect.width + delta.x;
                        rootWindow.height = clickedRect.height + delta.y;
                        break;
                    case _TopLeftArea:
                        break;
                    case _RightArea:
                        rootWindow.width = clickedRect.width + delta.x;
                        break;
                    case _LeftArea:
                        break;
                    case _BottomArea:
                        break;
                    case _TopArea:
                        break;

                    }
                }
            }
            else {
                if (mouseX > (width-margin) && mouseY > (height-margin)) {
                    sglWindowTitleBtnHoverd(true);
                    cursorShape = Qt.SizeFDiagCursor;
                    mouseArea = _BottomRightArea;
                }
                else if (mouseX < margin && mouseY < margin) {
                    cursorShape = Qt.SizeFDiagCursor;
                    mouseArea = _TopLeftArea;
                }
                else if (mouseX > width-margin && mouseY < margin) {
                    cursorShape = Qt.SizeBDiagCursor;
                    mouseArea = _TopRightArea;
                }
                else if (mouseX < margin && mouseY > height-margin) {
                    cursorShape = Qt.SizeBDiagCursor;
                    mouseArea = _BottomLeftArea;
                }
                else if (mouseX > width-margin) {
                    sglWindowTitleBtnHoverd(true);
                    cursorShape = Qt.SizeHorCursor;
                    mouseArea = _RightArea;
                }
                else if (mouseX < margin) {
                    sglWindowTitleBtnHoverd(true);
                    cursorShape = Qt.SizeHorCursor;
                    mouseArea = _LeftArea;
                }
                else if (mouseY > height-margin) {
                    cursorShape = Qt.SizeVerCursor;
                    mouseArea = _BottomArea;
                }
                else if (mouseY < margin) {
                    cursorShape = Qt.SizeVerCursor;
                    mouseArea = _TopArea;
                }
                else {
                    cursorShape = Qt.ArrowCursor;
                    ////sglWindowTitleBtnHoverd(false);
                    mouseArea = _CenterArea;

                }
            }
        }

        onDoubleClicked: {
            switchFullScreen();
        }
    }

    // pinch scale
//    PinchArea {
//       id: id_windowPinchScale
//        anchors { fill: parent }
//        property real windowWidth: id_rootWindow.width
//        property real windowHeight: id_rootWindow.height
//        onPinchStarted: {
//            windowWidth = id_rootWindow.width
//            windowHeight = id_rootWindow.height
//        }
//        onPinchUpdated: {
//            //console.log(pinch.scale)
//            id_rootWindow.width = windowWidth * pinch.scale;
//            id_rootWindow.height = windowHeight * pinch.scale;
//            console.log(pinch.point1);
//            console.log(pinch.point2);
//            console.log(pinch.pointCount);
//        }
//    }

    // background img
    Image {
        id: id_windowBackgroundImg
        anchors { fill: parent }
        source: ""
    }

    // window top (logo and tools)
    Rectangle  {
        id: id_windowTitle
        z: 10

        // const variable: icon size
        readonly property real  logoSize:           25 * dp
        readonly property real  btnWidth:           40 * dp
        readonly property real  btnHeight:          22 * dp
        readonly property real 	btnTopMargin:		5 * dp
        readonly property real  iconLineWidth:      1 * dp
        readonly property real  logoMargin:         5 * dp
        readonly property real  constSpacing:       15 * dp
        readonly property color iconColor:          "white"
        readonly property color iconHoveredColor:   "gray"

        // size and color
        anchors { left: parent.left; top: parent.top }
        width: parent.width
        height: logoSize + logoMargin * 2
        color: "transparent"

        // logo img
        Image {
            id: id_windowLogoImg
            anchors { left: parent.left; top: parent.top; margins: parent.logoMargin }
            width: id_windowTitle.logoSize
            height: width
            source: id_windowFrame.windowLogoImg

            Text {
                anchors { centerIn: parent }
                text: typeof(id_windowFrame.windowLogoImg) === "undefined" ? "logo" : ""
                color: "red"
                font { pixelSize: 24; bold: true }
            }
        }

        // logo text
        Text {
            id: id_windowLogoText
            anchors { left: id_windowLogoImg.right; verticalCenter: parent.verticalCenter; leftMargin: 5 * dp }
            text: typeof(id_windowFrame.windowLogoText) === "undefined" ? "logo text" : id_windowFrame.windowLogoText
            color: id_windowFrame.logoTextColor
            font { pointSize: 12 }
        }

        // music player switch
        Rectangle {
            id: id_musicPlayerSwitch
            anchors { left: id_windowLogoText.right; top: parent.top; margins: 5*dp; leftMargin: 40*dp }
            width: id_windowTitle.logoSize
            height: width
            radius: width / 2
            color: Qt.rgba(0, 0, 0, 0)

            Text {
                id: id_musicPlayerSwitchText
                anchors { centerIn: parent }
                color: "white"
                text: qsTr("音")
            }

            ToolTip {
                id: id_musicPlayerSwitchTooltip
                text: qsTr("切到音乐播放器")
                visible: false
            }

            MouseArea {
                anchors { fill: parent }
                hoverEnabled: true
                onClicked: {
                    id_musicPlayerSwitch.color = Qt.rgba(1, 1, 1, 1);
                    id_musicPlayerSwitchText.color = "black";

                    id_videoPlayerSwitch.color = Qt.rgba(0, 0, 0, 0);
                    id_videoPlayerSwitchText.color = "white";

                    id_windowContent.switchToMusicPlayer();
                }
                onEntered: {
                    id_musicPlayerSwitchTooltip.visible = true;
                    sglWindowTitleBtnHoverd(true);
                }
                onExited: {
                    id_musicPlayerSwitchTooltip.visible = false;
                    sglWindowTitleBtnHoverd(false);
                }
            }
        }

        // video player switch
        Rectangle {
            id: id_videoPlayerSwitch
            anchors { left: id_musicPlayerSwitch.right; top: parent.top; margins: id_musicPlayerSwitch.anchors.margins; leftMargin: id_musicPlayerSwitch.anchors.leftMargin }
            width: id_musicPlayerSwitch.width
            height: width
            radius: width / 2
            color: Qt.rgba(1, 1, 1, 1)

            Text {
                id: id_videoPlayerSwitchText
                anchors { centerIn: parent }
                color: "black"
                text : qsTr("视")
            }

            ToolTip {
                id: id_videoPlayerSwitchTooltip
                text: qsTr("切到视频播放器")
                visible: false
            }

            MouseArea {
                anchors { fill: parent }
                hoverEnabled: true
                onClicked: {
                    id_musicPlayerSwitch.color = Qt.rgba(0, 0, 0, 0);
                    id_musicPlayerSwitchText.color = "white";

                    id_videoPlayerSwitch.color = Qt.rgba(1, 1, 1, 1);
                    id_videoPlayerSwitchText.color = "black";

                    id_windowContent.switchToVideoPlayer();
                }
                onEntered: {
                    id_videoPlayerSwitchTooltip.visible = true;
                    sglWindowTitleBtnHoverd(true);
                }
                onExited: {
                    id_videoPlayerSwitchTooltip.visible = false;
                    sglWindowTitleBtnHoverd(false);
                }
            }
        }

        // theme setting
        ToolButton {
            id: id_windowTheme
            anchors { top: parent.top; right: id_windowMenuMore.left; margins: 1; topMargin: id_windowTitle.btnTopMargin }
            width: id_windowTitle.btnWidth
            height: id_windowTitle.btnHeight
            hoverEnabled: true
            checkable: true

            background: Loader {
                anchors { fill: parent }
                sourceComponent: com_btnBg
                property bool hovered: parent.hovered
            }

            Image {
                anchors { centerIn: parent }
                width: parent.height * 2 / 3
                height: width
                source: "/Images/theme.png"
            }

            onHoveredChanged: {
                sglWindowTitleBtnHoverd(checked ? true: hovered);
            }

            onClicked: {
                id_loaderThemeSetting.visible = !id_loaderThemeSetting.visible;
            }

            onCheckedChanged: {
                sglWindowTitleBtnHoverd(checked);
            }
        }

        // menu more
        ToolButton {
            id: id_windowMenuMore
            anchors { top: parent.top; right: id_windowMini.left; margins: 1; topMargin: id_windowTitle.btnTopMargin }
            width: id_windowTitle.btnWidth
            height: id_windowTitle.btnHeight
            hoverEnabled: true
            checkable: true

            background: Loader {
                anchors { fill: parent }
                sourceComponent: com_btnBg
                property bool hovered: parent.hovered
            }

            onHoveredChanged: {
                sglWindowTitleBtnHoverd(checked ? true : hovered);
            }

            onClicked: {
                id_loaderOptions.visible = !id_loaderOptions.visible;
            }

            onCheckedChanged: {
                sglWindowTitleBtnHoverd(checked);
            }

            Loader {
                anchors { centerIn: parent }
                width: parent.height / 2 + 1 * dp
                height: parent.height / 2
                property color iconLineColor: parent.hovered ? id_windowTitle.iconHoveredColor : id_windowTitle.iconColor
                sourceComponent: parent.hovered ? com_windowMenuMoreHover : com_windowMenuMore
            }

            Component {
                id: com_windowMenuMore
                Loader { sourceComponent: com_windowMenuMorePub }
            }

            Component {
                id: com_windowMenuMoreHover
                Loader { sourceComponent: com_windowMenuMorePub }
            }

            Component {
                id: com_windowMenuMorePub
                Canvas {
                    anchors { fill: parent }
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = parent.parent.iconLineColor
                        ctx.lineWidth = id_windowTitle.iconLineWidth;

                        ctx.beginPath();

                        ctx.moveTo(0, ctx.lineWidth/2);
                        ctx.lineTo(width, ctx.lineWidth/2);

                        ctx.moveTo(0, height/2);
                        ctx.lineTo(width, height/2);

                        ctx.moveTo(0, height-ctx.lineWidth/2);
                        ctx.lineTo(width, height-ctx.lineWidth/2);

                        ctx.stroke();
                    }
                }
            }
        }

        // mini window
        ToolButton {
            id: id_windowMini
            anchors { top: parent.top; right: id_windowMax.left; margins: 1; topMargin: id_windowTitle.btnTopMargin }
            width: id_windowTitle.btnWidth
            height: id_windowTitle.btnHeight
            hoverEnabled: true

            background: Loader {
                anchors { fill: parent }
                sourceComponent: com_btnBg
                property bool hovered: parent.hovered
            }

            Loader {
                anchors { centerIn: parent }
                width: parent.height / 2
                height: width
                property color iconLineColor: parent.hovered ? id_windowTitle.iconHoveredColor : id_windowTitle.iconColor
                sourceComponent: parent.hovered ? com_windowMiniHover : com_windowMini
            }

            Component {
                id: com_windowMini
                Loader { sourceComponent: com_windowMiniPub }
            }

            Component {
                id: com_windowMiniHover
                Loader { sourceComponent: com_windowMiniPub }
            }

            Component {
                id: com_windowMiniPub
                Canvas {
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = parent.parent.iconLineColor
                        ctx.lineWidth = id_windowTitle.iconLineWidth;

                        ctx.beginPath();

                        ctx.moveTo(0, height/2);
                        ctx.lineTo(width, height/2);

                        ctx.stroke();
                    }
                }
            }

            onHoveredChanged: {
                sglWindowTitleBtnHoverd(hovered);
            }

            onClicked: {
                rootWindow.showMinimized();
            }
        }

        // max window
        ToolButton {
            id: id_windowMax
            anchors { top: parent.top; right: id_windowClose.left; margins: 1; topMargin: id_windowTitle.btnTopMargin }
            width: id_windowTitle.btnWidth
            height: id_windowTitle.btnHeight
            hoverEnabled: true

            background:  Loader {
                anchors { fill: parent }
                sourceComponent: com_btnBg
                property bool hovered: parent.hovered
            }

            Loader {
                anchors { centerIn: parent; }
                width: parent.height / 2
                height: width
                property color iconLineColor: parent.hovered ? id_windowTitle.iconHoveredColor : id_windowTitle.iconColor
                sourceComponent: parent.hovered ? (id_windowFrame.isWindowMaximized ? com_windowMaxHover : com_windowNomalHover) : (id_windowFrame.isWindowMaximized ? com_windowMax : com_windowNomal)
            }

            Component {
                id: com_windowNomal
                Loader { sourceComponent: com_windowNomalPub }
            }

            Component {
                id: com_windowNomalHover
                Loader { sourceComponent: com_windowNomalPub }
            }

            Component {
                id: com_windowMax
                Loader { sourceComponent: com_windowMaxPub }
            }

            Component {
                id: com_windowMaxHover
                Loader { sourceComponent: com_windowMaxPub }
            }

            Component {
                id: com_windowNomalPub
                Canvas {
                    anchors { fill: parent }
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = parent.parent.iconLineColor;
                        ctx.lineWidth = id_windowTitle.iconLineWidth;
                        ctx.beginPath();
                        ctx.rect(ctx.lineWidth/2, width*1/11+ctx.lineWidth/2, width-ctx.lineWidth, width*9/11-ctx.lineWidth);
                        ctx.stroke();
                    }
                }
            }

            Component {
                id: com_windowMaxPub
                Canvas {
                    anchors { fill: parent }
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = parent.parent.iconLineColor;
                        ctx.lineWidth = id_windowTitle.iconLineWidth;

                        ctx.beginPath();

                        ctx.rect(ctx.lineWidth/2, 2*dp+ctx.lineWidth/2, width-2*dp-ctx.lineWidth, width-2*dp-ctx.lineWidth);

                        ctx.moveTo(2*dp+ctx.lineWidth/2, 2*dp+ctx.lineWidth/2);
                        ctx.lineTo(2*dp+ctx.lineWidth/2, ctx.lineWidth/2);
                        ctx.lineTo(width-ctx.lineWidth/2, ctx.lineWidth/2);
                        ctx.lineTo(width-ctx.lineWidth/2, height-2*dp-ctx.lineWidth/2);
                        ctx.lineTo(width-2*dp-ctx.lineWidth/2, height-2*dp-ctx.lineWidth/2)
                        ctx.stroke();
                    }
                }
            }

            onHoveredChanged: {
                sglWindowTitleBtnHoverd(hovered);
            }

            onClicked: {
                if (id_windowFrame.isWindowMaximized) {
                    rootWindow.showNormal();
                    id_windowFrame.isWindowMaximized = false;
                }
                else {
                    rootWindow.showMaximized();
                    id_windowFrame.isWindowMaximized = true;
                }
            }
        }

        // close window
        ToolButton {
            id: id_windowClose
            anchors { top: parent.top; right: parent.right; margins: 1; topMargin: id_windowTitle.btnTopMargin }
            width: id_windowTitle.btnWidth
            height: id_windowTitle.btnHeight
            hoverEnabled: true

            background:  Loader {
                anchors { fill: parent }
                sourceComponent: com_btnBg
                property bool hovered: parent.hovered
            }

            Loader {
                anchors { centerIn: parent }
                width: parent.height / 2
                height: width
                property color iconLineColor: parent.hovered ? "red" : id_windowTitle.iconColor
                sourceComponent: parent.hovered ? com_closeBtnHover : com_closeBtn
            }

            Component {
                id: com_closeBtn
                Loader { sourceComponent: com_closeBtnPub }
            }

            Component {
                id: com_closeBtnHover
                Loader { sourceComponent: com_closeBtnPub }
            }

            Component {
                id: com_closeBtnPub
                Canvas {
                    anchors { fill: parent }
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = parent.parent.iconLineColor;
                        ctx.lineWidth = id_windowTitle.iconLineWidth;

                        ctx.beginPath();

                        ctx.moveTo(0, 0);
                        ctx.lineTo(width, height);

                        ctx.moveTo(width, 0);
                        ctx.lineTo(0, height);

                        ctx.stroke();
                    }
                }
            }

            onHoveredChanged: {
                sglWindowTitleBtnHoverd(hovered);
            }

            onClicked: {
                Qt.quit();
            }
        }

        // theme line
        Rectangle {
            // id: id_lineTheme
            width: 1
            anchors { top: id_windowTheme.bottom; bottom: id_loaderThemeSetting.top; horizontalCenter: id_windowTheme.horizontalCenter }
        }

        // options line
        Rectangle {
            // id: id_lineOption
            width: 1
            anchors { top: id_windowMenuMore.bottom; bottom: id_loaderOptions.top; horizontalCenter: id_windowMenuMore.horizontalCenter }
        }

        // window theme setting loader
        Loader {
            id: id_loaderThemeSetting
            visible: false;
            anchors { right: parent.right; margins: 10 * dp; topMargin: 50 * dp }
            source: "ThemeSetting.qml"

            states: [
                State {
                    name: "startChors"
                    // when: visible == false
                    AnchorChanges {
                        target: id_loaderThemeSetting
                        anchors { bottom: parent.top }
                    }
                },
                State {
                    name: "endAnchors"
                    // when: visible == true
                    AnchorChanges {
                        target: id_loaderThemeSetting
                        anchors { top: parent.bottom }
                    }
                }
            ]

            transitions: Transition {
                AnchorAnimation {
                    duration: 200;
                    easing.type: Easing.InOutQuad
                }
            }

            onLoaded: {
                // init item
                item.handleId = id_windowFrame;
                item.dp = id_windowFrame.dp;
                item.setWindowAlphaSlider(id_windowFrame.color.a);

                // bind signals of item
                item.sglChooseWindowColor.connect(setWindowColor);
                item.sglChooseWindowBorderColor.connect(setWindowBorderColor);
                item.sglChooseBackgroundImg.connect(setWindowBackgroundPic);
                item.sglSetWindowBorderVisible.connect(setWindowBorderVisible);
                item.sglSetWindowAlpha.connect(setWindowAlpha);
                item.sglRestoreDefaultSetting.connect(restoreDefaultSetting);
            }

            onVisibleChanged: {
                state = visible ? "endAnchors" : "startAnchors";
                sglThemeSettingVisible(visible);
            }
        }

        // window options loader
        Loader {
            id: id_loaderOptions
            visible: false;
            anchors { right: parent.right; margins: 10 * dp; topMargin: 50 * dp }
            source: "VideoOptions.qml"

            states: [
                State {
                    name: "startChors"
                    // when: visible == false
                    AnchorChanges {
                        target: id_loaderOptions
                        anchors { bottom: parent.top }
                    }
                },
                State {
                    name: "endAnchors"
                    // when: visible == true
                    AnchorChanges {
                        target: id_loaderOptions
                        anchors { top: parent.bottom }
                    }
                }
            ]

            transitions: Transition {
                AnchorAnimation {
                    duration: 200;
                    easing.type: Easing.InOutQuad
                }
            }

            onLoaded: {
                // init item
                item.handleId = id_windowFrame;
                item.dp = id_windowFrame.dp;
            }

            onVisibleChanged: {
                state = visible ? "endAnchors" : "startAnchors";
                sglThemeSettingVisible(visible);
            }
        }

        Component {
            id: com_btnBg
            Rectangle {
                anchors { fill: parent }
                color: parent.parent.hovered || parent.parent.checked ? Qt.rgba(0, 0, 0, 0.6) : "transparent"
            }
        }
    }

    // window content
    Loader {
        id: id_windowContent
        anchors { fill: parent; margins: 1 }

        function switchToMusicPlayer() {
            id_windowContent.item.sglSetWindowTitleVisible.disconnect(setWindowTitleVisible);
            id_windowContent.item.sglSwitchFullScreen.disconnect(switchFullScreen);
            id_windowContent.item.sglShowNormalScreen.disconnect(showNormalScreen);
            id_windowContent.item.sglVideoPlaying.disconnect(hideWindowBorder);
            id_windowContent.item.sglVideoPlaying.disconnect(hideWindowTitle)
            id_windowContent.item.sglVideoStopped.disconnect(restoreWindow);

            id_loaderOptions.item.sglChangeVideoRate.disconnect(id_windowContent.item.setVideoPlayingRate);

            sglThemeSettingVisible.disconnect(id_windowContent.item.setLeftToolAreaAlwaysVisible);
            sglWindowTitleBtnHoverd.disconnect(id_windowContent.item.setLeftToolAreaAlwaysVisible);
            sglMousePositionChanged.disconnect(id_windowContent.item.showLeftToolArea);

            source = "MusicContent.qml";
        }

        function switchToVideoPlayer() {
            source = "VideoContent.qml";

            id_windowContent.item.sglSetWindowTitleVisible.connect(setWindowTitleVisible);
            id_windowContent.item.sglSwitchFullScreen.connect(switchFullScreen);
            id_windowContent.item.sglShowNormalScreen.connect(showNormalScreen);
            id_windowContent.item.sglVideoPlaying.connect(hideWindowBorder);
            id_windowContent.item.sglVideoPlaying.connect(hideWindowTitle)
            id_windowContent.item.sglVideoStopped.connect(restoreWindow);

            id_loaderOptions.item.sglChangeVideoRate.connect(id_windowContent.item.setVideoPlayingRate);

            sglThemeSettingVisible.connect(id_windowContent.item.setLeftToolAreaAlwaysVisible);
            sglWindowTitleBtnHoverd.connect(id_windowContent.item.setLeftToolAreaAlwaysVisible);
            sglMousePositionChanged.connect(id_windowContent.item.showLeftToolArea);

        }

        onLoaded: {
            item.dp = id_windowFrame.dp;
        }

        Component.onCompleted: {
            switchToVideoPlayer();
        }
    }
}
