# Retro Reckoning

A "You Don't Know Jack"-style retro quiz show, built with Clayground.

## Architecture

Single app with three views sharing game state via direct property bindings:

```
+---------------------------+-----------------+
|                           |   MODERATOR     |
|     PRESENTATION          |   Controls,     |
|     (Big Screen)          |   correct answer|
|                           +-----------------+
|     Title, rounds,        |   PLAYER        |
|     questions, scores     |   A  B          |
|                           |   C  D          |
+---------------------------+-----------------+
```

- **PresentationView** (65%) — TV show display with title, questions, scores
- **ModeratorView** (top-right 35%) — Host controls, shows correct answer
- **PlayerView** (bottom-right 35%) — Answer buttons and feedback

## Game Flow

```
title → roundIntro → question → reveal → ... → scoreboard → roundIntro → ... → finale
```

The moderator drives progression: Start Game, Start Round, Reveal Answer, Next.
The player submits answers during the question phase. A 15-second timer
auto-reveals if it expires.

## Rounds

1. **90s Games Trivia** — 5 standard multiple choice questions
2. **Insult Swordfighting** — 4 Monkey Island comeback-style questions
3. **Retro PC Survival** — 4 DOS/hardware trivia questions

## Question Format

Questions are defined in `QuestionData.js`. Each round has:
- `name`, `tagline`, `sponsor` (fake), `mode` ("standard" or "insult")
- Array of questions with: `text`, `answers[4]`, `correct` (index), `roast`

## How to Run

### WebDojo (via clay-dev-server)
```bash
clay-dev-server /Users/mistergc/dev/gamedev/quiz/Game.qml
# Open http://localhost:8090
```

### Desktop (via claydojo)
```bash
./build/bin/claydojo --sbx /Users/mistergc/dev/gamedev/quiz/Game.qml
```

## TODO

### Sound & Music
Every screen that needs audio has a `♫ TODO` badge. Sounds needed:
- Theme music loop (title screen)
- Round jingle + voiceover (round intro)
- Question reveal sting (question appears)
- Tension ticking loop (timer running)
- Correct fanfare / Wrong shame jingle (answer reveal)
- Score tally sound (scoreboard)
- Victory / end music (finale)
- Lock-in confirmation beep (player answers)
- UI click feedback (moderator buttons)
- Ambient lobby loop (player waiting)

### Networking
Currently all views share state in a single process. For multi-device play
(e.g. phones as player controllers), replace shared properties with
`clay_network` P2P sync.
