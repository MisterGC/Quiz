import QtQuick

Item {
    id: root

    required property QtObject game

    readonly property color gold: "#ffcc00"
    readonly property color panelBg: "#1a1a2e"

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
            color: "#2a1a3e"

            Text {
                anchors.centerIn: parent
                text: "MODERATOR"
                color: root.gold
                font { pixelSize: 14; bold: true; family: "monospace" }
            }
        }

        // Content area
        Item {
            width: parent.width
            height: parent.height - 36

            // --- Title phase ---
            Column {
                anchors.centerIn: parent
                spacing: 16
                visible: root.game.phase === "title"

                // Before music: "Annnd Action!" button
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Ton auf Präsentations-PC\neinschalten, dann:"
                    color: "#888888"
                    font { pixelSize: 12; family: "monospace" }
                    horizontalAlignment: Text.AlignHCenter
                    visible: !root.game.musicStarted
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 180; height: 44; radius: 6
                    color: root.gold
                    visible: !root.game.musicStarted

                    Text {
                        anchors.centerIn: parent
                        text: "Annnd Action!"
                        color: "#1a1a2e"
                        font { pixelSize: 16; bold: true; family: "monospace" }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.game.musicStarted = true
                    }
                }

                // After music: "Spiel starten" button
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Spiel ist bereit"
                    color: "#cccccc"
                    font { pixelSize: 14; family: "monospace" }
                    visible: root.game.musicStarted
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#2a7a3a"
                    visible: root.game.musicStarted

                    Text {
                        anchors.centerIn: parent
                        text: "Spiel starten"
                        color: "#ffffff"
                        font { pixelSize: 16; bold: true; family: "monospace" }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.game.startGame()
                    }
                }
            }

            // --- Round Intro phase ---
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: root.game.phase === "roundIntro"

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Runde " + (root.game.currentRound + 1)
                    color: root.gold
                    font { pixelSize: 16; bold: true; family: "monospace" }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.game.currentRoundData ? root.game.currentRoundData.name : ""
                    color: "#ffffff"
                    font { pixelSize: 14; family: "monospace" }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (root.game.currentRoundData
                           ? root.game.currentRoundData.questions.length : 0) + " Fragen"
                    color: "#888888"
                    font { pixelSize: 12; family: "monospace" }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#2a7a3a"

                    Text {
                        anchors.centerIn: parent
                        text: "Runde starten"
                        color: "#ffffff"
                        font { pixelSize: 16; bold: true; family: "monospace" }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.game.startRound()
                    }
                }
            }

            // --- Mode-specific moderator controls ---
            Loader {
                id: modModeLoader
                anchors.fill: parent
                visible: root.game.phase === "question" || root.game.phase === "reveal"
                         || root.game.phase === "duelPick" || root.game.phase === "duelCounter"
                         || root.game.phase === "duelResult"
                         || root.game.phase === "console" || root.game.phase === "consoleResult"
                         || root.game.phase === "singingActive" || root.game.phase === "singingReveal"

                source: {
                    switch (root.game.currentMode) {
                    case "quiz":        return "ModeratorQuiz.qml";
                    case "pirate-duel": return "ModeratorQuiz.qml";
                    case "taste":       return "ModeratorTaste.qml";
                    case "plank-duel":  return "ModeratorPlankDuel.qml";
                    case "dos-console": return "ModeratorConsole.qml";
                    case "singing":     return "ModeratorSinging.qml";
                    default:            return "ModeratorQuiz.qml";
                    }
                }

                onLoaded: item.game = root.game
            }

            // --- Scoreboard phase ---
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: root.game.phase === "scoreboard"

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Runde abgeschlossen"
                    color: "#cccccc"
                    font { pixelSize: 14; family: "monospace" }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "S1: " + root.game.player1Score
                          + "  S2: " + root.game.player2Score
                    color: root.gold
                    font { pixelSize: 14; bold: true; family: "monospace" }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#2a4a8a"

                    Text {
                        anchors.centerIn: parent
                        text: root.game.currentRound + 1 < root.game.totalRounds
                              ? "Nächste Runde" : "Endergebnis"
                        color: "#ffffff"
                        font { pixelSize: 16; bold: true; family: "monospace" }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.game.advanceFromScoreboard()
                    }
                }
            }

            // --- Finale phase ---
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: root.game.phase === "finale"

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Spiel vorbei"
                    color: "#cccccc"
                    font { pixelSize: 14; family: "monospace" }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#8a2a3a"

                    Text {
                        anchors.centerIn: parent
                        text: "Neustart"
                        color: "#ffffff"
                        font { pixelSize: 16; bold: true; family: "monospace" }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.game.restartGame()
                    }
                }
            }
        }
    }

    SoundTodo {
        label: "UI click feedback"
        anchors { bottom: parent.bottom; right: parent.right; margins: 8 }
    }
}
