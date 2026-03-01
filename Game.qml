import QtQuick
import "QuizParser.js" as QuizParser

// TODO: Replace shared properties with clay_network P2P
// Currently all three views share state via direct property bindings.
// For a real multi-device setup, the game state would be synced over
// the network using Clayground's clay_network plugin.

Item {
    id: root
    signal pointRevealStarted()

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
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0)
                    quizData = QuizParser.parse(xhr.responseText);
                else
                    console.error("Failed to load questions.md:", xhr.status);
            }
        };
        xhr.open("GET", Qt.resolvedUrl("questions.md"));
        xhr.send();
    }

    // --- Game state ---
    property bool musicStarted: false
    // Phases: title|roundIntro|question|reveal|scoreboard|finale
    //         |singingActive|singingReveal
    //         |duelPick|duelCounter|duelResult
    //         |console|consoleResult
    property string phase: "title"
    property int currentRound: 0
    property int currentQuestion: 0
    property bool answersRevealed: false
    property int timerValue: 0   // in tenths of a second
    property int timerMax: 150   // 15.0 seconds
    property bool timerRunning: false
    property string lastRoast: ""

    // --- Singing state ---
    property bool singingTimerStarted: false

    // --- Console state ---
    property bool scenarioSolved: false

    // --- Plank-duel state ---
    property int plankBasti: 0       // 0..4, at 4 = fallen off
    property int plankCrowd: 0       // 0..4
    property int duelTurn: 0
    property int duelMaxTurns: 4
    property bool plankShrunk: false
    property var usedInsults: []
    property var insultChoices: []    // 3 insult indices for crowd to pick
    property int chosenInsultIdx: -1  // which insult was picked
    property var currentDuelData: null // the chosen insult/counter data
    property string duelWinner: ""

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
    readonly property string currentMode: currentRoundData ? currentRoundData.mode : ""

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

    function jumpToRound(index) {
        if (index < 0 || index >= totalRounds) return;
        currentRound = index;
        currentQuestion = 0;
        player1Score = 0;
        player2Score = 0;
        phase = "roundIntro";
    }

    function startRound() {
        currentQuestion = 0;
        switch (currentMode) {
        case "singing":
            _startSong();
            break;
        case "dos-console":
            _startConsoleScenario();
            break;
        case "plank-duel":
            _startDuelTurn();
            break;
        default:
            _showQuestion();
            break;
        }
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
        if (!timerRunning && timerValue <= 0) return;

        if (playerIndex === 0 && !player1Locked) {
            player1Answer = answerIndex;
            player1Locked = true;
        } else if (playerIndex === 1 && !player2Locked) {
            player2Answer = answerIndex;
            player2Locked = true;
        }

        if (player1Locked && player2Locked)
            timerRunning = false;
    }

    function revealAnswer() {
        if (phase !== "question") return;
        timerRunning = false;

        var q = currentQuestionData;
        if (!q) return;

        if (currentMode === "taste") {
            // Taste mode: match = both chose the same option
            var match = (player1Answer >= 0 && player1Answer === player2Answer);
            player1Correct = match;
            player2Correct = match;
            player1PointsEarned = match ? 100 : 0;
            player2PointsEarned = match ? 100 : 0;
            lastRoast = "";
        } else {
            // Standard quiz scoring
            player1Correct = (player1Answer === q.correct);
            if (player1Correct) {
                var tb1 = Math.floor(timerValue / timerMax * 50);
                player1PointsEarned = 50 + tb1;
            } else {
                player1PointsEarned = 0;
            }

            player2Correct = (player2Answer === q.correct);
            if (player2Correct) {
                var tb2 = Math.floor(timerValue / timerMax * 50);
                player2PointsEarned = 50 + tb2;
            } else {
                player2PointsEarned = 0;
            }

            lastRoast = (!player1Correct || !player2Correct) ? q.roast : "";
        }

        phase = "reveal";
        pointRevealStarted();
    }

    function awardPoints(playerIndex) {
        if (playerIndex === 0)
            player1Score += player1PointsEarned;
        else if (playerIndex === 1)
            player2Score += player2PointsEarned;
    }

    // --- Singing mode ---
    function _startSong() {
        player1PointsEarned = 0;
        player2PointsEarned = 0;
        player1Correct = false;
        player2Correct = false;
        singingTimerStarted = false;
        var q = currentQuestionData;
        timerValue = q && q.timer > 0 ? q.timer : 200;
        timerMax = timerValue;
        timerRunning = false;
        phase = "singingActive";
    }

    function startSongTimer() {
        singingTimerStarted = true;
        timerRunning = true;
    }

    function awardSingingPoints(p1Points, p2Points) {
        player1PointsEarned = p1Points;
        player2PointsEarned = p2Points;
        player1Correct = p1Points > 0;
        player2Correct = p2Points > 0;
        player1Score += p1Points;
        player2Score += p2Points;
        timerRunning = false;
        phase = "singingReveal";
    }

    function nextSong() {
        var qs = currentRoundData ? currentRoundData.questions : [];
        if (currentQuestion + 1 < qs.length) {
            currentQuestion++;
            _startSong();
        } else {
            phase = "scoreboard";
        }
    }

    // --- Console mode ---
    // The actual DOS terminal runs in a separate browser window
    // (dos/index.html). This just manages timer and scoring.
    function _startConsoleScenario() {
        var q = currentQuestionData;
        scenarioSolved = false;
        player1PointsEarned = 0;
        player1Correct = false;
        timerValue = q && q.timer > 0 ? q.timer : 3000;
        timerMax = timerValue;
        timerRunning = false;
        phase = "console";
    }

    function startConsoleTimer() {
        timerRunning = true;
    }

    function resolveConsole(success) {
        timerRunning = false;
        if (success) {
            player1PointsEarned = 100;
            player1Correct = true;
            player1Score += 100;
        } else {
            player1PointsEarned = 0;
            player1Correct = false;
        }
        phase = "consoleResult";
    }

    function nextConsoleStep() {
        phase = "scoreboard";
    }

    // --- Plank-duel mode ---
    function _startDuelTurn() {
        if (duelTurn === 0) {
            plankBasti = 0;
            plankCrowd = 0;
            plankShrunk = false;
            usedInsults = [];
            duelWinner = "";
        }

        // Pick 3 unused insults for crowd to choose from
        var qs = currentRoundData ? currentRoundData.questions : [];
        var available = [];
        for (var i = 0; i < qs.length; i++) {
            if (usedInsults.indexOf(i) < 0) available.push(i);
        }
        // Shuffle and take 3
        for (var j = available.length - 1; j > 0; j--) {
            var k = Math.floor(Math.random() * (j + 1));
            var tmp = available[j];
            available[j] = available[k];
            available[k] = tmp;
        }
        insultChoices = available.slice(0, Math.min(3, available.length));
        chosenInsultIdx = -1;
        currentDuelData = null;
        player1Answer = -1;
        player1Locked = false;
        player2Answer = -1;
        player2Locked = false;
        answersRevealed = false;
        phase = "duelPick";
    }

    function submitInsultChoice(choiceIdx) {
        if (phase !== "duelPick") return;
        chosenInsultIdx = choiceIdx;
        var used = usedInsults.slice();
        used.push(choiceIdx);
        usedInsults = used;

        var qs = currentRoundData ? currentRoundData.questions : [];
        currentDuelData = (choiceIdx >= 0 && choiceIdx < qs.length)
                          ? qs[choiceIdx] : null;
        currentQuestion = choiceIdx;

        timerValue = timerMax;
        timerRunning = true;
        answersRevealed = true;
        phase = "duelCounter";
    }

    function submitDuelCounter(answerIdx) {
        if (phase !== "duelCounter") return;
        player1Answer = answerIdx;
        player1Locked = true;
        timerRunning = false;
        _revealDuelResult();
    }

    function _revealDuelResult() {
        var q = currentDuelData;
        if (!q) return;

        var correct = (player1Answer === q.correct);
        player1Correct = correct;

        if (correct) {
            plankCrowd = Math.min(plankCrowd + 1, 4);
        } else {
            plankBasti = Math.min(plankBasti + 1, 4);
        }

        duelTurn++;

        // Check win condition
        if (plankBasti >= 4) {
            duelWinner = "crowd";
        } else if (plankCrowd >= 4) {
            duelWinner = "basti";
        } else if (duelTurn >= duelMaxTurns && !plankShrunk) {
            plankShrunk = true;
        }

        phase = "duelResult";
    }

    function nextDuelStep() {
        if (phase !== "duelResult") return;

        if (duelWinner !== "") {
            // Award points and go to scoreboard
            if (duelWinner === "basti") {
                player1Score += 200;
                player1PointsEarned = 200;
                player2PointsEarned = 0;
            } else {
                player2Score += 200;
                player1PointsEarned = 0;
                player2PointsEarned = 200;
            }
            phase = "scoreboard";
            return;
        }

        // Check if enough insults remain
        var qs = currentRoundData ? currentRoundData.questions : [];
        var remaining = 0;
        for (var i = 0; i < qs.length; i++) {
            if (usedInsults.indexOf(i) < 0) remaining++;
        }

        if (remaining > 0) {
            _startDuelTurn();
        } else {
            // No more insults, decide by position
            if (plankBasti > plankCrowd)
                duelWinner = "crowd";
            else if (plankCrowd > plankBasti)
                duelWinner = "basti";
            else
                duelWinner = "draw";

            if (duelWinner === "basti") {
                player1Score += 200;
                player1PointsEarned = 200;
                player2PointsEarned = 0;
            } else if (duelWinner === "crowd") {
                player2Score += 200;
                player1PointsEarned = 0;
                player2PointsEarned = 200;
            } else {
                player1Score += 100;
                player2Score += 100;
                player1PointsEarned = 100;
                player2PointsEarned = 100;
            }
            phase = "scoreboard";
        }
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
        singingTimerStarted = false;
        plankBasti = 0;
        plankCrowd = 0;
        duelTurn = 0;
        plankShrunk = false;
        usedInsults = [];
        insultChoices = [];
        chosenInsultIdx = -1;
        currentDuelData = null;
        duelWinner = "";
        scenarioSolved = false;
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
