# PropertyShapeRepairer Class Support Report

**Datum**: 2026-03-15
**Scope**: Class-Awareness fuer PropertyShapeRepairer
**Ziel**: Classes (ObservableObject ViewModels) korrekt erkennen und behandeln

---

## 1. Root Cause in Old PropertyShapeRepairer Logic

6 Stellen im Code nutzten `struct`-only Regex:
- `_STRUCT_DECL_RE`: `r'^(struct\s+...`
- `_count_stored_properties()`: `r'^...struct\s+{type_name}'`
- `_insert_properties()`: `r'^...struct\s+{type_name}'`
- `repair_from_hygiene()`: Regex + Fehlermeldungen nur fuer `struct`

Wenn `ExamReadinessViewModel` eine `class` ist (ObservableObject), meldet der Repairer "struct not found" statt die Class zu finden.

---

## 2. Exact Central Fix Implemented

### A. Regex-Erweiterung: `struct` → `(?:struct|class)`

Alle 4 Regex-Stellen geaendert:

```python
# VORHER
rf'^(?:public\s+|internal\s+)?struct\s+{re.escape(type_name)}\b'

# NACHHER
rf'^(?:public\s+|internal\s+|private\s+)?(?:final\s+)?(?:struct|class)\s+{re.escape(type_name)}\b'
```

### B. Class-mit-explizitem-init Guard

Neuer Safety-Check: Wenn der Type eine `class` ist und schon einen expliziten `init(...)` hat, ist Property-Einfuegung nicht sinnvoll. Bei Classes erzeugt Swift KEINEN memberwise init — nur Structs bekommen das automatisch.

```python
is_class = bool(re.search(r'class\s+TypeName', content))
if is_class:
    has_explicit_init = bool(re.search(r'init\s*\(', content))
    if has_explicit_init:
        skip(reason="class has explicit init — adding properties alone
              would not fix the init mismatch")
```

---

## 3. How Declaration Matching Now Works

| Type | Vorher | Nachher |
|---|---|---|
| `struct Foo` | Gefunden | Gefunden |
| `final class Bar: ObservableObject` | **Nicht gefunden** | **Gefunden** |
| `public struct Baz` | Gefunden | Gefunden |
| `private final class Qux` | Nicht gefunden | **Gefunden** |

### Repair-Entscheidungsbaum

```
Type gefunden?
  Nein → skip ("type not found")
  Ja → Ist es eine class?
    Ja → Hat expliziten init?
      Ja → skip ("class has explicit init")
      Nein → Repair (Properties einfuegen)
    Nein (struct) → Hat 0 stored properties?
      Ja → Repair (Properties einfuegen)
      Nein → skip ("already has N stored properties")
```

---

## 4. Validation on ExamReadinessViewModel

| Schritt | Ergebnis |
|---|---|
| Type gefunden | Ja (final class in ViewModels/) |
| Ist class | Ja |
| Hat expliziten init | Ja (`init(service:)`) |
| Entscheidung | **SKIPPED** — korrekt |
| Reason | "class has explicit init — adding properties alone would not fix the init mismatch" |

### Warum Properties nicht helfen

`ServiceContainer.swift` ruft `ExamReadinessViewModel(examReadinessService:, navigationService:)` auf.
Das ViewModel hat `init(service: ExamReadinessServiceProtocol)` — nur 1 Parameter, anderer Name.
Properties einfuegen wuerde den init nicht aendern → Call-Site bleibt broken.
Das ist ein **Init-Signatur-Mismatch**, kein Property-Shape-Problem.

---

## 5. Compile Hygiene Outcome

```
Status:     BLOCKING
Blocking:   1 (FK-013 ExamReadinessViewModel — class init mismatch)
Warnings:   13
```

Dieser BLOCKING ist ein **echtes Code-Generierungs-Problem**: Generierter ServiceContainer nutzt falsche Init-Labels. Das ist nicht durch den PropertyShapeRepairer loesbar — es braucht entweder:
- Init-Signatur-Rewrite (neuer Repair-Typ), oder
- Bessere Code-Gen-Prompts die bestehende init-Signaturen respektieren

---

## 6. Regression Check Summary

| Test Case | Expected | Actual | Status |
|---|---|---|---|
| ExamReadinessSnapshot (struct, 8 props) | 8 stored | 8 | OK |
| DateComponentsValue (struct, 3 props) | 3 stored | 3 | OK |
| AnswerButtonView (struct, body only) | 0 stored | 0 | OK |
| ExamReadinessViewModel (class, explicit init) | found + skipped | found + skipped | OK |

---

## 7. Whether System Is Ready for Next Proof Run

**Ja** — das System ist strukturell bereit. Der verbleibende FK-013 BLOCKING ist ein Code-Gen-Mismatch zwischen generiertem `ServiceContainer` und bestehendem `ExamReadinessViewModel.init(service:)`. Es ist kein Repairer-Bug und kein Validator-false-positive.

Im naechsten Live-Run wird dieser Mismatch entweder:
- Nicht auftreten (anderer generierter Code)
- Auftreten aber korrekt als BLOCKING gemeldet und ehrlich uebersprungen

---

## 8. Single Next Recommended Step

**Naechster Live-Run** (Run 10) um zu sehen ob der class-init-Mismatch ein wiederkehrendes Pattern ist oder ein einmaliger Code-Gen-Zufall. Wenn wiederkehrend: **Init-Signatur-Repairer** als neuen Repair-Typ implementieren (liest den bestehenden init und generiert einen angepassten init oder Convenience-Init mit den fehlenden Labels).
