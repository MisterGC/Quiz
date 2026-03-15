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

### Start the servers

```bash
# Terminal 1 — QML dev server (serves quiz files)
clay-dev-server /path/to/quiz

# Terminal 2 — WebDojo (serves the WASM runtime)
cd /path/to/clayground/docs && python3 scripts/serve_dev.py
```

Both servers use HTTPS with auto-generated self-signed certificates.

## LAN / Multi-Device Setup

By default the app runs in **standalone** mode — all views side by side in one
window. For multi-device play, each device takes a different role.

### Online Mode (all browsers, needs internet)

All devices open the WebDojo with their role. PeerJS cloud handles signaling.

```
# Host / Big Screen
https://<hostname>:8000/webdojo?src=https://<hostname>:8090/Game.qml#role=presentation

# Moderator
https://<hostname>:8000/webdojo?src=https://<hostname>:8090/Game.qml#role=mod

# Player 1 / Player 2
https://<hostname>:8000/webdojo?src=https://<hostname>:8090/Game.qml#role=basti
https://<hostname>:8000/webdojo?src=https://<hostname>:8090/Game.qml#role=dacrowd
```

### Offline LAN Mode (no internet required)

Desktop host (claydojo) + browser clients on tablets. The clay-dev-server
provides a built-in PeerJS signaling relay so no internet is needed.

```bash
# Terminal 1 — QML dev server + signaling relay
clay-dev-server /path/to/quiz

# Terminal 2 — WebDojo
cd /path/to/clayground/docs && python3 scripts/serve_dev.py

# Desktop host (presentation)
claydojo --sbx /path/to/quiz/Game.qml \
  --arg role=presentation \
  --arg signaling=wss://<hostname>:8090/peerjs

# Browser clients (tablets)
https://<hostname>:8000/webdojo?src=https://<hostname>:8090/Game.qml#role=mod&signaling=wss://<hostname>:8090/peerjs
https://<hostname>:8000/webdojo?src=https://<hostname>:8090/Game.qml#role=basti&signaling=wss://<hostname>:8090/peerjs
https://<hostname>:8000/webdojo?src=https://<hostname>:8090/Game.qml#role=dacrowd&signaling=wss://<hostname>:8090/peerjs
```

Replace `<hostname>` with the machine's LAN hostname (e.g. `mistergc-air-1.local`).
mDNS/Bonjour (`.local`) resolves reliably between Apple devices — no IP needed.
Fallback if mDNS doesn't work: `ipconfig getifaddr en0` and use the IP directly.

**Join flow:** The host shows a join code on screen. Clients enter this code to
connect (or pass `#session=XYZ` in the URL to join automatically).

**Self-signed certificates:** On first access per device, visit both
`https://<hostname>:8000` and `https://<hostname>:8090` directly in the browser
and accept the certificate warning. On iPads: tap "Erweitert" → "Diese Webseite
besuchen". This persists as long as the certificate stays the same.

**Party hardware setup & Packliste:** See [doc/party_setup.md](doc/party_setup.md)
for the full checklist including test procedure, Packliste, and quick-setup guide.

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
