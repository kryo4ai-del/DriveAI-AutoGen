# DriveAI-AutoGen

Multi-agent AI App Factory with 111 agents across 18 departments. Builds iOS, Android, Web, and Unity apps autonomously from a single idea -- including market research, legal review, design, code generation, QA, signing, store submission, marketing, live operations, and iterative quality improvement.

## Factory at a Glance

| Metric | Value |
|---|---|
| Agents | 111 (104 active, 4 disabled, 3 planned) |
| Departments | 18 |
| Production Lines | 5 (iOS, Android, Web, Unity, Python) |
| LLM Provider | Anthropic Claude (100% -- 3-Tier: Sonnet/Haiku/Opus) |
| Pipeline Cost | $0.08/run (788x cheaper than legacy) |
| Python Files | 585 in factory/ (123,143 LOC) |
| Tests | 485 tests in 55 files |
| Documentation | 47 docs, 131+ developer reports |
| Dashboard | CEO Cockpit -- 42 React components, 18 API endpoints |
| Swarm Factory | 6-chapter autonomous pipeline (idea -> store-ready) |
| Marketing | 14 agents + 24 tools + 16 adapters (Phase 9 complete) |
| Evolution Loop | 6 agents, iterative quality improvement |
| Live Operations | 14 agents, 6h decision cycles, anomaly detection |
| Name Gate | Pre-pipeline name validation (6 checks, traffic light system) |

## Architecture Overview

```
Idea -> Name Gate -> Phase 1 (Research) -> [CEO Gate]
  -> Kap. 3 (Strategy) -> Kap. 4 (Scope) -> Kap. 4.5 (Design)
  -> Kap. 5 (Visual Audit) -> [Visual Review] -> Kap. 6 (Roadbook)
  -> Auto-Feasibility -> [Production Gate] -> Production
  -> Assembly -> QA -> Signing -> Store -> Live Operations
```

### CEO Cockpit Dashboard (React + Express)

Web-based dashboard at `factory/hq/dashboard/` for monitoring and controlling the entire factory.

**42 Components across 12 sections:**
- Pipeline (Project Grid + Detail), Gates (Inbox + Briefing), Production (Dashboard + Cost + Grid + Feed)
- Start (Name Gate + Suggestions + Alternatives), Team (6 sub-components), LiveOps (11 sub-components)
- Brain, Janitor, Showcase, Documents, Marketing, Assistant (Chat + Voice)

**18 API Endpoints:** agents, assistant, brain, documents, factory-health, feasibility, gates, history, janitor, liveops, marketing, namegate, production, projects, providers, showcase, start, team

## Structure

```
DriveAI-AutoGen/
├── main.py                          # Entry point (CLI + pipeline orchestration)
├── projects/                        # Generated projects
│   ├── askfin_v1-1/                 # AskFin iOS (234 Swift files)
│   ├── askfin_android/              # AskFin Android (204 Kotlin files)
│   └── askfin_web/                  # AskFin Web (TypeScript/React)
│
├── factory/                         # Factory Core (585 .py, 123K LOC)
│   ├── pipeline/                    # Hybrid Pipeline Runner
│   ├── orchestrator/                # Build planner (flat + layered + quality gates)
│   ├── brain/                       # TheBrain: 7 agents, model registry, chain optimizer
│   ├── operations/                  # Post-gen: hygiene, stubs, shape repair, sanitizer
│   ├── dispatcher/                  # Pipeline queue manager + product state machine + CLI entry
│   ├── shared/                      # Project registry, pipeline utils
│   ├── assembly/                    # Assembly lines (Android, Web, Unity, iOS via Mac)
│   │   └── repair/                  # 3-tier repair: deterministic -> LLM -> CEO escalation
│   ├── signing/                     # Signing pipeline: credentials -> version -> build -> artifacts
│   ├── qa/                          # QA department: coordinator, bounce tracker, test runner
│   ├── qa_forge/                    # Forge QA: 4 checkers + design compliance + orchestrator
│   ├── store_prep/                  # Store prep: metadata, privacy labels, screenshots
│   ├── store/                       # Store submission: compliance, packaging, readiness
│   ├── mac_bridge/                  # Mac build agent bridge (autonomous via git queue)
│   ├── pre_production/              # Swarm Phase 1: 7 agents, CEO gate
│   ├── market_strategy/             # Swarm Phase 2: 5 agents, monetization
│   ├── mvp_scope/                   # Swarm Kapitel 4: 3 agents, feature scope
│   ├── design_vision/               # Swarm Kapitel 5: design system generation
│   ├── visual_audit/                # Swarm Kapitel 5: UI/UX audit
│   ├── roadbook_assembly/           # Swarm Kapitel 6: CD technical roadbook
│   ├── document_secretary/          # 9 PDF templates, Playwright renderer
│   ├── name_gate/                   # Name Gate: 6 checks, traffic light, CLI
│   ├── integration/                 # Cross-dept: roadbook_to_spec, estimator, production_logger
│   ├── asset_forge/                 # Image/icon generation
│   ├── motion_forge/                # Animation generation
│   ├── sound_forge/                 # Audio generation
│   ├── scene_forge/                 # Level/scene generation
│   ├── brand/                       # DAI-Core Brand System (3-Tier)
│   ├── marketing/                   # Marketing dept (14 agents, 24 tools, 16 adapters)
│   ├── evolution_loop/              # Evolution Loop (6 agents, LDO, scoring, plugins)
│   ├── live_operations/             # Live Operations (14 agents, decision engine, anomaly detection)
│   ├── lines/                       # Production line definitions
│   ├── production_lines/            # Platform-specific templates (iOS/Android/Web/Unity)
│   ├── hq/                          # Factory HQ
│   │   ├── capabilities/            # Feasibility check + reports
│   │   ├── dashboard/               # CEO Cockpit Dashboard (React + Express)
│   │   │   ├── client/              # Vite + React (42 components)
│   │   │   └── server/              # Express (18 API endpoints)
│   │   ├── janitor/                 # Factory janitor (cleanup + health)
│   │   └── gates/                   # CEO gate files
│   └── status/                      # Factory status dashboard (legacy)
│
├── agents/                          # AI agents (Python, AutoGen v0.4+)
├── config/                          # Configuration (roles, toggles, profiles, model router)
├── code_generation/                 # Code extractors (Swift, Kotlin, TypeScript, C#, Python)
├── factory_knowledge/               # 22 knowledge entries (FK-001 to FK-022)
├── docs/                            # 47 documentation files
├── ideas/                           # CEO ideas (.md files)
├── MasterPrompt/                    # Cross-platform command dispatch
├── _commands/                       # Mac <-> Windows command queue
└── DeveloperReports/                # 131+ development reports
```

## Tech Stack

| Component | Technology |
|---|---|
| LLM | Anthropic Claude 100% (Sonnet 4.6 + Haiku 4.5 + Opus 4.6) |
| Framework | Python + AutoGen AgentChat v0.4+ + LiteLLM |
| iOS Line | Swift + SwiftUI + MVVM |
| Android Line | Kotlin + Jetpack Compose + Hilt |
| Web Line | TypeScript + React + Next.js |
| Unity Line | C# + Unity Engine + URP |
| Dashboard | React + Vite + Express + Tailwind (factory-* tokens) |
| Build | xcodegen (iOS), Gradle (Android), npm (Web), Unity CLI |
| Testing | 485 tests (55 files), XCUITest Golden Gates |
| TheBrain | 7 agents, model selection, chain optimizer, auto-splitter |
| Knowledge | Factory Brain (22 entries, cross-project, cross-platform) |

## 3-Tier Model System

| Tier | Model | Tasks |
|---|---|---|
| 1 (Code) | claude-sonnet-4-6 | Code generation, architecture, review |
| 2 (Reasoning) | claude-sonnet-4-6 | Planning, orchestration, content |
| 3 (Lightweight) | claude-haiku-4-5 | Classification, summarization, scoring |

## 18 Departments

| Department | Agents | Description |
|---|---|---|
| Code-Pipeline | 22 | Lead, architects, developers, reviewers, CD, UX, tests |
| Swarm Factory | 27 | Research, strategy, scope, design, roadbook, secretary |
| Live Operations | 14 | Metrics, health scoring, analytics, reviews, support, decisions, anomaly, escalation, updates, releases |
| Marketing | 14 | Brand guardian, strategy, copywriter, naming, ASO, visual, video, publishing, reports, reviews, community, HQ bridge |
| Infrastructure | 11 | HQ assistant, orchestrator, assembly, repair, status, janitor |
| Brain | 7 | Task router, response collector, problem detector, solution proposer, gap analyzer, extension advisor, factory memory |
| Evolution Loop | 6 | Simulation, evaluation, gap detection, decision, regression, orchestration |
| Asset Forge | 1 | Image/icon generation |
| Motion Forge | 1 | Animation generation |
| Sound Forge | 1 | Audio generation |
| Scene Forge | 1 | Level/scene generation |
| Name Gate | 1 | Pre-pipeline name validation |
| QA Forge | 1 | Forge output validation |
| Store Prep | 1 | Store preparation (metadata, screenshots) |
| Store | 1 | Store submission pipeline |
| Signing | 1 | Code signing (iOS/Android/Web) |
| Integration | 1 | Cross-department integration |

## Quick Start

```bash
# CEO Cockpit Dashboard
cd factory/hq/dashboard
node server/index.js &                    # Backend on :3001
cd client && npx vite --host              # Frontend on :3000

# Hybrid pipeline run
python main.py --project askfin_android --profile dev --approval auto --hybrid-pipeline "Generate feature X"

# Factory status
python main.py --factory-status

# Name Gate
python -m factory.name_gate validate "MyAppName"
python -m factory.name_gate generate --idea "AI fitness app"

# Production (via Dashboard or CLI)
python -m factory.integration.production_estimator --spec projects/slug/specs/build_spec.yaml --format json
python -m factory.dispatcher.dispatcher --start-production slug --spec path/to/build_spec.yaml

# Evolution Loop
python main.py --evolution-loop my_project --project-type game --production-line unity

# Feasibility check
python main.py --feasibility-check echomatch

# QA Forge
python -m factory.qa_forge.qa_forge_orchestrator --project echomatch --synthetic --save
```

## Swarm Factory: Autonomous Product Pipeline

6-chapter pipeline from raw idea to production-ready product. Only 2 human decisions needed (CEO Gate + Visual Review).

| Chapter | Agents | Output |
|---|---|---|
| Phase 1: Pre-Production | 7 | Trend, competitor, audience, concept, legal, risk reports |
| Kapitel 3: Market Strategy | 5 | Platform, monetization, marketing, release, cost reports |
| Kapitel 4: MVP Scope | 3 | Features, Phase A/B prioritization, screen list |
| Kapitel 5: Design Vision | - | Design system, visual audit |
| Kapitel 6: CD Roadbook | - | Technical roadbook for production |
| Document Secretary | 1 | 9 professional PDF types |

### Products in Pipeline

| Product | Phase 1 | CEO Gate | Strategy | Scope | Design | Roadbook | Feasibility | Production |
|---|---|---|---|---|---|---|---|---|
| GrowMeldAI | Done | GO | Done | Done | Done | Done | 0.88 | Gate Pending |
| EchoMatch | Done | GO | Done | Done | -- | -- | -- | -- |
| SkillSense | Done | Pending | -- | -- | -- | -- | -- | -- |

## Production Pipeline

```
[Production Gate GO] -> POST /api/production/start
  -> python -m factory.dispatcher.dispatcher --start-production <slug>
  -> FactoryOrchestrator.execute_plan(production_logger=logger)
  -> ProductionLogger -> production_log.jsonl
  -> SSE Stream -> Live Production Dashboard (cost, screens, agent feed)
```

- **ProductionLogger**: JSONL append-only log with step/phase/production lifecycle events
- **Live Dashboard**: Real-time cost tracking, screen progress grid, agent activity feed
- **Orchestrator**: 5-layer decomposition (Foundation -> Domain -> Application -> Presentation -> Polish)

## Evolution Loop

Iterative quality improvement system with 6 agents, LDO (Loop Data Object) communication, plugin system (Game + Business), CEO Review Gate, and cross-project Factory Learner.

```
Build + QA -> OrchestratorHandoff -> LDO
  -> SimulationAgent -> EvaluationAgent -> GapDetector
  -> DecisionAgent -> RegressionTracker -> LoopOrchestrator
  -> CEO Review Gate -> Factory Learner
```

## Live Operations

Post-launch monitoring and management with 14 agents across 6h decision cycles, 30min anomaly scans, and continuous monitoring mode.

- **Agents**: MetricsCollector, HealthScorer, Analytics, ReviewManager, SupportAgent, DecisionEngine, AnomalyDetector, EscalationManager, UpdatePlanner, FactoryAdapter, ReleaseManager
- **Self-Healing**: SystemHealthMonitor (5 checks), SelfHealer (5 actions), retry_on_failure
- **Test Harness**: Synthetic Fleet Generator (15 apps, 8 scenarios), Stress-Test Suite

## Two-Agent System

- **Windows Agent**: Factory operations, prompt quality gate, command dispatch
- **Mac Agent**: Xcode build, simulator testing, runtime validation, golden gates
- **Communication**: Git-based `_commands/` queue + `MasterPrompt/` dispatch

## Development History

| Phase | Reports | Milestone |
|---|---|---|
| Factory Core | 1-41 | 21 agents, 14 proof runs, auto-repair pipeline |
| Compile-to-Ship | 42-70 | 0 compile errors, 100% clean parse |
| Runtime Validation | 71-84 | Xcode build, simulator, golden gates |
| Feature Expansion | 85-112 | Quarantine cleanup, insight-to-action loop |
| Adaptive Learning | 113-122 | Real questions, confidence, learning signals |
| App Store Prep | 123-131 | Metadata, privacy, screenshots, launch strategy |
| Multi-Platform | Steps 1-23 | 5 extractors, orchestrator, brain, 3 projects |
| Assembly + Repair | Steps 24-37 | Android 537 .kt, Web 197 .ts, 90% auto-fix |
| TheBrain + Hybrid | Steps A1-C1 | 4 providers, 9 models, $63->$0.08/run |
| Store + Mac Bridge | Phase 3b | Store pipeline, Mac agent, Unity line |
| Swarm Factory | Phase 1-6 | 6-chapter autonomous pipeline, 27 agents |
| QA + Signing | Phase 13+ | QA forge, signing pipeline, feasibility check |
| Dashboard + Janitor | Phase HQ | CEO Cockpit (42 components), janitor, team view |
| Marketing | Phase 1-9 | 14 agents, 24 tools, 16 adapters, feature-complete |
| Evolution Loop | P-EVO-001-023 | 6 agents, iterative quality loop, plugins |
| Live Operations | Phase 1-6 | 14 agents, decision engine, self-healing, test harness |
| Name Gate | NGO-01 | 6 checks, traffic light, auto-generate, dashboard UI |
| Production Pipeline | Prompts 1-6 | Roadbook-to-Spec, Estimator, Briefing, Live Dashboard, Wiring |
