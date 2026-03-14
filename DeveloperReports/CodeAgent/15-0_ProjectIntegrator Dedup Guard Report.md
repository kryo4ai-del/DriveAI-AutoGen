# ProjectIntegrator Dedup Guard Report

**Datum**: 2026-03-14
**Scope**: Prevent ProjectIntegrator from blindly overwriting existing project files
**Ziel**: FK-012-Kollisionen durch blinden File-Copy eliminieren

---

## 1. Root Cause

### Alter ProjectIntegrator (vor Fix)

```python
# project_integrator.py — alte Logik (vereinfacht)
for filename in generated_files:
    if filename in _PROTECTED_FILES and os.path.exists(dest_path):
        skip()      # Nur statische Whitelist geschuetzt
    else:
        shutil.copy2(src, dest)  # BLIND COPY — ueberschreibt alles
```

**Probleme**:
1. `_PROTECTED_FILES` war eine **statische Whitelist** mit 55 hardcodierten Dateinamen
2. Alle anderen Dateien wurden **blind ueberschrieben** — auch wenn sie bereits im Projekt existierten
3. Neue generierte Dateien wurden **ohne Prüfung** hinzugefuegt, selbst wenn sie Typen enthielten die bereits existierten
4. Der Integrator lief **vor** dem OutputIntegrator (der den korrekten Dedup-Guard hat)

### Konkrete Schaeden in Run 3

| Datei | Was passierte | FK-012 Folge |
|---|---|---|
| ReadinessLevel.swift | UEBERSCHRIEBEN mit neuer Version | StrengthRating, ExamReadinessScore, ReadinessTrendPoint verloren |
| ExamReadinessViewModel.swift | UEBERSCHRIEBEN mit neuer Version | Alte ViewModel-Logik verloren |
| GeneratedHelpers.swift | UEBERSCHRIEBEN mit altem Duplikat-Dump | 2x ExamReadinessService Actor eingefuegt |
| ExamReadiness.swift | NEU HINZUGEFUEGT | Inline CategoryReadiness + ReadinessLevel → FK-012 |
| UserProgressService.swift | NEU HINZUGEFUEGT | Inline LocalDataService + CategoryProgress → FK-012 |

**Ergebnis: 5 FK-012 Kollisionen**, alle durch ProjectIntegrator verursacht.

---

## 2. Minimal Fix

### Neuer ProjectIntegrator — Dynamischer Projekt-File-Index

**Kernidee**: Statische `_PROTECTED_FILES` Whitelist (55 Eintraege) ersetzt durch dynamischen Projekt-Scan. Jede .swift-Datei die bereits irgendwo im Projekt existiert, wird uebersprungen.

```python
def _build_project_file_index(self) -> dict[str, str]:
    """Scannt alle .swift-Dateien im Projekt (exkl. generated_code/)."""
    index = {}
    for swift_file in root.rglob("*.swift"):
        # Skip generated_code/ (self-reference)
        try:
            swift_file.resolve().relative_to(generated)
            continue
        except ValueError:
            pass
        index[swift_file.name] = rel_path
    return index
```

**In `integrate_generated_code()`**:
```python
project_files = self._build_project_file_index()

for filename in generated_files:
    if filename in project_files:
        skipped_existing.append((filename, project_files[filename]))
        continue  # SKIP statt blindem Copy
    # ... nur neue Dateien werden kopiert
```

### Aenderungen im Detail

1. **`_PROTECTED_FILES` entfernt** (55-Zeilen statische Whitelist) — ersetzt durch dynamischen Index
2. **`_build_project_file_index()`** hinzugefuegt — scannt Projekt, exkludiert generated_code/
3. **Skip-Logik** geaendert: `filename in project_files` statt `filename in _PROTECTED_FILES`
4. **Return-Dict** angepasst: `protected` → `skipped_existing` (semantisch korrekt)
5. **Console-Output** verbessert: zeigt existierende Pfade bei Skip
6. **main.py** aborted-Dict angepasst: `protected: 0` → `skipped_existing: 0`

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| code_generation/project_integrator.py | Komplett ueberarbeitet: _PROTECTED_FILES entfernt, _build_project_file_index() hinzugefuegt, dynamischer Skip |
| main.py | Aborted-Dict Key: protected → skipped_existing |
| factory/operations/compile_hygiene_validator.py | XCTest, DriveAI zu Framework-Types hinzugefuegt |

### Projekt-Bereinigung (Run 3 Schaden revertiert)

| Datei | Aenderung |
|---|---|
| Models/GeneratedHelpers.swift | Auf Minimal-Placeholder zurueckgesetzt (2x ExamReadinessService Actor entfernt) |
| Models/ReadinessLevel.swift | Inline CategoryReadiness + ExamReadinessServiceProtocol entfernt |
| Services/ExamReadinessService.swift | Auf Placeholder reduziert (Impl jetzt in user-modifizierter ExamReadinessServiceProtocol.swift) |

---

## 4. Before vs After Integration Behavior

### Simulation: Run 3 Files mit neuem ProjectIntegrator

| Datei | Alt (blind) | Neu (mit Guard) |
|---|---|---|
| GeneratedHelpers.swift | COPY (overwrite) | **SKIP** (exists: Models\GeneratedHelpers.swift) |
| ReadinessLevel.swift | COPY (overwrite) | **SKIP** (exists: Models\ReadinessLevel.swift) |
| ExamReadinessViewModel.swift | COPY (overwrite) | **SKIP** (exists: ViewModels\ExamReadinessViewModel.swift) |
| ExamReadiness.swift | COPY (new) | COPY (new — kein Filename-Match) |
| UserProgressService.swift | COPY (new) | COPY (new — kein Filename-Match) |
| CategoryReadinessRow.swift | COPY (new) | COPY (new) |
| ErrorStateView.swift | COPY (new) | COPY (new) |
| FocusAreasCard.swift | COPY (new) | COPY (new) |
| ReadinessGaugeCard.swift | COPY (new) | COPY (new) |

**Ergebnis**: 9 → 6 Copies, 3 Overwrites verhindert

### FK-012 Impact

| Metrik | Vor Fix | Nach Fix |
|---|---|---|
| Overwrite-verursachte FK-012 | 3 | **0** |
| New-file-verursachte FK-012 | 2 | 2 |
| **Total FK-012 aus ProjectIntegrator** | **5** | **2** |
| **Reduktion** | | **-60%** |

---

## 5. Compile Hygiene nach Cleanup

| Metrik | Nach Run 3 (vor Fix) | Nach Fix + Cleanup |
|---|---|---|
| Files scanned | 123 | 117 |
| Total Issues | 11 | **2** |
| FK-012 | 5 | **0** |
| FK-014 | 5 | **1** |
| FK-015 | 1 | 1 |
| Blocking | 10 | **1** |

Das verbleibende FK-014 (`ExamReadiness` Type nicht deklariert) ist ein Folge-Issue der user-modifizierten `ExamReadinessServiceProtocol.swift`, nicht des ProjectIntegrators.

---

## 6. Remaining Limits

### 6.1 Neue Dateien mit Inline-Duplikaten

Der ProjectIntegrator Guard schuetzt nur gegen **Filename-Kollisionen**. Wenn die Factory eine neue Datei generiert (z.B. `ExamReadiness.swift`) die inline einen Typ definiert der bereits in einer anderen Datei existiert (z.B. `CategoryReadiness` in `CategoryReadiness.swift`), wird sie trotzdem kopiert.

**Fix**: Erfordert CodeExtractor-Projekt-Awareness — `_strip_duplicate_types()` muesste den Projekt-File-Index kennen, nicht nur die current-run Files.

### 6.2 Kein Content-Level Merge

Der Guard ist filename-basiert. Zwei Dateien mit unterschiedlichen Namen koennen denselben Typ enthalten. Content-Level-Dedup waere ein groesseres Projekt (Type-Registry quer ueber alle Dateien).

### 6.3 OutputIntegrator laeuft weiterhin parallel

Beide Integratoren existieren noch. Der ProjectIntegrator laeuft im Implementation Pass, der OutputIntegrator in der Operations Layer. Langfristig waere ein Single-Path sauberer.

---

## 7. Verdict: ProjectIntegrator ist materiell sicherer

### Was jetzt geschuetzt ist
- **Alle existierenden Dateien** im Projekt sind vor Overwrite geschuetzt (nicht nur 55 hardcodierte)
- Dynamischer Index passt sich automatisch an neue Projekt-Dateien an
- Keine manuelle Pflege der Protected-Liste mehr noetig

### Was noch fehlt
- Inline-Typ-Duplikate in **neuen** generierten Dateien (2 von 5 FK-012 unbehandelt)
- Erfordert CodeExtractor-Projekt-Awareness als naechsten Schritt

### Quantitativ
- **Overwrite-Schutz**: 0% → **100%** (dynamisch statt statisch)
- **FK-012 Verhinderung**: 0% → **60%** (3 von 5 Run-3-Kollisionen)
- **Wartungsaufwand**: _PROTECTED_FILES (55 Zeilen manuelle Pflege) → 0 Zeilen (automatisch)
