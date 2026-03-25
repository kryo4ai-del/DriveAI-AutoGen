# DriveAI-AutoGen — MEMORY.md

## Projekt-Uebersicht
- **Pfad**: `C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\`
- **Zweck**: Multi-Agent AI App Factory (AutoGen v0.4+) — generiert iOS/Android/Web/Unity Apps autonom
- **GitHub**: `https://github.com/kryo4ai-del/DriveAI-AutoGen` (main branch)
- **Git-User**: `kryo4ai-del` / `kryo4ai@gmail.com`
- **Mac**: `/Users/andreasott/DriveAI-AutoGen/` (Build Agent)

## Tech-Stack
- Python + AutoGen AgentChat v0.4+ + LiteLLM
- **LLM Provider**: 4 — Anthropic, OpenAI, Google, Mistral (9 Modelle)
- **Routing**: TheBrain (dynamisch, Tier+Quality+Cost-basiert)
- **API Keys**: ANTHROPIC, OPENAI, GOOGLE, MISTRAL in `.env`
- 62 Agents total (22 Code-Pipeline, 27 Swarm Factory, 13 Infrastruktur)

## TheBrain Modell-System
| Tier | Modelle | Preis (1k output) |
|---|---|---|
| Low | mistral-small ($0.0003), gemini-flash ($0.0006), haiku ($0.004), gpt-4o-mini ($0.0006) | Billigste |
| Mid | o3-mini ($0.0044), sonnet ($0.015), gpt-4o ($0.01), gemini-pro ($0.01) | Standard |
| High | opus ($0.075) | Premium |

### Quality Priority (neu 2026-03-23)
- `quality_priority` in project.yaml → Quality Score 0.0-1.0
- iOS askfin_v1-1: Score 1.0 → immer Sonnet fuer Code-Tasks
- Neutral (0.5): normales Cost-Sorting
- Nur fuer code-generierende Tasks, nicht Reviews

## 4 Production Lines
| Line | Stack | Assembly | Status |
|---|---|---|---|
| iOS | Swift/SwiftUI/MVVM | Mac Bridge | **Aktiv** (via Mac) |
| Android | Kotlin/Compose/Hilt | Gradle (Windows) | Bereit |
| Web | TypeScript/React/Next.js | npm (Windows) | Bereit |
| Unity | C#/Unity/URP | Unity CLI | Scene Forge complete (Phase 11) |
| Backend | Python/FastAPI/Pydantic | pip + Docker | Phase 12 Step 6 (Scaffolding) |

## Wichtige Befehle
```bash
# Code-Pipeline
python main.py --template feature --name Name --profile standard --approval auto --project askfin_v1-1
python main.py --mac-build breathflow5
python main.py --mac-generate askfin_v1-1 --feature "Name" --spec "..." --files "File1.swift,..."

# Swarm Factory (6 Kapitel + PDFs)
python -m factory.pre_production.pipeline --idea-file ideas/app.md --title "App" --mode factory
python -m factory.pre_production.ceo_gate --run-dir <dir> --decision GO
python -m factory.market_strategy.pipeline --run-dir <p1-dir>
python -m factory.mvp_scope.pipeline --latest
python -m factory.design_vision.pipeline --latest
python -m factory.visual_audit.pipeline --latest
python -m factory.roadbook_assembly.pipeline --latest
python -m factory.document_secretary.secretary --type all

# Factory Status
python main.py --factory-status
python main.py --brain-models
python main.py --assemble askfin_android

# QA Department
python main.py --qa askfin_v1-1 --platform ios
python main.py --qa askfin_v1-1 --platform all
python main.py --qa-status askfin_v1-1
python main.py --qa-reset-bounces askfin_v1-1 --platform ios

# Store Preparation
python main.py --store-prep askfin_v1-1 --platform ios          # Full 4-Phase run
python main.py --store-prep askfin_v1-1 --platform all           # All platforms
python main.py --store-prep-status askfin_v1-1                   # Show last report
python main.py --store-prep askfin_v1-1 --platform ios --metadata-only    # Only Phase 1
python main.py --store-prep askfin_v1-1 --platform web --compliance-only  # Only Phase 3

# Signing & Packaging
python main.py --sign brainpuzzle --platform android,web        # Build + Sign
python main.py --sign brainpuzzle --platform all                # Android + Web (iOS excluded on Windows)
python main.py --sign brainpuzzle --platform ios                # SKIPPED (Mac session noetig)
python main.py --check-credentials brainpuzzle --platform android  # Credential Check
python main.py --show-version brainpuzzle                       # Version anzeigen (alle Plattformen)
python main.py --bump-version brainpuzzle --version-type patch  # Version erhoehen (patch/minor/major)
python main.py --list-artifacts brainpuzzle                     # Gespeicherte Artefakte auflisten
```

## Swarm Factory Pipeline
```
Idee → P1 (7 Agents) → CEO Gate → K3 (5) → K4 (3) → K4.5 (3) → K5 (4) → K6 (2) → PDFs (15)
```
- **Vision Mode** (Default): Keine Limits
- **Factory Mode**: Max 20 Features, 12 Screens, realistischer Tech-Stack, Factory Constraints injected

### Produkte
| Produkt | Status | Mode |
|---|---|---|
| EchoMatch | K6 komplett, 10 PDFs | Vision |
| SkillSense | P1 komplett, Gate pending | Vision |
| MemeRun2026 | K6 komplett, 15 PDFs | **Factory** |

## Operations Layer (10 Steps)
```
OutputIntegrator → CompletionVerifier → ImportHygiene → PseudocodeSanitizer
→ CompileHygiene → StaleArtifactGuard → TypeStubGen → PropertyShapeRepair
→ SwiftCompileCheck → QualityGateLoop → RunMemory
```

### Quality Gate Loop (neu 2026-03-23)
- Nach Step 9, ersetzt alten Recovery Loop
- Tier 1: Deterministisch (kostenlos) — Import, Stub, Shape Repair
- Tier 2: LLM Repair (TheBrain-gesteuert)
- Max 3 Iterationen → PASS oder Escalation Report

## Swift Compile Contract (neu 2026-03-23)
- 6 Regeln in `config/platform_roles/ios.json`
- Injected in: swift_developer, ios_architect, refactor_agent, bug_hunter, test_generator
- Code Extractor Blocklist: 112 Framework-Types

## Mac Bridge
- iOS Line auf Windows: **disabled** (Mac uebernimmt)
- Commands: build_ios, generate_and_build, run_tests, screenshots, archive
- Git-Queue: `_commands/pending/*.json` → Mac pollt → `_commands/completed/*.json`
- `factory/mac_bridge/generate_command.py` — neuer Command Sender mit auto-retry

## AskFin Premium (askfin_v1-1)
- 255 Swift Files im Projekt
- iOS Line disabled — Mac Assembly Factory uebernimmt
- StudyStreak: via Mac generiert, 0 Compile Errors, 5 Files
- FocusTimer: via Mac generiert
- BreathFlow/Meditation Files: bereinigt (17 Files geloescht, 27 in Quarantine)
- Quality Score: 1.0 (hoechste Prioritaet)

## QA Department (neu 2026-03-24)
- Pfad: `factory/qa/`
- 6 Module: config, bounce_tracker, qa_report, test_runner, quality_criteria, qa_coordinator
- **4-Phase Pipeline**: Build → Operations → Tests → Quality Gate
- **Bounce System**: Max 3 Bounces pro Produkt, dann CEO Escalation via gate_api
- **BuildVerifier**: iOS (Mac Bridge), Android (Gradle), Web (npm/tsc)
- **TestRunner**: iOS (Mac Bridge run_tests), Android (Gradle test + JUnit XML), Web (Jest --json)
- **QualityCriteria**: 5 Checks — build_success (REQ), zero_blocking (REQ), no_crashes (REQ), test_pass_rate (REC), min_test_coverage (REC)
- **Auto-Repair**: Phase A nutzt RepairCoordinator, Phase B nutzt quality_gate_loop
- Reports: `factory/qa/reports/*.json`

## Store Preparation Layer (neu 2026-03-25)
- Pfad: `factory/store_prep/`
- Sitzt ZWISCHEN QA Department und bestehendem `factory/store/StorePipeline`
- **config.py**: StorePrepConfig — Apple/Google/Web Limits, LLM Toggle, Screenshot Sizes
- **platform_metadata.py**: 3 Dataclasses + Adapter
  - `AppleStoreMetadata`: app_name, subtitle, promotional_text, description, keywords (14 Felder)
  - `GooglePlayMetadata`: app_name, short_description, full_description, category (13 Felder)
  - `WebMetadata`: title, meta_description, og_*, manifest, robots (12 Felder)
  - Alle: `to_dict()`, `to_json(path)`, `validate() -> list[str]`
  - `PlatformMetadataAdapter`: generic StoreMetadata → plattformspezifisch
  - Zwei Pfade: LLM (TheBrain/LiteLLM) → Template Fallback
  - Apple Keywords Optimizer: no spaces, remove app name, max 100 chars
- **metadata_enricher.py**: MetadataEnricher — laedt Pre-Prod + Market Strategy + Design Vision Reports
  - `enrich()` → dict mit 7 Keys: audience, usp, competitors, positioning, monetization, marketing_hooks, design_language
  - Alle deterministisch (Regex/Text-Parsing, kein LLM)
  - Report-Aufloesung: project_registry → glob fallback
  - Unterstuetzt 3 Header-Formate: Markdown (##), Arrow (▶), Nummeriert (1.)
  - Getestet mit memerun2026: alle 7 Felder befuellt (167-3019 chars)
- **privacy_labels.py**: PrivacyLabelGenerator — scannt Source Code fuer Privacy Patterns
  - `CodePrivacyScan`: 14 Kategorien (networking, analytics, location, camera, ...)
  - `generate()` → dict mit scan, apple, google, web
  - Apple Privacy Nutrition Labels (privacy_tier, data_types)
  - Google Data Safety Sections (data_collected, data_shared, security_practices)
  - Web Privacy Hints (GDPR sections, consent_required, cookie_banner_needed)
  - `save()` → 4 JSON-Dateien (code_scan, apple_privacy_label, google_data_safety, web_privacy_hints)
  - 290 Swift-Dateien gescannt bei askfin_v1-1 Test (2 Kategorien erkannt)
- **screenshot_coordinator.py**: ScreenshotCoordinator — orchestriert Screenshot-Capture pro Plattform
  - `ScreenshotResult`: status (CAPTURED/SKIPPED/FAILED/PARTIAL), screenshots, count, reason, duration
  - iOS: Mac Bridge file-based queue (_commands/pending → completed), 120s Timeout, Polling 10s
  - Android/Web/Unity: SKIPPED (nicht implementiert)
  - `check_existing_screenshots()`: Prueft ob Screenshots bereits existieren (manuell/vorheriger Run)
  - Graceful Handling: kein _commands/ → SKIPPED, Timeout → SKIPPED, Fehler → FAILED
- **store_prep_report.py**: StorePrepReport — strukturierter JSON-Report pro Store Prep Run
  - `PlatformPrepStatus`: metadata, assets (icon/screenshots/feature_graphic), compliance, privacy_label, missing_items
  - `evaluate_overall_status()`: READY | INCOMPLETE | BLOCKED | PENDING (Priority: BLOCKED > INCOMPLETE)
  - `save()` → store_prep_report.json, `print_summary()` → Console Output
  - CEO Gates + Warnings tracking
- **store_prep_coordinator.py**: StorePrepCoordinator — Haupt-Orchestrator (4 Phasen pro Plattform)
  - Phase 1: MetadataGenerator → PlatformMetadataAdapter (LLM/Template) → validate → save → CEO Gate
  - Phase 2: AssetForge Icons (Roadbook) → Projekt-Icons Fallback → ScreenshotCoordinator
  - Phase 3: ComplianceChecker → PrivacyLabelGenerator → CEO Gate bei sensitiven Kategorien
  - Phase 4: Evaluate Readiness (READY/INCOMPLETE/BLOCKED) + missing_items
  - `StorePrepResult`: status, per_platform, report_path, output_dir, gates_triggered
  - Alle externen Imports lazy + try/except (MetadataGenerator, ComplianceChecker, AssetForge, gate_api)
  - Fallback: SimpleNamespace wenn MetadataGenerator fehlt
  - CEO Gates non-blocking (create only, kein wait)
  - Getestet: askfin_v1-1 iOS/web (0.6-1.6s), memerun2026 iOS/Android (7/7 Enrichment)
- Bestehendes `factory/store/` wird NICHT modifiziert
- Output: `factory/store_prep/output/{project}/{platform}/` (metadata.json, privacy/, compliance_report.md)
- **8 Module gesamt**: __init__, config, platform_metadata, metadata_enricher, privacy_labels, screenshot_coordinator, store_prep_report, store_prep_coordinator
- **CLI Integration** (main.py): 4 neue Flags, Handler nach QA-Handlern
  - `--store-prep PROJECT --platform PLAT` → voller 4-Phasen Run (StorePrepCoordinator.run())
  - `--store-prep-status PROJECT` → liest store_prep_report.json, zeigt Status/Metadata/Assets/Compliance/Privacy
  - `--store-prep PROJECT --platform PLAT --metadata-only` → nur Phase 1 (Metadata + Enrichment + Adapter)
  - `--store-prep PROJECT --platform PLAT --compliance-only` → nur Phase 3 (ComplianceChecker direkt)
  - `--platform all` iteriert ueber ios/android/web/unity
  - Benutzt bestehenden `--platform` Flag (shared mit QA)

## Signing & Packaging Layer (neu 2026-03-25)
- Pfad: `factory/signing/`
- Foundation fuer Build-Versionierung, Code Signing, Artifact Management
- **config.py**: SigningConfig — Timeouts, Keystore-Defaults, iOS Export, CEO Gates, Web Build
  - Android: RSA 2048, DNAME=DriveAI Stadtoldendorf, Validity 10000 Tage
  - iOS: ExportOptions.plist Template-Pfad, export_method (app-store/ad-hoc/development)
- **version_manager.py**: VersionManager — zentrale Versionsverwaltung pro Projekt+Plattform
  - `VersionInfo`: marketing_version + build_number + build_id + full_version
  - `get_current(platform)`: Laedt oder initialisiert (1.0.0, build 1)
  - `bump_build(platform)`: iOS build_number++, Android version_code++, Web YYYYMMDD-NNN
  - `bump_version(patch|minor|major)`: Marketing-Version erhoehen, Build-Numbers NICHT resetten
  - `apply_to_project(platform, dir)`: Schreibt Version in Info.plist / build.gradle.kts / package.json
  - `get_history(platform)`: Letzte 50 Eintraege mit Timestamp + Action
  - Persistenz: versions.json (atomic write, corrupt-file Backup, auto-create)
- Verzeichnisse: artifacts/ (Build-Artefakte), keystores/ (Signing Keys), templates/ (ExportOptions etc.)
- 14/14 Smoke Tests bestanden (alle Plattformen, apply_to_project, History, Edge Cases)
- **credential_checker.py**: CredentialChecker — prueft Signing-Voraussetzungen VOR Build
  - `check(platform, project)` → CredentialStatus (ready, found, missing, instructions)
  - iOS: ExportOptions.plist + Mac Bridge _commands/ (Limited, Full Check auf Mac)
  - Android: Keystore (.keystore/.jks) + Password (ENV) + keytool + Gradle
  - Web: npm + node (kein Signing noetig)
  - `get_keystore_path(project)` / `get_keystore_password(project)` — Utility fuer AndroidSigner
  - Keystore-Suche: keystores/{project}.keystore → .jks → ANDROID_KEYSTORE_PATH env
  - Password-Suche: ANDROID_KS_{PROJECT}_PASSWORD → ANDROID_KEYSTORE_PASSWORD
  - Instruktionen: keytool-Command generiert, .env Hinweise
- **artifact_registry.py**: ArtifactRegistry — zentraler Speicher fuer Build-Artefakte
  - `store(project, platform, version_info, artifact_path, metadata)` → ArtifactEntry
  - Kopiert Files (IPA/AAB) und Directories (Web-Bundle .next/)
  - build_info.json pro Version (git commit, timestamp, metadata)
  - `get_latest()`, `list_versions()`, `list_projects()`, `get_artifact_path()`
  - `cleanup_old(keep=N)` — entfernt aelteste, behaelt N neueste
  - `get_total_size()` — Disk-Usage Monitoring
  - Struktur: artifacts/{project}/{platform}/{version}_build{N}/
- 13/13 Artifact Registry Tests bestanden (store, copy, build_info, list, cleanup, web_bundle)
- 4/4 Credential Checker Tests bestanden (web READY, android NOT READY, ios limited, keystore None)
- Ergebnis Windows: npm/node OK, keytool/gradle/keystore MISSING, ExportOptions MISSING
- **signing_result.py**: SigningResult — shared Dataclass fuer alle Builder/Signer
  - Fields: status (SUCCESS/FAILED/SKIPPED), phase, artifact_path, artifact_type, version, error, duration_seconds, details
  - `summary()` — einzeilige Zusammenfassung (ASCII-safe, kein Unicode)
- **web_builder.py**: WebBuilder — npm Production Build
  - `build()` -> SigningResult: verify pkg.json -> npm install (skip wenn node_modules) -> npm run build -> find output
  - Windows: npm.cmd (sys.platform check), Timeout: config.web_build_timeout (300s)
  - Output-Suche: config.web_output_dirs in Reihenfolge (.next, dist, build, out)
  - Subprocess: capture_output, TimeoutExpired/FileNotFoundError/OSError abgefangen
- **android_signer.py**: AndroidSigner — Keystore + Gradle Release Build
  - `build_and_sign()` -> SigningResult: ensure keystore -> inject signingConfigs -> bundleRelease -> APK Fallback
  - `_ensure_keystore()`: keystores/{project}.keystore -> .jks -> ENV -> auto-create via keytool
  - Auto-Create: keytool -genkey mit config Defaults (RSA 2048, DNAME, 10000 Tage), Passwort aus ENV oder auto-generiert
  - `_inject_signing_config()`: signingConfigs Block in build.gradle.kts, Passwords via System.getenv() (NIE hardcoded)
  - Idempotent: erkennt bestehende signingConfigs, updated nur storeFile wenn noetig
  - Backup: .gradle.kts.bak vor Modifikation
  - Gradle-Suche: gradlew.bat/gradlew im Projekt -> shutil.which(gradle/gradle.bat)
  - Fallback: bundleRelease (AAB) -> assembleRelease (APK)
  - Artifact-Suche: app/build/outputs/bundle/release/*.aab bzw. apk/release/*.apk
- 17/17 Smoke Tests bestanden (SigningResult, WebBuilder verify/build/output, AndroidSigner gradle/password/keystore/inject/idempotent/artifacts)
- **signing_coordinator.py**: SigningCoordinator -- Haupt-Orchestrator fuer Signing Pipeline
  - `run(store_prep_path)` -> dict mit status (SUCCESS/PARTIAL/FAILED), platforms, artifacts, duration
  - Per-Platform Flow: credential check -> version bump -> build/sign -> artifact store
  - iOS: SKIPPED (deferred to Mac session), Unity: SKIPPED (not implemented)
  - Credential Gate: CEO Gate (blocking) bei fehlenden Credentials, 3 Optionen (setup_done/skip/abort)
  - Fallback: Wenn gate_api nicht verfuegbar -> FAILED mit fehlenden Credentials
  - `_resolve_project_dir()`: project_registry -> convention projects/{name}/ -> None
  - Lazy imports: gate_api, project_registry, AndroidSigner, WebBuilder
- **CLI Integration** (main.py): 6 neue Flags, Handler nach Store Prep
  - `--sign PROJECT --platform PLAT` -> SigningCoordinator.run() (Komma-getrennt oder 'all')
  - `--check-credentials PROJECT [--platform PLAT]` -> CredentialChecker fuer alle/bestimmte Plattformen
  - `--show-version PROJECT` -> Zeigt aktuelle Version fuer iOS/Android/Web
  - `--bump-version PROJECT --version-type patch|minor|major` -> Marketing-Version erhoehen
  - `--list-artifacts PROJECT` -> Letzte 10 Artefakte pro Plattform + Gesamtgroesse
  - `--platform all` bei --sign = android+web (iOS auf Windows excluded)
- 15/15 CLI Smoke Tests bestanden (import, iOS SKIPPED, Unity SKIPPED, web graceful fail, --show-version, --bump-version, --check-credentials, --list-artifacts, --sign ios/web, --sign ohne --platform, --factory-status weiterhin OK)
- **Signing Layer komplett (Windows-Seite)**: 9 Module (config, version_manager, credential_checker, artifact_registry, signing_result, web_builder, android_signer, signing_coordinator, __init__)
- Noch NICHT implementiert: IPA-Export (Mac Session, ios_signer.py + Mac Bridge commands)

## Factory Capabilities (Stand 2026-03-25)
| Bereich | Status |
|---|---|
| App Icons (multi-size) | JA — AssetForge |
| Screenshots (iOS Simulator) | Teilweise — nur Mac |
| Marketing Frames/Mockups | NEIN |
| Store Metadata (Name, Desc, Keywords) | JA — MetadataGenerator |
| Privacy Policy (Code-Analyse) | JA |
| Compliance Checker (iOS/Android/Web) | JA |
| Privacy Labels / Data Safety | JA — PrivacyLabelGenerator (Apple/Google/Web, Code-Scan) |
| Android Build (Gradle) | JA (wenn SDK installiert) |
| Web Build (npm/tsc) | JA |
| iOS Build (Mac Bridge) | JA |
| Build Versioning | JA — VersionManager (iOS/Android/Web, auto-increment, apply_to_project) |
| Web Production Build | JA — WebBuilder (npm install + npm run build, Output-Detection) |
| Android Signing | JA — AndroidSigner (Keystore auto-create, signingConfigs inject, bundleRelease/assembleRelease) |
| iOS Signing | NEIN — Mac Session noetig |
| Store API Upload | NEIN |
| Gate System (HQ) | JA — 2 Gates (ceo_gate, visual_review) |
| QA Department | JA — 4-Phase Pipeline, CLI: --qa / --qa-status / --qa-reset-bounces |
| Store Prep Layer | JA — 8 Module + CLI (--store-prep / --store-prep-status / --metadata-only / --compliance-only) |
| Store Pipeline (5 Steps) | JA — factory/store/ (Metadata, Compliance, Package, Submission, Readiness) |
| Factory Janitor (INF-13) | JA — 3 Zyklen (daily/weekly/monthly), Dashboard-Seite, HQ Assistant Tools |
| CD Forge Interface (Phase 12) | JA — Roadbook→Forge Mapping, Build Plan v2, 4 Parallel Groups, Validator |
| Forge Orchestrator (Phase 12) | JA — Koordiniert 4 Forges (A→B), Budget-Kontrolle, Manifest-Discovery |
| Asset Integration (Phase 12) | JA — Platform Asset Mapper (4 Plattformen) + IntegrationMap + Code-Referenzen |
| Backend Line (Phase 12) | JA — Line 5: Python/FastAPI, PythonExtractor (102 Types), 8-File Scaffolding |
| Full Pipeline (Phase 12) | JA — End-to-End: Roadbook→Forges→Integration→Code Ready, CLI, 24h Cache, Budget |

## Changelog

### 2026-03-25 — Phase 12 Step 7: Full Pipeline Orchestrator
- **full_pipeline_orchestrator.py**: End-to-End Pipeline (Roadbook → Forges → Integration → Code Ready)
- FullPipelineResult Dataclass: per-Forge results, integration stats, CEO actions, JSON export
- `run()`: Complete pipeline — analyze roadbook → run forges (cached/fresh) → integrate → CEO actions
- `dry_run()`: Analysis + cached output check, no generation
- `estimate_cost()`: Quick cost estimate via BuildPlanGenerator
- 24h Cache: forge_requirements.json + Forge manifests — skips re-analysis/re-generation
- Budget enforcement: max_cost checked before each Forge run
- CEO Actions: Unity verify, missing assets, integration readiness, cost summary
- CLI: --project, --roadbook-dir, --platform, --dry-run, --estimate-cost, --forges-only, --skip, --budget
- Pipeline result saved as JSON: maps/{project}_pipeline_result.json
- **Proof Run EchoMatch (Dry)**: 15 features, 106 forge items, 3 cached forges, $5.61 estimate, 105s
- **Proof Run EchoMatch (Full)**: 59 entries, 59 integrated, 0 missing, $0.00 (all cached), 0s

### 2026-03-25 — Signing: Coordinator + CLI (Windows-Seite komplett)
- **signing_coordinator.py**: SigningCoordinator -- orchestriert credential check -> version bump -> build/sign -> artifact store
  - iOS/Unity: SKIPPED (deferred), Android/Web: full pipeline
  - CEO Gate bei fehlenden Credentials (blocking, 3 Optionen), Fallback ohne gate_api
  - Project-Dir Resolution: project_registry -> convention -> None
- **main.py CLI**: 6 neue Flags (--sign, --check-credentials, --show-version, --bump-version, --version-type, --list-artifacts)
- 15/15 Smoke Tests: SigningCoordinator (import, iOS/Unity SKIPPED, web graceful fail), CLI (alle 6 Flags + bestehende Commands weiterhin OK)
- Signing Layer Windows-Seite komplett: 9 Module

### 2026-03-25 — Phase 12 Step 6: Backend Line (Line 5)
- **Backend Assembly Line**: `factory/integration/backend_line/` — Python/FastAPI Backend Generation
- **python_extractor.py**: PythonExtractor — AST-basierte Code-Extraktion (102 Known Types)
  - detect_file_type (7 Typen), validate_syntax (compile()), extract_routes (FastAPI Decorators)
  - extract_imports/classes/functions: AST + Regex Fallback
- **backend_assembly_line.py**: Generiert 8-File FastAPI Projekt aus BackendSpec
  - main.py, models.py, database.py, auth.py, config.py, requirements.txt, Dockerfile, .env.example
  - Database: Firebase (default) / PostgreSQL, Auth: Firebase / JWT
  - generate_from_roadbook(): PDF → LLM Spec-Extraktion → Projekt
- **config/platform_roles/backend.json**: role_overrides (architect, developer, test_generator)
- **EchoMatch Test**: 5 Endpoints, 3 Models → 8 Files, 4915 bytes, alle syntax-valide
- **Self-Tests**: 18/18 bestanden — 5 Production Lines (vorher 4)

### 2026-03-25 — Signing: Web Builder + Android Signer
- **signing_result.py**: SigningResult Dataclass (shared, ASCII-safe summary)
- **web_builder.py**: WebBuilder — npm install + npm run build, Output-Detection (.next/dist/build/out)
  - Windows: npm.cmd, Timeout 300s, node_modules Skip, alle Subprocess-Exceptions gefangen
- **android_signer.py**: AndroidSigner — Full Signing Flow
  - Keystore: find (keystores/ + ENV) oder auto-create via keytool
  - Gradle Injection: signingConfigs Block, Passwords via System.getenv(), Backup .bak, idempotent
  - Build: bundleRelease (AAB) mit assembleRelease (APK) Fallback
  - Artifact-Suche: app/build/outputs/{bundle,apk}/release/
- 17/17 Smoke Tests: SigningResult, WebBuilder (verify/build/output-dir), AndroidSigner (gradle/password/keystore/inject/idempotent/find-artifacts)
- Environment: npm/node OK, gradle/keytool NOT FOUND (kein JDK/Android SDK installiert)

### 2026-03-25 — Phase 12 Steps 3+4+5: Forge Orchestrator + Asset Integrator + Platform Mapper
- **forge_orchestrator.py**: ForgeOrchestrator — koordiniert alle 4 Forge-Runs
  - Group A (sequential): asset_forge + sound_forge + motion_forge
  - Group B (nach A): scene_forge
  - Budget-Kontrolle: max_cost, remaining berechnet vor jedem Forge-Run
  - `run()`: Vollstaendiger Run mit Budget, skip_forges, build_plan-Filterung
  - `dry_run()`: Kostenschaetzung ohne Generierung
  - `_find_manifest()`: Auto-Discovery in catalog/ und output/ Verzeichnissen
  - Alle Forges lazy imported, Fehler einzeln gefangen (andere laufen weiter)
- **platform_asset_mapper.py**: PlatformAssetMapper — plattformspezifische Pfade + Code-Referenzen
  - 4 Plattformen: Unity (Resources.Load), iOS (xcassets/SwiftUI), Android (R.drawable/R.raw), Web (public/assets)
  - 12+ Asset-Typen: sprite, icon, background, sfx, ambient, music, ui_sound, notification, animation_lottie, animation_css, animation_cs, scene, shader, prefab, level
  - `convert_name()`: snake_case, PascalCase, kebab-case, UPPER_ID
  - `map_manifest_entry()`: Manifest-Eintrag → {source, destination, code_reference, supported}
- **asset_integrator.py**: AssetIntegrator — kopiert Forge-Outputs in Projektstruktur
  - `_find_manifests()`: Auto-Discovery aller 4 Forge-Manifeste (catalog/ → output/ Fallback)
  - `integrate()`: Liest Manifeste → mappt → kopiert → IntegrationMap
  - 4 Manifest-Parser: asset, sound (per-platform files), animation (Lottie/CSS/C# je nach Platform), scene (levels/scenes/shaders/prefabs)
  - IntegrationMap: JSON-serialisierbar, `get_code_ref(asset_id)` fuer Code-Generator
  - Maps gespeichert in factory/integration/maps/{project}_{platform}_map.json
- **EchoMatch Proof Run**: Unity 59 entries (59 integrated, 0 missing), iOS/Android/Web je 33 integrated + 26 n/a (Unity-only Assets)
- **Self-Tests**: 17/17 bestanden

### 2026-03-25 — Signing & Packaging Foundation
- **Signing Layer**: `factory/signing/` — Foundation fuer Build-Versionierung und Code Signing
- config.py: SigningConfig (Android Keystore Defaults, iOS Export, Timeouts, CEO Gates, Web Build)
- version_manager.py: VersionManager + VersionInfo
  - 3 Plattformen: iOS (build_number), Android (version_code), Web (YYYYMMDD-NNN build_id)
  - bump_build: Incrementiert plattformspezifisch, bump_version: patch/minor/major (ohne Build-Reset)
  - apply_to_project: Info.plist (plistlib), build.gradle.kts (regex), package.json (json)
  - Persistenz: versions.json (atomic write, corrupt backup, auto-create, 50-entry history)
- Verzeichnisse: artifacts/, keystores/, templates/ (mit .gitkeep)
- 14/14 Smoke Tests: Import, get_current, 3x bump_build, 3x bump_version, no-reset-check, history, apply Web/Android/iOS-missing
- Capability Check (vorher): iOS Archive=JA, IPA Export=NEIN, Android assembleRelease=NEIN, Web npm build=nur StorePipeline, Versioning=Hardcoded 1.0.0

### 2026-03-25 — Phase 12: CD Forge Interface + Build Plan Schema
- **Integration Package**: `factory/integration/` — verbindet CD Roadbook Features mit Forge-Pipelines
- **cd_forge_interface.py**: CDForgeInterface + 3 Dataclasses (ForgeRequirement, FeatureForgeMap, ProjectForgeMap)
  - `analyze(roadbook_dir, project_name)`: PDF-Reader → LLM Feature-Extraktion → Forge-Mapping
  - `analyze_from_text(text, project_name)`: Direkt aus Text (15k char Limit)
  - LLM: TheBrain → Anthropic Fallback, robustes JSON-Parsing mit Truncation-Repair
  - Auto-Save nach build_plans/{project}_forge_requirements.json
  - `_set_dependencies()`: Standard-Reihenfolge A→B→C→D (Forge→Scene→Integrate→Code)
  - `_build_forge_summary()`: Zaehlt Items pro Forge ueber alle Features
- **build_plan_schema.py**: BuildPlan v2 mit Forge+Code Steps
  - 4 Dataclasses: BuildStep, BuildPhase, FeatureBuildPlan, BuildPlan
  - BuildPlanGenerator: Erzeugt v2 Plan aus ProjectForgeMap
    - Group A: asset_forge + sound_forge + motion_forge (parallel)
    - Group B: scene_forge (depends on A)
    - Group C: integration (depends on B/A)
    - Group D: code_generation (depends on C)
  - Cost Estimates: asset=$0.04, sound=$0.01, motion/scene=$0.00, code=$0.02/file
  - `validate_build_plan()`: 6 Checks (Version, depends_on Refs, Zyklen, specs_ref, Steps)
  - `is_legacy_plan()`: Erkennt v1 vs v2
  - Backward compatible: v1 (code-only) Plans funktionieren weiterhin
- **Self-Tests**: 11/12 bestanden (Test 4 LLM-Extraktion uebersprungen wg. API-Kosten)
  - Import, JSON Round-Trip, Summary, BuildPlan Create/Validate, Circular Dep Detection, Missing Specs, Legacy Detection, Generator, Cost Calculation

### 2026-03-25 — Factory Janitor (INF-13)
- **Factory Janitor**: `factory/hq/janitor/` — Autonomer Wartungs-Agent fuer Code-Hygiene
- 8 Module: janitor.py, scanner.py, graph_builder.py, analyzer.py, deep_analyzer.py, executor.py, config.json, agent.json
- **Drei Zyklen**:
  - Daily (Stufe 1+2): File-Scan + Abhaengigkeits-Graph, $0.00, ~20s
  - Weekly (+ Auto-Fixes): Green-Fixes ausfuehren + Yellow-Proposals erstellen, $0.00
  - Monthly (+ Stufe 3): LLM-Tiefenanalyse via Claude Sonnet, ~$0.50-2.00
- **Drei Sicherheitsstufen**:
  - Green: Auto-Fix (<=1 Datei, risikolos, z.B. __pycache__, leere Dateien, fehlende __init__.py)
  - Yellow: Proposal (2-5 Dateien, CEO entscheidet via Gate-System)
  - Red: Nur Report (6+ Dateien, z.B. grosse Dateien, zirkulaere Deps)
- **Scanner (10 Checks)**: empty_file, large_file, stale_file, backup_file, duplicate_filename, pycache, empty_dir, tech_debt_comments, commented_code_block, missing_init
- **Graph Builder**: Python AST-Parsing + JS require/import Regex, Orphan-Detection, Circular-Dep-Finder, Max-Depth
- **Analyzer**: dead_code, duplicate_logic, circular_dependency, stale_import, Safety-Level-Zuweisung
- **Executor**: Quarantaene-System (7 Tage Restore), Proposal-System (Gate-Integration), Protected Paths
- **Dashboard**: JanitorView.jsx mit Health Score Bar, Findings-Tabelle (filter by severity), Aktions-Log, Quarantaene, Proposals
- **HQ Assistant**: 2 neue Tools (get_janitor_status, run_janitor_scan)
- **Dashboard Routing**: Sidebar "Janitor" (Wrench Icon) mit Badge fuer offene Proposals
- **Initialer Scan**: 18.930 Dateien, 1.328.824 Zeilen, 362 Graph-Nodes, 473 Edges, Health Score 74/100
  - 172 Green (auto-fixable), 1662 Yellow (proposals, davon 1489 duplicate_filename), 285 Red (report only)
  - 8 Orphans, 2 zirkulaere Abhaengigkeiten, Max Depth 7
- CLI: `python -m factory.hq.janitor [daily|weekly|monthly|status|restore|proposals]`

### 2026-03-25 — Scene Forge (Phase 11 Steps 1-8) ✅ COMPLETE
- **Scene Forge**: `factory/scene_forge/` — Unity Scene/Level/Shader/Prefab Generation Pipeline

**Steps 1+2 (Spec Extractor + Level Generator):**
- scene_spec_extractor.py: 4 Spec-Dataclasses + SceneManifest + LLM Extraction aus Roadbook PDFs
- level_generator.py: S-Kurve Difficulty, BFS Reachability, No-Initial-Matches
- 4 Level Templates: match3_standard, match3_obstacles, match3_timed, match3_cascade

**Steps 3+4+5 (Scene Writer + Shader Generator + Prefab Generator):**
- utils/: unity_guid (deterministisches GUID), unity_fileid (21 ClassIDs), yaml_serializer (Custom Unity YAML, NICHT PyYAML)
- unity_scene_writer.py: .unity Files — Base Settings + Camera + Light + Canvas + EventSystem + required_elements
- shader_generator.py: URP HLSL — 3 Templates (unlit, bloom_emission, dissolve) + Custom Fallback, SRP Batcher
- prefab_generator.py: .prefab + .meta — Root/Children Hierarchie, m_Father/m_Children korrekt, 10+ Component-Types

**Steps 6+7+8 (Validator + Catalog + Orchestrator):**
- scene_validator.py: Deterministische Validierung (kein LLM), 4 Dateitypen
  - Scenes: 7 Checks (YAML header, TAG, documents, no dupe FileIDs, FileID consistency, camera, canvas+eventsystem)
  - Shaders: 8 Checks (Shader decl, SubShader, Pass, vertex/fragment pragmas, URP tag, SRP Batcher, no builtin includes, placeholders)
  - Prefabs: 7 Checks (YAML header, documents, no dupes, GameObject, Transform, FileID consistency, .meta+GUID)
  - Levels: 6 Checks (valid JSON, grid cells, dimensions, BFS reachability, difficulty 0-1, objectives)
- scene_catalog_manager.py: Kopiert in catalog/{project}/{type}/, Dedup Guard, scene_manifest.json
- scene_forge_orchestrator.py: 7-Step Pipeline (Load/Extract Specs -> Levels -> Scenes -> Shaders -> Prefabs -> Validate -> Catalog)
  - Budget Enforcement, Spec Caching, CLI: --project, --roadbook-dir, --dry-run, --estimate-cost, --only, --budget
  - Campaign: 10 Levels + Spec-basierte Levels, Filter: --only levels,shaders

**Proof Runs:**
- Steps 1+2: 5/5 Tests (LLM Extraction: 20 Specs aus 16 PDFs)
- Steps 3+4+5: 22/22 Tests (Utils + Scene + Shader + Prefab + Batch 15/15 EchoMatch Files)
- Steps 6+7+8 E2E: 30 Files generiert (15 Levels, 6 Scenes, 4 Shaders, 5 Prefabs), Validation 26 pass / 0 warn / 0 fail, $0.00 Cost

**Bugs gefixt:**
- PDFReader `.full_text`, max_tokens 8192, JSON Truncation-Repair, TheBrain Fallback, PYTHONPATH

### 2026-03-25 — Store Prep Layer + HQ Memory
- **Store Preparation Layer**: `factory/store_prep/` — neue Schicht zwischen QA und Store Pipeline
- config.py: StorePrepConfig (Apple/Google/Web Limits, LLM Toggle, Screenshot Sizes)
- platform_metadata.py: AppleStoreMetadata + GooglePlayMetadata + WebMetadata + PlatformMetadataAdapter
- LLM-Pfad (TheBrain/LiteLLM) mit Template-Fallback
- Apple Keywords Optimizer: no spaces, app name removal, 100-char limit
- metadata_enricher.py: Laedt Phase 1/2/4.5 Reports, extrahiert 7 Enrichment-Keys deterministisch
- privacy_labels.py: Scannt Source Code (14 Kategorien), generiert Apple/Google/Web Privacy Labels
- Enricher unterstuetzt 3 Header-Formate (Markdown ##, Arrow ▶, Nummeriert 1.)
- Privacy: CodePrivacyScan → Apple Nutrition Labels + Google Data Safety + Web GDPR Hints
- Alle Smoke Tests bestanden (Enricher: 7/7 Felder, Privacy: askfin 290 Files gescannt)
- screenshot_coordinator.py: ScreenshotCoordinator (iOS Mac Bridge + SKIPPED fuer Android/Web/Unity)
- store_prep_report.py: StorePrepReport + PlatformPrepStatus (JSON + Console Summary)
- Screenshot iOS Test: _commands/ existiert → 120s Poll → korrekt SKIPPED (Stub)
- Report Test: 2 Platforms, INCOMPLETE evaluation, JSON saved (1787 bytes), Summary printed
- store_prep_coordinator.py: StorePrepCoordinator — 4-Phasen Orchestrator pro Plattform
- Integriert: MetadataGenerator + PlatformMetadataAdapter + MetadataEnricher + ComplianceChecker + PrivacyLabelGenerator + ScreenshotCoordinator + AssetForge + Gate API
- Alle externen Imports lazy + try/except, Fallback SimpleNamespace fuer Metadata
- CEO Gates: non-blocking (store_metadata_review, store_asset_review, privacy_label_review)
- askfin_v1-1 iOS: INCOMPLETE (Privacy URL + Icon + Screenshots fehlen), 290 Files gescannt
- memerun2026 iOS+Android: 7/7 Enrichment, AssetForge tried (0 Specs), Compliance BLOCKED (kein Source)
- **CLI Integration** in main.py: --store-prep, --store-prep-status, --metadata-only, --compliance-only
- Handler nach QA-Handlern platziert, nutzt bestehenden --platform Flag
- Tests: Parse OK (alle 4 Flags), --store-prep-status zeigt Report, --compliance-only zeigt Blocker, --metadata-only generiert + speichert, fehlendes --platform gibt Error

### 2026-03-25 — HQ Assistant Persistent Memory Store
- `factory/hq/assistant/memory.json` — persistentes Gedaechtnis, ueberlebt Server-Neustarts
- 3 Kategorien: active_topics, recent_decisions, ceo_preferences + important_context + summary
- Memory wird in System-Prompt injiziert via `_build_system_prompt()` (~4700 chars total)
- Auto-Update alle 5 Nachrichten via Haiku (~$0.001 pro Update)
- Session-Reset: Memory-Update + sessions_count++ vor History-Loeschung
- 2 neue Tools: `get_memory` (CEO fragt "was weisst du noch?"), `update_memory_manual` (CEO sagt "merk dir...")
- memory.json in .gitignore (persoenliche Daten)
- Max-Limits: 5 topics, 15 decisions, 10 prefs, 10 context, summary max 500 chars

### 2026-03-24 — QA + Motion Forge Phase 10 + ElevenLabs Voice
- **QA Department komplett**: 6 Module in `factory/qa/`
- qa_coordinator.py: Haupt-Orchestrator mit 4 Phasen (Build, Ops, Tests, Gate)
- quality_criteria.py: Dynamische Kriterien aus project.yaml + Plattform
- test_runner.py: BuildVerifier + TestRunner (iOS/Android/Web)
- qa_report.py: Strukturierte JSON-Reports
- bounce_tracker.py: Bounce-Persistenz per Projekt+Plattform
- config.py: QAConfig Dataclass (Timeouts, Limits, Defaults)
- Alle Imports verifiziert
- **CLI Integration**: --qa, --qa-status, --qa-reset-bounces, --platform in main.py
  - `--qa <project> --platform <plat>` → startet QA Pipeline (Build→Ops→Tests→Gate)
  - `--qa-status <project>` → zeigt Bounce-Counts + letzte Reports
  - `--qa-reset-bounces <project> --platform <plat|all>` → Reset Bounces
  - `--platform all` iteriert ueber ios/android/web/unity

**Motion Forge — Platform Adapter** (Phase 10 Step 5):
- `factory/motion_forge/platform_adapter.py` — konvertiert Lottie JSON zu plattformspezifischen Formaten
- iOS/Android: Lottie JSON copy (native lottie-ios/lottie-android)
- Web: CSS @keyframes Konvertierung (12 Animationstypen), Fallback zu lottie-web bei inkompatiblen Typen (shimmer, custom, external)
- Unity: C# MonoBehaviour Coroutine Scripts (mit Ease-Funktion, CanvasGroup alpha, Transform)
- CLI: `--lottie-dir`, `--manifest`, `--output`, `--platforms`, `--anim-id`
- BatchAdaptResult mit Statistiken pro Plattform + CSS-Fallback-Counter
- `__init__.py` aktualisiert: exportiert PlatformAdapter, AdaptResult, BatchAdaptResult

**Motion Forge — Validator + Catalog + Orchestrator** (Phase 10 Steps 6-8):
- `factory/motion_forge/animation_validator.py` — deterministische Validierung (kein LLM)
  - 5 Checks: Lottie Validity, Timing Range, File Size, Ease Curves, Platform Compat
  - Timing-Ranges per Kategorie (micro: 100-900ms, transition: 300-1000ms, etc.)
  - ValidationResult mit pass/warn/fail + Details
- `factory/motion_forge/animation_catalog_manager.py` — organisiert alle Dateien in Katalog
  - Kopiert Lottie/CSS/C# in catalog/{project}/{platform}/
  - Generiert all_animations.css (combined CSS)
  - AnimationCatalog manifest mit Statistiken, Dedup-Guard
- `factory/motion_forge/motion_forge_orchestrator.py` — End-to-End Pipeline
  - 5 Steps: Extract Specs -> Generate Lotties -> Adapt Platforms -> Validate -> Build Catalog
  - Budget-Enforcement, 24h Spec-Cache, Filter nach anim_id/category/priority
  - CLI: --project, --roadbook-dir, --dry-run, --estimate-cost, --budget, --anim-id, --category

**Proof Run EchoMatch** ($0.04 total):
- 20 Specs -> 16/20 generiert (80%), 4 failed (complex custom_llm)
- Generation: 6 Template ($0), 10 Composition ($0), 4 Custom LLM ($0.04)
- Platforms: iOS 16/16, Android 16/16, Web 16/16 (7 lottie-web fallback), Unity 16/16
- Validation: Pass=5, Warn=12, Fail=0
- Catalog: 82 Dateien, manifest + all_animations.css
- Duration: 150s (mostly LLM wait time)
- Unicode-Fix: em-dash/arrow durch ASCII ersetzt (Windows cp1252)

**HQ Assistant — ElevenLabs Personal Voice**:
- `server.py`: `/speak` Endpoint (ElevenLabs TTS, base64 mp3, max 300 chars, fallback-Error)
- `server.py`: `/chat` gibt jetzt `speak_text` Feld zurueck (aus `<speak>` Tags)
- `assistant.py`: VOICE_RULES im System-Prompt, `extract_speak_text()` Parser
- `dashboard/server/api/assistant.js`: `/speak` Proxy-Route (port 3002)
- `VoiceOutput.jsx`: Komplett rebuilt — ElevenLabs Audio (base64→blob→Audio), Fallback Browser TTS
- `ChatPanel.jsx`: `speakText` in Messages, AutoVoice fuer letzte Nachricht, alte speakText-Funktion entfernt
- `.env`: `ELEVENLABS_VOICE_ID=z1EhmmPwF0ENGYE8dBE6` eingetragen
- Voice: `eleven_multilingual_v2`, stability=0.5, similarity_boost=0.75, style=0.3
- Logik: Assistant entscheidet selbst was gesprochen wird via `<speak>` Tags (max 250 chars, 1 Satz)
- Nur Begruessungen, Warnungen, Bestaetigungen — keine Listen, Tabellen, Reports
- Character-Tracking: `/speak` trackt Zeichen via `balance_monitor.add_tracked_usage("elevenlabs")`

### 2026-03-23 — Grosse Session (Factory Hardening + MemeRun)
- **Swift Compile Contract**: 6 Regeln in ios.json, Injection via platform_role_resolver.py
- **Framework Type Blocklist**: 52 → 112 Types im Code Extractor
- **Quality Priority System**: quality_priority in project.yaml, Quality Score in TheBrain get_model()
- **Quality Gate Loop**: Autonome 3-Iteration Repair (Tier 1 deterministisch + Tier 2 LLM)
- **Ops Reihenfolge gefixt**: StaleArtifactGuard → StubGen → CompileHygiene (war falsch herum)
- **Factory Mode**: --mode vision|factory in allen 6 Pipelines, Constraints in Roadbook injected
- **MemeRun2026**: Kompletter Factory-Mode Run (P1→K3→K4→K4.5→K5→K6), 15 PDFs
- **iOS auf Mac verlagert**: askfin_v1-1 ios.status=disabled, generate_command.py + --mac-generate CLI
- **StudyStreak**: Via Mac generiert, 0 Compile Errors, 5 Files
- **BreathFlow Cleanup**: 17 alte Files geloescht, 27 in Quarantine
- **Unicode Fix**: Alle Checkmarks/Emojis in Pipeline-Outputs durch ASCII ersetzt
- **Git Push Fix**: generate_command.py hatte silent Push-Failures (capture_output=True)
- **Compile Hygiene**: DEBUG/RELEASE/TARGET_OS_SIMULATOR zur Blocklist hinzugefuegt

### 2026-03-22 — Mac Build Agent + BreathFlow
- breathflow5: 40 Swift Files generiert, Xcode Build
- Mac Agent: RepairEngine (SwiftRepairEngine, deterministic + LLM Fallback)
- Mac Agent: Pre-Build Cleanup, xcodegen Integration

### 2026-03-21 — Kapitel 4 + Document Secretary
- Kapitel 4 (MVP Scope) komplett: 3 Agents, EchoMatch E2E Run
- Document Secretary: 9 PDF-Typen, Playwright/Chromium
- SkillSense: Phase 1 Run #004 komplett

### 2026-03-20 — Swarm Factory Phase 1 + 2
- Pre-Production Pipeline (7 Agents) + Market Strategy (5 Agents)
- CEO Gate, Memory System, SerpAPI Web Research
- EchoMatch: Erster vollstaendiger E2E Run (GO)

### 2026-03-18 — Multi-Platform Factory
- TheBrain: 4 Provider, 9 Modelle, ChainOptimizer, AutoSplitter
- Assembly Lines: iOS, Android, Web, Unity
- RepairEngine: 5 Fix-Strategien, 90% Auto-Fix-Rate
- Hybrid Pipeline: $63 → $0.08/Run (788x guenstiger)

### 2026-03-15 — Operations Layer v2
- Property Shape Repairer, Type Stub Generator, OutputIntegrator Semantic Dedup
- Compile Hygiene: FK-011 bis FK-017, Column-aware
- 8 Autonomy Proof Runs

### 2026-03-14 — Compile Pipeline
- Swift Compile Check (swiftc -parse)
- Factory Knowledge Error Patterns (FK-011 bis FK-017)

### 2026-03-12-13 — Foundation
- Claude Migration (OpenAI → Anthropic 100%)
- Creative Director + UX Psychology Agents
- Factory Knowledge System (22 Entries)
- Premium Product Strategy
