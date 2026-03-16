# 018 ScoringWeights Symbol-Scope Fix — Ergebnis

**Datum**: 2026-03-16
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Root Cause

`ScoringWeights` Typ fehlte. `ScoreWeights` existiert als private enum mit anderen Properties (Naming Drift, aber verschiedene Konzepte).

## Fix

`ScoringWeights` struct in ReadinessConfiguration.swift erstellt mit 4 Properties:
- categoryPerformance, streak, timeInvested, recentTrend (alle Double)

## Typecheck nach Fix

| Metrik | Vorher (017) | Nachher (018) |
|---|---|---|
| ScoringWeights Error | 2 | 0 |
| Neue Errors | — | 8 (1 File) |

### Neuer Blocker

`TrendAnalyzer.swift` — 8 Errors
- `LocalDataService` hat kein `fetchUserAnswerHistory()` und conformt nicht zu `LocalDataServiceProtocol` (fehlende Methoden)
- Protocol-Conformance-Luecke zwischen Protocol und Klasse
