import QtQuick
import "QuizParser.js" as QuizParser

// TODO: Replace shared properties with clay_network P2P
// Currently all three views share state via direct property bindings.
// For a real multi-device setup, the game state would be synced over
// the network using Clayground's clay_network plugin.

Item {
    id: root

    // --- Quiz content (parsed from questions.md) ---
    property var quizData: null
    readonly property string quizTitlePrefix: quizData ? quizData.titlePrefix : ""
    readonly property string quizTitleName: quizData ? quizData.titleName : ""
    readonly property string quizSubtitle: quizData ? quizData.subtitle : ""
    readonly property string quizTitleMusic: quizData ? quizData.titleMusic : ""
    readonly property var rounds: quizData ? quizData.rounds : []

    Component.onCompleted: _loadQuiz()

    function _loadQuiz() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", Qt.resolvedUrl("questions.md"), false);
        xhr.send();
        quizData = QuizParser.parse(xhr.responseText);
    }

    // --- Game state ---
    property string phase: "title" // title|roundIntro|question|reveal|scoreboard|finale
    property int currentRound: 0
    property int currentQuestion: 0
    property bool answersRevealed: false
    property int timerValue: 0   // in tenths of a second
    property int timerMax: 150   // 15.0 seconds
    property bool timerRunning: false
    property string lastRoast: ""

    // --- Per-player state ---
    property int player1Answer: -1
    property bool player1Locked: false
    property int player1Score: 0
    property bool player1Correct: false
    property int player1PointsEarned: 0

    property int player2Answer: -1
    property bool player2Locked: false
    property int player2Score: 0
    property bool player2Correct: false
    property int player2PointsEarned: 0

    // --- Derived ---
    readonly property int totalRounds: rounds.length
    readonly property var currentRoundData: (currentRound >= 0 && currentRound < totalRounds)
                                            ? rounds[currentRound] : null
    readonly property var currentQuestionData: {
        if (!currentRoundData) return null;
        var qs = currentRoundData.questions;
        return (currentQuestion >= 0 && currentQuestion < qs.length) ? qs[currentQuestion] : null;
    }
    readonly property int maxScore: {
        var total = 0;
        for (var r = 0; r < rounds.length; r++)
            total += rounds[r].questions.length * 100;
        return total;
    }

    // --- State machine ---
    function startGame() {
        currentRound = 0;
        player1Score = 0;
        player2Score = 0;
        phase = "roundIntro";
    }

    function startRound() {
        currentQuestion = 0;
        _showQuestion();
    }

    function _showQuestion() {
        player1Answer = -1;
        player2Answer = -1;
        player1Locked = false;
        player2Locked = false;
        player1Correct = false;
        player2Correct = false;
        player1PointsEarned = 0;
        player2PointsEarned = 0;
        answersRevealed = false;
        lastRoast = "";
        timerValue = timerMax;
        timerRunning = false;
        phase = "question";
    }

    function showAnswers() {
        answersRevealed = true;
        timerRunning = true;
    }

    function submitAnswer(playerIndex, answerIndex) {
        if (!answersRevealed || phase !== "question") return;

        if (playerIndex === 0 && !player1Locked) {
            player1Answer = answerIndex;
            player1Locked = true;
        } else if (playerIndex === 1 && !player2Locked) {
            player2Answer = answerIndex;
            player2Locked = true;
        }
    }

    function revealAnswer() {
        if (phase !== "question") return;
        timerRunning = false;

        var q = currentQuestionData;
        if (!q) return;

        // Score player 1
        player1Correct = (player1Answer === q.correct);
        if (player1Correct) {
            var tb1 = Math.floor(timerValue / timerMax * 50);
            player1PointsEarned = 50 + tb1;
            player1Score += player1PointsEarned;
        } else {
            player1PointsEarned = 0;
        }

        // Score player 2
        player2Correct = (player2Answer === q.correct);
        if (player2Correct) {
            var tb2 = Math.floor(timerValue / timerMax * 50);
            player2PointsEarned = 50 + tb2;
            player2Score += player2PointsEarned;
        } else {
            player2PointsEarned = 0;
        }

        lastRoast = (!player1Correct || !player2Correct) ? q.roast : "";
        phase = "reveal";
    }

    function nextStep() {
        if (phase !== "reveal") return;

        var qs = currentRoundData ? currentRoundData.questions : [];
        if (currentQuestion + 1 < qs.length) {
            currentQuestion++;
            _showQuestion();
        } else {
            phase = "scoreboard";
        }
    }

    function advanceFromScoreboard() {
        if (phase !== "scoreboard") return;

        if (currentRound + 1 < totalRounds) {
            currentRound++;
            phase = "roundIntro";
        } else {
            phase = "finale";
        }
    }

    function restartGame() {
        currentRound = 0;
        currentQuestion = 0;
        player1Answer = -1;
        player2Answer = -1;
        player1Locked = false;
        player2Locked = false;
        player1Score = 0;
        player2Score = 0;
        player1Correct = false;
        player2Correct = false;
        player1PointsEarned = 0;
        player2PointsEarned = 0;
        timerValue = 0;
        timerRunning = false;
        answersRevealed = false;
        lastRoast = "";
        phase = "title";
    }

    // --- Timer ---
    Timer {
        interval: 100
        running: root.timerRunning
        repeat: true
        onTriggered: {
            if (root.timerValue > 0) {
                root.timerValue--;
            } else {
                root.timerRunning = false;
                root.revealAnswer();
            }
        }
    }

    // --- Layout ---
    Rectangle {
        anchors.fill: parent
        color: "#0d0d1a"
    }

    Row {
        anchors.fill: parent

        // Presentation (left 65%)
        PresentationView {
            width: parent.width * 0.65
            height: parent.height
            game: root
        }

        // Vertical separator
        Rectangle {
            width: 2
            height: parent.height
            color: "#333355"
        }

        // Right panel (35%)
        Column {
            width: parent.width * 0.35 - 2
            height: parent.height

            // Moderator (top half)
            ModeratorView {
                width: parent.width
                height: parent.height * 0.5
                game: root
            }

            // Horizontal separator
            Rectangle {
                width: parent.width
                height: 2
                color: "#333355"
            }

            // Players (bottom half, side by side)
            Row {
                width: parent.width
                height: parent.height * 0.5 - 2

                PlayerView {
                    width: parent.width / 2
                    height: parent.height
                    game: root
                    playerIndex: 0
                }

                Rectangle {
                    width: 2
                    height: parent.height
                    color: "#333355"
                }

                PlayerView {
                    width: parent.width / 2 - 2
                    height: parent.height
                    game: root
                    playerIndex: 1
                }
            }
        }
    }
}
