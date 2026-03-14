# OutputIntegrator Dedup Fix Report

**Datum**: 2026-03-14
**Scope**: OutputIntegrator Accumulation + FK-012 Duplicate Prevention
**Ziel**: Factory-Run integriert nur aktuelle Artifacts und erzeugt keine Typ-Duplikate mehr

---

## 1. Root Cause: Accumulation + fehlende Deduplication

### Problem 1: Cross-Run Log Accumulation
`_collect_all()` sammelte Artifacts aus **4 Quellen**:
1. `generated_code/` — aktueller Run (korrekt)
2. **ALLE** `logs/driveai_run_*.txt` — 10+ historische Runs (FALSCH)
3. `delivery/exports/` — historische Exports (FALSCH)
4. `generated/` selbst als `existing_output` — Re-Integration der eigenen Ausgabe (FALSCH)

**Ergebnis**: 110 Artifacts statt 29, weil alte Runs mitgesammelt wurden.

### Problem 2: Keine Projekt-Deduplication
`_write_artifacts()` prueft nur ob die Datei in `generated/` bereits existiert (Groesse/Truncation-Guards). Es prueft **nicht**, ob derselbe Filename/Type bereits im Projektverzeichnis (`Models/`, `ViewModels/`, etc.) existiert.

**Ergebnis**: `generated/Models/AnswerOption.swift` wird neben `Models/AnswerOption.swift` geschrieben → FK-012 BLOCKING.

### Problem 3: generated/ nicht geleert
`generated/` wird nie zwischen Runs geleert. Jeder Run **addiert** Dateien, alte bleiben liegen.

---

## 2. Minimal Fix Implemented

### 2.1 Current-Run-Only Collection

`_collect_all()` sammelt jetzt nur noch:
- `generated_code/` — immer (aktueller Run)
- Logs — **nur wenn `log_filter` gesetzt** (scoped auf aktuellen Run)
- Delivery-Exports — nicht mehr gesammelt
- `existing_output` — nicht mehr gesammelt

```python
# VORHER: Alle Logs, alle Exports, existing_output
log_files = sorted(LOGS_DIR.glob("driveai_run_*.txt"))
# Kein Filter → 10+ Logs → 80+ zusaetzliche Artifacts

# NACHHER: Nur wenn log_filter gesetzt
if self.log_filter and LOGS_DIR.exists():
    log_files = [f for f in log_files if self.log_filter in f.name]
```

### 2.2 generated/ Cleanup vor Integration

Neue `_clean_output_dir()` Methode loescht alle `.swift` Dateien in `generated/` vor dem Schreiben. Parametrisiert ueber `clean_before_integrate=True` (Default).

### 2.3 Project-Level Dedup Guard

Neue `_build_project_file_index()` Methode baut einen Index aller `.swift`-Dateien im Projektverzeichnis (ausserhalb `generated/`). Vor jedem Write wird geprueft:

```python
if artifact.filename in project_files:
    # Skip — file already exists in project
    self.report.skipped_files.append((
        canonical_relative,
        f"already exists in project: {rel_existing}"
    ))
    continue
```

### 2.4 run_id Durchreichung

`_run_operations_layer()` bekommt jetzt `run_id` als Parameter und gibt es als `log_filter` an `OutputIntegrator` weiter. Auch die Re-Integration nach Recovery nutzt den gleichen Filter.

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `factory/operations/output_integrator.py` | +`clean_before_integrate` param, +`project_dir`, `_collect_all()` auf current-run-only, +`_clean_output_dir()`, +`_build_project_file_index()`, Dedup-Guard in `_write_artifacts()` |
| `main.py` | `_run_operations_layer()` +`run_id` param, `OutputIntegrator` mit `log_filter=run_id` + `clean_before_integrate=True`, Re-Integration nach Recovery ebenso |

---

## 4. Before vs After Artifact Flow

### VORHER (Run vom 2026-03-14)
```
Sources:
  generated_code/        → 20 files
  logs/ (10 Runs)        → 90 files (historisch!)
  existing_output        → already-written duplicates

Total collected:           110 artifacts
Written to generated/:     95 files
FK-012 BLOCKING issues:    155 (!)
```

### NACHHER (gleicher Run, mit Fix)
```
Sources:
  generated_code/        → 29 files  (nur aktueller Run)
  logs/                  → 0 files   (nur mit log_filter)
  existing_output        → NOT COLLECTED

Total collected:           29 artifacts
Deduped (in project):     21 files skipped
Written to generated/:     8 files  (genuinely new)
FK-012 expected:           0 (alle 8 neuen Files sind unique)
```

### Reduktion
| Metrik | Vorher | Nachher | Reduktion |
|---|---|---|---|
| Artifacts collected | 110 | 29 | -74% |
| Files written | 95 | 8 | -92% |
| FK-012 BLOCKING | 155 | 0 (erwartet) | -100% |

---

## 5. Remaining Limits

1. **Filename-basierte Dedup**: Der Guard vergleicht Dateinamen, nicht Type-Deklarationen. Wenn eine neue Datei `ExamReadiness.swift` einen Type enthalt der auch in `ReadinessScore.swift` definiert ist, wird das nicht erkannt. Fuer echte Type-Level Dedup waere ein AST-Parser noetig — zu komplex fuer den Minimal Fix.

2. **log_filter abhaengig von run_id Format**: Wenn `run_id` sich aendert (z.B. anderes Timestamp-Format), muss der Filter angepasst werden. Aktuell: `YYYYMMDD_HHMMSS`.

3. **clean_before_integrate loescht alles**: Bei iterativen Runs (z.B. Recovery → Re-Integration) wird `generated/` jedes Mal geleert und neu geschrieben. Das ist korrekt (frisch = sauber), aber bedeutet dass Recovery-Fixes nicht akkumulieren.

4. **Kein Content-Merge**: Wenn die generierte Version einer Datei besser ist als die existierende Projektdatei, wird sie trotzdem uebersprungen. Ein Merge-Mechanismus fehlt bewusst (zu komplex, zu riskant).

5. **CLI --log-filter weiterhin nutzbar**: Der CLI-Modus (`python -m factory.operations.output_integrator --log-filter X`) funktioniert wie bisher — dort kann man bewusst historische Logs einbeziehen.

---

## 6. Verdict: Materiell sicherer

Der OutputIntegrator ist jetzt **materiell sicherer fuer saubere AskFin-Runs**:

- **Keine Cross-Run Accumulation** mehr (nur `generated_code/` + optional aktueller Log)
- **Keine Re-Integration eigener Ausgabe** (`existing_output` entfernt)
- **Projekt-Level Dedup** verhindert FK-012 fuer alle Dateien die bereits im Projekt existieren
- **generated/ wird geleert** vor jeder Integration (kein Aufstauen)
- **Reporting transparent**: Jeder Skip wird mit Grund gemeldet

### Validierungsergebnisse
```
Instantiation:             PASS (log_filter, clean_before_integrate, project_dir)
Project file index:        PASS (95 existierende Files, 0 aus generated/)
Current-run collection:    PASS (29 Artifacts nur aus generated_code/)
Old logs excluded:         PASS (keine historischen Logs ohne Filter)
existing_output excluded:  PASS (nicht mehr gesammelt)
Dedup guard:               PASS (21 von 29 korrekt deduped)
New files collision-free:  PASS (8 neue Files, 0 Namenskollisionen)
main.py syntax:            PASS
output_integrator syntax:  PASS
```
