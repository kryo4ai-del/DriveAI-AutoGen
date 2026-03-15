# 008 WeakArea Duplikat-Kollision — Ergebnis

**Datum**: 2026-03-15
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Policy

Erweitert: `config/residual_compile_policy.json` v1.1
- Neue Section: `duplicate_type_collision`
- Policy: `dedicated-file-wins` (TypeName.swift ist canonical)

## Durchfuehrung

| Aktion | File |
|---|---|
| Canonical (behalten) | Models/WeakArea.swift |
| Inline entfernt | Models/AssessmentResult.swift (Zeilen 33-46) |
| Inline entfernt | Models/Recommendation.swift (Zeilen 20-35) |

## Typecheck nach Fix

| Metrik | Vorher (007) | Nachher (008) |
|---|---|---|
| WeakArea Errors | 4 (2 unique) | 0 |
| Verbleibende Errors | — | 10 (1 File) |

### WeakArea: Geloest

### Neuer Blocker: ExamSessionViewModel.swift (10 Errors)

- `@StateObject` ist ein SwiftUI-Attribut, nicht Combine — File hat nur `import Combine`
- `session.startTime` existiert nicht auf ExamSession
- `examSessionService` nicht im Scope
- Kaskaden-Errors durch @StateObject

Dies ist ein **fehlender SwiftUI-Import + strukturelles Problem** (fehlende Properties/Services).

## Zusammenfassung

WeakArea-Kollision vollstaendig geloest. Naechste Fehler-Klasse: ExamSessionViewModel braucht SwiftUI-Import und hat fehlende Referenzen.
