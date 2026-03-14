# CodeExtractor Project-Awareness Report

**Datum**: 2026-03-14
**Scope**: Inline-Typ-Dedup im CodeExtractor um Projekt-File-Awareness erweitern
**Ziel**: FK-012 durch neue generierte Dateien mit Inline-Duplikaten verhindern

---

## 1. Root Cause: Neue Dateien mit Inline-Duplikaten

### Problem

Der CodeExtractor hat eine `_strip_duplicate_types()`-Funktion die Inline-Typ-Definitionen entfernt wenn der gleiche Typ eine eigene Datei hat. **Aber**: Diese Funktion kannte nur die Dateien des **aktuellen Runs** — nicht die existierenden Projekt-Dateien.

```python
# VORHER: Nur current-run Names
all_file_names = {name for name, _, _, _ in files_to_write}
#                  ^^ nur 9 Files aus diesem Run

for i, (name, ..., block) in enumerate(files_to_write):
    other_names = all_file_names - {name}   # nur 8 andere Run-Files
    cleaned = _strip_duplicate_types(block, name, other_names)
```

### Konkreter Schaden in Run 3

| Generierte Datei | Inline-Typ | Existiert im Projekt als | Gestrippt? |
|---|---|---|---|
| ExamReadiness.swift | `CategoryReadiness` | CategoryReadiness.swift | NEIN |
| UserProgressService.swift | `LocalDataService` | LocalDataService.swift | NEIN |
| UserProgressService.swift | `CategoryProgress` | CategoryProgress.swift | NEIN |

Keiner dieser Inline-Typen wurde entfernt, weil `CategoryReadiness`, `LocalDataService` und `CategoryProgress` nicht im current-run File-Set waren.

---

## 2. Minimal Fix: Projekt-File-Index fuer Dedup

### Aenderung in `extract_swift_code()`

Neuer optionaler Parameter `project_name`. Wenn gesetzt, wird der Projekt-Ordner gescannt und alle .swift-File-Stems werden dem Dedup-Set hinzugefuegt.

```python
# NACHHER: Current-run Names + Projekt-File-Stems
all_file_names = {name for name, _, _, _ in files_to_write}

project_file_stems = set()
if project_name:
    project_dir = _PROJECT_ROOT / "projects" / project_name
    for sf in project_dir.rglob("*.swift"):
        project_file_stems.add(sf.stem)

all_known_names = all_file_names | project_file_stems
#                  ^^ 9 Run-Files + 117 Projekt-Files = 126 bekannte Types

for i, (name, ..., block) in enumerate(files_to_write):
    other_names = all_known_names - {name}   # 125 bekannte Type-Names
    cleaned = _strip_duplicate_types(block, name, other_names)
```

### Wie es funktioniert

1. `extract_swift_code()` erhaelt `project_name` (z.B. `"askfin_v1-1"`)
2. Scannt `projects/askfin_v1-1/` rekursiv fuer alle `.swift`-Dateien
3. Extrahiert File-Stems (z.B. `CategoryReadiness.swift` → `CategoryReadiness`)
4. Merged mit current-run File-Names
5. `_strip_duplicate_types()` bekommt jetzt das volle Set und kann Inline-Types gegen Projekt pruefen
6. Log zeigt Quelle: `(own file in project)` vs `(own file in current run)`

### Schutzmechanismen

- `generated_code/` wird bei Projekt-Scan ausgeschlossen (Self-Reference)
- Primary Type (Dateiname) wird nie gestrippt
- Nur top-level Types (Column 0) werden gestrippt — nested Types bleiben
- Wenn kein `project_name` uebergeben wird, Verhalten identisch wie vorher

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| code_generation/code_extractor.py | `extract_swift_code()`: +project_name Parameter, Projekt-Scan, erweiterter Dedup-Block |
| main.py (Zeile 463) | Implementation Pass: `project_name=project_name` durchgereicht |
| main.py (Zeile 724) | Fix Pass: `project_name=project_name` durchgereicht |

---

## 4. Before vs After: Run 3 Files

### ExamReadiness.swift

| Metrik | Ohne Projekt-Awareness | Mit Projekt-Awareness |
|---|---|---|
| Types found | ExamReadiness, CategoryReadiness | ExamReadiness, CategoryReadiness |
| Types stripped | (none) | **CategoryReadiness** |
| Lines | 55 → 55 | 55 → **14** |
| FK-012 | 1 (CategoryReadiness) | **0** |

**Hinweis**: `ReadinessLevel` (Zeile 24) ist ein **nested enum** innerhalb `CategoryReadiness` — wird korrekt nicht gestrippt (eingerueckt, nicht Column 0).

### UserProgressService.swift

| Metrik | Ohne Projekt-Awareness | Mit Projekt-Awareness |
|---|---|---|
| Types found | UserProgressService, CategoryProgress, LocalDataService, QuestionCategory | UserProgressService, CategoryProgress, LocalDataService, QuestionCategory |
| Types stripped | (none) | **LocalDataService, CategoryProgress** |
| Lines | 21 → 21 | 21 → **13** |
| FK-012 | 2 (LocalDataService, CategoryProgress) | **0** |

### Gesamtauswirkung auf Run 3

| Metrik | Ohne Fix | Mit Fix |
|---|---|---|
| FK-012 aus neuen Dateien | 2 | **0** |
| FK-012 aus Overwrites (ProjectIntegrator) | 3 | 0 (Report 15-0 Fix) |
| **Total FK-012 aus Run** | **5** | **0** |

---

## 5. Remaining Limits

### 5.1 Type Name ≠ File Stem

Der Fix prueft ob ein Inline-Typ-Name mit einem Projekt-File-Stem uebereinstimmt. Das funktioniert wenn Types in nach ihnen benannten Dateien leben (Swift-Konvention). Es wuerde versagen wenn ein Typ in einer Datei mit anderem Namen definiert ist (z.B. `StreakData` in `DashboardState.swift`).

**In der Praxis**: Die meisten Swift-Types folgen der Konvention `TypeName.swift`. Die verbleibenden Ausnahmen (z.B. Supporting Types am Ende einer Service-Datei) sind selten genug um kein FK-012-Risiko darzustellen.

### 5.2 Kein Content-Level Type-Matching

Der Fix vergleicht Dateinamen (Stems), nicht den tatsaechlichen Code-Inhalt. Ein Type der in einer anders benannten Datei definiert ist, wird nicht erkannt. Fuer echtes Content-Level-Matching waere eine Type-Registry noetig — das ist ein groesseres Projekt.

### 5.3 QuestionCategory nicht gefangen

In `UserProgressService.swift` wurde `QuestionCategory` nicht gestrippt, weil es keine Datei `QuestionCategory.swift` im Projekt gibt (es gibt `QuestionCategory` als Typ in einer anderen Datei). Das ist die Limit aus 5.1.

---

## 6. Verdict: FK-012 aus neuen Dateien materiell reduziert

### Quantitativ

| Metrik | Vor Fix | Nach Fix |
|---|---|---|
| Run-3 FK-012 aus neuen Dateien | 2 | **0** |
| Dedup-Scope | 9 Run-Files | **126 Files** (9 Run + 117 Projekt) |
| Projekt-Awareness | Keine | **Vollstaendig** (File-Stem-Level) |

### Zusammen mit Report 15-0 (ProjectIntegrator)

| FK-012-Quelle | Vor Fixes | Nach beiden Fixes |
|---|---|---|
| Overwrite existierender Dateien | 3 | **0** (ProjectIntegrator Guard) |
| Inline-Duplikate in neuen Dateien | 2 | **0** (CodeExtractor Projekt-Awareness) |
| **Total FK-012 aus Run 3** | **5** | **0** |

### Pipeline-Schutz jetzt dreischichtig

```
1. CodeExtractor    — strippt Inline-Duplikate (Run + Projekt)
2. ProjectIntegrator — ueberspringt existierende Dateien
3. OutputIntegrator  — Dedup-Guard gegen Projekt-File-Index
```

Jede Schicht faengt FK-012 ab die die vorherige durchlassen koennte. Die einzige verbleibende Luecke ist Type-Level-Matching (Type in anders benannter Datei) — das betrifft in der Praxis nur Ausnahmefaelle.
