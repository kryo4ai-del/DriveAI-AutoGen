# DriveAI-AutoGen

Multi-agent AI App Factory built with Microsoft AutoGen and 100% Anthropic Claude for iOS app development.

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
│   └── askfin_v1-1/           # AskFin Premium iOS App (~200+ Swift files)
│       ├── App/               # App entry point
│       ├── Models/            # Swift data models
│       ├── Services/          # Business logic
│       ├── ViewModels/        # MVVM ViewModels
│       ├── Views/             # SwiftUI Views
│       ├── UITests/           # XCUITests + Golden Gates
│       ├── Resources/         # questions.json + Assets
│       └── scripts/           # run_golden_gates.sh
├── factory/                   # Operations Layer (post-generation validation)
│   └── operations/            # Compile hygiene, type stubs, shape repair
├── factory_knowledge/         # 18 knowledge entries (FK-001 to FK-018)
├── config/                    # LLM config, model router, agent toggles
├── control_center/            # Streamlit Dashboard
├── MasterPrompt/              # Cross-platform command dispatch
│   ├── incomePrompt/          # Incoming prompts
│   ├── processed/             # Executed prompts
│   └── reportAgent/           # Reports (102-0+)
├── _commands/                 # Mac ↔ Windows command queue
└── DeveloperReports/          # Historical reports (1-0 to 101-0)
```

## Tech Stack

| Component | Technology |
|---|---|
| LLM | Anthropic Claude (Sonnet 4.6 + Haiku 4.5) |
| Framework | Python + AutoGen AgentChat v0.4+ |
| iOS App | Swift + SwiftUI + MVVM |
| Build | xcodegen → Xcode 26.3 |
| Testing | XCUITest + Golden Gates |

## 3-Tier Model System

| Tier | Model | Tasks |
|---|---|---|
| 1 (Code) | claude-sonnet-4-6 | Code generation, architecture, review |
| 2 (Reasoning) | claude-sonnet-4-6 | Planning, orchestration, content |
| 3 (Lightweight) | claude-haiku-4-5 | Classification, summarization, scoring |

## Quick Start

```bash
# Factory run (generates iOS code)
python main.py --template feature --name <Name> --profile standard --approval auto

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
