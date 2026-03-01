import QtQuick

Item {
    id: root

    property QtObject game: null
    property var correctSound: null
    property var wrongSound: null

    readonly property color gold: "#ffcc00"
    readonly property color colCorrect: "#00e676"
    readonly property color colWrong: "#ff1744"
    readonly property color colA: "#2a4a8a"
    readonly property color colD: "#8a2a3a"

    // Plank visualization
    Item {
        id: plankArea
        anchors.horizontalCenter: parent.horizontalCenter
        y: 30
        width: parent.width * 0.85
        height: 120

        // Battle line: both fighters move as a pair
        readonly property real stepSize: 0.0875
        readonly property real pairCenter: 0.5
            - stepSize * ((root.game ? root.game.plankBasti : 0)
                        - (root.game ? root.game.plankCrowd : 0))

        // Water background
        Rectangle {
            anchors.fill: parent
            color: "#0a2a4a"
            radius: 8
            opacity: 0.5
        }

        // Plank beam
        Rectangle {
            id: plank
            anchors.centerIn: parent
            width: (root.game && root.game.plankShrunk) ? 88 : parent.width * 0.8
            height: 20
            radius: 4
            color: "#8B4513"
            border.color: "#A0522D"
            border.width: 2
            Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutBounce } }
        }

        // Position markers on plank
        Repeater {
            model: 5

            Rectangle {
                x: plank.x + plank.width * (index + 0.5) / 5 - 2
                y: plank.y + plank.height
                width: 4; height: 6
                color: "#A0522D"
                opacity: 0.6
            }
        }

        // Basti sprite (left of battle line, follows the pair)
        Rectangle {
            id: bastiSprite
            property bool fallen: root.game && root.game.duelWinner === "crowd"
            width: 40; height: 50; radius: 6
            color: root.colA
            border.color: "#ffffff"
            border.width: 2
            x: plank.x + plankArea.pairCenter * plank.width - width - 4
            y: fallen ? plank.y + 10 : plank.y - height
            rotation: fallen ? 90 : 0
            Behavior on x { NumberAnimation { duration: 500; easing.type: Easing.OutBounce } }
            Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.InQuad } }
            Behavior on rotation { NumberAnimation { duration: 400; easing.type: Easing.InQuad } }

            Column {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u2694"
                    font.pixelSize: 18
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "S1"
                    color: "#ffffff"
                    font { pixelSize: 10; bold: true; family: "monospace" }
                }
            }
        }

        // Crowd sprite (right of battle line, follows the pair)
        Rectangle {
            id: crowdSprite
            property bool fallen: root.game && root.game.duelWinner === "basti"
            width: 40; height: 50; radius: 6
            color: root.colD
            border.color: "#ffffff"
            border.width: 2
            x: plank.x + plankArea.pairCenter * plank.width + 4
            y: fallen ? plank.y + 10 : plank.y - height
            rotation: fallen ? -90 : 0
            Behavior on x { NumberAnimation { duration: 500; easing.type: Easing.OutBounce } }
            Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.InQuad } }
            Behavior on rotation { NumberAnimation { duration: 400; easing.type: Easing.InQuad } }

            Column {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u2694"
                    font.pixelSize: 18
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "S2"
                    color: "#ffffff"
                    font { pixelSize: 10; bold: true; family: "monospace" }
                }
            }
        }

        // Turn counter
        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 4
            text: "Runde " + (root.game.duelTurn + 1)
            color: "#888888"
            font { pixelSize: 12; family: "monospace" }
        }
    }

    // --- Duel Pick: crowd chooses insult ---
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: plankArea.y + plankArea.height + 20
        width: parent.width - 60
        spacing: 12
        visible: root.game.phase === "duelPick"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "CROWD W\u00c4HLT BELEIDIGUNG"
            color: root.gold
            font { pixelSize: 20; bold: true; family: "monospace" }
        }

        Repeater {
            model: root.game.insultChoices

            Rectangle {
                width: parent.width
                height: insultText.height + 16
                radius: 8
                color: "#2a2a4a"
                border.color: "#555577"
                border.width: 1

                Text {
                    id: insultText
                    anchors.centerIn: parent
                    width: parent.width - 20
                    text: {
                        var qs = root.game.currentRoundData
                                 ? root.game.currentRoundData.questions : [];
                        var idx = modelData;
                        return (idx >= 0 && idx < qs.length)
                               ? qs[idx].text : "";
                    }
                    color: "#ffffff"
                    font { pixelSize: 18; italic: true; family: "monospace" }
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    // --- Duel Counter: Basti picks counter ---
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: plankArea.y + plankArea.height + 20
        width: parent.width - 60
        spacing: 12
        visible: root.game.phase === "duelCounter"

        // Show the chosen insult
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: root.game.currentDuelData
                  ? root.game.currentDuelData.text : ""
            color: root.gold
            font { pixelSize: 22; italic: true; bold: true; family: "monospace" }
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        // Timer
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.game.timerRunning
            text: {
                var s = Math.ceil(root.game.timerValue / 10);
                return s < 10 ? "0" + s : s.toString();
            }
            color: {
                var secs = root.game.timerValue / 10.0;
                if (secs > 7) return root.colCorrect;
                if (secs > 3) return root.gold;
                return root.colWrong;
            }
            font { pixelSize: 36; bold: true; family: "monospace" }
        }

        // Counter options
        Column {
            width: parent.width
            spacing: 8

            Repeater {
                model: root.game.currentDuelData
                       ? root.game.currentDuelData.answers : []

                Rectangle {
                    width: parent.width
                    height: counterText.height + 12
                    radius: 6
                    color: {
                        if (root.game.player1Locked
                            && root.game.player1Answer === index)
                            return "#3a3a6a";
                        return "#2a2a3a";
                    }
                    border.color: root.game.player1Locked
                                  && root.game.player1Answer === index
                                  ? root.gold : "#444466"
                    border.width: 1

                    Text {
                        id: counterText
                        anchors.centerIn: parent
                        width: parent.width - 16
                        text: (index + 1) + ". " + modelData
                        color: "#ffffff"
                        font { pixelSize: 16; family: "monospace" }
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    // --- Duel Result ---
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: plankArea.y + plankArea.height + 20
        width: parent.width - 60
        spacing: 16
        visible: root.game.phase === "duelResult"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.player1Correct
                  ? "TOUCHE! Basti kontert!" : "DANEBEN!"
            color: root.game.player1Correct ? root.colCorrect : root.colWrong
            font { pixelSize: 28; bold: true; family: "monospace" }
        }

        // Show correct counter
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            visible: !root.game.player1Correct && root.game.currentDuelData
            text: {
                var q = root.game.currentDuelData;
                if (!q) return "";
                return "Richtig: " + q.answers[q.correct];
            }
            color: root.colCorrect
            font { pixelSize: 14; italic: true; family: "monospace" }
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        // Winner announcement
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.game.duelWinner !== ""
            text: {
                if (root.game.duelWinner === "basti") return "BASTI GEWINNT! +200";
                if (root.game.duelWinner === "crowd") return "CROWD GEWINNT! +200";
                return "UNENTSCHIEDEN! +100/+100";
            }
            color: root.gold
            font { pixelSize: 24; bold: true; family: "monospace" }
        }

        // Shrunk warning
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.game.plankShrunk && root.game.duelWinner === ""
            text: "PLANKE SCHRUMPFT! Letzte Chance!"
            color: root.colWrong
            font { pixelSize: 18; bold: true; family: "monospace" }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
            }
        }
    }
}
