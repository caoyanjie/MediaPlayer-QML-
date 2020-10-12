import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    id: id_rootWindow
    visible: true
    width: Screen.width * 2 / 3
    height: Screen.height * 2 / 3
    //Application.mainWindow.screenIdleMode: 1

    TransparentWindowFrame {
        id: id_windowFrame
        windowLogoImg: "/Images/logo.png"
        windowLogoText: qsTr("Media Player")
        rootWindow: id_rootWindow
    }
}
