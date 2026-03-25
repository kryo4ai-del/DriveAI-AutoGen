# DriveAI-AutoGen - Projektkontext

## Projektuebersicht
- **Name**: DriveAI-AutoGen (Multi-Platform AI App Factory + TheBrain)
- **Typ**: Multi-Agent AI System (Python) + iOS/Android/Web/Unity App Generation
- **Repo**: GitHub `kryo4ai-del/DriveAI-AutoGen`
- **Lokal Windows**: `C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\`
- **Lokal Mac**: `/Users/andreasott/DriveAI-AutoGen/`
- **Besitzer**: Andreas Ott

## Tech-Stack
- **LLM Provider**: 4 Provider — Anthropic, OpenAI, Google, Mistral (9 Modelle)
- **Routing**: TheBrain (dynamische Modellwahl pro Agent + Profil + Quality Score)
- **Framework**: Python + AutoGen AgentChat v0.4+ + LiteLLM
- **API Keys**: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GOOGLE_API_KEY`, `MISTRAL_API_KEY` in `.env`

## TheBrain Modell-System
| Tier | Modelle | Aufgaben |
|---|---|---|
| Low (dev/fast) | mistral-small, gemini-2.5-flash, claude-haiku-4-5, gpt-4o-mini | classification, summarization, trend_analysis |
| Mid (standard) | o3-mini, claude-sonnet-4-6, gpt-4o, gemini-2.5-pro | code_generation, architecture, planning, review |
| High (premium) | claude-opus-4-6 | complex_reasoning, quality-critical tasks |

### Quality Priority System
- Lines mit `quality_priority` in project.yaml bekommen bessere Modelle fuer Code-Tasks
- iOS (Quality Score 1.0) → immer claude-sonnet-4-6 statt billiges Mid-Tier
- Quality Score beeinflusst NUR code-generierende Tasks, nicht Reviews/Summaries

## 5 Production Lines
| Line | Language | Framework | Assembly | Build |
|---|---|---|---|---|
| iOS | Swift | SwiftUI + MVVM | xcodegen → Xcode | Mac Bridge (Git-Queue) |
| Android | Kotlin | Jetpack Compose + Hilt | Gradle | Windows (gradle assembleDebug) |
| Web | TypeScript | React + Next.js | npm | Windows (npx tsc + Jest) |
| Unity | C# | Unity Engine + URP | Unity CLI | Lokal (nicht shipped) |
| Backend | Python | FastAPI + Pydantic | pip | Docker / Cloud Run |

## Projektstruktur
```
DriveAI-AutoGen/
├── main.py                          ← Einstiegspunkt (AutoGen Pipeline + CLI)
├── CLAUDE.md                        ← Diese Datei
├── MEMORY.md                        ← Aenderungs-Log
│
├── projects/                        ← Generierte Projekte
│   ├── askfin_v1-1/                 ← AskFin Premium iOS (255 Swift Files)
│   ├── askfin_android/              ← AskFin Android (Kotlin)
│   ├── askfin_web/                  ← AskFin Web (TypeScript/React)
│   ├── breathflow/...breathflow5/   ← BreathFlow Generationen
│   ├── brainpuzzle/                 ← BrainPuzzle
│   ├── echomatch/                   ← EchoMatch
│   └── skillsense/                  ← SkillSense
│
├── factory/                         ← Factory Core
│   ├── pipeline/                    ← Pipeline Runner + Operations Layer
│   ├── orchestrator/                ← Build-Planer (flat + layered + quality gates)
│   ├── brain/                       ← TheBrain: Modell-Provider + Service-Provider + Knowledge
│   │   ├── model_provider/          ← 9 Modelle, 4 Provider, Registry, ChainOptimizer, AutoSplitter
│   │   └── service_provider/        ← Image/Sound/Video Adapter (DALL-E, Stability, ElevenLabs)
│   ├── operations/                  ← Post-Generation Validierung + Auto-Repair
│   │   ├── compile_hygiene_validator.py  ← FK-011 bis FK-017 Checks
│   │   ├── quality_gate_loop.py     ← Autonome 3-Iteration Repair Loop (Tier 1 deterministisch + Tier 2 LLM)
│   │   ├── type_stub_generator.py   ← Automatische Stubs fuer FK-014
│   │   ├── property_shape_repairer.py  ← FK-013 Struct-Reparatur
│   │   ├── stale_artifact_guard.py  ← Quarantine alter Artefakte
│   │   └── toplevel_sanitizer.py    ← Pseudocode-Entfernung
│   ├── assembly/                    ← Assembly Lines + Repair
│   │   ├── lines/                   ← ios_line.py, android_line.py, web_line.py, unity_line.py
│   │   ├── repair/                  ← RepairEngine + 5 Fix-Strategien + LLM Repair
│   │   └── handoff_protocol.py      ← Production Handoff
│   ├── hq/                          ← Factory HQ
│   │   ├── assistant/               ← HQ Assistant (Agent 25, claude-sonnet-4-6, ElevenLabs Voice, Persistent Memory)
│   │   ├── dashboard/               ← React Dashboard (Node.js Express, 12 Seiten)
│   │   ├── janitor/                 ← Factory Janitor (INF-13, Autonome Code-Wartung)
│   │   │   ├── janitor.py           ← Orchestrator + CLI (daily/weekly/monthly)
│   │   │   ├── scanner.py           ← Stufe 1: File-Scanner (10 Checks)
│   │   │   ├── graph_builder.py     ← Stufe 2: Abhaengigkeits-Graph (AST + Regex)
│   │   │   ├── analyzer.py          ← Problem-Erkennung (5 Analysen)
│   │   │   ├── deep_analyzer.py     ← Stufe 3: LLM-Tiefenanalyse (monatlich)
│   │   │   ├── executor.py          ← Aktionen: Auto-Fix / Proposal / Report
│   │   │   ├── config.json          ← Scan-Pfade, Schwellenwerte, Safety-Levels
│   │   │   ├── quarantine/          ← Entfernte Dateien (7 Tage wiederherstellbar)
│   │   │   ├── proposals/           ← Offene CEO-Vorschlaege
│   │   │   └── reports/             ← Scan-Reports (daily/weekly/monthly)
│   │   ├── gate_api.py              ← Gate-System (create/wait/decide)
│   │   └── health_monitor.py        ← Factory Health Checks
│   ├── pre_production/              ← Phase 1: Pre-Production (7 Agents)
│   ├── market_strategy/             ← Kapitel 3: Market Strategy (5 Agents)
│   ├── mvp_scope/                   ← Kapitel 4: MVP & Feature Scope (3 Agents)
│   ├── design_vision/               ← Kapitel 4.5: Design Vision (3 Agents)
│   ├── visual_audit/                ← Kapitel 5: Visual Audit (4 Agents)
│   ├── roadbook_assembly/           ← Kapitel 6: CEO + CD Roadbook (2 Agents)
│   │   └── factory_constraints.md   ← Factory Mode Constraints
│   ├── document_secretary/          ← 15 PDF-Typen (Playwright/Chromium)
│   ├── store/                       ← Store Pipeline (Metadata, Compliance, Submission)
│   ├── mac_bridge/                  ← Mac Command Sender (build_ios, generate_and_build)
│   ├── dispatcher/                  ← Product Queue Manager
│   ├── asset_forge/                 ← Asset Generation + Varianten
│   ├── integration/                 ← CD Forge Interface + Build Plan v2 + Full Pipeline (Phase 12)
│   │   ├── cd_forge_interface.py    ← Maps CD Roadbook Features → Forge Requirements (LLM)
│   │   ├── build_plan_schema.py     ← BuildPlan v2: Forge+Code Steps, Parallel Groups, Validator
│   │   ├── forge_orchestrator.py    ← Koordiniert alle 4 Forges (Group A parallel, Group B nach A)
│   │   ├── platform_asset_mapper.py ← Plattform-spezifische Pfade + Code-Referenzen (4 Platforms)
│   │   ├── asset_integrator.py      ← Kopiert Forge-Outputs in Projektstruktur, erzeugt IntegrationMap
│   │   ├── full_pipeline_orchestrator.py ← End-to-End: Roadbook → Forges → Integration → Code Ready
│   │   ├── build_plans/             ← Gespeicherte Forge Requirements + Build Plans (JSON)
│   │   ├── maps/                    ← Integration Maps + Pipeline Results (JSON)
│   │   └── backend_line/            ← Line 5: Python/FastAPI Backend Generation
│   │       ├── python_extractor.py  ← Python Code Extractor (AST-basiert, 102 Known Types)
│   │       └── backend_assembly_line.py ← Generiert 8-File FastAPI Projekt (Firebase/JWT)
│   ├── scene_forge/                 ← Scene/Level/Shader/Prefab Generation (Phase 11)
│   │   ├── scene_spec_extractor.py  ← 4 Spec-Dataclasses + LLM Extraction aus Roadbook PDFs
│   │   ├── level_generator.py       ← Match-3 Level Generation (Difficulty Curve, BFS Reachability)
│   │   ├── unity_scene_writer.py    ← Unity .unity Scene File Generator (Custom YAML)
│   │   ├── shader_generator.py      ← URP HLSL Shader Generator (3 Templates + Custom Fallback)
│   │   ├── prefab_generator.py      ← Unity .prefab Generator (YAML + .meta)
│   │   ├── scene_validator.py       ← Deterministische Validierung (4 Dateitypen, kein LLM)
│   │   ├── scene_catalog_manager.py ← Katalog + scene_manifest.json + Dedup Guard
│   │   ├── scene_forge_orchestrator.py ← End-to-End Pipeline (7 Steps) + CLI
│   │   ├── utils/                   ← unity_guid, unity_fileid, yaml_serializer
│   │   ├── level_templates/         ← 4 Level Templates (standard, obstacles, timed, cascade)
│   │   ├── shader_templates/        ← 3 URP Shader Templates (unlit, bloom_emission, dissolve)
│   │   ├── specs/                   ← Extracted Scene Manifests (JSON)
│   │   ├── catalog/                 ← Organized Catalog per Project (levels/scenes/shaders/prefabs)
│   │   └── generated/               ← Generated Scenes, Shaders, Prefabs, Levels
│   ├── motion_forge/                ← Animation: Specs + Lottie + Platforms + Validator + Catalog + Orchestrator
│   │   ├── anim_spec_extractor.py   ← AnimSpec + AnimManifest aus Roadbook PDFs
│   │   ├── lottie_writer.py         ← 4 Modi: Template/Composition/Custom LLM/External
│   │   ├── template_composer.py     ← Merges 2-3 Lottie Templates
│   │   ├── platform_adapter.py      ← iOS/Android (Lottie copy), Web (CSS), Unity (C#)
│   │   ├── animation_validator.py   ← Deterministic QA (5 Checks, kein LLM)
│   │   ├── animation_catalog_manager.py ← Catalog + Manifest + Combined CSS
│   │   ├── motion_forge_orchestrator.py ← End-to-End Pipeline CLI
│   │   └── templates/               ← 12 Lottie JSON Templates
│   └── project_config.py            ← LineConfig + ProjectConfig + Quality Priority
│
├── agents/                          ← 22 AutoGen Agents (18 aktiv, 4 disabled)
├── config/                          ← Konfiguration
│   ├── platform_roles/              ← ios.json, android.json, web.json, unity.json, backend.json
│   ├── platform_role_resolver.py    ← Compile Contract Injection fuer Code-Agents
│   ├── model_router.py              ← Agent→Task→Tier Mapping
│   └── agent_roles.json             ← Agent System Messages
├── mac_agent/                       ← Mac Build Agent (xcodebuild, SwiftRepairEngine)
├── code_generation/                 ← Code Extractors (Swift, Kotlin, TypeScript)
│   └── code_extractor.py            ← 112 Framework-Types Blocklist
├── factory_knowledge/               ← 26 Knowledge Entries
├── ideas/                           ← CEO-Ideen (.md Dateien)
├── _commands/                       ← Mac ↔ Windows Command Queue (Git-basiert)
│   ├── pending/                     ← Wartende Commands (.json)
│   └── completed/                   ← Erledigte Commands (.json)
├── delivery/                        ← Sprint Reports + Run Manifests
├── _logs/                           ← Shared Logs (Mac ↔ Windows via Git)
└── venv/                            ← Python Virtual Environment
```

## Agents (61 gesamt)

### Code-Pipeline Agents (22 registriert, 18 aktiv)
Alle nutzen `create_model_client()` → TheBrain → Fallback Anthropic Sonnet.

| Agent | Task Type | Default Tier | Status |
|---|---|---|---|
| driveai_lead | planning | Mid (Sonnet) | aktiv |
| ios_architect | architecture | Mid (Sonnet) | aktiv |
| swift_developer | code_generation | Mid (Sonnet) | aktiv |
| reviewer | code_review | Mid (Sonnet) | aktiv |
| bug_hunter | bug_hunting | Mid (Sonnet) | aktiv |
| refactor_agent | refactoring | Mid (Sonnet) | aktiv |
| test_generator | test_generation | Mid (Sonnet) | aktiv |
| creative_director | creative_direction | Mid (Sonnet) | aktiv |
| ux_psychology | ux_psychology_review | Mid (Sonnet) | aktiv |
| product_strategist | classification | Low (Haiku) | aktiv |
| roadmap_agent | planning | Mid (Sonnet) | aktiv |
| content_script_agent | content_generation | Mid (Sonnet) | aktiv |
| change_watch_agent | trend_analysis | Low (Haiku) | aktiv |
| accessibility_agent | accessibility_review | Mid (Sonnet) | aktiv |
| opportunity_agent | trend_analysis | Low (Haiku) | aktiv |
| legal_risk_agent | compliance_review | Mid (Sonnet) | aktiv |
| project_bootstrap_agent | planning | Mid (Sonnet) | aktiv |
| autonomous_project_orchestrator | orchestration | Mid (Sonnet) | aktiv |
| android_architect | architecture | Mid (Sonnet) | disabled |
| kotlin_developer | code_generation | Mid (Sonnet) | disabled |
| web_architect | architecture | Mid (Sonnet) | disabled |
| webapp_developer | code_generation | Mid (Sonnet) | disabled |

### Swarm Factory Pipeline Agents (27 Agents in 6 Phasen)
Alle nutzen `_call_llm()` → TheBrain → Fallback `claude-sonnet-4-6`.

| Phase | Agents | Anzahl |
|---|---|---|
| Phase 1 (Pre-Production) | TrendScout, CompetitorScan, AudienceAnalyst, ConceptAnalyst, LegalResearch, RiskAssessment, MemoryAgent | 7 |
| Kapitel 3 (Market Strategy) | PlatformStrategy, MonetizationArchitect, MarketingStrategy, ReleasePlanner, CostCalculation | 5 |
| Kapitel 4 (MVP Scope) | FeatureExtraction, FeaturePrioritization, ScreenArchitect | 3 |
| Kapitel 4.5 (Design Vision) | EmotionArchitect, TrendBreaker, VisionCompiler | 3 |
| Kapitel 5 (Visual Audit) | AssetDiscovery, AssetStrategy, VisualConsistency, ReviewAssistant | 4 |
| Kapitel 6 (Roadbook) | CEORoadbook, CDRoadbook | 2 |

### Infrastruktur (13)
| Agent/Service | Modell | Typ |
|---|---|---|
| HQ Assistant (Agent 25) | hardcoded claude-sonnet-4-6 | Direct Anthropic API + ElevenLabs Voice |
| LLM Repair Agent | hardcoded claude-haiku-4-5 | Assembly Repair |
| CEO Gate | TheBrain | Entscheidungs-Agent |
| Document Secretary | TheBrain | 15 PDF-Typen |
| Mac Build Agent | kein LLM | Git-Queue Executor |
| Daily Briefing | TheBrain | Report Generator |
| Factory Janitor (INF-13) | hardcoded claude-sonnet-4-6 (nur monatlich) | Autonome Code-Wartung |
| 4 Assembly Lines | kein LLM | Build Orchestratoren |

## Swarm Factory Pipeline (Autonome Produkt-Pipeline)

### Ablauf
```
CEO-Idee → Phase 1 (Pre-Production, 7 Agents) → CEO-Gate (GO/KILL)
  → Kapitel 3 (Market Strategy, 5 Agents)
  → Kapitel 4 (MVP Scope, 3 Agents)
  → Kapitel 4.5 (Design Vision, 3 Agents)
  → Kapitel 5 (Visual Audit, 4 Agents)
  → Kapitel 6 (Roadbook Assembly, 2 Agents) → CEO + CD Roadbook
  → Document Secretary → 15 PDFs
```

### Pipeline Mode: Vision vs Factory
- `--mode vision` (Default): Keine Einschraenkungen, Dream-Dokument
- `--mode factory`: Production-Constraints (max 20 Features, max 12 Screens, realistischer Tech-Stack)
- Mode wird automatisch durch alle Phasen durchgereicht via `run_config.json`
- Factory Constraints: `factory/roadbook_assembly/factory_constraints.md`

### Produkte in der Pipeline
| Produkt | Phase 1 | Gate | K3 | K4 | K4.5 | K5 | K6 | PDFs |
|---|---|---|---|---|---|---|---|---|
| EchoMatch | #003 | GO | #001 | #001 | — | — | #001 | 10 |
| SkillSense | #004 | Pending | — | — | — | — | — | — |
| MemeRun2026 | #005 (factory) | GO | #003 | #003 | #002 | #003 | #007 | 15 |

## Operations Layer Pipeline
```
Output Integrator → Completion Verifier → Import Hygiene → Pseudocode Sanitizer
  → Compile Hygiene Validator → Stale Artifact Guard → Type Stub Generator
  → Property Shape Repairer → Swift Compile Check → Quality Gate Loop
  → Run Memory → Knowledge Writeback
```

### Quality Gate Loop (neu)
- Sitzt nach Step 9, ersetzt den alten Recovery Loop
- Tier 1: Deterministische Repairs (Import Hygiene, StubGen, Shape Repair — kostenlos)
- Tier 2: LLM Repair via RepairEngine (nur wenn Tier 1 nicht reicht)
- Max 3 Iterationen, dann CEO Escalation Report
- 0 BLOCKING → Fast-Path (Loop ueberspringen)

## Swift Compile Contract
- Definiert in `config/platform_roles/ios.json` als `compile_contract`
- 6 Regeln: Imports, keine Placeholder, keine Framework-Typ-Files, keine Duplikate, Entry Point, Valid Syntax
- Wird injected in: swift_developer, ios_architect, refactor_agent, bug_hunter, test_generator
- Code Extractor Blocklist: 112 Framework-Types (SwiftUI, Foundation, Combine, UIKit)

## Mac Bridge
- **build_ios**: xcodegen + xcodebuild + SwiftRepairEngine (5 Iterationen)
- **generate_and_build**: LLM Code-Generierung + Compile auf Mac
- **run_tests**: XCUITest via xcodebuild test
- **screenshots**: Test-Suite "screenshots"
- **archive**: xcodebuild archive (Debug)
- Kommunikation: `_commands/pending/*.json` → Git Push → Mac pollt → `_commands/completed/*.json`
- iOS Line auf Windows: disabled (Status in project.yaml), Mac uebernimmt

## iOS auf Mac (askfin_v1-1)
- iOS Line in project.yaml: `status: disabled` (Mac Assembly Factory uebernimmt)
- Mac-Generate: `python main.py --mac-generate askfin_v1-1 --feature "Name" --spec "..." --files "..."`
- Compile Contract wird automatisch aus ios.json geladen
- StudyStreak + FocusTimer bereits via Mac generiert und gebaut (0 Compile Errors)

## CLI Quick Reference
```bash
# Code-Pipeline
python main.py --template feature --name FeatureName --profile standard --approval auto --project askfin_v1-1

# Mac Build
python main.py --mac-build breathflow5

# Mac Generate + Build
python main.py --mac-generate askfin_v1-1 --feature "Name" --spec "Spec text" --files "File1.swift,File2.swift"

# Swarm Factory
python -m factory.pre_production.pipeline --idea-file ideas/app.md --title "AppName" --mode factory
python -m factory.pre_production.ceo_gate --run-dir factory/pre_production/output/005_appname --decision GO
python -m factory.market_strategy.pipeline --run-dir factory/pre_production/output/005_appname
python -m factory.mvp_scope.pipeline --latest
python -m factory.design_vision.pipeline --latest
python -m factory.visual_audit.pipeline --latest
python -m factory.roadbook_assembly.pipeline --latest --mode factory

# PDFs
python -m factory.document_secretary.secretary --type all

# Factory Janitor (Code-Hygiene)
python -m factory.hq.janitor daily       # Taeglicher Scan ($0.00)
python -m factory.hq.janitor weekly      # Woechentlich + Auto-Fixes ($0.00)
python -m factory.hq.janitor monthly     # Monatliche LLM-Tiefenanalyse (~$0.50-2.00)
python -m factory.hq.janitor status      # Letzter Report + offene Proposals
python -m factory.hq.janitor restore <path>  # Datei aus Quarantaene wiederherstellen
python -m factory.hq.janitor proposals   # Offene Vorschlaege anzeigen

# Scene Forge (Levels/Scenes/Shaders/Prefabs)
python -m factory.scene_forge.scene_spec_extractor --roadbook-dir <path> --project EchoMatch
python -m factory.scene_forge.level_generator --campaign 10 --seed 42
python -m factory.scene_forge.scene_forge_orchestrator --project echomatch --roadbook-dir <path> --budget 0.50
python -m factory.scene_forge.scene_forge_orchestrator --project echomatch --dry-run
python -m factory.scene_forge.scene_forge_orchestrator --project echomatch --estimate-cost
python -m factory.scene_forge.scene_forge_orchestrator --project echomatch --only levels,shaders

# Full Pipeline (Roadbook → Forges → Integration → Code Ready)
python -m factory.integration.full_pipeline_orchestrator --project echomatch --roadbook-dir <path> --platform unity --dry-run
python -m factory.integration.full_pipeline_orchestrator --project echomatch --roadbook-dir <path> --platform unity --budget 3.00 --forges-only
python -m factory.integration.full_pipeline_orchestrator --project echomatch --roadbook-dir <path> --platform unity --estimate-cost
python -m factory.integration.full_pipeline_orchestrator --project echomatch --roadbook-dir <path> --platform unity --skip asset_forge

# Motion Forge (Animations)
python -m factory.motion_forge.motion_forge_orchestrator --project echomatch --roadbook-dir <path> --budget 0.50
python -m factory.motion_forge.motion_forge_orchestrator --project echomatch --dry-run
python -m factory.motion_forge.motion_forge_orchestrator --project echomatch --estimate-cost
python -m factory.motion_forge.motion_forge_orchestrator --project echomatch --anim-id MI-001
python -m factory.motion_forge.motion_forge_orchestrator --project echomatch --category micro_interaction

# Assembly
python main.py --assemble askfin_android
python main.py --factory-status
python main.py --brain-models
```

## Quality Gate
> **PFLICHT bei jedem Prompt.** Regeln: `~/.claude/docs/QUALITY-GATE.md`
> Vor Ausfuehrung pruefen: Konzept-Konsistenz, Overengineering, Scope-Drift, Fehler, Kosten-Nutzen.

## Konventionen
- Sprache mit User: Deutsch
- Commit-Messages: Englisch
- Keine unnuetigen Nachfragen — einfach machen
- Alle Aenderungen in MEMORY.md dokumentieren
- `_commands/` fuer Mac ↔ Windows Austausch via Git
