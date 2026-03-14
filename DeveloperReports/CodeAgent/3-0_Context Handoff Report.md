# Context Handoff Report

**Datum**: 2026-03-14
**Scope**: Audit und Verbesserung des team.reset() Context Handoff
**Problem**: Downstream-Agents verlieren nach team.reset() allen Code-Kontext

---

## 1. Problem-Analyse

### team.reset() ist notwendig
- Ohne Reset: >50.000 Token Akkumulation über 8 Passes
- API-Kosten explodieren, Context Window Overflow möglich
- Reset zwischen Passes ist korrekt

### team.reset() zerstört Kontext
- Implementation Pass generiert Code → team.reset()
- Bug Hunter Pass sieht **keinen Code** — nur den Task-String
- Alle Review-Agents arbeiten im Blindflug

### Bisheriger Zustand: `build_implementation_summary()`
- Lieferte nur ~780 Chars: bare File-Listing (`filename.swift → subfolder`)
- Kein Code-Kontext, keine Typen, keine Methoden
- Downstream-Reviews waren generisch statt spezifisch

---

## 2. Lösung: API Skeleton Extraction

### Neue Methode: `_extract_api_skeleton(code, max_chars=800)`
**Datei**: `code_generation/code_extractor.py`

Regex-basierte Extraktion von:
- Import statements
- Type declarations (`class`, `struct`, `enum`, `protocol`, `actor`)
- Properties (`var`, `let`, `@Published`, `@State`, `@Binding`)
- Method signatures (`func ...` ohne Body)
- Init signatures
- Enum cases

### Budget-System
- **800 Chars pro File** — verhindert Token-Explosion
- **6000 Chars Total Skeleton Budget** — Truncation bei Überschreitung
- **Sortierung**: Längere Skeletons zuerst (mehr API-Surface = wichtiger)

### Ergebnis
```
Vorher:  ~780 Chars  — "QuestionHistoryService.swift → Services"
Nachher: ~2000-7000 Chars — vollständiges API Skeleton mit Typen + Methoden
```

### Beispiel-Output (gekürzt)
```
## Implementation Context
Feature: "Add question history tracking"
Files generated: 5

### QuestionHistoryService.swift (Services)
```swift
import Foundation
class QuestionHistoryService: ObservableObject {
    @Published var history: [QuestionRecord] = []
    func addRecord(_ record: QuestionRecord)
    func clearHistory()
    func getFilteredHistory(filter: HistoryFilter) -> [QuestionRecord]
}
```

---

## 3. Validierung

### AskFin (75 Files) Token-Rechnung
- 75 Files × ~24 Chars Skeleton avg = ~1800 Tokens (~7200 Chars)
- Mit 800 Chars/File Cap + 6000 Total Budget → Truncation greift
- Ergebnis bleibt innerhalb akzeptabler Limits

### Downstream Impact
- Bug Hunter sieht jetzt Typen, Properties, Method Signatures
- Reviews werden spezifisch statt generisch
- Fix Executor erhält `impl_summary` Parameter mit vollem Skeleton
