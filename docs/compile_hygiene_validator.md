# Compile Hygiene Validator

**Modul:** `factory/operations/compile_hygiene_validator.py`
**Typ:** Post-generation validation (deterministic, no LLM)
**Status:** v2 — 6 Checks implementiert (Round 2 + Round 3)

---

## Warum dieser Validator existiert

Die AskFin Premium Factory-Run (askfin_v1-1) produzierte 50+ Compile Errors. Die Analyse (Error Pattern Seed Round 1) identifizierte 7 wiederkehrende Fehlerklassen. Sechs davon sind automatisch und deterministisch erkennbar — diese prueft der Validator.

Ziel: Compile-Fehler erkennen **bevor** der Code in Xcode landet.

---

## Checks

### Round 2 Checks

#### FK-011 — AI Review Text in Source Files
**Severity:** BLOCKING

Erkennt AI-Agent-Kommentare die versehentlich in Swift-Dateien gelandet sind:
- Markdown-Headings (`## Review`)
- Review-Labels (`Issue:`, `Fix:`, `Recommendation:`)
- Agent-Selbstreferenz (`I'm stopping here...`)
- Markdown-Bold (`**Problem:**`)
- Nummerierte Review-Items (`1. Bug: ...`)

Ignoriert Matches in Kommentaren (`//`, `/* */`) und String-Literalen.

**Warum:** 5 von 75 Dateien waren in askfin_v1-1 davon betroffen.

#### FK-012 — Doppelte Typ-Definitionen
**Severity:** BLOCKING

Findet `struct`, `class`, `enum`, `protocol`, `actor` Deklarationen die in mehr als einer Datei vorkommen. Erkennt auch nested Typen (eingerueckt).

Ignoriert: Apple-Framework-Typen, Swift Codable Patterns (`CodingKeys`).

**Warum:** 8+ Redeclarations in askfin_v1-1.

#### FK-015 — Bundle.module in Xcode App Targets
**Severity:** WARNING

Erkennt `Bundle.module` in Swift-Dateien (nur in Swift Package Manager Targets gueltig).

**Warum:** 5 Dateien in askfin_v1-1 betroffen.

### Round 3 Checks

#### FK-013 — Parameter-Mismatch an Call-Sites
**Severity:** BLOCKING (0% Match) / WARNING (partieller Match)

Vergleicht Parameter-Labels an Call-Sites gegen bekannte explizite init-Signaturen. Erkennt wenn generierter Code einen Typ mit falschen Parameter-Namen aufruft.

**Mechanismus:**
1. Sammelt alle expliziten `init(...)` Deklarationen pro Typ (mit balanced-parenthesis Parsing fuer multi-line inits)
2. Ordnet jedes init dem richtigen Typ-Scope zu (auch in Extensions)
3. Findet `TypeName(label: ...)` Call-Sites
4. Vergleicht Call-Labels gegen bekannte Signaturen
5. Flaggt wenn <50% der Labels matchen und mind. 2 Labels vorhanden

**Limitierungen:**
- Prueft nur Typen die ein explizites `init` haben. Structs mit implizitem memberwise init werden uebersprungen (kein Full Swift Parser)
- Erkennt keine Methoden-Aufrufe mit falschen Parametern (nur init/Konstruktor)
- Kann bei Closures oder Trailing-Closure-Syntax false positives erzeugen

**Warum:** 4 View Call-Site Mismatches in askfin_v1-1.

#### FK-014 — Referenzierte Typen nie generiert
**Severity:** BLOCKING

Findet PascalCase-Typnamen die in 2+ Dateien referenziert aber nirgends deklariert werden.

**Mechanismus:**
1. Sammelt alle PascalCase-Referenzen (min. 4 Zeichen)
2. Filtert String-Literale und Kommentare raus
3. Vergleicht gegen Type Registry (deklarierte Typen)
4. Nur Findings die in 2+ Dateien vorkommen (reduziert Noise)

**Ignoriert:** 100+ Apple-Framework-Typen (SwiftUI, Foundation, Combine, UIKit), Swift-Keywords, Compiler-Direktiven, Codable-Typen.

**Limitierungen:**
- Erkennt keine Typen die in nur einer Datei referenziert werden (zu viel Noise)
- Kann durch Extensions oder Typealiases false positives erzeugen
- Nested Types (z.B. `Result.QuestionResult`) werden einzeln erkannt

**Warum:** 5+ fehlende Typen in askfin_v1-1.

#### FK-017 — Namespace-Kollisionen zwischen Feature-Layern
**Severity:** BLOCKING (cross-layer) / WARNING (generischer Name)

Erkennt zwei Szenarien:
1. **Cross-Layer Collision:** Gleicher Typ-Name in verschiedenen Feature-Ordnern (z.B. `Models/Question.swift` und `Premium/Models/Question.swift`)
2. **High-Risk Generic Names:** Generische Namen wie `Question`, `Session`, `Result` ohne Feature-Prefix (Warnung)

**Mechanismus:**
- Extrahiert Feature-Layer aus Pfad-Struktur (`Premium/Models/` → Layer "Premium")
- Prueft ob gleicher Typ in mehreren Layern vorkommt

**Limitierungen:**
- Erkennt nur pfadbasierte Layer-Grenzen, keine logischen Module
- Generic-Name-Warnungen koennen bei absichtlich einfachen Namen zu laut sein

**Warum:** 3 Typ-Kollisionen in askfin_v1-1 (`Question`, `Category`, `SessionResult`).

---

## Nutzung

### CLI (standalone)
```bash
python -m factory.operations.compile_hygiene_validator --project askfin_v1-1

# Custom Verzeichnis
python -m factory.operations.compile_hygiene_validator --project myapp --scan-dir /path/to/sources
```

### Programmatisch
```python
from factory.operations.compile_hygiene_validator import CompileHygieneValidator

validator = CompileHygieneValidator(project_name="askfin_v1-1")
report = validator.validate()

if report.status.value == "BLOCKING":
    print("Fix issues before building!")
```

### Exit Codes
- `0` — CLEAN oder WARNINGS
- `1` — BLOCKING

---

## Reports

Gespeichert in: `factory/reports/hygiene/<project>_compile_hygiene.json`

```json
{
  "project": "askfin_v1-1",
  "files_scanned": 75,
  "checks_run": ["FK-011", "FK-012", "FK-013", "FK-014", "FK-015", "FK-017"],
  "status": "CLEAN",
  "issues_found": 0,
  "blocking": 0,
  "warnings": 0,
  "issues": []
}
```

---

## Status-Klassifikation

| Status | Bedeutung | Wann |
|---|---|---|
| CLEAN | Keine Issues | Alles sauber |
| WARNINGS | Nur low-risk Findings | FK-015, low-confidence FK-013, FK-017 generic names |
| BLOCKING | Build wird fehlschlagen | FK-011, FK-012, FK-014, FK-017 cross-layer, high-confidence FK-013 |

---

## Pipeline-Integration

Integriert in `main.py` → `_run_operations_layer()`. Laeuft nach dem Completion Verifier. Status wird im Operations Layer Summary angezeigt.

---

## Noch nicht implementiert

- FK-016: Custom init unterdrueckt memberwise init (schwer deterministisch zu erkennen)
- Automatische Fix-Vorschlaege
- Blocking Gate (Pipeline stoppen wenn BLOCKING)
