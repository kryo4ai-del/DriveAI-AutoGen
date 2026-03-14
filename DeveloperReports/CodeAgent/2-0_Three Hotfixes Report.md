# Three Hotfixes Report

**Datum**: 2026-03-14
**Scope**: 3 kritische Hotfixes aus Factory Core Audit
**Constraint**: Kein Refactoring, keine neuen Features — nur Fixes

---

## Hotfix 1: MAX_FILES_PER_RUN 10 → 50

**Datei**: `code_generation/code_extractor.py:70`

```python
# Vorher
MAX_FILES_PER_RUN = 10

# Nachher
MAX_FILES_PER_RUN = 50
```

**Zusätzlich**: `_last_extraction_files` Tuple von 3 auf 4 Elemente erweitert (Code-Content hinzugefügt für API Skeleton Extraction).

**Impact**: AskFin (75 Files) wird nicht mehr still abgebrochen. Limit 50 deckt realistische Runs ab.

---

## Hotfix 2: Dead Integration Path

**Datei**: `main.py`

```python
# Vorher
integrator = ProjectIntegrator("DriveAI")

# Nachher
integrator = ProjectIntegrator(
    os.path.join("projects", project_name) if project_name else "DriveAI"
)
```

**Zusätzlich**: `project_name: str | None = None` als Parameter zu `_run_pipeline()` hinzugefügt und durch alle 3 Call-Sites (direct pipeline, pack run, queue batch) durchgefädelt.

**Impact**: Integration schreibt in korrektes Projektverzeichnis (`projects/askfin_v1-1/`).

---

## Hotfix 3: Silent Exception Swallowing → Explicit Logging

**Datei**: `main.py` (3 Stellen)

### Stelle 1: Memory Extraction
```python
# Vorher
try: ... except: pass

# Nachher
try: ...
except Exception as e:
    logger.warning(f"Memory extraction failed: {e}")
```

### Stelle 2: Knowledge Proposals
```python
# Vorher
try: ... except: pass

# Nachher
try: ...
except Exception as e:
    logger.warning(f"Knowledge proposal generation failed: {e}")
```

### Stelle 3: Operations Layer
```python
# Vorher
try: ... except: pass

# Nachher
try: ...
except Exception as e:
    logger.warning(f"Operations layer failed: {e}")
```

**Zusätzlich**: Truthful Status Reporting — Pipeline gibt jetzt `extraction_aborted`, `cd_gate_fail` oder `success` zurück statt immer `success`.

---

## Validierung

- Alle 3 Fixes sind minimal-invasiv
- Kein bestehendes Verhalten gebrochen
- Keine neuen Dependencies
- Console Summary zeigt `ABORTED` bei Extraction Failures
