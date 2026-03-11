import QtQuick

Item {
    id: root

    property QtObject game: null

    readonly property color gold: "#ffcc00"
    readonly property color colCorrect: "#00e676"
    readonly property color colWrong: "#ff1744"
    readonly property color colTimeout: "#ff9800"
    readonly property color colA: "#2a4a8a"
    readonly property color colD: "#8a2a3a"

    property var qData: root.game.currentQuestionData
    property real displayScore1: root.game.player1Score
    property real displayScore2: root.game.player2Score

    readonly property int totalPairs: game && game.currentRoundData
                                      ? game.currentRoundData.questions.length : 0

    Behavior on displayScore1 { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
    Behavior on displayScore2 { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

    // ====== blitzReady: "BEREIT?" screen ======
    Text {
        anchors.centerIn: parent
        visible: root.game.phase === "blitzReady"
        text: "BEREIT?"
        color: root.gold
        font { pixelSize: 72; bold: true; family: "monospace" }
        opacity: root.game.phase === "blitzReady" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    // ====== blitzPair: Two cards + VS + countdown ======
    Item {
        anchors.fill: parent
        visible: root.game.phase === "blitzPair"

        // Pair counter
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 12
            text: (root.game.currentQuestion + 1) + "/" + root.totalPairs
            color: root.gold
            font { pixelSize: 24; bold: true; family: "monospace" }
        }

        // Countdown
        Text {
            x: 20; y: 12
            text: {
                var s = Math.ceil(root.game.timerValue / 10);
                return s < 10 ? "0" + s : s.toString();
            }
            color: {
                var secs = root.game.timerValue / 10.0;
                if (secs > 3) return root.gold;
                return root.colWrong;
            }
            Behavior on color { ColorAnimation { duration: 500 } }
            font { pixelSize: 36; bold: true; family: "monospace" }
        }

        // Two large cards
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.18
            spacing: 0

            // Option A
            Rectangle {
                width: root.width * 0.38
                height: root.height * 0.45
                radius: 12
                color: "#2a3a5a"
                border.width: root.game.player1Locked
                              && root.game.player1Answer === 0 ? 3 : 1
                border.color: root.game.player1Locked
                              && root.game.player1Answer === 0
                              ? root.colA : "#333355"
                Behavior on border.color { ColorAnimation { duration: 300 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    width: parent.width - 24

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: root.qData && root.qData.answers.length > 0
                              ? root.qData.answers[0] : ""
                        color: "#ffffff"
                        font { pixelSize: 26; bold: true; family: "monospace" }
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Lock indicators
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Rectangle {
                            width: 32; height: 20; radius: 4
                            color: root.colA
                            visible: root.game.player1Locked
                                     && root.game.player1Answer === 0
                            Text {
                                anchors.centerIn: parent
                                text: "S1"; color: "#fff"
                                font { pixelSize: 10; bold: true; family: "monospace" }
                            }
                        }
                        Rectangle {
                            width: 32; height: 20; radius: 4
                            color: root.colD
                            visible: root.game.player2Locked
                                     && root.game.player2Answer === 0
                            Text {
                                anchors.centerIn: parent
                                text: "S2"; color: "#fff"
                                font { pixelSize: 10; bold: true; family: "monospace" }
                            }
                        }
                    }
                }
            }

            // VS separator
            Item {
                width: root.width * 0.08
                height: root.height * 0.45

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
                height: root.height * 0.45
                radius: 12
                color: "#2a3a5a"
                border.width: root.game.player1Locked
                              && root.game.player1Answer === 1 ? 3 : 1
                border.color: root.game.player1Locked
                              && root.game.player1Answer === 1
                              ? root.colA : "#333355"
                Behavior on border.color { ColorAnimation { duration: 300 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    width: parent.width - 24

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: root.qData && root.qData.answers.length > 1
                              ? root.qData.answers[1] : ""
                        color: "#ffffff"
                        font { pixelSize: 26; bold: true; family: "monospace" }
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Rectangle {
                            width: 32; height: 20; radius: 4
                            color: root.colA
                            visible: root.game.player1Locked
                                     && root.game.player1Answer === 1
                            Text {
                                anchors.centerIn: parent
                                text: "S1"; color: "#fff"
                                font { pixelSize: 10; bold: true; family: "monospace" }
                            }
                        }
                        Rectangle {
                            width: 32; height: 20; radius: 4
                            color: root.colD
                            visible: root.game.player2Locked
                                     && root.game.player2Answer === 1
                            Text {
                                anchors.centerIn: parent
                                text: "S2"; color: "#fff"
                                font { pixelSize: 10; bold: true; family: "monospace" }
                            }
                        }
                    }
                }
            }
        }
    }

    // ====== blitzReveal: Big JUBEL / OHHHH / ZU LANGSAM ======
    Item {
        anchors.fill: parent
        visible: root.game.phase === "blitzReveal"

        Text {
            id: revealText
            anchors.centerIn: parent
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
                    return root.colTimeout;
                return last.matched ? root.colCorrect : root.colWrong;
            }
            font { pixelSize: 80; bold: true; family: "monospace" }

            scale: revealScale.running ? 1.0 : 0.5
            opacity: root.game.phase === "blitzReveal" ? 1 : 0
        }

        SequentialAnimation {
            id: revealScale
            running: root.game.phase === "blitzReveal"
            loops: 1

            NumberAnimation {
                target: revealText; property: "scale"
                from: 0.3; to: 1.2; duration: 200
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: revealText; property: "scale"
                from: 1.2; to: 1.0; duration: 150
            }
        }
    }

    // ====== blitzDone: Pause screen ======
    Column {
        anchors.centerIn: parent
        spacing: 12
        visible: root.game.phase === "blitzDone"

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "GESCHMACKS-BLITZ"
            color: root.gold
            font { pixelSize: 40; bold: true; family: "monospace" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.game.blitzMatchCount + "/" + root.totalPairs
                  + " \u00dcBEREINSTIMMUNGEN"
            color: "#cccccc"
            font { pixelSize: 28; family: "monospace" }
        }
    }

    // ====== blitzSummary / blitzSummaryDone: Scrolling recap ======
    Item {
        anchors.fill: parent
        visible: root.game.phase === "blitzSummary"
                 || root.game.phase === "blitzSummaryDone"
        clip: true

        // Fixed header
        Rectangle {
            id: summaryHeader
            width: parent.width
            height: 60
            color: "#0d0d1a"
            z: 2

            Text {
                anchors.centerIn: parent
                text: root.game.blitzMatchCount + "/" + root.totalPairs
                      + " \u00dcBEREINSTIMMUNGEN"
                color: root.gold
                font { pixelSize: 28; bold: true; family: "monospace" }
            }
        }

        // Scrolling list
        Flickable {
            id: summaryFlick
            anchors.top: summaryHeader.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            width: parent.width
            contentHeight: summaryCol.height + 40
            clip: true

            Column {
                id: summaryCol
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12
                y: 20

                Repeater {
                    model: root.game.blitzResults

                    Rectangle {
                        width: summaryCol.width
                        height: pairContent.height + 20
                        radius: 8
                        color: modelData.matched ? "#1a3a1a" : "#2a1a1a"
                        border.color: modelData.matched ? root.colCorrect
                                      : (modelData.bastiAnswer < 0
                                         || modelData.crowdAnswer < 0)
                                        ? root.colTimeout : root.colWrong
                        border.width: 1

                        Column {
                            id: pairContent
                            anchors.centerIn: parent
                            width: parent.width - 20
                            spacing: 6

                            Text {
                                width: parent.width
                                text: modelData.pairText
                                color: "#ffffff"
                                font { pixelSize: 18; bold: true; family: "monospace" }
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 20

                                Text {
                                    text: "S1: " + (modelData.bastiAnswer >= 0
                                          && modelData.bastiAnswer < modelData.answers.length
                                          ? modelData.answers[modelData.bastiAnswer]
                                          : "\u2014")
                                    color: root.colA
                                    font { pixelSize: 14; family: "monospace" }
                                }

                                Text {
                                    text: "S2: " + (modelData.crowdAnswer >= 0
                                          && modelData.crowdAnswer < modelData.answers.length
                                          ? modelData.answers[modelData.crowdAnswer]
                                          : "\u2014")
                                    color: root.colD
                                    font { pixelSize: 14; family: "monospace" }
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: {
                                    if (modelData.bastiAnswer < 0
                                        || modelData.crowdAnswer < 0)
                                        return "\u2717 ZU LANGSAM";
                                    return modelData.matched
                                           ? "\u2713 MATCH" : "\u2717 KEIN MATCH";
                                }
                                color: {
                                    if (modelData.bastiAnswer < 0
                                        || modelData.crowdAnswer < 0)
                                        return root.colTimeout;
                                    return modelData.matched
                                           ? root.colCorrect : root.colWrong;
                                }
                                font { pixelSize: 16; bold: true; family: "monospace" }
                            }
                        }
                    }
                }
            }

            // Auto-scroll animation during blitzSummary
            NumberAnimation on contentY {
                id: scrollAnim
                from: 0
                to: Math.max(0, summaryCol.height + 40 - summaryFlick.height)
                duration: root.game.blitzResults.length * 3000
                running: root.game.phase === "blitzSummary"
                easing.type: Easing.InOutQuad
            }
        }
    }

    // ====== Score bar (always visible) ======
    Row {
        id: scoreBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        spacing: 20

        Rectangle {
            width: 160; height: 50; radius: 6
            color: root.game.player1Locked
                   && root.game.phase === "blitzPair"
                   ? Qt.lighter(root.colA, 1.6) : root.colA
            border.width: root.game.player1Locked
                          && root.game.phase === "blitzPair" ? 2 : 0
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
            color: root.game.player2Locked
                   && root.game.phase === "blitzPair"
                   ? Qt.lighter(root.colD, 1.6) : root.colD
            border.width: root.game.player2Locked
                          && root.game.phase === "blitzPair" ? 2 : 0
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
}
