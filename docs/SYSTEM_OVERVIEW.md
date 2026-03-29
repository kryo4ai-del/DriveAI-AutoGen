# DriveAI-AutoGen — System Overview

Last Updated: 2026-03-25

---

## What Is This?

A **Multi-Agent AI App Factory** that autonomously builds mobile and web apps from a single idea. The factory handles everything: market research, legal review, strategy, design, code generation, QA, signing, and store submission preparation.

---

## Factory Architecture

```
CEO Idea
  → Swarm Factory (6 Chapters: Research → Strategy → Scope → Design → Roadbook)
  → Feasibility Check (Can we build this?)
  → Production (Code Generation via Hybrid Pipeline)
  → QA (Compile Hygiene, Type Stubs, Shape Repair, Forge QA)
  → Assembly (Platform-specific packaging)
  → Signing (Credentials → Version → Build → Artifacts)
  → Store Prep (Metadata, Screenshots, Privacy)
  → Store Submission
```

---

## Key Numbers

| Metric | Value |
|---|---|
| Total Agents | 69 (62 active, 4 disabled, 3 planned) |
| Departments | 12 |
| Production Lines | 5 (iOS, Android, Web, Unity, Python) |
| LLM Providers | 4 (Anthropic, OpenAI, Google, Mistral) |
| LLM Models | 9 |
| Pipeline Cost | $0.08/run (was $63, 788x cheaper) |
| Python Files | 307 (in factory/) |
| Documentation | 42 docs, 131+ dev reports |
| Factory Knowledge | 22 entries (FK-001 to FK-022) |

---

## 12 Departments

| Department | Agents | Purpose |
|---|---|---|
| Code-Pipeline | 22 | Lead, architects, developers, reviewers, CD, UX, tests |
| Swarm Factory | 27 | Pre-production, market strategy, MVP scope, design, roadbook, secretary |
| Infrastructure | 11 | Brain, orchestrator, assembly, repair, status, promotion, mac bridge, janitor |
| Asset Forge | 1 | Image/icon generation |
| Motion Forge | 1 | Animation generation |
| Sound Forge | 1 | Audio generation |
| Scene Forge | 1 | Level/scene generation |
| QA Forge | 1 | Forge output validation (4 checkers + design compliance) |
| Store Prep | 1 | Store preparation (metadata, screenshots, privacy) |
| Store | 1 | Store submission pipeline |
| Signing | 1 | Code signing (iOS/Android/Web) |
| Integration | 1 | Cross-department integration |

---

## Swarm Factory Pipeline (6 Chapters)

| Chapter | Agents | Output |
|---|---|---|
| 1: Pre-Production | 7 | Trend, competitor, audience, concept, legal, risk → CEO Gate |
| 3: Market Strategy | 5 | Platform, monetization, marketing, release, cost |
| 4: MVP Scope | 3 | Features (72), prioritization (Phase A/B), screens (22) |
| 5: Design Vision | - | Design system, visual audit |
| 6: CD Roadbook | - | Technical roadbook for production |
| Secretary | 1 | 9 professional PDF types |

---

## Production Pipeline (Code Generation)

```
Spec → Hybrid Pipeline (Implementation → Bug Review → CD Review → UX Psychology → Refactor → Tests → Fix)
  → Operations Layer (Output Integrator → Compile Hygiene → Type Stubs → Shape Repair → Swift Compile → Recovery)
  → Assembly (Platform-specific build)
  → Repair Engine (Deterministic → LLM → CEO Escalation)
```

### Operations Layer
- **Output Integrator**: 5-layer dedup (filename + type-level + markdown sanitization)
- **Compile Hygiene**: 6 checks (FK-011 to FK-017), column-aware, memberwise-init
- **Type Stub Generator**: Auto-stubs for FK-014 (missing type declarations)
- **Property Shape Repairer**: Auto-repair FK-013 (0-property structs)
- **Top-Level Sanitizer**: FK-019 (code outside struct/class/enum)
- **Import Hygiene**: Foundation + Combine + SwiftUI auto-import

---

## TheBrain (Model Intelligence)

- **ModelRegistry**: 9 models, 4 providers
- **ProviderRouter**: LiteLLM-based, unified API
- **AutoSplitter**: Token-limit management, auto-model-switch
- **ChainOptimizer**: Finds cheapest model combination for 0 errors
- **PriceMonitor**: Provider health checks, new model detection
- **3-Tier System**: Sonnet (Code+Reasoning), Haiku (Lightweight), Opus (Premium)

---

## Post-Production Pipeline

### Feasibility Check
- Automatic check between CD Roadbook and Production start
- Capability Sheet (dynamic factory profile) vs Roadbook keywords
- Deterministic, no LLM, cost-free
- Results: feasible (proceed), partially_feasible (CEO gate), not_feasible (park)

### Signing Pipeline
- Per-platform: Credential Check → Version Bump → Build/Sign → Artifact Storage
- iOS (iOSSigner via Mac Bridge), Android (AndroidSigner), Web (WebBuilder)

### QA Forge (Phase 13)
- 4 Checkers: Visual Diff, Audio Check, Animation Timing, Scene Integrity
- Design Compliance: 12 auto-checks (DC-001..012) + 5 CEO manual checks
- QA Forge Orchestrator: All checkers + compliance + verdict

---

## Dashboard (Factory HQ)

React + Express web dashboard with 18 components:
- **Pipeline**: Project grid, project detail, progress bars
- **Gates**: CEO gate inbox, feasibility gates, decision UI
- **Janitor**: Scanner results, consistency checks, dependency health
- **Assistant**: Voice input/output, chat panel
- **Providers**: Service provider management
- **Team**: Agent overview
- **Documents**: Document library
- **Showcase**: Project showcase

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

# Feasibility
--feasibility-check <project> # Run check
--capability-sheet            # Show capabilities
--recheck-parked              # Re-check parked projects

# Signing
--sign <project> --platform <p>  # Build + sign
--check-credentials --platform <p>
--show-version
--bump-version --version-type <t>
--list-artifacts

# Store
--store-readiness <project>

# Mac Bridge
--mac-status
--mac-build <project>
--mac-test <project>

# Orchestrator
--orchestrate-dry <project>
--orchestrate-layered-dry <project>
--show-plan <project>

# Assembly
--assemble <project>

# QA Forge
python -m factory.qa_forge.qa_forge_orchestrator --project <p> --synthetic --save
```

---

## Documentation Index (docs/)

42 files covering:
- Architecture, agents, commands, roadmap
- Factory intake, operating guide, control center
- Premium product principles, learning loop
- Creative director integration, knowledge system
- Operations layer (output integrator, completion verifier, recovery, run memory)
- Compile hygiene, swift compile check
- Error patterns, UX psychology
- Feature index, project state, UX flow
