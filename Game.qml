import QtQuick
import Clayground.Common
import Clayground.Network
import "QuizParser.js" as QuizParser

Item {
    id: root
    signal pointRevealStarted()

    // ======= Role & Networking =======
    readonly property string role: Clayground.dojoArgs["role"] || "standalone"
    readonly property bool isNetworked: role !== "standalone"
    readonly property bool isHost: role === "presentation"
    readonly property bool isClient: isNetworked && !isHost

    property string sessionCode: Clayground.dojoArgs["session"] || ""
    property string signalingUrl: Clayground.dojoArgs["signaling"] || ""
    property var connectedRoles: ({})
    property bool networkReady: false

    // ======= Quiz content (parsed from questions.md) =======
    property var quizData: null
    readonly property string quizTitlePrefix: quizData ? quizData.titlePrefix : ""
    readonly property string quizTitleName: quizData ? quizData.titleName : ""
    readonly property string quizSubtitle: quizData ? quizData.subtitle : ""
    readonly property string quizTitleMusic: quizData ? quizData.titleMusic : ""
    readonly property var rounds: quizData ? quizData.rounds : []

    Component.onCompleted: {
        _loadQuiz();
        if (isHost)
            network.host();
        else if (isClient && sessionCode)
            network.join(sessionCode);
    }

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

    // ======= Game state =======
    property bool musicStarted: false
    property bool bonusAwarded: false
    // Phases: title|roundIntro|question|reveal|scoreboard|preFinale|bonusReveal|finale|outro
    //         |singingActive|singingReveal
    //         |duelPick|duelCounter|duelResult
    //         |console|consoleResult
    //         |blitzReady|blitzPair|blitzReveal|blitzDone|blitzSummary|blitzSummaryDone
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

    // --- Blitz state ---
    property var blitzResults: []
    readonly property int blitzMatchCount: {
        var count = 0;
        for (var i = 0; i < blitzResults.length; i++)
            if (blitzResults[i].matched) count++;
        return count;
    }

    // --- Plank-duel state ---
    property int plankBasti: 0       // 0..4, at 4 = fallen off
    property int plankCrowd: 0       // 0..4
    property int duelTurn: 0
    property int duelMaxTurns: 7
    property bool plankShrunk: false
    property var usedInsults: []
    property var insultChoices: []    // 4 insult indices for crowd to pick
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

    // ======= Derived =======
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

    // ======= Network =======
    Network {
        id: network
        maxNodes: 4
        topology: Network.Topology.Star
        autoRelay: false
        signalingUrl: root.signalingUrl

        onNetworkCreated: (code) => {
            root.sessionCode = code;
        }
        onNodeJoined: (nodeId) => {
            network.sendTo(nodeId, {
                action: "fullState",
                state: root._serializeState()
            });
        }
        onNodeLeft: (nodeId) => {
            var roles = root.connectedRoles;
            for (var r in roles) {
                if (roles[r] === nodeId) {
                    delete roles[r];
                    root.connectedRoles = roles;
                    root._broadcastGameState();
                    break;
                }
            }
        }
        onMessageReceived: (fromId, data) => {
            if (root.isHost)
                root._handleCommand(fromId, data);
            else
                root._handleHostMessage(data);
        }
        onStateReceived: (fromId, data) => {
            if (root.isClient)
                root._applyState(data);
        }
    }

    // Register role after connecting (client)
    Connections {
        target: network
        function onConnectedChanged() {
            if (root.isClient && network.connected)
                network.broadcast({action: "register", role: root.role});
        }
    }

    // Periodic state broadcast (host)
    Timer {
        interval: 200
        running: root.isHost && network.connected
        repeat: true
        onTriggered: root._broadcastGameState()
    }

    // Reconnection timer (client)
    Timer {
        interval: 3000
        running: root.isClient && !network.connected
                 && root.sessionCode !== ""
        repeat: true
        onTriggered: network.join(root.sessionCode)
    }

    // ======= Network helpers =======
    function _serializeState() {
        return {
            phase: phase,
            musicStarted: musicStarted,
            currentRound: currentRound,
            currentQuestion: currentQuestion,
            answersRevealed: answersRevealed,
            timerValue: timerValue,
            timerMax: timerMax,
            timerRunning: timerRunning,
            lastRoast: lastRoast,
            player1Answer: player1Answer,
            player1Locked: player1Locked,
            player1Score: player1Score,
            player1Correct: player1Correct,
            player1PointsEarned: player1PointsEarned,
            player2Answer: player2Answer,
            player2Locked: player2Locked,
            player2Score: player2Score,
            player2Correct: player2Correct,
            player2PointsEarned: player2PointsEarned,
            singingTimerStarted: singingTimerStarted,
            scenarioSolved: scenarioSolved,
            blitzResults: blitzResults,
            plankBasti: plankBasti,
            plankCrowd: plankCrowd,
            duelTurn: duelTurn,
            duelMaxTurns: duelMaxTurns,
            plankShrunk: plankShrunk,
            insultChoices: insultChoices,
            chosenInsultIdx: chosenInsultIdx,
            duelWinner: duelWinner,
            connectedRoles: connectedRoles,
            bonusAwarded: bonusAwarded
        };
    }

    function _applyState(s) {
        if (s.phase !== undefined) phase = s.phase;
        if (s.musicStarted !== undefined) musicStarted = s.musicStarted;
        if (s.currentRound !== undefined) currentRound = s.currentRound;
        if (s.currentQuestion !== undefined) currentQuestion = s.currentQuestion;
        if (s.answersRevealed !== undefined) answersRevealed = s.answersRevealed;
        if (s.timerValue !== undefined) timerValue = s.timerValue;
        if (s.timerMax !== undefined) timerMax = s.timerMax;
        if (s.timerRunning !== undefined) timerRunning = s.timerRunning;
        if (s.lastRoast !== undefined) lastRoast = s.lastRoast;
        if (s.player1Answer !== undefined) player1Answer = s.player1Answer;
        if (s.player1Locked !== undefined) player1Locked = s.player1Locked;
        if (s.player1Score !== undefined) player1Score = s.player1Score;
        if (s.player1Correct !== undefined) player1Correct = s.player1Correct;
        if (s.player1PointsEarned !== undefined) player1PointsEarned = s.player1PointsEarned;
        if (s.player2Answer !== undefined) player2Answer = s.player2Answer;
        if (s.player2Locked !== undefined) player2Locked = s.player2Locked;
        if (s.player2Score !== undefined) player2Score = s.player2Score;
        if (s.player2Correct !== undefined) player2Correct = s.player2Correct;
        if (s.player2PointsEarned !== undefined) player2PointsEarned = s.player2PointsEarned;
        if (s.singingTimerStarted !== undefined) singingTimerStarted = s.singingTimerStarted;
        if (s.scenarioSolved !== undefined) scenarioSolved = s.scenarioSolved;
        if (s.blitzResults !== undefined) blitzResults = s.blitzResults;
        if (s.plankBasti !== undefined) plankBasti = s.plankBasti;
        if (s.plankCrowd !== undefined) plankCrowd = s.plankCrowd;
        if (s.duelTurn !== undefined) duelTurn = s.duelTurn;
        if (s.duelMaxTurns !== undefined) duelMaxTurns = s.duelMaxTurns;
        if (s.plankShrunk !== undefined) plankShrunk = s.plankShrunk;
        if (s.insultChoices !== undefined) insultChoices = s.insultChoices;
        if (s.chosenInsultIdx !== undefined) chosenInsultIdx = s.chosenInsultIdx;
        if (s.duelWinner !== undefined) duelWinner = s.duelWinner;
        if (s.connectedRoles !== undefined) connectedRoles = s.connectedRoles;
        if (s.bonusAwarded !== undefined) bonusAwarded = s.bonusAwarded;
        // Recompute currentDuelData from synced indices
        if (chosenInsultIdx >= 0 && currentRoundData) {
            var qs = currentRoundData.questions;
            currentDuelData = (chosenInsultIdx < qs.length)
                              ? qs[chosenInsultIdx] : null;
        } else {
            currentDuelData = null;
        }
        networkReady = true;
    }

    function _sendCommand(cmd) {
        if (network.connected)
            network.broadcast(cmd);
    }

    function _handleCommand(fromId, cmd) {
        var senderRole = _roleForNode(fromId);
        switch (cmd.action) {
        case "register":
            var roles = connectedRoles;
            roles[cmd.role] = fromId;
            connectedRoles = roles;
            network.sendTo(fromId, {
                action: "fullState",
                state: _serializeState()
            });
            _broadcastGameState();
            break;
        case "startMusic":
            if (senderRole === "mod") startMusic();
            break;
        case "startGame":
            if (senderRole === "mod") startGame();
            break;
        case "jumpToRound":
            if (senderRole === "mod") jumpToRound(cmd.index);
            break;
        case "startRound":
            if (senderRole === "mod") startRound();
            break;
        case "showAnswers":
            if (senderRole === "mod") showAnswers();
            break;
        case "revealAnswer":
            if (senderRole === "mod") revealAnswer();
            break;
        case "nextStep":
            if (senderRole === "mod") nextStep();
            break;
        case "advanceFromScoreboard":
            if (senderRole === "mod") advanceFromScoreboard();
            break;
        case "restartGame":
            if (senderRole === "mod") restartGame();
            break;
        case "submitAnswer":
            if ((senderRole === "basti" && cmd.playerIndex === 0)
                || (senderRole === "dacrowd" && cmd.playerIndex === 1))
                submitAnswer(cmd.playerIndex, cmd.answerIndex);
            break;
        case "submitInsultChoice":
            if (senderRole === "dacrowd") submitInsultChoice(cmd.choiceIdx);
            break;
        case "submitDuelCounter":
            if (senderRole === "basti") submitDuelCounter(cmd.answerIdx);
            break;
        case "startSongTimer":
            if (senderRole === "mod") startSongTimer();
            break;
        case "awardSingingPoints":
            if (senderRole === "mod") awardSingingPoints(cmd.p1Points, cmd.p2Points);
            break;
        case "nextSong":
            if (senderRole === "mod") nextSong();
            break;
        case "startConsoleTimer":
            if (senderRole === "mod") startConsoleTimer();
            break;
        case "resolveConsole":
            if (senderRole === "mod") resolveConsole(cmd.success);
            break;
        case "nextConsoleStep":
            if (senderRole === "mod") nextConsoleStep();
            break;
        case "nextDuelStep":
            if (senderRole === "mod") nextDuelStep();
            break;
        case "startBlitz":
            if (senderRole === "mod") startBlitz();
            break;
        case "startBlitzSummary":
            if (senderRole === "mod") startBlitzSummary();
            break;
        case "advanceFromBlitzSummary":
            if (senderRole === "mod") advanceFromBlitzSummary();
            break;
        case "revealBonus":
            if (senderRole === "mod") revealBonus();
            break;
        case "showFinale":
            if (senderRole === "mod") showFinale();
            break;
        case "startOutro":
            if (senderRole === "mod") startOutro();
            break;
        }
    }

    function _handleHostMessage(data) {
        if (data.action === "fullState")
            _applyState(data.state);
    }

    function _roleForNode(nodeId) {
        for (var r in connectedRoles) {
            if (connectedRoles[r] === nodeId) return r;
        }
        return "";
    }

    function _broadcastGameState() {
        if (isHost && network.connected)
            network.broadcastState(_serializeState());
    }

    // ======= State machine =======
    function startMusic() {
        if (isClient) { _sendCommand({action: "startMusic"}); return; }
        musicStarted = true;
        _broadcastGameState();
    }

    function startGame() {
        if (isClient) { _sendCommand({action: "startGame"}); return; }
        currentRound = 0;
        player1Score = 0;
        player2Score = 0;
        phase = "roundIntro";
        _broadcastGameState();
    }

    function jumpToRound(index) {
        if (isClient) { _sendCommand({action: "jumpToRound", index: index}); return; }
        if (index < 0 || index >= totalRounds) return;
        currentRound = index;
        currentQuestion = 0;
        player1Score = 0;
        player2Score = 0;
        phase = "roundIntro";
        _broadcastGameState();
    }

    function startRound() {
        if (isClient) { _sendCommand({action: "startRound"}); return; }
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
        case "taste":
            _startBlitz();
            break;
        default:
            _showQuestion();
            break;
        }
        _broadcastGameState();
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

        if (currentMode === "bouncer") {
            player2Locked = true;
        }

        if (currentMode === "taste") {
            if (currentQuestion <= 2)      timerMax = 100;
            else if (currentQuestion <= 5) timerMax = 70;
            else if (currentQuestion === 6) timerMax = 50;
            else                            timerMax = 30;
        }

        timerValue = timerMax;
        timerRunning = false;
        phase = "question";
    }

    function showAnswers() {
        if (isClient) { _sendCommand({action: "showAnswers"}); return; }
        answersRevealed = true;
        timerRunning = true;
        _broadcastGameState();
    }

    function submitAnswer(playerIndex, answerIndex) {
        if (isClient) {
            _sendCommand({
                action: "submitAnswer",
                playerIndex: playerIndex,
                answerIndex: answerIndex
            });
            return;
        }
        if (!answersRevealed || (phase !== "question" && phase !== "blitzPair")) return;
        if (!timerRunning && timerValue <= 0) return;
        if (currentMode === "bouncer" && playerIndex === 1) return;

        if (playerIndex === 0 && !player1Locked) {
            player1Answer = answerIndex;
            player1Locked = true;
        } else if (playerIndex === 1 && !player2Locked) {
            player2Answer = answerIndex;
            player2Locked = true;
        }

        if (player1Locked && player2Locked) {
            timerRunning = false;
            if (phase === "blitzPair") {
                _blitzReveal();
            }
        }
        _broadcastGameState();
    }

    function revealAnswer() {
        if (isClient) { _sendCommand({action: "revealAnswer"}); return; }
        if (phase !== "question") return;
        timerRunning = false;

        var q = currentQuestionData;
        if (!q) return;

        if (currentMode === "taste") {
            var match = (player1Answer >= 0 && player1Answer === player2Answer);
            player1Correct = match;
            player2Correct = match;
            player1PointsEarned = match ? 100 : 0;
            player2PointsEarned = match ? 100 : 0;
            lastRoast = "";
        } else {
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
        _broadcastGameState();
    }

    function awardPoints(playerIndex) {
        if (playerIndex === 0)
            player1Score += player1PointsEarned;
        else if (playerIndex === 1)
            player2Score += player2PointsEarned;
        _broadcastGameState();
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
        if (isClient) { _sendCommand({action: "startSongTimer"}); return; }
        singingTimerStarted = true;
        timerRunning = true;
        _broadcastGameState();
    }

    function awardSingingPoints(p1Points, p2Points) {
        if (isClient) {
            _sendCommand({
                action: "awardSingingPoints",
                p1Points: p1Points,
                p2Points: p2Points
            });
            return;
        }
        player1PointsEarned = p1Points;
        player2PointsEarned = p2Points;
        player1Correct = p1Points > 0;
        player2Correct = p2Points > 0;
        player1Score += p1Points;
        player2Score += p2Points;
        timerRunning = false;
        phase = "singingReveal";
        _broadcastGameState();
    }

    function nextSong() {
        if (isClient) { _sendCommand({action: "nextSong"}); return; }
        var qs = currentRoundData ? currentRoundData.questions : [];
        if (currentQuestion + 1 < qs.length) {
            currentQuestion++;
            _startSong();
        } else {
            phase = "scoreboard";
        }
        _broadcastGameState();
    }

    // --- Console mode ---
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
        if (isClient) { _sendCommand({action: "startConsoleTimer"}); return; }
        timerRunning = true;
        _broadcastGameState();
    }

    function resolveConsole(success) {
        if (isClient) { _sendCommand({action: "resolveConsole", success: success}); return; }
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
        _broadcastGameState();
    }

    function nextConsoleStep() {
        if (isClient) { _sendCommand({action: "nextConsoleStep"}); return; }
        phase = "scoreboard";
        _broadcastGameState();
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

        // Pick unused insults for crowd to choose from
        var qs = currentRoundData ? currentRoundData.questions : [];
        var available = [];
        for (var i = 0; i < qs.length; i++) {
            if (usedInsults.indexOf(i) < 0) available.push(i);
        }
        // Shuffle and take up to 4
        for (var j = available.length - 1; j > 0; j--) {
            var k = Math.floor(Math.random() * (j + 1));
            var tmp = available[j];
            available[j] = available[k];
            available[k] = tmp;
        }
        insultChoices = available.slice(0, Math.min(4, available.length));
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
        if (isClient) { _sendCommand({action: "submitInsultChoice", choiceIdx: choiceIdx}); return; }
        if (phase !== "duelPick") return;
        chosenInsultIdx = choiceIdx;
        player2Locked = true;
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
        _broadcastGameState();
    }

    function submitDuelCounter(answerIdx) {
        if (isClient) { _sendCommand({action: "submitDuelCounter", answerIdx: answerIdx}); return; }
        if (phase !== "duelCounter") return;
        player1Answer = answerIdx;
        player1Locked = true;
        timerRunning = false;
        _revealDuelResult();
        _broadcastGameState();
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
        if (isClient) { _sendCommand({action: "nextDuelStep"}); return; }
        if (phase !== "duelResult") return;

        if (duelWinner !== "") {
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
            _broadcastGameState();
            return;
        }

        var qs = currentRoundData ? currentRoundData.questions : [];
        var remaining = 0;
        for (var i = 0; i < qs.length; i++) {
            if (usedInsults.indexOf(i) < 0) remaining++;
        }

        if (remaining > 0) {
            _startDuelTurn();
        } else {
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
        _broadcastGameState();
    }

    // --- Blitz mode (taste round) ---
    function _startBlitz() {
        blitzResults = [];
        currentQuestion = 0;
        phase = "blitzReady";
    }

    function startBlitz() {
        if (isClient) { _sendCommand({action: "startBlitz"}); return; }
        _startBlitzPair();
        _broadcastGameState();
    }

    function _startBlitzPair() {
        player1Answer = -1;
        player2Answer = -1;
        player1Locked = false;
        player2Locked = false;
        answersRevealed = true;
        timerMax = 50;
        timerValue = timerMax;
        timerRunning = true;
        phase = "blitzPair";
    }

    function _blitzReveal() {
        timerRunning = false;
        var matched = (player1Answer >= 0 && player1Answer === player2Answer);
        var qs = currentRoundData ? currentRoundData.questions : [];
        var pairData = (currentQuestion >= 0 && currentQuestion < qs.length)
                       ? qs[currentQuestion] : null;
        var results = blitzResults.slice();
        results.push({
            bastiAnswer: player1Answer,
            crowdAnswer: player2Answer,
            matched: matched,
            pairText: pairData ? pairData.text : "",
            answers: pairData ? pairData.answers : []
        });
        blitzResults = results;
        phase = "blitzReveal";
        timerMax = 20;
        timerValue = timerMax;
        timerRunning = true;
    }

    function _blitzAdvance() {
        timerRunning = false;
        var qs = currentRoundData ? currentRoundData.questions : [];
        if (currentQuestion + 1 < qs.length) {
            currentQuestion++;
            _startBlitzPair();
        } else {
            phase = "blitzDone";
        }
    }

    function startBlitzSummary() {
        if (isClient) { _sendCommand({action: "startBlitzSummary"}); return; }
        phase = "blitzSummary";
        timerMax = blitzResults.length * 30 + 20;
        timerValue = timerMax;
        timerRunning = true;
        _broadcastGameState();
    }

    function advanceFromBlitzSummary() {
        if (isClient) { _sendCommand({action: "advanceFromBlitzSummary"}); return; }
        var points = blitzMatchCount * 50;
        player1Score += points;
        player2Score += points;
        player1PointsEarned = points;
        player2PointsEarned = points;
        phase = "scoreboard";
        _broadcastGameState();
    }

    function nextStep() {
        if (isClient) { _sendCommand({action: "nextStep"}); return; }
        if (phase !== "reveal") return;

        var qs = currentRoundData ? currentRoundData.questions : [];
        if (currentQuestion + 1 < qs.length) {
            currentQuestion++;
            _showQuestion();
        } else {
            phase = "scoreboard";
        }
        _broadcastGameState();
    }

    function advanceFromScoreboard() {
        if (isClient) { _sendCommand({action: "advanceFromScoreboard"}); return; }
        if (phase !== "scoreboard") return;

        if (currentRound + 1 < totalRounds) {
            currentRound++;
            phase = "roundIntro";
        } else {
            phase = "preFinale";
        }
        _broadcastGameState();
    }

    function revealBonus() {
        if (isClient) { _sendCommand({action: "revealBonus"}); return; }
        if (phase !== "preFinale") return;
        player1Score += 10000;
        bonusAwarded = true;
        phase = "bonusReveal";
        _broadcastGameState();
    }

    function showFinale() {
        if (isClient) { _sendCommand({action: "showFinale"}); return; }
        if (phase !== "bonusReveal") return;
        phase = "finale";
        _broadcastGameState();
    }

    function startOutro() {
        if (isClient) { _sendCommand({action: "startOutro"}); return; }
        if (phase !== "finale") return;
        phase = "outro";
        _broadcastGameState();
    }

    function restartGame() {
        if (isClient) { _sendCommand({action: "restartGame"}); return; }
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
        blitzResults = [];
        bonusAwarded = false;
        phase = "title";
        _broadcastGameState();
    }

    // --- Timer (only runs on host/standalone) ---
    Timer {
        interval: 100
        running: root.timerRunning && !root.isClient
        repeat: true
        onTriggered: {
            if (root.timerValue > 0) {
                root.timerValue--;
            } else {
                root.timerRunning = false;
                if (root.phase === "blitzPair") {
                    root._blitzReveal();
                    root._broadcastGameState();
                } else if (root.phase === "blitzReveal") {
                    root._blitzAdvance();
                    root._broadcastGameState();
                } else if (root.phase === "blitzSummary") {
                    root.phase = "blitzSummaryDone";
                    root._broadcastGameState();
                }
            }
        }
    }

    // ======= Layout =======
    Rectangle {
        anchors.fill: parent
        color: "#0d0d1a"
    }

    // === Standalone: all views side by side ===
    Row {
        anchors.fill: parent
        visible: !root.isNetworked

        PresentationView {
            width: parent.width * 0.65
            height: parent.height
            game: root
        }

        Rectangle {
            width: 2
            height: parent.height
            color: "#333355"
        }

        Column {
            width: parent.width * 0.35 - 2
            height: parent.height

            ModeratorView {
                width: parent.width
                height: parent.height * 0.5
                game: root
            }

            Rectangle {
                width: parent.width
                height: 2
                color: "#333355"
            }

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

    // === Networked: role-specific fullscreen view ===
    Loader {
        id: roleView
        anchors.fill: parent
        active: root.isNetworked

        Component.onCompleted: {
            if (!root.isNetworked) return;
            switch (root.role) {
            case "presentation":
                setSource("PresentationView.qml", {game: root});
                break;
            case "mod":
                setSource("ModeratorView.qml", {game: root});
                break;
            case "basti":
                setSource("PlayerView.qml", {game: root, playerIndex: 0});
                break;
            case "dacrowd":
                setSource("PlayerView.qml", {game: root, playerIndex: 1});
                break;
            }
        }
    }

    // === Host: join code overlay (top-right corner) ===
    Rectangle {
        visible: root.isHost && root.sessionCode !== ""
        anchors { top: parent.top; right: parent.right; margins: 12 }
        width: codeCol.width + 24
        height: codeCol.height + 16
        radius: 8
        color: "#cc1a1a2e"
        border.color: "#ffcc00"
        border.width: 1
        z: 10

        Column {
            id: codeCol
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: "CODE: " + root.sessionCode
                color: "#ffcc00"
                font { pixelSize: 18; bold: true; family: "monospace" }
            }
            Text {
                text: {
                    var parts = [];
                    parts.push(root.connectedRoles["mod"]
                               ? "Mod \u2713" : "Mod ...");
                    parts.push(root.connectedRoles["basti"]
                               ? "Basti \u2713" : "Basti ...");
                    parts.push(root.connectedRoles["dacrowd"]
                               ? "Crowd \u2713" : "Crowd ...");
                    return parts.join("  ");
                }
                color: "#aaaacc"
                font { pixelSize: 11; family: "monospace" }
            }
        }
    }

    // === Client: join screen (covers view until connected + synced) ===
    Rectangle {
        anchors.fill: parent
        visible: root.isClient && !root.networkReady
        color: "#0d0d1a"
        z: 20

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    switch (root.role) {
                    case "mod": return "MODERATOR";
                    case "basti": return "BASTI";
                    case "dacrowd": return "DA CROWD";
                    default: return root.role.toUpperCase();
                    }
                }
                color: "#ffcc00"
                font { pixelSize: 28; bold: true; family: "monospace" }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (network.status === Network.Status.Connecting)
                        return "Verbinde...";
                    if (network.connected)
                        return "Verbunden! Warte auf Spielstand...";
                    if (root.sessionCode !== "")
                        return "Verbindung verloren \u2014 verbinde neu...";
                    return "Spiel-Code eingeben:";
                }
                color: (root.sessionCode !== "" && !network.connected
                        && network.status !== Network.Status.Connecting)
                       ? "#ff6644" : "#aaaacc"
                font { pixelSize: 14; family: "monospace" }
            }

            // Code input
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 220; height: 48
                radius: 8
                color: "#2a2a4e"
                border.color: codeInput.activeFocus ? "#ffcc00" : "#555577"
                border.width: 1
                visible: !network.connected

                TextInput {
                    id: codeInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: "#ffffff"
                    font { pixelSize: 22; bold: true; family: "monospace" }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    inputMethodHints: Qt.ImhUppercaseOnly
                    onAccepted: {
                        if (text.length > 0) {
                            root.sessionCode = text.toUpperCase();
                            network.join(root.sessionCode);
                        }
                    }
                }
            }

            // Connect button
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 180; height: 48; radius: 8
                color: codeInput.text.length > 0 ? "#2a7a3a" : "#333355"
                visible: !network.connected

                Text {
                    anchors.centerIn: parent
                    text: "Verbinden"
                    color: "#ffffff"
                    font { pixelSize: 18; bold: true; family: "monospace" }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (codeInput.text.length > 0) {
                            root.sessionCode = codeInput.text.toUpperCase();
                            network.join(root.sessionCode);
                        }
                    }
                }
            }
        }
    }
}
