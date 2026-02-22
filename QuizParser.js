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
                sound: ""
            };
            i++;

            // Check for Sound: line right after heading
            if (i < lines.length && lines[i].match(/^Sound:\s*/i)) {
                currentQuestion.sound = lines[i].replace(/^Sound:\s*/i, "").trim();
                i++;
            }
            continue;
        }

        // Answer line
        if (currentQuestion && line.match(/^- \[[ x]\] /)) {
            var isCorrect = line.match(/^- \[x\] /) !== null;
            var answerText = line.replace(/^- \[[ x]\] /, "").trim();
            if (isCorrect)
                currentQuestion.correct = currentQuestion.answers.length;
            currentQuestion.answers.push(answerText);
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
    if (round && question && question.answers.length > 0)
        round.questions.push(question);
}
