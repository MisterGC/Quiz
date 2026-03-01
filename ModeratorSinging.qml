import QtQuick

Item {
    id: root

    property QtObject game: null

    readonly property color gold: "#ffcc00"

    // --- Singing Active phase ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "singingActive"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "SONG " + (root.game.currentQuestion + 1)
            color: root.gold
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        // Cheat sheet: song title + artist
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 10
            height: cheatCol.height + 12
            radius: 6
            color: "#1a3a1a"
            border.color: "#00e676"
            border.width: 1

            Column {
                id: cheatCol
                anchors.centerIn: parent
                width: parent.width - 12
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.game.currentQuestionData
                          ? root.game.currentQuestionData.text : ""
                    color: "#00e676"
                    font { pixelSize: 14; bold: true; family: "monospace" }
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.game.currentQuestionData
                          ? root.game.currentQuestionData.artist : ""
                    color: "#aaddaa"
                    font { pixelSize: 12; italic: true; family: "monospace" }
                }
            }
        }

        // Timer start button
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160; height: 44; radius: 6
            color: "#2a7a3a"
            visible: !root.game.singingTimerStarted

            Text {
                anchors.centerIn: parent
                text: "Timer starten"
                color: "#ffffff"
                font { pixelSize: 16; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.game.startSongTimer()
            }
        }

        // Timer display
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.game.singingTimerStarted
            text: "Timer: " + (root.game.timerValue / 10.0).toFixed(1) + "s"
            color: "#888888"
            font { pixelSize: 11; family: "monospace" }
        }

        // Scoring buttons
        Column {
            width: parent.width
            spacing: 6
            visible: root.game.singingTimerStarted

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Punkte vergeben:"
                color: "#888888"
                font { pixelSize: 11; family: "monospace" }
            }

            // Both correct (Basti sang gut + Crowd hat erraten)
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 10; height: 34; radius: 6
                color: "#2a7a3a"

                Text {
                    anchors.centerIn: parent
                    text: "Beide richtig (+100/+100)"
                    color: "#ffffff"
                    font { pixelSize: 12; bold: true; family: "monospace" }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.awardSingingPoints(100, 100)
                }
            }

            // Only Basti
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 10; height: 34; radius: 6
                color: "#2a4a8a"

                Text {
                    anchors.centerIn: parent
                    text: "Nur Basti (+100/0)"
                    color: "#ffffff"
                    font { pixelSize: 12; bold: true; family: "monospace" }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.awardSingingPoints(100, 0)
                }
            }

            // Only Crowd
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 10; height: 34; radius: 6
                color: "#8a2a3a"

                Text {
                    anchors.centerIn: parent
                    text: "Nur Crowd (0/+100)"
                    color: "#ffffff"
                    font { pixelSize: 12; bold: true; family: "monospace" }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.awardSingingPoints(0, 100)
                }
            }

            // Nobody
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 10; height: 34; radius: 6
                color: "#3a3a3a"

                Text {
                    anchors.centerIn: parent
                    text: "Niemand (0/0)"
                    color: "#ffffff"
                    font { pixelSize: 12; bold: true; family: "monospace" }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.awardSingingPoints(0, 0)
                }
            }
        }
    }

    // --- Singing Reveal phase ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "singingReveal"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.currentQuestionData
                  ? root.game.currentQuestionData.text : ""
            color: "#cccccc"
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S1: +" + root.game.player1PointsEarned
                  + "  S2: +" + root.game.player2PointsEarned
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
                onClicked: root.game.nextSong()
            }
        }
    }
}
