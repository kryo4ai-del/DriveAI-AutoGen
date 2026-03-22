# DriveAI-AutoGen

Multi-agent AI App Factory built with Microsoft AutoGen and 100% Anthropic Claude. Builds iOS, Android, and Web apps autonomously from specs.

## Current Product: AskFin Premium

**"Nutze Fin und sage Ja"** — AI-powered iOS coaching app for German driver's license exam preparation.

### Status: App Store Prep Complete

| Metric | Value |
|---|---|
| Xcode Build | SUCCEEDED |
| Golden Gates | 15 Gates, 0 Failures |
| XCUITests | 20+ automated |
| Questions | 173 real exam questions |
| Reports | 131 development reports |
| Submission Blockers | App Icon + Developer Account |

### 4 Product Pillars

1. **Training Mode** — Adaptive question practice (3 modes: daily, topic, weakness)
2. **Exam Simulation** — Timed 30-question mock exam with gap analysis
3. **Skill Map** — Competency tracking per category with real confidence data
4. **Readiness Score** — 0-100% exam readiness assessment

### Key Features

- Adaptive learning with weakness-based question selection
- Per-question learning signal persistence
- Insight-to-Action loop: Exam → Gap Analysis → Drilldown → Targeted Training
- Full state persistence across cold restart
- Automated screenshot generation for App Store

## Structure

```
DriveAI-AutoGen/
├── agents/                    # 21 AI agents (Python, AutoGen v0.4+)
├── projects/
│   ├── askfin_v1-1/           # AskFin Premium iOS (234 Swift files, App Store ready)
│   ├── askfin_android/        # AskFin Android (204 Kotlin files, 4 features built)
│   └── askfin_web/            # AskFin Web (TypeScript/React, spec ready)
├── factory/
│   ├── pipeline/              # Extracted pipeline runner
│   ├── orchestrator/          # Build planner (flat + layered + quality gates)
│   ├── brain/                 # Cross-project knowledge store (22 FK entries)
│   ├── operations/            # Compile hygiene, type stubs, shape repair, sanitizer
│   ├── status/                # Factory status dashboard
│   ├── pre_production/        # Swarm Factory Phase 1: Pre-Production Pipeline (7 Agents)
│   ├── market_strategy/       # Swarm Factory Kapitel 3: Market Strategy Pipeline (5 Agents)
│   ├── mvp_scope/             # Swarm Factory Kapitel 4: MVP & Feature Scope (3 Agents)
│   ├── document_secretary/    # Agent 13: Professional PDF Generator (9 Types)
│   └── promotion_advisor.py   # Run promotion policy
├── code_generation/
│   ├── extractors/            # Platform extractors (Swift, Kotlin, TypeScript, Python)
│   ├── code_extractor.py      # Original Swift extraction (battle-tested)
│   └── project_integrator.py  # Content-aware file routing
├── config/
│   ├── platform_roles/        # ios.json, android.json, web.json
│   ├── llm_profiles.json      # dev (Haiku) / standard (Sonnet) / premium (Opus)
│   └── agent_roles.json       # Agent system messages
├── factory_knowledge/         # 22 knowledge entries (FK-001 to FK-022)
├── MasterPrompt/              # Cross-platform command dispatch
├── _commands/                 # Mac <-> Windows command queue (65+ commands)
└── DeveloperReports/          # 100+ development reports
```

## Tech Stack

| Component | Technology |
|---|---|
| LLM | 4 Providers: Anthropic, OpenAI, Google, Mistral (9 models) |
| Framework | Python + AutoGen AgentChat v0.7.5 + LiteLLM |
| iOS Line | Swift + SwiftUI + MVVM |
| Android Line | Kotlin + Jetpack Compose + Hilt |
| Web Line | TypeScript + React + Next.js |
| Unity Line | C# + Unity Engine + URP |
| Build | xcodegen (iOS), Gradle (Android), npm (Web), Unity CLI (Unity) |
| Testing | XCUITest Golden Gates (15 gates), Jest, JUnit |
| TheBrain | Model selection, chain optimizer, auto-splitter, price monitor |
| Knowledge | Factory Brain (25 entries, cross-project, cross-platform) |

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

# TheBrain model overview
python main.py --brain-models

# Store readiness check
python main.py --store-readiness askfin_v1-1

# Mac build (if Mac agent running)
python main.py --mac-build askfin_v1-1

# Orchestrator layered build
python main.py --orchestrate-layered-dry askfin_android

# Assembly + repair
python main.py --assemble askfin_android
```

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
| Multi-Platform Factory | Steps 1-23 | Pipeline extraction, 4 extractors, orchestrator, brain |
| Assembly + Repair | Steps 24-37 | Android 537 .kt, Web 197 .ts, RepairEngine (90% auto-fix) |
| **TheBrain + Hybrid** | **Steps A1-C1, B0** | **4 providers, 9 models, $63→$0.08/run (788x cheaper)** |
| **Store + Mac Bridge** | **Latest** | **Store pipeline, Mac Build Agent, Unity line, 7 departments** |

## Multi-Platform Architecture (Phase 2)

The factory now supports 3 production lines from a single codebase:

```
                    ┌─────────────────┐
                    │  Factory Brain   │  22 cross-project learnings
                    │   (knowledge)    │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │   Orchestrator   │  Spec → Build Plan → Execute
                    │  (layered/flat)  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────┴──────┐ ┌────┴──────┐ ┌─────┴───────┐
     │  iOS Line     │ │ Android   │ │  Web Line   │
     │  Swift/SwiftUI│ │ Kotlin/   │ │ TypeScript/ │
     │  234 files    │ │ Compose   │ │ React/Next  │
     │  App Store ✅ │ │ 204 files │ │ Spec ready  │
     └───────────────┘ └───────────┘ └─────────────┘
```

## Swarm Factory: Autonomous Product Pipeline

Fully autonomous pipeline from raw idea to investor-grade documents.

### Phase 1: Pre-Production (7 Agents)
```
CEO Idea → Memory → [Trend + Competitor + Audience] → Concept Brief → Legal → Risk → CEO Gate
```

### Kapitel 3: Market Strategy (5 Agents)
```
Phase 1 Output → [Platform + Monetization] → [Marketing + Release] → Cost Calculation
```

### Kapitel 4: MVP & Feature Scope (3 Agents)
```
All 11 Reports → Feature Extraction (72 Features) → Prioritization (Phase A/B/Backlog) → Screen Architecture (22 Screens, 7 Flows)
```

### Document Secretary (Agent 13)
Generates 9 professional PDF document types:
- CEO Briefing Phase 1 & 2
- Marketing Konzept (agency-grade)
- Investor Summary
- Technical Brief
- Legal & Compliance Summary
- Feature List (with tech-stack check)
- MVP Scope (Phase A/B split + budget validation)
- Screen Architecture (screens, flows, edge cases)

```bash
# Run full pipeline (Phase 1 → CEO Gate → Kapitel 3 → Kapitel 4 → PDFs)
python -m factory.pre_production.pipeline --idea "Your app idea" --title "AppName"
python -m factory.pre_production.ceo_gate --run-dir factory/pre_production/output/001_appname --decision GO
python -m factory.market_strategy.pipeline --run-dir factory/pre_production/output/001_appname
python -m factory.mvp_scope.pipeline --p1-dir factory/pre_production/output/001_appname --p2-dir factory/market_strategy/output/001_appname
python -m factory.document_secretary.secretary --type all --p1-dir factory/pre_production/output/001_appname --p2-dir factory/market_strategy/output/001_appname --k4-dir factory/mvp_scope/output/001_appname

# Or use --idea-file for ideas from disk
python -m factory.pre_production.pipeline --idea-file ideas/SkillSense.md --title "SkillSense"
```

### Products in Pipeline
| Product | Phase 1 | CEO Gate | Kapitel 3 | Kapitel 4 | PDFs |
|---|---|---|---|---|---|
| EchoMatch | Run #003 ✅ | **GO** ✅ | Run #001 ✅ | Run #001 ✅ | 10 PDFs ✅ |
| SkillSense | Run #004 ✅ | Pending | — | — | — |

## 5-Stage Validation Strategy

| Stage | Description | Status |
|---|---|---|
| 1 | AskFin on ALL platforms autonomously | iOS ✅ Android 537 files, Web 197 files |
| 2 | AskFin v2 (improved by Brain learnings) | Not started |
| 3 | New app (Gaming) without intervention | Not started |
| 4 | Intelligence + Validation layers | Not started |
| 5 | Deployment + Operations automation | Not started |
