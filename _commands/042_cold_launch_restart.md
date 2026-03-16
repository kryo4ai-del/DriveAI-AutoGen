# 042 Cold-Launch Restart State Test

**Status**: pending
**Ziel**: Verifiziere dass akkumulierter Multi-Session-State nach komplettem App-Neustart korrekt wiederhergestellt wird.

## Kontext

- 2 Sessions erfolgreich abgeschlossen (Daily + Weakness)
- State ist koharent waehrend App laeuft
- Verlauf zeigt Eintraege, Lernstand zeigt Fortschritt
- 7/7 Tests PASSED
- Persistenz via UserDefaults (TopicCompetenceService + SessionHistoryStore)

## Aufgabe

1. App starten, bestaetige dass mindestens 2 abgeschlossene Sessions existieren
2. App **komplett beenden** (nicht nur Hintergrund — kill im Simulator)
3. App **kalt neu starten**
4. Prüfe nach Neustart:
   - **Home**: Zeigt aggregierten State korrekt?
   - **Lernstand**: Zeigt akkumulierten Fortschritt?
   - **Verlauf**: Zeigt beide abgeschlossenen Sessions?
5. Dokumentiere ob State:
   - Vollstaendig wiederhergestellt
   - Teilweise wiederhergestellt
   - Nicht wiederhergestellt (reset)
   - Inkonsistent zwischen Tabs

## Validation

```bash
# Optional: XCUITest der App-Kill + Relaunch simuliert
# Oder manuell im Simulator:
# 1. App oeffnen, Sessions pruefen
# 2. Cmd+Shift+H (Home), dann App nach oben wischen (kill)
# 3. App neu oeffnen
# 4. Tabs pruefen
```

## Report

Schreibe Ergebnis in: `_commands/042_cold_launch_result.md`
Schreibe Report in: `DeveloperReports/CodeAgent/83-0_Cold Launch Restart Report.md`

Commit-Message: `test: cold-launch restart state verification (Report 83-0)`
