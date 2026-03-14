# Swift Compile Check

**Modul:** `factory/operations/swift_compile_check.py`
**Typ:** Post-generation validation (deterministic, no LLM)
**Status:** v1 — swiftc-basierte Syntax-Validierung

---

## Warum dieses Modul existiert

Der Compile Hygiene Validator (FK-011 bis FK-017) erkennt bekannte Fehlermuster per Regex. Aber nicht alle Swift-Syntaxfehler lassen sich per Pattern-Matching finden. Der Swift Compile Check nutzt den echten Swift Compiler (`swiftc`) fuer eine zuverlaessige Syntax-Pruefung — erkennt Fehler die kein Regex findet.

---

## Modi

| Modus | Flag | Was wird geprueft | Geschwindigkeit |
|---|---|---|---|
| `parse` | `swiftc -parse` | Nur Syntax (Grammatik) | Schnell, keine Imports noetig |
| `typecheck` | `swiftc -typecheck` | Syntax + Typen | Langsamer, braucht SDK/Frameworks |

**Default:** `parse` — reicht fuer die meisten Factory-generierten Fehler.

---

## Wie es funktioniert

1. **swiftc suchen** — Prueft ob `swiftc` auf PATH verfuegbar ist
2. **Swift-Dateien sammeln** — Rekursiv alle `*.swift` im Projektverzeichnis
3. **Einzeln pruefen** — Jede Datei wird einzeln an `swiftc -parse` uebergeben (30s Timeout)
4. **Diagnostics parsen** — stderr wird nach `file:line:col: error/warning: message` geparst
5. **Status klassifizieren** — CLEAN / WARNINGS / BLOCKING / SKIPPED
6. **JSON Report schreiben** — Kompaktes Format, nur Dateien mit Issues

---

## Verhalten ohne swiftc

Auf Systemen ohne Swift Compiler (z.B. Windows) meldet das Modul `SKIPPED` und gibt den Grund an. Die Pipeline laeuft normal weiter — kein Fehler, kein Abbruch.

---

## Nutzung

### CLI (standalone)
```bash
python -m factory.operations.swift_compile_check --project askfin_v1-1

# Custom Verzeichnis
python -m factory.operations.swift_compile_check --project myapp --scan-dir /path/to/sources

# Typecheck statt Parse
python -m factory.operations.swift_compile_check --project myapp --mode typecheck
```

### Programmatisch
```python
from factory.operations.swift_compile_check import SwiftCompileCheck

checker = SwiftCompileCheck(project_name="askfin_v1-1")
report = checker.check()

if report.status.value == "BLOCKING":
    print(f"{report.total_errors} Fehler gefunden!")
```

### Exit Codes
- `0` — CLEAN, WARNINGS, oder SKIPPED
- `1` — BLOCKING (mindestens ein Compile Error)

---

## Reports

Gespeichert in: `factory/reports/compile/<project>_swift_compile.json`

### Beispiel: SKIPPED (kein swiftc)
```json
{
  "project": "askfin_v1-1",
  "scan_dir": "/path/to/projects/askfin_v1-1",
  "mode": "skipped",
  "files_checked": 0,
  "status": "SKIPPED",
  "skip_reason": "swiftc not found on PATH"
}
```

### Beispiel: BLOCKING (Fehler gefunden)
```json
{
  "project": "askfin_v1-1",
  "scan_dir": "/path/to/projects/askfin_v1-1",
  "mode": "parse",
  "files_checked": 75,
  "files_ok": 72,
  "files_with_errors": 3,
  "files_with_warnings": 0,
  "total_errors": 5,
  "total_warnings": 0,
  "status": "BLOCKING",
  "swiftc_path": "/usr/bin/swiftc",
  "issues": [
    {
      "file": "Views/TrainingView.swift",
      "status": "error",
      "errors": [
        "TrainingView.swift:42:15 expected ')' in expression",
        "TrainingView.swift:58:1 expected '}' at end of struct"
      ]
    }
  ]
}
```

---

## Status-Klassifikation

| Status | Bedeutung | Wann |
|---|---|---|
| CLEAN | Keine Fehler | Alle Dateien kompilieren sauber |
| WARNINGS | Nur Warnungen | swiftc meldet Warnungen, keine Errors |
| BLOCKING | Build wird fehlschlagen | Mindestens eine Datei hat Compile Errors |
| SKIPPED | Nicht geprueft | swiftc nicht verfuegbar (z.B. Windows) |

---

## Pipeline-Integration

Integriert in `main.py` → `_run_operations_layer()`.

**Reihenfolge:**
1. Output Integrator
2. Completion Verifier
3. Compile Hygiene Validator (Regex-basiert)
4. **Swift Compile Check** (swiftc-basiert) ← hier
5. Recovery Runner (bei Bedarf)
6. Run Memory

Status wird im Operations Layer Summary angezeigt.

---

## Abgrenzung zum Compile Hygiene Validator

| Aspekt | Compile Hygiene Validator | Swift Compile Check |
|---|---|---|
| Methode | Regex Pattern Matching | Echter Swift Compiler |
| Was wird erkannt | 6 bekannte Fehlermuster (FK-011 bis FK-017) | Alle Syntaxfehler |
| Abhaengigkeit | Keine (laeuft ueberall) | Braucht `swiftc` auf PATH |
| Geschwindigkeit | Sehr schnell | Langsamer (1 Prozess pro Datei) |
| False Positives | Moeglich (Regex-Limitierungen) | Keine (Compiler ist autoritativ) |
| Plattform | Windows + Mac + Linux | Nur Mac + Linux (mit Swift) |

Beide ergaenzen sich: Der Hygiene Validator laeuft ueberall und erkennt bekannte Muster. Der Swift Compile Check laeuft auf Mac/Linux und findet alles was der Compiler findet.
