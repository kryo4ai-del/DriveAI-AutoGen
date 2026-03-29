# DriveAI-AutoGen

Multi-agent AI App Factory with 93 agents across 16 departments. Builds iOS, Android, Web, and Unity apps autonomously from a single idea -- including market research, legal review, design, code generation, QA, signing, store submission, marketing, and iterative quality improvement.

## Factory at a Glance

| Metric | Value |
|---|---|
| Agents | 93 (86 active, 16 departments) |
| Production Lines | 5 (iOS, Android, Web, Unity, Python) |
| LLM Provider | Anthropic Claude (100% -- 3-Tier: Sonnet/Haiku/Opus) |
| Pipeline Cost | $0.08/run (788x cheaper than legacy) |
| Python Files | 444 in factory/ (95,506 LOC) |
| Documentation | 46 docs, 131+ developer reports |
| Swarm Factory | 6-chapter autonomous pipeline (idea -> store-ready) |
| Marketing | 11 agents + 7 tools + 9 adapters (E2E pipeline) |
| Evolution Loop | 6 agents, iterative quality improvement (50 .py, 9,042 LOC) |

## Current Product: AskFin Premium

**"Nutze Fin und sage Ja"** -- AI-powered iOS coaching app for German driver's license exam preparation.

| Metric | Value |
|---|---|
| Xcode Build | SUCCEEDED |
| Golden Gates | 15 Gates, 0 Failures |
| XCUITests | 20+ automated |
| Questions | 173 real exam questions |
| App Store Readiness | 75% (missing: App Icon + Developer Account) |

### 4 Product Pillars

1. **Training Mode** -- Adaptive question practice (3 modes: daily, topic, weakness)
2. **Exam Simulation** -- Timed 30-question mock exam with gap analysis
3. **Skill Map** -- Competency tracking per category with real confidence data
4. **Readiness Score** -- 0-100% exam readiness assessment

## Structure

```
DriveAI-AutoGen/
├── main.py                          # Entry point (1,729 lines, CLI + pipeline orchestration)
├── projects/
│   ├── askfin_v1-1/                 # AskFin iOS (234 Swift files, App Store ready)
│   ├── askfin_android/              # AskFin Android (204 Kotlin files)
│   └── askfin_web/                  # AskFin Web (TypeScript/React)
├── factory/                         # Factory Core (444 .py files, 95,506 LOC)
│   ├── pipeline/                    # Hybrid Pipeline Runner
│   ├── orchestrator/                # Build planner (flat + layered + quality gates)
│   ├── brain/                       # TheBrain: 7 agents, model registry, chain optimizer
│   ├── operations/                  # Post-gen: hygiene, stubs, shape repair, sanitizer
│   ├── dispatcher/                  # Pipeline queue manager + product state machine
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
│   ├── asset_forge/                 # Image/icon generation
│   ├── motion_forge/                # Animation generation
│   ├── sound_forge/                 # Audio generation
│   ├── scene_forge/                 # Level/scene generation
│   ├── brand/                       # DAI-Core Brand System (3-Tier)
│   ├── marketing/                   # Marketing dept (54 .py, 12,653 LOC)
│   ├── evolution_loop/              # Evolution Loop (50 .py, 9,042 LOC)
│   │   ├── ldo/                     # LDO Schema + Storage + Validator
│   │   ├── scoring/                 # Hard + Soft Scores + Aggregator
│   │   ├── adapters/                # QA-to-LDO + Orchestrator Handoff
│   │   ├── gates/                   # CEO Review Gate (Human + AI Provider)
│   │   ├── tracking/               # Git Tagger + Cost Tracker
│   │   ├── plugins/                # Plugin System (Game + Business)
│   │   └── tests/                  # 15 test files
│   ├── live_operations/             # Live Operations Layer
│   ├── hq/                          # Factory HQ
│   │   ├── capabilities/            # Feasibility check
│   │   ├── dashboard/               # Web dashboard (React + Express, 19 components)
│   │   ├── janitor/                 # Factory janitor
│   │   └── gates/                   # CEO gate files
│   └── status/                      # Factory status dashboard
├── agents/                          # AI agents (Python, AutoGen v0.4+)
├── config/                          # Configuration (roles, toggles, profiles, model router)
├── code_generation/                 # Code extractors (Swift, Kotlin, TypeScript, C#, Python)
├── factory_knowledge/               # 22 knowledge entries (FK-001 to FK-022)
├── docs/                            # 46 documentation files
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
| Build | xcodegen (iOS), Gradle (Android), npm (Web), Unity CLI |
| Testing | XCUITest Golden Gates (15 gates), Jest, JUnit |
| TheBrain | 7 agents, model selection, chain optimizer, auto-splitter |
| Knowledge | Factory Brain (22 entries, cross-project, cross-platform) |
| Dashboard | React + Express (19 components: pipeline, gates, janitor, brain, team) |

## 3-Tier Model System

| Tier | Model | Tasks |
|---|---|---|
| 1 (Code) | claude-sonnet-4-6 | Code generation, architecture, review |
| 2 (Reasoning) | claude-sonnet-4-6 | Planning, orchestration, content |
| 3 (Lightweight) | claude-haiku-4-5 | Classification, summarization, scoring |

## Quick Start

```bash
# Hybrid pipeline run
python main.py --project askfin_android --profile dev --approval auto --hybrid-pipeline "Generate feature X"

# Factory status dashboard
python main.py --factory-status

# TheBrain model overview
python main.py --brain-models

# Evolution Loop
python main.py --evolution-loop my_project --project-type game --production-line unity
python main.py --evolution-status my_project
python main.py --evolution-history my_project
python main.py --evolution-ceo-review my_project

# Feasibility check
python main.py --feasibility-check echomatch

# Signing
python main.py --sign echomatch --platform all

# Store readiness
python main.py --store-readiness askfin_v1-1

# QA Forge (synthetic test)
python -m factory.qa_forge.qa_forge_orchestrator --project echomatch --synthetic --save

# Mac build (if Mac agent running)
python main.py --mac-build askfin_v1-1
```

## 16 Departments

| Department | Agents | Description |
|---|---|---|
| Code-Pipeline | 18 | Lead, architects, developers, reviewers, CD, UX, tests |
| Swarm Factory | 27 | Research, strategy, scope, design, roadbook, secretary |
| Brain | 7 | Task router, response collector, problem detector, solution proposer, gap analyzer, extension advisor, factory memory |
| Infrastructure | 8 | HQ assistant, orchestrator, assembly, repair, status, janitor |
| Marketing | 11 | Brand guardian, strategy, copywriter, naming, ASO, visual designer, video script, publishing, reports, reviews, community |
| Evolution Loop | 6 | Simulation, evaluation, gap detection, decision, regression, orchestration |
| Asset Forge | 1 | Image/icon generation |
| Motion Forge | 1 | Animation generation |
| Sound Forge | 1 | Audio generation |
| Scene Forge | 1 | Level/scene generation |
| QA Forge | 1 | Forge output validation |
| Store Prep | 1 | Store preparation (metadata, screenshots) |
| Store | 1 | Store submission pipeline |
| Signing | 1 | Code signing (iOS/Android/Web) |
| Live Operations | - | App registry, metrics, health scoring |
| Integration | 1 | Cross-department integration |

## Evolution Loop (P-EVO-001 to P-EVO-023)

Iterative quality improvement system. Automatically analyzes build artifacts, detects gaps, generates tasks, tracks regressions, and escalates to CEO when needed.

```
Build + QA -> OrchestratorHandoff -> LDO
  -> SimulationAgent (Static Analysis + Plugins)
  -> EvaluationAgent (Hard + Soft + Plugin Scores)
  -> GapDetector (Score-based + Regression Gaps)
  -> DecisionAgent (Gaps -> Tasks, CEO Feedback -> Tasks)
  -> RegressionTracker (Trend + Mode: Sprint -> Deep -> Pivot)
  -> LoopOrchestrator (Stop Conditions, Budget, Git Tags)
  -> CEO Review Gate (Human/AI Provider)
  -> Factory Learner (Cross-Project Analysis)
```

### Key Components
- **LDO (Loop Data Object)**: 15 dataclasses, JSON-serializable, sole communication medium
- **Plugin System**: Dynamic loading per project type (Game: 2 plugins, Business: 1 plugin)
- **CEO Review Gate**: Pluggable provider (Human file-based, AI swappable)
- **Factory Learner**: Cross-project queries, similar issues search, lessons per type
- **15 test files**, ~80 tests total

## Swarm Factory: Autonomous Product Pipeline

6-chapter pipeline from raw idea to production-ready product.

```
Idea -> Phase 1 (Research) -> CEO Gate -> Kapitel 3 (Strategy) -> Kapitel 4 (Scope)
  -> Kapitel 5 (Design) -> Kapitel 6 (Roadbook) -> Feasibility Check -> Production
  -> QA -> Signing -> Store Prep -> Submission
```

### Chapters

| Chapter | Agents | Output |
|---|---|---|
| Phase 1: Pre-Production | 7 | Trend, competitor, audience, concept, legal, risk reports |
| Kapitel 3: Market Strategy | 5 | Platform, monetization, marketing, release, cost reports |
| Kapitel 4: MVP Scope | 3 | 72 features, Phase A/B prioritization, 22 screens |
| Kapitel 5: Design Vision | - | Design system, visual audit |
| Kapitel 6: CD Roadbook | - | Technical roadbook for production |
| Document Secretary | 1 | 9 professional PDF types |

### Products in Pipeline

| Product | Phase 1 | CEO Gate | Kap. 3 | Kap. 4 | PDFs |
|---|---|---|---|---|---|
| EchoMatch | #003 | **GO** | #001 | #001 | 10 PDFs |
| SkillSense | #004 | Pending | -- | -- | -- |

## Marketing Department (Phase 1-4 COMPLETE)

| Agent | Role |
|---|---|
| MKT-01 Brand Guardian | Brand book, style sheets, compliance checks |
| MKT-02 Strategy | Factory narrative, app stories, marketing directives |
| MKT-03 Copywriter | Social media, store listings, blog, ad copy |
| MKT-04 Naming | Name generation, domain/social/store availability |
| MKT-05 ASO | Keyword research, localized listings, competitor analysis |
| MKT-06 Visual Designer | Creative briefs, social media templates, screenshots |
| MKT-07 Video Script | TikTok/YouTube/Reels scripts + video generation |
| MKT-08 Publishing Orchestrator | Cross-platform publishing, adapters (YouTube, TikTok, X) |
| MKT-09 Report Agent | Daily/weekly/monthly marketing reports |
| MKT-10 Review Manager | Two-tier review system (auto + CEO gate) |
| MKT-11 Community Agent | Two-tier social media comment management |

**Tools**: Template Engine, Video Pipeline, Content Calendar, Ranking DB, Social Analytics, KPI Tracker, HQ Bridge
**Adapters**: 5 active + 4 stubs (YouTube, TikTok, X, App Store, Google Play, Instagram, LinkedIn, Reddit, Twitch)

## Two-Agent System

- **Windows Agent**: Factory operations, prompt quality gate, command dispatch
- **Mac Agent**: Xcode build, simulator testing, runtime validation, golden gates
- **Communication**: Git-based `_commands/` queue + `MasterPrompt/` dispatch

## Multi-Platform Architecture

```
                    +------------------+
                    |  TheBrain (7)    |  Model registry, task routing
                    |  + Factory State |
                    +--------+---------+
                             |
                    +--------+---------+
                    |   Orchestrator   |  Spec -> Build Plan -> Execute
                    |  (layered/flat)  |
                    +--------+---------+
                             |
         +-----------+-------+-------+-----------+
         |           |               |           |
    +----+---+  +----+---+  +-------+--+  +-----+--+
    |  iOS   |  |Android |  |   Web    |  | Unity  |
    | Swift  |  | Kotlin |  | TS/React |  |  C#    |
    | 234 f  |  | 204 f  |  | Spec ok  |  | Line ok|
    +--------+  +--------+  +----------+  +--------+
```

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
| Dashboard + Janitor | Phase HQ | HQ dashboard (19 components), janitor, team view |
| Marketing | Phase 1-4 | 11 agents, 7 tools, 9 adapters, 12,653 LOC |
| **Evolution Loop** | **P-EVO-001-023** | **6 agents, iterative quality loop, 9,042 LOC, 80+ tests** |
