import QtQuick
import "QuestionData.js" as QData

// TODO: Replace shared properties with clay_network P2P
// Currently all three views share state via direct property bindings.
// For a real multi-device setup, the game state would be synced over
// the network using Clayground's clay_network plugin.

Item {
    id: root

    // --- Game state ---
    property string phase: "title" // title|roundIntro|question|reveal|scoreboard|finale
    property int currentRound: 0
    property int currentQuestion: 0
    property int playerAnswer: -1
    property bool answerLocked: false
    property int score: 0
    property int timerValue: 0   // in tenths of a second
    property int timerMax: 150   // 15.0 seconds
    property bool timerRunning: false
    property bool answersRevealed: false
    property string lastRoast: ""
    property bool lastCorrect: false
    property int lastPointsEarned: 0

    // --- Derived ---
    readonly property int totalRounds: QData.rounds.length
    readonly property var currentRoundData: (currentRound >= 0 && currentRound < totalRounds)
                                            ? QData.rounds[currentRound] : null
    readonly property var currentQuestionData: {
        if (!currentRoundData) return null;
        var qs = currentRoundData.questions;
        return (currentQuestion >= 0 && currentQuestion < qs.length) ? qs[currentQuestion] : null;
    }
    readonly property int maxScore: {
        var total = 0;
        for (var r = 0; r < QData.rounds.length; r++)
            total += QData.rounds[r].questions.length * 100;
        return total;
    }

    // --- State machine ---
    function startGame() {
        currentRound = 0;
        score = 0;
        phase = "roundIntro";
    }

    function startRound() {
        currentQuestion = 0;
        _showQuestion();
    }

    function _showQuestion() {
        playerAnswer = -1;
        answerLocked = false;
        answersRevealed = false;
        lastRoast = "";
        lastCorrect = false;
        lastPointsEarned = 0;
        timerValue = timerMax;
        timerRunning = false;
        phase = "question";
    }

    function showAnswers() {
        answersRevealed = true;
        timerRunning = true;
    }

    function submitAnswer(index) {
        if (answerLocked || !answersRevealed || phase !== "question") return;
        playerAnswer = index;
        answerLocked = true;
        timerRunning = false;
    }

    function revealAnswer() {
        if (phase !== "question") return;
        timerRunning = false;

        var q = currentQuestionData;
        if (!q) return;

        lastCorrect = (playerAnswer === q.correct);
        if (lastCorrect) {
            var timeBonus = Math.floor(timerValue / timerMax * 50);
            lastPointsEarned = 50 + timeBonus; // 50 base + up to 50 time bonus
            score += lastPointsEarned;
        } else {
            lastPointsEarned = 0;
        }

        lastRoast = !lastCorrect ? q.roast : "";
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
        playerAnswer = -1;
        answerLocked = false;
        score = 0;
        timerValue = 0;
        timerRunning = false;
        answersRevealed = false;
        lastRoast = "";
        lastCorrect = false;
        lastPointsEarned = 0;
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

            // Player (bottom half)
            PlayerView {
                width: parent.width
                height: parent.height * 0.5 - 2
                game: root
            }
        }
    }
}
