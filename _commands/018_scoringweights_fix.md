# 018 ScoringWeights Symbol-Scope Fix

**Status**: pending
**Ziel**: Fehlenden ScoringWeights Typ erstellen oder referenz korrigieren

## Auftrag

1. Pruefe ob `ScoringWeights` irgendwo im Projekt existiert:
   ```bash
   grep -r "ScoringWeights" projects/askfin_v1-1/ --include="*.swift"
   ```
2. Lies `ReadinessConfiguration.swift` — wie wird ScoringWeights verwendet?
3. Pruefe ob `ScoreWeights.swift` existiert (aehnlicher Name — Naming Drift?)
   ```bash
   find projects/askfin_v1-1/ -name "*Weight*" -o -name "*Score*" | grep -i weight
   ```
4. Entscheide:
   - Falls `ScoreWeights` existiert und passt → Referenz in ReadinessConfiguration korrigieren
   - Falls kein aehnlicher Typ existiert → Minimalen `ScoringWeights` struct erstellen
   - Properties aus dem Kontext in ReadinessConfiguration ableiten
5. Policy: Wenn Typ nur 1x referenziert und aehnlicher Name existiert → `naming-drift-correction`
   Wenn Typ fehlt → `stub-or-minimal-implementation` (wie NetworkMonitor)

## Nach dem Fix

```bash
cd ~/DriveAI-AutoGen
xcrun swiftc -typecheck \
  projects/askfin_v1-1/**/*.swift \
  -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macosx15.0 \
  2>&1 | head -60
```

## Report

Ergebnis in `_commands/018_scoringweights_fix_result.md`:
- Root cause (fehlend vs naming drift)
- Was erstellt/korrigiert
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: ScoringWeights symbol-scope resolution (Report 59-0)

- Policy: naming-drift-correction oder stub-or-minimal-implementation"
git push
```
