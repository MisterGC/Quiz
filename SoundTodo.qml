import QtQuick

Rectangle {
    id: root

    property string label: ""

    width: row.width + 16
    height: row.height + 8
    radius: 4
    color: "#cc1a1a2e"
    border.color: "#55ffcc00"
    border.width: 1

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: "♫"
            color: "#ffcc00"
            font.pixelSize: 11
        }
        Text {
            text: "TODO: " + root.label
            color: "#ffcc00"
            font.pixelSize: 10
            font.italic: true
        }
    }
}
