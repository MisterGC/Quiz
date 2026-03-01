import QtQuick

Item {
    id: root

    property QtObject game: null

    readonly property color gold: "#ffcc00"
    readonly property color colCorrect: "#00e676"
    readonly property color colWrong: "#ff1744"

    // --- Console phase: atmospheric CRT screen ---
    Item {
        anchors.fill: parent
        visible: root.game.phase === "console"

        Rectangle {
            anchors.fill: parent
            color: "#000000"
        }

        // Scanline overlay
        Column {
            anchors.fill: parent
            opacity: 0.08
            Repeater {
                model: Math.ceil(root.height / 3)
                Rectangle {
                    width: root.width
                    height: 1
                    y: index * 3
                    color: "#ffffff"
                }
            }
        }

        // Simulated DOS boot text
        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 16
            text: "Microsoft(R) MS-DOS Version 6.22\n"
                  + "(C)Copyright Microsoft Corp 1981-1994.\n\n"
                  + "HIMEM.SYS nicht geladen.\n"
                  + "Konventioneller Speicher: 520K frei.\n\n"
                  + "C:\\>"
            color: "#c0c0c0"
            font { pixelSize: 14; family: "monospace" }
        }

        // Blinking cursor
        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 60
            anchors.topMargin: 106
            text: "_"
            color: "#c0c0c0"
            font { pixelSize: 14; family: "monospace" }
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0; duration: 500 }
                NumberAnimation { to: 1; duration: 500 }
            }
        }

        // Timer (top-right)
        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            visible: root.game.timerRunning || root.game.timerValue > 0
            text: {
                var s = Math.ceil(root.game.timerValue / 10);
                return s.toString() + "s";
            }
            color: {
                var secs = root.game.timerValue / 10.0;
                if (secs > 60) return root.colCorrect;
                if (secs > 30) return root.gold;
                return root.colWrong;
            }
            font { pixelSize: 28; bold: true; family: "monospace" }
        }
    }

    // --- Console Result phase ---
    Item {
        anchors.fill: parent
        visible: root.game.phase === "consoleResult"

        Rectangle {
            anchors.fill: parent
            color: "#000000"
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.currentQuestionData
                      ? root.game.currentQuestionData.text : ""
                color: "#c0c0c0"
                font { pixelSize: 24; bold: true; family: "monospace" }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.player1Correct
                      ? "GESCHAFFT!" : "ZEIT ABGELAUFEN"
                color: root.game.player1Correct ? root.colCorrect : root.colWrong
                font { pixelSize: 48; bold: true; family: "monospace" }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.player1Correct
                      ? "+100 Punkte" : "+0 Punkte"
                color: root.game.player1Correct ? root.colCorrect : "#888888"
                font { pixelSize: 24; family: "monospace" }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Gesamtpunkte: " + root.game.player1Score
                color: root.gold
                font { pixelSize: 20; bold: true; family: "monospace" }
            }
        }
    }
}
