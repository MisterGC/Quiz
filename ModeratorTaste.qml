import QtQuick

Item {
    id: root

    property QtObject game: null

    readonly property color gold: "#ffcc00"

    // --- Question phase ---
    Column {
        anchors.centerIn: parent
        spacing: 10
        visible: root.game.phase === "question"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "GESCHMACKSFRAGE " + (root.game.currentQuestion + 1)
            color: root.gold
            font { pixelSize: 13; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 10
            text: root.game.currentQuestionData
                  ? root.game.currentQuestionData.text : ""
            color: "#cccccc"
            font { pixelSize: 12; family: "monospace" }
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        // Show both options
        Column {
            width: parent.width
            spacing: 4

            Repeater {
                model: root.game.currentQuestionData
                       ? root.game.currentQuestionData.answers : []

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (index + 1) + ". " + modelData
                    color: "#aaaaaa"
                    font { pixelSize: 12; family: "monospace" }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "(Keine richtige Antwort \u2014 Match z\u00e4hlt)"
            color: "#666666"
            font { pixelSize: 10; italic: true; family: "monospace" }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160; height: 44; radius: 6
            color: "#2a7a3a"
            visible: !root.game.answersRevealed

            Text {
                anchors.centerIn: parent
                text: "Optionen zeigen"
                color: "#ffffff"
                font { pixelSize: 16; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.game.showAnswers()
            }
        }

        Column {
            width: parent.width
            spacing: 8
            visible: root.game.answersRevealed

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "S1: " + (root.game.player1Locked ? "\u2713" : "...")
                      + "  S2: " + (root.game.player2Locked ? "\u2713" : "...")
                color: (root.game.player1Locked && root.game.player2Locked)
                       ? root.gold : "#666666"
                font { pixelSize: 12; family: "monospace" }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Timer: " + (root.game.timerValue / 10.0).toFixed(1) + "s"
                color: "#888888"
                font { pixelSize: 11; family: "monospace" }
                visible: root.game.timerRunning
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 160; height: 44; radius: 6
                color: "#8a5a2a"

                Text {
                    anchors.centerIn: parent
                    text: "Aufdecken"
                    color: "#ffffff"
                    font { pixelSize: 16; bold: true; family: "monospace" }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.revealAnswer()
                }
            }
        }
    }

    // --- Reveal phase ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "reveal"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.player1Correct ? "MATCH!" : "KEIN MATCH"
            color: root.game.player1Correct ? "#00e676" : "#ff1744"
            font { pixelSize: 16; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.player1Correct ? "+100 f\u00fcr beide" : "Keine Punkte"
            color: "#cccccc"
            font { pixelSize: 12; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S1: " + root.game.player1Score
                  + "  S2: " + root.game.player2Score
            color: root.gold
            font { pixelSize: 12; bold: true; family: "monospace" }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160; height: 44; radius: 6
            color: "#2a4a8a"

            Text {
                anchors.centerIn: parent
                text: "Weiter"
                color: "#ffffff"
                font { pixelSize: 16; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.game.nextStep()
            }
        }
    }
}
