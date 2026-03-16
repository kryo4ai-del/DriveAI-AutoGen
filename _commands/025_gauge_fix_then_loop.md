# 025 ReadinessScoreGauge Fix + Continue Fix-Loop

**Status**: pending
**Ziel**: ReadinessScoreGauge fixen, dann Fix-Loop weiterfuehren bis clean oder neues STOP-Pattern

## Teil 1: ReadinessScoreGauge Fix

1. Lies `ReadinessScoreGauge.swift` komplett
2. Lies `Models/ReadinessScore.swift` — was hat es aktuell?
3. Pruefe ob `ReadinessLabel` irgendwo existiert:
   ```bash
   grep -r "ReadinessLabel" projects/askfin_v1-1/ --include="*.swift"
   ```
4. Entscheide:
   - Falls ReadinessScore nur minimale Properties hat → `consumer-declares-need`: value, label etc. ergaenzen
   - Falls ReadinessScoreGauge zu komplex/kaputt ist → `quarantine` und minimalen Ersatz erstellen
   - Falls ReadinessLabel ein einfacher enum/struct ist → erstellen

## Teil 2: Fix-Loop weiter

Nach dem Gauge-Fix: Typecheck und Loop weiterfuehren mit den bekannten Patterns:

| Pattern | Policy |
|---|---|
| Typ 2x definiert | `dedicated-file-wins` |
| Fehlende Property | `consumer-declares-need` |
| Fehlender Typ | `stub-or-minimal-implementation` |
| Protocol fehlen Methoden | `consumer-declares-need` |
| Service conformt nicht | `concrete-service-must-conform` |
| Fehlende Conformance | `add-minimal-conformance` |
| Fehlender Import | `import-hygiene` |
| Pseudo-Code `(...)` | `replace-with-default` oder `quarantine` |
| SwiftUI ViewBuilder kaputt | `canonical-pattern-rewrite` |
| Type Mismatch | `type-mismatch-correction` |
| Missing switch cases | `add-missing-cases` |

### STOP-Bedingungen:
- Grundlegend neues Pattern
- Architektur-Entscheidung noetig
- Fix wuerde >20 Zeilen neuen Code erfordern
- >3 aufeinanderfolgende Fixes am gleichen File
- Typecheck >50 Errors nach einem Fix (Regression)

## Typecheck-Befehl

```bash
cd ~/DriveAI-AutoGen
xcrun swiftc -typecheck \
  projects/askfin_v1-1/**/*.swift \
  -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macosx15.0 \
  2>&1 | head -80
```

## Report

Ergebnis in `_commands/025_gauge_fix_loop_result.md`:

```
## Runde 1 (Gauge)
- Fehler: [was]
- Fix: [was]
- Files: [welche]

## Runde 2+
...

## Ergebnis
- Runden gesamt: X
- Typecheck: CLEAN / STOP bei [Pattern]
- Verbleibende Errors: X
```

## Git

```bash
git add -A
git commit -m "fix: ReadinessScoreGauge + batch fixes rounds 1-N (Report 66-0)

- [Zusammenfassung]
- Fix-loop: X Runden bis [clean/stop]"
git push
```
