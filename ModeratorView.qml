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

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Game is ready"
                    color: "#cccccc"
                    font { pixelSize: 14; family: "monospace" }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#2a7a3a"

                    Text {
                        anchors.centerIn: parent
                        text: "Start Game"
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
                    text: "Round " + (root.game.currentRound + 1)
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
                           ? root.game.currentRoundData.questions.length : 0) + " questions"
                    color: "#888888"
                    font { pixelSize: 12; family: "monospace" }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#2a7a3a"

                    Text {
                        anchors.centerIn: parent
                        text: "Start Round"
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

            // --- Question phase ---
            Column {
                anchors.centerIn: parent
                spacing: 10
                visible: root.game.phase === "question"
                width: parent.width - 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Q" + (root.game.currentQuestion + 1)
                          + " — Correct answer:"
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
                                         && root.game.currentRoundData.mode === "insult"
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
                        text: "Show Answers"
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

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.game.answerLocked ? "Player answered" : "Waiting for answer ..."
                        color: root.game.answerLocked ? root.gold : "#666666"
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
                            text: "Reveal Answer"
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
                spacing: 12
                visible: root.game.phase === "reveal"

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 140; height: 36; radius: 6
                    color: root.game.lastCorrect ? "#00e676" : "#ff1744"

                    Text {
                        anchors.centerIn: parent
                        text: root.game.lastCorrect ? "CORRECT!" : "WRONG!"
                        color: "#ffffff"
                        font { pixelSize: 16; bold: true; family: "monospace" }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "+" + root.game.lastPointsEarned + " pts"
                    color: root.gold
                    font { pixelSize: 14; family: "monospace" }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Score: " + root.game.score
                    color: "#cccccc"
                    font { pixelSize: 12; family: "monospace" }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#2a4a8a"

                    Text {
                        anchors.centerIn: parent
                        text: "Next"
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

            // --- Scoreboard phase ---
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: root.game.phase === "scoreboard"

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Round complete"
                    color: "#cccccc"
                    font { pixelSize: 14; family: "monospace" }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Score: " + root.game.score
                    color: root.gold
                    font { pixelSize: 16; bold: true; family: "monospace" }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#2a4a8a"

                    Text {
                        anchors.centerIn: parent
                        text: root.game.currentRound + 1 < root.game.totalRounds
                              ? "Next Round" : "Final Results"
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
                    text: "Game Over"
                    color: "#cccccc"
                    font { pixelSize: 14; family: "monospace" }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160; height: 44; radius: 6
                    color: "#8a2a3a"

                    Text {
                        anchors.centerIn: parent
                        text: "Restart"
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
