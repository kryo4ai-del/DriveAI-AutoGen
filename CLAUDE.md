# DriveAI-AutoGen - Projektkontext

## Projektübersicht
- **Name**: DriveAI-AutoGen (Multi-Platform AI App Factory + TheBrain)
- **Typ**: Multi-Agent AI System (Python) + iOS/Android/Web App Generation
- **Repo**: GitHub `kryo4ai-del/DriveAI-AutoGen`
- **Lokal Windows**: `C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\`
- **Lokal Mac**: `/Users/andreasott/DriveAI-AutoGen/`
- **Besitzer**: Andreas Ott

## Tech-Stack
- **LLM Provider**: Anthropic Claude (100% — kein OpenAI mehr)
- **Modelle**: claude-sonnet-4-6 (Tier 1+2), claude-haiku-4-5 (Tier 3)
- **Premium**: claude-opus-4-6 (bei Bedarf)
- **Framework**: Python + AutoGen AgentChat v0.4+
- **API Key**: `ANTHROPIC_API_KEY` in `.env`

## 3-Tier Modell-System
| Tier | Modell | Aufgaben |
|---|---|---|
| 1 (Code) | claude-sonnet-4-6 | code_generation, architecture, code_review, bug_hunting, refactoring, test_generation |
| 2 (Reasoning) | claude-sonnet-4-6 | planning, orchestration, content, compliance, accessibility |
| 3 (Lightweight) | claude-haiku-4-5 | classification, summarization, trend_analysis, scoring, labeling, extraction, briefing |

## Projektstruktur
```
DriveAI-AutoGen/
├── main.py                          ← Python Einstiegspunkt (1.729 Zeilen, CLI-Parsing + Pipeline)
├── CLAUDE.md                        ← Diese Datei
│
├── projects/                        ← Generierte Projekte
│   ├── askfin_v1-1/                 ← AskFin Premium iOS App (234 Swift Files)
│   ├── askfin_android/              ← AskFin Android (204 Kotlin Files)
│   └── askfin_web/                  ← AskFin Web (TypeScript/React, Spec ready)
│
├── factory/                         ← Factory Core (444 .py Files, 95.506 LOC)
│   ├── pipeline/                    ← Extrahierter Pipeline Runner
│   ├── orchestrator/                ← Build-Planer (flat + layered + quality gates)
│   ├── brain/                       ← TheBrain: Model Registry (9 Modelle, 4 Provider), AutoSplitter, Chain Optimizer, CapabilityMatcher (17 Tags, Score-Based), AgentClassifier (Auto-Tier + Auto-Caps, 94.7% Accuracy), FactoryState, CapabilityMap, StateReport, TaskRouter, Persona, ResponseCollector, ProblemDetector, SolutionProposer, GapAnalyzer, ExtensionAdvisor, FactoryMemory, ModelEvolution (Auto-Discovery + Registration + Tier Cascade), Directives (DIR-001 Self-First)
│   ├── operations/                  ← Post-Generation: Hygiene, Stubs, Shape Repair, Sanitizer, Import Hygiene
│   ├── status/                      ← Factory Status Dashboard
│   ├── dispatcher/                  ← Pipeline Queue Manager + Product State Machine + Project Creator
│   ├── shared/                      ← Project Registry, Pipeline Utils, Bootstrap
│   ├── assembly/                    ← Assembly Lines (Android, Web, Unity, iOS via Mac Bridge)
│   │   └── repair/                  ← RepairEngine: ErrorParser + 5 Fix-Strategies + LLM Agent + Coordinator
│   ├── signing/                     ← Signing Pipeline: Credential Check → Version Bump → Build/Sign → Artifacts
│   │   ├── signing_coordinator.py   ← Orchestrator (iOS + Android + Web)
│   │   ├── android_signer.py        ← Android AAB Signing
│   │   ├── web_builder.py           ← Web Bundle Builder
│   │   ├── credential_checker.py    ← Platform-spezifische Credential-Pruefung
│   │   ├── version_manager.py       ← Semantic Versioning pro Platform
│   │   └── artifact_registry.py     ← Artifact Storage + History
│   ├── qa/                          ← QA Department: Coordinator, Bounce Tracker, Test Runner
│   ├── store_prep/                  ← Store Prep: Metadata Enricher, Privacy Labels, Screenshots
│   ├── store/                       ← Store Pipeline: Metadata, Compliance, Packaging, Readiness
│   ├── mac_bridge/                  ← Mac Build Agent Bridge (Git-Queue)
│   ├── pre_production/              ← Swarm Factory Phase 1 (7 Agents, CEO Gate)
│   ├── market_strategy/             ← Swarm Factory Phase 2/Kapitel 3 (5 Agents)
│   ├── mvp_scope/                   ← Swarm Factory Kapitel 4 (3 Agents)
│   ├── design_vision/               ← Swarm Factory Kapitel 5 (Design-System)
│   ├── visual_audit/                ← Swarm Factory Kapitel 5 (Visual Audit)
│   ├── roadbook_assembly/           ← Swarm Factory Kapitel 6 (CD Technical Roadbook)
│   ├── document_secretary/          ← Agent 13: 9 PDF-Templates, Playwright Renderer
│   ├── qa_forge/                    ← Forge-QA (Phase 13): 4 Checker + Design Compliance + Orchestrator
│   ├── asset_forge/                 ← Asset Generation (Images, Icons)
│   ├── motion_forge/                ← Motion/Animation Generation
│   ├── sound_forge/                 ← Sound/Audio Generation
│   ├── scene_forge/                 ← Scene/Level Generation
│   ├── brand/                       ← DAI-Core Brand System: Brand Bible, Brand Summary, Brand Loader (3-Tier), CSS, Assets
│   ├── marketing/                   ← Marketing (54 .py, 12.653 LOC): 11 Agents + 7 Tools + 9 Adapters, E2E Pipeline
│   ├── evolution_loop/              ← Evolution Loop (50 .py, 9.042 LOC): 6 Agents, iterative Quality-Verbesserung
│   │   ├── ldo/                     ← LDO Schema + Storage + Validator
│   │   ├── scoring/                 ← Hard Scores + Soft Scores + Aggregator
│   │   ├── adapters/                ← QA-to-LDO + Orchestrator Handoff
│   │   ├── gates/                   ← CEO Review Gate (Human + AI Provider)
│   │   ├── tracking/               ← Git Tagger + Cost Tracker
│   │   ├── plugins/                ← Plugin-System (Game + Business Plugins)
│   │   ├── config/                 ← Loop Config + Defaults (YAML)
│   │   └── tests/                  ← 15 Test-Dateien
│   ├── live_operations/              ← Live Operations Layer (Phase 1 COMPLETE)
│   │   ├── app_registry/            ← App Registry (SQLite): database.py, migrator.py, cli.py
│   │   ├── agents/
│   │   │   ├── metrics_collector/   ← MetricsCollector: Store API + Firebase API Adapter (STUB), Normalisierung
│   │   │   └── health_scorer/       ← AppHealthScorer: 5 Kategorien, 5 Profile, Zonen (green/yellow/red)
│   │   └── data/                    ← Gesammelte Metriken (JSON pro Collection-Run)
│   ├── integration/                 ← Cross-Department Integration
│   ├── lines/                       ← Production Line Definitions
│   ├── production_lines/            ← Platform-specific Templates
│   │   ├── ios/templates/analytics/ ← Firebase Analytics (Swift)
│   │   ├── android/templates/analytics/ ← Firebase Analytics (Kotlin)
│   │   ├── web/templates/analytics/ ← Firebase Analytics (TypeScript): analyticsManager, analyticsEvents, firebaseConfig.template, INTEGRATION_GUIDE
│   │   └── unity/templates/analytics/ ← Firebase Analytics (C#): AnalyticsManager, AnalyticsEvents, firebase_config.template, INTEGRATION_GUIDE
│   ├── hq/                          ← Factory HQ
│   │   ├── capabilities/            ← Feasibility Check: Capability Sheet + Matching + Gate + Watcher
│   │   ├── dashboard/               ← Web Dashboard (React + Express, 19 Components + Team Redesign: 7 Sub-Components)
│   │   │   ├── server/              ← API Routes (projects, gates, feasibility, janitor, providers, team, assistant, brain, liveops)
│   │   │   └── client/              ← React Frontend (Pipeline, Gates, Janitor, Assistant, Provider, Team, Brain, LiveOps)
│   │   ├── gates/                   ← CEO Gate Files (JSON)
│   │   ├── janitor/                 ← Factory Janitor: Scanner, Analyzer, Consistency, Dependencies, Model Hardcode Checker, Model Evolution Check
│   │   └── providers/               ← Service Provider Management
│   └── reports/                     ← Factory Reports
│
├── agents/                          ← AI Agenten (Python, AutoGen)
├── config/                          ← Konfiguration (Roles, Toggles, Profiles, Platform Roles, model_router.py mit get_model_for_agent + Tier System)
├── factory_knowledge/               ← Factory Knowledge System (22 Entries, FK-001 bis FK-022)
├── code_generation/                 ← Code Extractors (Swift, Kotlin, TypeScript, C#, Python)
├── control_center/                  ← Streamlit Dashboard (Legacy, 19 Pages)
├── briefings/                       ← Daily Briefing Agent
├── docs/                            ← Dokumentation (46 .md Dateien)
├── ideas/                           ← CEO-Ideen (.md Dateien)
├── MasterPrompt/                    ← Cross-Platform Command Dispatch
├── _commands/                       ← Mac ↔ Windows Command Queue
├── _logs/                           ← Shared Logs (Mac ↔ Windows via Git)
└── DeveloperReports/                ← 131+ Development Reports
```

## Agents (93 total: 86 aktiv / 4 deaktiviert / 3 planned, 16 Departments)
> Registry: `factory/agent_registry.json` (auto-generated via `factory/agent_registry.py`)
> Agent-Files: `agent*.json` in jeweiligem Department-Ordner

### Departments
| Department | Agents | Beschreibung |
|---|---|---|
| Code-Pipeline | 22 | Lead, Architects, Developers, Reviewers, CD, UX, Tests |
| Swarm Factory | 27 | Pre-Production (7), Market Strategy (5), MVP Scope (3), Design Vision, Visual Audit, Roadbook, Secretary |
| Brain | 7 | Task Router (BRN-01) + Response Collector (BRN-02) + Problem Detector (BRN-03) + Solution Proposer (BRN-04) + Gap Analyzer (BRN-05) + Extension Advisor (BRN-06) + Factory Memory (BRN-07) — Routing, Verarbeitung, Eskalation, Problemerkennung, Loesungsvorschlaege, Gap-Tiefenanalyse, Erweiterungs-Roadmaps, Langzeit-Gedaechtnis |
| Infrastruktur | 11 | HQ Assistant (21 Tools: 14 Factory + 7 TheBrain), Orchestrator, Assembly, Repair, Status, Promotion, Mac Bridge, Janitor |
| Asset Forge | 1 | Bild/Icon-Generierung |
| Motion Forge | 1 | Animation/Motion-Generierung |
| Sound Forge | 1 | Audio/Sound-Generierung |
| Scene Forge | 1 | Level/Scene-Generierung |
| QA Forge | 1 | Forge-Output-Validierung |
| Store Prep | 1 | Store-Vorbereitung (Metadata, Screenshots) |
| Store | 1 | Store Submission Pipeline |
| Signing | 1 | Code Signing (iOS/Android/Web) |
| Marketing | 11 + 7 Tools + 9 Adapters | Brand Guardian (MKT-01) + Strategy (MKT-02) + Copywriter (MKT-03) + Naming (MKT-04) + ASO (MKT-05) + Visual Designer (MKT-06) + Video Script (MKT-07) + Publishing Orchestrator (MKT-08) + Report Agent (MKT-09) + Review Manager (MKT-10, Zwei-Stufen) + Community Agent (MKT-11, Zwei-Stufen). Tools: Template Engine, Video Pipeline, Content Calendar, Ranking DB, Social Analytics, KPI Tracker, HQ Bridge. Adapters: 5 aktiv + 4 Stubs. Phase 4 COMPLETE (59+32 Tests, 54 .py, 12.653 LOC) |
| Evolution Loop | 6 + FactoryLearner | EVO-01 SimulationAgent + EVO-02 EvaluationAgent + EVO-03 GapDetector + EVO-04 DecisionAgent + EVO-05 RegressionTracker + EVO-06 LoopOrchestrator. Subsysteme: LDO Schema/Storage, Hard+Soft Scoring, Plugin-System (Game+Business), CEO Review Gate, Git Tagger, Cost Tracker, Factory Learner. 50 .py, 9.042 LOC, 15 Tests |
| Live Operations | 2 + App Registry | MetricsCollector (Store+Firebase STUB), AppHealthScorer (5-Kat, 5-Profile, 3-Zonen). App Registry (SQLite), Dashboard Integration (Health Score Fleet View). Phase 1 COMPLETE |
| Integration | 1 | Cross-Department Integration |

### Deaktiviert (4)
- android_architect, kotlin_developer, web_architect, webapp_developer

### Planned (3)
- Android Assembly Line, Web Assembly Line, Unity Assembly Line

## AskFin Premium iOS App (askfin_v1-1)

### Mac Baseline (Stand 2026-03-18)
- **Xcode Build**: SUCCEEDED (xcodegen, iPhone 17 Pro Simulator)
- **Golden Gates**: 15 Gates, 20+ XCUITests, 0 Failures
- **4 Pillars**: Alle runtime-validiert + gate-geschuetzt (Training, Skill Map, Generalprobe, Readiness)
- **Adaptive Learning**: Echte Fragen-DB (173 Fuehrerschein-Fragen), Confidence-basierte Selektion, Learning Signal Persistence
- **Persistence**: UserDefaults (Competence + History + Learning Signals), ueberlebt Cold Restart
- **Insight-to-Action Loop**: Generalprobe → Gap-Analyse → Drilldown → "Thema ueben" CTA → Training
- **Schwaechen-Training CTA**: Result → "Schwaechen trainieren" → TrainingSessionView(.weaknessFocus)
- **App Store Prep**: Metadata, Privacy Policy, Screenshots (automatisiert), Icon Spec — submission-ready (fehlt: Icon + Developer Account)
- **Quarantine**: 7 Files FROZEN (siehe quarantine/QUARANTINE_STATUS.md)
- **Commands**: 092 ausgefuehrt, Reports bis 131-0
- **MasterPrompt Dispatch**: Reports ab 102-0 in `MasterPrompt/reportAgent/`

- **Typ**: SwiftUI MVVM Coaching App (Fuehrerschein-Pruefungsvorbereitung)
- **4 Pillars**: Training Mode, Exam Simulation, Skill Map, Readiness Score
- **~200+ Swift Files** in `projects/askfin_v1-1/`
- **Status**: Factory-generiert, 14 Autonomy Proof Runs, App Store Prep abgeschlossen
- **Bearbeitung**: Mac (Xcode/Build/Runtime) + Windows (Factory/Prompts/Quality Gate)
- **Projekt-Inferenz**: Automatisch erkannt wenn `--project` weggelassen wird

## AI App Factory
- **93 Agents** (86 aktiv, 16 Departments, Python AutoGen-basiert, 100% Anthropic Claude)
- **444 Python-Dateien**, 95.506 LOC in factory/
- **Streamlit Control Center**: `streamlit run control_center/app.py`
- **Bearbeitung**: Windows oder Server

## Operations Layer Pipeline
```
Output Integrator → Completion Verifier → Compile Hygiene Validator
  → Type Stub Generator (FK-014) → Re-Hygiene
  → Property Shape Repairer (FK-013) → Re-Hygiene
  → Swift Compile Check → Recovery Runner → Run Memory → Knowledge Writeback
```
- **Output Integrator**: 5-Layer Dedup (Filename + Type-Level + Markdown Sanitization)
- **Compile Hygiene Validator**: 6 Checks (FK-011 bis FK-017), Column-aware, Memberwise-Init-Erkennung
- **Type Stub Generator**: Automatische Stubs fuer FK-014 (fehlende Typ-Deklarationen)
- **Property Shape Repairer**: Automatische Struct-Property-Reparatur bei FK-013 (0%-Match)
- **Swift Compile Check**: swiftc -parse Validierung — nur Mac/Linux (SKIPPED auf Windows)
- **5 Dedup-Layers**: CodeExtractor → ProjectIntegrator → OutputIntegrator Filename → OutputIntegrator Type → CompileHygiene

## Factory Knowledge System
- **22 Eintraege** (FK-001 bis FK-022)
- FK-001 bis FK-010: Product/UX Knowledge (Premium Strategy, Psychology)
- FK-011 bis FK-017: Error Patterns (aus Xcode Build Failures)
- FK-018: Auto-promoted Proposal (File Duplication, 6 Beobachtungen)
- Deterministische Selektion fuer Creative Director Review
- **Writeback Loop**: Proposals mit 2+ Beobachtungen → auto-promoted zu `validated`
- **Run Pattern Extraction**: Recurring failures + Recovery outcomes → Knowledge
- **Role-Based Injection**: Bug Hunter, Refactor, Fix Executor empfangen validated+ Knowledge

## Quality Gate
> **PFLICHT bei jedem Prompt.** Regeln: `~/.claude/docs/QUALITY-GATE.md` (zentral, projektuebergreifend).
> Gilt automatisch — Prompt Pilot prueft vor Ausfuehrung, Agents lesen die Datei direkt.

## Konventionen
- Sprache mit User: Deutsch
- Commit-Messages: Englisch
- Keine unnötigen Nachfragen – einfach machen
- Alle Änderungen in CLAUDE.md + MEMORY.md dokumentieren
- `_logs/` für Mac ↔ Windows Austausch via Git

## Reports (Grundregel)
> **PFLICHT bei jedem Command**: Zwei Dateien schreiben.

### Aktueller Report-Pfad (ab Command 062)
```
MasterPrompt/reportAgent/    ← NEUER Pfad fuer alle Reports
  102-0_Quarantine Cleanup Report.md
  103-0_ReadinessService Rehabilitation Report.md
  ...
```

### Alter Report-Pfad (Commands 001-061)
```
DeveloperReports/CodeAgent/  ← Reports 1-0 bis 101-0
```

### Bei jedem Command ausfuehren
1. `_commands/XXX_..._result.md` — Detailliertes Ergebnis
2. `MasterPrompt/reportAgent/NNN-0_Titel.md` — Kompakter Report

## DeveloperReports (alt, bis Report 101-0)
> **PFLICHT bei jedem Agent-Wechsel**: Jeder strukturierte Report wird als `.md` gespeichert.

**Ordnerstruktur**:
```
DeveloperReports/
├── CodeAgent/           ← Reports vom Code-Agent (Claude Code)
│   ├── 1-0_Factory Core Audit Report.md
│   ├── 2-0_Three Hotfixes Report.md
│   └── ...
└── Steps-MasterLead/    ← Reports vom Master Lead (Andreas)
    └── ...
```

**Nummerierung** (pro Unterordner):
- Neues Thema: `N-0_Titel.md` (nächste freie Nummer)
- Folge-Report zum gleichen Thema: `N-1_Titel.md`, `N-2_Titel.md`, ...

**Regel**: Vor dem Erstellen prüfen welche Nummer als nächstes dran ist. Reports sind dauerhaft und dienen als Projekthistorie. Code-Agent-Reports → `CodeAgent/`, Master-Lead-Steps → `Steps-MasterLead/`.

## Swarm Factory (Autonome Produkt-Pipeline)

### Phase 1: Pre-Production Pipeline (12 Steps — KOMPLETT)
```
CEO-Idee → Memory-Briefing → [Trend+Competitor+Audience parallel] → Concept Brief → Legal → Risk → CEO-Gate → Memory
```
- 7 Agents (6x Sonnet, 1x Haiku), Web-Recherche via SerpAPI + Caching
- Runs: EchoMatch #003 (**GO**), SkillSense #004 (Gate pending)
- Output: `factory/pre_production/output/{NNN}_{slug}/`

### Kapitel 3: Market Strategy Pipeline (7 Steps — KOMPLETT)
```
Phase-1-Input → [Platform+Monetization] → [Marketing+Release] → Cost Calculation
```
- 5 Agents (alle Sonnet), Wave-basierte Ausfuehrung
- Run: EchoMatch #001 (5 Reports)
- Output: `factory/market_strategy/output/{NNN}_{slug}/`

### Kapitel 4: MVP & Feature Scope (7 Steps — KOMPLETT)
```
Alle 11 Reports → Feature-Extraction (72 Features) → Priorisierung (Phase A/B/Backlog) → Screen-Architektur (22 Screens, 7 Flows)
```
- 3 Agents (alle Sonnet), sequentiell, kein Web-Research
- Budget-Constraints: Phase A €252.500, Phase B €230.000
- KPI-Targets: D1≥40%, D7≥20%, D30≥10%, Session 6-10min
- Flow-Retry-Logik fuer robuste User-Flow-Generierung
- Run: EchoMatch #001 (Feature-Liste + Priorisierung + Screen-Architektur)
- Output: `factory/mvp_scope/output/{NNN}_{slug}/`

### Document Secretary (Agent 13 — KOMPLETT)
- 9 PDF-Typen: CEO Briefing P1/P2, Marketing-Konzept, Investor Summary, Tech Brief, Legal Summary, Feature-Liste, MVP Scope, Screen-Architektur
- HTML/CSS → PDF via Playwright (Chromium)
- CLI: `python -m factory.document_secretary.secretary --type all --p1-dir ... --p2-dir ... --k4-dir ...`
- E-Mail-Versand via SMTP (.env Config)
- 10 PDFs generiert fuer EchoMatch (Stand 2026-03-21)

### Kapitel 5: Design Vision + Visual Audit (KOMPLETT)
- Design-System-Generierung aus Phase 1-4 Output
- Visual Audit Pipeline fuer UI/UX Validierung

### Kapitel 6: CD Technical Roadbook (KOMPLETT)
- CEO Roadbook + CD Technical Roadbook Assembly
- Output: `factory/roadbook_assembly/output/{NNN}_{slug}/`

### Post-Roadbook Pipeline
```
CD_ROADBOOK_COMPLETE → Feasibility Check → [feasible → Production Review] | [partial → CEO Gate] | [blocked → Parked]
```
- Feasibility Check: Capability Sheet vs Roadbook Matching (deterministisch, kein LLM)
- CLI: `--feasibility-check <project>`, `--capability-sheet`, `--recheck-parked`

### Signing Pipeline
```
Credential Check → Version Bump → Build/Sign → Artifact Storage
```
- Platforms: iOS (iOSSigner, Mac Bridge), Android (AndroidSigner), Web (WebBuilder)
- CLI: `--sign <project> --platform <ios|android|web|all>`, `--check-credentials`, `--show-version`, `--bump-version`, `--list-artifacts`

### QA Forge (Phase 13)
- 4 Checker: visual_diff, audio_check, animation_timing, scene_integrity
- Design Compliance: 12 Auto-Checks + 5 CEO Manual Checks
- QA Forge Orchestrator: Alle Checker + Compliance + Verdict
- CLI: `python -m factory.qa_forge.qa_forge_orchestrator --project X --synthetic [--save] [--only visual audio]`

### Ideas Pipeline
- `ideas/` Ordner fuer CEO-Ideen als .md Dateien
- SkillSense.md vorhanden (Phase 1 durchgelaufen, Gate pending)
- `--idea-file ideas/SkillSense.md` fuer Pipeline-Input

### Evolution Loop (50 .py, 9.042 LOC — P-EVO-001 bis P-EVO-023)
```
Build + QA → OrchestratorHandoff → LDO
  → SimulationAgent (Static Analysis + Plugins)
  → EvaluationAgent (Hard + Soft + Plugin Scores)
  → GapDetector (Score-based + Regression Gaps)
  → DecisionAgent (Gaps → Tasks, CEO Feedback → Tasks)
  → RegressionTracker (Trend + Mode Escalation: Sprint → Deep → Pivot)
  → LoopOrchestrator (Stop Conditions, Budget, Git Tags)
  → CEO Review Gate (Human/AI Provider, Review Brief)
  → Factory Learner (Cross-Project Analysis, Similar Issues)
```
- **LDO (Loop Data Object)**: 15 Dataclasses, JSON-serialisierbar, alleiniges Kommunikationsmedium
- **Scoring**: Bug (100-failed*5), Roadbook (feat*40+screen*30+flow*30), Structural (4x25), Performance (4x25), UX (4x25), Plugin Scores
- **Plugin-System**: EvaluationPlugin ABC + PluginLoader (importlib), 3 Plugins (GameSystems, MechanicsConsistency, DataFlow)
- **CEO Review Gate**: ReviewProvider (ABC), HumanReviewProvider (file-basiert), austauschbar gegen AI
- **Tracking**: GitTagger (annotated tags, rollback), CostTracker (per-agent, per-iteration)
- **Factory Learner**: Cross-Project Queries, Similar Issues, Lessons per Type, Cross-Stats
- **CLI**: `--evolution-loop`, `--evolution-status`, `--evolution-history`, `--evolution-ceo-review`
- **Tests**: 15 Test-Dateien, ~80 Tests total
- **Referenz**: `docs/ROADBOOK_EVOLUTION_LOOP.md`

## Erledigtes
- [2026-03-29] Evolution Loop P-EVO-024: Agent Activation & Registry Finalisierung. 6 EVO Agents (EVO-01 bis EVO-06) in agent_registry.json eingetragen mit status=active, department=Evolution Loop. `factory/evolution_loop/__init__.py` vervollstaendigt: 37 Exports (6 Agents, 15 LDO-Typen, EvolutionConfig, 3 Scoring, 4 Gates, 2 Plugins, 2 Adapters, 2 Tracking, FactoryLearner). Alle 7 Sub-Package __init__.py verifiziert (ldo, scoring, gates, plugins, adapters, tracking, config). Registry Summary: 86 total, 79 active, 14 Departments. Backup: `_backups/agent_registry.json.bak_evolution_loop_activation`. 6/6 Validierungstests bestanden.
- [2026-03-29] Evolution Loop P-EVO-023: Factory Learner (`factory/evolution_loop/factory_learner.py`, 405 LOC). Query-Schicht ueber LDO-History: list_projects() (alle Projekte mit Iterationen/Scores/Trends), get_project_summary() (vollstaendige Zusammenfassung inkl. Score-Improvement/Gaps/Tasks/Mode-History), search_similar_issues() (Substring-Match mit Relevanz-Scoring, Resolution-Tracking), get_cross_project_stats() (aggregierte Statistiken: Avg Iterations/Scores/Costs, Gap-Verteilung, Type-Distribution), get_lessons_for_project_type() (Erkenntnisse pro Typ: typische Mode-Progression, haeufige Gaps). 100% deterministisch, read-only, cached. 7/7 Tests + alle bestehenden Tests gruen.
- [2026-03-29] Evolution Loop P-EVO-021: Plugin-System (`factory/evolution_loop/plugins/`). EvaluationPlugin ABC + PluginLoader (importlib dynamic loading, _TYPE_TO_DIR mapping). 3 Plugins: GameSystemsValidator (5 Systems je 20pts), MechanicsConsistencyChecker (Konstanten-Validierung), DataFlowValidator (API/Validation/Sanitization 40+30+30pts). SimulationAgent integriert: _run_plugins() nach synthetic_flow_check, Ergebnisse als dict fuer EvaluationAgent-Kompatibilitaet. Graceful bei missing files (Score=50, Confidence=10). 6/6 Tests + alle bestehenden Tests gruen.
- [2026-03-29] Evolution Loop P-EVO-018: CLI Integration in main.py (+134 LOC). 4 neue Flags: `--evolution-loop PROJECT_ID` (+ `--project-type`, `--production-line`), `--evolution-status PROJECT_ID`, `--evolution-history PROJECT_ID`, `--evolution-ceo-review PROJECT_ID`. Backup: `_backups/main.py.bak_evolution_loop`. Lazy Imports (innerhalb if-Bloecke). Bestehende Flags unberuehrt. Syntax OK, 5/5 E2E + 6/6 CEO Gate bestanden.
- [2026-03-29] Evolution Loop P-EVO-017: CEO Review Gate (`factory/evolution_loop/gates/`). ReviewProvider (ABC) + ReviewResult (dataclass). HumanReviewProvider: file-basiert, generiert `ceo_review_brief.md` (Markdown mit Scores/Gaps/Kosten/Feedback-Template), liest `ceo_feedback.json` (go/no_go + Issues), validiert JSON-Format. CEOReviewGate: execute() ruft Provider, bei no_go -> DecisionAgent.translate_ceo_feedback() generiert Tasks. Provider austauschbar (Human -> AI). 6/6 Tests + 5/5 E2E + 8/8 Tracking bestanden.
- [2026-03-29] Evolution Loop P-EVO-016: Git Rollback System + Cost Tracker (`factory/evolution_loop/tracking/`). GitTagger: `tag_iteration()` (annotated tags per Iteration), `rollback_to()` (neuer Branch, kein Force-Push), `list_tags()`, `get_last_stable_iteration()` (Bug>=90, Roadbook>=95, Structural>=85). CostTracker: `add_cost(agent_id, cost, iteration)`, `get_total()`, `get_cost_per_iteration()`, `check_budget(threshold)`, `get_cost_report()`, `reset()`. LoopOrchestrator: `accumulated_cost` jetzt Property via CostTracker, Git-Tag nach LDO-Save, Budget-Check via CostTracker. 8/8 Tests + 5/5 E2E + alle bisherigen Tests bestanden.
- [2026-03-29] Evolution Loop P-EVO-015: Loop-Modi Implementation. Sprint->Deep->Pivot Eskalation vollstaendig integriert. RegressionTracker: detect_loop_mode() vereinfacht (Deep->Pivot bei declining statt 3+ streak), neue Helpers (_count_iterations_in_mode, _count_recurring_gaps). LoopOrchestrator: check_stop_conditions() erweitert (Pivot->ceo_review, mode-spezifische Max-Iterations: Sprint=10, Deep=5). DecisionAgent: Deep Mode konvertiert non-critical "fix" Tasks zu "refactor". 6/6 Mode-Tests + 5/5 E2E + 7/7 Regression + 6/6 Decision bestanden.
- [2026-03-29] Evolution Loop P-EVO-014: Simulation Agent (`factory/evolution_loop/simulation_agent.py`, 487 LOC). Statische Code-Analyse ohne LLM: `_static_analysis()` (LOC, TODOs, Stubs, Hardcoded Values, Deep Nesting, Error Handling Ratio, Dead Code), `_roadbook_coverage()` (Feature/Screen-Matching per Filename+Content), `_synthetic_flow_check()` (Navigation-Patterns). Preserviert pre-populierte Daten wenn keine Dateien existieren. 7 Sprachen erkannt. Max 1000 Dateien. Binary-Skip. Encoding-Fallback. KEIN Stub mehr im Loop Orchestrator — alle 6 Agents funktional. 6/6 Tests + 5/5 E2E.
- [2026-03-29] Evolution Loop P-EVO-013: E2E Loop Test (`factory/evolution_loop/tests/test_evolution_loop_e2e.py`). 5 Szenarien: Happy Path (3 Iterationen, Stagnation→CEO Review), Perfect Build (1 Iteration, Targets met→CEO Review, Aggregate 99.0), Max Iterations (3/3), Score Tracking (Stagnation korrekt erkannt), Status Report (alle Felder). Bugfix: `features_implemented`→`features_covered` Key in Testdaten. 5/5 Tests, 0.09s.
- [2026-03-29] Evolution Loop P-EVO-012: Regression Tracker (`factory/evolution_loop/regression_tracker.py`). RegressionTracker analysiert Iterations-History: Trend-Detection (improving/stagnating/declining), Score-Regressions, Loop-Mode-Detection (sprint->deep->pivot, nur Eskalation). Thresholds aus Config (stagnation=2%, regression=5%, stagnation_iterations=2). Empfehlungen: improving->continue, stagnating->ceo_review, declining->stop. Trend-Summary-Text. LoopOrchestrator.regression_step() delegiert an RegressionTracker. Nur noch 1 Stub (simulation_step). 7/7 Tests.
- [2026-03-29] Evolution Loop P-EVO-011: Decision Agent (`factory/evolution_loop/decision_agent.py`). DecisionAgent uebersetzt Gaps in Tasks: bug->fix, feature->implement, structural/performance/ux->refactor. CEO-Feedback-Translation (blocker->critical, major->high). Eskalationslogik: >5 critical Gaps, persistente Regression (3+ Iter), >15 total Gaps. Task-IDs: TASK-{iter}-{NNN} bzw TASK-{iter}-CEO-{NNN}. LoopOrchestrator.decision_step() delegiert an DecisionAgent. 6/6 Tests.
- [2026-03-29] Evolution Loop P-EVO-010: Gap Detector (`factory/evolution_loop/gap_detector.py`). GapDetector identifiziert Gaps zwischen Soll und Ist: Score-basiert (5 Targets), Compile Errors, Test Failures, Feature Coverage. Regression-Check via LDOStorage (vorherige Iteration). Gap-IDs: GAP-{iter}-{NNN}. Severity-Sortierung (critical>high>medium>low). LoopOrchestrator.gap_detection_step() delegiert an GapDetector. 5/5 Tests.
- [2026-03-29] Evolution Loop P-EVO-009: Evaluation Agent (`factory/evolution_loop/evaluation_agent.py` + `scoring/soft_scores.py`). EvaluationAgent delegiert alle Score-Berechnungen: Hard Scores (Bug/Roadbook/Structural via HardScoreCalculator) + Soft Scores (Performance/UX via SoftScoreCalculator) + Plugin Scores + Aggregation. SoftScoreCalculator: Performance (4x25: Code-Size, Anti-Patterns, Stubs, Error-Handling, Confidence 50/35/15) + UX (4x25: Screen-Coverage, Flow-Completeness, Nav-Depth, Naming-Consistency, Confidence 40/30/15). LoopOrchestrator.evaluation_step() delegiert jetzt an EvaluationAgent statt inline. 6/6 Tests.
- [2026-03-29] Evolution Loop P-EVO-008: Loop Orchestrator (`factory/evolution_loop/loop_orchestrator.py`). LoopOrchestrator mit 10 Methoden (4 Stubs: simulation/gap/regression/decision, 6 funktional: run_loop/run_single_iteration/evaluation_step/check_stop_conditions/get_status_report/init). Evaluation nutzt EvaluationAgent. Stop-Bedingungen: max_iterations->stop, budget->ceo_review, regression->stop/ceo, targets_met->ceo_review. LDO-Storage pro Iteration. 7/7 Tests.
- [2026-03-28] Evolution Loop P-EVO-007: Hard Scores + Aggregator (`factory/evolution_loop/scoring/`). HardScoreCalculator (3 Methoden: bug=100-(failed*5)-(errors*15)-(warnings*1), roadbook_match=feat*40+screen*30+flow*30, structural_health=4x25 Punkte). ScoreAggregator (gewichteter Durchschnitt + Veto-Logik: Bug<min→cap 50, Roadbook/Structural<min→cap 60). check_targets_met() prueft alle Targets. 11/11 Tests.
- [2026-03-28] Evolution Loop P-EVO-006: Orchestrator Handoff (`factory/evolution_loop/adapters/orchestrator_handoff.py`). OrchestratorHandoff mit 3 Methoden: receive_from_orchestrator() (Build+QA→LDO, 3 Build-Formate: BuildReport/Simple/Empty), send_tasks_to_orchestrator() (LDO Tasks→Orchestrator Format), create_handoff_report() (Log-String). Hook-Point: nach execute_plan() + QA-Run. Nutzt QAToLDOAdapter. 5/5 Tests.
- [2026-03-28] Evolution Loop P-EVO-005: QA-to-LDO Adapter (`factory/evolution_loop/adapters/qa_to_ldo_adapter.py`). QAToLDOAdapter mit 4 Methoden: transform_qa_forge_results(), transform_qa_department_results(), merge_results(), extract_from_project(). Liest QA Forge + QA Department Output. Score-Formeln: bug=100-(failure_rate*500), structural=100-(blocking*25)-(warnings*5), ux/perf aus Forge pass-rate. 5/5 Tests.
- [2026-03-28] Evolution Loop P-EVO-004: 6 Agents registriert (EVO-01 bis EVO-06) in agent_registry.json. 86 Agents total, 14 Departments, 9 planned.
- [2026-03-28] Evolution Loop P-EVO-003: Default Config — 2 YAML + config_loader.py. Loop-Limits, Quality Targets, Score Weights (4 Typen), Confidence. Deep-merge fuer Projekt-Overrides.
- [2026-03-28] Evolution Loop P-EVO-002: LDO Schema — 15 Dataclasses (schema.py), Validator (validator.py), Storage (storage.py). Round-trip + nested deserialization + validation OK. 354 LOC gesamt.
- [2026-03-28] Evolution Loop P-EVO-001: Department-Struktur `factory/evolution_loop/` erstellt (10 Dirs, 9 __init__.py). Referenz: ROADBOOK_EVOLUTION_LOOP.md.
- [2026-03-28] Cascade Delete: DELETE /api/projects/:id von 8 auf 17 Locations erweitert (store_prep, asset_forge, forges, integration, qa_forge, marketing, ideas, capabilities, dispatcher). Test-Projekte (BrainPuzzle, MemeRun2026, SkillSense) komplett entfernt. Server-Banner auf DAI-Core.
- [2026-03-27] CEO Cockpit Dashboard Rebranding: Komplett auf DAI-Core Brand umgestellt. Farbschema (Magenta/Cyan/Void/Midnight), 5 Text-Referenzen in 4 Dateien, Logo + Favicon in public/. Build OK.
- [2026-03-27] Marketing Phase 4 COMPLETE: Integration-Test (10/10, E2E Store->DB->KPI->Alert->Report->HQ), Phase-4-Report. Gesamt: 32/32 Phase-4-Tests, 54 .py, 12.653 LOC, 11 Agents, 7 Tools, 9 Adapters. Zwei-Stufen-System: 0 auto-responses auf negative Inhalte.
- [2026-03-27] Marketing Phase 4 Block B: Report Agent (MKT-09, Daily/Weekly/Monthly Reports via LLM), Review Manager (MKT-10, Zwei-Stufen-System: HARD Logik → Tier 1 autonom, Tier 2 CEO-Gate), Community Agent (MKT-11, Zwei-Stufen-System fuer Social Media Kommentare), HQ Bridge (JSON-Export fuer Dashboard). Registry: 80 aktiv, Marketing=11. 12/12 Tests.
- [2026-03-27] Marketing Phase 4 Block A: App Store + Google Play Adapters, Ranking-DB (SQLite 5 Tabellen), Social Analytics Collector, KPI Tracker (7 KPIs aus EchoMatch Roadbook). 9 Adapters total. 10/10 Tests.
- [2026-03-27] Marketing Phase 3 Block B: 3 Plattform-Adapter (YouTube, TikTok, X) + 4 Stub-Adapter (Instagram, LinkedIn, Reddit, Twitch). Publishing Orchestrator (MKT-08, deterministisch). `get_adapter()` Factory. Cross-Post mit gestaffeltem Kalender. Alles Dry-Run, kein Live-Publishing. Registry: 77 aktiv, Marketing=8. 9/9 Tests.
- [2026-03-27] Marketing Phase 3 Block A: expected_output_tokens Fix (9 Werte in 4 Agents korrigiert, 2 Workarounds entfernt). Brand Guardian aktiviert (Brand Book MD+JSON, App Style Sheet, Compliance Check). Content Calendar (`content_calendar.py`, deterministisch, 8 Methoden, Launch-Kampagne). Template Engine liest Brand-Farben aus brand_book.json. 7/8 Tests (1 pre-existing o3-mini Compat-Issue).
- [2026-03-27] Team Dashboard Redesign: `team_enrichment.py` (Python-Enrichment fuer 76 Agents), 7 Sub-Components (team-utils, TeamSummary, TeamFilters, TeamTable, TeamDetailPanel, TeamDistribution, TeamView als Orchestrator). `/api/team/enriched` Endpoint mit 5-Min Cache. Dynamische Departments (13), Tier/Provider-Filter, Score-Bars, Capability-Chips, 3 Verteilungs-Panels. Vite Build OK.
- [2026-03-27] Agent Auto-Classification: `agent_classifier.py` (deterministisch + Haiku-Fallback). Auto-Tier + Auto-Caps bei Registration. `validate_agent_tier()` classifiziert statt ValueError. 94.7% Tier-Accuracy (75 Agents). CLI: `--brain-classify <id>|--brain-classify-validate`.
- [2026-03-27] Agent Capability Matching: `capability_tags.py` (17 Tags), `capability_matcher.py` (Score-Based Matching + Tier-Escalation). `get_model_for_agent()` nutzt jetzt Capability->Modell statt nur Tier->Modell. 83 Agents mit `capabilities_required` backfilled. Ergebnis: Swift Dev->Sonnet (swift_code), Roadbook->Gemini Pro (large_context), Lightweight->Flash/Haiku. CLI: `--brain-match <id>|--brain-match-all`.
- [2026-03-26] TheBrain Auto-Evolution Loop + Tier Cascade: `model_evolution.py` (autonomous 6-step pipeline mit Cascade Step 4.5), `known_prices.py` (static fallback prices + aggressive filters 86→22). Tier Cascade: Wenn neues High-Tier-Modell → gesamte Hierarchie verschiebt (Premium→Standard→Lightweight→Deprecated). Atomar mit Backup+Rollback (tier_config.json + llm_profiles.json + models_registry.json). Quick Benchmark vor Premium. `config/model_router.py` lädt tier_config.json als Override. Janitor/brain_tools/main.py Integration. CLI: `--brain-evolution-dry|force`. 24h Cooldown, Registry-Backup+Rollback, FactoryMemory-Logging.
- [2026-03-26] Hardcoded Model Migration COMPLETE (Batch 1+2): 78→0 Findings. Batch 1: 3 Depts (35 Findings). Batch 2: 33 Dateien in 15 Depts/Modulen (43 Findings). get_fallback_model(profile) in config/model_router.py + 8 Department-Configs. Agent Tier System: tier in 83 Agents, get_model_for_agent(). Whitelist: 19 Einträge. Backups in _backups/.
- [2026-03-26] Janitor Model Hardcode Checker: model_hardcode_checker.py scannt 363 .py-Dateien, Severity RED/YELLOW, Whitelist-System. Standalone: `python -m factory.hq.janitor.model_hardcode_checker`. Status: 0 Findings (clean).
- [2026-03-26] Marketing Phase 2 COMPLETE (Steps 2.1-2.13): 5 neue Agents (MKT-03 bis MKT-07) + 2 Tools (Template-Engine, Video-Pipeline). 29 Python-Dateien, 5.639 LOC, 24/24 Tests. Integration-Test 6/6. Content: 23 Dateien in output/ (2 MB), 14 in brand/ (48 KB). 3 Projekte mit Story Briefs (echomatch, memerun2026, skillsense). Phase-2-Report in reports/. ASO max_tokens Fix.
- [2026-03-26] Marketing Phase 2 Block C (Steps 2.8-2.10): 2 neue Agents. MKT-06 Visual Designer (Creative Briefs via LLM + Template-Engine fuer Social Media, Screenshots, Thumbnails, Ads. A/B-Varianten. AI-Background Stub). MKT-07 Video Script (Skripte fuer TikTok/Shorts/YouTube/Reels + Video-Erstellung aus Skripten via Template-Engine + Video-Pipeline. Szenen-Parser). Registry: 83 Agents, Marketing=7. 5/5 Tests. Echte PNGs + MP4 (68s TikTok-Video).
- [2026-03-26] Marketing Phase 2 Block B (Steps 2.6-2.7): 2 neue Tools. Template Engine (Pillow, 11 Formate, 7 Methoden) + Video Pipeline (FFmpeg 8.1, 5 Formate, 7 Methoden). Kein LLM. 8/8 Tests. Bugfixes: drawtext Font-Escaping, ffprobe Pfad.
- [2026-03-26] Marketing Phase 2 Block A (Steps 2.1-2.5): 3 neue Text-Agents. MKT-03 Copywriter (Social Media Packs, Store Listings, Blog, Ad Copy, A/B-Varianten, mehrsprachig). MKT-04 Naming (Namensgenerierung via LLM, Domain/Social/Store Verfuegbarkeitspruefung, CEO-Gate). MKT-05 ASO (Keyword Research, lokalisierte Store Listings, Competitor Analysis, SerpAPI-Integration). Registry: 81 Agents, Marketing=5. 5/5 Tests bestanden. Bugfixes: o3-mini max_tokens fuer Store Listings (16384), JSON-Parse robust gegen Markdown-Fencing, Gate options als dicts.
- [2026-03-26] Marketing Phase 1 COMPLETE: Steps 1.8-1.11 — Strategy Agent erste LLM-Outputs. Factory-Narrative (4 Versionen), EchoMatch Story Brief (6KB, 5 Quellen), EchoMatch Marketing-Direktive (8.7KB). Phase-1-Report in reports/. Bugfix: _call_llm temperature=1.0 (o3-mini) + error check in strategy.py + brand_guardian.py. dotenv in Run-Scripts.
- [2026-03-26] Marketing-Abteilung Phase 1 Steps 1.4-1.6: Agent Personas + Registry. MKT-01 Brand Guardian (Brand Book, Style Sheets, Compliance) + MKT-02 Marketing Strategy (Factory-Narrative, App Stories, Direktiven). Persona JSONs im Factory-Format, Python-Stubs mit System Messages + _call_llm (TheBrain + Anthropic-Fallback). Registry: 78 Agents, 14 Departments. Backup vorhanden.
- [2026-03-26] Marketing-Abteilung Phase 1 Infrastruktur (`factory/marketing/`). 14. Department. Verzeichnisstruktur (agents/, alerts/, brand/, reports/, output/, shared/). Alert-System mit Lifecycle (open→acknowledged→resolved) + CEO-Gates (pending→decided). JSON-Schema-Validierung. Config als Python-Modul. Input Loader liest Pipeline-Outputs aller Departments. Shared Utilities. Alle Import-Tests + Lifecycle-Tests bestanden. Keine bestehenden Dateien geaendert.
- [2026-03-26] HQ Assistant TheBrain-Integration (`factory/hq/assistant/`). 6 neue brain_* Tools: brain_briefing, brain_diagnose, brain_gaps, brain_roadmap, brain_quick_check, brain_commands. BrainTools-Klasse in brain_tools.py kapselt alle TheBrain-Interaktionen. Graceful Degradation wenn TheBrain nicht verfuegbar. Auto-Briefing erweitert (TheBrain Quick-Check im CEO Briefing). 28 Tools total (22 bestehende + 6 TheBrain). Ansatz A+C: Tool-Definitions + elif-Branches. 6/6 Tests. Bestehende Tools unveraendert.
- [2026-03-26] TheBrain Dashboard Page (`factory/hq/dashboard/`). Neue Seite im CEO Cockpit: TheBrain COO-Level Awareness. Backend: brain-scanner.js liest State Reports, Directives, Brain Agents, Memory Events. API: GET /api/brain. Frontend: BrainView.jsx mit 6 Tabs (Alerts, Subsysteme, Gaps, Direktiven, Brain Agents, Memory). Navigation: nach "Factory Status", Brain-Icon. Build OK. Bestehende Seiten unveraendert. Backups in _backups/.
- [2026-03-26] TheBrain Phase 4.5: Factory Memory (`factory/brain/memory/`). BRN-07 Agent. Langzeit-Gedaechtnis: Event Log (15 Typen), Knowledge Base (Lessons), Pattern Store. Kernmethode: check_similar_project_warnings() warnt proaktiv. MemoryWriter fuer einfaches Logging. State Snapshots + Vergleiche. ProblemDetector-Integration. JSON-Storage, append-mostly. 7/7 Tests. Registry auf 76 Agents, Brain=7.
- [2026-03-26] TheBrain Phase 4 Step 2: Extension Advisor (`factory/brain/extension_advisor.py`). BRN-06 Agent. Gap-Analysen → ausfuehrbare Roadmaps. Category-Planner (image, sound, voice, video, animation, production_lines). Production Line Sub-Planner (Android 7.5w, Web 6.5w, Unity 13.5w). Agent-Skill-Matching, Dependency-Wave-Timeline. 5/5 Tests. 21 Plaene (11 immediate, 9 short, 1 mid), 66.5w Gesamt. Sub-Routing in TaskRouter (_route_capabilities). Registry auf 75 Agents, Brain=6.
- [2026-03-26] TheBrain Phase 4 Step 1: Gap Analyzer (`factory/brain/gap_analyzer.py`). BRN-05 Agent. Tiefenanalyse aller Gaps mit DIR-001 4-Stufe-Logik. SELF_BUILD_KNOWLEDGE fuer 6 Kategorien (image, sound, voice_tts, video, animation, production_lines). 7 Stufe-2 + 9 Stufe-3 Optionen. Proxmox-Kompatibilitaetspruefung. `analyze_gaps()` im TaskRouter. 4/4 Tests. 21 Gaps, 21 self-solvable, 0 external-only. Registry auf 74 Agents, Brain=5.
- [2026-03-25] Factory Direktive DIR-001 Self-First (`factory/brain/directives/`). CEO-Direktive: Alles selbst entwickeln, 4-Stufen-Reihenfolge (Eigene Mittel → Self-Build → Self-Host → Extern nur Notfall). DirectiveEngine prueft Capability-Entscheidungen, Pause-Empfehlung, Prompt-Injection (68w). SolutionProposer nutzt DIR-001 Stufenlogik bei Gaps. 5/5 Tests.
- [2026-03-25] TheBrain Phase 3 Step 2: Solution Proposer (`factory/brain/solution_proposer.py`). BRN-04 Agent. 10 Solution Generators, 100% deterministisch (kein LLM). 3 Approval-Levels (auto/ceo_required/info_only). Execution Plan (immediate/needs_approval/long_term). `_find_alternative_services()` liest echte Service Registry + Draft-Adapter. `diagnose_and_propose()` im TaskRouter. 3/3 Tests. Registry auf 73 Agents, Brain=4.
- [2026-03-25] TheBrain Phase 3 Step 1: Problem Detector (`factory/brain/problem_detector.py`). BRN-03 Agent. 10 Detection Rules, 100% deterministisch (kein LLM). Thresholds als Class Constants. Erkennt: Queue-Backlog, stuck Projects, Service-Outages, RED Gaps, Health-Failures, Janitor-Backlog, Auto-Repair-Anomalien, Subsystem-Ausfaelle, Model-Issues, Line-Limits. 3/3 Tests. Registry auf 72 Agents, Brain=3.
- [2026-03-25] TheBrain Phase 2 Step 2: Response Collector (`factory/brain/response_collector.py`). BRN-02 Agent. 9 deterministische Prozessoren, LLM nur fuer process_multi(). Eskalations-Logik (RED Gaps, stuck Projects, Critical Alerts). Brain-Style-Filter. route_and_collect() im TaskRouter. 5/5 Tests.
- [2026-03-25] TheBrain Phase 2 Step 1.5: Brain Persona (`factory/brain/persona/`). brain_persona.md (Charakter-Sheet) + brain_system_prompt.py (System-Prompt Generator, 220 Woerter). Classification-Prompt fuer TaskRouter LLM-Fallback. Live-State-Injection aus FactoryStateCollector.
- [2026-03-25] TheBrain Phase 2 Step 1: Task Router (`factory/brain/task_router.py`). BRN-01 Agent. 2-stufige Klassifikation (Keyword+LLM-Fallback), 8 Routen-Kategorien, Department-Guessing. 6/6 Smoke-Tests bestanden. Agent-Registry auf 70 Agents, 13 Departments.
- [2026-03-25] TheBrain Phase 2 Step 0: Tier Lock (`config/model_router.py`). `tier_lock` Parameter in route()/route_for_agent()/get_model()/get_model_for_agent(). 3-Level Hierarchie (dev=0, standard=1, premium=2), 9 Modelle gemappt. Upgrade-Logging. 100% abwaertskompatibel, keine neuen Dateien.
- [2026-03-25] TheBrain Phase 1 Step 3: State Report Generator (`factory/brain/state_report.py`). Kompakt-Report (lesbar, ~40 Zeilen) + Full Report (Dict). Health=YELLOW, 4 Alerts, 21 Gaps. `save_report()` in `factory/brain/reports/`. `__init__.py` exportiert alle 3 Phase-1-Module.
- [2026-03-25] TheBrain Phase 1 Step 2: Capability Map (`factory/brain/capability_map.py`). `CapabilityMap` aggregiert Capabilities aus Agent/Service/Model Registry + Filesystem (Lines, Forges, Adapters). 69 Agents, 6 Services, 9 Modelle, 5 Forges, 4 Lines, 7 Draft-Adapter. `get_gaps()` findet 21 Gaps (1 red, 10 yellow, 10 green).
- [2026-03-25] TheBrain Phase 1 Step 1: Factory State Collector (`factory/brain/factory_state.py`). `FactoryStateCollector` sammelt Zustand aus 8 Subsystemen (Health Monitor, Janitor, Pipeline Queue, Project Registry, Service/Model Provider, Command Queue, Auto-Repair). 8/8 verfuegbar, read-only, kein LLM.
- [2026-03-25] Signing Coordinator: iOS Patch (SKIPPED→iOSSigner), 9 .py Files restored aus git, CLI-Flags wiederhergestellt, `--platform all` inkl. iOS
- [2026-03-25] QA Department: qa_coordinator, bounce_tracker, quality_criteria, test_runner (factory/qa/)
- [2026-03-25] Store Prep Layer: metadata_enricher, privacy_labels, screenshot_coordinator, store_prep_coordinator (factory/store_prep/)
- [2026-03-25] Phase 13 Steps 5+6: Design Compliance (12 Auto-Checks DC-001..012 + 5 CEO Manual) + QA Forge Orchestrator (5 Checker, Synthetic Proof Run 91.7%)
- [2026-03-25] Phase 13 Steps 1-4: QA Forge Checkers (visual_diff, audio_check, animation_timing, scene_integrity) mit 21 Self-Tests
- [2026-03-25] Janitor Phase 2: Protected Paths erweitert, Growth Alert, Config Consistency Check, Dependency Health Check. Dashboard: 2 neue Tabs.
- [2026-03-25] Janitor Fine-Tuning: 18.614→619 Dateien, node_modules-Bug, Health-Score rekalibriert
- [2026-03-25] Dashboard: Project Delete, Feasibility UI (4 Status-Farben, Gap-Chips, Re-Check), Gate Inbox (Feasibility-spezifische Buttons)
- [2026-03-25] Dashboard Regression Fix: 736 gelöschte Dateien wiederhergestellt, 4 UI-Files repariert
- [2026-03-25] Agent Registry: 69 Agents (62 aktiv, 12 Departments)
- [2026-03-25] Production Feasibility Check: Capability Sheet + Roadbook Matching + Parking + Gate Integration + Dashboard Frontend
- [2026-03-21] Kapitel 4 (MVP & Feature Scope) komplett: 3 Agents, EchoMatch E2E Run, 3 neue PDF-Templates
- [2026-03-21] Document Secretary: 9 PDF-Typen (3 neue: Feature-Liste, MVP Scope, Screen-Architektur)
- [2026-03-21] Screen-Architektur PDF Fix: Markdown-Fallback-Rendering bei JSON-Parse-Fehler
- [2026-03-21] Feature-Priorisierung: Haertere Phase-A/B-Trennung (MINIMUM statt alles-ins-Budget)
- [2026-03-21] SkillSense: Phase 1 Pre-Production Run #004 komplett (Gate pending)
- [2026-03-20] Swarm Factory Phase 1 + Phase 2 (Kapitel 3) + Document Secretary komplett implementiert und getestet
- [2026-03-15] Property Shape Repairer: FK-013 Struct-Property-Reparatur (0-Property-Structs)
- [2026-03-15] OutputIntegrator Semantic Dedup: Type-Level Dedup + Markdown Sanitization
- [2026-03-15] Compile Hygiene Truthfulness: Column-aware FK-012, Memberwise-Init FK-013
- [2026-03-15] Type Stub Generator: Automatische FK-014 Stub-Generierung
- [2026-03-15] Project Context Hardening: Auto-Inferenz aus projects/ Verzeichnis
- [2026-03-15] CD Gate Profile-Awareness: dev-profile = advisory (fail nicht blockierend)
- [2026-03-15] CD Rating Parser Fix: Agent-spezifische Extraktion statt letzter Match
- [2026-03-15] 8 Autonomy Proof Runs (Run 3-8) mit progressiver Verbesserung
- [2026-03-14] Swift Compile Check: swiftc-basierte Syntax-Validierung + Pipeline-Integration
- [2026-03-14] Compile Hygiene Validator Round 3: FK-013, FK-014, FK-017 (6 Checks total)
- [2026-03-14] Compile Hygiene Validator Round 2: FK-011, FK-012, FK-015
- [2026-03-14] Factory Knowledge Error Patterns: FK-011 bis FK-017 aus Xcode Fix Report
- [2026-03-14] Repo bereinigt: DriveAI/, DriveAi-AutoGen/ geloescht, AskFin Premium nach projects/askfin_v1-1/
- [2026-03-13] UX Psychology Review Layer + UX Knowledge Seed (FK-007 bis FK-010)
- [2026-03-13] Creative Director Soft Gate + Advisory Pass
- [2026-03-13] Commercial Strategy Generator + AskFin Premium Projekt
- [2026-03-12] Premium Product Strategy: 5 strategische Docs
- [2026-03-12] Komplette Migration OpenAI GPT → Anthropic Claude (3-Tier System)
- [2026-03-12] Factory erweitert: AutoResearchAgent, ResearchMemoryGraph, StrategyReportAgent
- [2026-03-12] Pipeline Reliability: team.reset(), _run_with_retry(), Implementation Summary
