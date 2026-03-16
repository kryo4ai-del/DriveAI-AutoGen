# 028 ExamReadinessDashboard + Continue Fix-Loop

**Status**: pending
**Ziel**: Dashboard-Errors fixen, dann Loop weiter bis clean oder Master-Lead-Entscheidung

## Startpunkt

22 Errors, davon 11 in ExamReadinessDashboard.swift. Vermutlich consumer-declares-need Pattern.

## Fix-Loop

Alle bekannten Patterns sofort anwenden:

| Pattern | Policy |
|---|---|
| Typ 2x definiert | `dedicated-file-wins` |
| Fehlende Property | `consumer-declares-need` |
| Fehlender Typ (klein) | `stub-or-minimal-implementation` |
| Fehlender Typ (>20 Zeilen / >3 fehlende Typen) | `quarantine` |
| Protocol fehlen Methoden | `consumer-declares-need` |
| Service conformt nicht | `concrete-service-must-conform` |
| Fehlende Conformance | `add-minimal-conformance` |
| Fehlender Import | `import-hygiene` |
| Type Mismatch | `type-mismatch-correction` |
| Missing switch cases | `add-missing-cases` |
| Pseudo-Code `(...)` / `...` | `replace-with-default` oder `quarantine` |
| SwiftUI ViewBuilder kaputt | `canonical-pattern-rewrite` |
| File >3 fehlende Typen | `quarantine` |

### STOP nur bei:
- Architektur-Entscheidung die Master-Lead braucht (neuer Domain-Bereich)
- Typecheck >50 Errors nach einem Fix (Regression)
- Zirkulaere Abhaengigkeit

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

Ergebnis in `_commands/028_dashboard_loop_result.md`

## Git

```bash
git add -A
git commit -m "fix: Dashboard + batch fixes (Report 69-0)

- Fix-loop: X Runden bis [clean/stop]"
git push
```
