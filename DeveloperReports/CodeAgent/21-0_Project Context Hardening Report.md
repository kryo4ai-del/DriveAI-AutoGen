# Project Context Hardening Report

**Datum**: 2026-03-14
**Scope**: Projekt-Kontext Auto-Inferenz + Warn-Logging bei fehlendem Projekt
**Ziel**: AskFin-Runs nutzen automatisch den richtigen Projekt-Kontext

---

## 1. Current Project-Context Root Cause

### Problem

`a["project"]` wird nur gesetzt wenn `--project <name>` explizit als CLI-Argument uebergeben wird. Default ist `None`.

```python
# CLI-Parsing (Zeile 93)
result = {
    "project": None,  # ← Default: None
}

# Nur gesetzt wenn --project uebergeben (Zeile 217-219)
elif args[i] == "--project" and i + 1 < len(args):
    result["project"] = args[i + 1]
```

### Auswirkung bei `project = None`

| Feature | Mit project | Ohne project |
|---|---|---|
| ProjectIntegrator Target | `projects/askfin_v1-1/` | `DriveAI/` (alter Pfad) |
| ProjectIntegrator Dedup | Gegen 125 Projekt-Files | Gegen DriveAI/ (leer/alt) |
| CodeExtractor Projekt-Awareness | Aktiv (117+ File-Stems) | **Inaktiv** |
| Operations Layer | Laeuft | **Uebersprungen** |
| CompileHygiene | Laeuft | **Uebersprungen** |
| RunMemory | Laeuft | **Uebersprungen** |
| Recovery | Laeuft | **Uebersprungen** |

### Warum Run 5 betroffen war

```bash
# Aufruf ohne --project:
python main.py --template feature --name ExamReadiness --profile dev --approval auto

# Korrekter Aufruf:
python main.py --template feature --name ExamReadiness --profile dev --approval auto --project askfin_v1-1
```

Kein Fehler, keine Warnung — die Pipeline lief stillschweigend im degradierten Modus.

---

## 2. Minimal Fix Implemented

### Auto-Inferenz aus `projects/` Verzeichnis

Nach dem CLI-Parsing wird geprueft ob `a["project"]` gesetzt ist. Falls nicht:

1. Scanne `projects/` Verzeichnis nach Unterordnern
2. Wenn **genau 1** Projekt existiert → automatisch verwenden
3. Wenn **mehrere** → Warning mit Liste (User muss waehlen)
4. Wenn **keines** → Warning (projects/ leer)

```python
# Auto-inference (nach CLI-Parsing, vor return)
if not result["project"]:
    _projects_dir = os.path.join(os.path.dirname(__file__), "projects")
    _candidates = [d for d in os.listdir(_projects_dir)
                   if os.path.isdir(...) and not d.startswith(".")]
    if len(_candidates) == 1:
        result["project"] = _candidates[0]
        result["_project_source"] = "auto-inferred (single project in projects/)"
    elif len(_candidates) > 1:
        result["_project_source"] = f"ambiguous — {len(_candidates)} projects found"
```

### Explizites Logging

**Beim Startup (vor Pipeline-Aufruf)**:
```
# Bei Auto-Inferenz:
Project         : askfin_v1-1 (auto-inferred (single project in projects/))

# Bei explizitem --project:
Project         : askfin_v1-1 (explicit (--project flag))

# Wenn kein Projekt:
Project         : NONE — ambiguous — 2 projects found: askfin_v1-1, askfin_v2. Use --project to select.
  WARNING: Operations Layer, ProjectIntegrator dedup, and
  CodeExtractor project-awareness will be inactive.
  Use --project <name> to enable full validation pipeline.
```

**Im Pipeline-Header**:
```
Project         : askfin_v1-1
# oder:
Project         : NONE — Operations Layer will be skipped!
```

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `main.py` Zeilen 237-264 | Auto-Inferenz nach CLI-Parsing: Projekt aus `projects/` Verzeichnis |
| `main.py` Zeilen 1422-1432 | Startup-Logging: Projekt + Quelle + Warning bei NONE |
| `main.py` Zeilen 442-445 | Pipeline-Header: Projekt-Zeile mit Warning bei NONE |

---

## 4. Before vs After Project-Resolution Behavior

### Szenario A: `--project` nicht angegeben, 1 Projekt in `projects/`

| | Vorher | Nachher |
|---|---|---|
| `a["project"]` | `None` | **`askfin_v1-1`** |
| Quelle | — | `auto-inferred (single project in projects/)` |
| Console-Output | Keine Info | `Project: askfin_v1-1 (auto-inferred...)` |
| ProjectIntegrator | `DriveAI/` | **`projects/askfin_v1-1/`** |
| CodeExtractor Awareness | Inaktiv | **Aktiv** |
| Operations Layer | **Uebersprungen** | **Laeuft** |

### Szenario B: `--project askfin_v1-1` explizit angegeben

| | Vorher | Nachher |
|---|---|---|
| `a["project"]` | `askfin_v1-1` | `askfin_v1-1` (identisch) |
| Quelle | — | `explicit (--project flag)` |
| Verhalten | Identisch | Identisch + Logging |

### Szenario C: Mehrere Projekte in `projects/`, kein `--project`

| | Vorher | Nachher |
|---|---|---|
| `a["project"]` | `None` | `None` (identisch) |
| Console-Output | Nichts | **WARNING mit Projekt-Liste** |
| Verhalten | Stillschweigend degradiert | **Laut degradiert** |

### Szenario D: `projects/` Verzeichnis leer oder nicht vorhanden

| | Vorher | Nachher |
|---|---|---|
| `a["project"]` | `None` | `None` |
| Console-Output | Nichts | **WARNING: no projects found** |

---

## 5. Remaining Limits

### 5.1 Kein Fail-Fast bei ambigem Projekt

Wenn mehrere Projekte existieren und `--project` fehlt, warnt die Pipeline aber laeuft trotzdem (degradiert). Ein Fail-Fast waere strenger aber koennte bestehende Workflows brechen die kein `--project` brauchen.

### 5.2 Inferenz basiert nur auf Verzeichnisse

Die Inferenz prueft `projects/` auf Unterordner — nicht auf den Inhalt der Project Registry (`project_registry.json`). Fuer den aktuellen Stand (1 Projekt) reicht das. Bei mehreren Projekten koennte man die Registry fuer Template-zu-Projekt-Mapping nutzen.

### 5.3 Kein Template-zu-Projekt-Mapping

Eine zukuenftige Verbesserung waere: Template `feature/ExamReadiness` → automatisch `askfin_v1-1` (weil ExamReadiness ein AskFin-Feature ist). Das erfordert aber ein Feature-zu-Projekt-Mapping das aktuell nicht existiert.

---

## 6. Verdict: Normal AskFin Runs nutzen jetzt automatisch den Projekt-Kontext

### Quantitativ

| Metrik | Vorher (Run 5) | Nachher |
|---|---|---|
| Auto-Inferenz | Keine | **askfin_v1-1 automatisch erkannt** |
| Operations Layer | Uebersprungen | **Laeuft** |
| CompileHygiene | Uebersprungen | **Laeuft** |
| ProjectIntegrator Target | DriveAI/ (falsch) | **projects/askfin_v1-1/** (korrekt) |
| CodeExtractor Awareness | Inaktiv | **Aktiv (117+ File-Stems)** |
| Warnung bei NONE | Keine | **Explizit mit Anleitung** |

### Validierung

```
Test 1 (no args):       project=askfin_v1-1, source=auto-inferred (single project in projects/)
Test 2 (explicit):      project=askfin_v1-1, source=explicit (--project flag)
Test 3 (template only): project=askfin_v1-1, source=auto-inferred (single project in projects/)
```

### Nächster Run

Der Befehl `python main.py --template feature --name ExamReadiness --profile dev --approval auto` wird jetzt automatisch:
1. `askfin_v1-1` als Projekt erkennen
2. ProjectIntegrator ins richtige Verzeichnis integrieren
3. CodeExtractor Projekt-Awareness aktivieren
4. Operations Layer ausfuehren (CompileHygiene, Recovery, RunMemory)
