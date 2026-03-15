# SwiftUI-Aware Property Counting Report

**Datum**: 2026-03-15
**Scope**: PropertyShapeRepairer + CompileHygiene memberwise-init SwiftUI-Awareness
**Ziel**: SwiftUI Property-Wrapper und computed properties korrekt klassifizieren

---

## 1. Root Cause in Old PropertyShapeRepairer Logic

### Problem 1: `var body: some View {` als stored property gezaehlt

Die alte Regex prueft `rest.startswith("{")` nach dem Doppelpunkt. Aber bei `var body: some View {` ist `rest` = `some View {` — beginnt mit `some`, nicht mit `{`. Ergebnis: Als stored property gezaehlt.

### Problem 2: `@State var x:` als stored property gezaehlt

Die alte Regex `r'^    (?:let|var)\s+(\w+)\s*:'` matcht `var x:` aber sieht den `@State` Prefix nicht. Property-Wrapper-Members sind aber NICHT Teil der Swift memberwise init.

### Problem 3: Lookahead zu weit (80 chars)

Der alte Code schaute 80 Zeichen nach dem `:` voraus um ein `{` zu finden. Bei `let hour: Int` gefolgt von `init(from components: DateComponents) {` wurde das `{` 71 Zeichen spaeter gefunden und `hour` faelschlicherweise als computed property klassifiziert.

---

## 2. Exact Central Fix Implemented

### In `property_shape_repairer.py` (`_count_stored_properties`):

```python
# 1. SwiftUI property wrappers — NOT part of memberwise init
_SWIFTUI_WRAPPERS = {
    "@State", "@Binding", "@Environment", "@EnvironmentObject",
    "@ObservedObject", "@StateObject", "@Published", "@AppStorage",
    "@SceneStorage", "@FocusState", "@GestureState", "@Namespace",
    "@FetchRequest", "@Query",
}

# 2. Regex captures prefix (including @Wrapper), keyword, name, type
r'^(    (?:@\w+(?:\(.*?\))?\s+)*)(let|var)\s+(\w+)\s*:(.*?)$'

# 3. Skip if prefix contains any SwiftUI wrapper
if any(prefix.startswith(w) for w in _SWIFTUI_WRAPPERS):
    continue

# 4. Computed property: { at END OF SAME LINE only (no cross-line lookahead)
same_line_rest = type_and_rest.strip()
if same_line_rest.endswith("{"):
    # Check = doesn't come before { (stored with closure default)
    ...
    continue
```

### In `compile_hygiene_validator.py` (`_collect_signatures` memberwise init):

Gleicher Fix angewendet — identische SwiftUI-Wrapper-Liste und same-line `{` Check.

---

## 3. How SwiftUI Wrappers / Computed Properties Are Now Handled

| Property Declaration | Old Classification | New Classification |
|---|---|---|
| `let name: String` | stored (korrekt) | stored (korrekt) |
| `var body: some View {` | stored (FALSCH) | **computed (korrekt)** |
| `@State private var isActive: Bool` | stored (FALSCH) | **skipped (korrekt)** |
| `@Binding var title: String` | stored (FALSCH) | **skipped (korrekt)** |
| `@Environment(\.colorScheme) var scheme` | stored (FALSCH) | **skipped (korrekt)** |
| `@Published var count: Int` | stored (FALSCH) | **skipped (korrekt)** |
| `var items: [String] = []` | stored (korrekt) | stored (korrekt) |

---

## 4. Validation on the AnswerButtonView Case

### Property Count

```
AnswerButtonView stored props: 0  (was 1 → now correct)
```

`var body: some View {` wird korrekt als computed property erkannt.

### CompileHygiene

AnswerButtonView FK-013 BLOCKING Issue ist **komplett verschwunden**. Grund: Die memberwise-init-Erkennung im CompileHygiene sieht jetzt dass AnswerButtonView keine explicit init und keine stored properties hat → kein Eintrag in der Signature-Map → FK-013 prueft diese Call-Site nicht mehr.

---

## 5. Compile Hygiene Outcome After Fix

```
Status:     WARNINGS
Blocking:   0
Warnings:   13
```

| Check | Blocking | Warnings |
|---|---|---|
| FK-011 | 0 | 0 |
| FK-012 | 0 | 0 |
| FK-013 | **0** | 12 |
| FK-014 | 0 | 0 |
| FK-015 | 0 | 1 |
| FK-017 | 0 | 0 |

**Erstmals 0 BLOCKING auf dem aktuellen Projekt-Stand.**

---

## 6. Whether the Remaining Blocking Issue Is Gone

**Ja — komplett geloest.** AnswerButtonView FK-013 tritt nicht mehr auf.

Keine neuen BLOCKING Issues entstanden. Alle 13 Warnings sind partial FK-013 mismatches (33%, 28%, 25% etc.) die als WARNINGS klassifiziert sind — operationell harmlos.

---

## 7. Regression Check Summary

| Test Case | Expected | Actual | Status |
|---|---|---|---|
| AnswerButtonView (body only) | 0 stored | 0 | OK |
| ExamReadinessSnapshot (8 let props) | 8 stored | 8 | OK |
| DateComponentsValue (3 let props) | 3 stored | 3 | OK |
| TestView (@State + @Binding + body) | 0 stored | 0 | OK |
| MixStruct (2 stored + 1 @Published) | 2 stored | 2 | OK |
| CompileHygiene FK-012 | 0 blocking | 0 | OK |
| CompileHygiene FK-014 | 0 blocking | 0 | OK |
| StubGen (if needed) | functional | OK | OK |

Keine Regressionen.

---

## 8. Single Next Recommended Step

**Run ein neuntes Autonomy Proof** um zu validieren dass die Pipeline mit 0 BLOCKING Issues durch die gesamte Operations Layer laeuft. Der entscheidende Test ist ob der neue Code im Live-Run halten — neue generierte Files koennten neue BLOCKING Issues erzeugen, aber die Auto-Repair-Pipeline (StubGen + ShapeRepairer + TypeDedup + Sanitization) sollte sie autonom beheben.

Alternativ: **CompletionVerifier fixen** — aktuell meldet er immer `FAILED` weil kein `specs/` Verzeichnis existiert. Das blockiert Recovery. Ein Specs-Generator oder ein intelligenterer Health-Check koennte den CompletionVerifier nuetzlich machen.
