# You don't Know Rämpf!

Eine Show über, für und mit unserem guten Freund Basti.
Moderiert von Serein und Nico, begleitet durch die App.
Dauer: ca. 45 Minuten (feinjustierbar über Markdown-Config pro Runde).

## Allgemeine Regeln

- **Zwei Spieler**: Basti (Player 1) und die Crowd (Player 2)
- **Crowd-Terminal**: Die Crowd hat immer nur EIN Terminal zum Wählen
  und muss sich untereinander einigen — das gilt für alle Runden
- **Fragen/Inhalt**: Nicht hardcoded, sondern über Markdown-Config-Dateien
  pro Runde definiert (Anzahl, Texte, Timer, etc.)
- **Moderation**: Serein und Nico moderieren live, die App unterstützt
  mit Anzeigen, Timern und Hinweisen

---

## Runde 1: "Hello my Friend, what can I do for you?"
_~8 Min (5 Fragen à ~1,5 Min + Übergänge)_

Es werden Fragen zu Spielen und Filmen, vor allem aus den 90er Jahren gestellt.

### Mechanik

- Basti vs. Crowd, klassisches Multiple Choice (4 Antworten)
- Beide Seiten wählen gleichzeitig, Punkte für richtige Antwort
- Konfigurierbarer Timer pro Frage, Moderator deckt danach auf
- Roast-Text wird NUR auf dem Moderator-Display angezeigt (als
  Moderationshinweis), NICHT auf der Präsentationssicht

### Inhalt

- 90er Games & Film-Trivia
- Anzahl Fragen und Inhalte über Markdown-Config

Gothic 1:
"Du? - Ich fress dich zum Frühstück Kleiner!"
"Nichts wird so heiß gegessen, wie es gekocht wird."
"Fleischwanzen Ragut alá Snuff, mit Reis und Pilzen."
"Steck die scheiß Waffe weg! - Glück gehabt."
"Verpiss dich!"

Diablo 1:
I sense a soul in search of answers...
The darkness grows stronger beneath the cathedral ...
Well, what can I do for ya?
Hello, my friend. Stay awhile and listen...

"Please, listen to me. The Archbishop Lazarus, he lead us down here to find the lost prince. The bastard lead us into a trap! Now everyone is dead... Killed by a Demon he called the Butcher. Avenge us! Find this Butcher and slay him, so that our souls may finally rest..."
"Your death will be avenged!"

Blade Movie:

Fünftes Element:



### Sound & Musik

Verwendet ausschließlich showweite Assets (siehe unten):
- Timer/Denk-Musik (Loop während Bedenkzeit)
- Lock-in Chime bei Antwort-Wahl
- Antwort-Reveal Sting beim Aufdecken
- Richtig/Falsch-Sting + Roast-Sting bei Ergebnis

### Grafische Assets

Bestehende Views reichen (PresentationView, ModeratorView, PlayerView).

### Moderation

- Serein/Nico lesen Fragen vor, kommentieren die Antworten
- Roast-Texte vom Mod-Display ablesen und mit eigener Würze liefern
- Einstiegsrunde — locker halten, Stimmung aufbauen, Publikum warmreden

---

## Runde 2: "Duell auf der Affeninsel"
_~8 Min (4+ Duelle à ~1,5 Min + Übergänge)_

Wir stellen die berühmten Spruch/Reim-Duelle aus Monkey Island nach.

### Mechanik

1. Das Programm wählt aus dem Pool eine Beleidigung aus (keine doppelt)
2. Die Crowd sieht mehrere Beleidigungen und wählt eine davon
3. Basti sieht die gewählte Beleidigung und muss den richtigen Konter
   aus mehreren Optionen finden
4. Visuell: Zwei statische Piraten-Sprites auf einem Balken (Planken-Duell)
   - Richtige Antwort von Basti → Crowd-Sprite wird zurückgedrängt
   - Falsche Antwort → Basti-Sprite wird zurückgedrängt
5. Wer runterfällt verliert, ODER nach 4 Fragen wird der Balken verkürzt
   und die letzte Frage entscheidet (Elfmeter-Modus)
6. Der Gewinner der Runde bekommt Punkte (Crowd kann also auch gewinnen)

### Inhalt

- Großer Pool an Beleidigung/Konter-Paaren (inspiriert durch Monkey Island)
- Jede Beleidigung hat mehrere mögliche Konter (inkl. dem korrekten)
- Pool und Paare über Markdown-Config definiert
- Das Programm wählt zufällig aus dem Pool, keine Beleidigung doppelt

### Sound & Musik

#### Beleidigungsfechten-Intro (Suno v5)

Spezial-Jingle für den Runden-Start. Piratenflair trifft Gameshow.

**Style of Music:**
```
pirate shanty meets lounge jazz, accordion, sea shanty rhythm, comedic, slightly dramatic, 20 seconds, German, male vocal
```

**Lyrics:**
```
[Instrumental, accordion riff with jazzy upright bass]

[Sung, dramatic pirate voice]
Zieh dein Schwert und deine besten Sprüche
Heute Nacht wird gefochten — in der Küche!

[Instrumental, accordion flourish, end]
```

#### Duell-Ambiente (Suno v5)

Hintergrund-Loop während des gesamten Planken-Duells. Monkey-Island-Flair:
Man steht auf einer Planke über dem Meer, Holz knarzt unter den Füßen,
Möwen kreisen, die Karibik-Sonne brennt — aber die Klingen sind gezückt.
Dezente Spannung, ohne die Moderation zu übertönen. Loop-freundlich,
wird leiser gemischt wenn Crowd/Basti wählen.

**Style of Music:**
```
caribbean pirate ambient, gentle ocean waves against wooden hull, creaking ship
timber, distant seagulls, subtle tension strings, nylon guitar, mysterious
adventure atmosphere, Monkey Island inspired, loop-friendly, instrumental, 45
seconds
```

**Struktur:**
```
[Ambient, ocean waves lapping gently, wooden hull creaking rhythmically]

[Instrumental, soft plucked nylon guitar enters, laid-back Caribbean feel]

[Instrumental, low mysterious strings underneath, subtle tension building]

[Ambient, distant seagull cry, waves swell gently, timber groans]

[Instrumental, tension holds steady, nylon guitar continues, clean loop point]
```

#### Duell-Soundeffekte (ElevenLabs)

| Trigger | SFX | ElevenLabs Prompt | Dauer |
|---------|-----|-------------------|-------|
| Beide Wahlen stehen, Klingen kreuzen sich | Säbelkreuzen | `two pirate cutlasses clashing together, sharp metallic sword impact with brief steel ring, swashbuckling duel, crisp and punchy` | 0.5s |
| Richtiger Konter — Gegner wird zurückgedrängt | Treffer | `sword thrust landing with impact, blade hitting shield with force, wooden plank creaking under shifting weight, comedic pirate duel hit` | 0.8s |
| Falscher Konter — Spieler wird zurückgedrängt | Verfehlt | `sword swing missing, awkward stumble on wooden plank, boot sliding on wet wood, off-balance wobble` | 0.7s |
| Verlierer fällt von der Planke | Ins Wasser fallen | `person falling off wooden plank into ocean, brief cartoon falling whistle followed by big comedic water splash, pirate overboard` | 1.5s |

Zusätzlich werden showweite Assets verwendet:
- Timer/Denk-Musik während Bastis Antwortzeit

### Grafische Assets

- `pirate_basti.png` — Piraten-Sprite für Basti (Dummy, wird ersetzt)
- `pirate_crowd.png` — Piraten-Sprite für Crowd (Dummy, wird ersetzt)
- `plank_large.png` — Großer Balken (Normalzustand)
- `plank_small.png` — Kleiner Balken (Elfmeter-Modus)
- Hintergrund: Piratenschiff-Deck / Monkey-Island-inspirierte Szene
- Keine Animationen im klassischen Sinn — Sprites wechseln Position,
  kein Rutschen/Wackeln

### Moderation

- Serein/Nico als Piraten-Kommentatoren ("Ohhh, da sitzt der Hieb!")
- Jeden Konter dramatisch kommentieren
- Spannung aufbauen wenn der Balken kürzer wird
- Bei Runterfallen: übertriebene Reaktion

---

## Runde 3: "Wenig RAM und schwere Röhren"
_~8 Min (2-3 Aufgaben à ~3 Min)_

Basti geht an den Präsentations-PC und löst in einer Fake-DOS-Konsole
retro PC-Aufgaben.

### Mechanik

- Basti spielt alleine an der Fake-Konsole (reine Solorunde)
- Basti tippt echte Befehle auf der Tastatur ein
- Bei ungültigen Befehlen: `Unknown command.`
- Hilfe-System: `help` zeigt alle verfügbaren Befehle,
  `help <befehl>` zeigt Hilfe zu einem bestimmten Befehl
- Exakter Befehl muss stimmen, keine Teilpunkte
- Konfigurierbarer Timer pro Aufgabe
- Crowd kann mündlich Tipps geben (Mods moderieren das)
- Punkte gehen nur an Basti

### Inhalt — Vorgeschlagene Szenarien

Drei typische Retro-PC-Probleme, vereinfacht für Show-Tauglichkeit:

**Szenario 1: "Wing Commander startet nicht"**
Ziel: Konventionellen Speicher freimachen, damit das Spiel startet.
- `mem` → zeigt: konventioneller Speicher zu knapp (< 580 KB frei)
- `type config.sys` → zeigt aktuelle Config (HIMEM.SYS fehlt)
- `edit config.sys` → Spieler muss `DEVICE=HIMEM.SYS` und
  `DEVICE=EMM386.EXE` eintragen
- `reboot` → System startet neu, `mem` zeigt jetzt genug Speicher
- `wc.exe` → Wing Commander startet, Erfolg!

**Szenario 2: "Doom hat keinen Sound"**
Ziel: Sound Blaster richtig konfigurieren.
- `doom.exe` → startet, aber "No sound device detected"
- `set` → zeigt: BLASTER-Variable fehlt
- `set BLASTER=A220 I5 D1` → Sound Blaster Umgebungsvariable setzen
- `sndtest` → "Sound Blaster detected. Playing test tone..." Erfolg!
- `doom.exe` → Doom startet mit Sound

**Szenario 3: "Festplatte voll — Monkey Island installieren"**
Ziel: Platz schaffen und von Diskette installieren.
- `dir` → zeigt: nur 2 MB frei, Installation braucht 8 MB
- `dir /s` → zeigt Verzeichnisse mit Speicherverbrauch
- Spieler muss unwichtige Dateien/Ordner löschen (`del`, `deltree`)
- `install a:` → Installation von Diskette starten
- Ggf. Diskettenwechsel ("Insert Disk 2...")

### Sound & Musik

#### Retro-PC Soundeffekte (ElevenLabs)

| Trigger | SFX | ElevenLabs Prompt | Dauer |
|---------|-----|-------------------|-------|
| Konsole wird gestartet | DOS POST Beep | `classic IBM PC BIOS POST beep, single short high-pitched square wave tone, retro computer startup` | 0.3s |
| Basti tippt Befehle | Tastatur-Klackern | `mechanical keyboard keypress, single clicky key, vintage IBM Model M buckling spring, crisp and tactile` | 0.15s |
| Ungültiger Befehl | Error Beep | `PC speaker error beep, short harsh buzzer tone, retro DOS invalid command, annoying square wave` | 0.3s |
| Spiel startet erfolgreich | Erfolgs-Jingle | `retro 8-bit victory chiptune, short triumphant fanfare, classic DOS game startup, bright and celebratory` | 2s |
| Dauerhaft im Hintergrund | CRT-Brummen | `CRT monitor electrical hum, subtle constant buzzing, old cathode ray tube ambient noise, very quiet` | 3s (loop) |

### Grafische Assets

- Fake-DOS-Konsole: weiß auf schwarz (echtes DOS-Look)
- Blinkender Cursor (`_`)
- ASCII-Art für Spielstart-Erfolge
- Optional: CRT-Scanline-Overlay-Effekt

### Moderation

- Serein/Nico setzen das Szenario vor jeder Aufgabe:
  "Es ist 1994, du willst Wing Commander starten, aber dein Rechner
  hat nur 4 MB RAM und nichts funktioniert..."
- Bastis Versuche live kommentieren
- Crowd-Tipps moderieren und ggf. filtern
- Können auch falsche Tipps einstreuen für Comedy
- Bei `Unknown command.` mitleidig reagieren

---

## Runde 4: "Eine Frage des Geschmacks"
_~6 Min (5-6 Fragen à ~1 Min)_

Allen werden zwei Alternativen gezeigt, Übereinstimmung gibt Punkte.

### Mechanik

- Zwei Alternativen werden gezeigt (z.B. "Tee oder Kaffee")
- Basti wählt was ER bevorzugt (muss sich entscheiden)
- Crowd wählt ebenfalls (ein Terminal, müssen sich einigen)
- Gleichzeitiges Aufdecken beider Wahlen
- Übereinstimmung = Punkte für beide, keine Übereinstimmung = keine Punkte

### Inhalt

- Paare und Anzahl über Markdown-Config definiert
- Thematisch frei (Gaming/90er oder allgemein — je nach Config)

### Sound & Musik

#### Rundenspezifische Stings (Suno v5)

**Spannungs-Sting** — vor dem Aufdecken beider Wahlen:
```
short dramatic suspense sting, rising strings with soft timpani roll, game show tension, anticipation, 4 seconds
```

**Match-Fanfare** — bei Übereinstimmung:
```
bright celebratory fanfare, warm brass with sparkle chimes, heartfelt match moment, feel-good game show, 5 seconds
```

**Kein-Match-Sting** — keine Übereinstimmung (sanft, eher "awww"):
```
gentle comedic disappointment sting, soft descending woodwinds, sympathetic not harsh, cute miss, 3 seconds
```

#### Hintergrundmusik (Suno v5)

Lockerer Loop während die Alternativen gezeigt werden.

**Style of Music:**
```
relaxed lounge jazz, warm Rhodes piano, soft brushed drums, feel-good quiz show, mellow and friendly, instrumental, loop-friendly, 30 seconds
```

### Grafische Assets

- Zwei große Karten/Buttons mit den Alternativen
- VS-Trenner dazwischen
- Reveal-Animation: Bastis Wahl + Crowd-Wahl gleichzeitig aufdecken
- Konfetti/Highlight bei Match

### Moderation

- Serein/Nico kommentieren die Alternativen, ziehen Basti auf
- Nach dem Reveal: persönliche Kommentare ("Die Crowd kennt dich!")
- Entspannte Runde — Übergang zum Finale, persönlich, lustig
- Können eigene Anekdoten zu den Themen einstreuen

---

## Runde 5: "Verstimmte Gabel, schmerzende Ohren"
_~7 Min (3-4 Songs à ~1,5 Min)_

Basti hört auf dem Kopfhörer einen Song und muss mitsingen,
die anderen müssen erraten. Die große Finale-Runde!

### Mechanik

- Basti bekommt Kopfhörer, Song wird extern abgespielt (z.B. Spotify)
- Basti singt/summt einfach drauf los — soll lustig sein
- PresentationView zeigt ein großes Fragezeichen (kein Songtitel)
- Kein Multiple Choice — Crowd ruft frei rein
- Pro Song: 15-20 Sek Snippet + konfigurierbares Zeitlimit zum Raten
  (das Zeitlimit umfasst das Abspielen)
- Mods loggen per Button: richtig/falsch
- Mods entscheiden ob Crowd UND Basti Punkte bekommen
- Wenn niemand rät: keine Punkte, Mods lösen auf
- Nach dem Auflösen: Reveal zeigt Songtitel und Interpret

### Inhalt

- Songs über Markdown-Config (Titel, Interpret, ggf. Spotify-Link)
- Populäre Songs von damals, die Basti vielleicht nicht mal mag
- Überraschung für Basti — er kennt die Songauswahl nicht vorher
- Anzahl Songs über Config

### Sound & Musik

- Songs extern über Spotify (nicht in der App)
- "Song erraten!"-Jubel: showweiten Richtig-Sting wiederverwenden
- "Niemand weiß es" / Zeit abgelaufen: showweiten Time-up Buzzer
  wiederverwenden

### Grafische Assets

- Großes Fragezeichen als zentrales UI-Element während des Singens
- Reveal-Darstellung: Songtitel + Interpret (groß, dramatisch)
- Optional: Musiknoten, Soundwellen-Visualisierung

### Moderation

- Serein/Nico sind Schiedsrichter — entscheiden ob eine Antwort gilt
- Können Hinweise geben ("Denkt an die 90er!", "Es ist ein Soundtrack...")
- Entscheiden ob eine Crowd-Antwort nah genug dran ist
- Basti für seine Performance feiern, egal wie schlecht
- Crowd anfeuern mitzuraten
- Höhepunkt der Show — Energie hochhalten!

---

## Showweite Sound-Assets

### Musik & Jingles (Suno v5)

#### 1. Intro / Titelmusik — "You Don't Know Rämpf"

Die Hauptnummer. Setzt den Ton für den ganzen Abend. Soll grooven, Nostalgie
wecken und die Mods vorstellen.

**Style of Music:**
```
funky retro game show theme, 90s hip-hop meets jazz, brass section, talk-sing, comedic, energetic, German, male vocals
```

**Lyrics:**
```
[Intro, funky bass riff with brass stabs]
[Verse 1, talk-sing, laid back but rhythmic]
Erinnert ihr euch noch an damals?
Aggressive Skating — Grinden und Springen bis die Knie bluten
Die ganze Nacht durchzocken, LAN-Party ohne Schlaf
Und Parties im Kunstpark Ost bis zum Morgengrauen

[Verse 2, talk-sing, building energy]
Ihr denkt, ihr wisst noch alles
Jedes Cheat-Passwort, jeden Titelsong
Dann beweist es jetzt
Oder blamiert euch vor allen — die ganze Nacht lang

[Chorus, sung, groovy with brass]
You Don't Know Rämpf!
Ihr wisst gar nichts und das wird peinlich
You Don't Know Rämpf!
Die Show, die Freundschaften auf die Probe stellt

[Verse 3, talk-sing, announcer energy]
Eure Gastgeber heute Abend
Er lächelt wie ein Moderator und fragt wie ein Staatsanwalt
Sein Charme ist echt, sein Anspruch hoch
Smooth, schlagfertig und absolut gnadenlos — Nico!

[Verse 4, talk-sing, same energy]
Und sein Partner in Crime
Er begrüßt euch mit Stil und bringt euch auf Touren
Sein Pokerface ist Legende, sein Timing perfekt
Der Mann mit dem Plan und den Fragen — Serein!

[Chorus, sung, full energy]
You Don't Know Rämpf!
Zeigt was ihr könnt — seid ihr der Challenge gewachsen?
You Don't Know Rämpf!
Drück den Buzzer, lüg dich durch und hoffe auf Glück

[Outro, brass fanfare fading into funky bass]
```

#### 2. Runden-Jingle

Kurzer Energiestoß wenn eine neue Runde startet.

**Style of Music:**
```
short retro game show jingle, funky brass stab, 8-bit synth accent, punchy, 15 seconds, German, male vocal
```

**Lyrics:**
```
[Instrumental, synth fanfare with brass]

[Sung, short and punchy]
Neue Runde, neues Glück
Wer hier pennt, fällt zurück!

[Instrumental, brass sting, hard cut]
```

#### 3. Timer / Denk-Musik

Hintergrundmusik während die Spieler nachdenken. Spannung aufbauen ohne
zu nerven. Loop-freundlich.

**Style of Music:**
```
tense game show thinking music, ticking clock percussion, jazzy Rhodes piano, building suspense, lounge noir, instrumental, loop-friendly, 30 seconds
```

**Struktur:**
```
[Instrumental, soft Rhodes piano with ticking hi-hat]

[Instrumental, subtle bass enters, tension building]

[Instrumental, soft brass swell, tempo holds steady]

[Instrumental, peak tension, clean cut for loop point]
```

#### 4. Richtige Antwort — Sting

3–5 Sekunden Jubel.

**Style of Music:**
```
short triumphant game show sting, brass fanfare, 5 seconds, celebratory, retro, energetic
```

**Struktur:**
```
[Instrumental, bright brass fanfare with cymbal crash]
```

#### 5. Falsche Antwort — Sting

3–5 Sekunden Enttäuschung. Komisch, nicht gemein.

**Style of Music:**
```
short comedic fail sting, sad trombone, descending notes, 5 seconds, funny, game show
```

**Struktur:**
```
[Instrumental, sad trombone wah-wah-wah, descending]
```

#### 6. Antwort-Reveal — Sting

Wenn der Moderator die richtige Antwort aufdeckt. Dramatischer
Trommelwirbel-Moment.

**Style of Music:**
```
dramatic reveal sting, drum roll into brass hit, tension to release, game show, 8 seconds
```

**Struktur:**
```
[Instrumental, snare drum roll building]

[Instrumental, single big brass hit with cymbal]
```

#### 7. Roast-Sting

Kurzer musikalischer Unterstrich wenn der Roast-Text eingeblendet wird.

**Style of Music:**
```
cheeky short sting, jazzy bass lick, comedic timing, lounge sleaze, 4 seconds
```

**Struktur:**
```
[Instrumental, walking bass lick with brush snare hit]
```

#### 8. Finale / Siegerehrung

Episches Ende. Übertrieben dramatisch, mit Augenzwinkern.

**Style of Music:**
```
epic game show finale, 80s synth power ballad meets brass fanfare, triumphant, dramatic, comedic undertone, German, male vocal, 30 seconds
```

**Lyrics:**
```
[Instrumental, epic synth pad with rising brass]

[Sung, dramatic and over-the-top]
Ein Held steht heute hier
Durch Wissen, Glück und keine Scham
Der Rest geht leer nach Haus

[Instrumental, massive brass fanfare, triumphant ending]

[Sung, soft fade]
You Don't Know Rämpf...
```

### Phasenübergreifende Soundeffekte (ElevenLabs)

Werden in mehreren Runden / Phasen verwendet. Wo ein Suno-Sting den
Moment bereits abdeckt, steht "—".

| Phase | Trigger | SFX | ElevenLabs Prompt | Dauer |
|-------|---------|-----|-------------------|-------|
| title→roundIntro | Mod: "Spiel starten" | Game-Start Whoosh | `dramatic cinematic whoosh transition, deep bass sweep left to right` | 1s |
| roundIntro | Runden-Animation startet | Runden-Swoosh | `quick upward swoosh, bright and energetic, digital game show transition` | 0.5s |
| question | Fragetext erscheint | Fragen-Reveal | `short suspenseful reveal sound, subtle rising tone with soft impact, quiz show` | 1s |
| question | Mod: "Antworten zeigen" | Antworten-Einblenden | `smooth sliding panel sound, soft mechanical whoosh, UI element appearing` | 0.8s |
| question | Spieler wählt Antwort | Lock-in Chime | `bright digital chime, single clean note, confirmation beep, crisp` | 0.3s |
| question | Beide Spieler gewählt | Doppel-Lock | `two quick ascending chimes, digital confirmation, complete` | 0.5s |
| question | Timer < 5s | Dringlichkeits-Tick | `tense clock ticking, fast tempo, dramatic countdown, single tick` | 0.3s |
| question | Timer = 0 | Time-up Buzzer | `harsh game show buzzer, time is up, short and punchy` | 0.8s |
| question→reveal | Mod: "Antwort aufdecken" | — | Suno-Sting #6 (Antwort-Reveal) | — |
| reveal | Richtig-Highlight | — | Suno-Sting #4 (Richtige Antwort) | — |
| reveal | Falsch-Highlight | — | Suno-Sting #5 (Falsche Antwort) | — |
| reveal | Roast-Text erscheint | — | Suno-Sting #7 (Roast) | — |
| reveal→question | Mod: "Weiter" | Nächste-Frage Swoosh | `quick light whoosh, page turn transition, subtle and fast` | 0.4s |
| scoreboard | Punkte zählen hoch | Score-Tally Tick | `retro arcade coin counter ticking, rapid digital counting sound` | 0.2s/Tick |
| any | Moderator-Button | UI Click | `soft tactile button click, subtle digital tap, clean` | 0.15s |

---

## Sound-Produktion

### Tools

| Tool | Zweck | Output |
|------|-------|--------|
| **Suno v5** | Musik & Jingles — alles mit Melodie, Rhythmus oder Vocals | `.mp3` Stems |
| **ElevenLabs SFX** | Kurze Soundeffekte — Clicks, Whooshes, Ticks | `.mp3` One-Shots |

### Tipps Suno v5

- **Spoken Word Problem**: Suno v5 singt manchmal `[Spoken]`-Parts. Workaround:
  `[Rap]` oder `[Talk-Sing]` statt `[Spoken]` — hält den Rhythmus und
  verhindert ungewolltes Singen. Alternativ: Spoken-Intro separat generieren
  (rein Spoken, kein Instrumental) und später druntermischen.
- **Kurze Stücke**: Für Jingles/Stings die Dauer auf 15–30s setzen, sonst
  generiert Suno zu viel.
- **Loop-Musik**: Für Timer-Musik und Ambiente "loop-friendly" im Style
  angeben und Fade-Out manuell schneiden.
- **Varianten**: Immer 3–4 Varianten generieren und die beste nehmen —
  besonders beim Intro.

### Tipps ElevenLabs SFX

- **Beschreibend prompten**: ElevenLabs reagiert gut auf konkrete
  Beschreibungen ("short digital chime, bright, single note") statt abstrakte
  Begriffe ("success sound").
- **Dauer angeben**: Immer die gewünschte Länge erwähnen (z.B. "0.5 second",
  "2 seconds") — sonst werden Effekte oft zu lang.
- **Mehrere Varianten**: 3–4 Varianten generieren und die passendste wählen.
- **Post-Processing**: Lautstärke normalisieren und ggf. mit Audacity
  trimmen/faden.

### ElevenLabs SFX API

```bash
curl -X POST "https://api.elevenlabs.io/v1/sound-generation" \
  -H "Content-Type: application/json" \
  -H "xi-api-key: $ELEVENLABS_API_KEY" \
  -d '{"text":"...", "duration_seconds":0.5}' \
  --output effect.mp3
```

### Produktions-Priorität

| Prio | Asset | Tool | Dauer | Runde |
|------|-------|------|-------|-------|
| 1 | Intro / Titelmusik | Suno | 60–90s | Show |
| 2 | Timer / Denk-Musik | Suno | 30s (loop) | 1,2,4 |
| 3 | UI Click | ElevenLabs | 0.15s | Alle |
| 4 | Runden-Jingle | Suno | 15s | Alle |
| 5 | Richtige Antwort Sting | Suno | 5s | 1,4,5 |
| 6 | Falsche Antwort Sting | Suno | 5s | 1,4 |
| 7 | Lock-in Chime | ElevenLabs | 0.3s | 1,2,4 |
| 8 | Time-up Buzzer | ElevenLabs | 0.8s | 1,2,5 |
| 9 | Antwort-Reveal Sting | Suno | 8s | 1,4 |
| 10 | Duell-Ambiente | Suno | 45s (loop) | 2 |
| 11 | Säbelkreuzen | ElevenLabs | 0.5s | 2 |
| 12 | Treffer | ElevenLabs | 0.8s | 2 |
| 13 | Verfehlt | ElevenLabs | 0.7s | 2 |
| 14 | Ins Wasser fallen | ElevenLabs | 1.5s | 2 |
| 15 | Beleidigungsfechten-Intro | Suno | 20s | 2 |
| 16 | Fragen-Reveal | ElevenLabs | 1s | 1,4 |
| 17 | Dringlichkeits-Tick | ElevenLabs | 0.3s | 1,2 |
| 18 | Game-Start Whoosh | ElevenLabs | 1s | Show |
| 19 | Runden-Swoosh | ElevenLabs | 0.5s | Alle |
| 20 | Antworten-Einblenden | ElevenLabs | 0.8s | 1,4 |
| 21 | Doppel-Lock | ElevenLabs | 0.5s | 1,4 |
| 22 | Nächste-Frage Swoosh | ElevenLabs | 0.4s | 1,4 |
| 23 | Score-Tally Tick | ElevenLabs | 0.2s | Alle |
| 24 | DOS POST Beep | ElevenLabs | 0.3s | 3 |
| 25 | Tastatur-Klackern | ElevenLabs | 0.15s | 3 |
| 26 | Error Beep | ElevenLabs | 0.3s | 3 |
| 27 | Erfolgs-Jingle | ElevenLabs | 2s | 3 |
| 28 | CRT-Brummen | ElevenLabs | 3s (loop) | 3 |
| 29 | Spannungs-Sting | Suno | 4s | 4 |
| 30 | Match-Fanfare | Suno | 5s | 4 |
| 31 | Kein-Match-Sting | Suno | 3s | 4 |
| 32 | R4 Hintergrundmusik | Suno | 30s (loop) | 4 |
| 33 | Roast-Sting | Suno | 4s | 1 |
| 34 | Finale / Siegerehrung | Suno | 30s | Show |

---

## Show-Ablauf Gesamtübersicht

```
Intro (Titelmusik)
→ Begrüßung durch Mods                          ~3 Min
→ Runde 1: Quiz (aufwärmen)                      ~8 Min
→ Scoreboard                                     ~1 Min
→ Runde 2: Beleidigungsfechten (Action)           ~8 Min
→ Scoreboard                                     ~1 Min
→ Runde 3: Fake-Konsole (Solo Basti)              ~8 Min
→ Scoreboard                                     ~1 Min
→ Runde 4: Geschmacksfragen (persönlich)          ~6 Min
→ Scoreboard                                     ~1 Min
→ Runde 5: Playback-Singen (Finale!)              ~7 Min
→ Finale / Siegerehrung                          ~2 Min
                                          Gesamt ~46 Min
```

Zwischen jeder Runde gibt es eine Scoreboard-Pause.
Zeiten sind Richtwerte — Feintuning über die Markdown-Configs.
