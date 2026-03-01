import QtQuick

Item {
    id: root

    property QtObject game: null

    readonly property color gold: "#ffcc00"

    // --- Duel Pick phase ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "duelPick"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "PLANKEN-DUELL"
            color: root.gold
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Runde " + (root.game.duelTurn + 1)
                  + " | S1:" + root.game.plankBasti
                  + " S2:" + root.game.plankCrowd
            color: "#888888"
            font { pixelSize: 11; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Crowd w\u00e4hlt Beleidigung..."
            color: "#cccccc"
            font { pixelSize: 12; family: "monospace" }
        }
    }

    // --- Duel Counter phase ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "duelCounter"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "BASTI KONTERT"
            color: root.gold
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        // Show correct answer
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 10
            height: correctDuelText.height + 16
            radius: 6
            color: "#1a3a1a"
            border.color: "#00e676"
            border.width: 1

            Text {
                id: correctDuelText
                anchors.centerIn: parent
                width: parent.width - 16
                text: {
                    var q = root.game.currentDuelData;
                    if (!q) return "";
                    return (q.correct + 1) + ": " + q.answers[q.correct];
                }
                color: "#00e676"
                font { pixelSize: 12; bold: true; family: "monospace" }
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Timer: " + (root.game.timerValue / 10.0).toFixed(1) + "s"
            color: "#888888"
            font { pixelSize: 11; family: "monospace" }
            visible: root.game.timerRunning
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S1: " + (root.game.player1Locked ? "\u2713" : "...")
            color: root.game.player1Locked ? root.gold : "#666666"
            font { pixelSize: 12; family: "monospace" }
        }
    }

    // --- Duel Result phase ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "duelResult"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.player1Correct ? "RICHTIG!" : "FALSCH!"
            color: root.game.player1Correct ? "#00e676" : "#ff1744"
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S1:" + root.game.plankBasti
                  + " S2:" + root.game.plankCrowd
            color: "#cccccc"
            font { pixelSize: 12; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.game.duelWinner !== ""
            text: {
                if (root.game.duelWinner === "basti") return "Basti gewinnt!";
                if (root.game.duelWinner === "crowd") return "Crowd gewinnt!";
                return "Unentschieden!";
            }
            color: root.gold
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160; height: 44; radius: 6
            color: "#2a4a8a"

            Text {
                anchors.centerIn: parent
                text: root.game.duelWinner !== "" ? "Scoreboard" : "Weiter"
                color: "#ffffff"
                font { pixelSize: 16; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.game.nextDuelStep()
            }
        }
    }
}
