import QtQuick

Item {
    id: root

    property QtObject game: null

    readonly property color gold: "#ffcc00"
    readonly property color colCorrect: "#00e676"
    readonly property color colWrong: "#ff1744"

    readonly property int totalPairs: game && game.currentRoundData
                                      ? game.currentRoundData.questions.length : 0

    // --- blitzReady: "Blitz starten" ---
    Column {
        anchors.centerIn: parent
        spacing: 10
        visible: root.game.phase === "blitzReady"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "GESCHMACKS-BLITZ"
            color: root.gold
            font { pixelSize: 16; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.totalPairs + " Paare \u2014 je 5 Sek."
            color: "#aaaaaa"
            font { pixelSize: 12; family: "monospace" }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 180; height: 48; radius: 6
            color: "#2a7a3a"

            Text {
                anchors.centerIn: parent
                text: "Blitz starten"
                color: "#ffffff"
                font { pixelSize: 16; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.game.startBlitz()
            }
        }
    }

    // --- blitzPair / blitzReveal: Status display ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "blitzPair"
                 || root.game.phase === "blitzReveal"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "PAAR " + (root.game.currentQuestion + 1) + "/" + root.totalPairs
            color: root.gold
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                var r = root.game.blitzResults;
                var matches = 0;
                for (var i = 0; i < r.length; i++)
                    if (r[i].matched) matches++;
                return "Matches: " + matches + "/" + r.length;
            }
            color: "#aaaaaa"
            font { pixelSize: 12; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.phase === "blitzPair"
                  ? "S1: " + (root.game.player1Locked ? "\u2713" : "...")
                    + "  S2: " + (root.game.player2Locked ? "\u2713" : "...")
                  : ""
            color: (root.game.player1Locked && root.game.player2Locked)
                   ? root.gold : "#666666"
            font { pixelSize: 12; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (root.game.timerValue / 10.0).toFixed(1) + "s"
            color: "#888888"
            font { pixelSize: 11; family: "monospace" }
            visible: root.game.timerRunning
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.game.phase === "blitzReveal"
            text: {
                var r = root.game.blitzResults;
                if (r.length === 0) return "";
                var last = r[r.length - 1];
                if (last.bastiAnswer < 0 || last.crowdAnswer < 0)
                    return "ZU LANGSAM";
                return last.matched ? "JUBEL!" : "OHHHH";
            }
            color: {
                var r = root.game.blitzResults;
                if (r.length === 0) return "#ffffff";
                var last = r[r.length - 1];
                if (last.bastiAnswer < 0 || last.crowdAnswer < 0)
                    return "#ff9800";
                return last.matched ? root.colCorrect : root.colWrong;
            }
            font { pixelSize: 18; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "(L\u00e4uft automatisch)"
            color: "#555555"
            font { pixelSize: 10; italic: true; family: "monospace" }
        }
    }

    // --- blitzDone: "Zusammenfassung" button ---
    Column {
        anchors.centerIn: parent
        spacing: 10
        visible: root.game.phase === "blitzDone"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "BLITZ VORBEI"
            color: root.gold
            font { pixelSize: 16; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.blitzMatchCount + "/" + root.totalPairs
                  + " \u00dcbereinstimmungen"
            color: "#aaaaaa"
            font { pixelSize: 12; family: "monospace" }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200; height: 48; radius: 6
            color: "#2a4a8a"

            Text {
                anchors.centerIn: parent
                text: "Zusammenfassung"
                color: "#ffffff"
                font { pixelSize: 16; bold: true; family: "monospace" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.game.startBlitzSummary()
            }
        }
    }

    // --- blitzSummary: auto-scrolling ---
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.game.phase === "blitzSummary"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ZUSAMMENFASSUNG..."
            color: root.gold
            font { pixelSize: 14; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (root.game.timerValue / 10.0).toFixed(1) + "s"
            color: "#888888"
            font { pixelSize: 11; family: "monospace" }
        }
    }

    // --- blitzSummaryDone: "Weiter" button ---
    Column {
        anchors.centerIn: parent
        spacing: 10
        visible: root.game.phase === "blitzSummaryDone"
        width: parent.width - 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.blitzMatchCount + "/" + root.totalPairs
                  + " MATCHES"
            color: root.gold
            font { pixelSize: 16; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "+" + (root.game.blitzMatchCount * 50) + " Punkte f\u00fcr beide"
            color: "#cccccc"
            font { pixelSize: 12; family: "monospace" }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160; height: 48; radius: 6
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
                onClicked: root.game.advanceFromBlitzSummary()
            }
        }
    }
}
