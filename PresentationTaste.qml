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

    property var qData: root.game.currentQuestionData
    property bool isReveal: root.game.phase === "reveal"
    property real displayScore1: root.game.player1Score
    property real displayScore2: root.game.player2Score

    Behavior on displayScore1 { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
    Behavior on displayScore2 { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

    // Countdown (upper-left)
    Text {
        x: 20; y: 15
        rotation: -8
        text: {
            var s = Math.ceil(root.game.timerValue / 10);
            return s < 10 ? "0" + s : s.toString();
        }
        visible: root.game.phase === "question"
        opacity: root.game.timerRunning ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }
        color: {
            var secs = root.game.timerValue / 10.0;
            if (secs > 7) return root.colCorrect;
            if (secs > 3) return root.gold;
            return root.colWrong;
        }
        Behavior on color { ColorAnimation { duration: 500 } }
        font { pixelSize: 48; bold: true; family: "monospace" }
    }

    // Question text at top
    Text {
        id: questionText
        width: parent.width - 60
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        y: 20
        text: root.qData ? root.qData.text : ""
        color: "#ffffff"
        wrapMode: Text.WordWrap
        font { pixelSize: 26; bold: true; family: "monospace" }
    }

    // Two large cards side by side
    Row {
        id: cardRow
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.25
        spacing: 0
        visible: root.game.answersRevealed || root.isReveal

        opacity: (root.game.answersRevealed || root.isReveal) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        // Option A
        Rectangle {
            width: root.width * 0.38
            height: root.height * 0.4
            radius: 12
            color: {
                if (!root.isReveal) return "#2a3a5a";
                if (root.game.player1Correct) return "#1a3a1a";
                return "#3a1a1a";
            }
            border.width: root.isReveal && root.game.player1Answer === 0 ? 3 : 1
            border.color: {
                if (root.isReveal && root.game.player1Answer === 0) return root.colA;
                if (root.isReveal && root.game.player2Answer === 0) return root.colD;
                return "#333355";
            }
            Behavior on color { ColorAnimation { duration: 400 } }
            Behavior on border.color { ColorAnimation { duration: 400 } }

            Column {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.qData && root.qData.answers.length > 0
                          ? root.qData.answers[0] : ""
                    color: "#ffffff"
                    font { pixelSize: 28; bold: true; family: "monospace" }
                }

                // Show who chose this on reveal
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    visible: root.isReveal

                    Rectangle {
                        width: 36; height: 22; radius: 4
                        color: root.colA
                        visible: root.game.player1Answer === 0
                        Text {
                            anchors.centerIn: parent
                            text: "S1"
                            color: "#ffffff"
                            font { pixelSize: 11; bold: true; family: "monospace" }
                        }
                    }
                    Rectangle {
                        width: 36; height: 22; radius: 4
                        color: root.colD
                        visible: root.game.player2Answer === 0
                        Text {
                            anchors.centerIn: parent
                            text: "S2"
                            color: "#ffffff"
                            font { pixelSize: 11; bold: true; family: "monospace" }
                        }
                    }
                }
            }
        }

        // VS separator
        Item {
            width: root.width * 0.08
            height: root.height * 0.4

            Text {
                anchors.centerIn: parent
                text: "VS"
                color: root.gold
                font { pixelSize: 32; bold: true; family: "monospace" }
                opacity: 0.8
            }
        }

        // Option B
        Rectangle {
            width: root.width * 0.38
            height: root.height * 0.4
            radius: 12
            color: {
                if (!root.isReveal) return "#2a3a5a";
                if (root.game.player1Correct) return "#1a3a1a";
                return "#3a1a1a";
            }
            border.width: root.isReveal && root.game.player1Answer === 1 ? 3 : 1
            border.color: {
                if (root.isReveal && root.game.player1Answer === 1) return root.colA;
                if (root.isReveal && root.game.player2Answer === 1) return root.colD;
                return "#333355";
            }
            Behavior on color { ColorAnimation { duration: 400 } }
            Behavior on border.color { ColorAnimation { duration: 400 } }

            Column {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.qData && root.qData.answers.length > 1
                          ? root.qData.answers[1] : ""
                    color: "#ffffff"
                    font { pixelSize: 28; bold: true; family: "monospace" }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    visible: root.isReveal

                    Rectangle {
                        width: 36; height: 22; radius: 4
                        color: root.colA
                        visible: root.game.player1Answer === 1
                        Text {
                            anchors.centerIn: parent
                            text: "S1"
                            color: "#ffffff"
                            font { pixelSize: 11; bold: true; family: "monospace" }
                        }
                    }
                    Rectangle {
                        width: 36; height: 22; radius: 4
                        color: root.colD
                        visible: root.game.player2Answer === 1
                        Text {
                            anchors.centerIn: parent
                            text: "S2"
                            color: "#ffffff"
                            font { pixelSize: 11; bold: true; family: "monospace" }
                        }
                    }
                }
            }
        }
    }

    // Match result text
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: cardRow.y + cardRow.height + 20
        visible: root.isReveal
        text: root.game.player1Correct ? "MATCH! +100" : "KEIN MATCH"
        color: root.game.player1Correct ? root.colCorrect : root.colWrong
        font { pixelSize: 36; bold: true; family: "monospace" }
        opacity: root.isReveal ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    // Score bar at bottom
    Row {
        id: scoreBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        spacing: 20

        Rectangle {
            width: 160; height: 50; radius: 6
            color: root.game.player1Locked && root.game.phase === "question"
                   ? Qt.lighter(root.colA, 1.6) : root.colA
            border.width: root.game.player1Locked
                          && root.game.phase === "question" ? 2 : 0
            border.color: root.gold
            Behavior on color { ColorAnimation { duration: 300 } }

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
                    text: Math.round(root.displayScore1).toString()
                    color: "#ffffff"
                    font { pixelSize: 22; bold: true; family: "monospace" }
                }
            }
        }

        Rectangle {
            width: 160; height: 50; radius: 6
            color: root.game.player2Locked && root.game.phase === "question"
                   ? Qt.lighter(root.colD, 1.6) : root.colD
            border.width: root.game.player2Locked
                          && root.game.phase === "question" ? 2 : 0
            border.color: root.gold
            Behavior on color { ColorAnimation { duration: 300 } }

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
                    text: Math.round(root.displayScore2).toString()
                    color: "#ffffff"
                    font { pixelSize: 22; bold: true; family: "monospace" }
                }
            }
        }
    }

    // Floating points - Player 1
    Text {
        id: floatingPoints1
        x: scoreBar.x + 80 - width / 2
        y: scoreBar.y - 50
        text: "+" + root.game.player1PointsEarned
        color: root.game.player1Correct ? root.colCorrect : root.colWrong
        font { pixelSize: 32; bold: true; family: "monospace" }
        opacity: 0
        scale: 1.5
        transformOrigin: Item.Bottom
    }

    // Floating points - Player 2
    Text {
        id: floatingPoints2
        x: scoreBar.x + 260 - width / 2
        y: scoreBar.y - 50
        text: "+" + root.game.player2PointsEarned
        color: root.game.player2Correct ? root.colCorrect : root.colWrong
        font { pixelSize: 32; bold: true; family: "monospace" }
        opacity: 0
        scale: 1.5
        transformOrigin: Item.Bottom
    }

    SequentialAnimation {
        id: pointRevealSequence

        ScriptAction {
            script: {
                if (root.game.player1Correct) {
                    if (root.correctSound) root.correctSound.play();
                } else {
                    if (root.wrongSound) root.wrongSound.play();
                }
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: floatingPoints1; property: "opacity"
                from: 0; to: 1.0; duration: 300
            }
            NumberAnimation {
                target: floatingPoints1; property: "scale"
                from: 1.5; to: 1.0; duration: 300
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: floatingPoints2; property: "opacity"
                from: 0; to: 1.0; duration: 300
            }
            NumberAnimation {
                target: floatingPoints2; property: "scale"
                from: 1.5; to: 1.0; duration: 300
                easing.type: Easing.OutBack
            }
        }
        PauseAnimation { duration: 500 }
        ScriptAction {
            script: {
                root.game.awardPoints(0);
                root.game.awardPoints(1);
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: floatingPoints1; property: "scale"
                to: 0.3; duration: 400; easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: floatingPoints1; property: "opacity"
                to: 0; duration: 400
            }
            NumberAnimation {
                target: floatingPoints1; property: "y"
                to: scoreBar.y; duration: 400; easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: floatingPoints2; property: "scale"
                to: 0.3; duration: 400; easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: floatingPoints2; property: "opacity"
                to: 0; duration: 400
            }
            NumberAnimation {
                target: floatingPoints2; property: "y"
                to: scoreBar.y; duration: 400; easing.type: Easing.InCubic
            }
        }
    }

    Connections {
        target: root.game
        function onPointRevealStarted() {
            floatingPoints1.y = scoreBar.y - 50;
            floatingPoints1.opacity = 0;
            floatingPoints1.scale = 1.5;
            floatingPoints2.y = scoreBar.y - 50;
            floatingPoints2.opacity = 0;
            floatingPoints2.scale = 1.5;
            pointRevealSequence.restart();
        }
        function onPhaseChanged() {
            if (root.game.phase !== "reveal")
                pointRevealSequence.stop();
        }
    }
}
