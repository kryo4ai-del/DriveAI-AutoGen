# 022 ExamSession Hashable Conformance Fix

**Status**: pending
**Ziel**: ExamSession Hashable-konform machen fuer AppCoordinator.Destination

## Auftrag

1. Lies `Models/ExamSession.swift` — welche stored properties hat es?
2. Lies `Models/AppCoordinator.swift` — wie wird ExamSession als associated value in Destination enum genutzt?
3. Identifiziere welche Property die automatische Hashable-Synthese blockiert:
   - Alle stored properties muessen Hashable sein
   - Typische Blocker: Date (ist Hashable), Arrays (sind Hashable wenn Element Hashable), Custom Types (brauchen explizite Conformance)
4. Fix-Optionen (kleinste zuerst):
   a) Wenn alle Properties schon Hashable-faehig: Einfach `: Hashable` ergaenzen
   b) Wenn 1-2 Properties nicht Hashable: Custom `hash(into:)` + `==` mit nur den ID-relevanten Properties
   c) Wenn ExamSession eine class ist: `Hashable` via `ObjectIdentifier` oder `id`-basiert
5. Falls ExamSession schon `Identifiable` ist: `hash(into:)` basierend auf `id`

## Policy

- Pattern: `model-conformance-gap`
- Policy: `add-minimal-conformance` — fehlende Protocol-Conformance ergaenzen, bevorzugt id-basiert

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

Ergebnis in `_commands/022_examsession_hashable_result.md`:
- Root cause (welche Property blockiert)
- Gewaehlter Fix-Ansatz
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: ExamSession Hashable conformance (Report 63-0)

- Hashable/Equatable via id-basiert
- Policy: add-minimal-conformance"
git push
```
