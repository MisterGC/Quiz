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
                text: "~ A Retro Quiz Show ~"
                color: root.gold
                font { pixelSize: 20; italic: true; family: "monospace" }
            }
            Item { width: 1; height: 30 }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Waiting for the moderator to start ..."
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
                // Reset animation state
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

        // Top decorative line
        Rectangle {
            id: topLine
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.28
            height: 2
            width: 0
            color: root.gold
            opacity: 0.6
        }

        // Bottom decorative line
        Rectangle {
            id: bottomLine
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.72
            height: 2
            width: 0
            color: root.gold
            opacity: 0.6
        }

        // "ROUND X" — zoom in with overshoot
        Text {
            id: roundNumText
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.32
            text: "ROUND " + (root.game.currentRound + 1)
            color: root.gold
            font { pixelSize: 38; bold: true; family: "monospace" }
            scale: 3.0
            opacity: 0
            transformOrigin: Item.Center
        }

        // Round name — slides in from right
        Text {
            id: roundNameText
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.42
            text: root.game.currentRoundData ? root.game.currentRoundData.name : ""
            color: "#ffffff"
            font { pixelSize: 54; bold: true; family: "monospace" }
            opacity: 0
        }

        // Tagline — typewriter reveal
        Text {
            id: taglineText
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.55
            text: roundIntroScreen.revealedTagline
            color: "#cccccc"
            font { pixelSize: 18; italic: true; family: "monospace" }
        }

        // Blinking cursor during typewriter
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

        // Sponsor text — fades in last
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

        // Typewriter timer
        Timer {
            id: taglineTimer
            interval: 30
            repeat: true
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

        // Sponsor fade-in after typewriter completes
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

        // Master animation sequence
        SequentialAnimation {
            id: introSequence

            // 1. Decorative lines expand from center
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

            // 2. "ROUND X" zooms in with overshoot
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

            // 3. Round name slides in from right
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

            // 4. Start typewriter for tagline
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

        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            // Insult round header
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: questionScreen.isInsult
                text: "⚔ INSULT DUEL ⚔"
                color: root.gold
                font { pixelSize: 22; bold: true; family: "monospace" }
            }

            // Question number
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Question " + (root.game.currentQuestion + 1) + " of "
                      + (root.game.currentRoundData ? root.game.currentRoundData.questions.length : 0)
                color: "#888888"
                font { pixelSize: 14; family: "monospace" }
            }

            // Question text
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: questionScreen.qData ? questionScreen.qData.text : ""
                color: "#ffffff"
                font {
                    pixelSize: questionScreen.isInsult ? 30 : 28
                    bold: true
                    italic: questionScreen.isInsult
                    family: "monospace"
                }
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 10 }

            // Answer grid 2x2
            Grid {
                id: answerGrid
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2
                spacing: 12
                width: Math.min(parent.width, 700)

                Repeater {
                    model: questionScreen.qData ? questionScreen.qData.answers : []

                    Rectangle {
                        id: answerCard
                        width: (answerGrid.width - answerGrid.spacing) / 2
                        height: 70
                        radius: 8
                        opacity: root.game.answersRevealed || questionScreen.isReveal ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        readonly property bool isCorrect: questionScreen.qData
                                                          && index === questionScreen.qData.correct
                        readonly property bool isChosen: index === root.game.playerAnswer
                        readonly property color baseColor: [root.colA, root.colB,
                                                            root.colC, root.colD][index]
                        readonly property string prefix: questionScreen.isInsult
                                                         ? ["1.", "2.", "3.", "4."][index]
                                                         : ["A", "B", "C", "D"][index]

                        color: {
                            if (!questionScreen.isReveal) return baseColor;
                            if (isCorrect) return root.colCorrect;
                            if (isChosen && !isCorrect) return root.colWrong;
                            return Qt.darker(baseColor, 2.0);
                        }
                        border.color: isChosen && !questionScreen.isReveal ? root.gold : "transparent"
                        border.width: isChosen && !questionScreen.isReveal ? 3 : 0

                        Behavior on color { ColorAnimation { duration: 300 } }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: answerCard.prefix
                                color: "#ffffff"
                                font { pixelSize: 22; bold: true; family: "monospace" }
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 40
                                text: modelData
                                color: "#ffffff"
                                font {
                                    pixelSize: 16
                                    family: "monospace"
                                    italic: questionScreen.isInsult
                                }
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            // Timer bar — fades in when timer starts, fades out when it stops
            Item {
                width: Math.min(parent.width, 700)
                height: 12
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.game.phase === "question"
                opacity: root.game.timerRunning ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 400 } }

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: "#333333"
                }
                Rectangle {
                    width: parent.width * (root.game.timerMax > 0
                           ? root.game.timerValue / root.game.timerMax : 0)
                    height: parent.height
                    radius: 6
                    color: {
                        var ratio = root.game.timerMax > 0
                                    ? root.game.timerValue / root.game.timerMax : 0;
                        if (ratio > 0.5) return root.colCorrect;
                        if (ratio > 0.25) return "#ffcc00";
                        return root.colWrong;
                    }
                    Behavior on width { NumberAnimation { duration: 100 } }
                    Behavior on color { ColorAnimation { duration: 500 } }
                }
            }

            // Roast text (on reveal)
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: questionScreen.isReveal && root.game.lastRoast !== ""
                text: root.game.lastRoast
                color: root.gold
                font { pixelSize: 20; italic: true; family: "monospace" }
            }
        }

        SoundTodo {
            label: "Question sting / Tension loop"
            anchors { bottom: parent.bottom; left: parent.left; margins: 8 }
            visible: root.game.phase === "question"
        }
        SoundTodo {
            label: questionScreen.isReveal && root.game.lastCorrect
                   ? "Correct fanfare" : "Wrong shame jingle"
            anchors { bottom: parent.bottom; left: parent.left; margins: 8 }
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
                text: "ROUND COMPLETE"
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
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.score.toString()
                color: "#ffffff"
                font { pixelSize: 96; bold: true; family: "monospace" }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "POINTS"
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

        property string rating: {
            var s = root.game.score;
            var maxScore = root.game.maxScore;
            if (maxScore <= 0) return "Participation Trophy";
            var pct = s / maxScore;
            if (pct >= 0.9) return "RETRO GOD";
            if (pct >= 0.7) return "Pixel Veteran";
            if (pct >= 0.5) return "Casual Gamer";
            if (pct >= 0.3) return "Button Masher";
            return "Noob Detected";
        }

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "FINAL RESULTS"
                color: root.gold
                font { pixelSize: 36; bold: true; family: "monospace" }
            }
            Item { width: 1; height: 10 }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.score.toString()
                color: "#ffffff"
                font { pixelSize: 112; bold: true; family: "monospace" }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "POINTS"
                color: "#888888"
                font { pixelSize: 20; family: "monospace" }
            }
            Item { width: 1; height: 20 }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: finaleScreen.rating
                color: root.gold
                font { pixelSize: 32; bold: true; family: "monospace" }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.game.score + " / " + root.game.maxScore
                color: "#666666"
                font { pixelSize: 16; family: "monospace" }
            }
        }

        SoundTodo {
            label: "Victory / end music"
            anchors { bottom: parent.bottom; right: parent.right; margins: 8 }
        }
    }
}
