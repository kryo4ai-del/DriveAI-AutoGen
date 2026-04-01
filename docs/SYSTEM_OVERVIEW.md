# DriveAI-AutoGen -- System Overview

Last Updated: 2026-04-02

---

## What Is This?

A **Multi-Agent AI App Factory** that autonomously builds mobile and web apps from a single idea. The factory handles everything: market research, legal review, strategy, design, code generation, QA, signing, store submission, marketing, and iterative quality improvement.

---

## Factory Architecture

```
CEO Idea
  -> Name Gate (Pre-Pipeline Name Validation, 6 Checks)
  -> Swarm Factory (6 Chapters: Research -> Strategy -> Scope -> Design -> Roadbook)
  -> Auto-Feasibility Check (Can we build this?)
  -> [Production Gate] (CEO Briefing: Cost/Duration/Scope)
  -> Production (Code Generation via Orchestrator + ProductionLogger)
  -> QA (Compile Hygiene, Type Stubs, Shape Repair, Forge QA)
  -> Assembly (Platform-specific packaging)
  -> Signing (Credentials -> Version -> Build -> Artifacts)
  -> Store Prep (Metadata, Screenshots, Privacy)
  -> Store Submission
  -> Marketing (Brand, Content, Campaigns, Publishing)
  -> Evolution Loop (Iterative Quality Improvement)
  -> Live Operations (Metrics, Health, Anomalies, Decisions)
```

---

## Key Numbers

| Metric | Value |
|---|---|
| Total Agents | 111 (104 active, 4 disabled, 3 planned) |
| Departments | 18 |
| Production Lines | 5 (iOS, Android, Web, Unity, Python) |
| LLM Provider | Anthropic Claude (100%) |
| LLM Models | 3-Tier: Sonnet 4.6 + Haiku 4.5 + Opus 4.6 |
| Pipeline Cost | $0.08/run (was $63, 788x cheaper) |
| Python Files | 585 (in factory/) |
| Total LOC | 123,143 (in factory/) |
| Tests | 485 tests in 55 files |
| Documentation | 47 docs, 131+ dev reports |
| Factory Knowledge | 22 entries (FK-001 to FK-022) |
| Dashboard | CEO Cockpit: 42 React components, 18 API endpoints |
| Evolution Loop | 6 agents, iterative quality improvement |
| Marketing | 14 agents + 24 tools + 16 adapters (Phase 9 complete) |
| Live Operations | 14 agents, decision cycles, anomaly detection |
| Name Gate | Pre-pipeline name validation (6 checks, traffic light) |

---

## 18 Departments

| Department | Agents | Purpose |
|---|---|---|
| Code-Pipeline | 22 | Lead, architects, developers, reviewers, CD, UX, tests |
| Swarm Factory | 27 | Pre-production, market strategy, MVP scope, design, roadbook, secretary |
| Live Operations | 14 | Metrics, health scoring, analytics, reviews, support, decisions, anomaly, escalation, updates, releases |
| Marketing | 14 | Brand guardian, strategy, copywriter, naming, ASO, visual, video, publishing, reports, reviews, community, HQ bridge |
| Infrastructure | 11 | HQ assistant, orchestrator, assembly, repair, status, promotion, mac bridge, janitor |
| Brain | 7 | Task router, response collector, problem detector, solution proposer, gap analyzer, extension advisor, factory memory |
| Evolution Loop | 6 | Simulation, evaluation, gap detection, decision, regression tracking, loop orchestration |
| Asset Forge | 1 | Image/icon generation |
| Motion Forge | 1 | Animation generation |
| Sound Forge | 1 | Audio generation |
| Scene Forge | 1 | Level/scene generation |
| Name Gate | 1 | Pre-pipeline name validation (6 checks, traffic light) |
| QA Forge | 1 | Forge output validation (4 checkers + design compliance) |
| Store Prep | 1 | Store preparation (metadata, screenshots, privacy) |
| Store | 1 | Store submission pipeline |
| Signing | 1 | Code signing (iOS/Android/Web) |
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

## Marketing Department (Phase 1-9 COMPLETE, feature-complete)

14 agents, 24 tools, 16 adapters, 20 DB tables. 90 Python files, 24K+ LOC.

**Agents**: Brand Guardian, Strategy, Copywriter, Naming, ASO, Visual Designer, Video Script, Publishing Orchestrator, Report Agent, Review Manager, Community Agent, HQ Bridge, Trend Monitor, Campaign Manager
**Adapters**: YouTube, TikTok, X, App Store, Google Play, Instagram, LinkedIn, Reddit, Twitch + more

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

## CEO Cockpit Dashboard (Factory HQ)

React + Vite + Express web dashboard with 42 components and 18 API endpoints:
- **Pipeline**: Project grid, project detail, progress bars
- **Gates**: CEO gate inbox, feasibility gates, production gate decision UI
- **Production**: Briefing (cost/scope/duration), Live Dashboard (SSE, cost tracker, screen grid, agent feed)
- **Start / Name Gate**: Name validation (6 checks, traffic light), alternatives, suggestions
- **Team**: Agent overview (enriched, 6 sub-components, tier/provider filter, capability chips)
- **LiveOps**: App fleet overview, health scoring, analytics, decision monitor, escalation log, release tracker, weekly reports, system health (11 sub-components)
- **Brain**: TheBrain COO-level awareness (6 tabs)
- **Janitor**: Scanner results, consistency checks, dependency health
- **Showcase**: App showcase gallery
- **Documents**: Document library
- **Marketing**: Marketing overview
- **Assistant**: Chat panel + voice input/output

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
| GrowMeldAI | Swarm Pipeline | Full pipeline complete, Production Gate pending (Feasibility 0.88) |
| EchoMatch | Swarm Pipeline | 10 PDFs, Strategy + Scope complete |
| SkillSense | Swarm Pipeline | Phase 1 complete, CEO gate pending |

---

## Production Pipeline (Prompts 1-6)

Complete end-to-end production wiring:

```
[Production Gate GO] -> POST /api/production/start
  -> python -m factory.dispatcher.dispatcher --start-production <slug>
  -> FactoryOrchestrator.execute_plan(production_logger=logger)
  -> ProductionLogger -> production_log.jsonl (JSONL append-only)
  -> SSE Stream (fs.watch on directory) -> Live Production Dashboard
```

| Component | File | Purpose |
|---|---|---|
| Roadbook-to-Spec | `factory/integration/roadbook_to_spec.py` | CD Roadbook (.md) -> build_spec.yaml |
| Production Estimator | `factory/integration/production_estimator.py` | build_spec -> cost/duration estimate |
| Production Logger | `factory/integration/production_logger.py` | JSONL lifecycle logging for dashboard |
| Production Briefing | `components/Production/ProductionBriefing.jsx` | CEO cost/scope/risk view before GO |
| Live Dashboard | `components/Production/ProductionDashboard.jsx` | SSE real-time progress, costs, agents |
| Dispatcher CLI | `factory/dispatcher/dispatcher.py` (__main__) | CLI entry for production subprocess |

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

47 files covering:
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
- System overview, directory structure
