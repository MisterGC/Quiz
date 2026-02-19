import QtQuick

Item {
    id: root

    required property QtObject game

    readonly property color colA: "#2a4a8a"
    readonly property color colB: "#8a5a2a"
    readonly property color colC: "#2a7a3a"
    readonly property color colD: "#8a2a3a"
    readonly property color colCorrect: "#00e676"
    readonly property color colWrong: "#ff1744"
    readonly property color gold: "#ffcc00"

    clip: true

    // --- Title Screen ---
    Item {
        id: titleScreen
        anchors.fill: parent
        visible: root.game.phase === "title"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "RETRO"
                color: root.gold
                font { pixelSize: 42; bold: true; family: "monospace" }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "RETRO RECKONING"
                color: "#ffffff"
                font { pixelSize: 64; bold: true; family: "monospace" }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "~ Eine Retro Quizshow ~"
                color: root.gold
                font { pixelSize: 20; italic: true; family: "monospace" }
            }
            Item { width: 1; height: 30 }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Warte auf den Moderator ..."
                color: "#88ffffff"
                font { pixelSize: 16; family: "monospace" }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1200 }
                    NumberAnimation { to: 1.0; duration: 1200 }
                }
            }
        }

        SoundTodo {
            label: "Theme music loop"
            anchors { bottom: parent.bottom; right: parent.right; margins: 8 }
        }
    }

    // --- Round Intro Screen (animated) ---
    Item {
        id: roundIntroScreen
        anchors.fill: parent
        visible: root.game.phase === "roundIntro"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        property string revealedTagline: ""
        property int taglineCharIdx: 0

        onVisibleChanged: {
            if (visible) {
                revealedTagline = "";
                taglineCharIdx = 0;
                roundNumText.scale = 3.0;
                roundNumText.opacity = 0;
                roundNameText.anchors.horizontalCenterOffset = roundIntroScreen.width * 0.6;
                roundNameText.opacity = 0;
                topLine.width = 0;
                bottomLine.width = 0;
                sponsorText.opacity = 0;
                sponsorText.anchors.bottomMargin = -10;
                introSequence.restart();
            }
        }

        Rectangle {
            id: topLine
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.28
            height: 2; width: 0
            color: root.gold; opacity: 0.6
        }

        Rectangle {
            id: bottomLine
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.72
            height: 2; width: 0
            color: root.gold; opacity: 0.6
        }

        Text {
            id: roundNumText
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.32
            text: "RUNDE " + (root.game.currentRound + 1)
            color: root.gold
            font { pixelSize: 38; bold: true; family: "monospace" }
            scale: 3.0; opacity: 0
            transformOrigin: Item.Center
        }

        Text {
            id: roundNameText
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.42
            text: root.game.currentRoundData ? root.game.currentRoundData.name : ""
            color: "#ffffff"
            font { pixelSize: 54; bold: true; family: "monospace" }
            opacity: 0
        }

        Text {
            id: taglineText
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.55
            text: roundIntroScreen.revealedTagline
            color: "#cccccc"
            font { pixelSize: 18; italic: true; family: "monospace" }
        }

        Text {
            visible: taglineTimer.running
            anchors.left: taglineText.right
            anchors.verticalCenter: taglineText.verticalCenter
            text: "▌"
            color: root.gold
            font { pixelSize: 18; family: "monospace" }
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0; duration: 300 }
                NumberAnimation { to: 1; duration: 300 }
            }
        }

        Text {
            id: sponsorText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -10
            text: root.game.currentRoundData ? root.game.currentRoundData.sponsor : ""
            color: "#666666"
            font { pixelSize: 14; family: "monospace" }
            opacity: 0
        }

        Timer {
            id: taglineTimer
            interval: 30; repeat: true
            onTriggered: {
                var full = root.game.currentRoundData ? root.game.currentRoundData.tagline : "";
                if (roundIntroScreen.taglineCharIdx < full.length) {
                    roundIntroScreen.taglineCharIdx++;
                    roundIntroScreen.revealedTagline = full.substring(0, roundIntroScreen.taglineCharIdx);
                } else {
                    taglineTimer.stop();
                    sponsorFadeIn.start();
                }
            }
        }

        ParallelAnimation {
            id: sponsorFadeIn
            NumberAnimation {
                target: sponsorText; property: "opacity"
                to: 1; duration: 600
            }
            NumberAnimation {
                target: sponsorText; property: "anchors.bottomMargin"
                to: 40; duration: 600; easing.type: Easing.OutCubic
            }
        }

        SequentialAnimation {
            id: introSequence

            ParallelAnimation {
                NumberAnimation {
                    target: topLine; property: "width"
                    to: roundIntroScreen.width * 0.6; duration: 500
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: bottomLine; property: "width"
                    to: roundIntroScreen.width * 0.6; duration: 500
                    easing.type: Easing.OutCubic
                }
            }

            PauseAnimation { duration: 100 }

            ParallelAnimation {
                NumberAnimation {
                    target: roundNumText; property: "scale"
                    to: 1.0; duration: 500; easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: roundNumText; property: "opacity"
                    to: 1.0; duration: 400
                }
            }

            PauseAnimation { duration: 300 }

            ParallelAnimation {
                NumberAnimation {
                    target: roundNameText; property: "anchors.horizontalCenterOffset"
                    to: 0; duration: 600; easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: roundNameText; property: "opacity"
                    to: 1.0; duration: 500
                }
            }

            PauseAnimation { duration: 400 }

            ScriptAction { script: taglineTimer.start() }
        }

        SoundTodo {
            label: "Round jingle + voiceover"
            anchors { bottom: parent.bottom; right: parent.right; margins: 8 }
        }
    }

    // --- Question / Reveal Screen ---
    Item {
        id: questionScreen
        anchors.fill: parent
        visible: root.game.phase === "question" || root.game.phase === "reveal"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        property var qData: root.game.currentQuestionData
        property bool isInsult: root.game.currentRoundData
                                ? root.game.currentRoundData.mode === "insult" : false
        property bool isReveal: root.game.phase === "reveal"

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
            visible: questionScreen.isInsult && root.game.answersRevealed
            text: "⚔ BELEIDIGUNGSDUELL ⚔"
            color: root.gold
            font { pixelSize: 18; bold: true; family: "monospace" }
        }

        // Question text — animates between centered (big) and top (small)
        Text {
            id: questionText
            width: parent.width - 60
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: questionScreen.qData ? questionScreen.qData.text : ""
            color: "#ffffff"
            wrapMode: Text.WordWrap
            font {
                pixelSize: questionScreen.isInsult ? 30 : 28
                bold: true
                italic: questionScreen.isInsult
                family: "monospace"
            }

            // Animate position and scale based on answersRevealed
            y: (root.game.answersRevealed || questionScreen.isReveal)
               ? 30 : parent.height * 0.3
            scale: (root.game.answersRevealed || questionScreen.isReveal)
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
            spacing: 14
            opacity: (root.game.answersRevealed || questionScreen.isReveal) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            Repeater {
                model: questionScreen.qData ? questionScreen.qData.answers : []

                Item {
                    width: answerList.width
                    height: answerLetterText.height + 8

                    readonly property bool isCorrect: questionScreen.qData
                                                      && index === questionScreen.qData.correct
                    readonly property bool isChosen1: index === root.game.player1Answer
                    readonly property bool isChosen2: index === root.game.player2Answer
                    readonly property color letterColor: [root.colA, root.colB,
                                                          root.colC, root.colD][index]
                    readonly property string prefix: questionScreen.isInsult
                                                     ? ["1", "2", "3", "4"][index]
                                                     : ["A", "B", "C", "D"][index]

                    // Letter badge
                    Text {
                        id: answerLetterText
                        anchors.verticalCenter: parent.verticalCenter
                        text: parent.prefix
                        color: {
                            if (!questionScreen.isReveal) return parent.letterColor;
                            if (parent.isCorrect) return root.colCorrect;
                            if ((parent.isChosen1 || parent.isChosen2) && !parent.isCorrect)
                                return root.colWrong;
                            return "#444444";
                        }
                        font { pixelSize: 24; bold: true; family: "monospace" }
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }

                    // Answer text
                    Text {
                        anchors.left: answerLetterText.right
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        color: {
                            if (!questionScreen.isReveal) return "#ffffff";
                            if (parent.isCorrect) return root.colCorrect;
                            if ((parent.isChosen1 || parent.isChosen2) && !parent.isCorrect)
                                return root.colWrong;
                            return "#555555";
                        }
                        font {
                            pixelSize: 20
                            bold: questionScreen.isReveal && parent.isCorrect
                            family: "monospace"
                            italic: questionScreen.isInsult
                        }
                        wrapMode: Text.WordWrap
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }
            }
        }

        // Roast text (on reveal)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: scoreBar.top
            anchors.bottomMargin: 20
            visible: questionScreen.isReveal && root.game.lastRoast !== ""
            text: root.game.lastRoast
            color: root.gold
            font { pixelSize: 20; italic: true; family: "monospace" }
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
                color: root.colA

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

            // Player 2 score
            Rectangle {
                width: 160; height: 50; radius: 6
                color: root.colD

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

        SoundTodo {
            label: "Question sting / Tension loop"
            anchors { bottom: scoreBar.top; left: parent.left; margins: 8 }
            visible: root.game.phase === "question"
        }
        SoundTodo {
            label: questionScreen.isReveal && root.game.player1Correct
                   ? "Correct fanfare" : "Wrong shame jingle"
            anchors { bottom: scoreBar.top; left: parent.left; margins: 8 }
            visible: root.game.phase === "reveal"
        }
    }

    // --- Scoreboard Screen ---
    Item {
        id: scoreboardScreen
        anchors.fill: parent
        visible: root.game.phase === "scoreboard"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "RUNDE ABGESCHLOSSEN"
                color: root.gold
                font { pixelSize: 28; bold: true; family: "monospace" }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.currentRoundData ? root.game.currentRoundData.name : ""
                color: "#cccccc"
                font { pixelSize: 20; family: "monospace" }
            }
            Item { width: 1; height: 20 }

            // Both scores
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 40

                Column {
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "SPIELER 1"
                        color: "#aaaacc"
                        font { pixelSize: 14; family: "monospace" }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.game.player1Score.toString()
                        color: "#ffffff"
                        font { pixelSize: 72; bold: true; family: "monospace" }
                    }
                }

                Column {
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "SPIELER 2"
                        color: "#ccaaaa"
                        font { pixelSize: 14; family: "monospace" }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.game.player2Score.toString()
                        color: "#ffffff"
                        font { pixelSize: 72; bold: true; family: "monospace" }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "PUNKTE"
                color: "#888888"
                font { pixelSize: 18; family: "monospace" }
            }
        }

        SoundTodo {
            label: "Score tally sound"
            anchors { bottom: parent.bottom; right: parent.right; margins: 8 }
        }
    }

    // --- Finale Screen ---
    Item {
        id: finaleScreen
        anchors.fill: parent
        visible: root.game.phase === "finale"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        property int totalScore: root.game.player1Score + root.game.player2Score
        property string winner: {
            if (root.game.player1Score > root.game.player2Score) return "SPIELER 1 GEWINNT!";
            if (root.game.player2Score > root.game.player1Score) return "SPIELER 2 GEWINNT!";
            return "UNENTSCHIEDEN!";
        }
        property string rating: {
            var maxScore = root.game.maxScore;
            if (maxScore <= 0) return "Trostpreis";
            var best = Math.max(root.game.player1Score, root.game.player2Score);
            var pct = best / maxScore;
            if (pct >= 0.9) return "RETRO GOTT";
            if (pct >= 0.7) return "Pixel-Veteran";
            if (pct >= 0.5) return "Gelegenheitsspieler";
            if (pct >= 0.3) return "Knöpfchendrücker";
            return "Noob erkannt";
        }

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "ENDERGEBNIS"
                color: root.gold
                font { pixelSize: 36; bold: true; family: "monospace" }
            }
            Item { width: 1; height: 10 }

            // Both scores side by side
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 40

                Column {
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "SPIELER 1"
                        color: "#aaaacc"
                        font { pixelSize: 14; family: "monospace" }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.game.player1Score.toString()
                        color: "#ffffff"
                        font { pixelSize: 96; bold: true; family: "monospace" }
                    }
                }

                Column {
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "SPIELER 2"
                        color: "#ccaaaa"
                        font { pixelSize: 14; family: "monospace" }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.game.player2Score.toString()
                        color: "#ffffff"
                        font { pixelSize: 96; bold: true; family: "monospace" }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: finaleScreen.winner
                color: root.gold
                font { pixelSize: 28; bold: true; family: "monospace" }
            }
            Item { width: 1; height: 10 }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: finaleScreen.rating
                color: root.gold
                font { pixelSize: 24; bold: true; family: "monospace" }
            }
        }

        SoundTodo {
            label: "Victory / end music"
            anchors { bottom: parent.bottom; right: parent.right; margins: 8 }
        }
    }
}
