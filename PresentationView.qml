import QtQuick
import Clayground.Sound

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

        // Marquee light frame around the title
        Item {
            id: marqueeFrame
            width: Math.min(parent.width * 0.8, 560)
            height: 170
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -30

            property int chasePos: 0
            property int totalLights: 52

            Timer {
                running: titleScreen.visible
                interval: 55
                repeat: true
                onTriggered: marqueeFrame.chasePos =
                    (marqueeFrame.chasePos + 1) % marqueeFrame.totalLights
            }

            Repeater {
                model: marqueeFrame.totalLights

                Rectangle {
                    width: 8; height: 8; radius: 4

                    property real perim: 2 * (marqueeFrame.width + marqueeFrame.height)
                    property real pos: index / marqueeFrame.totalLights * perim

                    x: {
                        var w = marqueeFrame.width, h = marqueeFrame.height;
                        if (pos < w) return pos - 4;
                        if (pos < w + h) return w - 4;
                        if (pos < 2 * w + h) return 2 * w + h - pos - 4;
                        return -4;
                    }
                    y: {
                        var w = marqueeFrame.width, h = marqueeFrame.height;
                        if (pos < w) return -4;
                        if (pos < w + h) return pos - w - 4;
                        if (pos < 2 * w + h) return h - 4;
                        return 2 * w + 2 * h - pos - 4;
                    }

                    property int dist: {
                        var d = Math.abs(index - marqueeFrame.chasePos);
                        var half = Math.floor(marqueeFrame.totalLights / 2);
                        return d > half ? marqueeFrame.totalLights - d : d;
                    }

                    color: dist < 5 ? root.gold : (index % 2 === 0 ? "#333355" : "#222240")
                    opacity: dist < 5 ? (1.0 - dist * 0.15) : 0.4

                    Behavior on color { ColorAnimation { duration: 80 } }
                    Behavior on opacity { NumberAnimation { duration: 80 } }
                }
            }

            // Title text (centered in frame)
            Column {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.game.quizTitlePrefix.toUpperCase()
                    color: root.gold
                    font { pixelSize: 26; bold: true; family: "monospace" }
                }

                // Glow layer behind main title
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: titleText.width; height: titleText.height

                    Text {
                        anchors.centerIn: parent
                        text: titleText.text
                        color: root.gold
                        opacity: 0.25
                        scale: titleText.scale * 1.08
                        font: titleText.font
                    }

                    Text {
                        id: titleText
                        anchors.centerIn: parent
                        text: root.game.quizTitleName.toUpperCase()
                        color: "#ffffff"
                        font { pixelSize: 72; bold: true; family: "monospace" }

                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 1.04; duration: 2000
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                to: 1.0; duration: 2000
                                easing.type: Easing.InOutSine
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: marqueeFrame.bottom
            anchors.topMargin: 20
            text: "~ " + root.game.quizSubtitle + " ~"
            color: root.gold
            font { pixelSize: 20; italic: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: marqueeFrame.bottom
            anchors.topMargin: 56
            text: "Warte auf den Moderator ..."
            color: "#88ffffff"
            font { pixelSize: 16; family: "monospace" }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 1200 }
                NumberAnimation { to: 1.0; duration: 1200 }
            }
        }

        // Sound hint (before music starts)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            text: "🔊 Ton einschalten!"
            color: root.gold
            font { pixelSize: 16; family: "monospace" }
            visible: !root.game.musicStarted

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 1000 }
                NumberAnimation { to: 1.0; duration: 1000 }
            }
        }

        Music {
            id: titleMusic
            source: "sound/title_song.mp3"
            loop: false
            volume: titleScreen.visible ? 1.0 : 0.0
            onVolumeChanged: if (volume === 0 && !titleScreen.visible) stop()
            Behavior on volume { NumberAnimation { duration: 1500 } }
        }

        Connections {
            target: root.game
            function onMusicStartedChanged() {
                if (root.game.musicStarted) titleMusic.play();
            }
        }
    }

    Music {
        id: roundJingle
        source: "sound/new_round.mp3"
    }

    Music {
        id: timeOutSound
        source: "sound/time_out.mp3"
    }
    Connections {
        target: root.game
        function onTimerRunningChanged() {
            if (!root.game.timerRunning && root.game.timerValue <= 0
                && root.game.phase === "question")
                timeOutSound.play();
        }
    }

    Music {
        id: lockInSound
        source: "sound/lock_in.mp3"
    }
    Connections {
        target: root.game
        function onPlayer1LockedChanged() { if (root.game.player1Locked) lockInSound.play(); }
        function onPlayer2LockedChanged() { if (root.game.player2Locked) lockInSound.play(); }
    }

    Music {
        id: correctSound
        source: "sound/correct_answer.mp3"
    }

    Music {
        id: wrongSound
        source: "sound/wrong_answer.mp3"
    }

    Music {
        id: tensionMusic
        source: "sound/waiting_for_answers.mp3"
        loop: true
        volume: root.game.answersRevealed && root.game.phase === "question" ? 1.0 : 0.0
        onVolumeChanged: if (volume === 0 && root.game.phase !== "question") stop()
        Behavior on volume { NumberAnimation { duration: 1500 } }

        property bool shouldPlay: root.game.answersRevealed
                                  && root.game.phase === "question"
        onShouldPlayChanged: if (shouldPlay) play()
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
                roundJingle.play();
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
                                ? root.game.currentRoundData.mode === "pirate-duel" : false
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
                        anchors.right: choiceTags.left
                        anchors.rightMargin: 6
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

                    // Player choice pills (always visible, light up on reveal)
                    Row {
                        id: choiceTags
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Rectangle {
                            width: 28; height: 18; radius: 4
                            color: parent.parent.isChosen1 && questionScreen.isReveal
                                   ? root.colA : "#1a1a2e"
                            opacity: parent.parent.isChosen1 && questionScreen.isReveal
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
                            color: parent.parent.isChosen2 && questionScreen.isReveal
                                   ? root.colD : "#1a1a2e"
                            opacity: parent.parent.isChosen2 && questionScreen.isReveal
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

        // Roast text (on reveal)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: scoreBar.top
            anchors.bottomMargin: 20
            visible: questionScreen.isReveal && root.game.lastRoast !== ""
                     && questionScreen.showRoast
            opacity: showRoast ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 400 } }
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
                        text: Math.round(questionScreen.displayScore1).toString()
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
                        text: Math.round(questionScreen.displayScore2).toString()
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
                    if (root.game.player1Correct)
                        correctSound.play();
                    else
                        wrongSound.play();
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
                    if (root.game.player2Correct)
                        correctSound.play();
                    else
                        wrongSound.play();
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
            ScriptAction { script: questionScreen.showRoast = true }
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
                questionScreen.showRoast = false;
                pointRevealSequence.restart();
            }
            function onPhaseChanged() {
                if (root.game.phase !== "reveal") {
                    pointRevealSequence.stop();
                    questionScreen.showRoast = false;
                }
            }
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
