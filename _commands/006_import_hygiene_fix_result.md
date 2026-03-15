# 006 Import-Hygiene Safeguard + Fix — Ergebnis

**Datum**: 2026-03-15
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Import-Hygiene Modul

Erstellt: `factory/operations/import_hygiene.py`
- Deterministisch, kein LLM
- Scannt nach 30+ bekannten Foundation-Symbolen
- Prueft ob `import Foundation/SwiftUI/UIKit` bereits vorhanden
- Fuegt `import Foundation` ein wenn noetig

## Scan-Ergebnis

| Metrik | Wert |
|---|---|
| Files gescannt | 223 |
| Bereits abgedeckt (SwiftUI/Foundation) | 118 |
| **Files gefixt** | **41** |
| Nicht betroffen | 64 |

## Typecheck nach Fix

| Metrik | Vorher (005) | Nachher (006) |
|---|---|---|
| App Files | 215 | 205 |
| Root-Cause Errors | 2 (fehlende Foundation) | 2 (neues Pattern) |
| Total Errors | 10 | 14 |

### Verbleibende Errors (2 neue Root Causes)

**1. RecommendationViewModel.swift**: `cannot find type 'ObservableObject'`, `unknown attribute 'Published'`
- Ursache: Fehlendes `import Combine` — ObservableObject und @Published sind in Combine definiert
- 6 Errors (1 Root + 5 Kaskaden)

**2. WeakArea ist 3x dupliziert**: `'WeakArea' is ambiguous for type lookup`
- Definiert in: AssessmentResult.swift, WeakArea.swift, Recommendation.swift
- 2 Errors (ReadinessAssessmentServiceProtocol + RecommendationViewModel)
- Dies ist ein strukturelles Duplikat-Problem, kein Import-Problem

## Zusammenfassung

Die 2 urspruenglichen Foundation-Import-Fehler sind behoben. 41 weitere Files praeventiv gefixt.
Neue Fehler-Klasse aufgedeckt: fehlende Combine-Imports und Typ-Duplikate.
