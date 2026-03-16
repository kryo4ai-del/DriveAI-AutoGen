# 026 PredictionEngine Quarantine + Continue Fix-Loop

**Status**: pending
**Ziel**: PredictionEngine quarantinen (zu viele fehlende Typen), dann Loop weiter bis clean oder Master-Lead-Entscheidung noetig

## Teil 1: PredictionEngine Quarantine

PredictionEngine.swift braucht 3 fehlende Typen + mehrere Properties → >20 Zeilen → Quarantine.

```bash
cd ~/DriveAI-AutoGen
mkdir -p projects/askfin_v1-1/quarantine
mv projects/askfin_v1-1/Models/PredictionEngine.swift projects/askfin_v1-1/quarantine/
```

Pruefe ob andere Files PredictionEngine referenzieren:
```bash
grep -r "PredictionEngine" projects/askfin_v1-1/ --include="*.swift" -l | grep -v quarantine
```
Falls ja: Auch diese quarantinen oder Referenz entfernen.

## Teil 2: Fix-Loop weiter

Bekannte Patterns sofort anwenden:

| Pattern | Policy |
|---|---|
| Typ 2x definiert | `dedicated-file-wins` |
| Fehlende Property | `consumer-declares-need` |
| Fehlender Typ (1-2 Properties) | `stub-or-minimal-implementation` |
| Fehlender Typ (>20 Zeilen noetig) | `quarantine` das File das ihn braucht |
| Protocol fehlen Methoden | `consumer-declares-need` |
| Service conformt nicht | `concrete-service-must-conform` |
| Fehlende Conformance | `add-minimal-conformance` |
| Fehlender Import | `import-hygiene` |
| Pseudo-Code `(...)` | `replace-with-default` oder `quarantine` |
| SwiftUI ViewBuilder kaputt | `canonical-pattern-rewrite` |
| Type Mismatch | `type-mismatch-correction` |
| Missing switch cases | `add-missing-cases` |
| File braucht >3 fehlende Typen | `quarantine` |

### STOP-Bedingungen (nur bei Master-Lead-Entscheidung):
- Architektur-Entscheidung: z.B. "sollen wir Feature X komplett entfernen oder implementieren?"
- Kern-Model-Redesign noetig (nicht nur Properties ergaenzen)
- Typecheck >50 Errors nach einem Fix (Regression)
- Zirkulaere Abhaengigkeit die nicht durch Quarantine loesbar ist

### KEIN STOP bei:
- Bekannten Patterns (einfach fixen)
- Quarantine-Kandidaten (einfach quarantinen)
- Fehlenden Typen/Properties (stub oder quarantine)

## Typecheck-Befehl

```bash
xcrun swiftc -typecheck \
  projects/askfin_v1-1/**/*.swift \
  -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macosx15.0 \
  2>&1 | head -80
```

## Report

Ergebnis in `_commands/026_quarantine_loop_result.md`:

```
## Runde 1 (PredictionEngine Quarantine)
...

## Runde N
...

## Quarantined Files (diese Session)
- [Liste]

## Ergebnis
- Runden gesamt: X
- Typecheck: CLEAN / STOP bei [was]
- Verbleibende Errors: X
- Quarantined total: X Files
```

## Git

```bash
git add -A
git commit -m "fix: PredictionEngine quarantine + batch fixes rounds 1-N (Report 67-0)

- [Zusammenfassung]
- Quarantined: [Liste]
- Fix-loop: X Runden bis [clean/stop]"
git push
```
