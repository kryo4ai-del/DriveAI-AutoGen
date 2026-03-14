# Compile Hygiene Validator

**Modul:** `factory/operations/compile_hygiene_validator.py`
**Typ:** Post-generation validation (deterministic, no LLM)
**Status:** v1 — 3 Checks implementiert

---

## Warum dieser Validator existiert

Die AskFin Premium Factory-Run (askfin_v1-1) produzierte 50+ Compile Errors. Die Analyse (Error Pattern Seed Round 1) identifizierte 7 wiederkehrende Fehlerklassen. Drei davon sind automatisch und deterministisch erkennbar — diese prueft der Validator.

Ziel: Compile-Fehler erkennen **bevor** der Code in Xcode landet.

---

## Checks

### FK-011 — AI Review Text in Source Files
**Severity:** BLOCKING

Erkennt AI-Agent-Kommentare die versehentlich in Swift-Dateien gelandet sind:
- Markdown-Headings (`## Review`)
- Review-Labels (`Issue:`, `Fix:`, `Recommendation:`)
- Agent-Selbstreferenz (`I'm stopping here...`)
- Markdown-Bold (`**Problem:**`)
- Nummerierte Review-Items (`1. Bug: ...`)

Ignoriert Matches in Kommentaren (`//`, `/* */`) und String-Literalen.

**Warum:** 5 von 75 Dateien waren in askfin_v1-1 davon betroffen. Jede betroffene Datei ist komplett unbrauchbar fuer den Compiler.

### FK-012 — Doppelte Typ-Definitionen
**Severity:** BLOCKING

Findet `struct`, `class`, `enum`, `protocol`, `actor` Deklarationen die in mehr als einer Datei vorkommen. Swift erlaubt keine Redeclarations im selben Target.

Ignoriert Apple-Framework-Typen (String, View, etc.).

**Warum:** 8+ Redeclarations in askfin_v1-1. Eine einzige Duplikat-Definition kann 10+ Compile Errors verursachen.

### FK-015 — Bundle.module in Xcode App Targets
**Severity:** WARNING (nicht BLOCKING, da einfach zu fixen)

Erkennt `Bundle.module` oder `bundle: .module` in Swift-Dateien. Dieser API ist nur in Swift Package Manager Targets verfuegbar, nicht in regulaeren Xcode App Targets.

**Warum:** 5 Dateien in askfin_v1-1 betroffen. Alle mussten auf inline Strings umgestellt werden.

---

## Nutzung

### CLI (standalone)
```bash
# Standard: scannt projects/<name>/
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
- `1` — BLOCKING (Compile wird definitiv fehlschlagen)

---

## Reports

Gespeichert in: `factory/reports/hygiene/<project>_compile_hygiene.json`

```json
{
  "project": "askfin_v1-1",
  "files_scanned": 75,
  "checks_run": ["FK-011", "FK-012", "FK-015"],
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
| WARNINGS | Nur low-risk Findings | Nur FK-015 (Bundle.module) |
| BLOCKING | Build wird fehlschlagen | FK-011 oder FK-012 gefunden |

---

## Noch nicht implementiert (fuer spaetere Runden)

- FK-013: Parameter-Mismatch zwischen Call-Sites und Signaturen
- FK-014: Referenzierte Typen die nie generiert wurden
- FK-016: Custom init unterdrueckt memberwise init
- FK-017: Feature-Layer Namespace-Kollisionen
- Automatische Fix-Vorschlaege
- main.py Pipeline-Integration als Gate
