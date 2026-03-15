# 49-0 WeakArea Dedup Report

**Datum**: 2026-03-15
**Agent**: Claude Code (Mac, Xcode 26.3)

## Policy

`dedicated-file-wins`: Wenn TypeName.swift existiert, ist das die canonical Definition.
Inline-Definitionen in anderen Files werden entfernt.

## Ergebnis

- Canonical: `Models/WeakArea.swift`
- Entfernt aus: `AssessmentResult.swift`, `Recommendation.swift`
- WeakArea-Kollision: **geloest (0 Errors)**

## Naechster Blocker

ExamSessionViewModel.swift: 10 Errors
- `@StateObject` ohne SwiftUI-Import
- Fehlende Properties (`startTime`) und Services (`examSessionService`)
