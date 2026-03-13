.pragma library

var rounds = [
    {
        name: "90er-Spiele-Wissen",
        tagline: "Wie gut erinnerst du dich WIRKLICH an die goldene Ära?",
        sponsor: "Präsentiert von Bonzi Buddy™ — Dein Desktop-Kumpel!",
        mode: "standard",
        questions: [
            {
                text: "Welcher Multiplayer-Charakter war in 'GoldenEye 007' für N64 berühmt dafür, zu klein zum Treffen zu sein?",
                answers: ["Jaws", "Oddjob", "Baron Samedi", "Natalya"],
                correct: 1,
                roast: "Selbst Oddjob ist enttäuscht von dir."
            },
            {
                text: "Wie lautete der Cheatcode bei 'Die Sims', um unbegrenzt Geld zu bekommen?",
                answers: ["motherlode", "rosebud", "kaching", "hesoyam"],
                correct: 1,
                roast: "Dein Kontostand: auch nur eine Simulation."
            },
            {
                text: "In welchem 90er-Spiel hieß der Protagonist 'Guybrush Threepwood'?",
                answers: ["Day of the Tentacle", "Sam & Max Hit the Road",
                          "The Secret of Monkey Island", "Full Throttle"],
                correct: 2,
                roast: "Du kämpfst wie ein Bauer."
            }
        ]
    },
    {
        name: "Beleidigungsfechten",
        tagline: "Du kämpfst wie eine Kuh.",
        sponsor: "Gesponsert von Stans Gebrauchtschiff-Handel — Keine Rückgabe!",
        mode: "insult",
        questions: [
            {
                text: "\"Du kämpfst wie ein Bauer!\"",
                answers: [
                    "Wie passend. Du kämpfst wie eine Kuh.",
                    "Ich bin Gummi, du bist Leim.",
                    "Nein, DU kämpfst wie ein Bauer!",
                    "Ich hatte mal einen Bauernhof."
                ],
                correct: 0,
                roast: "Selbst der Bauer schüttelt den Kopf."
            },
            {
                text: "\"Bald wirst du mein Schwert wie einen Schaschlikspieß tragen!\"",
                answers: [
                    "Ich hab gerade keinen Hunger.",
                    "Erst solltest du aufhören, damit herumzufuchteln wie mit einem Staubwedel.",
                    "Klingt eigentlich lecker.",
                    "Mein Schwert ist größer als deins."
                ],
                correct: 1,
                roast: "Du könntest nicht mal ein Regal abstauben, geschweige denn fechten."
            },
            {
                text: "\"Die Leute fallen vor mir auf die Knie, wenn sie mich kommen sehen!\"",
                answers: [
                    "Das wundert mich nicht, du stinkst fürchterlich.",
                    "Sogar BEVOR sie deinen Atem riechen?",
                    "Das muss sehr beeindruckend sein.",
                    "Ich falle vor niemandem auf die Knie!"
                ],
                correct: 1,
                roast: "Dein Atem könnte ein Schiff aus 50 Schritten versenken."
            },
            {
                text: "\"Ich hab heute eine lange, scharfe Lektion für dich!\"",
                answers: [
                    "Ich weiß jetzt schon mehr, als du je vergessen wirst.",
                    "Und ich hab einen kleinen TIPP für dich — kapier die POINTE!",
                    "Ich lerne schnell.",
                    "Lektionen sind was für die Schule!"
                ],
                correct: 1,
                roast: "Die einzige Pointe, die du je kriegst, ist die auf deinem Kopf."
            }
        ]
    },
    {
        name: "Retro-PC-Überlebenskampf",
        tagline: "Damals, als 640K für jeden reichten.",
        sponsor: "Powered by Turbo Pascal™ — Kompiliere deine Träume!",
        mode: "standard",
        questions: [
            {
                text: "Was hast du in DOS eingegeben, um konventionellen Speicher freizumachen, bevor du ein Spiel starten konntest?",
                answers: [
                    "MEMFREE.EXE",
                    "HIMEM.SYS + EMM386.EXE in CONFIG.SYS",
                    "FORMAT C:",
                    "DELTREE /Y C:\\WINDOWS"
                ],
                correct: 1,
                roast: "Du hast bestimmt auch mal COMMAND.COM gelöscht."
            },
            {
                text: "Welche IRQ-Nummer hat man typischerweise für eine Sound Blaster Karte eingestellt?",
                answers: ["IRQ 3", "IRQ 5", "IRQ 9", "IRQ 15"],
                correct: 1,
                roast: "Kein Sound für dich. Wie dein Liebesleben."
            },
            {
                text: "Welches Speichermedium fasste satte 1,44 MB?",
                answers: [
                    "ZIP Disk",
                    "3,5\"-Diskette",
                    "Compact Disc",
                    "Jaz Drive"
                ],
                correct: 1,
                roast: "1,44 MB — immer noch mehr Daten als dein Dating-Profil."
            },
            {
                text: "Was bedeutete 'Abort, Retry, Fail?' in DOS?",
                answers: [
                    "Dein Spiel wurde erfolgreich gespeichert",
                    "Ein kritischer Lese-/Schreibfehler ist aufgetreten",
                    "Windows war kurz davor, sich zu installieren",
                    "Du musstest die nächste Diskette einlegen"
                ],
                correct: 1,
                roast: "Abort, Retry, Fail — auch die Geschichte deiner Frisuren."
            }
        ]
    }
];
