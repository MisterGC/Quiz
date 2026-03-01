import QtQuick

Item {
    id: root

    property QtObject game: null
    property var correctSound: null
    property var wrongSound: null

    readonly property color gold: "#ffcc00"
    readonly property color colCorrect: "#00e676"
    readonly property color colWrong: "#ff1744"

    // --- Singing Active: big question mark + timer ---
    Item {
        anchors.fill: parent
        visible: root.game.phase === "singingActive"

        // Animated question mark
        Text {
            id: questionMark
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -30
            text: "?"
            color: root.gold
            font { pixelSize: 200; bold: true; family: "monospace" }
            opacity: 0.9

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { to: 1.15; duration: 1500; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
            }

            SequentialAnimation on rotation {
                loops: Animation.Infinite
                NumberAnimation { to: 5; duration: 2000; easing.type: Easing.InOutSine }
                NumberAnimation { to: -5; duration: 2000; easing.type: Easing.InOutSine }
            }
        }

        // Music notes floating
        Repeater {
            model: 6

            Text {
                property real startX: Math.random() * root.width
                property real speed: 2000 + Math.random() * 3000

                x: startX
                text: ["\u266A", "\u266B", "\u266C", "\u2669", "\u266A", "\u266B"][index]
                color: root.gold
                opacity: 0.3 + Math.random() * 0.3
                font { pixelSize: 24 + Math.random() * 20; family: "monospace" }

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    PropertyAction { value: root.height + 20 }
                    NumberAnimation {
                        to: -40
                        duration: speed
                        easing.type: Easing.Linear
                    }
                }
            }
        }

        // Song number
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 20
            text: "SONG " + (root.game.currentQuestion + 1)
            color: "#888888"
            font { pixelSize: 20; family: "monospace" }
        }

        // Timer (bottom)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            visible: root.game.singingTimerStarted
            text: {
                var s = Math.ceil(root.game.timerValue / 10);
                return s < 10 ? "0" + s : s.toString();
            }
            color: {
                var secs = root.game.timerValue / 10.0;
                if (secs > 10) return root.colCorrect;
                if (secs > 5) return root.gold;
                return root.colWrong;
            }
            Behavior on color { ColorAnimation { duration: 500 } }
            font { pixelSize: 48; bold: true; family: "monospace" }
        }

        // Timer bar
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: 6
            width: root.game.timerMax > 0
                   ? parent.width * (root.game.timerValue / root.game.timerMax)
                   : 0
            color: {
                var secs = root.game.timerValue / 10.0;
                if (secs > 10) return root.colCorrect;
                if (secs > 5) return root.gold;
                return root.colWrong;
            }
            visible: root.game.singingTimerStarted
            Behavior on width { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 500 } }
        }
    }

    // --- Singing Reveal: show song + artist ---
    Item {
        anchors.fill: parent
        visible: root.game.phase === "singingReveal"

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.currentQuestionData
                      ? root.game.currentQuestionData.text : ""
                color: "#ffffff"
                font { pixelSize: 48; bold: true; family: "monospace" }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.currentQuestionData
                      ? root.game.currentQuestionData.artist : ""
                color: root.gold
                font { pixelSize: 28; italic: true; family: "monospace" }
            }

            Item { width: 1; height: 20 }

            // Points awarded
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 30

                Column {
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "SPIELER 1"
                        color: "#aaaacc"
                        font { pixelSize: 12; family: "monospace" }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "+" + root.game.player1PointsEarned
                        color: root.game.player1Correct ? root.colCorrect : root.colWrong
                        font { pixelSize: 32; bold: true; family: "monospace" }
                    }
                }

                Column {
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "SPIELER 2"
                        color: "#ccaaaa"
                        font { pixelSize: 12; family: "monospace" }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "+" + root.game.player2PointsEarned
                        color: root.game.player2Correct ? root.colCorrect : root.colWrong
                        font { pixelSize: 32; bold: true; family: "monospace" }
                    }
                }
            }
        }

        // Total scores
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            spacing: 20

            Rectangle {
                width: 160; height: 50; radius: 6
                color: "#2a4a8a"
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "SPIELER 1"
                        color: "#aaaacc"
                        font { pixelSize: 10; family: "monospace" }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.game.player1Score.toString()
                        color: "#ffffff"
                        font { pixelSize: 22; bold: true; family: "monospace" }
                    }
                }
            }
            Rectangle {
                width: 160; height: 50; radius: 6
                color: "#8a2a3a"
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "SPIELER 2"
                        color: "#ccaaaa"
                        font { pixelSize: 10; family: "monospace" }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.game.player2Score.toString()
                        color: "#ffffff"
                        font { pixelSize: 22; bold: true; family: "monospace" }
                    }
                }
            }
        }
    }
}
