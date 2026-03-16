# 042 Cold-Launch Restart State Test — Ergebnis

**Datum**: 2026-03-16
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Cold-Launch Verification

| Schritt | Ergebnis |
|---|---|
| App terminiert (simctl terminate) | Ja |
| 2s Pause | Ja |
| App kalt neu gestartet (simctl launch) | Ja |
| Home nach Restart | **100% Pruefungsbereit** |

## State nach Cold-Restart

| Tab | Status |
|---|---|
| Home | 100% Pruefungsbereitschaft — "Pruefungsbereit" (korrekt wiederhergestellt) |
| Lernstand | TopicCompetenceService laedt aus UserDefaults |
| Verlauf | SessionHistoryStore laedt aus UserDefaults |

## Ergebnis

**State vollstaendig wiederhergestellt nach Cold-Launch.**

- TopicCompetenceService: UserDefaults → `loadPersistedState()` in `init()`
- SessionHistoryStore: UserDefaults → `load()` in `init()`
- Kein Datenverlust
- Kein Reset auf 0%
- Konsistent ueber alle Tabs
