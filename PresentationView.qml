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
        volume: root.game.answersRevealed && root.game.phase === "question"
                && root.game.currentMode !== "bouncer" ? 1.0 : 0.0
        onVolumeChanged: if (volume === 0 && root.game.phase !== "question") stop()
        Behavior on volume { NumberAnimation { duration: 1500 } }

        property bool shouldPlay: root.game.answersRevealed
                                  && root.game.phase === "question"
                                  && root.game.currentMode !== "bouncer"
        onShouldPlayChanged: if (shouldPlay) play()
    }

    Music {
        id: bouncerMusic
        source: "sound/bouncer_loop.mp3"
        loop: true
        volume: root.game.currentMode === "bouncer"
                && (root.game.phase === "question" || root.game.phase === "reveal") ? 1.0 : 0.0
        onVolumeChanged: if (volume === 0 && root.game.currentMode !== "bouncer") stop()
        Behavior on volume { NumberAnimation { duration: 1500 } }

        property bool shouldPlay: root.game.currentMode === "bouncer"
                                  && root.game.phase === "question"
        onShouldPlayChanged: if (shouldPlay) play()
    }

    Music {
        id: blitzMusic
        source: "sound/blitz_loop.mp3"
        loop: true
        volume: root.game.currentMode === "taste"
                && root.game.phase.startsWith("blitz") ? 1.0 : 0.0
        onVolumeChanged: if (volume === 0 && root.game.currentMode !== "taste") stop()
        Behavior on volume { NumberAnimation { duration: 1500 } }

        property bool shouldPlay: root.game.currentMode === "taste"
                                  && root.game.phase === "blitzPair"
                                  && root.game.currentQuestion === 0
        onShouldPlayChanged: if (shouldPlay) play()
    }

    Music {
        id: swordFightMusic
        source: "sound/sword_fighting.mp3"
        loop: true
        volume: isDuelPhase ? 1.0 : 0.0
        onVolumeChanged: if (volume === 0 && !isDuelPhase) stop()
        Behavior on volume { NumberAnimation { duration: 1500 } }

        property bool isDuelPhase: (root.game.phase === "duelPick"
                                    || root.game.phase === "duelCounter"
                                    || root.game.phase === "duelResult")
                                   && root.game.duelWinner === ""
        onIsDuelPhaseChanged: if (isDuelPhase) play()
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

    // --- Mode-specific content (loaded per round type) ---
    Loader {
        id: modeLoader
        anchors.fill: parent
        visible: root.game.phase === "question" || root.game.phase === "reveal"
                 || root.game.phase === "duelPick" || root.game.phase === "duelCounter"
                 || root.game.phase === "duelResult"
                 || root.game.phase === "console" || root.game.phase === "consoleResult"
                 || root.game.phase === "singingActive" || root.game.phase === "singingReveal"
                 || root.game.phase === "blitzReady" || root.game.phase === "blitzPair"
                 || root.game.phase === "blitzReveal" || root.game.phase === "blitzDone"
                 || root.game.phase === "blitzSummary" || root.game.phase === "blitzSummaryDone"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        source: {
            switch (root.game.currentMode) {
            case "quiz":        return "PresentationQuiz.qml";
            case "bouncer":     return "PresentationQuiz.qml";
            case "pirate-duel": return "PresentationQuiz.qml";
            case "taste":       return "PresentationTaste.qml";
            case "plank-duel":  return "PresentationPlankDuel.qml";
            case "dos-console": return "PresentationConsole.qml";
            case "singing":     return "PresentationSinging.qml";
            default:            return "PresentationQuiz.qml";
            }
        }

        onLoaded: {
            item.game = root.game;
            if (item.hasOwnProperty("correctSound"))
                item.correctSound = correctSound;
            if (item.hasOwnProperty("wrongSound"))
                item.wrongSound = wrongSound;
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
                        text: "BASTI"
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
                        text: "CROWD"
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

    // --- Pre-Finale Screen (suspense "?") ---
    Item {
        id: preFinaleScreen
        anchors.fill: parent
        visible: root.game.phase === "preFinale"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Text {
            id: preFinaleQ
            anchors.centerIn: parent
            text: "?"
            color: root.gold
            font { pixelSize: 200; bold: true; family: "monospace" }
            transformOrigin: Item.Center

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 1.15; duration: 1500
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: 1.0; duration: 1500
                    easing.type: Easing.InOutSine
                }
            }
        }

        // Glow behind "?"
        Text {
            anchors.centerIn: parent
            text: "?"
            color: root.gold
            opacity: 0.2
            scale: preFinaleQ.scale * 1.15
            font: preFinaleQ.font
        }
    }

    // --- Bonus Reveal Screen ---
    Item {
        id: bonusRevealScreen
        anchors.fill: parent
        visible: root.game.phase === "bonusReveal"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "LEGENDARY & AWESOME BONUS"
                color: root.gold
                font { pixelSize: 32; bold: true; family: "monospace" }

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: 1.06; duration: 1200
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: 1.0; duration: 1200
                        easing.type: Easing.InOutSine
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "+10.000"
                color: "#ffffff"
                font { pixelSize: 120; bold: true; family: "monospace" }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "FÜR BASTI"
                color: root.gold
                font { pixelSize: 28; bold: true; family: "monospace" }
            }
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
            if (root.game.player1Score > root.game.player2Score) return "BASTI GEWINNT!";
            if (root.game.player2Score > root.game.player1Score) return "CROWD GEWINNT!";
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
                        text: "BASTI"
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
                        text: "CROWD"
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

    // --- Outro Screen (title variant + outro music) ---
    Item {
        id: outroScreen
        anchors.fill: parent
        visible: root.game.phase === "outro"
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        // Marquee light frame (reused from title)
        Item {
            id: outroMarquee
            width: Math.min(parent.width * 0.8, 560)
            height: 170
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -30

            property int chasePos: 0
            property int totalLights: 52

            Timer {
                running: outroScreen.visible
                interval: 55
                repeat: true
                onTriggered: outroMarquee.chasePos =
                    (outroMarquee.chasePos + 1) % outroMarquee.totalLights
            }

            Repeater {
                model: outroMarquee.totalLights

                Rectangle {
                    width: 8; height: 8; radius: 4

                    property real perim: 2 * (outroMarquee.width + outroMarquee.height)
                    property real pos: index / outroMarquee.totalLights * perim

                    x: {
                        var w = outroMarquee.width, h = outroMarquee.height;
                        if (pos < w) return pos - 4;
                        if (pos < w + h) return w - 4;
                        if (pos < 2 * w + h) return 2 * w + h - pos - 4;
                        return -4;
                    }
                    y: {
                        var w = outroMarquee.width, h = outroMarquee.height;
                        if (pos < w) return -4;
                        if (pos < w + h) return pos - w - 4;
                        if (pos < 2 * w + h) return h - 4;
                        return 2 * w + 2 * h - pos - 4;
                    }

                    property int dist: {
                        var d = Math.abs(index - outroMarquee.chasePos);
                        var half = Math.floor(outroMarquee.totalLights / 2);
                        return d > half ? outroMarquee.totalLights - d : d;
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

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: outroTitleText.width; height: outroTitleText.height

                    Text {
                        anchors.centerIn: parent
                        text: outroTitleText.text
                        color: root.gold
                        opacity: 0.25
                        scale: outroTitleText.scale * 1.08
                        font: outroTitleText.font
                    }

                    Text {
                        id: outroTitleText
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
            anchors.top: outroMarquee.bottom
            anchors.topMargin: 20
            text: "~ " + root.game.quizSubtitle + " ~"
            color: root.gold
            font { pixelSize: 20; italic: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: outroMarquee.bottom
            anchors.topMargin: 56
            text: "DANKE FÜRS MITSPIELEN!"
            color: "#88ffffff"
            font { pixelSize: 18; bold: true; family: "monospace" }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 1200 }
                NumberAnimation { to: 1.0; duration: 1200 }
            }
        }

        Music {
            id: outroMusic
            source: "sound/outro_song.mp3"
            loop: false
            volume: outroScreen.visible ? 1.0 : 0.0
            onVolumeChanged: if (volume === 0 && !outroScreen.visible) stop()
            Behavior on volume { NumberAnimation { duration: 1500 } }
        }

        Connections {
            target: root.game
            function onPhaseChanged() {
                if (root.game.phase === "outro") outroMusic.play();
            }
        }
    }
}
