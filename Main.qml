import QtQuick
import QtQuick.Window

Window {
    visibility: Window.Maximized
    visible: true
    title: qsTr("Retro Reckoning")
    color: "#0d0d1a"
    Game { anchors.fill: parent }
    Component.onCompleted: if(Qt.platform.pluginName === "minimal") Qt.quit()
}
