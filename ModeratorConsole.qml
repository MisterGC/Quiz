import QtQuick

Item {
    id: root

    property QtObject game: null

    readonly property color gold: "#ffcc00"
    readonly property var qData: root.game ? root.game.currentQuestionData : null

    // --- Console phase ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "console"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "DOS-KONSOLE"
            color: root.gold
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        // Scenario info (data-driven from questions.md)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 10
            height: scenarioCol.height + 12
            radius: 6
            color: "#1a3a1a"
            border.color: "#00e676"
            border.width: 1

            Column {
                id: scenarioCol
                anchors.centerIn: parent
                width: parent.width - 12
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.qData ? root.qData.text : ""
                    color: "#00e676"
                    font { pixelSize: 13; bold: true; family: "monospace" }
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    width: parent.width
                    text: root.qData && root.qData.goal
                          ? "Ziel: " + root.qData.goal : ""
                    visible: text !== ""
                    color: "#aaddaa"
                    font { pixelSize: 11; family: "monospace" }
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: {
                        if (!root.qData || !root.qData.hints
                            || root.qData.hints.length === 0) return "";
                        var lines = "Hinweiskette:";
                        for (var i = 0; i < root.qData.hints.length; i++)
                            lines += "\n" + (i + 1) + ". " + root.qData.hints[i];
                        return lines;
                    }
                    visible: text !== ""
                    color: "#88aa88"
                    font { pixelSize: 10; family: "monospace" }
                    wrapMode: Text.WordWrap
                }
            }
        }

        // Open external terminal button
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 180; height: 36; radius: 6
            color: "#4a3a1a"
            border.color: root.gold; border.width: 1
            visible: root.qData && root.qData.url !== ""

            Text {
                anchors.centerIn: parent
                text: "Terminal öffnen"
                color: root.gold
                font { pixelSize: 12; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.qData && root.qData.url)
                        Qt.openUrlExternally(Qt.resolvedUrl(root.qData.url));
                }
            }
        }

        // Timer start button
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160; height: 36; radius: 6
            color: "#2a7a3a"
            visible: !root.game.timerRunning && !root.game.scenarioSolved

            Text {
                anchors.centerIn: parent
                text: "Timer starten"
                color: "#ffffff"
                font { pixelSize: 14; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.game.startConsoleTimer()
            }
        }

        // Timer display
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.game.timerRunning
            text: "Timer: " + (root.game.timerValue / 10.0).toFixed(1) + "s"
            color: "#888888"
            font { pixelSize: 11; family: "monospace" }
        }

        // Status
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.game.scenarioSolved
            text: "GESCHAFFT!"
            color: "#00e676"
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        // Override buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Rectangle {
                width: 90; height: 36; radius: 6
                color: "#2a7a3a"

                Text {
                    anchors.centerIn: parent
                    text: "Geschafft"
                    color: "#ffffff"
                    font { pixelSize: 12; bold: true; family: "monospace" }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.resolveConsole(true)
                }
            }

            Rectangle {
                width: 90; height: 36; radius: 6
                color: "#8a2a3a"

                Text {
                    anchors.centerIn: parent
                    text: "Gescheitert"
                    color: "#ffffff"
                    font { pixelSize: 12; bold: true; family: "monospace" }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.resolveConsole(false)
                }
            }
        }
    }

    // --- Console Result phase ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "consoleResult"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.player1Correct ? "GESCHAFFT!" : "GESCHEITERT"
            color: root.game.player1Correct ? "#00e676" : "#ff1744"
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S1: +" + root.game.player1PointsEarned + " Pkt."
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
                onClicked: root.game.nextConsoleStep()
            }
        }
    }
}
