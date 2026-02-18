import QtQuick

Item {
    id: root

    required property QtObject game

    readonly property color gold: "#ffcc00"
    readonly property color panelBg: "#1a1a2e"
    readonly property var answerColors: ["#2a4a8a", "#8a5a2a", "#2a7a3a", "#8a2a3a"]

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
            color: "#1a2a3e"

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: "PLAYER"
                color: root.gold
                font { pixelSize: 14; bold: true; family: "monospace" }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 12
                text: "Score: " + root.game.score
                color: "#cccccc"
                font { pixelSize: 13; family: "monospace" }
            }
        }

        // Content area
        Item {
            width: parent.width
            height: parent.height - 36

            // --- Waiting (title / roundIntro / scoreboard) ---
            Column {
                anchors.centerIn: parent
                spacing: 10
                visible: root.game.phase === "title"
                         || root.game.phase === "roundIntro"
                         || root.game.phase === "scoreboard"

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        if (root.game.phase === "title") return "Waiting for game ...";
                        if (root.game.phase === "roundIntro") return "Get ready!";
                        return "Waiting for next round ...";
                    }
                    color: "#888888"
                    font { pixelSize: 14; family: "monospace" }
                }

                SoundTodo {
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Ambient lobby loop"
                    visible: root.game.phase === "title"
                }
            }

            // --- Question phase ---
            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                visible: root.game.phase === "question"

                // Timer bar — fades in when timer starts, fades out when it stops
                Item {
                    width: parent.width
                    height: 8
                    opacity: root.game.timerRunning ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 400 } }

                    Rectangle {
                        anchors.fill: parent
                        radius: 4; color: "#333333"
                    }
                    Rectangle {
                        width: parent.width * (root.game.timerMax > 0
                               ? root.game.timerValue / root.game.timerMax : 0)
                        height: parent.height
                        radius: 4
                        color: {
                            var ratio = root.game.timerMax > 0
                                        ? root.game.timerValue / root.game.timerMax : 0;
                            if (ratio > 0.5) return "#00e676";
                            if (ratio > 0.25) return "#ffcc00";
                            return "#ff1744";
                        }
                        Behavior on width { NumberAnimation { duration: 100 } }
                        Behavior on color { ColorAnimation { duration: 500 } }
                    }
                }

                // Answer buttons 2x2
                Grid {
                    id: buttonGrid
                    width: parent.width
                    columns: 2
                    spacing: 6

                    Repeater {
                        model: root.game.currentQuestionData
                               ? root.game.currentQuestionData.answers : []

                        Rectangle {
                            id: btn
                            width: (buttonGrid.width - buttonGrid.spacing) / 2
                            height: (buttonGrid.parent.height - buttonGrid.y
                                     - buttonGrid.spacing - 30) / 2
                            radius: 6
                            opacity: root.game.answersRevealed ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            color: {
                                if (root.game.answerLocked && root.game.playerAnswer === index)
                                    return Qt.lighter(root.answerColors[index], 1.3);
                                if (root.game.answerLocked)
                                    return Qt.darker(root.answerColors[index], 1.5);
                                return root.answerColors[index];
                            }
                            border.color: root.game.answerLocked && root.game.playerAnswer === index
                                          ? root.gold : "transparent"
                            border.width: root.game.answerLocked && root.game.playerAnswer === index
                                          ? 2 : 0

                            Behavior on color { ColorAnimation { duration: 200 } }

                            readonly property bool isInsult: root.game.currentRoundData
                                                             && root.game.currentRoundData.mode === "insult"
                            readonly property string prefix: isInsult
                                                             ? ["1", "2", "3", "4"][index]
                                                             : ["A", "B", "C", "D"][index]

                            Column {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 2

                                Text {
                                    text: btn.prefix
                                    color: "#ffffff"
                                    font { pixelSize: 18; bold: true; family: "monospace" }
                                }
                                Text {
                                    width: parent.width
                                    text: modelData
                                    color: "#ffffff"
                                    font { pixelSize: 11; family: "monospace" }
                                    wrapMode: Text.WordWrap
                                    elide: Text.ElideRight
                                    maximumLineCount: 3
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: root.game.answerLocked
                                             ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.game.answerLocked)
                                        root.game.submitAnswer(index);
                                }
                            }
                        }
                    }
                }

                SoundTodo {
                    label: "Lock-in beep"
                    visible: root.game.answerLocked
                }
            }

            // --- Reveal phase ---
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: root.game.phase === "reveal"

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 120; height: 32; radius: 6
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
                    font { pixelSize: 18; bold: true; family: "monospace" }
                }

                SoundTodo {
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: root.game.lastCorrect ? "Correct sound" : "Wrong sound"
                }
            }

            // --- Finale phase ---
            Column {
                anchors.centerIn: parent
                spacing: 10
                visible: root.game.phase === "finale"

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "GAME OVER"
                    color: root.gold
                    font { pixelSize: 18; bold: true; family: "monospace" }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.game.score.toString()
                    color: "#ffffff"
                    font { pixelSize: 48; bold: true; family: "monospace" }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.game.score + " / " + root.game.maxScore
                    color: "#888888"
                    font { pixelSize: 12; family: "monospace" }
                }
            }
        }
    }
}
