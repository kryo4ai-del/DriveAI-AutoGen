# ROADBOOK: Evolution Loop System

## DriveAI-AutoGen — DAI-Core.ai

**Version:** 1.0  
**Datum:** 2026-03-28  
**Status:** Approved by CEO  
**Referenz-Benchmark:** Gaming (härtester App-Typ als Design-Maßstab)

---

## Inhaltsverzeichnis

1. [Vision & Zielsystem](#1-vision--zielsystem)
2. [Architektur-Übersicht](#2-architektur-übersicht)
3. [Evolution Loop Department](#3-evolution-loop-department)
4. [Agents](#4-agents)
5. [Loop Data Object (LDO)](#5-loop-data-object-ldo)
6. [Quality Score System](#6-quality-score-system)
7. [Loop-Logik & Modi](#7-loop-logik--modi)
8. [Integration in bestehende Factory](#8-integration-in-bestehende-factory)
9. [Pipeline-Erweiterung](#9-pipeline-erweiterung)
10. [Plugin-System (App-Typ-spezifisch)](#10-plugin-system-app-typ-spezifisch)
11. [CEO Review Gate](#11-ceo-review-gate)
12. [Langfristige Intelligence](#12-langfristige-intelligence)
13. [Ergebniszustände](#13-ergebniszustände)
14. [Kommunikationsregeln](#14-kommunikationsregeln)
15. [Implementierungs-Phasen](#15-implementierungs-phasen)
16. [Konfigurierbare Parameter](#16-konfigurierbare-parameter)
17. [Dateistruktur](#17-dateistruktur)

---

## 1. Vision & Zielsystem

### Vision

DAI-Core.ai ist eine autonome Multi-Agent Factory, die aus einer Idee vollständig funktionsfähige, marktreife Anwendungen generiert und durch einen iterativen Evolution Loop kontinuierlich verbessert, bis sie definierte Qualitätsziele erreicht.

### Zielsystem

- **Transformation:** Von linearer Pipeline (Roadbook → Build → Store) zu iterativem Selbstverbesserungssystem
- **Fokus:** Qualität, Konsistenz und Store-Reife statt nur Code-Generierung
- **Plattformagnostisch:** Der Evolution Loop arbeitet über einheitliche Interfaces mit jeder Production Line (iOS, Android, Web, Unity, Python — und zukünftigen)
- **Human Gate als austauschbares Modul:** An definierten Stellen sitzt heute ein `HumanReviewProvider`. Architektonisch als austauschbarer `ReviewProvider` gebaut — morgen potenziell `AIReviewProvider`. Kein Umbau nötig wenn sich AI-Fähigkeiten ändern.
- **Gaming als Referenz-Benchmark:** Jede Metrik, jeder Agent und jeder Prozess muss für ein Game funktionieren. Wenn es für Gaming funktioniert, funktioniert es für alles.

### Kern-Shift

```
VORHER (linear):
  Roadbook → Build → Assembly → Test → Store

NACHHER (iterativ):
  Roadbook → Build → Assembly → QA → [Evolution Loop ↔ Factory] → CEO Review → Store
```

---

## 2. Architektur-Übersicht

```
                        ┌──────────────┐
                        │     CEO      │
                        │  (Human/AI)  │
                        └──────┬───────┘
                               │ GO/NO-GO + strukturiertes Feedback
                               │
                        ┌──────┴───────┐
                        │  CEO Review  │
                        │    Gate      │
                        └──────┬───────┘
                               │
                        ┌──────┴───────┐
                        │  Evolution   │  ← Department mit Orchestrator-Privileg
                        │    Loop      │
                        │  Department  │
                        └──────┬───────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
       ┌──────┴──────┐ ┌──────┴──────┐ ┌───────┴──────┐
       │ Bestehender │ │  QA Forge   │ │   TheBrain   │
       │ Orchestrator│ │(Datenzulief.)│ │(Model Route) │
       └──────┬──────┘ └─────────────┘ └──────────────┘
              │
    ┌─────┬──┴──┬──────┬───────┐
    │     │     │      │       │
   iOS  Android Web  Unity  Python   ← Production Lines
```

### Positionierung

Der Evolution Loop ist architektonisch ein **Department** (eigener Ordner, eigene Agents, eigene Config), aber funktional eine **Steuerungsebene**:

- **Über** den Production Lines
- **Unter** dem CEO / Creative Director
- Darf Build-Zyklen auslösen, QA triggern, Assembly anstoßen
- Darf **keine** strategischen Entscheidungen treffen (das bleibt beim CEO/CD)

---

## 3. Evolution Loop Department

### Einordnung

| Eigenschaft | Wert |
|---|---|
| Department Name | `evolution_loop` |
| Ordner | `factory/evolution_loop/` |
| Agents | 6 |
| Typ | Factory-Level Control Loop |
| Privileg | Orchestrator-Privileg (darf andere Departments triggern) |
| Kommunikation | Ausschließlich über LDO (kein Agent-zu-Agent Chat) |

### Abgrenzung

| Verantwortung | Zuständig |
|---|---|
| Code bauen | Bestehender Orchestrator + Factory |
| Technische Tests | QA Forge (bestehend) |
| Qualität bewerten | Evolution Loop |
| Strategische Entscheidungen | CEO / Creative Director |
| Model Routing | TheBrain (bestehend) |

---

## 4. Agents

### 4.1 loop_orchestrator

| Eigenschaft | Wert |
|---|---|
| Agent-ID | `evo_loop_orchestrator` |
| TheBrain Tier | Tier 2 (Reasoning) |
| Rolle | Dirigent des Evolution Loops |

**Aufgaben:**
- Steuert den Zyklus und ruft Agents in korrekter Reihenfolge auf
- Zählt Iterationen, prüft Stop-Bedingungen
- Entscheidet ob nächste Runde, Modus-Wechsel oder Eskalation
- Einziger Agent der andere Loop-Agents aufrufen darf
- Führt Kosten-Tracking pro Loop-Durchlauf
- Kein eigenes Urteil über Qualität — nur Prozesssteuerung

### 4.2 simulation_agent

| Eigenschaft | Wert |
|---|---|
| Agent-ID | `evo_simulation` |
| TheBrain Tier | Tier 1 (Code) |
| Rolle | Analysiert Build-Artefakte |

**Aufgaben:**
- Statische Analyse: Code-Struktur, Dependency-Check, Dead Code, fehlende Error Handling
- Roadbook-Abgleich: sind alle definierten Features im Code vorhanden?
- Synthetische User Flows: definiert Szenarien und prüft ob Code-Pfade existieren und logisch funktionieren
- Liest QA Forge Ergebnisse aus dem LDO als zusätzliche Datenbasis
- Lädt App-Typ-spezifische Plugins (siehe Kapitel 10)

**Kann NICHT (heute):**
- Echte Runtime-Performance messen
- Echte UX bewerten
- Gameplay-Feel beurteilen
- → Diese Punkte sind Human ReviewProvider Aufgaben

### 4.3 evaluation_agent

| Eigenschaft | Wert |
|---|---|
| Agent-ID | `evo_evaluation` |
| TheBrain Tier | Tier 3 (Lightweight) |
| Rolle | Berechnet Quality Scores |

**Aufgaben:**
- Nimmt Simulation-Ergebnisse und Roadbook-Ziele
- Berechnet alle Quality Scores (Hard + Soft)
- Ermittelt Confidence Level pro Score
- Erzeugt Score-Report ins LDO
- Rein analytisch — kein Urteil über "was tun"

### 4.4 gap_detector

| Eigenschaft | Wert |
|---|---|
| Agent-ID | `evo_gap_detector` |
| TheBrain Tier | Tier 1 (Code) |
| Rolle | Identifiziert Abweichungen |

**Aufgaben:**
- Nimmt Score-Report, vergleicht Soll vs Ist
- Identifiziert konkrete Lücken: was fehlt, was ist kaputt, was weicht ab
- Priorisiert Gaps nach Severity (Critical, High, Medium, Low)
- Nutzt Regression Tracker Daten um Regressionen zu erkennen
- Output: priorisierte Gap-Liste ins LDO

### 4.5 decision_agent

| Eigenschaft | Wert |
|---|---|
| Agent-ID | `evo_decision` |
| TheBrain Tier | Tier 2 (Reasoning) |
| Rolle | Übersetzt Probleme in Lösungen |

**Aufgaben:**
- Nimmt Gap-Liste, erzeugt konkrete, ausführbare Tasks für die Factory
- Übersetzt CEO-Feedback in Tasks
- Entscheidet: kann die Factory das selbst lösen oder muss eskaliert werden?
- Im Deep Loop: erzeugt Refactoring-Pläne statt einzelner Fix-Tasks
- Übersetzungsschicht zwischen "Problem erkannt" und "Lösung implementieren"

### 4.6 regression_tracker

| Eigenschaft | Wert |
|---|---|
| Agent-ID | `evo_regression_tracker` |
| TheBrain Tier | Tier 3 (Lightweight) |
| Rolle | Hüter der Iterations-History |

**Aufgaben:**
- Speichert den Zustand jeder Iteration (komplettes LDO-Snapshot)
- Vergleicht Iteration N mit N-1 und mit Gesamttrend
- Erkennt Muster ("jede zweite Iteration bricht Feature X")
- Erkennt Stagnation (Scores verbessern sich nicht mehr)
- Erkennt Regression (Scores verschlechtern sich)
- **Entscheidet autonom ob Loop weiterläuft oder CEO-Review ausgelöst wird**
- CEO wird nur involviert bei: Target erreicht / Stagnation / Max Iterations / Budget-Überschreitung

### Agent-Interaktion (sequentiell, kein Chat)

```
Loop Orchestrator startet Iteration N
  │
  ├→ Simulation Agent analysiert Build-Artefakt
  │   └→ schreibt simulation_results ins LDO
  │
  ├→ Evaluation Agent berechnet Scores
  │   └→ schreibt scores ins LDO
  │
  ├→ Gap Detector findet Lücken
  │   └→ schreibt gaps ins LDO
  │
  ├→ Regression Tracker vergleicht mit History
  │   └→ schreibt regression_data ins LDO
  │   └→ Empfehlung: CONTINUE / CEO_REVIEW / STOP
  │
  ├→ Decision Agent (wenn CONTINUE)
  │   └→ schreibt tasks ins LDO
  │   └→ Tasks gehen an bestehenden Orchestrator → Factory
  │
  └→ Loop Orchestrator prüft: nächste Runde oder Stop?
```

---

## 5. Loop Data Object (LDO)

### Zweck

Einziges Kommunikationsmedium zwischen allen Agents. Kein Agent redet mit einem anderen Agent. Sie lesen aus dem LDO und schreiben ins LDO.

### Struktur

```json
{
  "meta": {
    "project_id": "string",
    "project_type": "game | business_app | utility | social | ...",
    "production_line": "ios | android | web | unity | python",
    "iteration": 0,
    "loop_mode": "sprint | deep | pivot",
    "timestamp": "ISO-8601",
    "accumulated_cost": 0.00,
    "git_tag": "evolution/iteration-N"
  },
  
  "roadbook_targets": {
    "features": [],
    "screens": [],
    "user_flows": [],
    "quality_thresholds": {},
    "score_weights": {}
  },
  
  "build_artifacts": {
    "paths": [],
    "compile_status": "success | failed",
    "platform_details": {}
  },
  
  "qa_results": {
    "tests_passed": 0,
    "tests_failed": 0,
    "test_details": [],
    "compile_errors": [],
    "warnings": []
  },
  
  "simulation_results": {
    "static_analysis": {},
    "roadbook_coverage": {},
    "synthetic_flows": [],
    "plugin_results": {}
  },
  
  "scores": {
    "bug_score": { "value": 0, "confidence": 0 },
    "roadbook_match_score": { "value": 0, "confidence": 0 },
    "structural_health_score": { "value": 0, "confidence": 0 },
    "performance_score": { "value": 0, "confidence": 0 },
    "ux_score": { "value": 0, "confidence": 0 },
    "plugin_scores": {},
    "quality_score_aggregate": 0
  },
  
  "gaps": [
    {
      "id": "GAP-001",
      "category": "bug | feature | performance | ux | structural",
      "severity": "critical | high | medium | low",
      "description": "",
      "affected_component": "",
      "is_regression": false,
      "first_seen_iteration": 0
    }
  ],
  
  "regression_data": {
    "trend": "improving | stagnating | declining",
    "iterations_without_improvement": 0,
    "regressions_detected": [],
    "recommendation": "continue | ceo_review | stop",
    "comparison_to_previous": {}
  },
  
  "tasks": [
    {
      "id": "TASK-001",
      "type": "fix | refactor | implement | remove",
      "description": "",
      "target_component": "",
      "originated_from": "gap_id | ceo_feedback",
      "priority": "critical | high | medium | low"
    }
  ],
  
  "ceo_feedback": {
    "status": "pending | go | no_go",
    "issues": [
      {
        "category": "bug | ux | performance | content | feel",
        "severity": "blocker | major | minor",
        "description": "",
        "resolved": false
      }
    ]
  }
}
```

### Prinzipien

- Jeder Agent hat ein **definiertes Input-Schema** (was er liest) und **Output-Schema** (was er schreibt)
- Output der nicht dem Schema entspricht → Fehler, nicht "naja passt schon"
- LDO wird pro Iteration als JSON gespeichert + Git-committed
- Komplette LDO-History ist Grundlage für Regression Tracking und langfristiges Lernen

---

## 6. Quality Score System

### Zwei Kategorien

#### Hard Scores (automatisch, objektiv, verlässlich)

| Score | Beschreibung | Datenquelle | Confidence |
|---|---|---|---|
| Bug Score | Compile Errors, Test Failures, Crash-Pfade, Dead Code, fehlende Error Handling | QA Forge + Statische Analyse | 90-100% |
| Roadbook Match Score | Sind alle Features, Screens, User Flows implementiert? | Roadbook-Abgleich | 90-100% |
| Structural Health Score | Code-Qualität, Architecture Compliance, Dependency Hygiene, Pattern-Konformität | Statische Analyse | 85-95% |

#### Soft Scores (geschätzt, perspektivisch Human oder Advanced AI)

| Score | Beschreibung | Datenquelle heute | Confidence heute |
|---|---|---|---|
| Performance Score | Bundle Size, Algorithmic Complexity, Anti-Patterns | Statische Heuristik | 40-60% |
| UX Score | Navigation Depth, Consistency, Accessibility-Basics | Statische Heuristik | 30-50% |
| Plugin Scores | App-Typ-spezifisch (z.B. Game Balance, Progression Flow) | Plugin-Analyse | 30-60% |

### Aggregation

**Quality Score = gewichteter Durchschnitt mit Hard Score Veto**

```
Regel 1: Hard Scores haben Veto-Recht
  → Bug Score < Threshold → Quality Score kann NICHT "gut" sein
  → Egal wie toll die Soft Scores aussehen

Regel 2: Gewichtung konfigurierbar pro Projekt-Typ
  → Business App: Roadbook Match höher gewichtet
  → Game: Performance + UX + Plugin Scores höher gewichtet
  → Gewichtung wird im Roadbook des jeweiligen Projekts definiert

Regel 3: Confidence Level steuert Entscheidungen
  → Soft Score mit Confidence < 50% → CEO sollte draufschauen
  → Soft Score mit Confidence > 80% → kann automatisch entschieden werden
```

---

## 7. Loop-Logik & Modi

### Drei Loop-Modi

#### Modus 1 — Sprint Loop (schnelle Fixes)

| Eigenschaft | Wert |
|---|---|
| Auslöser | Kleine Gaps, hoher Confidence, klare Tasks |
| Typische Tasks | Bug Fixes, fehlende Error Handler, Missing Features |
| Max Iterationen | 10 |
| CEO nötig | Nein (solange Scores steigen) |
| Typische Dauer | 2-5 Iterationen |

#### Modus 2 — Deep Loop (strukturelle Probleme)

| Eigenschaft | Wert |
|---|---|
| Auslöser | Sprint Loop löst Problem nicht, Architektur-Issues, persistente Performance-Probleme |
| Typische Tasks | Refactoring-Pläne, Architektur-Änderungen |
| Max Iterationen | 5 |
| CEO nötig | Nur bei Timeout |
| Erkennung | Automatisch wenn Sprint-Iterationen Score nicht verbessern |

#### Modus 3 — Pivot Loop (fundamentale Probleme)

| Eigenschaft | Wert |
|---|---|
| Auslöser | Loop dreht sich im Kreis, Fixes erzeugen neue Probleme |
| Aktion | Sofortige CEO-Eskalation mit komplettem LDO-History-Report |
| Max Iterationen | 0 (sofortiger Stop) |
| CEO nötig | Ja, immer |
| CEO entscheidet | Neuer Ansatz / Scope reduzieren / Feature streichen |

### Entscheidungsbaum pro Iteration

```
Iteration N abgeschlossen
  │
  ├→ Regression Tracker analysiert Trend
  │   │
  │   ├→ Scores verbessern sich
  │   │   └→ Sprint Loop weiter
  │   │
  │   ├→ Scores stagnieren seit 2+ Iterationen
  │   │   ├→ Hard Score Probleme? → Deep Loop
  │   │   └→ Soft Score Probleme? → CEO Review (Confidence zu niedrig)
  │   │
  │   └→ Scores verschlechtern sich
  │       ├→ Regression nur in letzter Iteration?
  │       │   └→ Rollback zu N-1, dann Deep Loop
  │       └→ Regression über mehrere Iterationen?
  │           └→ Pivot Loop → CEO Eskalation
  │
  └→ Quality Target Check
      │
      ├→ Alle Hard Scores über Threshold?
      │   ├→ Alle Soft Scores über Threshold ODER Confidence hoch genug?
      │   │   └→ JA → CEO Review Gate → Store
      │   └→ NEIN → CEO Review für Soft Score Validierung
      │
      └→ Hard Scores unter Threshold → Loop weiter
```

### Sicherheitsmechanismen

| Mechanismus | Wert |
|---|---|
| Stagnation Threshold | 2 aufeinanderfolgende Iterationen ohne Score-Verbesserung > 2% |
| Regression Threshold | Jeder Score-Rückgang > 5% in einer Iteration |
| Sprint Loop Max | 10 Iterationen |
| Deep Loop Max | 5 Iterationen |
| Gesamt-Maximum | 20 Iterationen absolute Obergrenze |
| Kosten-Bremse | Akkumulierte Kosten > Budget-Threshold → Zwangs-Pause + CEO-Report |

### Rollback-Fähigkeit

Jede Iteration speichert:
- Komplettes LDO als JSON
- Git Tag: `evolution/{project_id}/iteration-{N}`
- Kompletter Build-Stand im Git

Rollback jederzeit möglich zu jeder früheren Iteration. Bei Regression: automatischer Rollback zu letztem stabilen Stand, dann alternativer Ansatz.

### Kosten-Tracking

Der Loop Orchestrator führt ein Kosten-Log pro Iteration:
- Token-Kosten aller Agent-Calls
- Akkumulierte Gesamtkosten des Loops
- Bei Budget-Überschreitung: CEO-Report mit Kosten/Nutzen-Analyse
- Format: "Bisher $X ausgegeben, Score von Y auf Z gestiegen, geschätzte Kosten bis Target: $W"

---

## 8. Integration in bestehende Factory

### Vier Integrationspunkte

#### Punkt 1 — Orchestrator-Handoff

```
Bestehender Orchestrator (baut)
  → Roadbook → Build Plan → Factory → Assembly → QA
  → HANDOFF an Loop Orchestrator
                    ↓
             Loop Orchestrator (bewertet)
               → Simulation → Evaluation → Gaps → Decision
                    ↓
             Tasks zurück an bestehenden Orchestrator
               → Factory baut → Assembly → QA
               → HANDOFF zurück an Loop
```

- Bestehender Orchestrator: Chef für Build/Assembly/QA
- Loop Orchestrator: Chef für Bewertung/Iteration
- Klare Zuständigkeit, kein Überlappen
- Loop Orchestrator ruft **nie** direkt Assembly oder Code Generation auf

#### Punkt 2 — QA Forge als Datenschnittstelle

- QA Forge bleibt exakt wie sie ist — keine Änderung
- Einzige Ergänzung: `qa_to_ldo_adapter` schreibt QA-Ergebnisse ins LDO
- QA Forge weiß nicht mal dass der Evolution Loop existiert

#### Punkt 3 — Repair Pipeline

- Bestehende 3-Tier Repair (deterministisch → LLM → CEO) bleibt für Build-Fehler
- Evolution Loop nutzt sie nicht direkt
- Wenn Loop-Tasks Build-Fehler verursachen, greift Repair automatisch
- Keine Änderung nötig

#### Punkt 4 — TheBrain Model Routing

- Alle 6 Evolution Loop Agents werden bei TheBrain registriert
- Model-Zuweisung via `get_model_for_agent(agent_id)`
- Keine hardcoded Models, keine Sonderwege

| Agent | Erwarteter Tier |
|---|---|
| evo_loop_orchestrator | Tier 2 (Reasoning) |
| evo_simulation | Tier 1 (Code) |
| evo_evaluation | Tier 3 (Lightweight) |
| evo_gap_detector | Tier 1 (Code) |
| evo_decision | Tier 2 (Reasoning) |
| evo_regression_tracker | Tier 3 (Lightweight) |

### Was sich NICHT ändert

- `main.py` Einstiegspunkt (nur neues Flag `--evolution-loop`)
- Factory Folder-Struktur (neuer Ordner ergänzt, nichts umgebaut)
- Config-System (neue Agent-Rollen ergänzt)
- Production Lines — keinerlei Änderung
- Build / Assembly / Signing / Store — keinerlei Änderung
- Mac Bridge — keinerlei Änderung
- **Bestehende 307 Python Files bleiben unangetastet**

---

## 9. Pipeline-Erweiterung

### Bisheriger Flow

```
Roadbook → Creative Director → Build → Assembly → QA → Store
```

### Neuer Flow

```
Roadbook → Creative Director → Build → Assembly → QA
  → Evolution Loop (N Iterationen autonom)
    → CEO Review Gate (strukturiertes Feedback)
      → GO → Store Pipeline → Submission
      → NO-GO → Tasks → zurück in Evolution Loop
```

### Abgrenzung QA vs Evolution Loop

| Aspekt | QA Forge (bestehend) | Evolution Loop (neu) |
|---|---|---|
| Prüft | Einzelnen Build | Produkt als Ganzes |
| Gegen | Technische Korrektheit | Roadbook-Ziele + Qualität |
| Perspektive | "Kompiliert es? Laufen Tests?" | "Ist es gut genug für den Store?" |
| Rolle | Gate-Keeper pro Build | Qualitäts-Treiber über Iterationen |
| Beziehung | Datenzulieferer an Loop | Nutzt QA-Daten als Input |

---

## 10. Plugin-System (App-Typ-spezifisch)

### Konzept

Der Evolution Loop bleibt generisch. Evaluation Agent und Simulation Agent laden **Plugins** basierend auf dem `project_type` im Roadbook. Keine Sonderwege, keine eigenen Departments pro App-Typ.

### Plugin-Loading

```
Roadbook definiert: project_type = "game"
  → Evaluation Agent lädt:
      - Standard-Module (Bug, Roadbook Match, Structural Health)
      - game_systems_validator
      - world_consistency_checker
      - mechanics_consistency_checker
      - player_flow_analyzer

Roadbook definiert: project_type = "business_app"
  → Evaluation Agent lädt:
      - Standard-Module (Bug, Roadbook Match, Structural Health)
      - data_flow_validator
      - auth_permission_checker
```

### Game-Plugins

| Plugin | Prüft | Methode |
|---|---|---|
| game_systems_validator | Game Loop, State Management, Save/Load, Level Transitions, Input Handling | Statische Code-Analyse |
| world_consistency_checker | Welt-Konsistenz, referenzierte Items, Räume ohne Ausgang, ungültige Spawns | Code-Analyse + Datenvalidierung |
| mechanics_consistency_checker | Mathematische Konsistenz von Damage/Health/Cooldowns, Difficulty Curve, Boss-Besiegbarkeit | Mathematische Analyse |
| player_flow_analyzer | Tutorial-Flow, Complexity-Einführung, Sackgassen, Progression | Flow-Graph-Analyse |

### Was Plugins NICHT können (heute)

- Steuerung fühlen → Human ReviewProvider
- Spaß bewerten → Human ReviewProvider
- Schwierigkeitsgrad subjektiv einschätzen → Human ReviewProvider
- Pacing beurteilen → Human ReviewProvider

→ Bei Games ist das CEO Review Gate besonders kritisch und quasi Pflicht.

### Zukunftssicherheit

Neuer App-Typ = neue Plugins registrieren. Kein Umbau am Evolution Loop. Beispiele:
- IoT App → `device_communication_checker`, `protocol_validator`
- AR App → `spatial_consistency_checker`, `anchor_validator`
- AI-Gameplay-Evaluator in der Zukunft → ersetzt statische Game-Plugins

---

## 11. CEO Review Gate

### Konzept

Letzter Checkpoint vor Store Submission. Nicht nur GO/NO-GO sondern **GO mit strukturiertem Feedback**.

### Ablauf

```
1. Loop Orchestrator triggert CEO Review
   → Reason: Quality Target erreicht / Stagnation / Max Iterations / Budget

2. CEO erhält:
   → Aktuelle App (Build-Artefakt)
   → Score-Report (alle Scores + Confidence)
   → Gap-Report (offene Gaps wenn vorhanden)
   → Iterations-History (Trend-Übersicht)
   → Kosten-Report

3. CEO testet die App

4. CEO gibt strukturiertes Feedback:
   → Kategorie: Bug | UX | Performance | Content | Feel
   → Severity: Blocker | Major | Minor
   → Beschreibung: Freitext

5. Decision Agent übersetzt Feedback in Tasks

6. Ergebnis:
   → GO → Store Pipeline
   → NO-GO → Tasks ins LDO → zurück in Evolution Loop
```

### Strukturiertes Feedback-Feld

```
CEO Feedback Eingabe:
  ├── Kategorie (Pflicht): Bug | UX | Performance | Content | Feel
  ├── Severity (Pflicht):  Blocker | Major | Minor  
  ├── Beschreibung (Pflicht): Was ist das Problem?
  ├── Wo (Optional): In welchem Screen/Feature/Level?
  └── Erwartung (Optional): Was hätte passieren sollen?
```

### Architektur

- CEO Review Gate ist ein austauschbarer `ReviewProvider`
- Heute: `HumanReviewProvider` (CEO testet manuell)
- Morgen: `AIReviewProvider` (AI mit Screen Recording Analysis)
- Interface bleibt gleich, Implementation austauschbar

---

## 12. Langfristige Intelligence

### Drei Stufen

#### Stufe 1 — Project Memory (kommt mit dem Loop geschenkt)

- Jedes Projekt hat komplette LDO-History
- Alle Iterationen, Scores, Gaps, Tasks, CEO-Feedbacks
- Fällt automatisch ab, kein extra Aufwand
- **Nutzen:** "Gleiches Problem wie bei AskFin" → Decision Agent durchsucht AskFin LDO-History

#### Stufe 2 — Cross-Project Pattern Database (nach 3-5 Projekten)

Neuer Agent: **factory_learner** (außerhalb des Evolution Loops)

- Analysiert nach Projektabschluss die gesamte LDO-History
- Extrahiert statistische Patterns:
  - "Swift-Projekte haben in 80% Navigation-Stack Probleme in Iteration 1-3"
  - "Games brauchen im Schnitt 12 Iterationen, Business Apps nur 6"
  - "CEO-Feedback enthält in 70% UX-Probleme die der statische Check nicht fand"
- Speichert Patterns als **Factory Knowledge Entries** (FK-023, FK-024, ...)
- Nutzt bestehendes Factory Knowledge System (FK-001 bis FK-022)

#### Stufe 3 — Predictive Optimization (nach 8-10 Projekten)

Patterns fließen zurück in den Loop als Priorisierungshilfe:

- **Gap Detector:** "Bei Unity Games tauchen Performance-Probleme typischerweise in Iteration 4-6 auf" → prüft dort genauer
- **Decision Agent:** "Dieser Bug-Typ wurde in 3 Projekten durch Approach X gelöst" → schlägt bewährten Fix vor
- **Loop Orchestrator:** "Projekte mit diesem Score-Profil brauchen typischerweise noch 5 Iterationen" → realistische CEO-Schätzung

### Wichtig

Das ist **kein** selbstmodifizierendes System. Die Factory ändert nicht ihren eigenen Code. Sie sammelt Wissen und nutzt es für bessere Entscheidungen. Nachvollziehbar und korrigierbar.

---

## 13. Ergebniszustände

### Drei messbare Zustände

#### Zustand 1 — Loop Complete

| Kriterium | Threshold |
|---|---|
| Bug Score | ≥ 90 |
| Roadbook Match Score | ≥ 95 |
| Structural Health Score | ≥ 85 |
| Offene Critical/High Gaps | 0 |
| Regression Tracker Trend | Stabil oder steigend |

**Verantwortung:** Evolution Loop

#### Zustand 2 — CEO Approved

| Kriterium | Bedingung |
|---|---|
| CEO Review Gate Status | GO |
| CEO-Feedback Tasks | Alle RESOLVED |
| Offene Blocker aus CEO-Feedback | 0 |

**Verantwortung:** CEO (Human)

#### Zustand 3 — Store Ready

| Kriterium | Bedingung |
|---|---|
| Store Metadata | Komplett (Screenshots, Description, Keywords) |
| Privacy Labels | Korrekt |
| Signing Credentials | Vorhanden und gültig |
| Bundle/Package | Korrekt gebaut |
| Plattform Requirements | Erfüllt (z.B. App Icon, Target SDK) |
| Store Compliance Check | Bestanden |

**Verantwortung:** Bestehende Store Pipeline

### CEO-Touchpoints pro Projekt (reduziert)

| Touchpoint | Wann | Typ |
|---|---|---|
| Initiales GO | Nach Roadbook | Bestehend |
| CEO Review Gate | Nach Loop Complete | Neu (strukturiert) |
| Eskalation | Bei Pivot Loop / Budget | Ausnahmefall |

**Von ~20 manuellen Eingriffen auf 2-3 pro Projekt.**

---

## 14. Kommunikationsregeln

### Die drei eisernen Regeln

Aus der Erfahrung der Factory: unkontrollierter Agent-Chat hat Builds von 4 Minuten auf 4 Stunden aufgebläht und Kosten von $0.08 auf $63 getrieben. Das darf im Evolution Loop nicht passieren.

#### Regel 1 — LDO-Only

Jeder Agent liest aus dem LDO was er braucht und schreibt seinen Output ins LDO. **Keine direkten Agent-zu-Agent Calls.** Keine SelectorGroupChat-Diskussionen. Kein Hin-und-Her.

#### Regel 2 — Strict Schema

Jeder Agent hat ein definiertes Input-Schema und Output-Schema. Output der nicht dem Schema entspricht → **Fehler**, nicht "naja passt schon". Schema Violations werden geloggt und dem Loop Orchestrator gemeldet.

#### Regel 3 — Single Dispatcher

**Nur der Loop Orchestrator ruft Agents auf.** Kein Agent darf einen anderen Agent triggern. Der Orchestrator ruft Agent A auf, wartet auf Output, ruft Agent B auf, wartet auf Output. Sequentiell, vorhersagbar, keine Überraschungen.

---

## 15. Implementierungs-Phasen

### Phase 1 — Foundation

| Task | Beschreibung |
|---|---|
| Department Ordner | `factory/evolution_loop/` anlegen |
| LDO Schema | JSON Schema definieren und validieren |
| Loop Orchestrator | Basis-Implementierung (Iteration Count, Stop-Conditions) |
| Decision Agent | Basis-Implementierung (Gap → Task Übersetzung) |
| TheBrain Registration | 6 neue Agent-IDs registrieren |
| Orchestrator Handoff | Handoff-Logik im bestehenden Orchestrator |
| QA-to-LDO Adapter | QA Forge Output → LDO Schema |

### Phase 2 — Core Loop

| Task | Beschreibung |
|---|---|
| Evaluation Agent | Score-Berechnung (Hard Scores zuerst) |
| Gap Detector | Soll/Ist Vergleich, Gap-Priorisierung |
| Erster Loop | Build → Evaluate → Gaps → Tasks → Rebuild funktioniert |
| Scoring | Hard Scores implementiert, Soft Scores als Platzhalter |

### Phase 3 — Simulation & Regression

| Task | Beschreibung |
|---|---|
| Simulation Agent | Statische Analyse, synthetische Flows |
| Regression Tracker | Iterations-History, Trend-Erkennung, Stagnation Detection |
| Loop Modi | Sprint/Deep/Pivot Modus-Erkennung |
| Rollback | Git-Tag System pro Iteration |
| Kosten-Tracking | Budget-Monitoring und CEO-Report |
| CEO Review Gate | Strukturiertes Feedback-System |

### Phase 4 — Plugins & Intelligence

| Task | Beschreibung |
|---|---|
| Plugin-System | Plugin-Loading basierend auf project_type |
| Game-Plugins | 4 Game Evaluation Plugins |
| Soft Scores | Performance + UX Heuristiken verfeinern |
| factory_learner | Cross-Project Pattern Extraction (nach 3-5 Projekten) |
| Predictive Optimization | Pattern-gestützte Entscheidungen (nach 8-10 Projekten) |

---

## 16. Konfigurierbare Parameter

Alle Werte sind Defaults und können pro Projekt im Roadbook überschrieben werden.

### Loop-Limits

```yaml
evolution_loop:
  sprint_max_iterations: 10
  deep_max_iterations: 5
  total_max_iterations: 20
  stagnation_threshold_percent: 2
  stagnation_iterations: 2
  regression_threshold_percent: 5
  budget_threshold_usd: 5.00
```

### Quality Targets

```yaml
quality_targets:
  bug_score_min: 90
  roadbook_match_min: 95
  structural_health_min: 85
  performance_score_min: 70
  ux_score_min: 70
  quality_score_aggregate_min: 85
```

### Score-Gewichtung (Beispiel: Game)

```yaml
score_weights:
  game:
    bug_score: 0.20
    roadbook_match: 0.15
    structural_health: 0.15
    performance_score: 0.25
    ux_score: 0.15
    plugin_scores: 0.10
  business_app:
    bug_score: 0.25
    roadbook_match: 0.30
    structural_health: 0.20
    performance_score: 0.10
    ux_score: 0.15
    plugin_scores: 0.00
```

### Confidence Thresholds

```yaml
confidence:
  auto_decision_min: 80
  ceo_review_trigger: 50
```

---

## 17. Dateistruktur

```
factory/evolution_loop/
├── __init__.py
├── loop_orchestrator.py          # Dirigent, Iteration Control, Stop-Conditions
├── simulation_agent.py           # Statische Analyse, synthetische Flows
├── evaluation_agent.py           # Score-Berechnung
├── gap_detector.py               # Soll/Ist Vergleich, Gap-Priorisierung
├── decision_agent.py             # Gap → Task Übersetzung, Eskalationslogik
├── regression_tracker.py         # Iterations-History, Trend, Stagnation
├── ldo/
│   ├── __init__.py
│   ├── schema.py                 # LDO JSON Schema Definition
│   ├── validator.py              # Schema Validation
│   └── storage.py                # LDO Persistence (JSON + Git)
├── scoring/
│   ├── __init__.py
│   ├── hard_scores.py            # Bug, Roadbook Match, Structural Health
│   ├── soft_scores.py            # Performance, UX Heuristiken
│   └── aggregator.py             # Gewichteter Aggregate Score + Veto-Logik
├── plugins/
│   ├── __init__.py
│   ├── plugin_loader.py          # Lädt Plugins basierend auf project_type
│   ├── game/
│   │   ├── __init__.py
│   │   ├── game_systems_validator.py
│   │   ├── world_consistency_checker.py
│   │   ├── mechanics_consistency_checker.py
│   │   └── player_flow_analyzer.py
│   └── business/
│       ├── __init__.py
│       ├── data_flow_validator.py
│       └── auth_permission_checker.py
├── gates/
│   ├── __init__.py
│   ├── ceo_review_gate.py        # CEO Review mit strukturiertem Feedback
│   └── review_provider.py        # Interface: HumanReviewProvider / AIReviewProvider
├── adapters/
│   ├── __init__.py
│   ├── qa_to_ldo_adapter.py      # QA Forge Output → LDO
│   └── orchestrator_handoff.py   # Handoff-Logik zum bestehenden Orchestrator
├── tracking/
│   ├── __init__.py
│   ├── cost_tracker.py           # Kosten-Monitoring pro Iteration
│   └── git_tagger.py             # Git Tags pro Iteration
└── config/
    ├── default_config.yaml       # Default Loop-Parameter
    └── score_weights.yaml        # Default Score-Gewichtungen
```

### Integration in bestehende Struktur

```
factory/
├── evolution_loop/               # ← NEU (siehe oben)
├── pipeline/                     # Bestehend — unverändert
├── orchestrator/                 # Bestehend — nur Handoff-Logik ergänzt
├── brain/                        # Bestehend — nur neue Agent-IDs registriert
├── qa/                           # Bestehend — unverändert
├── qa_forge/                     # Bestehend — unverändert
├── assembly/                     # Bestehend — unverändert
├── ...                           # Alles andere — unverändert
```

---

## Anhang: Glossar

| Begriff | Bedeutung |
|---|---|
| LDO | Loop Data Object — einziges Kommunikationsmedium im Evolution Loop |
| Hard Score | Objektiv messbarer Quality Score (Bug, Roadbook Match, Structural Health) |
| Soft Score | Heuristik-basierter Score (Performance, UX) mit Confidence Level |
| Sprint Loop | Schnelle Fix-Iterationen für kleine Gaps |
| Deep Loop | Strukturelle Refactoring-Iterationen |
| Pivot Loop | Fundamentale Probleme → CEO-Eskalation |
| ReviewProvider | Austauschbares Interface für Reviews (heute Human, morgen AI) |
| Quality Floor | Minimaler Quality Score den kein Projekt unterschreiten darf |
| factory_learner | Agent der Cross-Project Patterns extrahiert (Phase 4) |
| FK-Entry | Factory Knowledge Entry — gespeichertes Projektwissen |

---

*Dieses Roadbook ist die verbindliche Referenz für die Implementierung des Evolution Loop Systems in der DriveAI-AutoGen Factory.*
