import QtQuick

Item {
    id: root

    required property QtObject game
    required property int playerIndex

    readonly property color gold: "#ffcc00"
    readonly property color panelBg: "#1a1a2e"
    readonly property var answerColors: ["#2a4a8a", "#8a5a2a", "#2a7a3a", "#8a2a3a"]
    readonly property color headerColor: playerIndex === 0 ? "#1a2a3e" : "#2a1a2e"

    // Per-player state accessors
    readonly property int myAnswer: playerIndex === 0 ? game.player1Answer : game.player2Answer
    readonly property bool myLocked: playerIndex === 0 ? game.player1Locked : game.player2Locked
    readonly property int myScore: playerIndex === 0 ? game.player1Score : game.player2Score
    readonly property bool myCorrect: playerIndex === 0 ? game.player1Correct : game.player2Correct
    readonly property int myPoints: playerIndex === 0 ? game.player1PointsEarned : game.player2PointsEarned

    clip: true

    Rectangle {
        anchors.fill: parent
        color: root.panelBg
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            width: parent.width
            height: 36
            color: root.headerColor

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                text: "SPIELER " + (root.playerIndex + 1)
                color: root.gold
                font { pixelSize: 12; bold: true; family: "monospace" }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 8
                text: root.myScore.toString()
                color: "#cccccc"
                font { pixelSize: 12; family: "monospace" }
            }
        }

        // Content area
        Item {
            width: parent.width
            height: parent.height - 36

            // --- Waiting (title / roundIntro / scoreboard) ---
            Text {
                anchors.centerIn: parent
                visible: root.game.phase === "title"
                         || root.game.phase === "roundIntro"
                         || root.game.phase === "scoreboard"
                text: {
                    if (root.game.phase === "title") return "...";
                    if (root.game.phase === "roundIntro") return "Bereit!";
                    return "...";
                }
                color: "#888888"
                font { pixelSize: 12; family: "monospace" }
            }

            // --- Question phase: A/B/C/D buttons only ---
            Grid {
                id: buttonGrid
                anchors.fill: parent
                anchors.margins: 6
                columns: 2
                spacing: 4
                visible: root.game.phase === "question"

                Repeater {
                    model: root.game.answersRevealed ? 4 : 0

                    Rectangle {
                        width: (buttonGrid.width - buttonGrid.spacing) / 2
                        height: (buttonGrid.height - buttonGrid.spacing) / 2
                        radius: 6
                        opacity: root.game.answersRevealed ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        readonly property bool isInsult: root.game.currentRoundData
                                                         && root.game.currentRoundData.mode === "insult"
                        readonly property string label: isInsult
                                                        ? ["1", "2", "3", "4"][index]
                                                        : ["A", "B", "C", "D"][index]

                        color: {
                            if (root.myLocked && root.myAnswer === index)
                                return Qt.lighter(root.answerColors[index], 1.3);
                            if (root.myLocked)
                                return Qt.darker(root.answerColors[index], 1.5);
                            return root.answerColors[index];
                        }
                        border.color: root.myLocked && root.myAnswer === index
                                      ? root.gold : "transparent"
                        border.width: root.myLocked && root.myAnswer === index
                                      ? 2 : 0

                        Behavior on color { ColorAnimation { duration: 200 } }

                        Text {
                            anchors.centerIn: parent
                            text: parent.label
                            color: "#ffffff"
                            font { pixelSize: 24; bold: true; family: "monospace" }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: root.myLocked
                                         ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: {
                                if (!root.myLocked)
                                    root.game.submitAnswer(root.playerIndex, index);
                            }
                        }
                    }
                }
            }

            // --- Reveal phase ---
            Column {
                anchors.centerIn: parent
                spacing: 8
                visible: root.game.phase === "reveal"

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 100; height: 28; radius: 6
                    color: root.myCorrect ? "#00e676" : "#ff1744"

                    Text {
                        anchors.centerIn: parent
                        text: root.myCorrect ? "RICHTIG!" : "FALSCH!"
                        color: "#ffffff"
                        font { pixelSize: 14; bold: true; family: "monospace" }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "+" + root.myPoints + " Pkt."
                    color: root.gold
                    font { pixelSize: 16; bold: true; family: "monospace" }
                }
            }

            // --- Finale phase ---
            Column {
                anchors.centerIn: parent
                spacing: 6
                visible: root.game.phase === "finale"

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SPIEL VORBEI"
                    color: root.gold
                    font { pixelSize: 14; bold: true; family: "monospace" }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.myScore.toString()
                    color: "#ffffff"
                    font { pixelSize: 36; bold: true; family: "monospace" }
                }
            }
        }
    }
}
