# DriveAI-AutoGen

Multi-agent AI App Factory with 69 agents across 12 departments. Builds iOS, Android, Web, and Unity apps autonomously from a single idea — including market research, legal review, design, code generation, QA, signing, and store submission.

## Factory at a Glance

| Metric | Value |
|---|---|
| Agents | 69 (62 active, 12 departments) |
| Production Lines | 5 (iOS, Android, Web, Unity, Python) |
| LLM Providers | 4 (Anthropic, OpenAI, Google, Mistral) — 9 models |
| Pipeline Cost | $0.08/run (788x cheaper than legacy) |
| Python Files | 307 in factory/ |
| Documentation | 42 docs, 131+ developer reports |
| Swarm Factory | 6-chapter autonomous pipeline (idea → store-ready) |

## Current Product: AskFin Premium

**"Nutze Fin und sage Ja"** — AI-powered iOS coaching app for German driver's license exam preparation.

| Metric | Value |
|---|---|
| Xcode Build | SUCCEEDED |
| Golden Gates | 15 Gates, 0 Failures |
| XCUITests | 20+ automated |
| Questions | 173 real exam questions |
| App Store Readiness | 75% (missing: App Icon + Developer Account) |

### 4 Product Pillars

1. **Training Mode** — Adaptive question practice (3 modes: daily, topic, weakness)
2. **Exam Simulation** — Timed 30-question mock exam with gap analysis
3. **Skill Map** — Competency tracking per category with real confidence data
4. **Readiness Score** — 0-100% exam readiness assessment

## Structure

```
DriveAI-AutoGen/
├── main.py                          # Entry point (1,449 lines, CLI + pipeline orchestration)
├── projects/
│   ├── askfin_v1-1/                 # AskFin iOS (234 Swift files, App Store ready)
│   ├── askfin_android/              # AskFin Android (204 Kotlin files)
│   └── askfin_web/                  # AskFin Web (TypeScript/React)
├── factory/                         # Factory Core (307 .py files, 35 subdirectories)
│   ├── pipeline/                    # Hybrid Pipeline Runner (SelectorGroupChat + Single-Calls)
│   ├── orchestrator/                # Build planner (flat + layered + quality gates)
│   ├── brain/                       # TheBrain: 9 models, 4 providers, chain optimizer
│   ├── operations/                  # Post-gen: hygiene, stubs, shape repair, sanitizer
│   ├── dispatcher/                  # Pipeline queue manager + product state machine
│   ├── shared/                      # Project registry, pipeline utils
│   ├── assembly/                    # Assembly lines (Android, Web, Unity, iOS via Mac)
│   │   └── repair/                  # 3-tier repair: deterministic → LLM → CEO escalation
│   ├── signing/                     # Signing pipeline: credentials → version → build → artifacts
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
│   ├── hq/                          # Factory HQ
│   │   ├── capabilities/            # Feasibility check (capability sheet + roadbook matching)
│   │   ├── dashboard/               # Web dashboard (React + Express, 18 components)
│   │   ├── janitor/                 # Factory janitor (scanner, consistency, dependencies)
│   │   └── gates/                   # CEO gate files
│   └── status/                      # Factory status dashboard
├── agents/                          # AI agents (Python, AutoGen v0.4+)
├── config/                          # Configuration (roles, toggles, profiles, platform roles)
├── code_generation/                 # Code extractors (Swift, Kotlin, TypeScript, C#, Python)
├── factory_knowledge/               # 22 knowledge entries (FK-001 to FK-022)
├── docs/                            # 42 documentation files
├── ideas/                           # CEO ideas (.md files)
├── MasterPrompt/                    # Cross-platform command dispatch
├── _commands/                       # Mac ↔ Windows command queue
└── DeveloperReports/                # 131+ development reports
```

## Tech Stack

| Component | Technology |
|---|---|
| LLM | 4 Providers: Anthropic, OpenAI, Google, Mistral (9 models) |
| Framework | Python + AutoGen AgentChat v0.4+ + LiteLLM |
| iOS Line | Swift + SwiftUI + MVVM |
| Android Line | Kotlin + Jetpack Compose + Hilt |
| Web Line | TypeScript + React + Next.js |
| Unity Line | C# + Unity Engine + URP |
| Build | xcodegen (iOS), Gradle (Android), npm (Web), Unity CLI |
| Testing | XCUITest Golden Gates (15 gates), Jest, JUnit |
| TheBrain | Model selection, chain optimizer, auto-splitter, price monitor |
| Knowledge | Factory Brain (25 entries, cross-project, cross-platform) |
| Dashboard | React + Express (18 components: pipeline, gates, janitor, assistant) |

## 3-Tier Model System

| Tier | Model | Tasks |
|---|---|---|
| 1 (Code) | claude-sonnet-4-6 | Code generation, architecture, review |
| 2 (Reasoning) | claude-sonnet-4-6 | Planning, orchestration, content |
| 3 (Lightweight) | claude-haiku-4-5 | Classification, summarization, scoring |

## Quick Start

```bash
# Hybrid pipeline run (788x cheaper than legacy)
python main.py --project askfin_android --profile dev --approval auto --hybrid-pipeline "Generate feature X"

# Factory status dashboard
python main.py --factory-status

# Factory pipeline queue
python main.py --factory-queue

# TheBrain model overview
python main.py --brain-models

# Feasibility check
python main.py --feasibility-check echomatch
python main.py --capability-sheet

# Signing
python main.py --sign echomatch --platform all
python main.py --check-credentials --platform ios

# Store readiness
python main.py --store-readiness askfin_v1-1

# QA Forge (synthetic test)
python -m factory.qa_forge.qa_forge_orchestrator --project echomatch --synthetic --save

# Mac build (if Mac agent running)
python main.py --mac-build askfin_v1-1

# Orchestrator layered build
python main.py --orchestrate-layered-dry askfin_android

# Assembly + repair
python main.py --assemble askfin_android
```

## 12 Departments

| Department | Agents | Description |
|---|---|---|
| Code-Pipeline | 22 | Lead, architects, developers, reviewers, CD, UX, tests |
| Swarm Factory | 27 | Research, strategy, scope, design, roadbook, secretary |
| Infrastructure | 11 | Brain, orchestrator, assembly, repair, status, janitor |
| Asset Forge | 1 | Image/icon generation |
| Motion Forge | 1 | Animation generation |
| Sound Forge | 1 | Audio generation |
| Scene Forge | 1 | Level/scene generation |
| QA Forge | 1 | Forge output validation |
| Store Prep | 1 | Store preparation (metadata, screenshots) |
| Store | 1 | Store submission pipeline |
| Signing | 1 | Code signing (iOS/Android/Web) |
| Integration | 1 | Cross-department integration |

## Two-Agent System

- **Windows Agent**: Factory operations, prompt quality gate, command dispatch
- **Mac Agent**: Xcode build, simulator testing, runtime validation, golden gates
- **Communication**: Git-based `_commands/` queue + `MasterPrompt/` dispatch

## Swarm Factory: Autonomous Product Pipeline

6-chapter pipeline from raw idea to production-ready product.

```
Idea → Phase 1 (Research) → CEO Gate → Kapitel 3 (Strategy) → Kapitel 4 (Scope)
  → Kapitel 5 (Design) → Kapitel 6 (Roadbook) → Feasibility Check → Production
  → QA → Signing → Store Prep → Submission
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
| SkillSense | #004 | Pending | — | — | — |

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
| TheBrain + Hybrid | Steps A1-C1 | 4 providers, 9 models, $63→$0.08/run |
| Store + Mac Bridge | Phase 3b | Store pipeline, Mac agent, Unity line |
| Swarm Factory | Phase 1-6 | 6-chapter autonomous pipeline, 27 agents |
| QA + Signing | Phase 13+ | QA forge, signing pipeline, feasibility check |
| **Dashboard + Janitor** | **Latest** | **HQ dashboard, janitor, 69 agents, 12 departments** |

## Multi-Platform Architecture

```
                    ┌─────────────────┐
                    │  Factory Brain   │  25 cross-project learnings
                    │  (4 providers)   │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │   Orchestrator   │  Spec → Build Plan → Execute
                    │  (layered/flat)  │
                    └────────┬────────┘
                             │
         ┌───────────┬───────┴───────┬───────────┐
         │           │               │           │
    ┌────┴───┐  ┌────┴───┐  ┌───────┴──┐  ┌─────┴──┐
    │  iOS   │  │Android │  │   Web    │  │ Unity  │
    │ Swift  │  │ Kotlin │  │ TS/React │  │  C#    │
    │ 234 f  │  │ 204 f  │  │ Spec ✓   │  │ Line ✓ │
    └────────┘  └────────┘  └──────────┘  └────────┘
```

## 5-Stage Validation Strategy

| Stage | Description | Status |
|---|---|---|
| 1 | AskFin on ALL platforms autonomously | iOS App Store ready, Android 204 files, Web spec ready |
| 2 | AskFin v2 (improved by Brain learnings) | Not started |
| 3 | New app (Gaming) without intervention | Not started |
| 4 | Intelligence + Validation layers | Not started |
| 5 | Deployment + Operations automation | Not started |
