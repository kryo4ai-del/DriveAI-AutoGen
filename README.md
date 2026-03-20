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
│   ├── market_strategy/       # Swarm Factory Phase 2: Market Strategy Pipeline (5 Agents)
│   ├── document_secretary/    # Agent 13: Professional PDF Generator (6 Types)
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
| LLM | Anthropic Claude (Sonnet 4.6 + Haiku 4.5 + Opus 4.6) |
| Framework | Python + AutoGen AgentChat v0.7.5 |
| iOS Line | Swift + SwiftUI + MVVM |
| Android Line | Kotlin + Jetpack Compose + Hilt |
| Web Line | TypeScript + React + Next.js |
| Build (iOS) | xcodegen → Xcode 26.3 |
| Testing | XCUITest Golden Gates (15 gates, 0 failures) |
| Knowledge | Factory Brain (22 entries, cross-project) |

## 3-Tier Model System

| Tier | Model | Tasks |
|---|---|---|
| 1 (Code) | claude-sonnet-4-6 | Code generation, architecture, review |
| 2 (Reasoning) | claude-sonnet-4-6 | Planning, orchestration, content |
| 3 (Lightweight) | claude-haiku-4-5 | Classification, summarization, scoring |

## Quick Start

```bash
# iOS run (auto-infers project from projects/)
python main.py --template feature --name <Name> --profile standard --approval auto

# Android run
python main.py --project askfin_android --template feature --name <Name> --profile dev --approval auto

# Factory status dashboard
python main.py --factory-status

# Orchestrator dry-run (layered build plan)
python main.py --orchestrate-layered-dry askfin_android

# Golden Gates (Mac only)
cd projects/askfin_v1-1 && bash scripts/run_golden_gates.sh
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
| **Multi-Platform Factory** | **Steps 1-23** | **Pipeline extraction, 3 extractors, orchestrator, brain, Android build (204 .kt files)** |

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

### Phase 2: Market Strategy (5 Agents)
```
Phase 1 Output → [Platform + Monetization] → [Marketing + Release] → Cost Calculation
```

### Document Secretary (Agent 13)
Generates 6 professional PDF document types:
- CEO Briefing Phase 1 & 2
- Marketing Konzept (agency-grade)
- Investor Summary
- Technical Brief
- Legal & Compliance Summary

```bash
# Run full pipeline
python -m factory.pre_production.pipeline --idea "Your app idea" --title "AppName"
python -m factory.pre_production.ceo_gate --run-dir factory/pre_production/output/001_appname --decision GO
python -m factory.market_strategy.pipeline --run-dir factory/pre_production/output/001_appname
python -m factory.document_secretary.secretary --type all --p1-dir factory/pre_production/output/001_appname --p2-dir factory/market_strategy/output/001_appname
```

### First Product: EchoMatch
- Phase 1 Run #003: 6 reports, CEO Gate: **GO**
- Phase 2 Run #001: 5 reports
- 6 professional PDFs generated (CEO, Investor, Marketing, Tech, Legal)

## 5-Stage Validation Strategy

| Stage | Description | Status |
|---|---|---|
| 1 | AskFin on ALL platforms autonomously | iOS ✅ Android partial, Web pending |
| 2 | AskFin v2 (improved by Brain learnings) | Not started |
| 3 | New app (Gaming) without intervention | Not started |
| 4 | Intelligence + Validation layers | Not started |
| 5 | Deployment + Operations automation | Not started |
