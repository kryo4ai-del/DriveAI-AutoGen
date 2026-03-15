# FK-013 Property Shape Repair Report

**Datum**: 2026-03-15
**Scope**: Automatische Struct-Property-Reparatur bei FK-013 Init-Mismatches
**Ziel**: Letzten BLOCKING Issue (ExamReadinessSnapshot) autonom beheben

---

## 1. Current Real FK-013 Root Cause

### ExamReadinessSnapshot: Struct ohne Properties

```swift
// Models/ExamReadinessSnapshot.swift (VORHER)
struct ExamReadinessSnapshot {
    func validate() throws { ... }    // nur Methode
    enum SnapshotError { ... }        // nur nested enum
    // KEINE stored properties!
}
```

### Call-Site erwartet 8 Properties

```swift
// Services/MockReadinessCalculationService.swift
ExamReadinessSnapshot(
    overallReadinessPercentage: 75.0,
    categoryBreakdown: [...],
    recommendedFocusCategories: [],
    examCountdown: DateComponentsValue(...),
    currentStreak: 5,
    totalQuestionsAnswered: 100,
    estimatedCompletionDays: 7,
    lastUpdated: Date()
)
```

### Warum das passiert ist

Verschiedene Factory-Runs haben verschiedene Aspekte der gleichen Struct generiert:
- Run X: Nur das Validierungs-Snippet (func + enum)
- Run Y: Den Mock mit vollstaendigem Constructor-Aufruf

Die Property-Definitionen gingen verloren weil der Validierungs-Snippet-Run die Datei ueberschrieben hat.

---

## 2. Minimal Fix Implemented

### Neues Modul: `factory/operations/property_shape_repairer.py`

Deterministisch (kein LLM). Laeuft nach CompileHygiene und Stub Generator.

**Ablauf:**
1. Extrahiert FK-013 BLOCKING Issues (0% match)
2. Findet die Struct-Definition im Projekt
3. Prueft ob die Struct 0 stored properties hat (nur dann reparierbar)
4. Extrahiert Label/Value-Paare aus der Call-Site
5. Inferiert Swift-Types aus den Werten
6. Fuegt Properties in die Struct ein

### Type-Inferenz-Heuristik

```
"75.0"                          -> Double
"5", "100"                      -> Int
"Date()"                        -> Date
"DateComponentsValue(...)"      -> DateComponentsValue
"[CategoryReadiness(...)]"      -> [CategoryReadiness]
"[]"                            -> [Any]
label: "currentStreak"          -> Int (endet auf "Streak"→count)
label: "lastUpdated"            -> Date (endet auf "date"/"Updated")
label: "overallReadinessPercentage" -> Double (endet auf "percentage")
```

### Safety Guards

- **Nur 0-Property-Structs**: Structs mit bestehenden Properties werden uebersprungen
- **Nur BLOCKING (0% match)**: Partial matches (Warnings) werden nicht angefasst
- **Einrueckungs-bewusst**: Property-Zaehlung auf erster Einrueckungsebene (4 Spaces)
- **Kein Ueberschreiben**: Properties werden nach der `{` eingefuegt, nichts wird geloescht

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `factory/operations/property_shape_repairer.py` | **NEU** — PropertyShapeRepairer Klasse (~310 Zeilen) |
| `main.py` Zeile 1037 | Import PropertyShapeRepairer |
| `main.py` Zeilen 1087-1103 | Shape Repairer nach Stub Generator, vor SwiftCompile |
| `main.py` Zeile 1224 | Shape-Repair-Count im Operations Summary |

---

## 4. Before vs After Repair-Path Behavior

### Vorher

```
CompileHygiene: 1 BLOCKING (FK-013 ExamReadinessSnapshot)
     |
     v
[NICHTS — FK-013 hat keinen Repair-Path]
     |
     v
Status: BLOCKING
```

### Nachher

```
CompileHygiene: 1 BLOCKING (FK-013 ExamReadinessSnapshot)
     |
     v
PropertyShapeRepairer:
  - Struct hat 0 stored properties
  - Call-Site hat 8 Labels
  - 8 Properties inferiert und eingefuegt:
    + let overallReadinessPercentage: Double
    + let categoryBreakdown: [CategoryReadiness]
    + let recommendedFocusCategories: [Any]
    + let examCountdown: DateComponentsValue
    + let currentStreak: Int
    + let totalQuestionsAnswered: Int
    + let estimatedCompletionDays: Int
    + let lastUpdated: Date
     |
     v
Re-run CompileHygiene: 0 BLOCKING, 12 WARNINGS
Status: WARNINGS (nicht mehr BLOCKING!)
```

### ExamReadinessSnapshot nach Repair

```swift
struct ExamReadinessSnapshot {
    let overallReadinessPercentage: Double
    let categoryBreakdown: [CategoryReadiness]
    let recommendedFocusCategories: [Any]
    let examCountdown: DateComponentsValue
    let currentStreak: Int
    let totalQuestionsAnswered: Int
    let estimatedCompletionDays: Int
    let lastUpdated: Date

    func validate() throws { ... }
    enum SnapshotError { ... }
}
```

### Quantitativ

| Metrik | Vorher | Nachher |
|---|---|---|
| FK-013 BLOCKING | 1 | **0** |
| Total BLOCKING | 1 | **0** |
| CompileHygiene Status | BLOCKING | **WARNINGS** |
| ExamReadinessSnapshot match | 0% (BLOCKING) | 28% (WARNING) |
| Properties in Struct | 0 | **8** |

---

## 5. Remaining Limits

### 5.1 Type-Inferenz nicht perfekt

- `recommendedFocusCategories: [Any]` — der Wert war `[]` (leeres Array), daher `[Any]`. Koennte `[String]` sein. Nicht kritisch fuer Kompilierbarkeit.
- Die Heuristik basiert auf Namenskonventionen und Literal-Erkennung. Komplexe Default-Werte koennten falsch inferiert werden.

### 5.2 Nur 0-Property-Structs werden repariert

Structs mit bereits bestehenden Properties werden uebersprungen um keine destructive Aenderung zu machen. Wenn eine Struct 3 von 8 benoetigten Properties hat, wird sie nicht angefasst.

### 5.3 Call-Site-Parsing hat Grenzen

Multi-line Call-Sites mit verschachtelten Closures oder Trailing-Closure-Syntax koennten nicht korrekt geparst werden. Der Parser nutzt Klammer-Balancing.

### 5.4 Verbleibende FK-013 Warnings

10 FK-013 Warnings bleiben (33%, 25%, 16% match). Diese sind partial mismatches wo die Structs teilweise korrekte Properties haben. Sie sind nicht BLOCKING und werden nicht angefasst.

---

## 6. Verdict: FK-013 Init-Mismatches sind jetzt materiell actionable

### Repair-Pipeline komplett

```
FK-014 (Type nicht deklariert)  → TypeStubGenerator    → Stub erzeugt
FK-013 (Init-Mismatch, 0%)     → PropertyShapeRepairer → Properties eingefuegt  ← NEU
FK-012 (Typ-Duplikat)           → OutputIntegrator Dedup → ubersprungen
FK-011 (Markdown)               → Markdown Sanitization  → entfernt
```

### CompileHygiene Fortschritt ueber alle Runs

| Run | BLOCKING | Status |
|---|---|---|
| Run 4 | 5 (1x FK-012, 1x FK-013, 2x FK-014, 1x FK-015) | BLOCKING |
| Run 6 | 4 (1x FK-012 fp, 1x FK-013 fp, 2x FK-014) | BLOCKING |
| Run 7 | 5 (1x FK-011, 3x FK-012, 1x FK-013) | BLOCKING |
| Aktuell | **0** | **WARNINGS** |

Von 5 BLOCKING auf **0 BLOCKING** — erstmals CLEAN (nur Warnings).
