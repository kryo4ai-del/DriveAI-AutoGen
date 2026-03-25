# DriveAI-AutoGen

Multi-agent AI App Factory built with Microsoft AutoGen, LiteLLM, and 4 LLM providers (Anthropic, OpenAI, Google, Mistral). Builds iOS, Android, Web, and Unity apps autonomously from specs.

## Architecture

```
                    ┌─────────────────┐
                    │    TheBrain     │  9 models, 4 providers
                    │  (model router) │  Quality Priority + Cost Optimization
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │   Orchestrator   │  Spec → Build Plan → Execute
                    │  (layered/flat)  │
                    └────────┬────────┘
                             │
         ┌───────────┬───────┴───────┬───────────┐
         │           │               │           │
    ┌────┴────┐ ┌────┴────┐ ┌───────┴──┐ ┌──────┴───┐
    │  iOS    │ │ Android │ │   Web    │ │  Unity   │
    │ Swift/  │ │ Kotlin/ │ │ TS/React │ │ C#/Unity │
    │ SwiftUI │ │ Compose │ │ Next.js  │ │ URP      │
    │ (Mac)   │ │ (Win)   │ │ (Win)    │ │ (Local)  │
    └─────────┘ └─────────┘ └──────────┘ └──────────┘
```

## Tech Stack

| Component | Technology |
|---|---|
| LLM | 4 Providers: Anthropic, OpenAI, Google, Mistral (9 models) |
| Routing | TheBrain: dynamic model selection (tier + quality + cost) |
| Framework | Python + AutoGen AgentChat v0.7.5 + LiteLLM |
| iOS Line | Swift + SwiftUI + MVVM (via Mac Bridge) |
| Android Line | Kotlin + Jetpack Compose + Hilt (Gradle on Windows) |
| Web Line | TypeScript + React + Next.js (npm on Windows) |
| Unity Line | C# + Unity Engine + URP |
| Testing | XCUITest Golden Gates (iOS), JUnit (Android), Jest (Web) |

## 61 Agents

- **22 Code-Pipeline Agents** (AutoGen-based, 18 active): driveai_lead, ios_architect, swift_developer, reviewer, bug_hunter, refactor_agent, test_generator, creative_director, ux_psychology, and more
- **27 Swarm Factory Agents** (6 pipeline phases): TrendScout, CompetitorScan, MonetizationArchitect, FeatureExtraction, EmotionArchitect, CEORoadbook, etc.
- **12 Infrastructure**: HQ Assistant, LLM Repair Agent, Mac Build Agent, Document Secretary, 4 Assembly Lines, etc.

## Swarm Factory: Autonomous Product Pipeline

6-chapter pipeline from raw idea to investor-grade documents:

```
CEO Idea → Phase 1 (7 Agents) → CEO Gate → K3 Market Strategy (5) → K4 MVP Scope (3)
  → K4.5 Design Vision (3) → K5 Visual Audit (4) → K6 Roadbook Assembly (2) → 15 PDFs
```

### Pipeline Modes
- `--mode vision` (default): No constraints, dream document
- `--mode factory`: Production-constrained (max 20 features, 12 screens, realistic tech stack)

### Products in Pipeline
| Product | Status | Mode |
|---|---|---|
| EchoMatch | Complete (K6 + 10 PDFs) | Vision |
| MemeRun2026 | Complete (K6 + 15 PDFs) | Factory |
| SkillSense | Phase 1 complete, Gate pending | Vision |

## Quick Start

```bash
# Clone + setup
git clone https://github.com/kryo4ai-del/DriveAI-AutoGen.git
cd DriveAI-AutoGen
python -m venv venv && source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
cp .env.example .env  # Add API keys

# Code generation pipeline
python main.py --template feature --name "FeatureName" --profile standard --approval auto --project askfin_v1-1

# Mac build (requires Mac agent running)
python main.py --mac-build breathflow5

# Mac generate + build
python main.py --mac-generate askfin_v1-1 --feature "StudyStreak" --spec "A study streak tracker..." --files "StudyStreakView.swift,StudyStreakViewModel.swift"

# Swarm Factory (full pipeline)
python -m factory.pre_production.pipeline --idea-file ideas/memerun_2026.md --title "MemeRun2026" --mode factory
python -m factory.pre_production.ceo_gate --run-dir factory/pre_production/output/005_memerun2026 --decision GO
python -m factory.market_strategy.pipeline --run-dir factory/pre_production/output/005_memerun2026
python -m factory.mvp_scope.pipeline --latest
python -m factory.design_vision.pipeline --latest
python -m factory.visual_audit.pipeline --latest
python -m factory.roadbook_assembly.pipeline --latest --mode factory
python -m factory.document_secretary.secretary --type all

# Factory status + tools
python main.py --factory-status
python main.py --brain-models
python main.py --store-readiness askfin_v1-1
python main.py --assemble askfin_android
```

## Two-Machine System

- **Windows Agent**: Factory operations, code generation, prompt dispatch, Swarm Factory
- **Mac Agent**: Xcode build, simulator testing, runtime validation, golden gates, iOS assembly
- **Communication**: Git-based `_commands/` queue (JSON files, 15s polling)

## Operations Layer

10-step post-generation validation pipeline:

```
OutputIntegrator → CompletionVerifier → ImportHygiene → PseudocodeSanitizer
  → CompileHygiene → StaleArtifactGuard → TypeStubGen → PropertyShapeRepair
  → SwiftCompileCheck → QualityGateLoop → RunMemory
```

Quality Gate Loop: autonomous 3-iteration repair (Tier 1 deterministic + Tier 2 LLM).

## Cost Efficiency

| Mode | Cost per Run |
|---|---|
| Legacy (SelectorGroupChat) | $63.00 |
| Hybrid Pipeline (TheBrain) | $0.08 |
| Improvement | **788x cheaper** |

## Development History

| Phase | Milestone |
|---|---|
| Factory Core | 21 agents, 14 proof runs, auto-repair pipeline |
| Compile-to-Ship | 0 compile errors, 100% clean parse |
| Runtime Validation | Xcode build, simulator, golden gates |
| Multi-Platform | 4 production lines, 4 extractors, assembly + repair |
| TheBrain | 4 providers, 9 models, chain optimizer, $0.08/run |
| Swarm Factory | 6-chapter pipeline, 24 research agents, 15 PDF types |
| Factory Mode | Production constraints, Quality Priority, autonomous repair |
| Mac Bridge | iOS on Mac, generate_and_build, Git-based queue |
