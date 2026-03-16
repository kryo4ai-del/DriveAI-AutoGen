# 027 ExamReadiness Reconstruct + Continue Fix-Loop

**Status**: pending
**Ziel**: ExamReadiness als kanonisches Model rekonstruieren, Service realignen, dann Loop weiter bis clean

## Teil 1: ExamReadiness Reconstruction

### Analyse

1. Lies `ExamReadiness` Definition (vermutlich in ExamReadinessServiceProtocol.swift oder eigenes File)
2. Lies `ExamReadinessSnapshot` — hat bereits die meisten Properties die Consumer erwarten
3. Lies `ExamReadinessService` — welche Properties/Methoden erwartet der Service?
4. Sammle alle Consumer-Erwartungen:
   ```bash
   grep -r "ExamReadiness\." projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | grep -v "ExamReadinessSnapshot\|ExamReadinessScore\|ExamReadinessService\|ExamReadinessViewModel\|ExamReadinessError\|ExamReadinessResult" | head -30
   ```

### Entscheidung

**Bevorzugter Ansatz**: ExamReadiness wird zum kanonischen Read-Model mit Properties die aus Consumer-Erwartungen abgeleitet werden. ExamReadinessSnapshot bleibt als Persistenz-Snapshot bestehen.

Falls ExamReadinessSnapshot bereits alle nötigen Properties hat:
- `typealias ExamReadiness = ExamReadinessSnapshot` oder
- ExamReadiness von Snapshot ableiten/kopieren

Falls ExamReadiness eigene Shape braucht:
- Stored properties definieren basierend auf Consumer-Aufrufe
- ExamReadinessService methods muessen ExamReadiness zurueckgeben

### Policy
- `canonical-model-reconstruction` — Fragment-Typ wird zum vollstaendigen Read-Model ausgebaut
- Properties aus Consumer-Erwartungen ableiten (consumer-declares-need)
- Service muss zum Model passen (concrete-service-must-conform)

## Teil 2: Fix-Loop weiter

Nach der Reconstruction: Typecheck und Loop mit allen bekannten Patterns.

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

### STOP nur bei:
- Architektur-Entscheidung die Master-Lead braucht
- Kern-Model-Redesign eines ANDEREN Domain-Bereichs (nicht Readiness)
- Typecheck >50 Errors nach einem Fix (Regression)
- Zirkulaere Abhaengigkeit die nicht loesbar ist

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

Ergebnis in `_commands/027_reconstruct_loop_result.md`:

```
## ExamReadiness Reconstruction
- Gewaehlter Ansatz: [typealias / neue Shape / ...]
- Properties: [Liste]
- Service-Alignment: [was geaendert]

## Fix-Loop Runden
## Runde 1
...

## Quarantined Files (diese Session)
- [Liste falls neue]

## Ergebnis
- Runden gesamt: X
- Typecheck: CLEAN / STOP bei [was]
- Verbleibende Errors: X
```

## Git

```bash
git add -A
git commit -m "fix: ExamReadiness canonical reconstruction + batch fixes (Report 68-0)

- ExamReadiness als vollstaendiges Read-Model rekonstruiert
- Service realigned
- Fix-loop: X Runden bis [clean/stop]"
git push
```
