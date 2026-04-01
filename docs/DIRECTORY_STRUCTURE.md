# DriveAI-AutoGen — Ordnerstruktur

**Stand**: 2026-04-02
**Agents**: 111 (104 aktiv) | **Departments**: 18 | **Lines**: 5
**Python-Dateien**: 585 (factory/) | **LOC**: 123.143 (factory/) | **Tests**: 485 in 55 Dateien
**Dashboard**: 42 React Components, 18 API Endpoints | **docs**: 47 Dateien

> Ausgeblendet: `node_modules/`, `venv/`, `__pycache__/`, `.git/`, Build-Artefakte
> Collapsed `[...]`: Ordner mit vielen generierten Dateien (Anzahl angegeben)

---

```
DriveAI-AutoGen/
|-- .env                              # API Keys (Anthropic, OpenAI, etc.)
|-- .env.example
|-- .gitignore
|-- CLAUDE.md                         # Projekt-spezifische Claude-Anweisungen
|-- MEMORY.md                         # Projekt-Changelog & Erkenntnisse
|-- README.md
|-- main.py                           # Factory Entry Point
|-- requirements.txt
|
|===================================================================
|  DEVELOPER REPORTS & COMMANDS
|===================================================================
|
|-- DeveloperReports/
|   |-- DrivaAI-AutoGen-Handoff.md
|   |-- CodeAgent/                    ... [100 Agent Reports]
|   L-- Steps-MasterLead/             ... [116 MasterLead Steps]
|
|-- _commands/                        ... [~190 Command-Dateien (Swift Compile, Fixes, Gates)]
|   L-- completed/                    ... [15 abgeschlossene Commands]
|
|-- _logs/                            # Status-Logs
|
|===================================================================
|  CORE MODULES (Root-Level)
|===================================================================
|
|-- accessibility/                    # Barrierefreiheit
|   |-- accessibility_manager.py
|   L-- accessibility_reports.json
|
|-- agents/                           # 22 Root-Level Agents
|   |-- agent_*.json                  # Persona-Dateien (22 Stueck)
|   |-- lead_agent.py                 # CEO / Lead
|   |-- autonomous_project_orchestrator.py
|   |-- creative_director.py
|   |-- ios_architect.py / android_architect_agent.py / web_architect_agent.py
|   |-- swift_developer.py / kotlin_developer_agent.py / webapp_developer_agent.py
|   |-- product_strategist.py / ux_psychology.py
|   |-- reviewer.py / bug_hunter.py / test_generator.py
|   |-- refactor_agent.py / change_watch_agent.py
|   |-- content_script_agent.py / legal_risk_agent.py
|   |-- opportunity_agent.py / roadmap_agent.py
|   L-- project_bootstrap_agent.py
|
|-- analytics/                        # Analytics Tracker
|-- bootstrap/                        # Projekt-Bootstrapping
|-- briefings/                        # Daily Briefings (Email, HTML)
|-- code_generation/                  # Code-Extraktion & Integration
|   L-- extractors/                   # Swift, Kotlin, TypeScript, C#, Python
|-- compliance/                       # Legal/Compliance Manager
|-- config/                           # Zentrale Konfiguration
|   |-- llm_config.py                 # LLM-Profile
|   |-- model_router.py               # Model-Routing
|   |-- agent_toggles.json            # Agent An/Aus
|   |-- cost_budgets.json             # Kosten-Budgets
|   |-- session_presets.json           # Session-Vorlagen
|   L-- platform_roles/               # android.json, ios.json, unity.json, web.json
|-- content/                          # Content Manager
|-- control_center/                   # Streamlit Dashboard (Legacy)
|   L-- pages/                        # 19 Dashboard-Seiten
|-- costs/                            # Kosten-Tracking
|-- delivery/                         # Sprint-Reports & Run-Exports
|   L-- exports/                      ... [936 Run-Export-Dateien]
|
|===================================================================
|  DOCS
|===================================================================
|
|-- docs/
|   |-- DIRECTORY_STRUCTURE.md        # <-- Diese Datei
|   |-- FEATURE_INDEX.md              # Feature-Index
|   |-- PROJECT_STATE.md              # Projekt-Status
|   |-- SYSTEM_OVERVIEW.md            # System-Uebersicht
|   |-- UX_FLOW.md                    # UX Flow
|   |-- agents.md                     # Agent-Doku
|   |-- architecture.md               # Architektur-Doku
|   L-- ... (30+ weitere Docs)
|
|===================================================================
|  FACTORY (Kern-System)
|===================================================================
|
|-- factory/
|   |-- __init__.py
|   |-- agent_registry.json           # Zentrales Agent-Register (87 Agents)
|   |-- agent_registry.py             # Registry-Logik
|   |-- capability_registry.py        # Capability Matching (17 Tags)
|   |-- project_config.py / project_registry.py
|   |-- run_mode.py / spec_manager.py
|   |
|   |-- assembly/                     # === ASSEMBLY LINE ===
|   |   |-- assembly_manager.py       # Haupt-Orchestrator
|   |   |-- handoff_protocol.py       # Handoff zwischen Lines
|   |   |-- lines/                    # 5 Assembly Lines
|   |   |   |-- base_line.py          # Basis-Klasse
|   |   |   |-- ios_line.py           # iOS (Swift)
|   |   |   |-- android_line.py       # Android (Kotlin)
|   |   |   |-- web_line.py           # Web (TypeScript)
|   |   |   L-- unity_line.py         # Unity (C#)
|   |   L-- repair/                   # Auto-Repair System
|   |       |-- repair_coordinator.py
|   |       |-- repair_engine.py
|   |       |-- llm_repair_agent.py
|   |       |-- error_parser.py
|   |       |-- fix_strategies/       # 5 Fix-Strategien
|   |       L-- language_profiles/    # Swift, Kotlin, TypeScript
|   |
|   |-- brand/                        # === DAI-CORE BRAND SYSTEM ===
|   |   |-- __init__.py
|   |   |-- brand_loader.py           # Brand Context Loader (3-Tier: Full/Summary/None)
|   |   |-- DAI-CORE_Brand_Bible_v1.0.md  # Vollstaendige Brand Bible (Tier A)
|   |   |-- brand_summary.md          # Kompakte Zusammenfassung (Tier B)
|   |   |-- BRAND_INTEGRATION.md      # Integrations-Guide
|   |   |-- assets/                   # Logo-PNGs (manuell kopieren)
|   |   L-- css/
|   |       L-- brand_variables.css   # CSS Custom Properties
|   |
|   |-- asset_forge/                  # === ASSET FORGE ===
|   |   |-- pipeline.py               # Asset-Pipeline
|   |   |-- spec_extractor.py         # PDF -> Asset Specs
|   |   |-- prompt_builder.py         # Image-Prompts
|   |   |-- variant_generator.py
|   |   |-- catalog_manager.py
|   |   |-- style_checker.py
|   |   |-- output/                   ... [54 generierte Assets]
|   |   L-- templates/                # Prompt-Templates
|   |
|   |-- brain/                        # === THE BRAIN ===
|   |   |-- brain.py                  # Haupt-Brain-Logik
|   |   |-- capability_map.py         # Agent-Faehigkeiten
|   |   |-- factory_state.py          # Factory-Zustand
|   |   |-- state_report.py
|   |   |-- task_router.py            # Task -> Agent Routing
|   |   |-- gap_analyzer.py           # Luecken-Erkennung
|   |   |-- problem_detector.py
|   |   |-- solution_proposer.py
|   |   |-- extension_advisor.py
|   |   |-- response_collector.py
|   |   |-- directives/              # Brain-Direktiven
|   |   |   |-- directive_engine.py
|   |   |   L-- directive_001_self_first.md
|   |   |-- memory/                  # Factory Memory (BRN-07)
|   |   |   |-- factory_memory.py
|   |   |   |-- memory_writer.py
|   |   |   L-- data/                ... [Memory-Daten]
|   |   |-- model_provider/          # Model-Management
|   |   |   |-- provider_router.py    # LLM-Router (Anthropic, OpenAI, etc.)
|   |   |   |-- model_registry.py     # Modell-Register
|   |   |   |-- model_evolution.py    # Auto-Evolution Loop
|   |   |   |-- agent_classifier.py   # Auto-Classification (94.7%)
|   |   |   |-- capability_matcher.py # Capability Matching (17 Tags)
|   |   |   |-- capability_tags.py
|   |   |   |-- auto_splitter.py
|   |   |   |-- chain_optimizer.py / chain_tracker.py
|   |   |   |-- benchmark_runner.py
|   |   |   |-- price_monitor.py / known_prices.py
|   |   |   |-- team_enrichment.py
|   |   |   L-- benchmarks/ chain_profiles/ chain_runs/ health_reports/
|   |   |-- persona/                 # Brain-Persona
|   |   |   L-- brain_system_prompt.py
|   |   L-- service_provider/        # External Service Management
|   |       |-- service_router.py / service_scout.py
|   |       |-- cost_tracker.py / quality_scorer.py
|   |       L-- adapters/            # Service-Adapter
|   |           |-- image/            # DALL-E, Stability, Recraft
|   |           |-- sound/            # ElevenLabs, Suno
|   |           |-- video/            # Runway
|   |           L-- drafts/           # 7 Draft-Adapter
|   |
|   |-- design_vision/               # === DESIGN VISION ===
|   |   |-- pipeline.py
|   |   |-- config.py / input_loader.py
|   |   |-- agents/
|   |   |   |-- emotion_architect.py
|   |   |   |-- trend_breaker.py
|   |   |   L-- vision_compiler.py
|   |   L-- output/                   ... [Design Output]
|   |
|   |-- dispatcher/                   # === DISPATCHER ===
|   |   |-- dispatcher.py             # Projekt-Dispatch
|   |   |-- product_state.py
|   |   L-- project_creator.py
|   |
|   |-- document_secretary/           # === DOCUMENT SECRETARY ===
|   |   |-- secretary.py              # Haupt-Agent
|   |   |-- pdf_builder.py / docx_builder.py
|   |   |-- email_service.py
|   |   |-- output/                   ... [44 generierte Docs]
|   |   L-- templates/                # 15 PDF-Templates
|   |
|   |-- hq/                           # === HQ (Headquarters) ===
|   |   |-- gate_api.py               # CEO Gate API
|   |   |-- health_monitor.py         # System-Health
|   |   |-- auto_repair.py
|   |   |-- assistant/               # HQ Assistant (21 Tools)
|   |   |   |-- assistant.py          # Haupt-Assistent
|   |   |   |-- server.py             # FastAPI Server (Port 3002)
|   |   |   |-- context_builder.py
|   |   |   |-- action_executor.py
|   |   |   L-- brain_tools.py        # TheBrain-Integration
|   |   |-- capabilities/            # Feasibility & Gate System
|   |   |   |-- feasibility_check.py
|   |   |   |-- gate_creator.py
|   |   |   L-- capability_sheet.py / capability_watcher.py
|   |   |-- dashboard/               # React Dashboard
|   |   |   |-- package.json
|   |   |   |-- client/              # Vite + React (Port 3000)
|   |   |   |   |-- src/
|   |   |   |   |   |-- App.jsx
|   |   |   |   |   L-- components/  ... [24 React Components]
|   |   |   |   L-- vite.config.js
|   |   |   L-- server/              ... [Express Server (Port 3001), 22 files]
|   |   |-- gates/                   ... [CEO Gates (pending/decided)]
|   |   |-- janitor/                 ... [Janitor (25 files, proposals/quarantine/reports)]
|   |   |-- logs/
|   |   L-- providers/               # Provider Balance Monitor
|   |
|   |-- integration/                  # === INTEGRATION ===
|   |   |-- forge_orchestrator.py     # Forge-Orchestrator
|   |   |-- full_pipeline_orchestrator.py
|   |   |-- cd_forge_interface.py
|   |   |-- asset_integrator.py
|   |   |-- platform_asset_mapper.py
|   |   L-- backend_line/             # Backend Assembly Line
|   |
|   |-- lines/                        # === PLATFORM LINES ===
|   |   |-- android/ ios/ unity/ web/ # Agent-Personas pro Plattform
|   |
|   |-- mac_bridge/                   # === MAC BRIDGE ===
|   |   |-- mac_bridge.py             # Xcode Build via SSH
|   |   L-- generate_command.py
|   |
|   |-- market_strategy/              # === MARKET STRATEGY ===
|   |   |-- pipeline.py
|   |   |-- agents/
|   |   |   |-- cost_calculation.py
|   |   |   |-- marketing_strategy.py
|   |   |   |-- monetization_architect.py
|   |   |   |-- platform_strategy.py
|   |   |   L-- release_planner.py
|   |   L-- output/                   ... [20 Strategy-Dateien]
|   |
|   |-- marketing/                    # === MARKETING DEPT (groesste Abteilung) ===
|   |   |-- config.py / input_loader.py
|   |   |-- run_step_*.py             # Phase-Runner
|   |   |-- adapters/                # 9 Adapter (5 aktiv + 4 Stubs)
|   |   |   |-- youtube_adapter.py    # YouTube API
|   |   |   |-- tiktok_adapter.py     # TikTok API
|   |   |   |-- x_adapter.py          # X (Twitter) API
|   |   |   |-- appstore_adapter.py   # App Store Connect
|   |   |   |-- googleplay_adapter.py # Google Play Developer
|   |   |   |-- instagram_adapter.py  # Stub
|   |   |   |-- linkedin_adapter.py   # Stub
|   |   |   |-- reddit_adapter.py     # Stub
|   |   |   L-- twitch_adapter.py     # Stub
|   |   |-- agents/                  # 11 Agents (MKT-01 bis MKT-11)
|   |   |   |-- agent_*.json          # 11 Persona-Dateien
|   |   |   |-- strategy.py           # MKT-01 Strategy
|   |   |   |-- copywriter.py         # MKT-02 Copywriter
|   |   |   |-- visual_designer.py    # MKT-03 Visual Designer
|   |   |   |-- video_script_agent.py # MKT-04 Video Script
|   |   |   |-- aso_agent.py          # MKT-05 ASO
|   |   |   |-- naming_agent.py       # MKT-06 Naming
|   |   |   |-- brand_guardian.py     # MKT-07 Brand Guardian
|   |   |   |-- publishing_orchestrator.py  # MKT-08 Publishing
|   |   |   |-- report_agent.py       # MKT-09 Report Agent
|   |   |   |-- review_manager.py     # MKT-10 Review Manager (Zwei-Stufen)
|   |   |   L-- community_agent.py    # MKT-11 Community Agent (Zwei-Stufen)
|   |   |-- alerts/                  ... [Alert-Dateien (active/resolved/gates)]
|   |   |-- brand/                   ... [Brand Book, App Stories, Directives]
|   |   |-- data/
|   |   |   L-- marketing_metrics.db  # SQLite (5 Tabellen)
|   |   |-- docs/
|   |   |   L-- model_tier_config.md
|   |   |-- output/                  ... [Marketing Output]
|   |   |-- reports/                 # Phase-Reports
|   |   |   |-- phase_1_report.md ... phase_4_report.md
|   |   |   L-- daily/ weekly/ monthly/
|   |   |-- shared/
|   |   |   L-- marketing_utils.py
|   |   |-- tests/                   # 10 Test-Dateien, 59+ definierte Tests
|   |   |   |-- test_phase_2_*.py     # Phase 2 Tests
|   |   |   |-- test_phase_3_*.py     # Phase 3 Tests
|   |   |   |-- test_phase_4_*.py     # Phase 4 Tests (32/32)
|   |   |   L-- test_phase_4_integration.py  # E2E Integration (10/10)
|   |   L-- tools/                   # 7 Tools
|   |       |-- template_engine.py    # Bild-Templates (Pillow)
|   |       |-- video_pipeline.py     # Video-Pipeline (FFmpeg)
|   |       |-- content_calendar.py   # Content-Kalender
|   |       |-- ranking_database.py   # SQLite Rankings
|   |       |-- social_analytics_collector.py
|   |       |-- kpi_tracker.py
|   |       L-- hq_bridge.py          # HQ Dashboard Export
|   |
|   |-- motion_forge/                 # === MOTION FORGE ===
|   |   |-- motion_forge_orchestrator.py
|   |   |-- anim_spec_extractor.py
|   |   |-- lottie_writer.py
|   |   |-- platform_adapter.py
|   |   |-- template_composer.py
|   |   |-- animation_catalog_manager.py / animation_validator.py
|   |   |-- generated/               # 16 Motion-Items (MI-001 bis MI-020)
|   |   |-- catalog/                 ... [83 Catalog-Dateien]
|   |   |-- platform_output/         ... [64 Platform-Animationen]
|   |   |-- templates/               # 12 Animation-Templates
|   |   L-- specs/
|   |
|   |-- mvp_scope/                    # === MVP SCOPE ===
|   |   |-- pipeline.py
|   |   |-- agents/
|   |   |   |-- feature_extraction.py
|   |   |   |-- feature_prioritization.py
|   |   |   L-- screen_architect.py
|   |   L-- output/                   ... [14 MVP-Dateien]
|   |
|   |-- operations/                   # === OPERATIONS ===
|   |   |-- compile_hygiene_validator.py
|   |   |-- completion_verifier.py
|   |   |-- import_hygiene.py
|   |   |-- output_integrator.py
|   |   |-- property_shape_repairer.py
|   |   |-- quality_gate_loop.py
|   |   |-- recovery_runner.py
|   |   |-- run_memory.py
|   |   |-- stale_artifact_guard.py
|   |   |-- swift_compile_check.py
|   |   |-- toplevel_sanitizer.py
|   |   L-- type_stub_generator.py
|   |
|   |-- orchestrator/                 # === ORCHESTRATOR ===
|   |   |-- orchestrator.py
|   |   |-- build_layers.py / build_plan.py
|   |   |-- layer_decomposer.py / layer_context.py / layer_gates.py
|   |   |-- import_boundary_checker.py
|   |   L-- spec_parser.py
|   |
|   |-- pipeline/                     # === PIPELINE ===
|   |   |-- pipeline_runner.py
|   |   L-- review_pass.py
|   |
|   |-- pre_production/               # === PRE-PRODUCTION ===
|   |   |-- pipeline.py / config.py
|   |   |-- ceo_gate.py               # CEO Gate fuer PreProd
|   |   |-- ambition_controller.py
|   |   |-- agents/                  # 7 PreProd Agents
|   |   |   |-- concept_analyst.py
|   |   |   |-- competitor_scan.py
|   |   |   |-- audience_analyst.py
|   |   |   |-- trend_scout.py
|   |   |   |-- legal_research.py
|   |   |   |-- risk_assessment.py
|   |   |   L-- memory_agent.py
|   |   |-- memory/                  # Run-Memory
|   |   |-- output/                  ... [33 PreProd-Dateien]
|   |   L-- tools/
|   |       L-- web_research.py
|   |
|   |-- projects/                    ... [4 Projekte: echomatch, skillsense, memerun2026, brainpuzzle]
|   |
|   |-- qa/                           # === QA ===
|   |   |-- qa_coordinator.py
|   |   |-- test_runner.py
|   |   |-- bounce_tracker.py
|   |   L-- reports/
|   |
|   |-- qa_forge/                     # === QA FORGE ===
|   |   |-- qa_forge_orchestrator.py
|   |   |-- animation_timing.py / audio_check.py
|   |   |-- design_compliance.py / scene_integrity.py / visual_diff.py
|   |   L-- reports/
|   |
|   |-- reports/                     ... [22 Factory-Reports (compile, hygiene, recovery, etc.)]
|   |
|   |-- roadbook_assembly/            # === ROADBOOK ASSEMBLY ===
|   |   |-- pipeline.py
|   |   |-- agents/
|   |   |   |-- cd_roadbook.py
|   |   |   L-- ceo_roadbook.py
|   |   L-- output/                   ... [8 Roadbook-Dateien]
|   |
|   |-- scene_forge/                  # === SCENE FORGE ===
|   |   |-- scene_forge_orchestrator.py
|   |   |-- level_generator.py / prefab_generator.py / shader_generator.py
|   |   |-- unity_scene_writer.py
|   |   |-- scene_spec_extractor.py / scene_validator.py
|   |   |-- scene_catalog_manager.py
|   |   |-- catalog/                 ... [32 Scene-Dateien]
|   |   |-- generated/              ... [32 generierte Scenes]
|   |   |-- level_templates/          # 4 Match3-Level-Templates
|   |   |-- shader_templates/         # 3 URP Shader
|   |   |-- specs/
|   |   L-- utils/                    # Unity FileID, GUID, YAML
|   |
|   |-- shared/                       # Gemeinsame Utils
|   |   |-- pipeline_utils.py
|   |   |-- project_registry.py
|   |   L-- bootstrap_projects.py
|   |
|   |-- signing/                      # === SIGNING ===
|   |   |-- signing_coordinator.py
|   |   |-- android_signer.py / web_builder.py
|   |   |-- version_manager.py / credential_checker.py
|   |   |-- artifact_registry.py
|   |   L-- keystores/ artifacts/ templates/
|   |
|   |-- sound_forge/                  # === SOUND FORGE ===
|   |   |-- sound_forge_orchestrator.py
|   |   |-- sfx_generator.py / music_generator.py
|   |   |-- sound_spec_extractor.py / sound_prompt_builder.py
|   |   |-- audio_format_pipeline.py
|   |   |-- sound_catalog_manager.py
|   |   |-- raw/                      # 17 Raw Audio Files
|   |   |-- catalog/                 ... [70 Catalog-Dateien]
|   |   |-- processed/              ... [68 Processed-Dateien]
|   |   L-- specs/
|   |
|   |-- status/                       # Factory Status
|   |   L-- factory_status.py
|   |
|   |-- store/                        # === STORE SUBMISSION ===
|   |   |-- store_pipeline.py
|   |   |-- metadata_generator.py
|   |   |-- compliance_checker.py
|   |   |-- submission_preparer.py
|   |   |-- build_packager.py / readiness_report.py
|   |   L-- templates/
|   |
|   |-- store_prep/                   # === STORE PREP ===
|   |   |-- store_prep_coordinator.py
|   |   |-- metadata_enricher.py / platform_metadata.py
|   |   |-- privacy_labels.py / screenshot_coordinator.py
|   |   L-- output/                  ... [23 Store-Prep-Dateien]
|   |
|   L-- visual_audit/                 # === VISUAL AUDIT ===
|       |-- pipeline.py / review_gate.py
|       |-- agents/
|       |   |-- asset_discovery.py / asset_strategy.py
|       |   |-- visual_consistency.py / review_assistant.py
|       L-- output/                   ... [15 Audit-Dateien]
|
|===================================================================
|  KNOWLEDGE & STRATEGY
|===================================================================
|
|-- factory_knowledge/                # Factory-Wissen (Proposals, Learnings)
|   |-- knowledge.json / index.json
|   |-- knowledge_reader.py / knowledge_writeback.py
|   |-- proposal_generator.py
|   L-- proposals/                    ... [60 Proposals]
|
|-- factory_strategy/                 # Kommerzielle Strategie
|   L-- commercial_strategy_generator.py
|
|===================================================================
|  GENERATED CODE (App Output)
|===================================================================
|
|-- generated_code/                   # Generierter App-Code
|   |-- Models/                       # 9 Swift Models
|   |-- ViewModels/                   # 3 Swift ViewModels
|   |-- Views/                        # 4 Swift Views
|   |-- components/                   # 4 React/TSX Components
|   |-- hooks/                        # 1 React Hook
|   |-- services/                     # 2 Service-Dateien
|   L-- types/                        # 2 TypeScript Types
|
|===================================================================
|  PROJEKTE (App-Quellcode)
|===================================================================
|
|-- projects/
|   |-- askfin_android/               ... [Android App (Kotlin), 561 files]
|   |-- askfin_v1-1/                  ... [iOS App (Swift), 259 files]
|   L-- askfin_web/                   ... [Web App (Next.js), 454 files]
|
|===================================================================
|  SUPPORT MODULES
|===================================================================
|
|-- ideas/                            # Projekt-Ideen
|-- improvements/                     # Verbesserungsvorschlaege
|-- logs/                             ... [280+ Run-Logs]
|-- mac_agent/                        # Mac Build Agent (SSH)
|   |-- mac_build_agent.py / xcode_builder.py
|   L-- repair/                       # Swift-Repair auf Mac
|-- memory/                           # Memory Manager
|-- opportunities/                    # Opportunity Tracker
|-- orchestration/                    # Orchestration Plans
|-- planning/                         # Feature Backlog
|-- project_context/                  # Roadbook-Kontext
|-- radar/                            # Market Radar
|-- research/ research_graph/         # Research & Graph
|-- strategy/                         # Weekly Strategy Reports
|-- strategy_books/                   # Strategie-Buecher
|-- tasks/                            # Task Queue & Templates
|-- test-images/                      # Test-Bilder (Mock + Real)
|-- tests/                            # Root-Level Tests
|-- trends/                           # Trend Scanner
|-- utils/                            # Git Auto-Commit
|-- watch/                            # Watch Events
L-- workflows/                        # Phase Gates & Recipes
```

---

## Kennzahlen

| Metrik | Wert |
|---|---|
| Factory Departments | 14 (Brain, HQ, Assembly, Marketing, Design Vision, Market Strategy, MVP Scope, PreProduction, Roadbook, Visual Audit, Integration, QA, Scene/Sound/Motion/Asset Forge, Signing, Store) |
| Assembly Lines | 5 (iOS, Android, Web, Unity, Backend) |
| Total Agents | 87 (80 aktiv) |
| Marketing Agents | 11 (MKT-01 bis MKT-11) |
| Marketing Tools | 7 |
| Marketing Adapters | 9 (5 aktiv + 4 Stubs) |
| Dashboard Components | 24 React Components |
| Run-Logs | ~280 |
| Developer Reports | ~216 |
| Factory Proposals | ~60 |
| Projekte | 4 (EchoMatch, SkillSense, MemeRun2026, BrainPuzzle) |
| App-Plattformen | 3 (iOS Swift, Android Kotlin, Web Next.js) |
