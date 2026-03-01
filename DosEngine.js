.pragma library

// --- Scenario definitions ---
var scenarios = {
    "wc": {
        name: "Wing Commander startet nicht",
        goal: "Konventionellen Speicher freimachen und wc.exe starten",
        solution: [
            "type config.sys",
            "edit config.sys  (DEVICE=HIMEM.SYS und DEVICE=EMM386.EXE eintragen)",
            "reboot",
            "wc.exe"
        ],
        initState: function() {
            return {
                files: {
                    "config.sys": "FILES=30\nBUFFERS=20\nDEVICE=MOUSE.SYS",
                    "autoexec.bat": "@ECHO OFF\nPATH C:\\DOS;C:\\GAMES\nSET TEMP=C:\\TEMP",
                    "wc.exe": "[Wing Commander - 1.2 MB]",
                    "mouse.sys": "[Mouse Driver]"
                },
                mem: { conv: 520, upper: 0, total: 640 },
                configEdited: false,
                rebooted: false,
                solved: false
            };
        }
    },

    "doom": {
        name: "Doom hat keinen Sound",
        goal: "Sound Blaster konfigurieren damit Doom Sound hat",
        solution: [
            "set  (BLASTER Variable fehlt)",
            "set BLASTER=A220 I5 D1",
            "doom.exe"
        ],
        initState: function() {
            return {
                files: {
                    "doom.exe": "[DOOM v1.9 - 2.3 MB]",
                    "doom.wad": "[DOOM WAD Data - 4.1 MB]",
                    "setup.exe": "[DOOM Setup]",
                    "sndtest.com": "[Sound Blaster Test Utility]"
                },
                env: {
                    "PATH": "C:\\DOS;C:\\GAMES",
                    "TEMP": "C:\\TEMP"
                },
                solved: false
            };
        }
    },

    "mi": {
        name: "Monkey Island installieren",
        goal: "Platz schaffen und Monkey Island von Diskette installieren",
        solution: [
            "dir  (nur 2 MB frei)",
            "del temp.dat oder deltree tempdir",
            "install a:"
        ],
        initState: function() {
            return {
                files: {
                    "command.com": "[DOS Command Interpreter - 54 KB]",
                    "temp.dat": "[Temporaere Daten - 4.2 MB]",
                    "game1.sav": "[Spielstand - 128 KB]",
                    "readme.txt": "Willkommen auf deinem 486er!\nFestplatte: 20 MB\nRAM: 4 MB"
                },
                dirs: {
                    "tempdir": { "cache1.tmp": "[1.8 MB]", "cache2.tmp": "[2.1 MB]" }
                },
                diskFree: 2048,
                diskTotal: 20480,
                diskUsed: 18432,
                installStarted: false,
                solved: false
            };
        }
    }
};

function createScenario(scenarioId) {
    var def = scenarios[scenarioId];
    if (!def) return null;
    var state = def.initState();
    state.scenarioId = scenarioId;
    state.output = "Microsoft(R) MS-DOS Version 6.22\n(C)Copyright Microsoft Corp 1981-1994.\n\n";
    return state;
}

function execute(state, command) {
    var cmd = command.trim();
    if (cmd === "") return { output: "", solved: false };

    var parts = cmd.split(/\s+/);
    var base = parts[0].toLowerCase();
    var args = parts.slice(1).join(" ");

    switch (base) {
    case "help":
        return _help(state, args);
    case "dir":
        return _dir(state, args);
    case "type":
        return _type(state, args);
    case "edit":
        return _edit(state, args);
    case "mem":
        return _mem(state);
    case "set":
        return _set(state, args);
    case "del":
        return _del(state, args);
    case "deltree":
        return _deltree(state, args);
    case "reboot":
        return _reboot(state);
    case "cls":
        return { output: "\n\n\n", solved: false, cls: true };
    default:
        return _runExe(state, cmd, base, args);
    }
}

function _help(state, args) {
    if (args) {
        var cmdHelp = {
            "dir": "Zeigt Dateien und Verzeichnisse an.\nSyntax: DIR [/s]",
            "type": "Zeigt den Inhalt einer Datei an.\nSyntax: TYPE dateiname",
            "edit": "Bearbeitet eine Textdatei.\nSyntax: EDIT dateiname",
            "mem": "Zeigt Speicherbelegung an.\nSyntax: MEM",
            "set": "Zeigt oder setzt Umgebungsvariablen.\nSyntax: SET [variable=wert]",
            "del": "Loescht eine Datei.\nSyntax: DEL dateiname",
            "deltree": "Loescht ein Verzeichnis mit Inhalt.\nSyntax: DELTREE verzeichnis",
            "reboot": "Startet den Computer neu.",
            "cls": "Loescht den Bildschirm.",
            "help": "Zeigt Hilfe an.\nSyntax: HELP [befehl]"
        };
        var h = cmdHelp[args.toLowerCase()];
        if (h) return { output: h + "\n", solved: false };
        return { output: "Kein Hilfethema fuer '" + args + "'.\n", solved: false };
    }

    return {
        output: "Verfuegbare Befehle:\n"
                + "  DIR      Dateien anzeigen\n"
                + "  TYPE     Dateiinhalt anzeigen\n"
                + "  EDIT     Datei bearbeiten\n"
                + "  MEM      Speicher anzeigen\n"
                + "  SET      Umgebungsvariablen\n"
                + "  DEL      Datei loeschen\n"
                + "  DELTREE  Verzeichnis loeschen\n"
                + "  REBOOT   Neustart\n"
                + "  CLS      Bildschirm loeschen\n"
                + "  HELP     Diese Hilfe\n"
                + "\nTipp: HELP <befehl> fuer Details.\n",
        solved: false
    };
}

function _dir(state, args) {
    var lines = " Verzeichnis von C:\\\n\n";
    var totalSize = 0;
    var fileCount = 0;

    for (var f in state.files) {
        var sizeStr = _fileSize(state.files[f]);
        lines += "  " + _pad(f.toUpperCase(), 16) + sizeStr + "\n";
        totalSize += _fileSizeBytes(state.files[f]);
        fileCount++;
    }
    if (state.dirs) {
        for (var d in state.dirs) {
            lines += "  " + _pad(d.toUpperCase(), 16) + "<DIR>\n";
        }
    }

    var freeKb = state.diskFree ? state.diskFree : "???";
    lines += "\n  " + fileCount + " Datei(en)  " + _formatBytes(totalSize) + "\n";
    if (state.diskFree !== undefined)
        lines += "  " + _formatKB(state.diskFree) + " frei\n";

    return { output: lines, solved: false };
}

function _type(state, args) {
    if (!args) return { output: "Syntax: TYPE dateiname\n", solved: false };
    var fname = args.toLowerCase();
    if (state.files[fname])
        return { output: state.files[fname] + "\n", solved: false };
    return { output: "Datei nicht gefunden: " + args + "\n", solved: false };
}

function _edit(state, args) {
    if (!args) return { output: "Syntax: EDIT dateiname\n", solved: false };
    var fname = args.toLowerCase();

    // Scenario-specific editing
    if (state.scenarioId === "wc" && fname === "config.sys") {
        state.files["config.sys"] =
            "FILES=30\nBUFFERS=20\nDEVICE=HIMEM.SYS\nDEVICE=EMM386.EXE\nDEVICE=MOUSE.SYS";
        state.configEdited = true;
        return {
            output: "--- EDIT: config.sys ---\n"
                    + "DEVICE=HIMEM.SYS hinzugefuegt.\n"
                    + "DEVICE=EMM386.EXE hinzugefuegt.\n"
                    + "Datei gespeichert.\n",
            solved: false
        };
    }

    if (state.files[fname])
        return { output: "EDIT: " + fname + " geoeffnet (keine Aenderungen).\n", solved: false };
    return { output: "Datei nicht gefunden: " + args + "\n", solved: false };
}

function _mem(state) {
    if (!state.mem)
        return { output: "Speichertyp      Gesamt    Benutzt    Frei\n"
                         + "Konventionell     640K      ???K       ???K\n", solved: false };

    var free = state.mem.conv;
    var used = state.mem.total - free;
    var enough = free >= 580;

    return {
        output: "Speichertyp      Gesamt    Benutzt    Frei\n"
                + "Konventionell     " + state.mem.total + "K"
                + "      " + used + "K"
                + "       " + free + "K"
                + (enough ? "" : "  << ZU WENIG!") + "\n"
                + "Upper Memory      " + state.mem.upper + "K\n"
                + "\nGroesstes freies Segment: " + free + "K\n"
                + (enough ? "" : "WARNUNG: Mindestens 580K konventioneller Speicher benoetigt!\n"),
        solved: false
    };
}

function _set(state, args) {
    if (!args) {
        // Show all environment variables
        var env = state.env || {};
        var lines = "";
        for (var k in env)
            lines += k + "=" + env[k] + "\n";
        if (state.scenarioId === "doom" && !env["BLASTER"])
            lines += "\n(BLASTER Variable nicht gesetzt!)\n";
        return { output: lines || "(keine Variablen gesetzt)\n", solved: false };
    }

    var eq = args.indexOf("=");
    if (eq < 0) return { output: "Syntax: SET variable=wert\n", solved: false };

    var varName = args.substring(0, eq).trim().toUpperCase();
    var varVal = args.substring(eq + 1).trim();

    if (!state.env) state.env = {};
    state.env[varName] = varVal;

    if (state.scenarioId === "doom" && varName === "BLASTER") {
        return {
            output: "BLASTER=" + varVal + "\nSound Blaster Konfiguration gesetzt.\n",
            solved: false
        };
    }

    return { output: varName + "=" + varVal + "\n", solved: false };
}

function _del(state, args) {
    if (!args) return { output: "Syntax: DEL dateiname\n", solved: false };
    var fname = args.toLowerCase();

    if (fname === "command.com")
        return { output: "FEHLER: Systemdatei kann nicht geloescht werden!\n", solved: false };

    if (state.files[fname]) {
        var size = _fileSizeBytes(state.files[fname]);
        delete state.files[fname];
        if (state.diskFree !== undefined)
            state.diskFree += Math.round(size / 1024);
        return { output: fname.toUpperCase() + " geloescht.\n", solved: false };
    }
    return { output: "Datei nicht gefunden: " + args + "\n", solved: false };
}

function _deltree(state, args) {
    if (!args) return { output: "Syntax: DELTREE verzeichnis\n", solved: false };
    var dirname = args.toLowerCase();

    if (state.dirs && state.dirs[dirname]) {
        var totalSize = 0;
        var dir = state.dirs[dirname];
        for (var f in dir)
            totalSize += _fileSizeBytes(dir[f]);
        delete state.dirs[dirname];
        if (state.diskFree !== undefined)
            state.diskFree += Math.round(totalSize / 1024);
        return {
            output: "Verzeichnis " + dirname.toUpperCase()
                    + " mit Inhalt geloescht.\n"
                    + _formatKB(Math.round(totalSize / 1024)) + " freigegeben.\n",
            solved: false
        };
    }
    return { output: "Verzeichnis nicht gefunden: " + args + "\n", solved: false };
}

function _reboot(state) {
    if (state.scenarioId === "wc") {
        if (state.configEdited) {
            state.rebooted = true;
            state.mem.conv = 602;
            state.mem.upper = 384;
            return {
                output: "\n*** Neustart ***\n"
                        + "HIMEM.SYS geladen.\n"
                        + "EMM386.EXE geladen.\n"
                        + "Konventioneller Speicher: 602K frei.\n\n"
                        + "C:\\>\n",
                solved: false
            };
        }
        return {
            output: "\n*** Neustart ***\n"
                    + "Konventioneller Speicher: 520K frei.\n"
                    + "(Keine Aenderung an CONFIG.SYS)\n\n"
                    + "C:\\>\n",
            solved: false
        };
    }

    return { output: "\n*** Neustart ***\n\nC:\\>\n", solved: false };
}

function _runExe(state, fullCmd, base, args) {
    var exe = base.indexOf(".") >= 0 ? base : base + ".exe";

    // Wing Commander scenario
    if (state.scenarioId === "wc" && (exe === "wc.exe")) {
        if (state.rebooted && state.mem.conv >= 580) {
            state.solved = true;
            return {
                output: "\n"
                    + "    *  W I N G  C O M M A N D E R  *\n"
                    + "    ================================\n"
                    + "    Lade Spiel... OK!\n\n"
                    + "     _______________\n"
                    + "    /               \\\n"
                    + "   /  MISSION START  \\\n"
                    + "   \\   >>>>>>>>>>>   /\n"
                    + "    \\_____________/\n\n"
                    + "  Spiel gestartet! GESCHAFFT!\n",
                solved: true
            };
        }
        return {
            output: "Wing Commander v1.0\n"
                    + "Fehler: Nicht genug konventioneller Speicher!\n"
                    + "Benoetigt: 580K  Verfuegbar: " + state.mem.conv + "K\n"
                    + "Tipp: Pruefe CONFIG.SYS\n",
            solved: false
        };
    }

    // Doom scenario
    if (state.scenarioId === "doom") {
        if (exe === "doom.exe") {
            var env = state.env || {};
            if (env["BLASTER"]) {
                state.solved = true;
                return {
                    output: "\n"
                        + "    D O O M  v1.9\n"
                        + "    =============\n"
                        + "    Sound Blaster erkannt: " + env["BLASTER"] + "\n"
                        + "    Sound: OK!\n\n"
                        + "     _____\n"
                        + "    |     |\n"
                        + "    | >:) |\n"
                        + "    |_____|\n\n"
                        + "  DOOM laeuft mit Sound! GESCHAFFT!\n",
                    solved: true
                };
            }
            return {
                output: "DOOM v1.9\n"
                        + "Initialisiere...\n"
                        + "Sound: FEHLER - No sound device detected!\n"
                        + "Tipp: BLASTER Umgebungsvariable pruefen.\n",
                solved: false
            };
        }
        if (exe === "sndtest.com" || exe === "sndtest") {
            var env2 = state.env || {};
            if (env2["BLASTER"]) {
                return {
                    output: "Sound Blaster Test Utility v2.0\n"
                            + "Konfiguration: " + env2["BLASTER"] + "\n"
                            + "Sound Blaster erkannt!\n"
                            + "Spiele Testton... BEEP!\n"
                            + "Test erfolgreich.\n",
                    solved: false
                };
            }
            return {
                output: "Sound Blaster Test Utility v2.0\n"
                        + "FEHLER: BLASTER Variable nicht gesetzt!\n"
                        + "Syntax: SET BLASTER=A220 I5 D1\n",
                solved: false
            };
        }
    }

    // Monkey Island scenario
    if (state.scenarioId === "mi") {
        if (exe === "install" || fullCmd.toLowerCase().match(/^install\s+a:/)) {
            if (state.diskFree >= 8192) {
                state.solved = true;
                return {
                    output: "\n"
                        + "  The Secret of Monkey Island\n"
                        + "  ===========================\n"
                        + "  Installiere von Diskette A:...\n"
                        + "  Diskette 1 von 4... OK\n"
                        + "  Diskette 2 von 4... OK\n"
                        + "  Diskette 3 von 4... OK\n"
                        + "  Diskette 4 von 4... OK\n\n"
                        + "     ,,,\n"
                        + "    (o o)\n"
                        + "  oo0-(_)-0oo\n"
                        + "   Guybrush!\n\n"
                        + "  Installation abgeschlossen! GESCHAFFT!\n",
                    solved: true
                };
            }
            return {
                output: "The Secret of Monkey Island - Setup\n"
                        + "FEHLER: Nicht genug Speicherplatz!\n"
                        + "Benoetigt: 8 MB  Verfuegbar: "
                        + _formatKB(state.diskFree) + "\n"
                        + "Bitte Festplatte aufraeumen.\n",
                solved: false
            };
        }
    }

    // Check if file exists
    if (state.files[exe])
        return { output: exe.toUpperCase() + " kann nicht ausgefuehrt werden.\n", solved: false };

    return { output: "Unbekannter Befehl: " + fullCmd + "\n", solved: false };
}

// --- Helpers ---
function _pad(str, len) {
    while (str.length < len) str += " ";
    return str;
}

function _fileSize(content) {
    var match = content.match(/(\d+\.?\d*)\s*(KB|MB|GB)/i);
    if (match) return match[1] + " " + match[2].toUpperCase();
    return (content.length) + " B";
}

function _fileSizeBytes(content) {
    var match = content.match(/(\d+\.?\d*)\s*(KB|MB|GB)/i);
    if (match) {
        var val = parseFloat(match[1]);
        var unit = match[2].toUpperCase();
        if (unit === "KB") return val * 1024;
        if (unit === "MB") return val * 1024 * 1024;
        if (unit === "GB") return val * 1024 * 1024 * 1024;
    }
    return content.length;
}

function _formatBytes(bytes) {
    if (bytes >= 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB";
    if (bytes >= 1024) return Math.round(bytes / 1024) + " KB";
    return bytes + " B";
}

function _formatKB(kb) {
    if (kb >= 1024) return (kb / 1024).toFixed(1) + " MB";
    return kb + " KB";
}
