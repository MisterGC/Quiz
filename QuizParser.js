.pragma library

function parse(markdown) {
    var lines = markdown.split("\n");
    var result = {
        titlePrefix: "",
        titleName: "",
        subtitle: "",
        titleMusic: "",
        rounds: []
    };

    var i = 0;
    // Parse title (# heading)
    while (i < lines.length) {
        var line = lines[i];
        if (line.match(/^# /)) {
            var fullTitle = line.replace(/^# /, "").trim();
            var lastSpace = fullTitle.lastIndexOf(" ");
            if (lastSpace >= 0) {
                result.titlePrefix = fullTitle.substring(0, lastSpace);
                result.titleName = fullTitle.substring(lastSpace + 1);
            } else {
                result.titleName = fullTitle;
            }
            i++;
            // Parse title blockquote (subtitle, music)
            while (i < lines.length && lines[i].match(/^> /)) {
                var val = lines[i].replace(/^> /, "").trim();
                if (val.match(/^Music:\s*/i))
                    result.titleMusic = val.replace(/^Music:\s*/i, "");
                else if (!result.subtitle)
                    result.subtitle = val;
                i++;
            }
            break;
        }
        i++;
    }

    // Parse rounds (## headings)
    var currentRound = null;
    var currentQuestion = null;

    while (i < lines.length) {
        var line = lines[i];

        // Horizontal rule = round separator (cosmetic, skip)
        if (line.match(/^---/)) {
            _finishQuestion(currentRound, currentQuestion);
            currentQuestion = null;
            i++;
            continue;
        }

        // Round heading
        if (line.match(/^## /)) {
            _finishQuestion(currentRound, currentQuestion);
            currentQuestion = null;

            currentRound = {
                name: line.replace(/^## /, "").trim(),
                tagline: "",
                sponsor: "",
                mode: "quiz",
                music: "",
                questions: []
            };
            result.rounds.push(currentRound);
            i++;

            // Parse round blockquote metadata
            while (i < lines.length && lines[i].match(/^> /)) {
                var val = lines[i].replace(/^> /, "").trim();
                if (val.match(/^Sponsor:\s*/i))
                    currentRound.sponsor = val.replace(/^Sponsor:\s*/i, "");
                else if (val.match(/^Type:\s*/i))
                    currentRound.mode = val.replace(/^Type:\s*/i, "").trim();
                else if (val.match(/^Music:\s*/i))
                    currentRound.music = val.replace(/^Music:\s*/i, "");
                else if (!currentRound.tagline)
                    currentRound.tagline = val;
                i++;
            }
            continue;
        }

        // Question heading
        if (line.match(/^### /) && currentRound) {
            _finishQuestion(currentRound, currentQuestion);
            currentQuestion = {
                text: line.replace(/^### /, "").trim(),
                answers: [],
                correct: -1,
                roast: "",
                sound: "",
                artist: "",
                scenario: "",
                timer: 0,
                url: "",
                goal: "",
                hints: []
            };
            i++;

            // Parse metadata lines after heading (> Key: Value)
            while (i < lines.length && lines[i].match(/^> /)) {
                var qmeta = lines[i].replace(/^> /, "").trim();
                if (qmeta.match(/^Artist:\s*/i))
                    currentQuestion.artist = qmeta.replace(/^Artist:\s*/i, "");
                else if (qmeta.match(/^Scenario:\s*/i))
                    currentQuestion.scenario = qmeta.replace(/^Scenario:\s*/i, "");
                else if (qmeta.match(/^Timer:\s*/i))
                    currentQuestion.timer = parseInt(qmeta.replace(/^Timer:\s*/i, "")) || 0;
                else if (qmeta.match(/^Sound:\s*/i))
                    currentQuestion.sound = qmeta.replace(/^Sound:\s*/i, "");
                else if (qmeta.match(/^Url:\s*/i))
                    currentQuestion.url = qmeta.replace(/^Url:\s*/i, "");
                else if (qmeta.match(/^Goal:\s*/i))
                    currentQuestion.goal = qmeta.replace(/^Goal:\s*/i, "");
                else if (qmeta.match(/^Hint:\s*/i))
                    currentQuestion.hints.push(qmeta.replace(/^Hint:\s*/i, ""));
                else if (currentQuestion.answers.length > 0 && !currentQuestion.roast)
                    currentQuestion.roast = qmeta;
                i++;
            }
            continue;
        }

        // Answer line (checkbox style: quiz/pirate-duel/plank-duel)
        if (currentQuestion && line.match(/^- \[[ x]\] /)) {
            var isCorrect = line.match(/^- \[x\] /) !== null;
            var answerText = line.replace(/^- \[[ x]\] /, "").trim();
            if (isCorrect)
                currentQuestion.correct = currentQuestion.answers.length;
            currentQuestion.answers.push(answerText);
            i++;
            continue;
        }

        // Plain list answer (taste mode: no checkbox)
        if (currentQuestion && currentRound
            && currentRound.mode === "taste" && line.match(/^- /)) {
            var tasteAnswer = line.replace(/^- /, "").trim();
            currentQuestion.answers.push(tasteAnswer);
            i++;
            continue;
        }

        // Roast blockquote (after answers)
        if (currentQuestion && line.match(/^> /) && currentQuestion.answers.length > 0) {
            currentQuestion.roast = line.replace(/^> /, "").trim();
            i++;
            continue;
        }

        i++;
    }

    _finishQuestion(currentRound, currentQuestion);
    return result;
}

function _finishQuestion(round, question) {
    if (!round || !question) return;
    // Singing/console questions have no answers but are still valid
    var hasAnswers = question.answers.length > 0;
    var hasMeta = question.scenario !== "" || question.artist !== ""
                  || question.url !== "";
    if (hasAnswers || hasMeta)
        round.questions.push(question);
}
