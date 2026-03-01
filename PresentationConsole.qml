import QtQuick

Item {
    id: root

    property QtObject game: null
    property var correctSound: null
    property var wrongSound: null

    readonly property color gold: "#ffcc00"
    readonly property color colCorrect: "#00e676"
    readonly property color colWrong: "#ff1744"

    // --- Console phase: fake DOS terminal ---
    Item {
        anchors.fill: parent
        visible: root.game.phase === "console"

        // CRT background
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

        // Timer (top-right)
        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            visible: root.game.timerRunning
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
            font { pixelSize: 20; bold: true; family: "monospace" }
        }

        // Scenario title (top-left)
        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 10
            text: root.game.currentQuestionData
                  ? root.game.currentQuestionData.text : ""
            color: "#888888"
            font { pixelSize: 14; family: "monospace" }
        }

        // Scrollable output area
        Flickable {
            id: outputFlick
            anchors.fill: parent
            anchors.topMargin: 35
            anchors.bottomMargin: 40
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            contentHeight: outputText.height
            clip: true
            flickableDirection: Flickable.VerticalFlick

            Text {
                id: outputText
                width: outputFlick.width
                text: root.game.consoleOutput
                color: "#c0c0c0"
                font { pixelSize: 14; family: "monospace" }
                wrapMode: Text.WrapAnywhere
            }

            onContentHeightChanged: {
                if (contentHeight > height)
                    contentY = contentHeight - height;
            }
        }

        // Command input line
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 36
            color: "#111111"

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 0

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "C:\\>"
                    color: "#c0c0c0"
                    font { pixelSize: 14; family: "monospace" }
                }

                TextInput {
                    id: cmdInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 40
                    color: "#ffffff"
                    font { pixelSize: 14; family: "monospace" }
                    focus: root.game.phase === "console"
                    cursorVisible: true

                    Keys.onReturnPressed: {
                        if (text.trim() !== "") {
                            root.game.submitConsoleCommand(text);
                            text = "";
                        }
                    }
                }
            }

            // Blinking cursor indicator
            Rectangle {
                anchors.bottom: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 10
                width: parent.width - 20
                height: 1
                color: "#333333"
            }
        }

        // Success overlay
        Rectangle {
            anchors.fill: parent
            color: "#001100"
            opacity: root.game.scenarioSolved ? 0.3 : 0
            Behavior on opacity { NumberAnimation { duration: 500 } }
        }

        Text {
            anchors.centerIn: parent
            visible: root.game.scenarioSolved
            text: "GESCHAFFT!"
            color: root.colCorrect
            font { pixelSize: 64; bold: true; family: "monospace" }
            opacity: root.game.scenarioSolved ? 1 : 0
            scale: root.game.scenarioSolved ? 1 : 2
            Behavior on opacity { NumberAnimation { duration: 400 } }
            Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
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
