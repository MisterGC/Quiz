import QtQuick

Item {
    id: root

    property QtObject game: null
    property var correctSound: null
    property var wrongSound: null

    readonly property color colA: "#2a4a8a"
    readonly property color colB: "#8a5a2a"
    readonly property color colC: "#2a7a3a"
    readonly property color colD: "#8a2a3a"
    readonly property color colCorrect: "#00e676"
    readonly property color colWrong: "#ff1744"
    readonly property color gold: "#ffcc00"

    property var qData: root.game.currentQuestionData
    property bool isInsult: root.game.currentRoundData
                            ? root.game.currentRoundData.mode === "pirate-duel"
                              || root.game.currentRoundData.mode === "plank-duel" : false
    property bool isReveal: root.game.phase === "reveal"
    property real displayScore1: root.game.player1Score
    property real displayScore2: root.game.player2Score
    property bool showRoast: false

    Behavior on displayScore1 { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
    Behavior on displayScore2 { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

    // Background question number (large, faint)
    Text {
        anchors.centerIn: parent
        text: (root.game.currentQuestion + 1).toString()
        color: "#ffffff"
        opacity: 0.06
        font { pixelSize: 280; bold: true; family: "monospace" }
    }

    // Countdown number (upper-left, rotated)
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

    // Insult round header
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 8
        visible: root.isInsult && root.game.answersRevealed
        text: "\u2694 BELEIDIGUNGSDUELL \u2694"
        color: root.gold
        font { pixelSize: 18; bold: true; family: "monospace" }
    }

    // Question text — animates between centered (big) and top (small)
    Text {
        id: questionText
        width: parent.width - 60
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: root.qData ? root.qData.text : ""
        color: "#ffffff"
        wrapMode: Text.WordWrap
        font {
            pixelSize: root.isInsult ? 30 : 28
            bold: true
            italic: root.isInsult
            family: "monospace"
        }

        y: (root.game.answersRevealed || root.isReveal)
           ? 30 : parent.height * 0.3
        scale: (root.game.answersRevealed || root.isReveal)
               ? 0.6 : 1.0
        transformOrigin: Item.Top

        Behavior on y { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
    }

    // Vertical answer list
    Column {
        id: answerList
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.right: parent.right
        anchors.rightMargin: 50
        y: parent.height * 0.35
        spacing: 18
        opacity: (root.game.answersRevealed || root.isReveal) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        Repeater {
            model: root.qData ? root.qData.answers : []

            Item {
                width: answerList.width
                height: Math.max(answerLetterText.implicitHeight,
                                 answerText.implicitHeight) + 12

                readonly property bool isCorrect: root.qData
                                                  && index === root.qData.correct
                readonly property bool isChosen1: index === root.game.player1Answer
                readonly property bool isChosen2: index === root.game.player2Answer
                readonly property color letterColor: [root.colA, root.colB,
                                                      root.colC, root.colD][index]
                readonly property string prefix: root.isInsult
                                                 ? ["1", "2", "3", "4"][index]
                                                 : ["A", "B", "C", "D"][index]

                // Letter badge
                Text {
                    id: answerLetterText
                    anchors.verticalCenter: parent.verticalCenter
                    text: parent.prefix
                    color: {
                        if (!root.isReveal) return parent.letterColor;
                        if (parent.isCorrect) return root.colCorrect;
                        if ((parent.isChosen1 || parent.isChosen2) && !parent.isCorrect)
                            return root.colWrong;
                        return "#444444";
                    }
                    font { pixelSize: 30; bold: true; family: "monospace" }
                    Behavior on color { ColorAnimation { duration: 300 } }
                }

                // Answer text
                Text {
                    id: answerText
                    anchors.left: answerLetterText.right
                    anchors.leftMargin: 14
                    anchors.right: choiceTags.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData
                    color: {
                        if (!root.isReveal) return "#ffffff";
                        if (parent.isCorrect) return root.colCorrect;
                        if ((parent.isChosen1 || parent.isChosen2) && !parent.isCorrect)
                            return root.colWrong;
                        return "#555555";
                    }
                    font {
                        pixelSize: 26
                        bold: root.isReveal && parent.isCorrect
                        family: "monospace"
                        italic: root.isInsult
                    }
                    wrapMode: Text.WordWrap
                    Behavior on color { ColorAnimation { duration: 300 } }
                }

                // Player choice pills
                Row {
                    id: choiceTags
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Rectangle {
                        width: 28; height: 18; radius: 4
                        color: parent.parent.isChosen1 && root.isReveal
                               ? root.colA : "#1a1a2e"
                        opacity: parent.parent.isChosen1 && root.isReveal
                                 ? 1.0 : 0.2
                        Behavior on color { ColorAnimation { duration: 300 } }
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        Text {
                            anchors.centerIn: parent
                            text: "S1"
                            color: "#ffffff"
                            font { pixelSize: 10; bold: true; family: "monospace" }
                        }
                    }
                    Rectangle {
                        width: 28; height: 18; radius: 4
                        color: parent.parent.isChosen2 && root.isReveal
                               ? root.colD : "#1a1a2e"
                        opacity: parent.parent.isChosen2 && root.isReveal
                                 ? 1.0 : 0.2
                        Behavior on color { ColorAnimation { duration: 300 } }
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        Text {
                            anchors.centerIn: parent
                            text: "S2"
                            color: "#ffffff"
                            font { pixelSize: 10; bold: true; family: "monospace" }
                        }
                    }
                }
            }
        }
    }

    // Score bar at bottom
    Row {
        id: scoreBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        spacing: 20

        // Player 1 score
        Rectangle {
            width: 160; height: 50; radius: 6
            color: root.game.player1Locked && root.game.phase === "question"
                   ? Qt.lighter(root.colA, 1.6) : root.colA
            border.width: root.game.player1Locked
                          && root.game.phase === "question" ? 2 : 0
            border.color: root.gold

            Behavior on color { ColorAnimation { duration: 300 } }
            Behavior on border.width { NumberAnimation { duration: 200 } }

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

        // Player 2 score
        Rectangle {
            width: 160; height: 50; radius: 6
            color: root.game.player2Locked && root.game.phase === "question"
                   ? Qt.lighter(root.colD, 1.6) : root.colD
            border.width: root.game.player2Locked
                          && root.game.phase === "question" ? 2 : 0
            border.color: root.gold

            Behavior on color { ColorAnimation { duration: 300 } }
            Behavior on border.width { NumberAnimation { duration: 200 } }

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

    SoundTodo {
        label: "Question sting / Tension loop"
        anchors { bottom: scoreBar.top; left: parent.left; margins: 8 }
        visible: root.game.phase === "question"
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

    // Sequential point reveal animation
    SequentialAnimation {
        id: pointRevealSequence

        // --- Player 1 ---
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
        }
        PauseAnimation { duration: 500 }
        ScriptAction { script: root.game.awardPoints(0) }
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
        }

        // --- Pause between players ---
        PauseAnimation { duration: 400 }

        // --- Player 2 ---
        ScriptAction {
            script: {
                if (root.game.player2Correct) {
                    if (root.correctSound) root.correctSound.play();
                } else {
                    if (root.wrongSound) root.wrongSound.play();
                }
            }
        }
        ParallelAnimation {
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
        ScriptAction { script: root.game.awardPoints(1) }
        ParallelAnimation {
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

        // --- Show roast ---
        PauseAnimation { duration: 300 }
        ScriptAction { script: root.showRoast = true }
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
            root.showRoast = false;
            pointRevealSequence.restart();
        }
        function onPhaseChanged() {
            if (root.game.phase !== "reveal") {
                pointRevealSequence.stop();
                root.showRoast = false;
            }
        }
    }
}
