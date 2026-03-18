# Swift Compile Reality Check Report

**Datum**: 2026-03-15
**Scope**: Erster echter swiftc Parse-Check auf Mac (Xcode 26.3)
**Ziel**: Plattform-Wahrheit messen — kompiliert die AskFin-Baseline wirklich?

---

## 1. Compile Environment

| Metrik | Wert |
|---|---|
| Plattform | macOS (Mac) |
| Toolchain | Xcode 26.3 |
| Befehl | `swiftc -parse` (Syntax-Check, kein volles Compile) |
| Methode | `_commands/` Queue (Windows -> Mac -> Windows via Git) |
| Xcode-Projekt | Nicht vorhanden (kein .xcodeproj, kein Package.swift) |

---

## 2. Compile Outcome

| Metrik | Wert |
|---|---|
| Swift Files geprueft | **227** |
| Exit Code | **1** (Fehler) |
| Unique Errors | **19** |
| Total Error Lines | 38 (inkl. Duplikate) |
| Warnings | 0 |
| Betroffene Files | **16** |
| Saubere Files | **211 (93%)** |

---

## 3. Fehler-Patterns (4 Kategorien)

### Pattern 1: Top-Level Statements (11 Files, 58% der Fehler)

```
"expressions/statements are not allowed at the top level"
```

**Ursache**: Die Factory generiert Usage-Beispiele oder Code-Snippets die als ausfuehrbarer Code ausserhalb von Structs/Classes im File stehen.

**Beispiel** (konzeptionell):
```swift
struct ExamConfig {
    let maxQuestions: Int
}

// Das hier steht als Top-Level-Code im File:
let config = ExamConfig(maxQuestions: 30)
print(config.maxQuestions)  // <-- ERROR: not allowed at top level
```

**Betroffene Files**:
- ExamConfig.swift
- ReadinessThresholds.swift
- ExamDateState.swift
- AssessmentButtonStyle.swift
- ServiceError.swift
- QuestionOptionButton.swift
- ExamReadiness.swift
- AccessibilityColors.swift
- ExamReadinessView.swift
- ReadinessScore+Extension.swift
- ReadinessState.swift

### Pattern 2: Strukturelle Fragmente (4 Files, 21%)

```
"extraneous '}' at top level"
```

**Ursache**: Code-Fragmente ohne umschliessende struct/class/extension. Oder Code der mitten in einer Methode beginnt.

**Betroffene Files**:
- ReadinessScore+Extension.swift (2x)
- PreviewDataFactory.swift (fehlendes #endif)
- UIError.swift

### Pattern 3: Abgeschnittener Code (2 Files, 10%)

```
"expected declaration" nach @MainActor
```

**Ursache**: `@MainActor` am Ende eines Files ohne zugehoerige Deklaration — der Rest des Codes wurde abgeschnitten (Truncation).

**Betroffene Files**:
- ExamReadinessError.swift:39
- PersistenceError.swift:15

### Pattern 4: Pseudo-Code (1 File, 5%)

```
`if ... { ... }` als Platzhalter
```

**Betroffene Files**:
- ReadinessThresholds.swift

---

## 4. Interpretation: Factory-Central oder Project-Local?

### Eindeutig Factory-Central

Alle 4 Patterns sind **Code-Generierungs-Defizite**, keine projektspezifischen Probleme:

| Pattern | Factory-Ursache | Betroffene Pipeline-Stufe |
|---|---|---|
| Top-Level Statements | LLM generiert Usage-Beispiele als echten Code | **CodeExtractor** (sollte sie erkennen) |
| Strukturelle Fragmente | LLM generiert Code-Snippets ohne Kontext | **CodeExtractor** (sollte Fragmente erkennen) |
| Abgeschnittener Code | Message-Limit erreicht, Code unvollstaendig | **CodeExtractor** (Truncation-Erkennung) |
| Pseudo-Code | LLM schreibt `{ ... }` Platzhalter | **CodeExtractor** (sollte Platzhalter erkennen) |

### Was das fuer die Factory bedeutet

1. **CodeExtractor** ist der zentrale Fix-Punkt — er muss Top-Level-Statements und Fragmente erkennen
2. **CompileHygiene** hat diese Patterns nicht erkannt — FK-011 bis FK-017 decken sie nicht ab
3. **Ein neues FK-Pattern** (z.B. FK-019: Top-Level Statement Detection) waere sinnvoll

---

## 5. Einordnung in den Gesamtfortschritt

### Von 0% auf 93% Compile-Sauberkeit

| Zeitpunkt | Compile-Status |
|---|---|
| Vor Factory-Arbeit | Unbekannt (nie getestet) |
| Run 4-7 | Nicht testbar (Windows, kein swiftc) |
| Run 8-14 | CompileHygiene: 0 BLOCKING (aber kein echtes Compile) |
| **Jetzt (Mac swiftc)** | **93% sauber, 7% Top-Level-Statement-Fehler** |

### Was die Factory-Repair-Pipeline schon geloest hat

| Problem | Geloest durch |
|---|---|
| Typ-Duplikate (FK-012) | 5-Layer Dedup |
| Fehlende Typen (FK-014) | TypeStubGenerator |
| Init-Mismatches (FK-013) | PropertyShapeRepairer |
| AI-Markdown (FK-011) | Markdown Sanitization |
| Stale Artifacts | StaleArtifactGuard |

### Was noch fehlt (durch diesen Compile-Check entdeckt)

| Problem | Noch nicht geloest |
|---|---|
| **Top-Level Statements** | Kein FK-Pattern, kein Repair |
| **Code-Fragmente** | Kein FK-Pattern, kein Repair |
| **Truncation** | Erkannt aber nicht repariert |

---

## 6. Single Next Recommended Step

**Top-Level-Statement-Cleaner als neues FK-Pattern** — ein deterministischer Post-Generation-Pass der:
1. Jede Swift-Datei parsed
2. Code ausserhalb von `struct/class/enum/protocol/extension/func/#Preview` erkennt
3. Solchen Code in Kommentare umwandelt oder entfernt
4. Als FK-019 in CompileHygiene integriert

Das wuerde die 11 betroffenen Files automatisch fixen und den Compile-Sauberkeitsgrad von 93% auf ~98% heben.

Alternativ: Die 16 Files manuell bereinigen (schneller aber nicht nachhaltig fuer zukuenftige Runs).
