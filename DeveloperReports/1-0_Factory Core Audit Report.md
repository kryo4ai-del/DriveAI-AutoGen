# Factory Core Audit Report

**Datum**: 2026-03-14
**Scope**: Full repo-based audit — Factory Pipeline von Execution bis Clean App Output
**Ziel**: Identifikation aller Blocker für autonome App-Generierung

---

## 1. Systemic Blockers (Factory-weit)

### Blocker 1: MAX_FILES_PER_RUN = 10
- **Datei**: `code_generation/code_extractor.py`
- **Problem**: Hardcoded Limit von 10 Files pro Run — AskFin hat 75 Files
- **Impact**: Jeder Run mit >10 Files wurde **still abgebrochen** ohne Fehlermeldung
- **Fix**: Limit auf 50 erhöht

### Blocker 2: Dead Integration Path
- **Datei**: `main.py` → `ProjectIntegrator("DriveAI")`
- **Problem**: Hardcoded Pfad `DriveAI/` existiert nicht mehr (gelöscht bei Repo-Bereinigung)
- **Impact**: Output-Integration schlägt fehl, generierter Code geht verloren
- **Fix**: Dynamischer Pfad über `project_name` Parameter

### Blocker 3: Silent Exception Swallowing
- **Datei**: `main.py` (3 Stellen)
- **Problem**: Bare `except: pass` bei Memory Extraction, Knowledge Proposals, Operations Layer
- **Impact**: Kritische Fehler werden verschluckt, Pipeline meldet `success` trotz Failure
- **Fix**: Explizites Logging mit `logger.warning()` + Truthful Status Reporting

### Blocker 4: Context Loss bei team.reset()
- **Problem**: `team.reset()` zwischen Passes löscht gesamten Kontext
- **Impact**: Downstream-Agents (Bug Hunter, Refactor, Fix Executor) arbeiten ohne Code-Kontext
- **Fix**: API Skeleton Extraction + Review Digest Accumulation (separate Reports)

### Blocker 5: Truthful Status Reporting
- **Problem**: Pipeline gab immer `success` zurück, auch bei Abbruch oder Gate-Failure
- **Fix**: Neues `_pipeline_status` mit Werten: `extraction_aborted`, `cd_gate_fail`, `success`

### Blocker 6: Console Summary Misleading
- **Problem**: Normale Counts bei Extraction-Abbruch
- **Fix**: Shows `ABORTED` für Extraction Failures

---

## 2. Project-Specific Blockers (AskFin)

### Blocker A: 75 Files vs 10-File Limit
- Direkte Auswirkung von Systemic Blocker 1

### Blocker B: Veralteter Projektpfad
- Direkte Auswirkung von Systemic Blocker 2

### Blocker C: Operations Layer Exceptions
- Compile Hygiene + Swift Compile Check werfen Exceptions bei fehlenden Dateien

---

## 3. Pipeline Health Summary

| Komponente | Status vor Audit | Status nach Fix |
|---|---|---|
| Code Extraction | Silently Aborting | Functional (50 Files) |
| Output Integration | Dead Path | Dynamic Path |
| Error Reporting | Silent | Explicit Logging |
| Status Reporting | Always "success" | Truthful |
| Context Handoff | Lost at reset() | API Skeleton + Digests |
| Operations Layer | Exception-prone | Logged + Recoverable |

---

## 4. Empfehlung

Die 3 kritischsten Blocker (MAX_FILES, Dead Path, Silent Exceptions) wurden als Hotfixes umgesetzt (siehe Report 2-0). Context Handoff wurde in 2 Phasen verbessert (siehe Reports 3-0 und 4-0).
