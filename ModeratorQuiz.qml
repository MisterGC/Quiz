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
            text: "F" + (root.game.currentQuestion + 1)
                  + " \u2014 Richtige Antwort:"
            color: "#888888"
            font { pixelSize: 12; family: "monospace" }
        }

        // Show correct answer
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 10
            height: correctText.height + 16
            radius: 6
            color: "#1a3a1a"
            border.color: "#00e676"
            border.width: 1

            Text {
                id: correctText
                anchors.centerIn: parent
                width: parent.width - 16
                text: {
                    var q = root.game.currentQuestionData;
                    if (!q) return "";
                    var labels = root.game.currentRoundData
                                 && (root.game.currentRoundData.mode === "pirate-duel"
                                     || root.game.currentRoundData.mode === "plank-duel")
                                 ? ["1", "2", "3", "4"] : ["A", "B", "C", "D"];
                    return labels[q.correct] + ": " + q.answers[q.correct];
                }
                color: "#00e676"
                font { pixelSize: 13; bold: true; family: "monospace" }
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Before answers shown: "Show Answers" button
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160; height: 44; radius: 6
            color: "#2a7a3a"
            visible: !root.game.answersRevealed

            Text {
                anchors.centerIn: parent
                text: "Antworten zeigen"
                color: "#ffffff"
                font { pixelSize: 16; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.game.showAnswers()
            }
        }

        // After answers shown: player status + timer + reveal button
        Column {
            width: parent.width
            spacing: 8
            visible: root.game.answersRevealed

            // Both players' status
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
                    text: "Antwort aufdecken"
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
        width: parent.width - 20

        // Player 1 result
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S1: " + (root.game.player1Correct ? "RICHTIG!" : "FALSCH!")
                  + (root.game.player1PointsEarned > 0
                     ? " +" + root.game.player1PointsEarned + " Pkt." : "")
            color: root.game.player1Correct ? "#00e676" : "#ff1744"
            font { pixelSize: 12; bold: true; family: "monospace" }
        }

        // Player 2 result
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S2: " + (root.game.player2Correct ? "RICHTIG!" : "FALSCH!")
                  + (root.game.player2PointsEarned > 0
                     ? " +" + root.game.player2PointsEarned + " Pkt." : "")
            color: root.game.player2Correct ? "#00e676" : "#ff1744"
            font { pixelSize: 12; bold: true; family: "monospace" }
        }

        // Roast text (moderator only)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 10
            height: roastText.height + 12
            radius: 6
            color: "#2a2a1a"
            border.color: root.gold
            border.width: 1
            visible: root.game.lastRoast !== ""

            Text {
                id: roastText
                anchors.centerIn: parent
                width: parent.width - 12
                text: root.game.lastRoast
                color: root.gold
                font { pixelSize: 12; italic: true; family: "monospace" }
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Scores
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S1: " + root.game.player1Score
                  + "  S2: " + root.game.player2Score
            color: "#cccccc"
            font { pixelSize: 12; family: "monospace" }
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
