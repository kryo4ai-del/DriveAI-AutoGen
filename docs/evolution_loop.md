# Evolution Loop — Dokumentation

## Uebersicht

Der Evolution Loop ist das iterative Qualitaetssystem der DAI-Core Factory. Er nimmt eine App nach dem initialen Build und verbessert sie autonom in Schleifen, bis sie Store-ready ist.

**Kernidee**: Evaluate → Find Gaps → Decide Fixes → Simulate → Build → Check Regression → Repeat.

Der Loop laeuft solange bis:
- Alle Quality Targets erreicht sind → CEO Review
- Budget erschoepft → CEO Review
- Maximale Iterationen erreicht → Stop
- Regression erkannt → Stop oder CEO Review

## Architektur

```
                    ┌─────────────┐
                    │     CEO     │
                    │  (Review)   │
                    └──────┬──────┘
                           │ go / no_go
                    ┌──────▼──────┐
                    │    Loop     │
                    │ Orchestrator│ ◄── EVO-06
                    │  (EVO-06)   │
                    └──┬──┬──┬──┬─┘
          ┌────────────┘  │  │  └────────────┐
          ▼               ▼  ▼               ▼
   ┌────────────┐  ┌──────────────┐  ┌─────────────┐
   │ Evaluation │  │ Gap Detector │  │  Decision   │
   │  (EVO-02)  │  │   (EVO-03)   │  │  (EVO-04)   │
   └────────────┘  └──────────────┘  └─────────────┘
          │                                  │
          ▼                                  ▼
   ┌────────────┐                    ┌─────────────┐
   │ Simulation │                    │ Regression  │
   │  (EVO-01)  │                    │  Tracker    │
   └────────────┘                    │  (EVO-05)   │
                                     └─────────────┘

   Alle Agents kommunizieren NUR ueber das LDO (Loop Data Object).
   Kein Agent-zu-Agent Chat. Alles geht durch das LDO.
```

**Position in der Factory**: Ueber den Production Lines, unter dem CEO. Der Loop greift auf Build-Artefakte der Production Lines zu und meldet Ergebnisse nach oben.

## Die 6 Agents

| Agent-ID | Name | Aufgabe |
|---|---|---|
| EVO-01 | Simulation Agent | Statische Code-Analyse: LOC, TODOs, Stubs, Nesting, Error Handling, Roadbook-Coverage, Navigation Flows. Kein LLM — rein deterministisch. |
| EVO-02 | Evaluation Agent | Berechnet Quality Scores: Hard Scores (Bug, Roadbook, Structural) + Soft Scores (Performance, UX) + Plugin Scores. Delegiert an Scoring-Module. |
| EVO-03 | Gap Detector | Vergleicht Ist-Scores mit Soll-Targets. Findet Compile Errors, Test Failures, Feature Gaps. Erkennt Regressionen vs. vorheriger Iteration. |
| EVO-04 | Decision Agent | Uebersetzt Gaps in Tasks: bug→fix, feature→implement, structural→refactor. Verarbeitet CEO-Feedback. Eskaliert bei >5 critical Gaps. |
| EVO-05 | Regression Tracker | Analysiert Score-Trends ueber Iterationen: improving/stagnating/declining. Erkennt Loop-Mode-Wechsel. Empfiehlt continue/ceo_review/stop. |
| EVO-06 | Loop Orchestrator | Steuert den gesamten Zyklus. Ruft alle anderen Agents in Reihenfolge auf. Prueft Stop-Bedingungen. Speichert LDO pro Iteration. |

Alle Agents sind deterministisch (model_tier: none) — keine LLM-Aufrufe.

## Loop Data Object (LDO)

Das LDO ist das **einzige Kommunikationsmedium** zwischen allen Agents. Jede Iteration erzeugt ein neues LDO.

### Wichtigste Felder

| Feld | Typ | Beschreibung |
|---|---|---|
| `meta` | LDOMeta | project_id, iteration, timestamp, loop_mode, status |
| `roadbook_targets` | RoadbookTargets | Soll-Werte: bug_score, roadbook_match, structural, performance, ux |
| `build_artifacts` | BuildArtifacts | compile_errors, test_results, warnings, build_log_path |
| `qa_results` | QAResults | test_passed/failed/total, failure_rate, coverage, blocking_issues |
| `simulation_results` | SimulationResults | loc_total, stubs, todos, error_handling_ratio, features_covered |
| `scores` | Scores | Alle berechneten Scores (hard + soft + plugin + aggregate) |
| `gaps` | list[Gap] | Identifizierte Luecken mit severity und Beschreibung |
| `regression_data` | RegressionData | Trend, regressions, mode_recommendation |
| `tasks` | list[Task] | Generierte Verbesserungs-Tasks |
| `ceo_feedback` | CEOFeedback | go/no_go + Issues vom CEO |

### Speicherort

```
factory/evolution_loop/data/{project_id}/iteration_{N}.json
```

Jede Iteration wird als JSON gespeichert. LDOStorage verwaltet Lesen/Schreiben.

### Schema-Validierung

`LDOValidator.validate(ldo)` prueft:
- Alle Pflichtfelder vorhanden
- Scores im Bereich 0-100
- Iteration >= 1
- project_id nicht leer

## Quality Scores

### Hard Scores vs Soft Scores

| Score | Typ | Berechnung | Gewicht (Default) |
|---|---|---|---|
| Bug Score | Hard | 100 - (failed_tests × 5) - (compile_errors × 15) - (warnings × 1) | 30% |
| Roadbook Match | Hard | features × 40% + screens × 30% + flows × 30% | 25% |
| Structural Health | Hard | 4 × 25 Punkte (Architektur, Dependencies, Naming, Code Org) | 20% |
| Performance | Soft | Code-Size + Anti-Patterns + Stubs + Error-Handling (je 25) | 15% |
| UX | Soft | Screen-Coverage + Flow-Completeness + Nav-Depth + Naming (je 25) | 10% |

### Veto-Logik

Scores werden nicht nur gemittelt — es gibt Veto-Regeln:
- **Bug Score < Minimum** (default 60) → Aggregate gedeckelt auf **50**
- **Roadbook/Structural < Minimum** (default 50) → Aggregate gedeckelt auf **60**

Das verhindert, dass eine App mit schweren Bugs trotzdem einen hohen Gesamt-Score bekommt.

### Score Weights pro Projekt-Typ

Definiert in `factory/evolution_loop/config/score_weights.yaml`:

| Typ | Bug | Roadbook | Structural | Performance | UX |
|---|---|---|---|---|---|
| game | 0.25 | 0.20 | 0.15 | 0.25 | 0.15 |
| education | 0.30 | 0.25 | 0.20 | 0.10 | 0.15 |
| utility | 0.30 | 0.25 | 0.20 | 0.15 | 0.10 |
| content | 0.25 | 0.20 | 0.15 | 0.15 | 0.25 |

## Loop-Modi

Der Loop hat 3 Modi mit aufsteigender Eskalation:

```
Sprint ──(stagnating)──► Deep ──(declining)──► Pivot
```

| Modus | Trigger | Max Iterations | Verhalten |
|---|---|---|---|
| **Sprint** | Start / improving | 10 | Schnelle Fixes, nur "fix"-Tasks |
| **Deep** | Stagnation (Score aendert sich <2% ueber 2 Iterationen) | 5 | "fix" Tasks werden zu "refactor" konvertiert |
| **Pivot** | Declining (Scores fallen) | 3 | CEO Review wird erzwungen |

Modi eskalieren nur nach oben (Sprint → Deep → Pivot), nie zurueck.

### Stop-Bedingungen (vereinfacht)

```
Targets met?           → ceo_review (Erfolg!)
Budget erschoepft?     → ceo_review
Mode = Pivot?          → ceo_review (erzwungen)
Max Iterations?        → stop
Regression erkannt?    → stop oder ceo_review
```

## CEO Review Gate

### Ablauf

1. Loop erreicht Stop-Bedingung oder Targets → **CEO Review** wird ausgeloest
2. `HumanReviewProvider` generiert `ceo_review_brief.md` mit:
   - Aktuelle Scores (alle Kategorien)
   - Offene Gaps
   - Bisherige Kosten
   - Feedback-Template
3. CEO liest Brief, testet App, schreibt Feedback als JSON
4. Loop liest `ceo_feedback.json` → bei `no_go`: DecisionAgent erzeugt neue Tasks

### Pfade

```
factory/evolution_loop/data/{project_id}/ceo_review_brief.md    ← generiert
factory/evolution_loop/data/{project_id}/ceo_feedback.json      ← CEO schreibt
```

### CEO-Feedback JSON-Format

```json
{
  "decision": "no_go",
  "issues": [
    {
      "description": "Login-Screen reagiert nicht auf Dark Mode",
      "severity": "major",
      "area": "ux"
    },
    {
      "description": "App crasht beim ersten Start ohne Internet",
      "severity": "blocker",
      "area": "stability"
    }
  ]
}
```

Severity-Mapping: `blocker` → critical Priority, `major` → high, `minor` → medium.

## CLI-Befehle

### Evolution Loop starten

```bash
python main.py --evolution-loop <PROJECT_ID> --project-type game --production-line unity
```

Optionale Flags:
- `--project-type`: game | education | utility | content (Default: utility)
- `--production-line`: ios | android | web | unity (Default: web)

### Status abfragen

```bash
python main.py --evolution-status <PROJECT_ID>
```

Zeigt: aktuelle Iteration, Scores, Loop-Mode, Stop-Reason.

### History anzeigen

```bash
python main.py --evolution-history <PROJECT_ID>
```

Zeigt: alle Iterationen mit Scores, Trends, Mode-Wechsel.

### CEO Review starten

```bash
python main.py --evolution-ceo-review <PROJECT_ID>
```

Generiert CEO Review Brief und wartet auf Feedback-JSON.

## Plugin-System

### Bestehende Plugins

| Plugin | Typ | Prueft |
|---|---|---|
| GameSystemsValidator | game | 5 Systeme (Physics, AI, Inventory, Combat, Progression) je 20 Punkte |
| MechanicsConsistencyChecker | game | Konstanten-Validierung in Game-Dateien |
| DataFlowValidator | business | API-Calls (40) + Validation (30) + Sanitization (30) |

### Neues Plugin erstellen

1. Ordner in `factory/evolution_loop/plugins/` fuer den Typ (z.B. `plugins/education/`)
2. Python-Datei mit Klasse die `EvaluationPlugin` erbt
3. `evaluate(project_path, ldo)` Methode implementieren → return `{"score": float, "confidence": float, "details": dict}`
4. Fertig — `PluginLoader` findet und laedt es automatisch via `_TYPE_TO_DIR` Mapping

```python
from factory.evolution_loop.plugins import EvaluationPlugin

class MyPlugin(EvaluationPlugin):
    name = "my_plugin"

    def evaluate(self, project_path: str, ldo) -> dict:
        # Analyse durchfuehren
        return {"score": 85.0, "confidence": 70.0, "details": {"checks_passed": 17}}
```

**Wichtig**: Plugin-Ordner muss in `PluginLoader._TYPE_TO_DIR` gemappt sein.

## Konfiguration

### Dateien

```
factory/evolution_loop/config/
├── default_config.yaml    ← Loop-Limits, Quality Targets, Confidence Thresholds
├── score_weights.yaml     ← Gewichtungen pro Projekt-Typ
└── config_loader.py       ← EvolutionConfig Klasse (deep-merge)
```

### default_config.yaml — Wichtigste Werte

```yaml
evolution_loop:
  max_iterations: 10
  budget_limit: 5.0          # USD pro Projekt
  stagnation_threshold: 2.0  # Prozent
  stagnation_iterations: 2

quality_targets:
  bug_score: 90
  roadbook_match: 95
  structural_health: 85
  performance: 70
  ux: 70

confidence:
  minimum: 30
  high_threshold: 70
```

### Projekt-spezifisch ueberschreiben

```python
from factory.evolution_loop import EvolutionConfig

config = EvolutionConfig(project_config_path="path/to/my_project_config.yaml")
limits = config.get_loop_limits()
weights = config.get_score_weights("game")
```

Nur die Werte im Override-YAML werden ueberschrieben — alles andere bleibt beim Default (deep-merge).

## Factory Learner

Cross-Project Query-Schicht ueber die LDO-History. Read-only, deterministisch, cached.

### Methoden

| Methode | Beschreibung |
|---|---|
| `list_projects()` | Alle Projekte mit Iterations-Count, letztem Score, Trend |
| `get_project_summary(pid)` | Vollstaendige Zusammenfassung: Scores, Improvement, Gaps, Tasks, Modes, Cost |
| `search_similar_issues(query)` | Substring-Match mit Relevanz-Scoring (100=exakt, 80=substring, 40=category) |
| `get_cross_project_stats()` | Aggregiert: Avg Iterations/Scores/Costs, Gap-Verteilung |
| `get_lessons_for_project_type(type)` | Erkenntnisse pro Typ: typische Mode-Progression, haeufige Gaps |

### Nutzung

```python
from factory.evolution_loop import FactoryLearner

learner = FactoryLearner()
projects = learner.list_projects()
summary = learner.get_project_summary("my_project")
similar = learner.search_similar_issues("crash on startup")
stats = learner.get_cross_project_stats()
```

## Dateistruktur

```
factory/evolution_loop/
├── __init__.py                    ← 37 Exports (Agents, LDO, Config, Scoring, ...)
├── loop_orchestrator.py           ← EVO-06: Haupt-Loop-Steuerung (309 LOC)
├── simulation_agent.py            ← EVO-01: Statische Code-Analyse (525 LOC)
├── evaluation_agent.py            ← EVO-02: Score-Berechnung (102 LOC)
├── gap_detector.py                ← EVO-03: Gap-Erkennung (223 LOC)
├── decision_agent.py              ← EVO-04: Gap→Task Konvertierung (185 LOC)
├── regression_tracker.py          ← EVO-05: Trend-Analyse (311 LOC)
├── factory_learner.py             ← Cross-Project Queries (405 LOC)
├── adapters/
│   ├── orchestrator_handoff.py    ← Build→LDO Adapter (307 LOC)
│   └── qa_to_ldo_adapter.py       ← QA Output→LDO Adapter (473 LOC)
├── config/
│   ├── config_loader.py           ← EvolutionConfig (73 LOC)
│   ├── default_config.yaml
│   └── score_weights.yaml
├── gates/
│   ├── ceo_review_gate.py         ← CEO Review Gate (60 LOC)
│   ├── human_review_provider.py   ← File-basierter Review (190 LOC)
│   └── review_provider.py         ← ABC + ReviewResult (33 LOC)
├── ldo/
│   ├── schema.py                  ← LDO Dataclasses (227 LOC)
│   ├── storage.py                 ← JSON Persistence (67 LOC)
│   └── validator.py               ← Schema-Validierung (120 LOC)
├── plugins/
│   ├── base_plugin.py             ← EvaluationPlugin ABC (28 LOC)
│   ├── plugin_loader.py           ← Dynamic Loader (86 LOC)
│   ├── game/                      ← 2 Game-Plugins (277 LOC)
│   └── business/                  ← 1 Business-Plugin (153 LOC)
├── scoring/
│   ├── hard_scores.py             ← Bug, Roadbook, Structural (210 LOC)
│   ├── soft_scores.py             ← Performance, UX (232 LOC)
│   └── aggregator.py              ← Gewichteter Avg + Veto (190 LOC)
├── tracking/
│   ├── cost_tracker.py            ← Budget-Tracking (90 LOC)
│   └── git_tagger.py              ← Git Tags + Rollback (151 LOC)
├── data/                          ← LDO JSON Files pro Projekt
└── tests/                         ← 15 Test-Dateien
```

## Troubleshooting

| Problem | Loesung |
|---|---|
| "No evolution data found" | Projekt-ID pruefen. Loop muss erst mit `--evolution-loop` gestartet worden sein. |
| Loop stoppt sofort | Scores pruefen — vielleicht sind alle Targets bereits erreicht (→ CEO Review). |
| Loop dreht sich im Kreis | Normal bei Stub-Builds. Mit echten Production Line Builds werden Scores sich aendern. |
| Git Tags fehlen | Git nicht verfuegbar oder kein Repo — Loop laeuft trotzdem, Tags werden uebersprungen. |
| Import Error | `factory/evolution_loop/__init__.py` pruefen — muss 37 Exports haben. |
| Plugin wird nicht geladen | Pruefen: Ordner in `plugins/`, Klasse erbt `EvaluationPlugin`, `_TYPE_TO_DIR` Mapping vorhanden. |
| Score stagniert bei ~50 | Veto-Logik greift — Bug Score oder Structural sind unter Minimum. Diese zuerst fixen. |
| CEO Review Brief leer | LDO hat keine Scores — Evaluation muss vor CEO Review laufen. |
