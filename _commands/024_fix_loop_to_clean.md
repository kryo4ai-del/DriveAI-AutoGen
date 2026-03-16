# 024 Fix-Loop bis Clean Build

**Status**: pending
**Ziel**: Alle verbleibenden Typecheck-Fehler in einem Loop abarbeiten bis clean oder grundlegend neues Problem

## Auftrag

Arbeite in einem Loop:

```
WHILE typecheck hat Fehler:
  1. Typecheck ausfuehren
  2. Fehler analysieren
  3. Bekanntes Pattern? → Sofort fixen
  4. Unbekanntes Pattern? → STOP und reporten
  5. Zurueck zu 1
```

### Bekannte Fix-Patterns (sofort anwenden):

| Pattern | Policy | Beispiel |
|---|---|---|
| Typ 2x definiert | `dedicated-file-wins` — Inline-Definition entfernen, kanonische Datei behalten/mergen | WeakArea, CategoryResult, LocalDataServiceProtocol |
| Fehlende Property auf Model/Enum | `consumer-declares-need` — Property aus Aufrufstelle ableiten und ergaenzen | ReadinessLevel.emoji, ExamReadinessSnapshot.score |
| Fehlender Typ (nirgends definiert) | `stub-or-minimal-implementation` — Minimalen Struct/Protocol erstellen | NetworkMonitor, ScoringWeights |
| Protocol fehlen Methoden | `consumer-declares-need` — Methoden aus Consumer ableiten und ergaenzen | ExamReadinessServiceProtocol |
| Service conformt nicht zu Protocol | `concrete-service-must-conform` — Fehlende Methoden mit Default-Impl ergaenzen | LocalDataService |
| Fehlende Hashable/Equatable/Codable Conformance | `add-minimal-conformance` — Conformance ergaenzen | ExamSession |
| Fehlender Import (Foundation/Combine/SwiftUI) | `import-hygiene` — Import ergaenzen wenn bekannte Symbole genutzt | Date→Foundation, @Published→Combine |
| Pseudo-Code-Platzhalter `(...)` | `replace-with-default` oder `quarantine` | ExamReadinessResult |
| SwiftUI ViewBuilder Struktur kaputt | `canonical-pattern-rewrite` — Group/switch normalisieren | ReadinessLevelBadge |
| Trailing-closure Ambiguity | `explicit-call-over-trailing-closure` — Explizite Klammern | TrendAnalyzer |
| Naming Drift (aehnlicher Name existiert) | `naming-drift-correction` — Referenz korrigieren | ScoringWeights vs ScoreWeights |

### STOP-Bedingungen (nicht selbst fixen, nur reporten):

- Grundlegend neues Pattern das nicht in der Tabelle steht
- Zirkulaere Abhaengigkeit die mehrere Files gleichzeitig betrifft
- Architektur-Entscheidung noetig (z.B. welches Framework verwenden)
- Fix wuerde >20 Zeilen neuen Code erfordern
- Mehr als 3 aufeinanderfolgende Fixes am gleichen File (deutet auf tieferes Problem hin)
- Typecheck produziert >50 Errors nach einem Fix (Regression)

### Aktueller Startpunkt

Bekannter naechster Blocker:
- `QuestionRepositoryProtocol` 2x definiert → `dedicated-file-wins`
- `QuestionRepository` undefined `questions` → Property ergaenzen

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

Ergebnis in `_commands/024_fix_loop_result.md`:

Format:
```
## Runde 1
- Fehler: [was]
- Pattern: [welches]
- Fix: [was geaendert]
- Files: [welche]

## Runde 2
...

## Ergebnis
- Runden gesamt: X
- Typecheck: CLEAN / STOP bei [Pattern]
- Verbleibende Errors: X
- Naechster Blocker (falls STOP): [was]
```

## Git

Nach JEDER Runde NICHT committen. Erst am Ende:

```bash
git add -A
git commit -m "fix: batch compile fixes rounds 1-N (Report 65-0)

- [Zusammenfassung der wichtigsten Fixes]
- Fix-loop: X Runden bis [clean/stop]"
git push
```
