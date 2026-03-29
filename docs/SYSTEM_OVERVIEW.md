# DriveAI-AutoGen -- System Overview

Last Updated: 2026-03-29

---

## What Is This?

A **Multi-Agent AI App Factory** that autonomously builds mobile and web apps from a single idea. The factory handles everything: market research, legal review, strategy, design, code generation, QA, signing, store submission, marketing, and iterative quality improvement.

---

## Factory Architecture

```
CEO Idea
  -> Swarm Factory (6 Chapters: Research -> Strategy -> Scope -> Design -> Roadbook)
  -> Feasibility Check (Can we build this?)
  -> Production (Code Generation via Hybrid Pipeline)
  -> QA (Compile Hygiene, Type Stubs, Shape Repair, Forge QA)
  -> Assembly (Platform-specific packaging)
  -> Signing (Credentials -> Version -> Build -> Artifacts)
  -> Store Prep (Metadata, Screenshots, Privacy)
  -> Store Submission
  -> Marketing (Brand, Content, Campaigns, Publishing)
  -> Evolution Loop (Iterative Quality Improvement)
```

---

## Key Numbers

| Metric | Value |
|---|---|
| Total Agents | 93 (86 active, 4 disabled, 3 planned) |
| Departments | 16 |
| Production Lines | 5 (iOS, Android, Web, Unity, Python) |
| LLM Provider | Anthropic Claude (100%) |
| LLM Models | 3-Tier: Sonnet 4.6 + Haiku 4.5 + Opus 4.6 |
| Pipeline Cost | $0.08/run (was $63, 788x cheaper) |
| Python Files | 444 (in factory/) |
| Total LOC | 95,506 (in factory/) |
| Documentation | 46 docs, 131+ dev reports |
| Factory Knowledge | 22 entries (FK-001 to FK-022) |
| Evolution Loop | 50 .py, 9,042 LOC, 15 test files |
| Marketing | 54 .py, 12,653 LOC, 11 agents + 7 tools + 9 adapters |

---

## 16 Departments

| Department | Agents | Purpose |
|---|---|---|
| Code-Pipeline | 18 | Lead, architects, developers, reviewers, CD, UX, tests |
| Swarm Factory | 27 | Pre-production, market strategy, MVP scope, design, roadbook, secretary |
| Brain | 7 | Task router, response collector, problem detector, solution proposer, gap analyzer, extension advisor, factory memory |
| Infrastructure | 8 | HQ assistant, orchestrator, assembly, repair, status, promotion, mac bridge, janitor |
| Marketing | 11 | Brand guardian, strategy, copywriter, naming, ASO, visual designer, video script, publishing, reports, reviews, community |
| Evolution Loop | 6 | Simulation, evaluation, gap detection, decision, regression tracking, loop orchestration |
| Asset Forge | 1 | Image/icon generation |
| Motion Forge | 1 | Animation generation |
| Sound Forge | 1 | Audio generation |
| Scene Forge | 1 | Level/scene generation |
| QA Forge | 1 | Forge output validation (4 checkers + design compliance) |
| Store Prep | 1 | Store preparation (metadata, screenshots, privacy) |
| Store | 1 | Store submission pipeline |
| Signing | 1 | Code signing (iOS/Android/Web) |
| Live Operations | - | App registry, metrics collection, health scoring |
| Integration | 1 | Cross-department integration |

---

## Swarm Factory Pipeline (6 Chapters)

| Chapter | Agents | Output |
|---|---|---|
| 1: Pre-Production | 7 | Trend, competitor, audience, concept, legal, risk -> CEO Gate |
| 3: Market Strategy | 5 | Platform, monetization, marketing, release, cost |
| 4: MVP Scope | 3 | Features (72), prioritization (Phase A/B), screens (22) |
| 5: Design Vision | - | Design system, visual audit |
| 6: CD Roadbook | - | Technical roadbook for production |
| Secretary | 1 | 9 professional PDF types |

---

## Production Pipeline (Code Generation)

```
Spec -> Hybrid Pipeline (Implementation -> Bug Review -> CD Review -> UX Psychology -> Refactor -> Tests -> Fix)
  -> Operations Layer (Output Integrator -> Compile Hygiene -> Type Stubs -> Shape Repair -> Swift Compile -> Recovery)
  -> Assembly (Platform-specific build)
  -> Repair Engine (Deterministic -> LLM -> CEO Escalation)
```

### Operations Layer
- **Output Integrator**: 5-layer dedup (filename + type-level + markdown sanitization)
- **Compile Hygiene**: 6 checks (FK-011 to FK-017), column-aware, memberwise-init
- **Type Stub Generator**: Auto-stubs for FK-014 (missing type declarations)
- **Property Shape Repairer**: Auto-repair FK-013 (0-property structs)
- **Top-Level Sanitizer**: FK-019 (code outside struct/class/enum)
- **Import Hygiene**: Foundation + Combine + SwiftUI auto-import

---

## Evolution Loop (P-EVO-001 to P-EVO-023)

Iterative quality improvement system. 50 Python files, 9,042 LOC, 15 test files.

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

### Components
| Component | Description |
|---|---|
| LDO Schema | 15 dataclasses, JSON-serializable, sole communication medium |
| Scoring | Bug, Roadbook, Structural, Performance, UX + Plugin Scores |
| Plugin System | Dynamic loading per project type (Game: 2 plugins, Business: 1 plugin) |
| CEO Review Gate | ReviewProvider ABC, HumanReviewProvider (file-based), swappable for AI |
| Tracking | GitTagger (annotated tags, rollback), CostTracker (per-agent, per-iteration) |
| Factory Learner | Cross-project queries, similar issues, lessons per type, cross-stats |
| Adapters | QA-to-LDO + Orchestrator Handoff |

---

## TheBrain (Model Intelligence)

7 agents (BRN-01 to BRN-07):
- **BRN-01 Task Router**: 2-stage classification (keyword + LLM fallback), 8 route categories
- **BRN-02 Response Collector**: 9 deterministic processors, LLM for multi-response
- **BRN-03 Problem Detector**: 10 detection rules, 100% deterministic
- **BRN-04 Solution Proposer**: 10 solution generators, 3 approval levels
- **BRN-05 Gap Analyzer**: Deep analysis with DIR-001 4-stage logic
- **BRN-06 Extension Advisor**: Gap analyses -> executable roadmaps
- **BRN-07 Factory Memory**: Long-term memory (event log, knowledge base, pattern store)

Additional systems:
- **ModelRegistry**: 9 models, 4 providers
- **ModelEvolution**: Auto-discovery + registration + tier cascade
- **Directives**: DIR-001 Self-First (build everything in-house)
- **3-Tier System**: Sonnet (Code+Reasoning), Haiku (Lightweight), Opus (Premium)

---

## Marketing Department (Phase 1-4 COMPLETE)

11 agents, 7 tools, 9 adapters. 54 Python files, 12,653 LOC.

**Tools**: Template Engine, Video Pipeline, Content Calendar, Ranking DB, Social Analytics, KPI Tracker, HQ Bridge
**Adapters**: YouTube, TikTok, X, App Store, Google Play + 4 stubs

---

## Post-Production Pipeline

### Feasibility Check
- Capability Sheet vs Roadbook Matching (deterministic, no LLM)
- Results: feasible -> proceed, partially_feasible -> CEO gate, not_feasible -> park

### Signing Pipeline
- Per-platform: Credential Check -> Version Bump -> Build/Sign -> Artifact Storage
- iOS (iOSSigner via Mac Bridge), Android (AndroidSigner), Web (WebBuilder)

### QA Forge (Phase 13)
- 4 Checkers: Visual Diff, Audio Check, Animation Timing, Scene Integrity
- Design Compliance: 12 auto-checks + 5 CEO manual checks

---

## Dashboard (Factory HQ)

React + Express web dashboard with 19 components:
- **Pipeline**: Project grid, project detail, progress bars
- **Gates**: CEO gate inbox, feasibility gates, decision UI
- **Janitor**: Scanner results, consistency checks, dependency health
- **Assistant**: Chat panel (21 tools: 14 factory + 7 TheBrain)
- **Team**: Agent overview (enriched, tier/provider filter, capability chips)
- **Brain**: TheBrain COO-level awareness (6 tabs)

---

## Two-Agent System

- **Windows Agent**: Factory operations, quality gate, command dispatch
- **Mac Agent**: Xcode build, simulator testing, runtime validation, golden gates
- **Communication**: Git-based `_commands/` queue + `MasterPrompt/` dispatch

---

## Products

| Product | Platform | Status |
|---|---|---|
| AskFin Premium | iOS (Swift/SwiftUI) | App Store Prep (75% ready) |
| AskFin Android | Kotlin/Compose | 204 files, 4 features |
| AskFin Web | TypeScript/React | Spec ready |
| EchoMatch | Swarm Pipeline | 10 PDFs generated, all chapters complete |
| SkillSense | Swarm Pipeline | Phase 1 complete, CEO gate pending |

---

## CLI Reference (main.py)

```bash
# Pipeline
--factory-status              # CEO dashboard
--factory-queue               # Pipeline queue
--factory-summary             # 5-line summary

# Code Generation
--template <t> --name <N>     # Single template run
--pack <p> --name <N>         # Task pack
--profile dev|standard|premium
--project <name>

# TheBrain
--brain-models                # Model overview
--brain-chain                 # Chain profile
--brain-health                # Provider health
--brain-costs                 # Cost tracking
--brain-evolution-dry|force   # Auto model evolution

# Evolution Loop
--evolution-loop <project>    # Run evolution loop
--evolution-status <project>  # Current status
--evolution-history <project> # Iteration history
--evolution-ceo-review <project>  # CEO review brief

# Feasibility
--feasibility-check <project>
--capability-sheet
--recheck-parked

# Signing
--sign <project> --platform <p>
--check-credentials --platform <p>
--show-version / --bump-version / --list-artifacts

# Store / Mac / Orchestrator / Assembly / QA Forge
--store-readiness <project>
--mac-build <project> / --mac-test <project>
--orchestrate-dry <project> / --orchestrate-layered-dry <project>
--assemble <project>
python -m factory.qa_forge.qa_forge_orchestrator --project <p> --synthetic --save
```

---

## Documentation Index (docs/)

46 files covering:
- Architecture, agents, commands, roadmap
- Factory intake, operating guide, control center
- Premium product principles, learning loop
- Creative director integration, knowledge system
- Operations layer (output integrator, completion verifier, recovery, run memory)
- Compile hygiene, swift compile check
- Error patterns, UX psychology
- Feature index, project state, UX flow
- Evolution Loop roadbook (ROADBOOK_EVOLUTION_LOOP.md)
- Live operations roadbook (DAI-Core_Live-Operations_Roadbook_v1.0.md)
