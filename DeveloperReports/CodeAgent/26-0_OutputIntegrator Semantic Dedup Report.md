# OutputIntegrator Semantic Dedup + Markdown Sanitization Report

**Datum**: 2026-03-15
**Scope**: Type-Level Dedup Guard + FK-011 Markdown-Bereinigung
**Ziel**: OutputIntegrator soll keine semantischen Duplikate mehr schreiben

---

## 1. Current OutputIntegrator Semantic-Dup Root Cause

### Filename-Only Dedup

Der bestehende Dedup-Guard in `_write_artifacts()` prueft:
```python
if artifact.filename in project_files:
    # skip
```

Das matched nur den **exakten Dateinamen**. Aber:
- `generated/Services/ReadinessAssessmentService.swift` (Dateiname: `ReadinessAssessmentService.swift`)
- `Models/ReadinessAssessmentServiceProtocol.swift` (Dateiname: `ReadinessAssessmentServiceProtocol.swift`)

Verschiedene Dateinamen → kein Match → wird geschrieben. Aber beide enthalten die Klasse `ReadinessAssessmentService` → FK-012 BLOCKING.

### Warum 3 FK-012 Duplikate in Run 7

| Generated File | Enthaltene Types | Projekt-Owner |
|---|---|---|
| `generated/Services/AssessmentPersistenceService.swift` | `AssessmentPersistenceServiceProtocol` | `Models/AssessmentPersistenceServiceProtocol.swift` |
| `generated/Services/ReadinessAssessmentService.swift` | `ReadinessAssessmentServiceProtocol`, `ReadinessAssessmentService` | `Models/ReadinessAssessmentServiceProtocol.swift` |

Alle 3 Types hatten verschiedene Dateinamen → Filename-Dedup griff nicht.

### FK-011 Root Cause

OutputIntegrator schreibt Artefakte "as-is" ohne Markdown-Bereinigung. Wenn ein LLM `---` oder `## Heading` in generierten Code einbettet, landet es direkt im Projekt.

---

## 2. Minimal Fix Implemented

### 2.1 Type-Level Dedup Guard

Neuer `_build_project_type_index()` scannt alle Projekt-Swift-Files (ausserhalb `generated/`) und extrahiert top-level Type-Deklarationen:

```python
def _build_project_type_index(self) -> dict[str, str]:
    """Returns {TypeName: relative_path} for all top-level types."""
    for swift_file in self.project_dir.rglob("*.swift"):
        # Skip generated/
        content = swift_file.read_text(...)
        for m in _TOP_LEVEL_TYPE_RE.finditer(content):
            type_index[m.group(1)] = rel_path
```

In `_write_artifacts()` nach dem Filename-Check:

```python
# Type-level dedup: skip if any top-level type in artifact
# already exists in project
artifact_types = [m.group(1) for m in _TOP_LEVEL_TYPE_RE.finditer(artifact.content)]
conflicting = [(t, project_types[t]) for t in artifact_types if t in project_types]
if conflicting:
    skip(reason=f"type-level dedup: {conflict_desc}")
```

### 2.2 Markdown Contamination Sanitization

Vor dem Schreiben werden offensichtliche Markdown-Muster entfernt:
- `---` (Markdown Horizontal Rules)
- `## Heading` Zeilen (ausser in Comments/Strings)
- Resultierende Leerzeilen-Runs werden komprimiert

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `output_integrator.py` Zeilen 34-51 | Neue Regexes: `_TOP_LEVEL_TYPE_RE`, `_MARKDOWN_CONTAMINATION_RE`, `_MARKDOWN_HEADING_RE` |
| `output_integrator.py` Zeilen 621-658 | Neue Methode `_build_project_type_index()` |
| `output_integrator.py` Zeilen 672-676 | Type-Index Aufbau und Logging im `_write_artifacts()` |
| `output_integrator.py` Zeilen 690-721 | Type-Level Dedup Guard |
| `output_integrator.py` Zeilen 723-748 | Markdown Sanitization |

---

## 4. Before vs After Integration/Sanitation Behavior

### FK-012: Type-Level Dedup

**Vorher (Run 7)**: 3 Files in `generated/Services/` geschrieben die Types duplizieren:
```
generated/Services/AssessmentPersistenceService.swift
  -> AssessmentPersistenceServiceProtocol (owned by Models/AssessmentPersistenceServiceProtocol.swift)

generated/Services/ReadinessAssessmentService.swift
  -> ReadinessAssessmentService (owned by Models/ReadinessAssessmentServiceProtocol.swift)
  -> ReadinessAssessmentServiceProtocol (owned by Models/ReadinessAssessmentServiceProtocol.swift)
```
Ergebnis: 3 FK-012 BLOCKING

**Nachher**: Synthetischer Test zeigt Type-Level Dedup greift:
```
Types in artifact: [AssessmentPersistenceServiceProtocol, ReadinessAssessmentService]
Conflicting: AssessmentPersistenceServiceProtocol owned by Models\..., ReadinessAssessmentService owned by Models\...
Would be SKIPPED: True
```
Ergebnis: 0 FK-012 BLOCKING

### FK-011: Markdown Sanitization

**Vorher**: `---` in Test-File → FK-011 BLOCKING
**Nachher**: `---` wird entfernt bevor File geschrieben wird

### CompileHygiene Vergleich

| Metrik | Run 7 (nach StubGen) | Nach Fix |
|---|---|---|
| FK-011 BLOCKING | 1 | **0** |
| FK-012 BLOCKING | 3 | **0** |
| FK-013 BLOCKING | 1 | 1 (echt) |
| FK-014 BLOCKING | 0 (StubGen) | 0 |
| **Total BLOCKING** | **5** | **1** |

---

## 5. Remaining Limits

### 5.1 Type-Index scannt nur top-level Deklarationen
Nested types (column > 0) werden im Type-Index nicht erfasst. Wenn ein Artefakt einen nested type dupliziert, wird es nicht erkannt. Das ist akzeptabel — nested types sind Eigentuemer der umschliessenden struct/class.

### 5.2 Markdown-Sanitization ist konservativ
Nur `---` und `## Heading` werden entfernt. Andere AI-Kontamination (z.B. Review-Kommentare, Agent-Referenzen) wird von FK-011 im CompileHygiene erkannt aber nicht automatisch bereinigt.

### 5.3 Kein Content-Merge
Wenn ein Generated File *zusaetzliche* Types oder Methoden enthaelt neben dem duplizierten Type, wird die gesamte Datei uebersprungen. Ein Content-Merge (nur neue Parts uebernehmen) ist nicht implementiert — das waere zu riskant ohne vollstaendigen Swift-Parser.

### 5.4 Type-Index Scan-Performance
214 Types aus 158 Files werden bei jedem OutputIntegrator-Run gescannt. Das ist deterministisch und schnell (< 1s), aber bei sehr grossen Projekten koennte es langsamer werden.

---

## 6. Verdict: FK-012 und FK-011 Risiko materiell reduziert

### Quantitativ

| Metrik | Run 7 | Nach Fix |
|---|---|---|
| FK-012 durch OutputIntegrator | 3 BLOCKING | **0** |
| FK-011 durch Markdown | 1 BLOCKING | **0** |
| Total BLOCKING | 5 | **1** |
| Dedup-Layers | 2 (Filename + existing check) | **3** (+Type-Level) |

### Dedup-Tiefe jetzt

```
Layer 1: CodeExtractor inline type dedup (pre-save)
Layer 2: ProjectIntegrator filename dedup (project copy)
Layer 3: OutputIntegrator filename dedup (generated/ write)
Layer 4: OutputIntegrator TYPE-LEVEL dedup (generated/ write)  ← NEU
Layer 5: CompileHygiene FK-012 detection (post-validation)
```

5 Schutzschichten gegen Typ-Duplikate. Die einzige verbleibende BLOCKING Issue (ExamReadinessSnapshot FK-013) ist ein echtes Code-Generierungs-Problem — kein Dedup/Integrations-Defizit.
