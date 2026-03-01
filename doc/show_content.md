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

### Sound & Musik

Komplett im Sound-Konzept abgedeckt:
- Timer/Denk-Musik (Loop)
- Lock-in Chime, Reveal-Sting, Richtig/Falsch-Sting
- Keine zusätzlichen Assets nötig

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

- Beleidigungsfechten-Intro Jingle (existiert im Sound-Konzept)
- Timer/Denk-Musik für Bastis Antwortzeit
- Schwertklirren bei richtigem Konter
- Zurückdräng-Whoosh wenn Sprite geschoben wird
- Runterfallen-SFX (Splash/Schrei)
- Piraten-Ambiente als Hintergrund-Loop (voll piratig: Möwen, Wellen,
  Knarzen — aber leiser/gedämpft während Crowd und Basti wählen)

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

- DOS-Boot-Sound / POST-Beep
- Tastatur-Klackern (mechanisch, retro)
- Error-Beep bei `Unknown command.`
- Erfolgs-Melodie wenn ein Spiel "startet"
- CRT-Brummen als leises Ambient (optional)

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

- Spannungs-Sting vor dem Reveal
- Übereinstimmungs-Fanfare (positiv, feiernd)
- Nicht-Übereinstimmungs-Sound (sanft, eher "awww" als "falsch")
- Lockere Hintergrundmusik (entspannter Vibe)

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
- Jingle für "Song erraten!" (Jubel-Sting, kann Richtig-Antwort-Sting
  wiederverwenden)
- Buzzer für "Niemand weiß es" / Zeit abgelaufen

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
