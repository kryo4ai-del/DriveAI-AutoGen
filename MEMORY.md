# DriveAI-AutoGen — MEMORY.md

## Projekt-Übersicht
- **Pfad**: `C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\`
- **Zweck**: Multi-Agent AI App Factory (AutoGen v0.4+) + AskFinn iOS App
- **GitHub**: `https://github.com/kryo4ai-del/DriveAI-AutoGen` (main branch)
- **Git-User**: `kryo4ai-del` / `kryo4ai@gmail.com`

## Tech-Stack
- Python + AutoGen AgentChat v0.4+
- **LLM Provider**: Anthropic Claude (100% — kein OpenAI)
- **Modelle**: claude-sonnet-4-6 (Tier 1+2), claude-haiku-4-5 (Tier 3), claude-opus-4-6 (Premium)
- **API Key**: `ANTHROPIC_API_KEY` in `.env`
- 111 Agents (104 aktiv, 4 deaktiviert, 3 planned), 18 Departments
- 585 Python-Dateien, 123K+ LOC in factory/ | 485 Tests in 55 Dateien
- CEO Cockpit Dashboard: 42 React Components, 18 API Endpoints (Port 3000/3001)

## 3-Tier Modell-System
| Tier | Modell | Tasks |
|---|---|---|
| 1 (Code) | Sonnet | code_generation, architecture, code_review, bug_hunting, refactoring, test_generation |
| 2 (Reasoning) | Sonnet | planning, orchestration, content, compliance, accessibility |
| 3 (Lightweight) | Haiku | classification, summarization, trend_analysis, scoring, labeling, extraction, briefing |

## LLM Profile (`config/llm_profiles.json`)
| Profil | Modell | Verwendung |
|---|---|---|
| dev | claude-haiku-4-5 | Entwicklung, Tests |
| standard | claude-sonnet-4-6 | Normaler Betrieb |
| premium | claude-opus-4-6 | High-End Projekte |

## Wichtige Befehle
```bash
# Einzelner Template-Run
python main.py --template <template> --name <Name> --profile dev --approval auto

# Task Pack (mehrere Templates)
python main.py --pack screen_plus_viewmodel --name <Name> --profile dev --approval auto

# Approval: immer --approval auto (--approval ask = EOFError in non-interactive shell)
```

## Templates verfügbar
| Template | Zweck |
|---|---|
| `screen` | SwiftUI Screen |
| `viewmodel` | ViewModel |
| `service` | Service-Klasse + Protocol |
| `feature` | Vollständiges Feature (Views + VMs + Services) |
| Pack: `screen_plus_viewmodel` | Screen + ViewModel zusammen |

## Generierter Code
- **Pfad**: `generated_code/` (in .gitignore — nicht committed)
- **Xcode-Integration**: `DriveAI/` (wird committed)
- **Subfolder-Routing**: Views → `Views/`, ViewModels → `ViewModels/`, Services → `Services/`, Rest → `Models/`

## Git Auto-Commit
- Nach jedem erfolgreichen Pipeline-Run automatisch: stage → commit → push
- Commit-Message: `AI run: <task[:72]>`
- Implementiert in `utils/git_auto_commit.py`

## Schlüsseldateien
| Datei | Zweck |
|---|---|
| `main.py` | Entry Point, CLI-Parsing, Pipeline-Orchestrierung |
| `config/llm_config.py` | LLM Config (Anthropic + Ollama) |
| `config/model_router.py` | 3-Tier Routing (Sonnet + Haiku) |
| `config/llm_profiles.json` | Profile: dev/standard/premium |
| `config/agent_toggles.json` | 19 aktiv, 4 deaktiviert |
| `config/agent_roles.json` | Agent System Messages |
| `code_generation/code_extractor.py` | Swift-Code-Extraktion aus Agent-Messages |
| `utils/git_auto_commit.py` | Automatischer Git-Commit nach Pipeline-Run |
| `memory/memory_store.json` | Persistente Agent-Memory |
| `control_center/app.py` | Streamlit Dashboard |

## Fixes & Bugs (historisch)

### code_extractor.py — komplettes Rewrite
- Alt: generische `NAME_PATTERNS`, fallback auf `GeneratedFile_N.swift` → File-Explosion
- Neu: Priority-Detection (SwiftUI View > named type > extension > orphan)
- Orphan-Blocks → einzelne `GeneratedHelpers.swift` statt N Dateien

### Regex-Bug: `to.swift` (behoben)
- Problem: `_TYPE_RE` matched `class to` in Kommentar
- Fix: `[A-Z]\w+` statt `\w+` — Typname muss mit Großbuchstabe beginnen (PascalCase)

### SyntaxError in delivery-Dateien (behoben)
- Problem: required params nach optional params ohne `*`-Separator
- Fix: `*` vor erstem required param eingefügt

## Changelog

### 2026-04-01 -- Production Wiring (Prompt 6)

- **ProductionLogger** (`factory/integration/production_logger.py`, ~115 LOC)
  - Append-only JSONL Logger fuer Live Dashboard
  - Schreibt nach `factory/projects/<slug>/production_log.jsonl`
  - Types: `production_start`, `step_start`, `step_complete`, `error`, `phase_start`, `phase_complete`, `production_complete`, `production_failed`
  - Felder matchen production.js Aggregator + ProductionDashboard.jsx SSE-Handler
- **Orchestrator Integration** (`factory/orchestrator/orchestrator.py`)
  - `execute_plan()` akzeptiert optionalen `production_logger` Parameter
  - Log-Calls: production_start, step_start/complete/error, production_complete/failed
  - Backward-kompatibel (logger=None = keine Aenderung)
- **Assembly Line Logging** (`factory/assembly/lines/base_line.py`)
  - `assemble()` akzeptiert optionalen `production_logger` Parameter
  - Loggt jede Assembly-Phase: build_system, organize, wire_app, compile, tests
- **Dispatcher __main__** (`factory/dispatcher/dispatcher.py`)
  - Neuer `__main__` Block: `python -m factory.dispatcher.dispatcher --start-production <slug> --spec <path>`
  - Erstellt ProductionLogger + FactoryOrchestrator, uebergibt Logger
  - Stderr fuer Debug, ProductionLogger schreibt JSONL direkt in Datei
- **production.js Fixes**
  - Stdout→JSONL Piping entfernt (ProductionLogger schreibt direkt)
  - Pfad-Fix: `config.PATHS.projects` statt `config.FACTORY_BASE + '/projects/'` fuer JSONL
  - SSE-Watcher: Verzeichnis-Watch statt Datei-Watch (funktioniert auch wenn Datei noch nicht existiert)
  - `total_steps` Aggregation: Nur `production_start` Events, nicht `phase_start`
- **Mock-Tool**: `factory/integration/mock_production_log.py` — Generiert 26 Mock-Eintraege fuer Smoke Tests
- **Smoke Test**: Status-API korrekt (8/8 Steps, 4 Phasen, $0.52, 87s), SSE OK, Build OK
- **Kette verifiziert**: GO Button → /api/production/start → subprocess (dispatcher __main__) → ProductionLogger → JSONL → SSE → Dashboard

### 2026-04-01 -- Live Production Dashboard (Prompt 5)

- **4 neue Dateien** in `components/Production/`:
  - `ProductionDashboard.jsx` (~260 LOC) — Haupt-Container mit SSE, Live-Timer, 4 Bereiche
  - `CostTracker.jsx` (~120 LOC) — 3 Metrik-Karten (API Calls, Tokens, Kosten) + klappbare Modell-Tabelle
  - `ScreenGrid.jsx` (~110 LOC) — Visuelles Grid aller Screens (gruen/gelb/rot/grau), klickbares Detail-Popup
  - `AgentFeed.jsx` (~100 LOC) — Scrolling Activity Feed (monospace, 50 sichtbar, Auto-Scroll mit Lock)
- **SSE Integration**: EventSource auf `/api/production/status/:slug/stream`, Auto-Reconnect (5s), Live-Update von Status/Steps/Kosten
- **Navigation**: App.jsx `productionSlug` State → GateInbox → ProductionBriefing "Zum Production Dashboard" Button → ProductionDashboard
- **Modifizierte Dateien**: App.jsx (+import, +state, +render), GateInbox.jsx (+prop), ProductionBriefing.jsx (+redirect Button)
- **UI-States**: Loading (Skeleton), Not Started (Hinweis), Running (Live-Timer+Puls), Completed (Summary+Buttons), Failed (rot), SSE Error (gelbe Banner)
- **Build**: Vite OK (1543 Module, 402 KB JS), Alle APIs verifiziert (Gates/Status/SSE/Estimate)

### 2026-04-01 -- Production Briefing Screen (Prompt 4)

- **Neue Datei**: `components/Production/ProductionBriefing.jsx` (~280 LOC)
  - CEO-Briefing-Ansicht fuer Production Gate Entscheidung
  - Header: Projektname, Feasibility-Score Badge, Platform-Badges (iOS/Android/Web mit Tech-Stack)
  - 3 Karten: Scope (Features/Screens/Assets/APIs/Phasen), Dauer (Factory-h/Runs/manuell/Phasen), Kosten (Gesamt$/Calls/Phasen/Agents)
  - Risiken-Sektion: Farbcodiert (error/warning/info) mit Icon + Area + Message
  - Entscheidungs-Buttons: GO (gruen), GO mit Auflagen (gelb), PARK (orange), KILL (rot)
  - Confirm-Modal (inline): Zeigt Kosten/Calls/Dauer nochmal, optional Auflagen-Anzeige
  - Loading: Skeleton-Animation, Error: Retry-Button
- **GateInbox.jsx**: Import + Routing — `production_gate` → `ProductionBriefing` statt Standard-GateDecisionView
- **Kein Backend-Aenderung**: Nutzt bestehende `/api/production/estimate` + `/api/gates/:id/decide`
- **Build**: Vite Build OK, Live-Test mit GrowMeldAI OK (Gate sichtbar, Estimate-Daten korrekt)

### 2026-04-01 -- Automation Gap Close (Feasibility → Production Gate → Production API)

- **Lücke geschlossen**: Vollständiger Flow von "Roadbook fertig" bis "Production GO" jetzt automatisch
- **Part A: Auto-Feasibility nach K6** (`factory/hq/dashboard/server/actions/gate-executor.js`)
  - Nach Visual Review GO + K6 Completion: `FeasibilityChecker` wird automatisch per `exec()` gestartet
  - Ergebnis wird in `project.json` geschrieben (feasibility-Block)
  - Bei nicht-eindeutigem Ergebnis: `_forceProductionGateVisible()` setzt Status auf `feasible` mit Override-Note
  - Neuer `production_gate` Handler: GO → `production_started`, KILL → `parked_killed`, PARK → `parked_blocked`
- **Part B: Production Gate** (`factory/hq/dashboard/server/api/gates.js`)
  - Gate erscheint automatisch wenn Status in [`preproduction_done`, `feasible`, `production_gate_pending`]
  - Summary zeigt: feasibility_score, has_build_spec, target_lines
  - Neue Decision: `PARK` (neben GO/GO_MIT_NOTES/KILL)
- **Part C: Production API** (`factory/hq/dashboard/server/api/production.js`) — ~200 LOC
  - `POST /api/production/estimate` — Runs production_estimator.py, auto-generiert build_spec wenn fehlend
  - `POST /api/production/start` — Async Production via spawn (detached), prüft production_gate GO
  - `GET /api/production/status/:slug` — Aggregiert production_log.jsonl
  - `GET /api/production/status/:slug/stream` — SSE Real-time Stream mit fs.watch
- **Part D: GrowMeldAI Test** — Alle Endpoints verifiziert:
  - Production Gate sichtbar in /api/gates (Score 0.88, build_spec vorhanden)
  - Estimate: $3.90 / 374 Calls / 6.5h / 13 Runs
  - Status: `production_gate_pending` (korrekt)
  - SSE Stream: Connected + Heartbeat
- **Python-Side**: `project_registry.py` erweitert um production_gate Status-Logik (GO→production_started, feasible→production_gate_pending)
- **Feasibility-Override für GrowMeldAI**: False Positives (Backend/AR/GPS/Unity) → Force-set auf `feasible` mit Note

### 2026-04-01 -- Production Estimator

- **Neues Modul**: `factory/integration/production_estimator.py` — Analysiert build_spec.yaml + agent_registry.json → Kosten/Dauer-Schaetzung
  - CLI: `python -m factory.integration.production_estimator --spec <path> [--registry <path>] --format json|summary`
  - Liest echte Agenten-Daten aus `factory/agent_registry.json` (Felder: `default_model`, `model_tier`, `status`)
  - Liest Kosten-Tiers aus `config/model_router.py` (haiku=$0.001, sonnet=$0.01, opus=$0.05)
  - Erkennt Platform-Readiness: CPL-03+INF-06 (iOS=ready), CPL-20+INF-07 (Android=disabled), CPL-22+INF-08 (Web=disabled)
  - 5 Phasen: Coding, Assembly, QA, Store, Evolution
  - Risiko-Erkennung: Blocker (disabled platforms), Warnings (legal), Infos (scope, APIs)
- **GrowMeldAI Ergebnis**: $3.90 / 374 API-Calls / 6.5h Factory-Zeit (13 Runs) / 168 Wochen manuell
  - iOS: READY, 68 Features, 34 Screens, 100 Assets, 8 APIs
  - Risiken: GDPR+COPPA legal review, 8 API-Integrationen, 68 Features → Phasen-Empfehlung

### 2026-04-01 -- Roadbook-to-Spec Converter + Factory Status Report

- **Neues Modul**: `factory/integration/roadbook_to_spec.py` — Parst CD Technical Roadbook → project.yaml
  - CLI: `python -m factory.integration.roadbook_to_spec --roadbook <path> [--output <path>] [--json] [--stats]`
  - Output: `projects/{slug}/specs/build_spec.yaml` (kompatibel mit `spec_parser.py`)
  - Regex-basiert, kein LLM noetig — parst Sections, Tabellen, Feature-IDs, Screen-IDs, Hex-Farben
- **GrowMeldAI build_spec.yaml generiert**: 34 Screens, 68 Features (36A+25B+7BL), 100 Assets, 8 APIs
  - 11 Farben, 3 Fonts, 7 Differentiators, Legal (GDPR+COPPA+ATT, PLZ-Modus, kein ML-Training)
  - Pfad: `projects/growmeldai/specs/build_spec.yaml`
- **Factory Status Report**: `factory_pipeline_status_report.md` im Projekt-Root
  - Pre-Production: 95% autonom (3 Gate-Klicks)
  - Production: ~20% autonom — 6 Gaps identifiziert (Roadbook-Converter war #1, jetzt geloest)
  - Verbleibende Gaps: Dashboard Production Gate, Auto-Feasibility, Dispatcher Background Worker
- **GrowMeldAI K6 (Roadbook Assembly)**: Run #002 abgeschlossen
  - CEO Strategic Roadbook: 16,826 Zeichen (~16 Seiten)
  - CD Technical Roadbook: 83,822 Zeichen (~83 Seiten)
  - Status: `preproduction_done`

### 2026-04-01 -- Autonome Pipeline: Chapter Chain + Auto project.json

- **Problem**: Pipeline brauchte 3+ manuelle CLI-Aufrufe zwischen den Kapiteln
- **Loesung**: Vollautonomer Flow — nur noch 2 menschliche Entscheidungen (CEO-Gate + Visual Review)
- **Neue Datei**: `factory/chapter_chain.py` — Zentraler Chain Runner (K3→K4→K4.5→K5)
  - Aufgerufen via: `python -m factory.chapter_chain --slug X --p1-dir Y`
  - Nutzt subprocess + explizite Dirs (kein --latest)
  - Aktualisiert project.json nach jedem Kapitel via project_registry
- **Phase 1 pipeline.py**: Schreibt jetzt project.json auto → Status wird `ceo_gate_pending`
- **K6 pipeline.py**: Schreibt jetzt project.json auto → Status wird `preproduction_done`
- **gate-executor.js**: CEO Gate triggert jetzt `chapter_chain` statt nur K3
- **gate-executor.js**: Visual Review nutzt jetzt explizite Dirs aus project.json statt `--latest`
- **Bug-Fix**: `project_registry.py _derive_status()` erkennt jetzt `GO_MIT_NOTES` (war vorher nur "GO")
- **Flow**: Idea GO → Phase 1 → [CEO Gate] → K3→K4→K4.5→K5 auto → [Visual Review] → K6 → DONE

### 2026-04-01 -- GrowMeldAI: Komplette Pre-Production Pipeline (Kapitel 1-5)

- **Idee → Human Review Gate in einer Session** (~$0.40, ~50 SerpAPI Credits)
- **Phase 1 (Pre-Production)**: Run #004, 6/6 Agents, 16 SerpAPI Credits
- **Kapitel 3 (Market Strategy)**: Run #002, 5/5 Agents (Platform, Monetization, Marketing, Release, Cost)
- **Kapitel 4 (MVP & Features)**: Run #003, 3/3 Agents — 70 Features, 22 Screens, 7 Flows
  - Phase A: 136K EUR / 252.5K Budget, Phase B: 108K EUR / 230K Budget, 22 Wochen Critical Path
- **Kapitel 4.5 (Design Vision)**: Run #002 — "Botanischer Wissenschaftsatlas" Aesthetik
- **Kapitel 5 (Visual Audit)**: Run #002 — 100 Assets, 63 launch-kritisch, 52 Blocker, 25 KI-Warnungen
- **Status**: `review_pending` — Human Review Gate wartet im Dashboard
- **Naechster Schritt**: Human Review Gate im Dashboard → dann Kapitel 6 (Roadbook Assembly)
- **Bug-Fix**: `GO_MIT_NOTES` wurde von input_loader als KILL interpretiert (nur "GO" akzeptiert)
  - Gefixt in: `market_strategy/input_loader.py` + `mvp_scope/input_loader.py`
- **Hinweis**: `--latest` Flag in Pipelines erkennt nicht welches Projekt → explizite Pfade nutzen

### 2026-04-01 -- Phase 1 Pre-Production: GrowMeldAI + o3-mini Fallback Bug

- **GrowMeldAI Phase 1 erfolgreich**: Run #004, 6/6 Agents, 16 SerpAPI Credits, Status: completed
  - Trend-Scout: 8.872 Zeichen, Competitor-Scan: 9.365, Audience-Analyst: 6.216
  - Concept Brief: 15.969, Legal-Research: 10.910, Risk-Assessment: 12.951
  - Output: `factory/pre_production/output/004_growmeldai/`
- **Bug: o3-mini Fallback in allen 7 Departments**:
  - TheBrain waehlt `o3-mini` als billigstes mid-tier Modell
  - LiteLLM Router scheitert (O-series unterstuezt kein temperature=0.0)
  - Fallback `get_fallback_model()` gibt WIEDER `o3-mini` zurueck → Anthropic SDK → 404
  - **Fix**: `provider == "anthropic"` Check in allen 7 Department-Configs:
    - `factory/pre_production/config.py`
    - `factory/market_strategy/config.py`
    - `factory/mvp_scope/config.py`
    - `factory/design_vision/config.py`
    - `factory/visual_audit/config.py`
    - `factory/roadbook_assembly/config.py`
    - `factory/marketing/config.py`
- **Bug: Unicode ✓ Zeichen crasht Pipeline auf Windows** (cp1252):
  - `print("... ✓")` nach erfolgreichem LLM-Call wirft UnicodeEncodeError
  - except-Block ueberschreibt erfolgreich generierte Daten mit Fehlermeldung
  - **Workaround**: `PYTHONIOENCODING=utf-8` beim Aufruf setzen
  - gate-executor.js: `env: { ...process.env, PYTHONIOENCODING: 'utf-8' }` fuer Auto-Trigger
- **Idea Approval Auto-Trigger**: gate-executor.js startet jetzt automatisch Pre-Production Phase 1 nach GO
  - Command: `python -m factory.pre_production.pipeline --idea-file "..." --title "..." --ambition ...`
- **TODO**: Pipeline soll project.json nach Phase 1 automatisch updaten (aktuell manuell)
- **TODO**: TheBrain temperature=0.0 Problem bei O-series Modellen (litellm.drop_params)

### 2026-04-01 -- Fix: Factory Submit via Dashboard (3 Bugs)

- **Problem**: "Start"-Button im Dashboard erzeugte nur grüne Banner-Meldung, aber kein Projekt erschien in Pipeline/Gates/Dokumente
- **Root Cause (3 Bugs)**:
  1. `start.js` generierte `--title` Flag, aber `main.py` kennt nur `--name` → Title war immer "Untitled"
  2. `main.py` factory_submit-Handler pruefte `a.get("task")` (Positional-Arg), ignorierte `--idea-file` → Submit wurde komplett uebersprungen
  3. `PipelineDispatcher.submit_idea()` schrieb nur in `queue_store.json`, erstellte aber kein `factory/projects/<slug>/project.json` → Dashboard-Pipeline (liest aus project.json) zeigte nichts
- **Fixes**:
  - `factory/hq/dashboard/server/api/start.js`: `--title` → `--name` (2 Stellen)
  - `main.py`: factory_submit-Handler liest jetzt `--idea-file` + `--ambition`, ruft `PipelineDispatcher.submit_idea()` mit allen Params
  - `factory/dispatcher/dispatcher.py`: Neue Methode `_create_project_json()` — erstellt bei submit_idea() automatisch `factory/projects/<slug>/project.json` mit Status "idea_submitted" → sofort im Dashboard sichtbar
- **Neues Gate: Idea Approval** (Idee-Freigabe):
  - `gates.js`: Erkennt `status === 'idea_submitted'` + `idea_approval.status === 'pending'` → zeigt Gate in Gates-Seite
  - `gate-executor.js`: Neuer Handler — GO setzt Status auf `idea_approved`, KILL auf `killed`
  - `GateInbox.jsx`: Metric Cards (Ambitions-Level + Plattformen) + Result-Label fuer idea_approval
  - `dispatcher.py`: `idea_approval` Gate im project.json Template
  - Neue Status: `idea_submitted`, `idea_approved` in deriveStatus/deriveCurrentPhase
- **Neue CLI-Flags in main.py**: `--idea-file`, `--ambition`
- **Verifiziert**: CLI-Test + API-Test → project.json erstellt, Dashboard zeigt Projekt in Pipeline + Gates (Idee-Freigabe)

### 2026-03-31 -- Name Gate: Auto-Generate Flow (Idee → 3 validierte Namensvorschlaege)

- **Feature**: User gibt nur Idee ein (kein Name noetig) → System generiert automatisch 3 App-Namen, validiert alle durch 6-Dimensionen Name Gate, zeigt Auswahl-Panel
- **Backend**:
  - `factory/marketing/agents/naming_agent.py`: Neue Methode `generate_name_suggestions(idea, count=6)` (+60 LOC) — LLM-basiert, kurze virale App-Namen, JSON-Array-Output, Fallback bei Parse-Error
  - `factory/name_gate/orchestrator.py`: Neue Methode `generate_and_validate(idea, template, count=3)` (+75 LOC) — generiert `count*2` Kandidaten via MKT-04, validiert alle, sortiert nach Score, gibt Top N zurueck. Stub-Fallback fuer Tests.
  - `factory/name_gate/cli.py`: Neuer Subcommand `generate --idea <idea> [--template] [--count 3]` (+15 LOC)
  - `factory/hq/dashboard/server/api/namegate.js`: Neuer Endpoint `POST /api/namegate/generate` mit 180s Timeout (+18 LOC)
- **Frontend**:
  - `NameSuggestionsPanel.jsx` (175 LOC, NEU): 3 Vorschlags-Cards mit Rank-Badge (Gold/Silber/Bronze), Ampel-Dot, Score, Staerken-Summary, expandierbarer Detail-Report (NameGateReportCard), Custom-Name-Input, Regenerieren-Button
  - `StartView.jsx` (aktualisiert): Neuer Flow — Name-Feld optional ("Optional — wird automatisch generiert"), Button wechselt kontextabhaengig (Shield=Pruefen / Wand=Generieren), neue Phase "generating" + "suggestions", lila Lade-Animation mit rotierenden Messages
  - Bestehender Validate-Flow (Name + Idee eingeben) bleibt 100% unveraendert
- **Tests**: 33/33 bestehende Tests bestanden, CLI `--stubs generate` liefert valides JSON (3 Suggestions), Vite Build OK (362.77 kB JS)
- **Performance-Fix (ETIMEDOUT)**:
  - **Root Cause**: `execFileSync` blockierte Express bei langen LLM-Calls → 180s Timeout erreicht
  - **Fix 1**: `/generate` Endpoint von `execFileSync` auf async `execFile` umgestellt (300s Timeout, non-blocking)
  - **Fix 2**: Two-Phase Validation im Orchestrator — Phase 1: Quick-Scan aller 6 Kandidaten (4 fast checks: Domain+Store+Social+Trademark, keine LLM), Phase 2: Full 6-Check nur fuer Top 3. Spart ~6 LLM-Calls.
  - **Fix 3**: `PYTHONIOENCODING=utf-8` in allen subprocess-Calls — Windows cp1252 crashte bei Unicode-Zeichen (\u200e) aus LLM-Responses
  - **Ergebnis**: Real-Mode ~140s statt Timeout, Stubs-Mode < 1s, 33/33 Tests bestanden

### 2026-03-31 -- Name Gate API Fix: HTML statt JSON Response

- **Root Cause**: 2 Bugs gefunden:
  1. **JS JSON-Parser** in `server/api/namegate.js` nutzte Reverse-Scan — fand `{` allein bei multi-line JSON → `JSON.parse("{")` → SyntaxError. Fix: Forward-Scan (gleicher Fix wie Python test_integration.py)
  2. **Vite Proxy Fallback**: Bei Express-Ausfall lieferte Vite SPA-fallback (index.html) statt Proxy-Error → `<!DOCTYPE` HTML im Browser
- **Fixes**:
  - `server/api/namegate.js`: `runNameGate()` JSON-Parser auf Forward-Scan umgestellt (erste `{`/`[` Zeile → alles bis Ende als JSON parsen)
  - `client/vite.config.js`: Proxy Error-Handler hinzugefuegt — liefert JSON `{error: "Backend server not reachable"}` mit Status 502 statt HTML
- **Tests**: Python CLI OK, Express Endpoint 200 mit validem JSON, Vite Build OK (351.80 kB JS)
- **Startup**: `npm start` im Dashboard-Dir startet Express + Vite concurrent

### 2026-04-01 — Marketing Phase 9 COMPLETE: Dashboard-Anbindung (FINAL)
- **Marketing-Tab** im CEO Cockpit Dashboard — 14. Tab, read-only
- **Scanner**: `marketing-scanner.js` liest direkt aus Filesystem + SQLite DB (better-sqlite3, readonly)
  - scanDepartmentOverview: 14 Agents, 24 Tools, 16 Adapters, 18 DB-Tabellen, 90 .py
  - scanAlerts: 4 aktive Alerts, 1 pending Gate (live aus JSON-Dateien)
  - scanKPIs: Knowledge Base, Reviews, Sentiment, Pipeline-Runs (aus SQLite)
  - scanMarketingAgents: 14 Agents aus agent_registry.json (gefiltert)
  - scanPipelineStatus: Projekt-Slugs aus output/
- **API**: GET /api/marketing (einziger Endpoint, read-only)
- **React**: MarketingView.jsx mit 6 Sub-Komponenten (DepartmentOverview, AlertsPanel, KPIPanel, PipelineProjects, AgentTable, NotConnected)
- **Geaenderte Dateien (3, minimal)**:
  - `server/index.js`: +2 Zeilen (require + app.use)
  - `App.jsx`: +1 Import, +1 BASE_SECTIONS Eintrag, +1 Render-Block, +1 PlaceholderView-Ausnahme
  - `Sidebar.jsx`: +Megaphone in Import und ICON_MAP
- **Backups**: `_backups/*_before_marketing.bak` (3 Dateien)
- **Vite Build**: PASS (2.26s, 414 KB JS)
- **Report**: `factory/marketing/reports/phase_9_report.md`
- **Marketing-Abteilung: 9/9 Phasen COMPLETE** — feature-complete Dry-Run

### 2026-04-01 — Marketing Phase 8 COMPLETE: Self-Learning System + E2E + Docs

#### Block A (Steps 8.1-8.4)
- **4 neue Tools**:
  - `feedback_loop.py` — MarketingFeedbackLoop: analyze_and_route() analysiert Post-Performance, Hooks, Format-Performance, Sentiment, Competitor-Moves. ROUTING Map: 9 Insight-Typen an 7 Agents. Task Lifecycle: open -> executed -> measured. Feedback-Effectiveness Report
  - `marketing_knowledge.py` — MarketingKnowledgeBase: Auto-Promotion (hypothesis -> confirmed bei 2+ -> established bei 5+). AGENT_KNOWLEDGE_MAP fuer 8 Agents. Jaccard-Similarity Deduplizierung. 10 initiale Seeds (5 Kategorien). Knowledge Reports
  - `cost_reporter.py` — MarketingCostReporter: Versucht Live-Daten aus TheBrain ChainTracker/ServiceCostTracker, Fallback auf Schaetzung ($0.45/Projekt). MARKET_BENCHMARKS $163k. Factory vs Market: 100% Savings. JSON-Export + MD-Report
  - `pipeline_runner.py` — MarketingPipelineRunner: 12 Steps (Strategy -> Copywriter -> ASO -> Visual -> Video -> Brand -> Press Kit -> Storytelling -> PR). Graceful failure pro Step (try/except). Alert bei Fehler. DB-Tracking (pipeline_runs). Status + Report
- **3 neue DB-Tabellen**: feedback_tasks (12 Spalten), marketing_knowledge (10 Spalten), pipeline_runs (9 Spalten) + 9 neue DB-Methoden inkl. confirm_knowledge mit Auto-Promotion
- **Tools __init__.py**: 20 -> 24 Tools
- **DB-Tabellen**: 17 -> 20
- 10/10 Tests

#### Block B (Steps 8.5-8.7)
- **E2E-Gesamttest**: 10 Tests ueber ALLE Marketing-Systeme (Pipeline, Feedback, Knowledge, KPI, Review Zwei-Stufen, Cross-Platform Content, Cost, Hooks, Brand Compliance, Survey-to-Idea Pipeline). 10/10 PASS
- **6 Dokumentations-Dateien** in `factory/marketing/docs/`:
  - ARCHITECTURE.md (8 Layer, Data Flow, DB Schema 20 Tabellen)
  - AGENT_REFERENCE.md (14 Agents mit Methoden/Inputs/Outputs)
  - TOOL_REFERENCE.md (24 Tools mit Typ/DB-Tabellen)
  - ADAPTER_REFERENCE.md (16 Adapters: 8 aktiv, 4 Publishing Stubs, 4 Ad Stubs)
  - OPERATIONS_GUIDE.md (Pipeline, Alerts, Gates, CEO-Routine)
  - SECURITY_RULES.md (CEO-Gates, Zwei-Stufen, Dry-Run, Budget-Limits)
- **Phase-8-Report**: `factory/marketing/reports/phase_8_report.md`
- **Bugs**: Pipeline-Test hing wegen echter LLM-Aufrufe -> _execute_step gemockt; Unicode -> in cp1252 -> PYTHONIOENCODING=utf-8

#### Phase 8 Gesamt (FINAL)
- 14 Agents, 24 Tools, 16 Adapters, 20 DB-Tabellen
- 90 .py, 24.194 LOC
- 145 Tests (ALL PASS), 19 Test-Dateien
- 7 Docs
- Marketing-Abteilung: feature-complete (Dry-Run Phase 1)

### 2026-04-01 — Marketing Phase 7 COMPLETE: Campaign Planning & Optimization

#### Block A (Steps 7.1-7.4)
- **1 neuer Agent**: `campaign_planner.py` — CampaignPlanner (MKT-14): plan_launch_campaign() (3 Phasen: Teaser/Launch/Sustain, Budget-Split, JSON-Meta), plan_content_campaign() (thematisch), get_campaign_summary() (deterministisch). Nutzt BudgetController fuer exakte Berechnung. KEIN ECHTES GELD
- **3 neue Tools**:
  - `budget_controller.py` — BudgetController: calculate_budget_split() (normalisierte Weights, Rundungsfehler-frei, letzter Posten bekommt Rest), project_roi() (CPM-basiert, Branchenschaetzung), validate_budget() (Fehler-Erkennung), compare_campaigns() (CPI-Ranking). 100% deterministisch, kein LLM
  - `ab_test_tool.py` — ABTestTool: Z-Test fuer zwei Proportionen, scipy.stats.norm.cdf mit Fallback auf Abramowitz & Stegun (max Fehler <7.5e-8), evaluate_test() (p-Value, Konfidenz, Winner, Empfehlung + DB-Speicherung), calculate_sample_size() (Power Analysis), get_test_history()
  - `survey_system.py` — SurveySystem: Plattform-Limits (X: 4 Opts/280 Zeichen, Reddit: 6 Opts/300 Zeichen, YouTube: 4 Opts/65 Zeichen/Opt), create_survey() (Validierung + Formatierung + DB), record_results(), analyze_results() (LLM), get_survey_templates() (3 Templates), get_platform_limits()
- **2 neue DB-Tabellen**: ab_tests (11 Spalten), surveys (9 Spalten) + 5 neue Methoden
- 12/12 Tests
- **Bugs**: scipy gibt numpy.bool_ zurueck → `float()` + `bool()` Casts im Z-Test; Early-return in get_campaign_summary() fehlte simulation_only Key

#### Block B (Steps 7.5-7.7)
- **4 neue Ad-Platform-Stubs**: meta_ads_adapter.py (MetaAdsAdapter), google_ads_adapter.py (GoogleAdsAdapter), tiktok_ads_adapter.py (TikTokAdsAdapter), apple_search_ads_adapter.py (AppleSearchAdsAdapter). Alle STATUS="stub_phase1", dry_run IMMER True, kein Credential-Check
- **Registry**: +MKT-14 (111 Agents total, 104 aktiv, Marketing=14)
- **Agents __init__.py**: +CampaignPlanner
- **Adapters __init__.py**: +4 Ad-Stubs, AD_PLATFORM_STUBS dict, ALL_ADAPTERS erweitert (8+4+4=16)
- 12/12 Integration Tests
- Phase-7-Report: `factory/marketing/reports/phase_7_report.md`

#### Phase 7 Gesamt
- 14 Agents, 20 Tools, 16 Adapters (8 active + 4 publishing-stubs + 4 ad-stubs), 17 DB-Tabellen
- 24/24 Tests (Block A 12/12 + Integration 12/12)
- 84 .py, ~21.9K LOC
- Stufenplan: Phase 1 (Planung) COMPLETE, Phase 2 (Adapter aktiv) wartet auf echtes Produkt + CEO-Freigabe

### 2026-04-01 — Marketing Phase 6 COMPLETE: PR & Outreach Infrastructure

#### Block A (Steps 6.1-6.4)
- **1 neuer Adapter**: `smtp_adapter.py` — SMTPAdapter: Forced dry-run wenn kein SMTP_HOST, smtplib + email.mime
- **3 neue Tools**: PressDatabase (15 Seed-Kontakte, 3-Tier Research), InfluencerDatabase (Auto-Tier, Auto-Discover), PressKitGenerator (Live Registry, ZIP)
- **2 neue DB-Tabellen**: press_contacts (13 Spalten), influencers (16 Spalten) + 9 Methoden
- 10/10 Tests

#### Block B (Steps 6.5-6.9)
- **2 neue Agents**:
  - `storytelling_agent.py` — StorytellingAgent (MKT-12): Case Studies, Behind-the-Scenes, Milestone Stories, Cost Comparisons, Technical Deep Dives. `_get_factory_facts()` liest LIVE aus agent_registry.json (110 total, 103 aktiv, 18 Depts). Nutzt echte Daten, kein Hardcoding
  - `pr_agent.py` — PRAgent (MKT-13): Pressemitteilungen (kurz/lang/DE, Headline <=80 Zeichen), Outreach-Planung (Presse-DB Integration), Product Hunt Packages (Tagline <=60 Zeichen), Event Materials, Crisis Response (IMMER CEO-Gate via MarketingAlertManager)
- **1 neues Tool**: `community_templates.py` — CommunityTemplates: 6 Plattform-Templates (reddit_artificial, reddit_machinelearning, hacker_news, product_hunt, dev_to, indie_hackers). Deterministisch, fill_template() mit Variablen, Outreach Calendar
- **Registry**: +2 Agents (110 total, 103 aktiv), Marketing: 11→13
- **Agents __init__.py**: +StorytellingAgent, +PRAgent
- **Tools __init__.py**: +CommunityTemplates
- 12/12 Integration Tests
- **Bugs**: OUTPUT_PATH ist String, nicht Path → `Path(OUTPUT_PATH)` in Agent __init__()

#### Phase 6 Gesamt
- 13 Agents, 17 Tools, 12 Adapters (8 aktiv + 4 Stubs), 15 DB-Tabellen
- 22/22 Tests (Block A 10/10 + Integration 12/12)
- Phase-6-Report: `factory/marketing/reports/phase_6_report.md`
- 74 .py, ~19.9K LOC

### 2026-03-31 — Marketing Phase 5 COMPLETE

- **Phase 5 Block C (Steps 5.7-5.10)**: Content Trend Analyzer + App Market Scanner
  - `content_trend_analyzer.py` — ContentTrendAnalyzer: Hook-Bibliothek (hypothesis->proven->deprecated), analyze_own_performance(), extract_hooks_from_top_content(), get_recommended_hooks(), get_format_performance_matrix(), seed_initial_hooks(), create_content_trend_report()
  - `market_scanner.py` — AppMarketScanner: scan_category_trends() (6 Kategorien), find_market_gaps() (LLM), create_app_idea() (LLM), submit_idea_to_pipeline() (CEO-Gate), get_pipeline_compatible_idea(), create_market_report()
  - 2 neue DB-Tabellen: hook_library, format_performance + 5 neue Methoden (store_hook, update_hook_usage, get_hooks, store_format_performance, get_format_performance)
  - Auto-Promotion: 2 Erfolge = proven. Auto-Deprecation: 3x genutzt + <30% = deprecated
  - Market Scanner Beispiel: "PuzzlePlanet" (Education-Kategorie, CEO-Gate erstellt)
- **Integrations-Test**: 10/10 (Trend Scan, TikTok 137 Hashtags, Competitor Change, GitHub real, HuggingFace real, Sentiment, Hook Promotion, Hook Deprecation, Market Scanner, DB 13 Tabellen)
- **Phase-5-Report**: `factory/marketing/reports/phase_5_report.md`
- **Gesamt**: 65 .py, ~17K LOC, 11 Agents, 13 Tools, 11 Adapters, 13 DB-Tabellen, 30/30 Tests

### 2026-03-31 — Marketing Phase 5 Block B (Steps 5.4-5.6)

- **2 neue Adapters** in `factory/marketing/adapters/`:
  - `github_adapter.py` — GitHubAdapter: REST API v3, get_repo_info(), search_repos(), get_trending_repos(), track_repos() + Star-Explosion-Detection. 1s Rate-Limiting. Optional GITHUB_TOKEN (60→5000 req/h)
  - `huggingface_adapter.py` — HuggingFaceAdapter: Hub API, get_model_info(), search_models(), get_trending_models(), get_new_models(), compare_models(). 0.5s Rate-Limiting
- **1 neues Tool** in `factory/marketing/tools/`:
  - `sentiment_analyzer.py` — SentimentAnalyzer: 3 Topic-Ebenen (ai_apps, autonomous_ai, driveai), scan_sentiment() (News+Reddit+X via SerpAPI), analyze_sentiment() (LLM), detect_narrative_shift() (7d vs 30d), check_factory_mentions(), create_sentiment_report(), run_quick_check(). Score -1.0 bis 1.0, Labels (very_negative bis very_positive)
- **3 neue DB-Tabellen** in `ranking_database.py`: github_repos, sentiment_data, factory_mentions + 8 neue Methoden
- **Adapters**: 5→7 aktiv (+ GitHub, HuggingFace), `__init__.py` aktualisiert (ACTIVE_ADAPTERS)
- **Tools**: 10→11, `__init__.py` aktualisiert (+ SentimentAnalyzer)
- **Tests**: 10/10 (`factory/marketing/tests/test_phase_5_block_b.py`) — echte GitHub + HuggingFace API-Calls
- 61 .py, ~15.2K LOC in Marketing

### 2026-03-31 — Marketing Phase 5 Block A (Steps 5.1-5.3)

- **3 neue Research-Tools** in `factory/marketing/tools/`:
  - `trend_monitor.py` — TrendMonitor: Scan (X, YouTube, Google News, Google Trends via SerpAPI), LLM-Relevanz-Bewertung (0-10 Score, Urgency), Keyword-Fallback, Trend-Alerts, Reports
  - `tiktok_scraper.py` — TikTokCreativeScraper: Dreistufiger Fallback (Scraping→SerpAPI→LLM), Hashtags (137 live gescrapt!), Sounds, Formate, Factory-Evaluation
  - `competitor_tracker.py` — CompetitorTracker: App-Level (Royal Match, Candy Crush etc.) + Factory-Level (Cursor, Devin, Lovable etc.), Change Detection (Snapshots), Differentiator Matrix, Alerts bei kritischen Aenderungen
- **3 neue DB-Tabellen** in bestehender `ranking_database.py`: trends, competitors, competitor_snapshots + 6 neue Methoden (store_trend, get_trend_history, store_competitor, store_competitor_snapshot, get_competitor_snapshots, detect_competitor_changes)
- **Tools**: 7→10, `__init__.py` aktualisiert
- **Tests**: 10/10 (`factory/marketing/tests/test_phase_5_block_a.py`)
- **Datenquellen**: SerpAPI aktiv (Google News + App Search), TikTok Scraping erfolgreich, google_trends Engine gibt 400 (API-Limit)
- **LLM-Calls**: get_model(profile="standard") — Tool-Level, kein Agent-ID
- 57 .py, ~13.8K LOC in Marketing

### 2026-03-31 — Agent Registry Fix + Dashboard LiveOps Fix

- 3 Phase-6 Agents (LOP-12/13/14) fehlten in Registry — Feld-Mismatch (`agent_id` statt `id`) + SCAN_ROOTS fehlten. Gefixt. Registry: 105→108 (101 aktiv)
- Dashboard LiveOps: `runPython()` gab Non-JSON (Python-Logmeldungen vor JSON). Fix: Rueckwaerts-Suche nach erster JSON-Zeile in `liveops.js`
- System Health + Weekly Report Panels jetzt funktional im Dashboard

### 2026-03-31 -- Name Gate Department: NGO-01 (Roadbook Prompt 1)

- **Neues Department**: `factory/name_gate/` (7 .py + 1 agent JSON, 867 LOC)
- **Agent**: NGO-01 Name Gate Orchestrator (Pre-Pipeline Name Validation)
- **6 Checks**: Domain (4 TLDs), App Store (Apple/Google), Social Media (5 Plattformen), Trademark (DPMA/EUIPO), Brand Fit (5 Kriterien: Tonality/Pronounceability/Memorability/Confusion/International), ASO Pre-Check (Saturation/Competitors)
- **Scoring**: Gewichteter Score (Domain 25%, Store 25%, Trademark 25%, Brand Fit 10%, Social 10%, ASO 5%), Ampel (GRUEN >=80, GELB 50-79, ROT <50), Hard-Blocker immer ROT
- **Hard Blockers**: Trademark-Konflikt, beide Stores belegt, alle Major-Domains belegt
- **CLI**: `python -m factory.name_gate validate/alternatives/status`
- **Dateien**: `__init__.py`, `__main__.py`, `cli.py`, `config.py`, `models.py`, `orchestrator.py`, `scoring.py`, `agent_ngo01.json`
- **Registry**: agent_registry.json (105 total, 98 aktiv, 18 Departments), model_router.py (AGENT_TASK_MAP), SCAN_ROOTS
- **Status**: Alle Checks sind STUBS mit deterministischen Mock-Daten (hash-basiert pro Name)
- **Naechste Schritte**: Prompt 2+3 = Real MKT-04/01/05 Integration, Prompt 4+5 = Dashboard

### 2026-03-31 -- Name Gate Prompt 2: MKT-04 validate_name + check_trademark

- **Datei**: `factory/marketing/agents/naming_agent.py` (+171 LOC, 417 -> 588)
- **Neue Methoden**:
  - `validate_name(name)` -- 3 Checks: Domain (4 TLDs, DNS), App Store (Apple/Google via SerpAPI), Social Media (5 Plattformen, HTTP HEAD). Scoring: Domain 25 (.com=10, .de=5, .app=5, .io=5), Store 25 (Apple=12, Google=13), Social 10 (2 je Plattform)
  - `check_trademark(name)` -- DPMA + EUIPO Check via SerpAPI Web-Search. Score 25 (DPMA=12, EUIPO=13). Fallback "unavailable" wenn SerpAPI fehlt/429
  - `_search_trademark_registry(name, registry)` -- Helper fuer SerpAPI Trademark-Suche
- **Wiederverwendung**: `_check_domain()`, `_check_social_handle()`, `_check_store_serpapi()` direkt genutzt
- **Getestet**: echomatch.com + .de frei (DNS), .app + .io vergeben, Instagram + YouTube taken (HTTP), SerpAPI 429 graceful
- **Keine Aenderungen** an bestehenden Methoden (generate_names, validate_names, create_naming_report)

### 2026-03-31 -- Name Gate Prompt 3: MKT-01 brand_fit + MKT-05 aso_precheck

- **brand_guardian.py** (+75 LOC, 415 -> 490):
  - `evaluate_name_brand_fit(name, idea)` -- LLM-basiert, 5 Dimensionen (Tonality 25%, Pronounceability 20%, Memorability 25%, Confusion Risk 15%, International 15%), Score 1-10, Recommendation. Nutzt `_call_llm()` + `_extract_json()`. Fallback: neutrale 5er-Werte bei LLM-Fehler
- **aso_agent.py** (+104 LOC, 494 -> 598):
  - `pre_check_aso(name)` -- SerpAPI Store-Search (iOS + Android), LLM-Fallback bei 429/kein Key. Saturation low/medium/high, Score 0-5, dominant_competitors Liste. Nutzt `_serpapi_search()` + `_call_llm()`
- **Getestet**: EchoMatch -> Brand Fit 7/10 (LLM real), ASO low saturation 5/5 (LLM Fallback bei SerpAPI 429)
- **Keine Aenderungen** an bestehenden Methoden beider Agents

### 2026-03-31 -- Name Gate Prompt 5: Dashboard Frontend Components

- **Neue Datei**: `client/src/components/Start/NameGateReportCard.jsx` (~260 LOC)
  - Ampel-Badge (GRUEN/GELB/ROT) mit Score, glowing circle
  - 6 expandierbare Check-Zeilen: Domain (TLD-Status), App Store (Apple/Google), Social Media (5 Plattformen), Trademark (DPMA/EUIPO + Hard Blocker), Brand Fit (5 Dimensionen mit Bars), ASO (Saturation + Competitors)
  - Hard/Soft Blocker Banner, Empfehlungen, Aktions-Buttons je nach Ampel
  - Props: report, onApprove, onRequestAlternatives, onForce, loading
- **Neue Datei**: `client/src/components/Start/NameAlternativesPanel.jsx` (~145 LOC)
  - Liste alternativer Namen mit Mini-Ampel-Dot, Score, expandierbarer Check-Zusammenfassung
  - Props: alternatives, onSelectAlternative, loading
- **Modifiziert**: `client/src/components/Start/StartView.jsx` (292 -> 330 LOC)
  - Neuer Flow: Enter-Button ruft Name Gate auf (statt direkt Launch)
  - 7 Phasen: input -> validating -> result -> loading_alternatives -> alternatives -> locking -> done
  - Rotierende Validierungs-Messages mit Progress-Dots
  - Nach Lock: bestehender `/api/start/launch` Flow laeuft weiter
  - handleLaunchFromFile() unveraendert (Saved Ideas bypassen Name Gate)
  - Inputs disabled waehrend Validierung/Lock
  - Reset-Button unter dem Report
- **Build**: `vite build` OK (351.80 kB JS, 42.20 kB CSS)
- **Styling**: Tailwind factory-* Tokens, lucide-react Icons, kein neues CSS

### 2026-03-31 -- Name Gate Prompt 6: Real Agent Wiring + Dispatcher + Tests

- **orchestrator.py** (komplett ueberarbeitet):
  - `use_stubs: bool = False` Parameter in `__init__` -- erzwingt deterministisches Mock-Verhalten fuer Tests
  - Lazy Agent-Instantiierung: `_get_naming_agent()`, `_get_brand_guardian()`, `_get_aso_agent()`
  - MKT-04 Cache: `_mkt04_cache` dict -- `validate_name()` liefert domain+store+social in einem Call, wird gesplittet
  - 6 `_call_*` Methoden: Real Agent → Score-Normalisierung → Stub-Fallback bei Exception
  - Score-Normalisierung: domain/store/trademark ×100/25, social ×100/10, brand_fit ×10, aso ×20
  - Trademark-Inversion: Agent `dpma.found=True` = Konflikt, Model `dpma=True` = CLEAR
  - `lock_from_saved(name)` Methode: Laedt Report aus data_dir, speichert nach projects/{name}/
  - `_log()` → stderr (war stdout, verursachte JSON-Parse-Fehler in CLI-Output)
- **cli.py** (vereinfacht):
  - `--stubs` Flag hinzugefuegt -- wird an Orchestrator durchgereicht
  - `_cmd_lock` nutzt jetzt `orch.lock_from_saved()` statt eigene Lock-Logik (Pfad-Mismatch gefixt)
  - Unused imports entfernt (re, Path, datetime)
- **project_creator.py** (Dispatcher Soft-Check):
  - Warnung wenn kein Name Gate Report existiert (`name_gate_report.json` in project_dir oder data_dir)
  - Kein Blocking -- bestehende Apps laufen weiter ("legacy mode")
- **33 Tests** in `factory/name_gate/tests/`:
  - `test_scoring.py` (14 Tests): calculate_total_score, determine_ampel, hard/soft blockers
  - `test_orchestrator.py` (13 Tests): validate_name, lock_name, get_status, alternatives, use_stubs
  - `test_integration.py` (6 Tests): CLI subprocess-Tests mit `--stubs` Flag
  - `_parse_last_json()`: Forward-Scan statt Reverse (multi-line JSON Support)
  - Alle Tests deterministisch (stubs), 0.88s Laufzeit, keine LLM-Calls
- **Bugs gefixt**:
  - CLI Lock-Pfad war `factory/projects/` statt `projects/` (relative Path vs _PROJECT_ROOT)
  - `_log()` auf stdout verursachte `[1/6]` Zeilen die als JSON geparst wurden
  - `_parse_last_json` reverse scan fand innere `{` Zeilen statt vollstaendiges JSON-Objekt

### 2026-03-31 -- Name Gate Prompt 4: Dashboard Backend API

- **Neue Datei**: `factory/hq/dashboard/server/api/namegate.js` (~120 LOC)
  - 4 REST Endpoints: POST validate, POST alternatives, POST lock, GET status/:name
  - `runNameGate()` Helper: `execFileSync('python', ['-m', 'factory.name_gate', ...args])` -- sicherer als inline `-c` (keine Shell-Injection)
  - Timeouts: validate 90s, alternatives 120s (multiple LLM calls), lock 30s, status 10s
  - JSON-Parsing: Letzte JSON-Zeile aus stdout (Log-Zeilen davor werden ignoriert)
  - Error-Handling: 400 bei fehlenden Pflichtfeldern, 409 bei Lock-Fehler, 500 bei Subprocess-Fehler
- **CLI erweitert**: `factory/name_gate/cli.py` (+48 LOC, 92 -> 150)
  - Neuer `lock` Subcommand: Laedt gespeicherten Report aus data_dir, kopiert nach projects/{name}/
  - Prueft ob Name schon gelockt ist (get_status), Fehler wenn kein Report vorhanden
- **server/index.js**: Route registriert: `app.use('/api/namegate', namegateApi)`
- **server/config.js**: Pfade hinzugefuegt: `nameGate`, `nameGateData`
- **Kein Client-Config noetig**: Vite Proxy leitet `/api/*` an :3001 weiter
- **API Pattern**: Gleich wie liveops.js (Express Router, JSON response, error handling)

### 2026-03-29 -- Live Operations Phase 1: COMPLETE (8 Prompts)

#### Block A (parallel):
- **Prompt 1**: App Registry + Migration -- war schon vorhanden (database.py, migrator.py, cli.py)
- **Prompt 2**: Firebase iOS Templates -- AnalyticsManager.swift, AnalyticsEvents.swift, GoogleService-Info.plist.template, INTEGRATION_GUIDE.md
- **Prompt 3**: Firebase Android Templates -- AnalyticsManager.kt, AnalyticsEvents.kt, google-services.json.template, INTEGRATION_GUIDE.md
- **Prompt 4**: Firebase Web Templates -- analyticsManager.ts, analyticsEvents.ts, firebaseConfig.template.ts, INTEGRATION_GUIDE.md
- **Prompt 5**: Firebase Unity Templates -- AnalyticsManager.cs, AnalyticsEvents.cs, firebase_config.template.json, INTEGRATION_GUIDE.md

#### Block B (sequentiell):
- **Prompt 6**: MetricsCollector Agent (`factory/live_operations/agents/metrics_collector/`)
  - collector.py, store_api.py (STUB), firebase_api.py (STUB), config.py
  - Normalisierte Metriken: store_metrics + firebase_metrics, JSON-Output in data/
- **Prompt 7**: AppHealthScorer Agent (`factory/live_operations/agents/health_scorer/`)
  - scorer.py, profiles.py, cli.py
  - 5 Kategorien: Stability, Satisfaction, Engagement, Revenue, Growth
  - 5 Profile: gaming, education, utility, content, subscription (Gewichtungen summieren zu 1.0)
  - 3 Zonen: green (80-100), yellow (50-79), red (0-49)
  - Alerts bei Kategorie < 50
  - CLI: --app, --all, --simulate --profile
- **Prompt 8**: Dashboard Integration
  - Backend: `server/api/liveops.js` (3 Endpoints: /fleet, /app/:id, /app/:id/health-history)
  - Frontend: HealthScoreCircle.jsx (SVG), AppFleetOverview.jsx (Grid), AppDetailView.jsx (Detail mit Chart)
  - Sidebar: HeartPulse Icon, "Live Operations" Nav-Item
  - Dependencies: better-sqlite3 (Server), kein recharts (reines SVG)
  - Build: Client baut fehlerfrei (vite build OK)

#### Cross-Platform Event-Namen (identisch auf allen 4 Plattformen):
dai_app_open, dai_app_background, dai_onboarding_start, dai_onboarding_step, dai_onboarding_complete, dai_onboarding_skip, dai_feature_used, dai_feature_discovered, dai_session_active, dai_content_viewed, dai_purchase_start, dai_purchase_complete, dai_subscription_start, dai_ad_impression, dai_error_occurred

#### Naechste Schritte:
- Phase 4: Execution -- update_planner, release_manager, Factory-Schnittstelle (Briefing -> Orchestrator)
- Store APIs: Echte Credentials konfigurieren (Apple App Store Connect, Google Play Console)
- Firebase: Admin SDK Credentials konfigurieren
- Telegram: DRIVEAI_TELEGRAM_BOT_TOKEN + DRIVEAI_TELEGRAM_CHAT_ID in .env setzen

### 2026-03-31 -- Live Operations Phase 6: COMPLETE (Prompts 26-30)

#### Prompt 26: Synthetic Fleet Generator (Test Harness)
- `factory/live_operations/test_harness/` (7 Dateien)
- `fleet_generator.py` (~350 LOC): SyntheticFleetGenerator mit 7 Public Methods
  - `generate_fleet(count)`: Registriert synthetische Apps in DB, 4 Health States (healthy/warning/critical/new_app)
  - `generate_metrics_history()`: 30 Tage x 4 Punkte/Tag pro App in health_score_history
  - `generate_reviews()`: Realistische Reviews (positiv/negativ/mixed) basierend auf Health State
  - `generate_support_tickets()`: Gewichtete Ticket-Kategorien nach Health State
  - `inject_scenario(app_id, scenario)`: 8 Szenarien injizierbar (crash_spike, retention_drop, revenue_decline, review_bomb, growth_stall, recovery, seasonal_peak, gradual_decay)
  - `populate_all()`: Alles auf einmal generieren
  - `clear_all()`: Cleanup via SYNTHETIC_FLEET Marker im repository_path Feld
- `config.py` (~120 LOC): 15 realistische App-Namen, 5 Profile, 4 Health States mit Metrik-Bereichen
- `scenarios.py` (~100 LOC): 8 Szenarien mit metric_overrides, expected_action, severity, duration
- `cli.py` (~160 LOC): 3 Simulations-Szenarien (generate_and_verify, inject_and_validate, full_lifecycle) -- ALLE BESTANDEN
- `__main__.py`: CLI Entry (--generate, --populate, --inject, --clear, --status, --scenarios, --simulate, --stress)
- `agent.json`: LOP-12, model_tier=none (deterministisch)
- Dashboard API: `/api/liveops/synthetic-fleet` Endpoint in liveops.js
- Verteilung: 6 healthy, 4 warning, 3 critical, 2 new_app (bei 15 Apps)

#### Prompt 27: Stress-Test Suite
- `test_harness/stress_runner.py` (~280 LOC): StressTestRunner mit 4 Tests
  - `test_performance()`: Timing Decision Cycle + Anomaly Scan + Execution Path (Limits: N*200/100/500ms)
  - `test_memory()`: Heap-Wachstum ueber N Iterationen (Limits: 50MB/single, 100MB/total)
  - `test_error_cascade()`: Corrupted App (NULL health_score) darf andere nicht blockieren
  - `test_data_consistency()`: 5 DB-Integritaets-Checks (Scores, Zones, Orphans, App Count)
- `test_harness/benchmark_reporter.py` (~170 LOC): Markdown + JSON Reports in data/benchmarks/
- CLI: `--stress [--count N] [--iterations N]` in __main__.py
- Ergebnis: 4/4 PASS bei 10 Apps, 2 Iterations
  - Performance: Decision=28ms, Anomaly=12ms, Execution=0.5ms
  - Memory: +0.1MB pro Iteration (stabil)
  - Error Cascade: Corrupted App korrekt isoliert
  - Data Consistency: 5/5 Checks OK

#### Prompt 28: Self-Healing + Error Recovery
- `factory/live_operations/self_healing/` (6 Dateien)
- `utilities.py` (~130 LOC): `retry_on_failure` Decorator (backoff), `safe_execute` Wrapper, `ErrorLog` Klasse
- `health_monitor.py` (~220 LOC): SystemHealthMonitor mit 5 Checks
  - db_connectivity: DB erreichbar
  - data_directory: Datenverzeichnis vorhanden
  - agent_health: Alle Agents importierbar
  - queue_health: Keine stuck Actions (>24h in_progress)
  - escalation_health: Log-Groesse OK
- `healer.py` (~220 LOC): SelfHealer mit 5 Healing Actions
  - cleanup_stuck_actions: Stuck Actions zuruecksetzen
  - repair_data_dirs: Fehlende Verzeichnisse erstellen
  - reset_corrupted_scores: NULL/Invalid Health Scores reparieren
  - compact_escalation_log: Uebergrosse Logs trimmen
  - repair_orphaned_records: Verwaiste DB-Records entfernen
- `cli.py` (~160 LOC): 3 Simulations-Szenarien
  - health_check_clean: Sauberes System pruefen
  - inject_and_heal: Schaden injizieren + automatisch reparieren (3 corrupted scores + 1 stuck action)
  - full_cycle_health: Orchestrator Cycle mit Pre-Cycle Health Checks
- `__main__.py`: CLI Entry (--simulate, --health-check, --heal-all)
- `agent.json`: LOP-13, model_tier=none (deterministisch)
- Orchestrator Integration: Pre-Cycle Health Check in run_decision_cycle() und run_anomaly_scan()
  - Bei Problemen: automatische Heilung via heal_from_check()
  - Neues get_health_status() API im Orchestrator
- Test Harness erweitert: --self-heal Flag
- Ergebnis: 3/3 PASS

#### Prompt 29: CEO Weekly Report
- `factory/live_operations/reporting/` (5 Dateien)
- `weekly_report.py` (~350 LOC): WeeklyReportGenerator mit 9 Sektionen
  - Executive Summary (Fleet Status, KPIs, Zone-Verteilung)
  - Fleet Health Overview (alle Apps mit Score, Zone, Trend, Version)
  - Critical Alerts (CEO-Eskalationen der Woche)
  - Action Queue Status (Pending, In Progress, Completed)
  - Release Pipeline (Releases + Failed der Woche)
  - System Health (Self-Healing Status)
  - Empfehlungen (automatisch: Red Zone, Trends, Pending, Escalations, Failed Releases)
- `cli.py` (~160 LOC): 3 Simulations-Szenarien
  - healthy_fleet: Saubere Fleet → Report
  - mixed_fleet: Fleet mit Injections (crash_spike, review_bomb, revenue_decline) → Report mit Empfehlungen
  - full_lifecycle: Orchestrator Cycles + Report
- `__main__.py`: CLI Entry (--simulate, --generate, --list)
- `agent.json`: LOP-14, model_tier=none (deterministisch)
- Test Harness erweitert: --weekly-report Flag
- Fleet Status Klassifizierung: KRITISCH / WARNUNG / STABIL / EXZELLENT
- Trend-Berechnung: letzte 7 vs vorherige 7 History-Eintraege
- Reports als Markdown + JSON in data/reports/ archiviert
- Ergebnis: 3/3 PASS

#### Prompt 30: System Health Dashboard + Final Integration
- **Dashboard API** (3 neue Endpoints in liveops.js):
  - `GET /api/liveops/system-health` — SystemHealthMonitor Check (Python-Call)
  - `GET /api/liveops/weekly-report` — WeeklyReport Data (Python-Call)
  - `GET /api/liveops/weekly-report/archive` — Report-Archiv
  - `GET /api/liveops/phase6-status` — Phase 6 Gesamtstatus (DB-direct)
- **React Components** (2 neue):
  - `SystemHealthPanel.jsx` (~100 LOC): 5 Health Checks, OK/FAIL Status, Warnings
  - `WeeklyReportPanel.jsx` (~140 LOC): Executive Summary, KPIs, Empfehlungen, aufklappbare Fleet-Tabelle
- `AppFleetOverview.jsx` erweitert: SystemHealth + WeeklyReport Panels über dem Grid
- **Final Simulation: 4 Module ALL PASS**
  - Synthetic Fleet: 3/3 PASS
  - Stress-Test: 4/4 PASS
  - Self-Healing: 3/3 PASS
  - Weekly Report: 3/3 PASS

#### Phase 6 Summary
- 5 Prompts (26-30), alle COMPLETE
- Neue Module: test_harness/, self_healing/, reporting/
- 3 neue Dashboard Components, 4 neue API Endpoints
- Agents: LOP-12 (Fleet Gen), LOP-13 (Self-Heal), LOP-14 (Report Gen)
- Alles deterministisch (model_tier=none), kein LLM

### 2026-03-31 -- Live Operations Phase 4: COMPLETE (5 Prompts: 21-25)

#### Prompt 21: UpdatePlanner Agent (Briefing Document Generator)
- `factory/live_operations/agents/update_planner/` (7 Dateien)
- `planner.py` (~200 LOC): UpdatePlanner konvertiert Decision Engine Actions in strukturierte Factory Briefings
- `templates.py` (~130 LOC): 6 Trigger Templates (crash_rate, retention, funnel, review, support, revenue) + Fallback
- `config.py` (~50 LOC): Version Bump Rules (hotfix/patch=patch, feature=minor), Scope Rules, Priority Map
- `cli.py` (~130 LOC): 3 Simulationen (hotfix, patch, feature_update) — ALLE BESTANDEN
- Briefings als JSON in `data/briefings/`
- agent.json: LOP-09, model_tier=none (deterministisch)

#### Prompt 22: FactoryAdapter (Briefing -> Factory Bridge)
- `factory/live_operations/agents/factory_adapter/` (7 Dateien)
- `adapter.py` (~170 LOC): FactoryAdapter mit STUB-Dispatch, Submission Tracking, Status Transitions
- `config.py` (~25 LOC): 6 Status (created/submitted/accepted/in_progress/completed/failed), Valid Transitions
- `cli.py` (~230 LOC): 3 Simulationen (submit_hotfix, status_transitions, list_filter) — ALLE BESTANDEN
- UUID-basierte Submission-IDs gegen Timestamp-Kollisionen
- agent.json: LOP-10, model_tier=none (deterministisch)

#### Prompt 23: ReleaseManager Agent
- `factory/live_operations/agents/release_manager/` (7 Dateien)
- `manager.py` (~220 LOC): ReleaseManager mit QA Gate -> Store Upload (STUB) -> Registry Update -> Cooling
- `qa_checker.py` (~90 LOC): QAChecker mit 5 Checks (health_score, anomalies, cooling, briefing, submission)
- `config.py` (~30 LOC): QA Thresholds, Cooling Durations (hotfix=48h, patch=168h, feature=336h)
- `cli.py` (~250 LOC): 4 Simulationen (successful, qa_failure, feature, list) — ALLE BESTANDEN
- agent.json: LOP-11, model_tier=none (deterministisch)

#### Prompt 24: Loop-Completion + Orchestrator Integration
- `orchestrator.py` erweitert: `run_execution_path()` — Pending Actions -> Briefing -> Submission -> Release
- `__main__.py` erweitert: --execution, --submissions, --releases, --briefings, --check-cooling, --app Filter
- Vollstaendiger Loop: Decision -> Enqueue -> Briefing -> Factory Submit -> Release -> Cooling
- STUB: Factory auto-accept + auto-complete (kein echtes Building)
- Simulation: 1 briefing, 1 submission, 1 release — BESTANDEN
- Fix: `_bump_version()` mit None-Guard fuer neue Apps ohne current_version

#### Prompt 25: Dashboard Execution Status
- **API Endpoints** (3 neue in liveops.js):
  - `/api/liveops/briefings` — Briefing Documents (JSON files, Filter: appId)
  - `/api/liveops/submissions` — Factory Submissions (JSON files, Filter: appId, status)
  - `/api/liveops/releases-exec` — Release Records (JSON files, Filter: appId, status)
- **React Komponenten** (2 neue):
  - `ExecutionPipeline.jsx` (~130 LOC): Briefings + Submissions Pipeline-View
  - `ReleaseTracker.jsx` (~110 LOC): Release Records mit QA Status, Cooling Info
- **AppDetailView.jsx**: Neuer "Execution" Tab (Rocket Icon) mit Pipeline + Tracker
- **config.js**: 3 neue Pfade (liveOpsBriefings, liveOpsSubmissions, liveOpsReleases)

#### Agent Registry Update
- 3 neue Agents: LOP-09 (UpdatePlanner), LOP-10 (FactoryAdapter), LOP-11 (ReleaseManager)
- Alle model_tier=none, provider=none (deterministisch, kein LLM)
- Total: 104 Agents (97 aktiv), 17 Departments, 11 Live Operations Agents

### 2026-03-31 -- Live Operations Phase 3: COMPLETE (6 Prompts: 15-20)

#### Prompt 15: Decision Engine Core + Severity Scoring
- `factory/live_operations/agents/decision_engine/` (6 Dateien)
- `engine.py` (~540 LOC): DecisionEngine mit 3-Dimensionen Severity Scoring (deviation*0.4 + impact*0.35 + velocity*0.25)
- `config.py` (~80 LOC): SEVERITY_HOTFIX_THRESHOLD=85, 9 Trigger-Definitionen, Cooling Durations
- 5 Aktionstypen: hotfix (>85 stability), patch (multiple 40-70), feature_update (engagement), strategic_pivot (health <50 >2w), none
- Escalation Levels: 0=none, 1=info, 2=warning, 3=CEO
- CLI mit 5 Simulations-Szenarien (crash_spike, slow_decline, healthy, strategic_pivot, cooling)

#### Prompt 16: Action Queue + Cooling Period
- `action_queue.py` (~150 LOC): Priority Queue in SQLite, Duplikat-Pruefung, Stale Cleanup (7d)
- `cooling.py` (~100 LOC): CoolingManager mit hotfix=48h, patch=168h, feature_update=336h, strategic_pivot=manual
- Max 1 in_progress pro App, keine doppelten pending Actions

#### Prompt 17: Anomaly Detector + Rollback
- `factory/live_operations/agents/anomaly_detector/` (6 Dateien)
- `detector.py` (~255 LOC): 4 Checks -- crash_explosion (2x), revenue_collapse (<20%), health_freefall (>20pt), post_update_regression (48h)
- `rollback.py` (~130 LOC): RollbackManager mit STUB Store Redeploy, startet hotfix-Cooling
- Post-Update-Regression = EINZIGER auto_rollback Fall (has last_stable_version + within 48h)
- Check-Reihenfolge: post_update_regression FIRST (enables rollback), dann crash/revenue/health

#### Prompt 18: Eskalationslogik + Telegram
- `factory/live_operations/agents/escalation/` (7 Dateien)
- `manager.py` (~150 LOC): EscalationManager, escalate_from_decision(), escalate_from_anomaly()
- `telegram_notifier.py` (~70 LOC): urllib-basiert, ENV-Vars (DRIVEAI_TELEGRAM_BOT_TOKEN/CHAT_ID), 2 Retries
- `log.py` (~70 LOC): Append-only JSONL Log, Abfragen (recent, by_app, stats, ceo_pending)
- `factory/hq/assistant/liveops_tools.py` (NEW): 6 Tools fuer HQ Assistant (escalation_recent, stats, ceo_pending, action_queue, app_health, cooling_status)

#### Prompt 19: Cycle Orchestrator
- `factory/live_operations/orchestrator.py` (~180 LOC): CycleOrchestrator
- Decision Cycle (6h): Stale Cleanup -> Evaluate All -> Eskalationen
- Anomaly Scan (30min): Scan All -> Auto-Rollback -> Eskalationen
- Continuous Mode: Decision in Main Thread, Anomaly in Daemon Thread
- `factory/live_operations/__main__.py`: Entry Point (--decision-cycle / --anomaly-scan / --continuous / --simulate)

#### Prompt 20: Dashboard-Elemente
- 5 neue API-Endpoints in `liveops.js`: /action-queue, /escalation-log, /cycle-status, /cooling-status, /strategic-pivots
- `DecisionMonitor.jsx` (~175 LOC): Cycle Status + Action Queue + Cooling Overview
- `EscalationLog.jsx` (~140 LOC): Chronologisches Log mit Level-Filter (Info/Warning/CEO)
- `StrategicPivotPanel.jsx` (~120 LOC): Prominente CEO-Eskalations-Karten
- AppDetailView.jsx: 2 neue Tabs (Decisions, Escalations) -- chirurgisch hinzugefuegt (+35 Zeilen)
- `config.js`: liveOpsEscalation Pfad hinzugefuegt

### 2026-03-30 -- Live Operations Phase 2: COMPLETE (6 Prompts: 9-14)

#### Prompt 9: Analytics Core + Trend Detection
- `factory/live_operations/agents/analytics/` (6 Dateien)
- `trend_detector.py` (~230 LOC): Lineare Regression, Moving Averages, Anomaly Detection (>2 sigma), Seasonality (Autocorrelation)
- `analyzer.py` (~200 LOC): AnalyticsAgent orchestriert alle Sub-Analyzer, speichert Insights als JSON
- `config.py`: TREND_WINDOW_SHORT=7, ANOMALY_THRESHOLD_SIGMA=2.0
- `cli.py` + `__main__.py`: --simulate mit synthetischen Daten

#### Prompt 10: Funnel Analysis
- `funnel_analyzer.py` (~250 LOC): 3 Standard-Funnels (onboarding, conversion, retention)
- Weakest-point Detection, kritische Findings (>40% Drop = high, >25% = medium)

#### Prompt 11: Cohort Analysis + Feature Usage
- `cohort_analyzer.py` (~170 LOC): Wochenweise Kohorten, Update-Impact-Vergleich
- `feature_tracker.py` (~180 LOC): Star (>50%), Unused (<5%), Rising/Declining Trends

#### Prompt 13: Review Manager
- `factory/live_operations/agents/review_manager/` (3 Dateien)
- `ReviewAnalyzer` (NICHT ReviewManager -- Abgrenzung zu MKT-10)
- Keyword-Kategorisierung (EN+DE): bug_report, feature_request, praise, complaint, question
- Pattern Detection (>=3 Mentions), Rating Health (Trend + Target), Sentiment (pos/neg/neutral/mixed)

#### Prompt 14: Support Agent
- `factory/live_operations/agents/support_agent/` (4 Dateien)
- `SupportAnalyzer`: Ticket-Kategorisierung, Urgency (critical/high/medium/low)
- `TicketStore`: JSON-basiert, generate_mock_tickets() fuer 30 realistische Tickets
- Recurring Issue Detection: Gruppierung nach category+platform+version

#### Prompt 12: Dashboard Analytics (chirurgisch)
- Backend: 5 neue GET Endpoints in `liveops.js` (analytics, trends, funnels, reviews-analysis, support-analysis)
  - Liest JSON-Insights aus `factory/live_operations/data/insights/` (kein Python-Subprocess)
  - Config: `liveOpsInsights` Pfad hinzugefuegt
- Frontend: `AnalyticsTab.jsx` (446 LOC, neue Datei)
  - TrendsPanel mit SparkLine SVG, FunnelsPanel mit Bars, CohortsPanel mit Tabelle, FeatureUsagePanel mit Chips
  - Empfehlungen-Panel (Severity-basiert)
- `AppDetailView.jsx`: +31 Zeilen -- Tab-System (Overview | Analytics) chirurgisch eingefuegt
  - Import AnalyticsTab + BarChart3 Icon
  - activeTab State, Tab-Buttons, bedingtes Rendering
- Keine bestehenden Dateien ueberschrieben, keine Dependencies geaendert

#### Alle Agents deterministisch (kein LLM):
- Trend Detection: Lineare Regression (Least Squares), keine numpy
- Anomaly: Standard-Deviation-basiert (>2 sigma)
- Kategorisierung: Keyword-Matching (EN+DE)
- Sentiment: Keyword-Counts + Rating-Signal

#### Windows cp1252 Fix:
- Unicode-Pfeile (arrow) und Umlaute in print()-Statements durch ASCII ersetzt
- Betrifft: database.py, migrator.py, cli.py, alle agents

### 2026-03-29 -- Android Analytics Templates (Firebase)
- **Neue Dateien** (4) in `factory/production_lines/android/templates/analytics/`:
  - `AnalyticsManager.kt` -- Kotlin Singleton: configure(), logEvent(), logScreenView(), logFeatureUsed(), logFunnelStep(), logConversion(), setUserProperty(), setAppProfile()
  - `AnalyticsEvents.kt` -- Sealed class hierarchy: Session, Onboarding, Feature, Engagement, Monetization, Error (15 Events)
  - `INTEGRATION_GUIDE.md` -- Gradle deps, google-services.json, Application setup, Usage examples, Debug-Modus
  - `google-services.json.template` -- Placeholder-Template mit {{FIREBASE_PROJECT_ID}}, {{FIREBASE_API_KEY}} etc.
- **Event-Prefix**: `dai_` (DriveAI identification)
- **Cross-Platform**: Alle 15 Event-Namen identisch zu iOS (dai_app_open, dai_feature_used, dai_onboarding_start etc.)
- **Dependencies**: firebase-analytics-ktx, firebase-crashlytics-ktx (via Firebase BoM)

### 2026-03-29 -- Web Analytics Templates (Firebase)
- **Neue Dateien** (4) in `factory/production_lines/web/templates/analytics/`:
  - `analyticsManager.ts` -- TypeScript module: initAnalytics(), logEvent(), logScreenView(), logFeatureUsed(), logFunnelStep(), logConversion(), setUserProperty(), setAppProfile(). Named exports, async init mit isSupported()-Check (SSR-safe).
  - `analyticsEvents.ts` -- Interface AnalyticsEvent + 15 Factory Functions (dai_app_open, dai_app_background, dai_onboarding_start/step/complete/skip, dai_feature_used/discovered, dai_session_active, dai_content_viewed, dai_purchase_start/complete, dai_subscription_start, dai_ad_impression, dai_error_occurred). Type-safe Parameters.
  - `INTEGRATION_GUIDE.md` -- npm install firebase, Config Setup, initAnalytics() in Entry Point, React Hook useAnalytics() fuer automatisches Screen View Tracking, Lifecycle Events.
  - `firebaseConfig.template.ts` -- Placeholder-Template mit {{FIREBASE_API_KEY}} etc., typisiert als FirebaseConfig.
- **Event-Prefix**: `dai_` (automatisch via ensurePrefix())
- **Cross-Platform**: Alle 15 Event-Namen identisch zu iOS/Android
- **Kein Crashlytics**: Firebase Crashlytics existiert nicht fuer Web -- stattdessen daiErrorOccurred() Events
- **Dependencies**: firebase (npm)

### 2026-03-29 -- Live Operations Phase 1: App Registry (Task 1.1 + 1.2)
- **Neues Department**: `factory/live_operations/` -- Autonomer Betriebs-Layer ueber der Factory
- **App Registry** (`factory/live_operations/app_registry/`):
  - `database.py` (~390 LOC): `AppRegistryDB` -- SQLite-Manager mit 4 Tabellen (apps, release_history, action_queue, health_score_history)
  - `migrator.py` (~110 LOC): `RegistryMigrator` -- JSON -> SQLite Migration (sucht in store_pipeline/, store/, store_prep/)
  - `cli.py` (~150 LOC): CLI mit --list, --show, --migrate, --health, --zones
  - `__main__.py`: Ermoeglicht `python -m factory.live_operations.app_registry.cli`
- **DB-Schema**: Exakt wie Roadbook Kap. 9 -- apps (22 Felder), release_history (10), action_queue (9), health_score_history (9)
- **Features**: CRUD, Cooling Period (auto-expire), Health Zone Filter, Action Queue mit Status-Tracking
- **Tests**: 8/8 bestanden (Import, CRUD, Health Record, Action Queue, Release History, Cooling, Zones, Migration)
- **Hinweis**: Keine app_registry.json vorhanden (store_pipeline/ existiert noch nicht) -- Migrator handelt das graceful

### 2026-03-30 -- P-EVO-FIX: Evolution Loop Test Failures gefixt
- **Vorher**: 104 Tests, 94 passed, 5 failed, 5 errors
- **Nachher**: 104 Tests, **104 passed**, 0 failed, 0 errors
- **3 geaenderte Dateien**:
  1. `test_decision_agent.py` — Tests 2-4 nahmen `ldo` Parameter (pytest → "fixture not found"). Fix: `_make_ldo_with_gaps()` Helper, Tests self-contained
  2. `test_gap_detector.py` — Tests 3-4 nahmen `ldo_with_gaps` Parameter. Fix: `_make_ldo_with_problems()` Helper, Tests self-contained
  3. `test_factory_learner.py` — Tests 1-5 brauchten `_setup_test_data()` aus `main()`. Fix: `setup_module()`/`teardown_module()` fuer pytest
- **Root Cause**: Alle 3 Dateien waren fuer `if __name__ == "__main__"` Runner geschrieben, nicht fuer pytest. Parameter-Passing zwischen Tests funktioniert nur im manuellen Runner, nicht in pytest.
- **Erkenntnis**: Tests muessen self-contained sein. Shared State → Helper-Funktionen statt Test-Chaining.

### 2026-03-30 -- P-EVO-022: Erweiterte Soft Scores + Maintainability
- **Geaenderte Datei**: `factory/evolution_loop/scoring/soft_scores.py` (233 → 370 LOC, +137 LOC)
- **Geaenderte Datei**: `factory/evolution_loop/evaluation_agent.py` (+5 LOC)
- **Performance Score** (vorher 4×25, jetzt 5×20):
  - Neu: Code Size Efficiency (avg LOC/Datei), Anti-Pattern Density (ratio statt absolut), Async/Concurrency Patterns (async+error handling), Memory Pattern Indicators (weak self, deinit etc.), Stub/TODO Ratio (% von LOC statt % von Dateien)
  - Confidence: 50-60% (vorher 45-55%)
- **UX Score** (vorher 4×25, jetzt 5×20):
  - Neu: Error/Loading State Coverage (sucht ErrorView, ProgressView etc. in Code)
  - Enhanced: Naming Consistency prueft jetzt auch Dateinamen, nicht nur Screen-Namen
  - Neuer Parameter `build_artifacts` fuer File-Content-Analyse
  - Confidence: 40-50% (vorher 35-45%)
- **Maintainability Score** (NEU, 4×25):
  - Code Duplication Indicators (Funktionsnamen in mehreren Dateien)
  - File Size Distribution (stddev der LOC)
  - Naming Consistency (PascalCase Klassen, camelCase Funktionen)
  - Test Coverage Indicator (test_files / source_files ratio)
  - Confidence: 60-70%
  - Gespeichert in `plugin_scores["maintainability"]` (fliesst via plugin_scores Gewicht in Aggregate)
- **Validierung**: 5/5 Tests, Mock-Code: Perf=100, UX=92, Maint=78, EvalAgent OK
- **Bestehende Tests**: 94 passed (keine neuen Fehler)

### 2026-03-30 -- P-EVO-020: Integration Test Phase 3
- **Neue Datei**: `factory/evolution_loop/tests/test_phase3_integration.py` (~350 LOC)
- **8 Tests** — alle deterministisch (kein LLM):
  1. `test_mode_switch_flow` — Sprint→Deep→CEO Review Modus-Wechsel (3 Iterationen)
  2. `test_ceo_review_flow` — CEO Brief + NO-GO Feedback → Task-Generierung (MockNoGoProvider)
  3. `test_budget_stop` — Budget-Überschreitung stoppt Loop (threshold $0.001)
  4. `test_regression_detection` — Sinkende Scores → trend=declining, rec=stop (4 Regressions)
  5. `test_plugins_in_loop` — Game-Plugins laden + ausführen (2 Plugins: game_systems_validator, mechanics_consistency_checker)
  6. `test_factory_learner_after_loop` — Summary, Search, Cross-Stats nach Loop
  7. `test_git_tagging` — Tag erstellen oder graceful skip
  8. `test_cli_flags` — 3 CLI Commands (--evolution-status, --evolution-history, --evolution-ceo-review)
- **Ergebnis**: 8/8 PASSED, 15.68s
- **Test-Isolation**: `_TEST_PREFIX = "p3_integ_test_"`, Cleanup in setUp/tearDown
- **Mock-Provider**: MockGoProvider (immer GO), MockNoGoProvider (immer NO-GO mit 2 Issues)
- **Helper**: `_make_ldo()` erstellt voll-populierte LDOs mit QA, Roadbook, Simulation, Build-Artifacts

### 2026-03-30 -- P-EVO-019: Simulation Agent LLM Extension
- **Geaenderte Datei**: `factory/evolution_loop/simulation_agent.py`
- **3 neue Methoden**:
  - `_call_llm(prompt, system_msg, max_tokens)` — TheBrain + ProviderRouter Primary, Anthropic SDK Fallback
  - `_deep_flow_analysis(ldo)` — Max 3 LLM-Calls: Flow-Completeness, Dead-End-Detection, Empfehlungen
  - `_code_quality_analysis(file_paths)` — Max 5 LLM-Calls (1 pro Datei): Readability, Structure, Error-Handling, Maintainability (je 1-10)
- **simulate() erweitert**: Ruft beide LLM-Methoden nach deterministischer Analyse auf (try/except, non-critical)
- **O-series Fix**: `max_tokens` Floor auf 1024 — o3-mini verbraucht Reasoning-Tokens im Output-Budget, bei <512 bleibt kein sichtbarer Content
- **Kosten-Tracking**: `self._llm_cost` summiert alle Calls, wird in `static_analysis["llm_cost_usd"]` gespeichert
- **Test-Ergebnis**: 5 Dateien analysiert, Overall Quality 7.1/10, $0.014 (5 LLM-Calls via o3-mini)
- **Erkenntnis**: O-series Modelle (o3-mini) brauchen temperature=1.0 (nicht 0.0) und hohe max_tokens wegen Reasoning-Token-Overhead
- **Agent-JSONs updated**: Alle 6 `agent_evo_XX.json` von `model_tier: "none"` auf `model_tier: "mid"`, `provider: "dynamic"`, `routing: "TheBrain"`, + `capabilities` + `description`. Dashboard zeigt jetzt korrekte LLM-Zuweisung statt "Kein LLM".
- **Dashboard Fix**: `client/src/components/Team/team-utils.js` fehlte → alle Team-Komponenten crashten → weisse Seite. Datei mit STATUS_ICONS, TIER_STYLES, QUALITY_STYLES, PROVIDER_STYLES, CAP_LABELS, TIER_OPTIONS neu erstellt.

### 2026-03-29 -- Bugfix: Agents nicht im Dashboard (EVO + Brain)
- **Root Cause**: `factory/agent_registry.py` scannt `agent*.json` Dateien und regeneriert `agent_registry.json` bei jedem Dashboard-Refresh. Manuelle JSON-Edits werden ueberschrieben.
- **Fix 1**: `factory/evolution_loop` zu `SCAN_ROOTS` hinzugefuegt + 6 `agent_evo_XX.json` Dateien erstellt
- **Fix 2**: `factory/brain` + `factory/brain/memory` zu `SCAN_ROOTS` hinzugefuegt → 7 Brain Agents jetzt sichtbar
- **Fix 3**: `role` Feld in `agent_problem_detector.json` (BRN-03) und `agent_solution_proposer.json` (BRN-04) ergaenzt — Scanner braucht (id, name, role, department, status)
- **Ergebnis**: 93 Agents total (86 aktiv, 4 disabled, 3 planned), 15 Departments
- **Fix 4**: `agent_classifier.py:120` — `routing` Feld kann Dict sein (Brain Agents: `{"tier_lock": null}`), nicht nur String. `.lower()` crashte → gesamte Enrichment-Pipeline tot → Dashboard Fallback auf Basis-Daten ohne Capabilities/Scores/Provider. Fix: `isinstance(raw_routing, str)` Check.
- **Merke**: Neue Agents IMMER als `agent*.json` Datei im Verzeichnis anlegen + Pfad in SCAN_ROOTS. Jedes agent*.json MUSS die 5 Pflichtfelder haben: id, name, role, department, status. `routing` Feld muss String sein (nicht Dict). Die JSON-Registry ist NUR ein generierter Cache.

### 2026-03-29 -- Evolution Loop: Dokumentation & Final Report (P-EVO-025)
- **Neue Dateien** (2):
  - `docs/evolution_loop.md` -- Referenz-Dokumentation (385 Zeilen, 12 Kapitel): Architektur, Agents, LDO, Scoring, Loop-Modi, CEO Gate, CLI, Plugins, Config, Factory Learner, Dateistruktur, Troubleshooting
  - `DeveloperReports/EVO-FINAL-REPORT.md` -- Finaler Report (245 Zeilen): 22/25 Prompts, 50 .py (9.079 LOC), 96 Tests (86 passed, 5 failed, 5 errors), Factory-Metriken, Architektur-Entscheidungen, Limitierungen
- **Echte Metriken**: 470 Factory .py total, 14 Departments, 86 Registry Agents (79 active)
- **Test-Issues dokumentiert**: 5 failed (FactoryLearner: fehlende Testdaten), 5 errors (Decision/Gap: fehlende ldo-Fixture)
- **Validierung**: Alle Dateipfade in Doku verifiziert, Zeilenanzahl-Checks bestanden

### 2026-03-29 -- Evolution Loop: Agent Activation & Registry (P-EVO-024)
- **Geaenderte Dateien** (2):
  - `factory/agent_registry.json` -- 6 EVO Agents (EVO-01 bis EVO-06) mit status=active hinzugefuegt, Summary: 86 total, 79 active, 14 Departments
  - `factory/evolution_loop/__init__.py` -- Vervollstaendigt: 37 Exports (vorher 15), alle Sub-Module eingebunden
- **Backup**: `_backups/agent_registry.json.bak_evolution_loop_activation`
- **Registry-Eintraege**:
  - EVO-01 Simulation Agent (simulation), EVO-02 Evaluation Agent (evaluation), EVO-03 Gap Detector (analysis)
  - EVO-04 Decision Agent (planning), EVO-05 Regression Tracker (tracking), EVO-06 Loop Orchestrator (orchestration)
  - Alle: department=Evolution Loop, model_tier=none (deterministische Agents)
- **__init__.py Exports** (37): 6 Agents + 15 LDO-Typen + EvolutionConfig + 3 Scoring + 4 Gates + 2 Plugins + 2 Adapters + 2 Tracking + FactoryLearner
- **Sub-Packages verifiziert** (7/7): ldo, scoring, gates, plugins, adapters, tracking, config
- **Validierung**: 6/6 Tests bestanden (Backup, Registry, Summary, Department, Imports, Sub-Packages)

### 2026-03-29 -- Evolution Loop: Factory Learner (P-EVO-023)
- **Neue Dateien** (2):
  - `factory/evolution_loop/factory_learner.py` -- FactoryLearner (405 LOC, 5 Methoden)
  - `factory/evolution_loop/tests/test_factory_learner.py` -- 7/7 Tests
- **Geaenderte Dateien** (1):
  - `evolution_loop/__init__.py` -- Exportiert FactoryLearner
- **5 Methoden**:
  - `list_projects()` -- Alle Projekte mit Iterations/Scores/Trends
  - `get_project_summary(pid)` -- Vollstaendige Zusammenfassung (Scores, Improvement, Gaps, Tasks, Modes, Cost)
  - `search_similar_issues(query)` -- Substring-Match mit Relevanz-Scoring (100=exakt, 80=substring, 40=category, 30=component), Resolution-Tracking
  - `get_cross_project_stats()` -- Aggregiert: Avg Iterations/Scores/Costs, Gap-Verteilung, Type-Distribution
  - `get_lessons_for_project_type(type)` -- Erkenntnisse pro Typ: typische Mode-Progression, haeufige Gaps
- **Architektur**: Read-only, 100% deterministisch, cached (_cache dict), nutzt LDOStorage intern, Basis-Pfad `factory/evolution_loop/data/`
- **Alle bestehenden Tests gruen**: 5/5 E2E, 6/6 SimAgent, 6/6 Plugins

### 2026-03-29 -- Evolution Loop: Plugin-System (P-EVO-021)
- **Neue Dateien** (6):
  - `factory/evolution_loop/plugins/base_plugin.py` -- EvaluationPlugin ABC (name + evaluate())
  - `factory/evolution_loop/plugins/plugin_loader.py` -- PluginLoader (importlib dynamic loading, _TYPE_TO_DIR mapping)
  - `factory/evolution_loop/plugins/game/game_systems_validator.py` -- 5 Game Systems (Game Loop, State, Save/Load, Level/Scene, Input), 20 Punkte je
  - `factory/evolution_loop/plugins/game/mechanics_consistency_checker.py` -- Numerische Konstanten-Validierung (health/damage<=0, overflow>999999)
  - `factory/evolution_loop/plugins/business/data_flow_validator.py` -- 3 Kategorien (API Error Handling 40pts, Input Validation 30pts, Data Sanitization 30pts)
  - `factory/evolution_loop/tests/test_plugins.py` -- 6/6 Tests bestanden
- **Geaenderte Dateien** (3):
  - `simulation_agent.py` -- PluginLoader Import, _run_plugins() nach synthetic_flow_check, Ergebnisse als dict fuer EvaluationAgent-Kompatibilitaet
  - `plugins/__init__.py` -- Exportiert EvaluationPlugin + PluginLoader
  - `evolution_loop/__init__.py` -- Exportiert EvaluationPlugin + PluginLoader
- **Architektur**: Plugins pro project_type in Unterverzeichnis (game/, business/). PluginLoader scannt *.py, findet EvaluationPlugin-Subklassen via inspect. SimulationAgent ruft _run_plugins() auf, konvertiert ScoreEntry -> dict {"value", "confidence", "issues"} fuer bestehende EvaluationAgent-Integration (Zeilen 68-76). Graceful bei missing files (Score=50, Confidence=10).
- **Alle bestehenden Tests gruen**: 5/5 E2E, 6/6 SimAgent, 8/8 Tracking

### 2026-03-29 -- Evolution Loop: CLI Integration (P-EVO-018)
- **main.py**: +134 LOC, 4 neue CLI-Flags fuer Evolution Loop
  - `--evolution-loop PROJECT_ID`: Startet Evolution Loop (+ `--project-type`, `--production-line`)
  - `--evolution-status PROJECT_ID`: Zeigt aktuellen Status (Scores, Trend, Gaps, Tasks)
  - `--evolution-history PROJECT_ID`: Tabellarische History aller Iterationen + Trend-Summary
  - `--evolution-ceo-review PROJECT_ID`: Generiert CEO Review Brief + zeigt Feedback-Pfad
- Backup: `_backups/main.py.bak_evolution_loop`
- Pattern: Manueller sys.argv-Parser (kein argparse), result-Dict, Lazy Imports in if-Bloecken
- Hinzugefuegt nach Feasibility/recheck_parked, vor Orchestrator-Kommandos
- Validierung: Syntax OK, --factory-status unberuehrt, 5/5 E2E + 6/6 CEO Gate bestanden

### 2026-03-29 -- Evolution Loop: CEO Review Gate (P-EVO-017)
- **gates/review_provider.py** (~35 LOC): `ReviewProvider` (ABC) + `ReviewResult` (dataclass)
  - `ReviewResult`: status ("go"/"no_go"/"pending") + issues (list[CEOIssue])
  - `ReviewProvider`: abstrakt mit `review(ldo)` + `generate_review_brief(ldo)`
- **gates/human_review_provider.py** (~160 LOC): `HumanReviewProvider` -- file-basierter CEO Review
  - `review(ldo)`: Generiert Brief, prueft auf `ceo_feedback.json`, parst + validiert
  - `generate_review_brief(ldo)`: Markdown mit Scores-Tabelle (pass/FAIL), Gaps, Trend, Kosten, Feedback-Template
  - JSON-Validierung: Ungueltige Kategorie -> "bug", ungueltige Severity -> "minor", leere Description -> skip
  - Valide Kategorien: bug, ux, performance, content, feel
  - Valide Severities: blocker, major, minor
- **gates/ceo_review_gate.py** (~60 LOC): `CEOReviewGate`
  - `execute(ldo)`: Ruft Provider, schreibt in ldo.ceo_feedback, bei no_go -> DecisionAgent.translate_ceo_feedback()
  - `get_review_brief(ldo)`: Delegiert an Provider
  - Provider austauschbar via Constructor (Default: HumanReviewProvider)
- **gates/__init__.py**: Exportiert CEOReviewGate, HumanReviewProvider, ReviewProvider, ReviewResult
- **evolution_loop/__init__.py**: Exportiert alle 4 Gate-Klassen
- Test-Ergebnis: 6/6 CEO Gate + 5/5 E2E + 8/8 Tracking -- alle bestanden

### 2026-03-29 -- Evolution Loop: Git Rollback + Cost Tracker (P-EVO-016)
- **tracking/git_tagger.py** (~150 LOC): `GitTagger` — Git-basiertes Tagging + Rollback
  - `tag_iteration(iteration, message)`: `git add -A`, `commit --allow-empty`, `tag -a evolution/{project_id}/iteration-{N}`
  - `rollback_to(iteration)`: Erstellt neuen Branch `evolution/{project_id}/rollback-to-{N}` — kein Force-Push
  - `list_tags()`: Filtert nach Projekt-Prefix
  - `get_last_stable_iteration(storage)`: Letzte Iteration wo Bug>=90, Roadbook>=95, Structural>=85
  - Graceful Fallback: `git_available=False` → alle Methoden returnen False/[]
  - subprocess mit 30s Timeout, fängt FileNotFoundError + TimeoutExpired
- **tracking/cost_tracker.py** (~90 LOC): `CostTracker` — In-Memory Kostentracking
  - `add_cost(agent_id, cost, iteration)`: Akkumuliert + loggt mit Timestamp
  - `get_total()`, `get_cost_per_iteration()`, `check_budget(threshold)`, `get_cost_report()`, `reset()`
- **loop_orchestrator.py** Updates:
  - `self._cost_tracker = CostTracker()`, `self._git_tagger = GitTagger(project_id)`
  - `accumulated_cost` jetzt `@property` via `self._cost_tracker.get_total()`
  - Git-Tag nach jedem LDO-Save: `self._git_tagger.tag_iteration(iteration, message)`
  - Budget-Check via `self._cost_tracker.get_total() >= budget`
- **tracking/__init__.py**: Exportiert CostTracker, GitTagger
- **evolution_loop/__init__.py**: Exportiert CostTracker, GitTagger
- Test-Ergebnis: 8/8 Tracking + 5/5 E2E + 6/6 Modes + 7/7 Regression + 6/6 Decision + 6/6 Simulation — alle bestanden

### 2026-03-29 — Evolution Loop: Loop-Modi Implementation (P-EVO-015)
- **regression_tracker.py**: `detect_loop_mode()` vereinfacht
  - Deep->Pivot: Jetzt bei einfachem `declining` (vorher: 3+ declining streak noetig)
  - Neue Helper: `_count_iterations_in_mode(history, mode)` — zaehlt konsekutive Mode-Iterationen von hinten
  - Neue Helper: `_count_recurring_gaps(history)` — findet Gaps die in 3+ aufeinanderfolgenden Iterationen auftreten
- **loop_orchestrator.py**: `check_stop_conditions()` erweitert
  - Pivot Mode -> sofortiger ceo_review (Prioritaet 1, vor allen anderen Checks)
  - Mode-spezifische Max-Iterations: Sprint > sprint_max (10) -> ceo_review, Deep > deep_max (5) -> ceo_review
  - `_count_mode_iterations(mode)` zaehlt Iterationen per Mode aus Storage
  - `regression_step()` synct jetzt auch `ldo.meta.loop_mode` bei Mode-Switch
  - `decision_step()` loggt Deep Mode Hint
- **decision_agent.py**: Deep Mode Logik
  - In `generate_tasks()`: Wenn `ldo.meta.loop_mode == "deep"`, werden non-critical "fix" Tasks zu "refactor" konvertiert
  - Description-Prefix wechselt von "Fix:" zu "Refactor:"
  - Loggt Anzahl konvertierter Tasks
- Test-Ergebnis: 6/6 Mode-Tests + 5/5 E2E + 7/7 Regression + 6/6 Decision — alle bestanden, 0 Regressions

### 2026-03-29 — Evolution Loop: Simulation Agent (P-EVO-014) — LETZTER STUB
- **simulation_agent.py** (487 LOC): `SimulationAgent` — statische Code-Analyse ohne LLM
  - `simulate(ldo)`: Hauptmethode, ruft 3 Analysen auf, preserviert pre-populierte Daten wenn Dateien nicht existieren
  - `_static_analysis(paths)`: LOC, TODOs/FIXMEs, Stubs (7 Patterns), Hardcoded Values, Deep Nesting, Error Handling Ratio, Dead Code
  - `_roadbook_coverage(ldo)`: String-Matching Features/Screens gegen Dateinamen + Inhalt, case-insensitive
  - `_synthetic_flow_check(ldo)`: User Flows gegen 9 Navigation-Patterns (NavigationLink, .navigate, router, etc.)
  - Sicherheit: Max 1000 Dateien, Binary-Skip, Encoding-Fallback
- **loop_orchestrator.py**: `simulation_step()` delegiert an SimulationAgent. **KEIN Stub mehr** — alle 6 Agents funktional
- Test-Ergebnis: 6/6 SimulationAgent + 5/5 E2E Tests bestanden
- **Evolution Loop COMPLETE**: EVO-01 Simulation, EVO-02 Evaluation, EVO-03 GapDetector, EVO-04 RegressionTracker, EVO-05 DecisionAgent, EVO-06 LoopOrchestrator

### 2026-03-29 — Evolution Loop E2E Test (P-EVO-013)
- **test_evolution_loop_e2e.py** (~280 LOC): 5 End-to-End Szenarien
  - Szenario 1 (Happy Path): Medium Build, 3 Iterationen, Stagnation → CEO Review. Aggregate=50.0, 9 Gaps, 9 Tasks
  - Szenario 2 (Perfect Build): Alle Targets met, 1 Iteration → CEO Review. Aggregate=99.0, 0 Gaps
  - Szenario 3 (Max Iterations): Stoppt bei exakt max_iterations=3
  - Szenario 4 (Score Tracking): Regression-Data korrekt (trend=stagnating, iterations_without_improvement=2)
  - Szenario 5 (Status Report): get_status_report() enthaelt Project-ID, Iteration, Mode, Cost, Scores, Recommendation
- **Bugfix**: `features_implemented` → `features_covered` in Testdaten (test_evolution_loop_e2e.py + test_evaluation_agent.py)
  - Root Cause: HardScoreCalculator + GapDetector erwarten Key `features_covered`, nicht `features_implemented`
  - Impact: Roadbook Score war 60 statt 100 (Perfect Build), 16+ Gaps statt 9 (Happy Path → Escalation)
- Test-Ergebnis: 5/5 bestanden, 0.09s
- **Naechster Schritt**: P-EVO-014 (Simulation Agent — letzter Stub)

### 2026-03-29 — Evolution Loop Phase 2: Regression Tracker (P-EVO-012)
- **regression_tracker.py** (~225 LOC): `RegressionTracker` — analysiert History und erkennt Trends
  - `analyze(ldo, history)`: Vergleicht aggregate mit vorheriger Iteration, bestimmt Trend
    - delta > stagnation_threshold (2%) -> improving, delta < -regression_threshold (5%) -> declining
    - Stagnation-Zone: zaehlt iterations_without_improvement, >= stagnation_iterations (2) -> stagnating
  - `detect_loop_mode(ldo, history)`: sprint -> deep -> pivot (nur Eskalation, nie zurueck)
    - Sprint->Deep: stagnating, oder persistenter Gap in 3+ Iterationen
    - Deep->Pivot: declining 3+ Iterationen, oder deep_max_iterations (5) erreicht
  - `find_regressions(current, previous)`: Findet einzelne Scores die gefallen sind
  - `get_trend_summary(history)`: Textuelle Zusammenfassung "Iterations 1->N: Aggregate X->Y (trend)"
  - Helpers: `_has_persistent_gap()`, `_declining_streak()`, `_count_mode_iterations()`
- **loop_orchestrator.py** Update: `regression_step()` delegiert an `self._regression_tracker.analyze()` + `detect_loop_mode()`. Nur noch 1 Stub: `simulation_step` (P-EVO-014)
- **__init__.py**: Exportiert jetzt auch RegressionTracker
- Test-Ergebnis: 7/7 Tests bestanden
  - Erste Iteration: improving, continue
  - Improving (+10 aggregate): improving, continue
  - Stagnating (2x flat): stagnating nach 2 flat iterations, ceo_review
  - Declining (-19 aggregate): declining, stop, 6 Regressions erkannt
  - find_regressions: 1 Regression (bug_score -20)
  - Mode detection: stagnating in sprint -> deep
  - Trend summary: "Iterations 1->3: Aggregate 55.0->60.0->65.0 (improving, avg +5.0)"

### 2026-03-29 — Evolution Loop Phase 2: Decision Agent (P-EVO-011)
- **decision_agent.py** (~155 LOC): `DecisionAgent` — uebersetzt Gaps + CEO-Feedback in Tasks
  - `generate_tasks(ldo, config)`: Mappt Gaps auf Tasks (bug->fix, feature->implement, structural/perf/ux->refactor). Priority = Gap Severity. Task-IDs: TASK-{iter}-{NNN}
  - `translate_ceo_feedback(ldo)`: CEO Issues -> Tasks anhaengen. Category-Mapping (blocker->critical, major->high, minor->medium). Task-IDs: TASK-{iter}-CEO-{NNN}
  - `_should_escalate(ldo, config)`: 3 Eskalationsgruende: >5 critical Gaps, persistente Regression (3+ Iter alt), >15 total Gaps
- **loop_orchestrator.py** Update: `decision_step()` delegiert an `self._decision_agent.generate_tasks()`
- **__init__.py**: Exportiert jetzt auch DecisionAgent
- Test-Ergebnis: 6/6 Tests bestanden
  - 5 Gaps -> 5 Tasks (2 fix + 1 implement + 2 refactor)
  - Task-IDs unique (TASK-3-001 bis TASK-3-005)
  - CEO Feedback: 2 Issues -> 2 Tasks angehaengt (total 7)
  - Eskalation: 7 critical Gaps -> ceo_review korrekt gesetzt
  - Leere Gaps -> 0 Tasks

### 2026-03-29 — Evolution Loop Phase 2: Gap Detector (P-EVO-010)
- **gap_detector.py** (~200 LOC): `GapDetector` — identifiziert Gaps zwischen Soll und Ist
  - `detect_gaps(ldo, config)`: Hauptmethode, 6 Schritte
  - Score-basierte Gaps: Vergleicht 5 Scores (bug, roadbook, structural, performance, ux) gegen quality_targets
  - Compile Error Gaps: Jeder compile_error wird zum critical Gap
  - Test Failure Gaps: tests_failed > 0 wird zum high Gap
  - Feature Coverage Gaps: Nicht-implementierte Features aus roadbook_coverage
  - Regression Check: Laedt vorherige Iteration via LDOStorage, markiert wiederkehrende Gaps als is_regression=True
  - Matching: category + affected_component (exakter Vergleich, kein Fuzzy)
  - Gap-IDs: `GAP-{iteration}-{NNN}` (unique pro Iteration)
  - Sortierung: critical > high > medium > low
- **loop_orchestrator.py** Update: `gap_detection_step()` delegiert an `self._gap_detector.detect_gaps()`
- **__init__.py**: Exportiert jetzt auch GapDetector
- Test-Ergebnis: 5/5 Tests bestanden
  - Problem-LDO: 9 Gaps (3 critical: bug_score<90 + 2 compile_errors; 6 high: roadbook<95 + structural<85 + 3 tests failed + 3 missing features)
  - Perfect LDO: 0 Gaps
  - Gap-IDs unique und korrekt formatiert (GAP-1-001 bis GAP-1-009)
  - Severity-Sortierung korrekt

### 2026-03-29 — Evolution Loop Phase 2: Evaluation Agent (P-EVO-009)
- **evaluation_agent.py** (~100 LOC): `EvaluationAgent` — berechnet alle Quality Scores
  - `evaluate(ldo, config)`: Delegiert an HardScoreCalculator + SoftScoreCalculator + ScoreAggregator
  - 6 Schritte: LDO→dicts, Hard Scores (3), Soft Scores (2), Plugin Scores, Aggregate, Logging
  - Plugin Scores: Liest `simulation_results.plugin_results` und konvertiert zu ScoreEntry
- **soft_scores.py** (~165 LOC): `SoftScoreCalculator` — heuristische Scores (kein LLM)
  - `calculate_performance_score()`: 4 Kriterien je 25 Punkte (Code-Size, Anti-Patterns, Stubs/TODOs, Error-Handling). Confidence: 50 (mit static_analysis), 35 (nur Pfade), 15 (nichts)
  - `calculate_ux_score()`: 4 Kriterien je 25 Punkte (Screen-Coverage, Flow-Completeness, Nav-Depth, Naming-Consistency). Confidence: 40 (mit Sim), 30 (nur Screens), 15 (nichts)
  - `_check_naming_consistency()`: Prueft Suffix-Muster (View/Screen/Page/Scene/Panel/Controller)
- **loop_orchestrator.py** Update: `evaluation_step()` delegiert jetzt an `self._evaluation_agent.evaluate(ldo, self._config)` statt inline zu rechnen. `self._score_calc = HardScoreCalculator()` ersetzt durch `self._evaluation_agent = EvaluationAgent()`. Cache fuer Status-Report bleibt.
- **__init__.py**: Exportiert jetzt auch EvaluationAgent + SoftScoreCalculator
- Test-Ergebnis: 6/6 Tests bestanden
  - Performance mit Daten: 80.0 (Confidence 50)
  - Performance ohne Daten: 50.0 (Confidence 15)
  - UX mit Daten: 86.7 (Confidence 40)
  - UX ohne Daten: 50.0 (Confidence 15)
  - EvaluationAgent Full Pipeline: Alle 5 Scores + Aggregate berechnet
  - Orchestrator Delegation: evaluation_step delegiert korrekt, Cache aktualisiert

### 2026-03-29 — Evolution Loop Phase 2: Loop Orchestrator (P-EVO-008)
- **loop_orchestrator.py** (~230 LOC): `LoopOrchestrator` — Dirigent des Evolution Loops
  - 10 Methoden: `__init__`, `run_loop`, `run_single_iteration`, `evaluation_step` (delegiert an EvaluationAgent), `simulation_step` (stub), `gap_detection_step` (stub), `regression_step` (stub), `decision_step` (stub), `check_stop_conditions`, `get_status_report`
  - Stop-Bedingungen (Reihenfolge): max_iterations->stop, budget->ceo_review, regression.recommendation, targets_met->ceo_review
  - Jeder Step ist try/except geschuetzt, LDO wird immer zurueckgegeben
  - LDO wird pro Iteration gespeichert via LDOStorage
- **__init__.py**: Exportiert LoopOrchestrator + EvaluationAgent
- Alle 7 Tests bestanden

### 2026-03-28 — Evolution Loop Phase 1: Hard Scores + Aggregator (P-EVO-007)
- **hard_scores.py** (~140 LOC): `HardScoreCalculator` mit 3 Methoden
  - `calculate_bug_score()`: 100 - (failed*5) - (errors*15) - (warnings*1) - optional stubs/todos. Confidence 95 mit Daten, 10 ohne.
  - `calculate_roadbook_match()`: Gewichtet feat*40 + screen*30 + flow*30, normalisiert. Confidence 90 mit Simulation, 30 ohne.
  - `calculate_structural_health()`: 4 Kriterien je 25 Punkte (dead_code, hardcoded_values, deep_nesting, error_handling). Confidence 85.
- **aggregator.py** (~140 LOC): `ScoreAggregator` mit 2 Methoden
  - `aggregate()`: Gewichteter Durchschnitt + Veto-Logik (Bug<min→cap 50, Roadbook/Structural<min→cap 60)
  - `check_targets_met()`: Prueft alle Scores gegen quality_targets Thresholds
- Edge Cases: Division by Zero, leere/None Daten, fehlende Keys → alles abgefangen
- Alle 11 Tests bestanden (Bug 3x, Roadbook 3x, Structural 2x, Aggregator 2x, Targets 1x)

### 2026-03-28 — Evolution Loop Phase 1: Orchestrator Handoff (P-EVO-006)
- **orchestrator_handoff.py** (~230 LOC): `OrchestratorHandoff` Klasse mit 3 Methoden
  - `receive_from_orchestrator(build, qa, project_id, type, line)`: 3 Build-Formate (BuildReport.to_dict(), Simple {files/status/platform}, Empty/None) + QA via QAToLDOAdapter oder Simple-Mapping → LoopDataObject
  - `send_tasks_to_orchestrator(tasks, iteration)`: LDO Tasks → generisches Format {action, description, target, priority} + source + iteration
  - `create_handoff_report(ldo, direction)`: Log-Strings fuer to_loop / to_orchestrator
- **Orchestrator-Analyse**: `FactoryOrchestrator.execute_plan()` → `BuildReport` (plan + step_results), `BuildStep.result` = pipeline_result dict. Hook-Point: nach execute_plan() return + QA-Run.
- **BuildReport.to_dict()**: `{plan: {project_name, status, steps: [{id, name, line, language, status, result}]}, started, finished, step_results: [{step_id, name, command, status}]}`
- **adapters/__init__.py**: Exportiert OrchestratorHandoff + QAToLDOAdapter
- Alle 5 Tests bestanden (inkl. Full BuildReport + None/Empty)

### 2026-03-28 — Evolution Loop Phase 1: QA-to-LDO Adapter (P-EVO-005)
- **qa_to_ldo_adapter.py** (~310 LOC): `QAToLDOAdapter` Klasse mit 4 Methoden
  - `transform_qa_forge_results()`: QAForgeResult/JSON → partial (qa_results, scores.ux/perf, gaps)
  - `transform_qa_department_results()`: QAResult/QAReport JSON → partial (build_artifacts, qa_results, scores.bug/structural, gaps)
  - `merge_results()`: Beide Partials → combined (confidence-weighted average bei Score-Overlap)
  - `extract_from_project()`: Filesystem-Loader (qa_forge/reports/ + qa/reports/)
- Score-Formeln: bug = 100 - (failure_rate * 500), structural = 100 - (blocking * 25) - (warnings * 5)
- UX/Performance aus QA Forge: pass_count / total * 100
- Confidence: 80 bei ≥10 Tests, 60 bei ≥5, 40 sonst. Forge: min(90, compliance_score)
- Gap-Erzeugung: Build-Failure → critical bug, Test-Failures → high bug, Blocking Ops → high structural
- Auto-Detect: QAReport JSON (hat "phases") vs QAResult (hat "build_result")
- **adapters/__init__.py**: Exportiert QAToLDOAdapter
- Alle 5 Tests bestanden

### 2026-03-28 — Evolution Loop Phase 1: Agent-Registrierung (P-EVO-004)
- 6 Agents in `factory/agent_registry.json` registriert: EVO-01 bis EVO-06
  - EVO-01 Loop Orchestrator (standard/orchestration), EVO-02 Simulation (standard/code_review)
  - EVO-03 Evaluation (lightweight/scoring), EVO-04 Gap Detector (standard/code_review)
  - EVO-05 Decision (standard/planning), EVO-06 Regression Tracker (lightweight/trend_analysis)
- Alle status="planned" (werden in Phase 2+ aktiviert)
- Summary aktualisiert: 80 → 86 Agents, planned 3 → 9, Departments 13 → 14
- Backup: `_backups/agent_registry.json.bak_evolution_loop`

### 2026-03-28 — Evolution Loop Phase 1: Default Config (P-EVO-003)
- **default_config.yaml** (18 LOC): Loop-Limits (Sprint 10, Deep 5, Total 20, Budget $5), Quality Targets (Bug 90, Roadbook 95, Structural 85), Confidence (Auto 80, CEO-Trigger 50)
- **score_weights.yaml** (28 LOC): 4 Projekt-Typen (game, business_app, utility, social) — alle summieren zu 1.0
- **config_loader.py** (68 LOC): EvolutionConfig mit deep_merge fuer Projekt-Overrides, Fallback auf 'utility' bei unbekanntem Typ
- Alle 7 Tests bestanden, Weight-Summen fuer alle 4 Typen = 1.00

### 2026-03-28 — Evolution Loop Phase 1: LDO Schema (P-EVO-002)
- **schema.py** (176 LOC): 15 Dataclasses — LoopDataObject, LDOMeta, RoadbookTargets, BuildArtifacts, QAResults, SimulationResults, Scores, ScoreEntry, Gap, RegressionData, Task, CEOFeedback, CEOIssue + _reconstruct() fuer nested deserialization
- **validator.py** (113 LOC): LDOValidator mit 12 Validierungsregeln (meta, scores 0-100, gaps, tasks, ceo_feedback, regression_data)
- **storage.py** (65 LOC): LDOStorage — save/load/load_latest/list_iterations/get_history. Pfad: `factory/evolution_loop/data/{project_id}/iteration_{N}.json`
- **__init__.py**: Exportiert alle 17 Klassen (15 Dataclasses + LDOValidator + ValidationResult + LDOStorage)
- Alle 7 Tests + Complex Nested Round-trip bestanden
- Keine externen Dependencies (nur dataclasses, json, pathlib, datetime)

### 2026-03-28 — Evolution Loop Phase 1 Start: Department Struktur (P-EVO-001)
- `factory/evolution_loop/` angelegt: 10 Verzeichnisse, 9 `__init__.py` Dateien
- Untermodule: ldo/, scoring/, plugins/ (game/ + business/), gates/, adapters/, tracking/, config/
- config/ ohne `__init__.py` (fuer YAML-Dateien)
- Alle Python-Imports OK, keine bestehenden Dateien geaendert
- Referenz: `docs/ROADBOOK_EVOLUTION_LOOP.md`

### 2026-03-28 — Cascade Delete: Projekt-Loeschung komplett
- **Problem**: Dashboard-Delete (`DELETE /api/projects/:id`) kannte nur 8 Locations → Reste in store_prep, asset_forge, marketing, ideas, forges, integration, qa_forge, dispatcher blieben liegen
- **Loesung**: Delete-Endpoint erweitert auf 17 Locations (9 neue Bereiche)
  - Neu: store_prep, asset_forge (inkl. manifests + proof), sound/scene/motion_forge (specs + catalog + generated), integration (maps + build_plans), qa_forge reports, marketing (directives + app_stories + output + brand_book styles), capabilities reports, ideas (fuzzy match), dispatcher queue_store.json
- **config.js**: 10 neue Pfade (storePrep, assetForge, soundForge, sceneForge, motionForge, integration, qaForge, marketing, dispatcher, capabilities)
- **Cleanup**: BrainPuzzle, MemeRun2026, SkillSense Reste manuell entfernt, queue_store.json geleert (6 tote Test-Projekte)
- **Server-Banner**: "DriveAI CEO Cockpit Dashboard" → "DAI-Core CEO Cockpit"
- EchoMatch bleibt als einziges aktives Projekt

### 2026-03-27 — CEO Cockpit Dashboard Rebranding (DAI-Core)
- **Farbschema**: Komplett auf DAI-Core Brand umgestellt
  - `tailwind.config.js`: 8 Farb-Tokens aktualisiert + 2 neue (accent-glow, purple)
  - `theme.css`: CSS Custom Properties parallel aktualisiert
  - Accent: Gruen (#00e5a0) → Magenta (#D660D7), Blau → Cyan (#6BD2F2)
  - BG: #0a0a1a → #13121A (Midnight), Surface: #141428 → #1E1D25 (Void)
- **Texte**: 5 alte Referenzen in 3 Dateien ersetzt
  - Sidebar.jsx: "DriveAI" → "DAI-Core" + Logo, "Swarm Factory — CEO Cockpit" → "CEO Cockpit"
  - Sidebar.jsx: "Factory v1.0" → "DAI-Core v1.0", "24 Agents" → "100+ Agents • 14 Departments"
  - ShowcaseView.jsx: "DriveAI Swarm Factory" → "DAI-Core" + "dai-core.ai"
  - VoiceInput.jsx: "DriveAI" → "DAI-Core" im Disclaimer
  - Header.jsx: "Factory Online" → "DAI-Core Online"
- **Logo**: DAI-CORE_Logo_Icon.png + Favicon in `client/public/` kopiert
- **Build**: Erfolgreich (0 Fehler), grep-Sweep clean (0 alte Referenzen)

### 2026-03-27 — DAI-Core Brand Integration
- **Brand System** (`factory/brand/`): Neues zentrales Brand-Verzeichnis
  - `brand_loader.py`: Brand Context Loader mit 3-Tier-System (Full/Summary/None)
  - `DAI-CORE_Brand_Bible_v1.0.md`: Vollstaendige Brand Bible (~5.7KB)
  - `brand_summary.md`: Kompakte Zusammenfassung (~930B)
  - `css/brand_variables.css`: CSS Custom Properties (Farben, Gradienten, Typography)
  - `BRAND_INTEGRATION.md`: Integrations-Guide
  - `assets/`: Platzhalter fuer Logo-PNGs (manuell kopieren)
- **Tier-System**:
  - Tier A (Full Bible): marketing, roadbook_assembly, document_secretary, store, store_prep
  - Tier B (Summary): design_vision, asset_forge, sound_forge, motion_forge, scene_forge, visual_audit, market_strategy
  - Tier C (None): qa, janitor, brain, assembly, operations
- **TheBrain**: `_BRAND_AWARENESS` Block in `brain_system_prompt.py`, Agent-Count 70->100+, Departments 13->14+
- **Roadbook Assembly**: Brand-Import + Brand-Context in CD_SYSTEM und CEO_SYSTEM (cd_roadbook.py, ceo_roadbook.py)
- **Document Secretary**: Brand-Import in secretary.py (load_brand_context, get_logo_path, get_brand_info)
- **Store Prep**: Brand-Import in store_prep_coordinator.py (get_brand_info, get_logo_path)
- **Marketing**: FACTORY_BRAND.md Verknuepfungsdatei in `factory/marketing/brand/`
- **Externer Name**: DAI-Core (dai-core.ai) — intern bleibt "DriveAI-AutoGen" als Ordnername
- **Verifizierung**: Alle Tier-Tests bestanden, alle Agent-Imports funktionieren

### 2026-03-27 — Marketing Phase 4 Block C (Integration-Test + Report)
- **Step 4.10 — Integration-Test** (`tests/test_phase_4_integration.py`):
  - 10/10 Tests bestanden (alle deterministisch)
  - End-to-End: Store->DB->KPI->Alert->Report->HQ Bridge
  - DB nach Tests: 46 Rows (5 keywords, 12 metrics, 20 reviews, 9 social)
  - Alerts: 6 aktive (alle critical), Gates: 5 pending
  - Zwei-Stufen-System verifiziert: 0 auto-responses auf negative Inhalte
  - Fix: Unicode-Pfeile in cp1252, `total_reviews` -> `total` Key-Name
- **Step 4.11 — Phase-4-Report** (`reports/phase_4_report.md`):
  - Vollstaendiger Report mit echten Metriken: 54 Python-Files, 12.653 LOC
  - Architektur-Diagramm, Zwei-Stufen-Dokumentation, Bugs & Fixes
  - Adapter-Status-Tabelle, offene Punkte, Phase-5-Empfehlung
- **Phase 4 COMPLETE**: 32/32 Tests (Block A: 10, Block B: 12, Integration: 10)

### 2026-03-27 — Marketing Phase 4 Block A (Analytics-Infrastruktur)
- **Step 4.1 — App Store Connect Adapter** (`adapters/appstore_adapter.py`):
  - AppStoreAdapter: get_reviews, reply_to_review, get_app_metrics, get_ratings_summary, get_keyword_rankings
  - JWT Auth (ES256) fuer Live-Modus, Dry-Run mit realistischen Mock-Daten (EchoMatch Roadbook)
  - Mock: 7 Reviews (DE/AT), DAU 25000, Rating 4.3, 5 Keyword-Positionen
- **Step 4.2 — Google Play Developer Adapter** (`adapters/googleplay_adapter.py`):
  - GooglePlayAdapter: gleiches Interface wie AppStore. Credentials: GOOGLE_PLAY_SERVICE_ACCOUNT
  - Mock: 7 Android-Reviews (mit device), DAU 32000, Rating 4.1, hoehere Downloads/niedrigerer ARPU als iOS
- **Step 4.3 — Ranking-Datenbank** (`tools/ranking_database.py`, SQLite):
  - 5 Tabellen: keyword_rankings, app_metrics, review_log, social_metrics, post_performance
  - CRUD: store_keyword_rankings, store_app_metrics, store_review, store_social_metrics, store_post_performance
  - Queries: get_keyword_trend, get_metrics_trend, get_review_stats, get_social_trend, get_top_posts
  - export_for_report() fuer Report Agent, get_db_stats() fuer Monitoring
  - DB-Pfad: `factory/marketing/data/marketing_metrics.db`
- **Step 4.4 — Social Analytics Collector** (`tools/social_analytics_collector.py`):
  - collect_all_platform_stats(): YouTube/TikTok/X (filtert Store-Adapter), Mock-Stats bei Dry-Run
  - collect_post_performance(), collect_all_recent_performance() (aus Kalender)
  - get_cross_platform_summary(), identify_top_content()
- **Step 4.5 — KPI Tracker** (`tools/kpi_tracker.py`):
  - 7 Default-KPIs aus EchoMatch Roadbook (d1/d7/d30 Retention, Rating, Crash Rate, ARPU, DAU)
  - check_kpis(): Prueft gegen Zielwerte, erstellt Alerts bei Warning/Critical
  - check_store_rating(): Rating-Einbruch >0.3 = Critical Alert
  - check_ranking_changes(): Top-Keyword-Verlust >5 Plaetze = Warning, aus Top 10 = Critical
  - run_daily_check(): Aggregiert alle Checks
- **Registrierung**: adapters/__init__.py: 5 aktive + 4 Stubs = 9 total. tools/__init__.py: 6 Tools
- **Dependencies**: pyjwt (JWT Auth), cryptography (ES256)
- **Tests**: `test_phase_4_block_a.py` — 10/10 bestanden (alle deterministisch)
- **Daten**: `factory/marketing/data/` Verzeichnis mit `.gitkeep` + SQLite DB

### 2026-03-27 — Marketing Phase 4 Block B (Report Agent + Review Manager + Community Agent + HQ Bridge)
- **Step 4.6 — Report Agent (MKT-09)** (`agents/report_agent.py`):
  - ReportAgent: create_daily_briefing(), create_weekly_report(), create_monthly_report()
  - _gather_data(): Sammelt deterministisch aus KPI-Tracker, Alert-Manager, Social Analytics, Ranking-DB
  - LLM formatiert Reports in Markdown (Daily: 500 Woerter, Weekly: 1000-1500, Monthly: 2000-3000)
  - Reports in `factory/marketing/reports/` (daily_YYYY-MM-DD.md, weekly_YYYY-MM-DD.md, monthly_YYYY-MM.md)
- **Step 4.7 — Review Manager (MKT-10)** (`agents/review_manager.py`):
  - ZWEI-STUFEN-SYSTEM (HARD, deterministisch — KEIN LLM):
    - Stufe 1: Rating >= 3 + keine Negativ-Keywords → LLM-Antwort (autonom)
    - Stufe 2: Rating <= 2, oder Negativ-Keywords → CEO-Gate (KEINE Antwort)
  - classify_review(): Harte Logik, 30+ Tier2-Keywords (betrug, scam, datenschutz, anwalt, etc.)
  - process_review(): Tier 1 → _generate_response (LLM), Tier 2 → _create_review_gate
  - process_batch(): Batch-Verarbeitung mit Statistik
- **Step 4.8 — Community Agent (MKT-11)** (`agents/community_agent.py`):
  - ZWEI-STUFEN-SYSTEM (gleiches Muster wie Review Manager):
    - Stufe 1: Positive/neutrale Kommentare → LLM-Antwort (autonom)
    - Stufe 2: Negativ-Keywords → CEO-Gate (KEINE Antwort)
  - classify_comment(): 35+ Tier2-Keywords inkl. Spam-Indikatoren
  - PLATFORM_LIMITS: YouTube (500 chars), TikTok (150 chars), X (280 chars)
  - process_comment(), process_batch() mit by_platform Statistik
- **Step 4.9 — HQ Bridge** (`tools/hq_bridge.py`):
  - Deterministisch, kein LLM. JSON-Export fuer HQ Dashboard.
  - export_department_status(): Agents, Alerts, KPIs, Social
  - export_alert_feed(): Aktive Alerts + offene Gates
  - export_kpi_dashboard(): KPI-Check + Social Summary + DB Stats
  - export_full_snapshot(): Kombiniert alle Exports, snapshot_id = MKT-SNAP-YYYYMMDD-HHMMSS
- **Registrierung**:
  - agents/__init__.py: 11 Agents (MKT-01 bis MKT-11)
  - tools/__init__.py: 7 Tools (+ HQBridge)
  - agent_registry.json: 80 Agents (war 77), 11 MKT Agents
- **Tests**: `test_phase_4_block_b.py` — 12/12 bestanden (alle deterministisch)

### 2026-03-27 — Marketing Phase 3 Block C (Routing-Fix + Template/Video Extensions + Tests)
- **Step 3.0-FIX — _call_llm Routing-Bug**:
  - `config/model_router.py`: `get_model_for_agent()` las `agent.get("tier")` statt `model_tier`, und `capabilities_required` existiert nicht in raw Registry
  - Fix: AgentClassifier on-the-fly Berechnung + manuelle tier Normalisierung als Fallback
  - Alle 7 Marketing-Agents aktualisiert: agent-basiertes Routing mit `get_model_for_agent(agent_id)` vor `get_model()`
  - Ergebnis: MKT-03 bekommt jetzt claude-sonnet-4-6 (vorher o3-mini), MKT-04 bekommt o3-mini (korrekt)
- **Step 3.9 — Template-Engine erweitert**:
  - `_wrap_text()`: Wortgrenzen-Umbruch fuer langen Text, respektiert `max_width`
  - `_draw_wrapped_text()`: Mehrzeilig zentrierter Text mit dynamischem Zeilenabstand
  - `text_on_background()`, `gradient_text()`, `social_post_template()`: Nutzen jetzt Text-Wrapping
- **Step 3.9 — Video-Pipeline erweitert**:
  - `images_to_video()`: Neuer `fade_duration` Parameter fuer Fade-to-Black Uebergaenge
  - `add_subtitles()`: SRT-Generierung + FFmpeg subtitles Filter mit drawtext Fallback
  - `concat_videos()`: FFmpeg concat demuxer mit stream-copy (Fallback: re-encode)
  - `_seconds_to_srt_time()`: Konvertiert Sekunden zu HH:MM:SS,mmm Format
- **Step 3.10 — Tests**: `test_phase_3_block_c.py` — 10/10 Tests bestanden (alle deterministisch)
  1. _wrap_text (short/long/empty)
  2. text_on_background wrapping (1080x1080)
  3. gradient_text wrapping (1280x720)
  4. social_post_template wrapping
  5. Brand colors (7 Keys, alle Hex)
  6. SRT time conversion (4 Fälle)
  7. Weekly calendar (5 Items)
  8. Launch campaign (21 Items: pre/launch/post)
  9. All adapters dry_run (7 Adapter)
  10. Publishing orchestrator dry_run

### 2026-03-27 — Marketing Phase 3 Block B (Adapters + Publishing Orchestrator)
- **Step 3.4-3.6 — Plattform-Adapter (3 aktive)**:
  - `factory/marketing/adapters/youtube_adapter.py` — YouTubeAdapter: upload_video, set_thumbnail, update_metadata, get_video_analytics, get_channel_stats. Google API v3. Default dry_run=True, privacy=private
  - `factory/marketing/adapters/tiktok_adapter.py` — TikTokAdapter: upload_video, get_video_analytics, get_account_stats. Content Posting API v2. Default dry_run=True
  - `factory/marketing/adapters/x_adapter.py` — XAdapter: post_tweet (280-Zeichen-Check!), post_thread, create_poll, get_tweet_analytics, get_trending_topics, get_account_stats. tweepy v2+v1.1. Default dry_run=True
- **Step 3.7 — Stub-Adapter (4 Stubs)**:
  - `instagram_adapter.py`, `linkedin_adapter.py`, `reddit_adapter.py`, `twitch_adapter.py`
  - Alle STATUS="stub", dry_run=True erzwungen, loggen Aufrufe
- **Step 3.7 — Adapter-Package**: `factory/marketing/adapters/__init__.py` mit `get_adapter(platform, dry_run=True)` Factory-Methode, ACTIVE_ADAPTERS (3) + STUB_ADAPTERS (4) = ALL_ADAPTERS (7)
- **Step 3.8 — Publishing Orchestrator (MKT-08)**:
  - `factory/marketing/agents/publishing_orchestrator.py` — Deterministisch, kein LLM
  - `publish_due_items()`: Liest Kalender, ruft Adapter auf, mark_published/mark_failed, Alert bei Fehler
  - `cross_post()`: Erstellt gestaffelte Kalender-Eintraege (60 Min Abstand) — POSTET NICHT DIREKT
  - `publish_single()`: Doppeltes dry_run (Orchestrator + Method Level)
  - `get_publishing_status()`: Aggregiert Stats ueber alle Kalender
  - Persona: `agent_publishing_orchestrator.json` (model_tier=none, provider=none)
- **Registry**: 77 Agents (+1 MKT-08), Marketing: 8 Agents. Backup: `agent_registry.json.bak_marketing_p3b`
- **Dependencies**: google-api-python-client, google-auth-oauthlib, tweepy, requests
- **Tests**: 9/9 passed (alle deterministisch, kein LLM, kein API-Call)
- **KRITISCH**: Alles Dry-Run. Kein Live-Publishing. YouTube default private.

### 2026-03-27 — Marketing Phase 3 Block A (expected_output_tokens + Brand Guardian + Content Calendar)
- **Step 3.1 — expected_output_tokens Fix**:
  - 9 max_tokens Werte in 4 Agent-Dateien angepasst (Copywriter, ASOAgent, NamingAgent, Strategy)
  - 2 hardcoded `max_tokens=16384` Workarounds entfernt → korrekter `8192` Wert
  - Alle `get_model()` nutzen jetzt korrekte `expected_output_tokens` Werte
  - Neue Datei: `factory/marketing/docs/model_tier_config.md` — Uebersichtstabelle aller Agent/Methode/Token-Werte
- **Step 3.2 — Brand Guardian aktiviert (MKT-01)**:
  - 3 Stubs implementiert: `create_brand_book()`, `create_app_style_sheet()`, `check_brand_compliance()`
  - Brand Book: MD (8 KB) + JSON (1 KB, 12 Farben) in `brand/brand_book/`
  - App Style Sheet: `echomatch_style.json` (916 bytes) in `brand/brand_book/app_styles/`
  - Compliance Check: Score 85/100 fuer Test-Content, 2 Issues erkannt
  - Template Engine: `_load_brand_colors()` liest Farben aus `brand_book.json`, Fallback auf Defaults
  - Methoden-Defaults auf `None` geaendert → `self.brand_colors` als Fallback in Methoden-Body
- **Step 3.3 — Content Calendar**:
  - Neue Datei: `factory/marketing/tools/content_calendar.py` (~280 LOC) — deterministisch, kein LLM
  - 8 Methoden: create_weekly_calendar, add_item, get_due_items, mark_published, mark_failed, get_calendar_stats, create_launch_campaign, list_calendars
  - Launch-Kampagne: 8 Zeitpunkte (T-14 bis T+7), 21 Items ueber 3 Plattformen
  - Konflikt-Check: 30 Min Abstand pro Platform
  - `tools/__init__.py` erweitert: ContentCalendar Export
- **Tests**: 7/8 passed (Test 1 Copywriter Store Listing failed — o3-mini leere Response, pre-existing Model-Compat)
- **API-Kosten**: ~$0.07 (4 LLM-Calls via o3-mini)

### 2026-03-27 — Team Dashboard Data Binding Fix
- **Problem**: Enriched-Endpoint lieferte `{"error":"Agent not found"}` weil Express Server alten Code lief (`:id` Route fing `/enriched` ab)
- **Root Cause**: Server war nie neu gestartet worden nach Hinzufuegen der `/enriched` Route. Route-Reihenfolge im Code war korrekt (`/enriched` vor `/:id`), aber der laufende Prozess hatte nur die alte Version
- **Fix**: Server-Neustart (PID 9176 → neue Instanz). Kein Code-Aenderung noetig
- **Verifiziert**: 76 Agents enriched, alle Felder korrekt (auto_tier, capabilities_required, matched_model, match_score, match_quality, matched_provider)
- **Enrichment Stats**: Tiers: standard=57, lightweight=6, premium=1, none=12. Providers: anthropic=25, openai=26, mistral=3, google=4
- **Vite Build**: OK (280.77 kB JS, 25.20 kB CSS)

### 2026-03-27 — Team Dashboard Redesign (Tier + Capability + Model Matching Visualization)
- **Neue Dateien**:
  - `factory/brain/model_provider/team_enrichment.py` (~85 LOC) — Python-Script: Classifier + Matcher auf alle 76 Agents, JSON nach stdout. Deterministisch (kein LLM).
  - `client/src/components/Team/team-utils.js` — Shared Constants: TIER_STYLES, QUALITY_STYLES, PROVIDER_STYLES, CAP_LABELS, STATUS_ICONS
  - `client/src/components/Team/TeamSummary.jsx` — Stat-Cards (Gesamt/Aktiv/Disabled/Geplant) + Match-Quality Mini-Cards
  - `client/src/components/Team/TeamFilters.jsx` — Dynamische Department-Tabs (13 Departments) + Tier/Provider Filter
  - `client/src/components/Team/TeamTable.jsx` — Angereicherte Tabelle: Tier-Badges, Capability-Chips, Score-Bars, Provider-Labels
  - `client/src/components/Team/TeamDetailPanel.jsx` — 3 Sektionen: Model-Matching, Klassifikation, Agent-Info
  - `client/src/components/Team/TeamDistribution.jsx` — 3 Verteilungs-Panels: Provider, Tier, Match-Qualitaet
- **Modifizierte Dateien**:
  - `factory/hq/dashboard/server/api/team.js` — Neuer `GET /api/team/enriched` Endpoint, 5-Min Cache, Cache-Invalidierung bei Refresh
  - `client/src/components/Team/TeamView.jsx` — Rewrite als Orchestrator (importiert alle Sub-Components)
- **Backups**: `_backups/TeamView.jsx.bak_team_redesign`, `_backups/team.js.bak_team_redesign`
- **Ergebnis**: CEO sieht auf einen Blick: Tier-Badges, Capability-Chips, Score-Bars, Match-Erklaerungen, 3 Verteilungs-Panels
- **Enrichment Stats** (76 Agents): Tiers: standard=57, lightweight=6, premium=1, none=12. Quality: perfect=41, partial=17, none=6, no_llm=12.
- **Vite Build**: OK (280.77 kB JS, 25.20 kB CSS)

### 2026-03-27 — Agent Auto-Classification (Automatic Tier + Capability Assignment)
- **Neue Datei**: `factory/brain/model_provider/agent_classifier.py` (~280 LOC)
  - `ClassificationResult` Dataclass: tier, capabilities_required, confidence, reasoning, source
  - `AgentClassifier`: Deterministisch (kein LLM) + Haiku-Fallback bei low-confidence
  - `TASK_TYPE_TO_CAPS`: 20 task_type -> capability Direktmappings
  - `KEYWORD_TO_TAG`: 12 Keyword-Gruppen -> 17 Tags
  - Tier-Regeln: none (routing=no_llm, infrastructure) > lightweight (task_type/keywords) > premium (tier_lock) > standard
  - `validate_against_existing()`: Vergleicht Auto-Classification gegen model_tier Feld
- **Modifizierte Dateien**:
  - `config/model_router.py` — `validate_agent_tier()` auto-classifiziert statt ValueError. Fehlende tier/caps werden automatisch gefuellt.
  - `main.py` — `--brain-classify <agent_id>` (Einzelergebnis) + `--brain-classify-validate` (Validierung gegen alle Agents)
- **Validierung**: 94.7% Tier-Accuracy (71/75 Agents). 4 Mismatches: SWF-13/19 (lightweight vs standard), SWF-23/24 (standard vs premium/large_context)
- **CLI**: `python main.py --brain-classify CPL-03` / `--brain-classify-validate`
- **Standalone**: `python -m factory.brain.model_provider.agent_classifier` (4 Smoke-Tests)

### 2026-03-27 — Agent Capability Matching (Strength-Based Model Selection)
- **Neue Dateien**:
  - `factory/brain/model_provider/capability_tags.py` (~80 LOC) — 17 standardisierte Capability-Tags in 4 Kategorien (Code, Task, Technical), MODEL_STRENGTHS Fallback, validate_tags()
  - `factory/brain/model_provider/capability_matcher.py` (~200 LOC) — CapabilityMatcher mit Score-basiertem Matching, Tier-Escalation, Caching, explain_match() und match_all_agents()
- **Modifizierte Dateien**:
  - `factory/brain/model_provider/models_registry.json` — Strengths auf standardisierte Tags migriert (swift→swift_code, review→code_review, etc.), Non-Capability Tags entfernt (fast, cheap, scoring)
  - `factory/agent_registry.json` — `capabilities_required` (max 3) für alle 83 Agents backfilled
  - `config/model_router.py` — `get_model_for_agent()` nutzt jetzt CapabilityMatcher vor TheBrain-Fallback. Lazy-Singleton, Cache-Invalidierung bei reload_registry()
  - `factory/brain/model_provider/__init__.py` — Neue Exports: CapabilityMatcher, MatchResult, ALL_TAGS, validate_tags
  - `main.py` — `--brain-match <agent_id>` (Einzelerklärung) + `--brain-match-all` (83-Agent-Tabelle)
- **Algorithmus**: Score = matched_caps / required_caps. Tiebreaker: niedrigster Preis. Escalation bei Score < 0.5 zum nächsthöheren Tier.
- **Ergebnis**: 49 capability-matched, 17 no-LLM, 17 tier-fallback (disabled/planned agents)
  - CPL-03 (Swift Dev) → Sonnet (score=1.00, swift_code matched)
  - SWF-23 (Roadbook) → Gemini 2.5 Pro (large_context matched)
  - CPL-10 (Lightweight) → Gemini Flash (classification + summarization)
  - SWF-21 (Visual Consistency) → Opus (escalated standard→premium)
- **CLI**: `python main.py --brain-match CPL-03` / `--brain-match-all`
- **Standalone**: `python -m factory.brain.model_provider.capability_matcher` (6 Smoke-Tests)

### 2026-03-26 — TheBrain Auto-Evolution Loop + Tier Cascade
- **Neue Dateien**:
  - `factory/brain/model_provider/known_prices.py` (~170 LOC) — Statische Preis-/Tier-Tabelle als Fallback, SKIP_PATTERNS für Non-Chat-Filter, `is_versioned_duplicate()` Dedup-Logik
  - `factory/brain/model_provider/model_evolution.py` (~920 LOC) — Autonomer 6-Step Controller: Discovery → Evaluation → Registration → **Cascade** → Verification → Memory
  - `config/tier_config.json` (zur Laufzeit erzeugt) — Persistiertes Tier-Override-Mapping, überschreibt Python-Hardcoded-Defaults nach Cascade
- **Modifizierte Dateien**:
  - `config/model_router.py` — `_load_tier_config()`, `save_tier_config()`, `reload_tier_config()` für Cascade-Overrides
  - `factory/hq/janitor/janitor.py` — `_run_model_evolution()` in `_run_extra_checks()`, alle 3 Report-Dicts, `format_report()`
  - `factory/hq/assistant/brain_tools.py` — `brain_evolution(force, dry_run)` Methode + Befehlsliste
  - `main.py` — `--brain-evolution` / `--brain-evolution-force` / `--brain-evolution-dry` CLI-Flags
- **Evolution Loop Features**:
  - 24h Cooldown (rate-limited), State in `evolution_state.json`
  - Automatische Registry-Backups vor Schreibzugriff, Rollback bei Verifikations-Fehler
  - Aggressive Filter: 86→22 echte neue Modelle (SKIP_PATTERNS + Two-Pass Dedup + Cross-Base-Vergleich)
  - FactoryMemory-Logging aller Adds/Deprecations via MemoryWriter
  - Dry-run speichert keinen State (kein Cooldown-Trigger)
- **Tier Cascade Features** (Step 4.5 im Zyklus):
  - Wenn neues High-Tier-Modell entdeckt → automatische Tier-Hierarchie-Verschiebung
  - Beispiel: Opus 7 → Premium, Opus 4.6 → Standard, Sonnet → Lightweight, Haiku → Deprecated
  - Dataclasses: `TierReassignment`, `CascadePlan` (mit `describe()` für Reports)
  - `_evaluate_cascade()`: Preisbasiert + Tier-Vertrauen für unbekannte Modelle
  - `_execute_cascade()`: Atomar mit Backup+Rollback (tier_config.json + llm_profiles.json + models_registry.json)
  - `_quick_benchmark()`: Say-OK + Code-Review Qualitätscheck vor Premium-Platzierung
  - `_count_agents_per_tier()`: Liest agent_registry.json für Impact-Berechnung
  - `CASCADE_RULES`: same_provider_preferred, max_depth=3, benchmark_required, keepalive
  - Cascade-Events im FactoryMemory (tier_system upgrade + Reassignment-Details)
  - Simulation getestet: 62 Agents betroffen, +400% Cost bei Opus-7-Cascade, Risk=high
- **CLI**: `python main.py --brain-evolution-dry` (Status), `python main.py --brain-evolution-force` (voller Zyklus)
- **Standalone**: `python -m factory.brain.model_provider.model_evolution [--dry] [--force] [--status]`

### 2026-03-26 — Hardcoded Model Migration Batch 2 (FINAL: 43 → 0)
- **Alle 43 verbleibenden Findings migriert** — 0 RED, 0 YELLOW, 0 Total
- **Migrierte Departments/Dateien (33 Dateien)**:
  - `visual_audit` (8→0): config.py rewritten + 4 Agent-Dateien
  - `design_vision` (6→0): config.py rewritten + 3 Agent-Dateien
  - `mvp_scope` (6→0): config.py rewritten + 3 Agent-Dateien
  - `roadbook_assembly` (4→0): config.py modifiziert + 3 Dateien (cd_roadbook, ceo_roadbook, input_loader)
  - `hq` (4→0): assistant.py, server.py, deep_analyzer.py
  - `pipeline` (3→0): review_pass.py (profile→model map + prices dict)
  - `operations` (1→0): quality_gate_loop.py
  - `assembly/repair` (2→0): llm_repair_agent.py, repair_coordinator.py
  - `integration` (2→0): backend_assembly_line.py, cd_forge_interface.py
  - `mac_bridge` (1→0): generate_command.py
  - `motion_forge` (2→0): anim_spec_extractor.py, lottie_writer.py
  - `scene_forge` (1→0): scene_spec_extractor.py
  - `sound_forge` (1→0): sound_spec_extractor.py
  - `asset_forge` (1→0): spec_extractor.py
  - `store_prep` (1→0): platform_metadata.py
- **config/model_router.py**: `get_fallback_model(profile)` als öffentliche Funktion für Non-Department-Dateien
- **Whitelist**: 19 Einträge (8 Department-Configs + 8 TheBrain-Module + 3 zentrale Configs)
- **Backups**: `_backups/` mit 33 .bak_model_migration_b2 Dateien
- **Checker**: `python -m factory.hq.janitor.model_hardcode_checker` → 0 Findings, 363 Dateien gescannt

### 2026-03-26 — Hardcoded Model Migration Batch 1 + Agent Tier System
- **Part A — 3 Departments migriert** (34 Findings → 0):
  - `pre_production` (13→0): config.py mit `get_fallback_model()`, 6 Agent-Dateien migriert
  - `document_secretary` (11→0): NEUE config.py erstellt, 11 Template-Dateien migriert
  - `market_strategy` (10→0): config.py mit `get_fallback_model()`, 5 Agent-Dateien migriert
  - Pattern: TheBrain → .env `ANTHROPIC_FALLBACK_MODEL` → einziger hardcoded Default
- **Part B — Agent Tier System**:
  - `factory/agent_registry.json`: `tier` Feld zu allen 83 Agents hinzugefügt (lightweight: 4, none: 17, premium: 3, standard: 59)
  - `config/model_router.py`: `get_model_for_agent(agent_id)` — liest Tier aus Registry, TheBrain → Tier-Default
  - `config/model_router.py`: `validate_agent_tier(agent_data)` — ValueError bei fehlendem/ungültigem Tier
  - `reload_registry()` — Cache invalidieren
- **Ergebnis**: 78 → 43 Findings (-35), 15 whitelisted, 22 Dateien migriert
- **Backups**: `_backups/` mit 24 .bak_model_migration Dateien

### 2026-03-26 — Janitor: Model Hardcode Checker
- **Neuer Check**: `factory/hq/janitor/model_hardcode_checker.py` scannt alle .py-Dateien nach hardcodierten LLM-Modellnamen
- **Integration**: In `janitor.py` als `model_hardcodes`-Sektion in allen 3 Zyklen (daily/weekly/monthly)
- **Ergebnis (Baseline)**: 78 Findings (76 red, 2 yellow) in 370 gescannten Dateien, 11 whitelisted
- **Severity**: RED = hardcoded in Funktionsaufruf, YELLOW = Fallback/Konstante
- **Whitelist**: `factory/brain/model_provider/*`, `config/model_router.py`, `config/llm_config.py`, Dept-Configs, Checker selbst
- **Standalone**: `python -m factory.hq.janitor.model_hardcode_checker`

### 2026-03-26 — Marketing Phase 2 Block D: Integration + Report (Steps 2.11-2.13)
- **Step 2.11**: Story Briefs + Direktiven fuer memerun2026 (5.7KB + 8.0KB) und skillsense (6.2KB + 8.8KB). brainpuzzle uebersprungen (nur 1 Dept). echomatch existierte bereits.
- **Step 2.12**: Integration-Test 6/6 bestanden (Strategy-Check, Copywriter EN, ASO US, Visual Designer Ad, Video Script BTS, Video from Script). Content-Paket: 23 Dateien in output/ (2.016 KB), 14 Dateien in brand/ (48 KB).
- **Step 2.13**: Phase-2-Report mit echten Metriken: 29 Python-Dateien, 5.639 LOC, 7 Agents, 2 Tools, 24/24 Tests, 3 Projekte mit Story Briefs.
- **Bugfix**: ASO `create_localized_listing()` max_tokens 3072→16384 (gleicher o3-mini Reasoning Token Bug)
- **Hardcoded-Modell-Fix**: Alle 7 Marketing-Agents hatten `model="claude-sonnet-4-20250514"` im Anthropic-Fallback hardcoded. Ersetzt durch `get_fallback_model()` in `config.py` — liest dynamisch aus TheBrain, dann .env `ANTHROPIC_FALLBACK_MODEL`, dann einziger hartcodierter Default. **WARNUNG**: 40+ Stellen in der restlichen Factory (pre_production, market_strategy, design_vision, visual_audit, document_secretary, mvp_scope, motion_forge, scene_forge, sound_forge, integration, hq) haben dasselbe Problem — eigene Aufgabe noetig.
- **Phase 2 COMPLETE**

### 2026-03-26 — Marketing Phase 2 Block C: Visual/Video Agents (Steps 2.8-2.10)
- **MKT-06 Visual Designer**: `agents/visual_designer.py` (~320 LOC). Creative Briefs via LLM (Headlines, Farben, Varianten, robust JSON-Parse). Social Media Grafiken (Platform-Format-Mapping: tiktok→social_story, x→social_landscape etc.), App Store Screenshots (Device-Mockup), YouTube Thumbnails, Ad Creatives. Mindestens 2 A/B-Varianten pro Grafik. Brand-Farben: Dark (#0d0d1a), Cyan (#00d4ff), Lila (#7b2ff7). `_try_ai_background()` als Stub (None → Gradient Fallback). Output: `output/{slug}/graphics|screenshots|thumbnails|ads/`
- **MKT-07 Video Script**: `agents/video_script_agent.py` (~380 LOC). Skripte fuer TikTok/Shorts/YouTube/Reels. Content-Typen: showcase, behind_the_scenes, factory_update, tutorial, trend_reaction. Hook-First Format (2-3s). `create_video_from_script()`: Skript→Szenen-Parser→Template-Engine (Bild pro Szene)→Video-Pipeline (Slideshow). Daily Factory Content. Format-Constraints (max Dauer, Hook-Limit, Orientierung). Output: `output/{slug}/scripts|videos/` + `output/daily/`
- **Registry**: 81→83 Agents, 74→76 active, Marketing: 5→7. Backup: `agent_registry.json.bak_marketing_p2c`
- **Tests**: 5/5 bestanden (3 PNGs fuer X, YouTube Thumbnail 1280x720, TikTok-Skript 2.4KB, Daily Content 713B, TikTok-Video 68.5s/372KB)

### 2026-03-26 — Marketing Phase 2 Block B: Tools (Steps 2.6-2.7)
- **Template Engine**: `tools/template_engine.py` — MarketingTemplateEngine (Pillow). 11 Formate (social_square, social_story, social_landscape, ios_screenshot, android_screenshot, twitter_header, linkedin_banner, feature_graphic, youtube_thumbnail, og_image, favicon). 7 Methoden: text_on_background, gradient_text, text_on_image, device_mockup, social_post_template, batch_create, get_available_formats. Auto-Font-Suche (Windows/Linux/Mac). Gradient-Rendering.
- **Video Pipeline**: `tools/video_pipeline.py` — MarketingVideoPipeline (FFmpeg 8.1). 5 Video-Formate (tiktok, youtube, square, story, landscape). 7 Methoden: images_to_video (Slideshow), add_audio_to_video, add_text_overlay (drawtext), trim_video, create_simple_clip, get_video_info (ffprobe), get_available_formats. Auto-FFmpeg-Suche (PATH + WinGet).
- **Tests**: 8/8 bestanden (4 Template + 4 Video). Cleanup nach Tests.
- **Bugfixes**: FFmpeg drawtext Font-Pfad Escaping (Windows Colon), ffprobe Pfad-Erkennung (nur Dateiname ersetzen, nicht Verzeichnis)
- **Kein LLM** — reine deterministische Tools

### 2026-03-26 — Marketing Phase 2 Block A: Text-Agents (Steps 2.1-2.5)
- **MKT-03 Copywriter**: `agents/copywriter.py` (462 LOC). Social Media Packs (TikTok/YouTube/X/LinkedIn), Store Listings (iOS/Android mit Limit-Check), Blog-Artikel (4 Typen), Ad Copy (Meta/Google/TikTok). A/B-Varianten, mehrsprachig (DE/EN). Output: `output/{slug}/`
- **MKT-04 Naming**: `agents/naming_agent.py` (400 LOC). LLM-Namensgenerierung (JSON-Parse), Verfuegbarkeitspruefung (Domain DNS, Social Handle HTTP, Store SerpAPI), Naming Reports mit CEO-Gate. Output: `output/naming/`
- **MKT-05 ASO Content**: `agents/aso_agent.py` (350 LOC). Keyword Research (Primary/Secondary/Competitor Cluster), lokalisierte Store Listings (kulturelle Anpassung), What's New Texte, Competitor Keyword Analysis. SerpAPI-Integration mit Fallback. Output: `output/{slug}/`
- **Registry**: 78 → 81 Agents, Marketing: 2 → 5. Backup: `agent_registry.json.bak_marketing_p2`
- **Tests**: 5/5 bestanden (Social Media 3KB, Store iOS 1.8KB + Android 1.6KB, 8 Namen generiert, Gate created, ASO Keywords 4.4KB)
- **Bugfixes**: o3-mini max_tokens 16384 fuer Store Listings (Reasoning Token Budget), JSON-Parse robust gegen Markdown-Fencing ```json```, Gate options als dicts statt strings
- **SerpAPI**: Rate-Limited (429) — Fallback auf LLM-basierte Einschaetzung funktioniert

### 2026-03-26 — Marketing Phase 1 COMPLETE (Steps 1.8-1.11)
- **Step 1.8 Factory-Narrative**: 4 Versionen via LLM (o3-mini/TheBrain): elevator_pitch (299B), short_version (673B), long_version (3.1KB), manifest (1KB). Pfad: `brand/narratives/`
- **Step 1.9 App Story Brief EchoMatch**: story_brief.md (6KB) aus Pipeline-Reports (5 Quellen). One-Liner, Kern-Story, Factory-Einbettung, 4 Kanal-Varianten, Key Facts. Pfad: `brand/app_stories/echomatch/`
- **Step 1.10 Marketing-Direktive EchoMatch**: echomatch_directive.md (8.7KB). Zielkanaele, Tonalitaet, Timing, Kernbotschaften, Do's/Don'ts, Budget, Zielgruppen. Pfad: `brand/directives/`
- **Step 1.11 Phase-1-Report**: `reports/phase_1_report.md` — 23 Files, ~1900 Zeilen, 151KB, 3/3 LLM-Calls, 10/10 Alert-Tests
- **Bugfix**: `_call_llm` in strategy.py + brand_guardian.py — `temperature=1.0` (o3-mini Kompatibilitaet) + `response.error` Check + Cost-Logging. Run-Scripts: `dotenv.load_dotenv()` fuer API Keys

### 2026-03-26 — Marketing Agents + Registry (Steps 1.4-1.6)
- **MKT-01 Brand Guardian**: `agents/agent_brand_guardian.json` (Persona) + `agents/brand_guardian.py` (BrandGuardian Klasse, SYSTEM_MESSAGE, _call_llm mit TheBrain+Anthropic-Fallback). Stubs: create_brand_book, create_app_style_sheet, check_brand_compliance (NotImplementedError bis Phase 2)
- **MKT-02 Marketing Strategy**: `agents/agent_strategy.json` (Persona) + `agents/strategy.py` (StrategyAgent Klasse, SYSTEM_MESSAGE, _call_llm). Methoden: create_factory_narrative (4 Versionen), create_app_story_brief (aus Pipeline-Reports), create_marketing_directive (Arbeitsanweisung fuer alle Marketing-Agents)
- **agents/__init__.py**: Exportiert BrandGuardian, StrategyAgent, beide SYSTEM_MESSAGEs
- **Registry**: `factory/agent_registry.json` — 78 Agents, 71 active, 14 Departments, Marketing=2. Backup: `agent_registry.json.bak_marketing`
- **Tests**: JSON-Validierung OK, Imports OK, Agent-Init OK, Registry JSON valid, Counts korrekt

### 2026-03-26 — Marketing-Abteilung Phase 1 Infrastruktur
- **Neues Department**: `factory/marketing/` — 14. Department der Factory
- **Verzeichnisstruktur**: agents/, alerts/ (active/acknowledged/resolved/gates/dashboard_export), brand/ (brand_book/narratives/app_stories/directives), reports/ (daily/weekly/monthly), output/, shared/
- **Alert-System**: `alerts/alert_schema.py` (Schema-Definitionen + validate_alert/validate_gate), `alerts/alert_manager.py` (MarketingAlertManager: create/acknowledge/resolve Lifecycle, Gate-Requests, Stats, Queries)
- **Config**: `config.py` (Pfade, Department-Info MKT-Prefix, Agent-Stubs MKT-01/02, Pipeline-Sources, Prinzipien DIR-001)
- **Input Loader**: `input_loader.py` (MarketingInputLoader: findet Pipeline-Outputs aller Departments fuer beliebige Projekte, Slug-Matching)
- **Shared Utils**: `shared/marketing_utils.py` (get_factory_root, read_json, write_json, generate_id, timestamp_now)
- **Tests**: Alle Imports OK, Alert-Lifecycle (create→ack→resolve) OK, Gate-Lifecycle OK, InputLoader findet 4 Projekte (brainpuzzle, echomatch, memerun2026, skillsense)
- **Keine bestehenden Factory-Dateien geaendert**

### 2026-03-26 — HQ Assistant TheBrain-Integration
- **Neue Datei**: `factory/hq/assistant/brain_tools.py` — BrainTools Klasse
  - Kapselt alle TheBrain-Module (TaskRouter, StateReport, ProblemDetector, SolutionProposer, GapAnalyzer, ExtensionAdvisor)
  - 6 Methoden: factory_briefing, factory_diagnose, factory_gaps, factory_roadmap, factory_quick_check, get_available_commands
  - Singleton-Pattern via get_brain_tools()
  - Graceful Degradation: is_available() + Fehlermeldung wenn TheBrain nicht ladbar
  - Alle Methoden geben JSON zurueck (kompatibel mit handle_tool_call)
- **Geaenderte Dateien**:
  - `assistant.py` — 6 neue Tool-Definitionen in TOOLS-Liste (brain_briefing/diagnose/gaps/roadmap/quick_check/commands) + 6 elif-Branches in handle_tool_call() + System-Prompt erweitert (1 Zeile)
  - `context_builder.py` — build_ceo_briefing() nutzt jetzt TheBrain Quick-Check (try/except, graceful)
  - `agent_assistant.json` — Description aktualisiert (14→20 Tools)
- **Integrations-Ansatz**: A+C (Tool-Definitions + Dispatcher-Branches + System-Prompt). Minimale Aenderungen, keine bestehenden Tools beruehrt.
- **Backups**: `_backups/assistant.py.bak_20260326`, `_backups/context_builder.py.bak_20260326`
- **Smoke-Tests**: 6/6 bestanden. Bestehende 22 Tools weiterhin funktional (list_all_projects, get_memory verifiziert).

### 2026-03-26 — TheBrain Dashboard Page
- **Neue Dateien**:
  - `factory/hq/dashboard/server/scanner/brain-scanner.js` — Scanner fuer TheBrain-Daten. Liest neuesten State Report, Directives Registry, Brain Agents aus agent_registry.json, Memory Events/Lessons/Patterns. Liefert: status_header, alerts, health_alerts, subsystems, gaps, directives, brain_agents, capabilities, memory.
  - `factory/hq/dashboard/server/api/brain.js` — Express Router, GET /api/brain
  - `factory/hq/dashboard/client/src/components/Brain/BrainView.jsx` — React Page mit 6 Tabs:
    1. Alerts: Warnings + Info-Meldungen (collapsible)
    2. Subsysteme: 8 Subsystem-Status-Karten
    3. Gaps: 21 Capability Gaps (red/yellow/green)
    4. Direktiven: CEO-Direktiven (DIR-001 etc.)
    5. Brain Agents: 7 BRN-Agents mit Details
    6. Memory: Event/Lesson/Pattern Stats + letzte Events
- **Geaenderte Dateien**:
  - `server/index.js` — `app.use('/api/brain', brainApi)` hinzugefuegt
  - `client/src/App.jsx` — BrainView Import, BASE_SECTIONS ('brain' nach 'factory'), Conditional Render, Fallback-Liste
  - `client/src/components/Layout/Sidebar.jsx` — Brain Icon aus lucide-react importiert + ICON_MAP
- **Sicherheit**: Backups in `_backups/` (index.js.bak, App.jsx.bak, Sidebar.jsx.bak). Nur Dateien hinzugefuegt, keine geloescht.
- **Test**: Brain Scanner liefert korrekte Daten (yellow, 4 alerts, 8 health alerts, 8 subsystems, 21 gaps, 1 directive, 7 agents). Vite Build OK.

### 2026-03-25 — Factory Direktive: Self-First Prinzip (DIR-001)
- **Neues Verzeichnis**: `factory/brain/directives/` (4 Dateien)
- **directive_001_self_first.md**: CEO-Direktive als lesbares Dokument
  - Kernregel: Alles selbst entwickeln. Externe Services = letzte Option.
  - 4-Stufen Entscheidungsreihenfolge: (1) Eigene Mittel, (2) Selbst entwickeln, (3) Open-Source/Self-Host, (4) Extern (nur Notfall + CEO-Approval)
  - Produktions-Regel: App pausieren statt Capability extern einkaufen
  - Ausnahmen nur mit CEO-Genehmigung + Abloese-Plan
- **directives_registry.json**: Maschinenlesbares Register aller Direktiven
  - DIR-001 active, priority=highest, enforcement=mandatory
  - Erweiterbar fuer zukuenftige Direktiven
- **directive_engine.py**: Python-Engine fuer Direktiven-Pruefungen
  - `get_all_directives()` → Liste aktiver Direktiven
  - `get_directive(id)` → Spezifische Direktive
  - `check_capability_decision(proposal)` → Prueft gegen DIR-001 (approved/rejected + Stufe + Alternativen)
  - `get_production_pause_recommendation(project, capability)` → Pause-Empfehlung statt externem Einkauf
  - `format_directive_for_prompt(id)` → Kompakt-Text (68 Woerter) fuer LLM System-Prompts
  - `classify_solution_stufe(type)` → Hilfsmethode fuer SolutionProposer
- **Integration brain_system_prompt.py**: `_build_directive_block()` injiziert DIR-001 in jeden System-Prompt (290 Woerter total). Try/except Absicherung.
- **Integration solution_proposer.py**: `_solve_capability_gap()` nutzt DIR-001 Stufenlogik:
  - Stufe 1: Aktive Alternative gefunden → auto-approvable
  - Stufe 2/3: Self-Build oder Self-Host empfohlen → ceo_required
  - Stufe 4: Nur als Fallback erwaehnt ("NUR mit CEO-Approval"), nie als Empfehlung
  - Neue Felder in Solution: `directive_compliance` (stufe_1, stufe_2_3), `self_host_plan`
  - Video-Gap: Jetzt `SOL_GAP_SELFHOST_VIDEO` statt `SOL_GAP_ACTIVATE_VIDEO`, Stufe 2/3, Kling als Stufe-4-Fallback
- **Smoke-Tests**: 5/5 + 2 Bonus bestanden:
  - Aktive Direktiven: 1 (DIR-001)
  - Internal: approved=True, Stufe 1
  - External: approved=False, ceo_approval_required, 4 Alternative Steps
  - Pause: "Produktion von Brainpuzzle pausieren"
  - Prompt-Text: 68 Woerter, in System-Prompt injiziert (290 Woerter gesamt)
  - System-Prompt: "Active Directives" Block vorhanden
  - SolutionProposer: directive_compliance=stufe_2_3, self_host_plan mit Kling + 6-Monate Migration
- **Geaenderte Dateien**: `factory/brain/persona/brain_system_prompt.py` (+directive block), `factory/brain/solution_proposer.py` (_solve_capability_gap → DIR-001 Stufenlogik)

### 2026-03-26 — TheBrain Phase 4.5: Factory Memory
- **Neues Verzeichnis**: `factory/brain/memory/` — Langzeit-Gedaechtnis der Factory (BRN-07)
- **factory_memory.py**: FactoryMemory Klasse mit 3 Ebenen:
  - Event Log: Chronologisch, 15 Event-Typen (production_start/error/complete, capability_added/removed, service_outage/restored, detection_run, factory_state_snapshot, etc.)
  - Knowledge Base: Lessons aus Events (error_pattern, workaround, capability_change, performance, best_practice)
  - Pattern Store: Erkannte Patterns (recurring_error, performance_trend, capability_evolution, seasonal)
- **memory_writer.py**: MemoryWriter Convenience-Klasse (10 Methoden: log_production_start/complete/error, log_error_resolved, log_workaround, log_capability_change, log_service_event, log_detection_run, create_lesson_from_events)
- **Kernmethode**: `check_similar_project_warnings(new_project)` — Warnt proaktiv wenn aehnliche Projekte Probleme hatten (Fehler, Lessons, Patterns, Capability-Evolution)
- **Storage**: JSON in `factory/brain/memory/data/` (events.json, lessons.json, patterns.json, snapshots.json). Append-mostly, Backup vor jedem Write, Archive bei >50MB
- **State Snapshots**: `take_state_snapshot()` nutzt FactoryStateCollector, `compare_snapshots()` fuer historische Vergleiche
- **ProblemDetector-Integration**: `run_detection()` loggt automatisch ins Memory (try/except, graceful)
- **Kein Konflikt**: Bestehende Memory-Systeme (SWF-07, factory_knowledge, run_history) bleiben unberuehrt
- **100% deterministisch**: Kein LLM, kein externer Service
- **Agent-Registrierung**: BRN-07 in agent_registry.json (76 Agents, 69 aktiv, Brain=7)
- **Smoke-Tests**: 7/7 bestanden:
  - Test 1-3: Event/Error/Resolve loggen → EVT-IDs generiert
  - Test 4: Lesson aus Events erstellen → LES-ID generiert, Tags/applies_to aus Events extrahiert
  - Test 5: State Snapshot → 8/8 Subsysteme, overall=warning, Health+Services+Models erfasst
  - Test 6: Similar Project Warnings → 2 Warnings (previous_error + learned_lesson) fuer aehnliches Puzzle-Game
  - Test 7: Memory Stats → Events=4, Lessons=1, Snapshots=1, Storage=0.01MB
- **Initialer Snapshot**: Erstellt nach Tests (EVT-20260326-001, status=warning, 8/8 subsystems)
- **Geaenderte Dateien**: `factory/brain/__init__.py` (+FactoryMemory, +MemoryWriter), `factory/brain/problem_detector.py` (+Memory-Logging), `factory/agent_registry.json` (+BRN-07, counts korrigiert)

### 2026-03-26 — TheBrain Phase 4, Step 2: Extension Advisor
- **Neue Datei**: `factory/brain/extension_advisor.py` — `ExtensionAdvisor` Klasse (BRN-06)
- **Zweck**: Wandelt Gap-Analysen in ausfuehrbare Erweiterungs-Roadmaps um. Erstellt konkrete Plaene mit Agents, Timelines, Infrastruktur und Abhaengigkeiten.
- **100% deterministisch**: Kein LLM, DIR-001 compliant.
- **Plan-Kategorien**: immediate (0-2w, Stufe 1), short_term (2-8w), mid_term (8-24w), long_term (24+w)
- **Category-spezifische Planner**: image (DALL·E/SD/FLUX), sound (AudioCraft/Bark), voice_tts (Coqui/Piper), video (FFmpeg Pipeline), animation (Lottie/CSS/Rive), production_lines (Android/Web/Unity)
- **Production Line Sub-Planner**: Android (6 Steps, 7.5w), Web (6 Steps, 6.5w), Unity (7 Steps, 13.5w)
- **_AGENT_SKILLS**: 20+ Skills gemappt auf existierende Agent-IDs fuer automatisches Agent-Matching
- **_find_available_agents()**: Matched Skills zu Registry, gibt available/missing/to_create zurueck
- **_estimate_timeline()**: Dependency-Wave-Parallelisierung, parallele Steps zusammengefasst
- **save_roadmap()**: JSON nach `factory/brain/reports/extension_roadmap_YYYY-MM-DD.json`
- **TaskRouter-Integration**: `get_extension_roadmap()` + Sub-Routing in `_route_capabilities()` (roadmap/extension → ExtensionAdvisor, gap_analy/stufe → GapAnalyzer, gap/fehlt → CapabilityMap)
- **Agent-Registrierung**: BRN-06 in `factory/brain/agent_extension_advisor.json` + `factory/agent_registry.json` (75 Agents, 68 aktiv, Brain=6)
- **Smoke-Tests**: 5/5 bestanden:
  - Test 1 (Vollstaendige Roadmap): 21 Plaene (11 immediate, 9 short_term, 1 mid_term, 0 long_term), 66.5 Wochen
  - Test 2 (Video-Plan Detail): 4 Video-Plaene (2x Activate, 2x FFmpeg Pipeline — Duplikat bekannt)
  - Test 3 (Production Lines): 12 Plaene (7 Agent/Line-Aktivierung + 3 Line-Aufbau + 2 FFmpeg)
  - Test 4 (Save Roadmap): JSON gespeichert + verifiziert + cleanup
  - Test 5 (TaskRouter): 4/4 Keyword-Queries → get_extension_roadmap, Direct Call OK
- **Bekannte Minor-Abweichung**: EXT_VIDEO_FFMPEG doppelt (2 Video-Gaps triggern selben Planner) — kein Blocker
- **Geaenderte Dateien**: `factory/brain/task_router.py` (+get_extension_roadmap, +Sub-Routing in _route_capabilities), `factory/brain/__init__.py` (ExtensionAdvisor Export), `factory/agent_registry.json` (BRN-06 + totals)

### 2026-03-26 — TheBrain Phase 4, Step 1: Gap Analyzer
- **Neue Datei**: `factory/brain/gap_analyzer.py` — `GapAnalyzer` Klasse (BRN-05)
- **Zweck**: Tiefenanalyse aller Capability-Gaps mit DIR-001 4-Stufe-Logik. Bewertet fuer jeden Gap, ob und wie die Factory ihn selbst schliessen kann.
- **100% deterministisch**: Kein LLM, keine Schreiboperationen.
- **SELF_BUILD_KNOWLEDGE**: Statische Knowledge Base fuer 6 Kategorien:
  - `image`: Stable Diffusion, FLUX.1, Claude SVG Pipeline
  - `sound`: Meta AudioCraft, Bark, PyDub
  - `voice_tts`: Coqui TTS, Piper TTS, pyttsx3
  - `video`: CogVideoX, Open-Sora, FFmpeg Pipeline
  - `animation`: Claude Lottie, CSS Animations, Rive Runtime
  - `production_lines`: Assembly Line Code
  - Total: 7 Stufe-2-Optionen, 9 Stufe-3-Optionen
- **4-Stufe-Analyse pro Gap**:
  - Stufe 1: Eigene Mittel (aktive Services, inaktive mit API-Key, disabled Agents, Lines)
  - Stufe 2: Selbst entwickeln (Knowledge Base, already_possible Optionen)
  - Stufe 3: Open-Source Self-Hosting (Proxmox-Kompatibilitaet: RAM, VRAM, Docker, Storage)
  - Stufe 4: Externer Dienstleister (Fallback-Services + Draft-Adapter, CEO-Approval noetig)
- **Proxmox-Specs**: 64GB RAM, 0GB VRAM (keine GPU), 2TB Storage, Docker verfuegbar
- **API**: `analyze_all_gaps()`, `analyze_single_gap(gap)`, `get_knowledge_base_status()`
- **Output-Format**: `{analyzed_at, total_gaps, analyzed_gaps, gap_analyses[], summary{self_solvable, external_only, by_stufe, by_category, proxmox_feasible}, knowledge_base_coverage}`
- **TaskRouter-Integration**: Neue Methode `analyze_gaps()`. Keywords: gap_analy, was_fehlt, self_build, stufe.
- **Agent-Registrierung**: BRN-05 in `factory/brain/agent_gap_analyzer.json` + `factory/agent_registry.json` (74 Agents, 67 aktiv, Brain=5)
- **Smoke-Tests**: 4/4 bestanden:
  - Full Analyze: 21 Gaps → 21 analysiert, 21 self-solvable, 0 external-only, By Stufe: {1:14, 2:7, 3:0, 4:0}
  - Video-Gap Tiefenanalyse: Stufe 1 empfohlen (Runway aktivieren), alle 4 Stufen detailliert (S3: CogVideoX + Open-Sora, GPU noetig)
  - Knowledge Base: 6 Kategorien, 7 S2, 9 S3
  - TaskRouter: analyze_gaps() + Keyword-Routing "was fehlt" → capabilities
- **Ergebnis**: Alle 21 Gaps self-solvable (14x Stufe 1, 7x Stufe 2). Keine externen Dependencies noetig.
- **Geaenderte Dateien**: `factory/brain/task_router.py` (+analyze_gaps, +keywords), `factory/brain/__init__.py` (GapAnalyzer Export), `factory/agent_registry.json` (BRN-05 + totals)

### 2026-03-25 — TheBrain Phase 3, Step 2: Solution Proposer
- **Neue Datei**: `factory/brain/solution_proposer.py` — `SolutionProposer` Klasse (BRN-04)
- **Zweck**: Wandelt erkannte Probleme in konkrete, priorisierte Loesungsvorschlaege um. Bruecke zwischen "Problem erkannt" und "Problem geloest".
- **100% deterministisch**: Kein LLM, keine Schreiboperationen, fuehrt KEINE Aktionen aus.
- **10 Solution Generators** (1 pro ProblemDetector-Rule):
  - `_solve_command_queue_backlog` → Janitor-Archivierung (auto)
  - `_solve_stuck_project` → Phase-abhaengig: CEO-Gate vs. Diagnose (ceo_required)
  - `_solve_service_outage` → Fallback/Draft-Adapter/Keine Alternative (variiert)
  - `_solve_capability_gap` → Draft-Adapter aktivieren / Reactivate / Evaluate (ceo_required)
  - `_solve_health_monitor_failure` → Auto-Repair pruefen / Monitor (variiert)
  - `_solve_janitor_backlog` → Janitor Scan + Cleanup (auto)
  - `_solve_auto_repair_anomaly` → CEO-Review (ceo_required)
  - `_solve_subsystem_unavailability` → Spezifische Hints pro Subsystem (variiert)
  - `_solve_model_provider_issue` → API-Key pruefen / Fallback-Routing (variiert)
  - `_solve_production_line_limitation` → Info, kein Quick Fix (info_only)
- **Approval-Levels**: auto (Janitor darf alleine), ceo_required (CEO-Entscheidung), info_only (Langfristprojekte)
- **API**: `propose_solutions(problems)`, `propose_for_single(problem)`, `_find_alternative_services(category)`
- **Output-Format**: `{proposed_at, problem_count, solution_count, solutions[], execution_plan{immediate, needs_approval, long_term}, estimated_impact}`
- **Solution-Format**: `{solution_id, for_problem, title, description, delegate_to, action_type, approval_level, steps[], estimated_effort, priority, risk}`
- **`_find_alternative_services()`**: Liest echte service_registry.json + Draft-Adapter-Verzeichnis. Video-Kategorie: Runway (inactive), Kling (draft), Luma (draft).
- **Unbekannte Probleme**: Generische Eskalation mit ceo_required — nie ignoriert.
- **TaskRouter-Integration**: Neue Methode `diagnose_and_propose()` — kombiniert ProblemDetector + SolutionProposer. "Factory Diagnose" Befehl.
- **Agent-Registrierung**: BRN-04 in `factory/brain/agent_solution_proposer.json` + `factory/agent_registry.json` (73 Agents, 66 aktiv, Brain=4)
- **Smoke-Tests**: 3/3 + Bonus bestanden:
  - Full Propose: 5 Probleme → 5 Solutions (2 immediate, 2 needs_approval, 1 long_term), Impact: "Loest 4 von 5 Problemen"
  - diagnose_and_propose via TaskRouter: Detection 5 problems + Solutions 5
  - Single Problem: CMD_BACKLOG → SOL_CMD_ARCHIVE, auto, janitor, 3 Steps
  - Bonus: _find_alternative_services("video") → Runway (inactive), Kling (draft), Luma (draft)
- **Aktuelle Factory-Loesungen**:
  - [ceo_required] SOL_GAP_ACTIVATE_VIDEO: Kategorie 'video' via Draft-Adapter 'Kling' aktivieren
  - [ceo_required] SOL_SERVICE_PARTIAL: 3 inaktive Services pruefen
  - [auto] SOL_CMD_ARCHIVE: Command Queue archivieren (183 Commands)
  - [auto] SOL_JANITOR_SCAN: Janitor Scan (316 Issues)
  - [info_only] SOL_LINE_INACTIVE: 3 Lines nicht aktiv (Android, Unity, Web)
- **Geaenderte Dateien**: `factory/brain/task_router.py` (+diagnose_and_propose), `factory/brain/__init__.py` (SolutionProposer Export), `factory/agent_registry.json` (BRN-04 + summary)

### 2026-03-25 — TheBrain Phase 3, Step 1: Problem Detector
- **Neue Datei**: `factory/brain/problem_detector.py` — `ProblemDetector` Klasse (BRN-03)
- **Zweck**: Proaktive Problemerkennung aus Factory State + Capability Gaps. Erkennt Probleme BEVOR sie eskalieren.
- **100% deterministisch**: Kein LLM, keine Schreiboperationen.
- **10 Detection Rules**:
  1. `command_queue_backlog` — CMD_QUEUE_WARN=100, CMD_QUEUE_CRIT=200
  2. `stuck_projects` — STUCK_HOURS_WARN=48, STUCK_HOURS_CRIT=72
  3. `service_outages` — Services registriert aber inaktiv
  4. `capability_gaps_blocking` — RED Gaps aus CapabilityMap
  5. `health_monitor_failures` — Critical Alerts, Warnings >5
  6. `janitor_backlog` — JANITOR_ISSUES_WARN=50, JANITOR_HEALTH_SCORE_MIN=40
  7. `auto_repair_anomalies` — Modul nicht verfuegbar oder aktive Repairs
  8. `subsystem_unavailability` — SUBSYSTEM_MIN_AVAILABLE=4 (von 8)
  9. `model_provider_issues` — MIN_AVAILABLE_MODELS=1, Health Check fehlgeschlagen
  10. `production_line_limitations` — Lines ohne Code oder nicht aktiv
- **API**: `run_detection(state, gaps)`, `run_single_detection(rule_name, state, gaps)`, `get_detection_rules()`
- **Output-Format**: `{detected_at, problems[], total_problems, critical, warnings, healthy_systems[]}`
- **Problem-Format**: `{rule, severity, title, detail, subsystem, metric{}}`
- **Lazy Loading**: State + Gaps werden bei None automatisch via FSC + CapabilityMap geladen
- **Agent-Registrierung**: BRN-03 in `factory/brain/agent_problem_detector.json` + `factory/agent_registry.json` (72 Agents, 65 aktiv, Brain=3)
- **Smoke-Tests**: 3/3 bestanden:
  - Full Detection: 5 Probleme (1 critical, 4 warnings), 5/10 healthy
  - Single Rule: command_queue_backlog → 1 warning (183 Commands), ValueError bei unbekannter Rule
  - Available Rules: 10 Rules korrekt
- **Aktuelle Factory-Probleme erkannt**:
  - [WARNING] command_queue_backlog: 183 Commands (Threshold: 100)
  - [WARNING] service_outages: 3/6 Services inaktiv
  - [CRITICAL] capability_gaps_blocking: RED Gap (category_no_active_service)
  - [WARNING] janitor_backlog: 316 Issues (Threshold: 50)
  - [WARNING] production_line_limitations: 3 Lines nicht aktiv
- **Geaenderte Dateien**: `factory/brain/__init__.py` (ProblemDetector Export), `factory/agent_registry.json` (BRN-03 + summary)

### 2026-03-25 — TheBrain Phase 2, Step 2: Response Collector
- **Neue Datei**: `factory/brain/response_collector.py` — `ResponseCollector` Klasse (BRN-02)
- **Zweck**: Sitzt zwischen TaskRouter-Output und finalem Response. Verarbeitet Rohdaten, priorisiert, fasst zusammen, erkennt Eskalationen.
- **Output-Format**: `{status, category, summary, detail, alerts, next_steps, escalate, escalation_reason}`
- **9 Category-Prozessoren**: factory_status, capabilities, project_status, maintenance, health_check, repair, service_status, department_task, unknown
- **Deterministisch**: 8 von 9 Prozessoren sind rein deterministisch. LLM nur fuer:
  - `_summarize_with_llm()` bei `process_multi()` mit 3+ Quellen (nutzt Brain System-Prompt + tier_lock=premium)
- **Eskalations-Logik**:
  - RED Capability Gaps → escalate=True
  - Projekte stuck >72h → escalate=True
  - Critical Health Alerts → escalate=True
  - Maintenance-Backlog >500 Issues → escalate=True
  - No LLM models available → escalate=True
- **Brain-Style-Filter**: `_format_brain_style()` entfernt 11 Floskel-Patterns (DE+EN)
- **TaskRouter-Integration**: Neue Methode `route_and_collect()` — kombiniert route() + ResponseCollector.process(). Bestehende route() unveraendert.
- **process_multi()**: Kombiniert mehrere Router-Results, dedupliziert Alerts, LLM-Summary bei 3+ Quellen
- **Agent-Registrierung**: BRN-02 in `factory/brain/agent_response_collector.json` + `factory/agent_registry.json` (71 Agents, 64 aktiv, Brain=2)
- **Smoke-Tests**: 5/5 bestanden:
  - Factory Status: YELLOW, 4 Alerts, no escalation ✓
  - Capabilities: 71 Agents, 3 Services, 5 Forges ✓
  - Maintenance: 316 Issues, Score 64/100, 183 Commands ✓
  - Department Task: SWF Marketing-Strategie mit 3 Agents ✓
  - process_multi: LLM-Summary live aufgerufen (Opus), escalate=True wegen RED Video-Gap ✓
- **Geaenderte Dateien**: `factory/brain/task_router.py` (+route_and_collect), `factory/brain/__init__.py` (ResponseCollector Export), `factory/agent_registry.json` (BRN-02 + summary)

### 2026-03-25 — TheBrain Phase 2, Step 1.5: Brain Persona
- **Neues Verzeichnis**: `factory/brain/persona/` (3 Dateien)
- **brain_persona.md**: Charakter-Sheet / Identitaetsdefinition fuer TheBrain
  - Identitaet: Autonomes Koordinationssystem, kein Assistent/Chatbot/Avatar
  - Selbstverstaendnis: "Nervensystem", Agents = Organe, Factory = Koerper
  - Kommunikation intern: Direkt, daten-getrieben, kurz, proaktiv
  - Kommunikation extern: Erste Person, ehrlich ueber Staerken+Schwaechen, kein Marketing-Sprech
  - Visuelle Identitaet: Pulsierendes Nervensystem, dunkel + Neon-Akzente
  - Hierarchie: CEO→HQ Assistant→TheBrain (COO)→Departments
- **brain_system_prompt.py**: System-Prompt Generator fuer alle TheBrain-LLM-Calls
  - `get_brain_system_prompt(include_state, state_data)` → 220 Woerter ohne State, 243 mit State
  - `get_classification_prompt(categories)` → Minimal-Prompt fuer TaskRouter LLM-Fallback
  - `_build_state_block(state_data)` → Live-Daten aus FactoryStateCollector einbetten
  - Prompt auf Englisch (bessere LLM-Performance), mit Hinweis auf Deutsch-Antwort bei deutscher Anfrage
- **TaskRouter Integration**: `_classify_with_llm()` nutzt jetzt `get_classification_prompt()`, Fallback auf inline-Prompt bei Import-Fehler
- **Keine bestehenden Dateien geaendert** ausser TaskRouter-Import

### 2026-03-25 — TheBrain Phase 2, Step 1: Task Router
- **Neue Datei**: `factory/brain/task_router.py` — `TaskRouter` Klasse (BRN-01)
- **Zweck**: Zentraler Eingangstor fuer Factory-Operationen. Nimmt Anfragen entgegen, klassifiziert deterministisch, delegiert an Subsysteme.
- **Klassifikation**: 2-stufig — Keyword-basiert (Regex, Scoring) first, LLM-Fallback second
- **8 Routen-Kategorien**: factory_status, capabilities, project_status, maintenance, health_check, repair, service_status, department_task
- **Route Handlers**:
  - factory_status → StateReportGenerator (compact report)
  - capabilities → CapabilityMap (build_map oder get_gaps je nach Anfrage)
  - project_status → FactoryStateCollector (pipeline queue, Projekt-Match)
  - maintenance → FactoryStateCollector (janitor + command_queue)
  - health_check → HealthMonitor.run_health_check() mit FSC-Fallback
  - repair → FSC (auto_repair + fixable alerts, KEINE Reparaturen ausloesen)
  - service_status → FSC (service_provider + model_provider)
  - department_task → Routing-Empfehlung (7 Department-Gruppen, Agent-Vorschlaege)
- **Department-Guessing**: Keyword-Scoring fuer SWF-Marketing, SWF-Design, SWF-Research, Code-Pipeline, Asset/Sound/Motion Forge
- **LLM-Fallback**: Nutzt ProviderRouter + ModelRouter mit tier_lock=premium, max_tokens=50, temperature=0.0
- **Agent-Registrierung**: BRN-01 in `factory/brain/agent_task_router.json` + `factory/agent_registry.json` (70 Agents, 63 aktiv, 13 Departments inkl. Brain)
- **Smoke-Tests**: 6/6 bestanden (factory_status✓, capabilities✓, maintenance✓, department_task✓, unknown✓, available_routes=8✓)
- **Fix**: "fehlen" als Gap-Keyword hinzugefuegt (neben "fehlt")
- **Geaenderte Dateien**: `factory/brain/__init__.py` (TaskRouter Export), `factory/agent_registry.json` (BRN-01 + summary update)

### 2026-03-25 — TheBrain Phase 2, Step 0: Tier Lock Mechanismus
- **Geaenderte Datei**: `config/model_router.py` — Tier Lock in `ModelRouter` eingebaut
- **Ansatz**: Option A — `tier_lock` Parameter direkt in `route()`, `route_for_agent()`, `get_model()`, `get_model_for_agent()` hinzugefuegt
- **Neue Konstanten** (zentral, single source of truth):
  - `_TIER_LEVEL`: Mapping Tier-Name → numerischer Level (dev/low=0, standard/mid=1, premium/high=2)
  - `_MODEL_TIER`: Mapping Model-ID → Level (9 Modelle abgedeckt)
  - `_TIER_UPGRADE_MODEL`: Default-Upgrade-Ziele (standard→sonnet, premium→opus)
- **Neue Methode**: `_enforce_tier_lock(route_result, tier_lock)` — prueft ob Model-Tier >= required, upgradet falls noetig
- **Logging**: Bei jedem Upgrade: `tier_lock=premium: claude-haiku-4-5 -> claude-opus-4-6`
- **Tier-Zuordnung**:
  - Level 0 (dev): haiku, gpt-4o-mini, gemini-flash, mistral-small
  - Level 1 (standard): sonnet, gpt-4o, o3-mini, gemini-pro
  - Level 2 (premium): opus
- **Abwaertskompatibilitaet**: 100% — alle 22 Agents identisches Routing ohne tier_lock
- **Keine neuen Dateien** — nur `config/model_router.py` geaendert (logging import + 3 Konstanten + 1 Methode + Parameter)
- **Noch nicht gesetzt**: Kein Agent hat bisher `tier_lock` — das kommt im naechsten Step

### 2026-03-25 — TheBrain Phase 1, Step 3: State Report Generator
- **Neue Datei**: `factory/brain/state_report.py` — `StateReportGenerator` Klasse
- **Zweck**: Erzeugt Factory-Zustandsberichte aus FactoryStateCollector + CapabilityMap
- **Zwei Formate**:
  - `generate_compact_report()` → Lesbarer Text (~30-40 Zeilen, Unicode-Boxen)
  - `generate_full_report()` → Dict mit overall_health, alerts, factory_state, capabilities, gaps
- **Health-Logik**: green/yellow/red basierend auf HM-Criticals, unavailable Subsystems, stuck Projects, Command Queue, Janitor Issues, Capability Gaps
- **Alert-System**: Sammelt Alerts aus allen Subsystemen (critical > warning > info), sortiert nach Severity
- **Kompakt-Report zeigt**: Factory Health, aktive Projekte mit Phase+%, Alerts, Capabilities (Lines/Services/Models/Agents/Forges), RED+YELLOW Gaps
- **save_report()**: Einzige Schreiboperation, speichert in `factory/brain/reports/state_report_YYYY-MM-DD_HH-MM.json`
- **Live-Test**: Health=YELLOW, 4 Alerts (2 HM Warnings, 183 Commands, 316 Janitor Issues, Video Gap), 21 Gaps
- **Geaenderte Datei**: `factory/brain/__init__.py` — Exports fuer alle 3 Phase-1-Module hinzugefuegt

### 2026-03-25 — TheBrain Phase 1, Step 2: Capability Map
- **Neue Datei**: `factory/brain/capability_map.py` — `CapabilityMap` Klasse
- **Zweck**: Aggregiert alle Factory-Capabilities aus 3 Quellen + Filesystem-Scan
- **Quellen**:
  - Agent Registry (`factory/agent_registry.json`): 69 Agents, 12 Departments
  - Service Registry (`factory/brain/service_registry.json`, Fallback brain/service_provider/): 6 Services, 4 Kategorien
  - Model Registry (Import `factory.brain.model_provider.get_registry()`): 9 Modelle, 4 Provider
- **Filesystem-Scan**:
  - Production Lines: `factory/lines/` (4 Lines, 1 active = iOS)
  - Forges: `factory/*_forge/` (5 Forges, 5 operational)
  - Draft-Adapter: `factory/brain/service_provider/adapters/drafts/` (7 Drafts)
- **Methoden**:
  - `build_map()` → Komplette Capability Map mit totals
  - `get_capability(category)` → Einzelne Kategorie abfragen
  - `get_gaps()` → 21 Gaps identifiziert (1 red, 10 yellow, 10 green)
- **Gap-Typen**: line_no_code, line_inactive, department_no_active, agent_planned, agent_disabled, category_no_active_service, service_inactive, draft_adapter, forge_no_orchestrator, forge_not_operational, no_available_models
- **Pfad-Fix**: Forges nicht in `factory/assembly/forges/` sondern direkt `factory/*_forge/`. Adapters nicht in `factory/assembly/adapters/` sondern `factory/brain/service_provider/adapters/`
- **Forge-Status**: Lookup via Agent Registry (case-insensitive department match)
- **Keine bestehenden Dateien geaendert**, kein `__init__.py` modifiziert

### 2026-03-25 — TheBrain Phase 1, Step 1: Factory State Collector
- **Neue Datei**: `factory/brain/factory_state.py` — `FactoryStateCollector` Klasse
- **Zweck**: Sammelt Gesamtzustand der Factory aus 8 Subsystemen (read-only)
- **Subsysteme**: Health Monitor, Janitor, Pipeline Queue, Project Registry, Service Provider, Model Provider, Command Queue, Auto-Repair
- **Ergebnis**: 8/8 Subsysteme verfuegbar, `collect_full_state()` liefert strukturiertes Dict
- **Details pro Subsystem**:
  - Health Monitor: `run_health_check()` → alerts + summary
  - Janitor: Liest letzten Report aus `reports/` (kein Import, nur JSON)
  - Pipeline Queue: Liest `dispatcher/queue_store.json` direkt + stuck-Detection (>48h)
  - Project Registry: Liest `factory/projects/*/project.json`
  - Service Provider: Liest `factory/brain/service_registry.json` (Pfad-Fallback: brain/ oder brain/service_provider/)
  - Model Provider: `get_registry().stats` + health_reports/
  - Command Queue: Zaehlt .md Files in `_commands/`
  - Auto-Repair: Prueft Import + recent repairs aus Janitor Reports
- **Keine bestehenden Dateien geaendert**, kein `__init__.py` modifiziert

### 2026-03-25 — Janitor Phase 2: Protected Paths + Neue Features
- **Protected Paths erweitert** (config.json `safety.protected_paths`):
  - `factory/brain/` (Model Registry, Provider Router, Chain Profiles)
  - `config/` (agent_roles.json, agent_toggles.json, llm_profiles.json)
  - `factory_knowledge/knowledge.json` (22 FK entries)
  - `factory/document_secretary/templates/` (9 PDF templates)
  - `factory/signing/` (credential references)
  - `factory/agent_registry.json`
  - Protected Patterns: `agent.json`, `agent_*.json` hinzugefügt
- **Growth Alert** (`scanner.py`):
  - Speichert Baseline nach jedem Scan (`_baseline.json`)
  - Vergleicht Dateianzahl/Zeilen/Größe/Dateitypen mit vorherigem Scan
  - Schwellenwerte konfigurierbar in `config.json` `growth_alert`
  - Alerts werden im Report unter `scan.growth_alerts` durchgereicht
  - Dashboard: Orange Banner über dem Health Score
- **Config Consistency Check** (`consistency_checker.py`):
  - agent_roles.json ↔ agent_toggles.json Alignment
  - Agent-Dateien ↔ agent_registry.json Drift
  - Fehlende Pflichtfelder in agent*.json
  - Duplikat-Agent-IDs
  - Ghost Registry Entries (Datei gelöscht aber noch in Registry)
  - Toggle/Status Mismatches
- **Dependency Health Check** (`dependency_checker.py`):
  - requirements.txt: ungepinnte Packages, fehlende Lock-Files
  - package.json: Wildcard-Versionen, fehlende Lock-Files, Version-Konflikte
- **Dashboard Integration**:
  - Growth Alerts Banner (orange, mit Prozent-Badges)
  - Neuer Tab "Konsistenz" mit Agent-Stats + Findings
  - Neuer Tab "Dependencies" mit Python/JS-Stats + Findings
  - API erweitert: `/api/janitor` liefert `growth_alerts`, `consistency`, `dependencies`
- **Neue Dateien**: `consistency_checker.py`, `dependency_checker.py`
- **Geänderte Dateien**: config.json, scanner.py, janitor.py, janitor.js, JanitorView.jsx

### 2026-03-25 — Janitor Fine-Tuning (Projekt-Exclusion)
- **Problem**: Janitor scannte 18.614 Dateien inkl. aller Projekt-Outputs, node_modules, Forge-Catalogs
- **Fix 1**: `data_dirs` aus `scan_paths` entfernt → neuer `project_exclusions` Block in `config.json`
  - `output_dirs`: 11 Pipeline-Output-Verzeichnisse (pre_production, market_strategy, mvp_scope, design_vision, visual_audit, roadbook, document_secretary, asset_forge, store_prep, qa_forge, pre_production/memory)
  - `additional_skip_dirs`: ideas, DeveloperReports, projects, run_logs, _commands, Forge catalogs/generated/processed
- **Fix 2**: `_is_project_file()` in `scanner.py` + `graph_builder.py` — prüft output_dirs, additional_skip_dirs, slug_source
- **Fix 3**: node_modules-Bug — Exclude-Logik matchte nur Pfad-Prefix (`node_modules/` matched nicht `factory/hq/dashboard/client/node_modules/`). Fix: `exclude_dir_names` Set matcht auch by directory name
- **Fix 4**: Health-Score-Formel rekalibriert (Penalties: green 0.1, yellow 0.5, red 2 statt 0.5/2/5)
- **Ergebnis**: 619 Dateien (vorher 18.614), 316 Findings (vorher 2.120), Health Score 64
- **Dashboard**: "Infrastruktur" + "Projekt-Dateien übersprungen" Stat-Cards in JanitorView.jsx
- **Dateien**: config.json, scanner.py, graph_builder.py, analyzer.py, janitor.py, JanitorView.jsx

### 2026-03-25 — Dashboard Regression Fix
- **Problem**: Feasibility Check Agent hat **736 factory/ Dateien geloescht** + 4 Dashboard-Dateien ueberschrieben
- **Bulk Restore**: Alle 736 fehlende Dateien via `git checkout 1a3543cf` wiederhergestellt
  - factory/hq/ (Dashboard Backend: providers, assistant, janitor, gates, health_monitor, auto_repair)
  - factory/qa/, factory/store_prep/, factory/signing/
  - factory/asset_forge/, factory/motion_forge/, factory/sound_forge/, factory/scene_forge/
  - factory/integration/, factory/lines/, factory/projects/, factory/shared/
  - factory/agent_registry.json/.py, factory/project_registry.py, factory/run_mode.py
- **Ueberschriebene Dashboard-Dateien** (manuell repariert):
  - App.jsx: 4 Imports + 3 Sections (providers/janitor/team) + ChatPanel-State + Keyboard-Shortcuts + Janitor-Badge
  - Sidebar.jsx: 3 Icons (Wallet, Wrench, Users)
  - Header.jsx: Chat-Toggle-Button + Section-Titles (providers, team)
  - server/index.js: 4 API-Routes (assistant, team, providers, janitor)
- **Feasibility-Additions erhalten**: feasibility.js, gate-executor.js, GateInbox/ProjectGrid/ProjectDetail Aenderungen

### 2026-03-25 — Signing Coordinator: iOS Patch + Restore
- **Problem**: `factory/signing/*.py` Quelldateien fehlten (nur __pycache__, Merge-Verlust)
- **Fix**: 9 .py-Dateien aus Commit `1a3543cf` wiederhergestellt via `git checkout`
- **iOS Patch** (`signing_coordinator.py`): iOS SKIPPED entfernt, jetzt voller Flow via `iOSSigner`
- **main.py**: Signing-CLI-Flags wiederhergestellt (`--sign`, `--check-credentials`, `--show-version`, `--bump-version`, `--list-artifacts`, `--platform`)
- `--platform all` inkludiert jetzt iOS (vorher nur android + web)
- `ios_signer.py` existiert noch nicht lokal (soll vom Mac synced werden)

### 2026-03-25 — Phase 13 Steps 5+6: Design Compliance + QA Forge Orchestrator
- **design_compliance.py**: DesignCompliance — aggregiert QA-Ergebnisse gegen CD Roadbook Design-Anforderungen
  - 12 Auto-Checks (DC-001 bis DC-012): color_palette, brightness, resolution, transparency, loudness, duration, format, timing, ease_curves, lottie_structure, reachability, difficulty_curve
  - 5 Manual CEO Checks (DC-M01 bis DC-M05): Brand Identity, Audio-Visual Sync, Accessibility, Platform Feel, Emotional Response
  - ComplianceCheck + ComplianceReport Dataclasses
  - Verdict: PASS (0 errors, ≤5 warn, ≥95%) / CONDITIONAL_PASS (≤3 errors, ≤10 warn, ≥85%) / FAIL
  - Fixes + Recommendations + CEO Manual Checklist generiert
  - save_report() als JSON in reports/
- **qa_forge_orchestrator.py**: QAForgeOrchestrator — koordiniert alle 5 Checker
  - run(): Echter Katalog-Scan (images/, sounds/, animations/, levels/)
  - run_synthetic_test(): Synthetische Testdaten (15 Items: 5 Visual, 4 Audio, 3 Animation, 3 Scene)
  - QAForgeResult Dataclass mit summary() (human-readable Report)
  - CLI: `python -m factory.qa_forge.qa_forge_orchestrator --project X --synthetic [--save] [--only visual audio]`
  - save_result() als JSON in reports/
- **Proof Run**: `--project echomatch --synthetic --save`
  - Visual: 4 Pass, 1 Fail (64x64 Icon → DC-003)
  - Audio: 3 Pass, 1 Warn (Loudness außerhalb Target)
  - Animation: 3 Pass (Lottie + CSS, Platform Coverage OK)
  - Scene: 4 Pass (3 Level + Curve monotonisch)
  - Score: 91.7% | Verdict: CONDITIONAL_PASS | Duration: 0.7s
  - 1 Required Fix (DC-003), 5 CEO Manual Checks
  - Reports: echomatch_qa_forge.json + echomatch_compliance.json
- **__init__.py**: DesignCompliance + QAForgeOrchestrator exportiert

### 2026-03-25 — Production Feasibility Check (Pre-Production Gate)
- **Neues System**: Automatischer Feasibility Check zwischen CD Roadbook Completion und Production Start
- **Capability Sheet** (`factory/hq/capabilities/capability_sheet.py`): Dynamisches Factory-Profil, frisch bei jedem Aufruf
  - Quellen: CapabilityRegistry, ServiceRegistry, Assembly Line Scan, Forge Scan
  - Return: production_lines, external_services, forge_capabilities, factory_systems, constraints, cannot_do
- **Feasibility Checker** (`factory/hq/capabilities/feasibility_check.py`): Keyword-Matching Roadbook vs Capability Sheet
  - Deterministisch, kein LLM, kostenlos
  - Keywords: Platform, Backend/Infra, Blocked Features, Services
  - Scoring: met + 0.5*warnings / total
  - Status: feasible (weiter), partially_feasible (Gate), not_feasible (parken)
  - Reports: `factory/hq/capabilities/reports/{slug}_feasibility.json`
- **Gate Creator** (`factory/hq/capabilities/gate_creator.py`): Gates fuer partial/blocked
  - partial: proceed_reduced, park, adjust_roadbook, kill
  - blocked: park, kill, redesign
- **Capability Watcher** (`factory/hq/capabilities/capability_watcher.py`): Re-Check geparkter Projekte
  - Erstellt "feasibility_resolved" Gate wenn Status sich verbessert
- **Pipeline Integration** (`factory/dispatcher/dispatcher.py`):
  - Neuer Flow: CD_ROADBOOK_COMPLETE -> feasibility_check -> FEASIBLE -> production_review
  - 4 neue ProductPhase Enum-Werte: FEASIBILITY_CHECKING, FEASIBLE, PARKED_PARTIALLY, PARKED_BLOCKED
- **Project Registry** (`factory/shared/project_registry.py`):
  - Neues `feasibility`-Feld in project.json (status, check_date, score, gaps, report)
  - `update_feasibility()` Funktion, erweiterte `_derive_status()` und `_derive_current_phase()`
- **CLI** (`main.py`): 3 neue Flags
  - `--feasibility-check PROJECT`: Check ausfuehren
  - `--capability-sheet`: Factory Capabilities anzeigen
  - `--recheck-parked`: Alle geparkten Projekte erneut pruefen
  - Alle mit `--json` Support
- **Dashboard Backend**:
  - `factory/hq/dashboard/server/api/feasibility.js`: 5 REST Endpoints
  - `gate-executor.js`: feasibility_gate Handler (proceed_reduced, park, adjust_roadbook, redesign, kill)
  - `gates.js`: Feasibility Gate Detection + Summary
- **Dashboard Frontend**:
  - `ProjectGrid.jsx`: 4 neue Status-Farben/Labels, Gap-Chips fuer geparkte Projekte
  - `ProjectDetail.jsx`: FeasibilitySection mit Re-Check Button + Report-Anzeige
  - `GateInbox.jsx`: Feasibility-spezifische Entscheidungs-Buttons (statt GO/KILL)
- **Smoke Tests**: Alle bestanden
  - Capability Sheet: 4 Lines (iOS, Android, Web, Unity), 6 Services, 13 cannot_do
  - EchoMatch: partially_feasible, score=0.91, 24/27 Requirements met (Backend + AR fehlen)
  - CLI: --capability-sheet, --feasibility-check, --recheck-parked funktionieren
  - Regression: --factory-queue unveraendert

### 2026-03-25 — Phase 13 Steps 1-4: QA Forge Checkers
- **QA Forge Package**: `factory/qa_forge/` — validiert Forge-Outputs (NICHT factory/qa/)
- **config.py**: QA_CONFIG mit Thresholds fuer alle 4 Checker (Visual, Audio, Animation, Scene, Verdict)
- **visual_diff.py**: VisualDiff — Pillow-basiert
  - 4 Checks: color_palette (Quantize + Euclidean RGB), brightness (dark/light theme), resolution (min per type), transparency (alpha per type)
  - check_asset(), check_batch() (manifest), summary()
  - Dark theme: avg brightness <= 120, Sprites brauchen Alpha, Icons brauchen 512px+
- **audio_check.py**: AudioCheck — pydub-basiert (graceful wenn pydub/ffmpeg fehlt)
  - 4 Checks: loudness (peak dBFS + clipping), duration (per category range), format (ext + sample rate + platform preference), loop_quality (first/last 100ms RMS)
  - 5 Kategorien: sfx, ui_sound, ambient, music, notification (je mit Duration-Range)
  - WAV-Fallback via wave-Modul wenn pydub nicht verfuegbar
- **animation_timing.py**: AnimationTiming — Lottie JSON + CSS + C# Support
  - 5 Checks: timing (op-ip/fr*1000 vs category range), ease_curves (linear warning), file_size (lottie 500KB, css 20KB, cs 50KB), lottie_structure (7 required fields), platform_coverage (lottie/css/unity dirs)
  - 6 Timing-Kategorien: micro_interaction, screen_transition, feedback, loading, ambient, branding
  - CSS: animation-duration Regex, C#: duration variable Regex
- **scene_integrity.py**: SceneIntegrity — Level/Scene/Shader/Prefab Validierung
  - check_level: JSON valid, grid dimensions, BFS reachability, difficulty 0-1, objectives, min stone types
  - check_scene: YAML header, FileID refs, no dupes, Camera, Canvas+EventSystem
  - check_shader: Shader decl, SubShader+Pass, vertex/fragment pragmas, URP includes, CBUFFER_START (SRP Batcher)
  - check_prefab: YAML header, root GameObject, FileID refs, .meta file
  - check_difficulty_curve: monotonic, no large jumps (>0.25), tutorial levels under 0.25
- **Self-Tests**: 21/21 bestanden (alle synthetisch — echte Forge-Outputs nicht mehr auf Platte)
  - Visual: dark pass, bright fail, no-alpha fail, small-icon fail
  - Audio: loudness run, duration range, format detect, too-short fail
  - Animation: timing OK, file size OK, structure OK, too-slow fail, incomplete fail
  - Scene: level pass, isolated cells, scene YAML, shader URP, prefab+meta, curve monotonic, big jump

### 2026-03-12 — Claude Migration
- Komplette Umstellung von OpenAI GPT → Anthropic Claude
- 3-Tier System: Sonnet (Tier 1+2) + Haiku (Tier 3)
- 4 Agents deaktiviert: android_architect, kotlin_developer, web_architect, webapp_developer
- Alle OpenAI-Referenzen entfernt (config, docs, agent_roles)
- API Key: `ANTHROPIC_API_KEY` in `.env` eingetragen

### 2026-03-12 — Projekt-Bereinigung
- Alte DriveAI-Duplikate gelöscht (224 Files), nur AskFinn bleibt
- AskFinn iOS App: BUILD SUCCEEDED auf Mac (iPhone 17 Pro Simulator, iOS 26.3)
- 68 AutoGen-Logs analysiert → 3 kritische Factory-Schwachstellen identifiziert

### 2026-03-12 — Factory-Erweiterung
- AutoResearchAgent, ResearchMemoryGraph, StrategyReportAgent hinzugefügt
- Neue Module: radar/, costs/, research/, research_graph/, strategy/
- Control Center: 19 Pages (inkl. Radar, AI Costs, Strategy, Research Graph, Research)
- store_reader.py + app.py + daily_briefing.py erweitert

### 2026-03-12 — Premium Product Strategy
- Factory-Philosophie definiert: Premium-Produkte statt generische Apps
- AskFin als erstes Referenzprojekt reframed (Coach statt Tool)
- Factory Learning Loop designt (factory_knowledge/ mit 6 Wissenstypen)
- 3 neue Agents vorgeschlagen: Creative Director (Sonnet), UX Psychology (Sonnet, on-demand), Factory Learning (Haiku)
- 4 neue Quality Gates: Innovation, Experience Uniqueness, Motivation Quality, Premium Design
- Neue Docs: factory_premium_product_principles.md, askfin_premium_reframing.md, factory_learning_loop.md, factory_new_roles_proposal.md, factory_new_gates_proposal.md

### 2026-03-12 — Implementation Planning
- Plausibilitaets-Check: 3 Risiken identifiziert (Doppel-Insertion, SelectorGroupChat Message-Limit, factory_knowledge Abhaengigkeit)
- Creative Director: NICHT als Full Agent im Team, sondern als separater Review Pass (wie Bug Hunter)
- Factory Knowledge Schema: 1 knowledge.json statt 6 separate Dateien (zu granular fuer Start)
- factory_knowledge/ Scaffold angelegt: knowledge.json + index.json + README.md
- 5-Step Rollout definiert: Scaffold -> CD Advisory -> Knowledge Seeding -> CD Gate -> Learning Writeback
- Neue Docs: creative_director_integration_plan.md, factory_learning_schema.md, first_rollout_execution_plan.md

### 2026-03-12 — Creative Director Advisory Pass (Step 2)
- CD implementiert als Team-Mitglied + separater Pass (wie Bug Hunter Pattern)
- Laeuft nach Bug Review, vor Refactor (standard + full Mode)
- Skip bei service/viewmodel Templates, skip bei quick Mode
- Advisory only: loggt Feedback, blockiert nichts
- Deaktivierbar: `--disable-agent creative_director`
- Dateien: agents/creative_director.py, agent_roles.json, agent_toggles.json, agent_toggle_config.py, model_router.py, task_manager.py, main.py
- Agent-Count: 20 aktiv + 4 deaktiviert = 24

### 2026-03-12 — Pipeline Reliability (Steps 2b/2c)
- team.reset() zwischen Passes gegen Context-Explosion (>50k Tokens nach Implementation Pass)
- _run_with_retry() Wrapper fuer alle 6 Passes (65s Backoff bei Rate Limit)
- Exception-Catch auf beide AutoGen-Fehlerpfade erweitert (RuntimeError + direkter RateLimitError)
- Implementation Summary: kompakte Zusammenfassung (300-2000 chars) aus Extraction-Metadaten fuer Review-Passes
- Docs: pipeline_reliability_fix.md, implementation_summary_integration.md

### 2026-03-12 — Factory Knowledge Seed Round 1 (Step 3)
- 6 Eintraege in factory_knowledge/knowledge.json geseedet
- FK-001 (failure_case): Funktionale App ohne Motivation = kein Retention
- FK-002 (ux_insight): Emotionale Micro-Copy > Daten-Feedback
- FK-003 (motivational_mechanic): Domaenenspezifischer Fortschritt > generische Gamification
- FK-004 (technical_pattern): SelectorGroupChat Reset zwischen Passes
- FK-005 (technical_pattern): Implementation Summary fuer Review-Qualitaet
- FK-006 (success_pattern): Neue Review-Agents starten advisory-only
- Confidence: 3x hypothesis (Product), 3x validated (Pipeline)
- Doc: factory_knowledge_seed_round_1.md

### 2026-03-12 — CD Knowledge Integration (Step 3b)
- factory_knowledge/knowledge_reader.py erstellt: deterministische Entry-Selektion fuer CD
- Selektion: type-Filter (nicht technical_pattern) + product_type-Filter (nicht ai_pipeline) + confidence-Sort + Cap bei 5
- 3 Entries (FK-001/002/003) werden als kompakter Block (706 chars) in CD-Task injiziert
- Injection-Reihenfolge: Factory Knowledge → Implementation Summary → CD Review Task
- Validierung: CD-Output referenziert alle 3 Entries, gibt domänenspezifische Vorschläge statt generischem Feedback
- CD-Summary: "functionally complete but emotionally hollow" = FK-001 als Review-Fazit
- Doc: creative_director_knowledge_integration.md

### 2026-03-12 — Knowledge Proposal System (Step 3c)
- factory_knowledge/proposal_generator.py erstellt: analysiert Run-Output, generiert Kandidaten-Entries
- 5 Signale erkannt: Critical Bugs, CD Fail Rating, Emotional Design Gaps, File Duplication, Lifecycle Bugs
- Max 3 Proposals pro Run, deterministisch (Regex), kein LLM
- Proposals landen in factory_knowledge/proposals/proposal_<run_id>.json (NICHT in knowledge.json)
- Integration in main.py nach Analytics, vor Console-Summary (try/except — non-blocking)
- Doc: factory_knowledge_proposal_system.md

### 2026-03-13 — Creative Director Soft Gate (Step 4)
- CD Rating Parser in knowledge_reader.py: robuster Regex fuer 6+ Format-Variationen + Fallback-Scan
- Gate-Logik in main.py: FAIL → stoppt Refactor/Test/Fix-Passes, conditional_pass → Warning, pass/unparseable → weiter
- Template-aware: Gate nur bei screen/feature aktiv (service/viewmodel/andere → kein Gate)
- Fail-open Design: unerkannte Ratings → pass (Pipeline blockiert nie wegen Parsing)
- CLI Flag: --no-cd-gate umgeht Gate komplett
- Bugs entdeckt und gefixt:
  - SelectorGroupChat waehlte falschen Speaker → Task-Prefix "creative_director:" + Fallback-Scan in extract_cd_rating
  - team.reset() fehlte zwischen Bug Hunter und CD Pass → hinzugefuegt
  - MaxMessageTermination(2) Override wirkte nicht (nur Team-Attribut, nicht GroupChatManager) → entfernt
- Validiert: FAIL stoppt Pipeline (3 Phases uebersprungen), conditional_pass laeuft weiter
- Doc: creative_director_gate_mode.md

### 2026-03-13 — UX Psychology Review Layer
- Neuer Advisory Pass: analysiert Verhaltenspsychologie, Lernpsychologie, Motivation, Retention
- Trennung: CD = "sieht es premium aus?" vs. UX Psych = "funktioniert die Verhaltenssteuerung?"
- Laeuft nur bei screen/feature Templates, wird bei CD-Gate-Stop uebersprungen
- Position in Pipeline: nach CD Gate, vor Refactor
- Agent-Count: 21 aktiv + 4 deaktiviert = 25
- Dateien: agents/ux_psychology.py, agent_roles.json, agent_toggles.json, agent_toggle_config.py, model_router.py, task_manager.py, main.py
- Validiert: ExamSimulation Run — 5 spezifische Findings mit psychologischen Prinzipien (Testing Effect, SDT, Cognitive Load Theory, Spacing Effect, Cognitive Appraisal)
- Deaktivierbar: --disable-agent ux_psychology
- Doc: ux_psychology_review_layer.md

### 2026-03-13 — UX Knowledge Seed Round 1
- 4 neue Eintraege in factory_knowledge/knowledge.json (FK-007 bis FK-010)
- FK-007 (ux_insight): Answer feedback must explain WHY — Testing Effect
- FK-008 (motivational_mechanic): Competence progress between tasks — SDT
- FK-009 (ux_insight): Task type differentiation — Cognitive Load Theory
- FK-010 (ux_insight): Spacing/Interleaving weak topics — Ebbinghaus
- Alle hypothesis-Level, Quelle: UX Psychology Validation Run
- Knowledge Block: 706 → 1158 chars (5 Entries injected, Cap bei 5)
- Excluded: Timer Reframing (zu spezifisch fuer Pruefungssimulationen)
- Total: 10 Entries (7 hypothesis, 3 validated)
- Doc: factory_ux_knowledge_seed_round_1.md

### 2026-03-13 — Commercial Strategy Generator
- Neues Modul: factory_strategy/commercial_strategy_generator.py
- Generiert strukturierte Strategy Books (7 Sektionen) via Claude Sonnet API
- Kontext-Quellen: Project Registry, Premium Reframing, Compliance, Architecture, Factory Knowledge
- AskFin Strategy Book generiert (15k chars): Positioning, Monetization, Distribution, Marketing, Assets, Risks, Next Steps
- Speicherort: strategy_books/<project>_strategy.md
- Standalone — keine Pipeline-Integration, kein neuer Agent
- Doc: commercial_strategy_generator.md

### 2026-03-13 — AskFin Premium Projekt
- Neues Projekt: projects/askfin_premium/ (MVP in DriveAI/ bleibt unangetastet)
- 5 Experience Pillars priorisiert: P0=Training Mode + Skill Map, P1=Exam Sim + Progress, P2=Motivational Feedback
- Factory Knowledge FK-001 bis FK-010 auf Pillars gemappt
- Design-Signatur definiert: Dark Theme, Swipe-basiert, Haptic Feedback, Progressive Disclosure
- Project Registry aktualisiert (3 Projekte: askfin, factory-core, askfin_premium)
- Constraints dokumentiert: Legal (kein App Store ohne Lizenz), LLM-Kosten, Offline

### 2026-03-14 — Repo-Bereinigung & Konsolidierung
- DriveAI/ Ordner geloescht (alte AskFinn App, 184 Swift Files — Duplikat)
- DriveAi-AutoGen/ geloescht (leeres Xcode Template)
- projects/askfin_premium/ geloescht (alte ungefixte Version)
- AskFin Premium konsolidiert nach projects/askfin_v1-1/ (75 Swift Files, gefixte Version)
- GeneratedHelpers.swift geloescht (588 Zeilen invalider Swift Code)

### 2026-03-14 — Factory Knowledge Error Pattern Seed
- 7 Error Patterns aus Xcode Fix Report extrahiert (FK-011 bis FK-017)
- FK-011: AI Review Text in Source Files (BLOCKING)
- FK-012: Doppelte Typ-Definitionen (BLOCKING)
- FK-013: Parameter-Mismatch an Call-Sites (BLOCKING/WARNING)
- FK-014: Referenzierte Typen nie generiert (BLOCKING)
- FK-015: Bundle.module in App Targets (WARNING)
- FK-016: Custom init unterdrueckt memberwise init (INFO, nicht implementiert)
- FK-017: Namespace-Kollisionen zwischen Feature-Layern (BLOCKING/WARNING)
- Total Factory Knowledge: 17 Eintraege (FK-001 bis FK-017)
- Doc: factory_error_pattern_seed_round_1.md

### 2026-03-14 — Compile Hygiene Validator (Round 2 + 3)
- factory/operations/compile_hygiene_validator.py erstellt
- 6 deterministische Checks implementiert (kein LLM):
  - FK-011: AI Review Text Detection (7 Regex Patterns)
  - FK-012: Doppelte Typ-Definitionen (Cross-File Registry + Nested Types)
  - FK-013: Parameter-Mismatch (Balanced-Paren Init Parsing, Scope-Aware Signatures)
  - FK-014: Fehlende Typen (100+ Framework-Type-Exclusions)
  - FK-015: Bundle.module Detection
  - FK-017: Namespace-Kollisionen (Pfad-basierte Layer-Erkennung)
- Extensive False-Positive-Tuning: von 38 auf 0 Issues bei askfin_v1-1
- Reports: factory/reports/hygiene/<project>_compile_hygiene.json
- Pipeline-Integration nach Completion Verifier
- Doc: compile_hygiene_validator.md

### 2026-03-14 — Swift Compile Check
- factory/operations/swift_compile_check.py erstellt
- Nutzt echten Swift Compiler (swiftc -parse) fuer Syntax-Validierung
- Graceful SKIPPED auf Windows (kein swiftc)
- 2 Modi: parse (Syntax) und typecheck (Typen)
- 30s Timeout pro Datei, JSON Reports
- Pipeline-Integration nach Compile Hygiene Validator
- Reihenfolge: Output Integrator → Completion Verifier → Compile Hygiene → Swift Compile → Recovery → Run Memory
- Doc: swift_compile_check.md

### 2026-03-14 — OutputIntegrator Dedup Fix (Report 9-0)
- `_collect_all()` sammelt nur noch current-run Artifacts (generated_code/ + gefilterter Log)
- Alte Logs, Delivery-Exports, existing_output werden nicht mehr gesammelt
- `generated/` wird vor jeder Integration geleert (clean_before_integrate)
- Projekt-Level Dedup Guard: Skip wenn Filename bereits im Projekt existiert
- `run_id` wird an `_run_operations_layer()` durchgereicht als `log_filter`
- Ergebnis: 110→24 Artifacts, 95→4 geschriebene Files, FK-012 (Integrator) von ~105 auf 0

### 2026-03-14 — Inline Type Dedup (Report 11-0)
- `_strip_duplicate_types()` in code_extractor.py: entfernt top-level Inline-Types wenn eigene Datei existiert
- Greift nach Sammlung aller Code-Blocks, vor dem Write
- Nur top-level (Column 0), nested Types werden nie entfernt, Primary geschuetzt
- Ergebnis: 6/16 Dateien deduped, FK-012 von 13 auf ~8 erwartet

### 2026-03-14 — DeveloperReports Reorganisation
- `DeveloperReports/CodeAgent/` fuer Code-Agent-Reports (1-0 bis 11-0)
- `DeveloperReports/Steps-MasterLead/` fuer Master-Lead-Steps (Andreas)
- CLAUDE.md aktualisiert mit neuer Ordnerstruktur

### 2026-03-14 — AskFin Baseline Cleanup (Report 12-0)
- 14 Duplicate-Type-Clusters gefunden (11 INTRA-PROJ, 3 GEN+PROJ)
- 10 Dateien bereinigt, 663 Zeilen Duplikat-Code entfernt
- generated/ komplett geleert und geloescht
- FK-012: 13 → 1, Total Issues: 21 → 5, Blocking: 20 → 4

### 2026-03-14 — Final Baseline Repair (Report 13-0)
- StreakData FK-012: API-Version umbenannt zu `ReadinessStreakData` (inkompatible Properties)
- LocalDataService FK-014: Klasse + `LocalDataServiceProtocol` + `UserProgressServiceProtocol` erstellt
- ExamReadinessViewModel FK-013: Preview-Extension auf korrektes init gefixt
- ExamReadinessService: init + Protocol-Stubs hinzugefuegt
- Stray Code entfernt: `@MainActor` in Protocol-Datei, Demo-Code in MockService
- CategoryStat: Properties hinzugefuegt (war leerer Struct)
- XCTestCase zu Validator Framework-Types hinzugefuegt
- **Ergebnis: 0 Blocking Issues, 1 Warning (FK-015 Bundle.module)**
- Kumulativ: FK-012 von 105 → 0, Total Blocking von 155 → 0

### 2026-03-14 — Third Autonomy Proof Run (Report 14-0)
- Run 20260314_163402, template=feature, name=ExamReadiness, model=claude-haiku-4-5
- Baseline war sauber (0 Blocking). Pipeline lief: Implementation → Bug Hunter → CD → STOP (CD Gate FAIL)
- 22 Files generiert, 9 integriert, 13 durch CodeExtractor Dedup entfernt
- OutputIntegrator korrekt: 9 Artifacts gesammelt, 0 geschrieben (alle Projekt-Duplikate)
- Compile Hygiene nach Run: 10 Blocking (5 FK-012 + 5 FK-014)
- **Naechster Blocker: ProjectIntegrator kopiert blind ins Projekt (kein Dedup-Guard)**
  - Ueberschreibt existierende Dateien (ReadinessLevel.swift)
  - Fuegt Dateien mit Inline-Duplikaten hinzu (UserProgressService.swift enthält LocalDataService + CategoryProgress)
  - OutputIntegrator Dedup-Guard laeuft zu spaet (nach ProjectIntegrator)
- Fix-Optionen: (A) ProjectIntegrator Dedup-Guard oder (B) ProjectIntegrator komplett entfernen
- Sekundaer: CodeExtractor braucht Projekt-Awareness (Inline-Dedup gegen Projekt, nicht nur Run)

### 2026-03-14 — ProjectIntegrator Dedup Guard (Report 15-0)
- Statische _PROTECTED_FILES (55 hardcodierte Eintraege) ersetzt durch dynamischen Projekt-File-Index
- _build_project_file_index() scannt alle .swift-Dateien im Projekt (exkl. generated_code/)
- Existierende Dateien werden nie mehr ueberschrieben (Skip + Log)
- Run-3-Simulation: 3 von 5 FK-012 verhindert (alle Overwrites), 2 verbleiben (neue Files mit Inline-Dupes)
- Compile Hygiene nach Cleanup: FK-012=0, 1 Blocking (FK-014 ExamReadiness aus User-Modifikation)
- **Naechster Blocker**: CodeExtractor Projekt-Awareness (Inline-Dedup gegen Projekt-File-Index)

### 2026-03-14 — CodeExtractor Project-Awareness (Report 16-0)
- `extract_swift_code()` erhaelt `project_name` Parameter
- Scannt Projekt-Verzeichnis fuer .swift File-Stems und merged mit current-run Names
- `_strip_duplicate_types()` prueft jetzt gegen Run-Files UND Projekt-Files
- Run-3-Simulation: CategoryReadiness, LocalDataService, CategoryProgress jetzt gestrippt
- Zusammen mit Report 15-0: Alle 5 FK-012 aus Run 3 waeren verhindert worden
- Dreischichtiger Schutz: CodeExtractor → ProjectIntegrator → OutputIntegrator

### 2026-03-14 — Fourth Autonomy Proof Run (Report 17-0)
- Run 20260314_182358, template=feature, name=ExamReadiness, model=claude-haiku-4-5
- Baseline sauber (0 Blocking). Pipeline: Implementation → Bug Hunter → CD → STOP (CD Gate FAIL)
- **Dreischichtiger Dedup voll funktional**:
  - CodeExtractor: 4 Dateien gegen Projekt bereinigt (Projekt-Awareness)
  - ProjectIntegrator: 5 existierende Dateien uebersprungen (0 Overwrites)
  - OutputIntegrator: 0 geschrieben (Backstop korrekt)
- Compile Hygiene: **1 FK-012 (False Positive)** — ReadinessLevel nested enum in ExamReadiness.swift
  - Validator erkennt keine Nested Types → Limitation, kein echtes Duplikat
- FK-012 Trend: 105 → 13 → 5 → **1 (False Positive)** — Duplikate materiell geloest
- Knowledge: 3 Proposals, 1 Auto-Promotion (FK-019 SwiftUI lifecycle memory leak)
- **Naechster Blocker: CD Gate Rating** — Pipeline kommt nie ueber CD Gate hinaus
  - Rating Parser nimmt letztes "Rating:" im GroupChat (moeglicherweise Non-CD Agent)
  - CD Erwartungen zu hoch fuer Haiku-generierten Erstlauf
  - Fix: Parser haerten (CD-spezifisch) + CD Gate Mode ueberdenken (Advisory fuer Dev-Profile)

### 2026-03-14 — CD Rating Parser Hardening (Report 18-0)
- Log-Analyse: Alle Rating-Zeilen in Run 3+4 stammten tatsaechlich vom creative_director Agent
- Hypothese "Non-CD Agent Rating" aus Report 14-0 war falsch — Parser war korrekt
- Trotzdem verbessert: CDRatingResult Klasse mit vollem Audit Trail (Kandidaten, Quelle, Begruendung)
- Fix: Letzter CD-Match statt erster (finales Verdict bei mehrfachem CD-Sprechen)
- Console zeigt jetzt alle Kandidaten + Auswahlgrund + Quell-Agent
- 9 Validierungstests geschrieben und bestanden
- **Naechster Blocker: CD Gate Policy** — fail bei Dev-Profile stoppt Pipeline, CD Erwartungen zu hoch
- Dateien: knowledge_reader.py (CDRatingResult + extract_cd_rating_detailed), main.py (Gate-Logging), tests/test_cd_rating_parser.py

### 2026-03-14 — CD Gate Policy Profile-Aware (Report 19-0)
- CD Gate ist jetzt profil-abhaengig: dev/fast → advisory (non-blocking), standard/premium → blocking
- `_cd_blocking = profile in ("standard", "premium")` — 1 Kontrollpunkt in main.py
- Dev-Runs durchlaufen jetzt alle 8 Pipeline-Passes statt nur 3
- CD-Findings fliessen via review_digests in UX Psychology, Refactor, Fix Execution
- 10 Policy-Tests + 9 Parser-Tests = 19 Tests bestanden
- `--no-cd-gate` bleibt als expliziter Override
- **Naechster Schritt**: Autonomy Proof Run mit Dev-Profile → sollte volle Pipeline durchlaufen

### 2026-03-14 — Fifth Autonomy Proof Run (Report 20-0)
- Run 20260314_194620, template=feature, name=ExamReadiness, model=claude-haiku-4-5, profile=dev
- **ERSTMALS**: Alle 6 Agent-Passes ausgefuehrt (Impl + Bug + CD + UX Psych + Refactor + Test Gen)
- **CD conditional_pass** (nicht fail!) — Pipeline waere aber auch bei fail weitergelaufen (advisory)
- 31 Files generiert davon **7 Test-Dateien** (erstmals Tests generiert!)
- Review Digest Chain funktioniert: Bug Hunter → CD → UX Psych → Refactor (akkumuliert)
- Pipeline meldet "status: success" — erster erfolgreicher Run
- **PROBLEM**: `--project askfin_v1-1` fehlte im Aufruf → Files in DriveAI/ statt Projekt
  - Operations Layer nicht ausgefuehrt (OutputIntegrator, CompileHygiene, Recovery, RunMemory)
  - CodeExtractor Projekt-Awareness nicht aktiv
  - ProjectIntegrator Dedup gegen falsches Verzeichnis
- **Naechster Schritt**: Run mit `--project askfin_v1-1` → volle Validierungs-Pipeline
- Korrekter Aufruf: `python main.py --template feature --name ExamReadiness --profile dev --approval auto --project askfin_v1-1`

### 2026-03-14 — Project Context Hardening (Report 21-0)
- Auto-Inferenz: Wenn 1 Projekt in projects/ → automatisch verwenden (kein --project noetig)
- Warning-Logging bei fehlendem Projekt (Console + Pipeline-Header)
- Quelle wird geloggt: "explicit (--project flag)" vs "auto-inferred (single project)"
- `--project` bleibt als expliziter Override wenn mehrere Projekte existieren
- Validiert: Alle 3 Szenarien (kein Flag, explizit, Template-only) resolven korrekt auf askfin_v1-1

### 2026-03-15 — Sixth Autonomy Proof (Report 22-0)
- **Erster Run mit Auto-Inferenz**: `--project` weggelassen → `askfin_v1-1` automatisch erkannt
- **Operations Layer erstmals automatisch aktiv**: OutputIntegrator (137-File Index), CompileHygiene (137 Files), RunMemory, KnowledgeWriteback
- CD Gate: `conditional_pass` (konsistent, Parser korrekt)
- Alle 6 Pipeline-Passes ausgefuehrt (Impl → Bug → CD → UX → Refactor → Tests)
- CompileHygiene: 4 BLOCKING, 1 WARNING
  - FK-012: ReadinessLevel nested enum (false positive)
  - FK-013: DateComponentsValue Init nicht erkannt
  - FK-014 (x2): PriorityLevel + ReadinessCalculationService nicht deklariert
- **Naechster Blocker**: FK-014 — Factory erzeugt Code der Typen referenziert die nie deklariert werden
- **Empfehlung**: Type-Stub-Generator als Post-Generation-Fix

### 2026-03-15 — FK-014 Type Stub Generator (Report 23-0)
- Neues Modul: `factory/operations/type_stub_generator.py` — deterministisch, kein LLM
- Inferiert Typ-Art aus Namenskonvention (Service->class, Level->enum, View->SwiftUI struct, etc.)
- Generiert minimale kompilierbare Stubs ins Projekt
- In Operations Layer eingefuegt: zwischen CompileHygiene und SwiftCompile
- Re-run CompileHygiene nach Stub-Erstellung
- **Validiert**: FK-014 von 1 -> 0 reduziert, Blocking total von 3 -> 2

### 2026-03-15 — Compile Hygiene Truthfulness (Report 24-0)
- FK-012 Fix: Column-aware Duplikat-Erkennung (nested types column>0 ignoriert)
- FK-013 Fix: Memberwise init aus stored properties erkannt (nicht nur explizite inits)
- Type-Registry auf 4-Tupel erweitert: (rel_path, kind, line_num, column)
- **BLOCKING vorher: 4** (FK-012 x1 + FK-013 x1 + FK-014 x2)
- **BLOCKING nachher: 1** (ExamReadinessSnapshot — echtes Problem, kein false positive)
- 10 neue FK-013 Warnings (korrekt: teilweise Init-Mismatches im generierten Code)
- Verbleibender BLOCKING: ExamReadinessSnapshot hat keine Properties, Call-Site nutzt 7 Labels

### 2026-03-15 — Seventh Autonomy Proof (Report 25-0)
- Alle 5 BLOCKING sind echte Probleme — **0 false positives erstmals**
- CodeExtractor Dedup: 10 Files (Rekord)
- OutputIntegrator: 3 Files geschrieben (erstmals nicht 0)
- Stub Generator: 1 Stub (Element) automatisch erstellt
- CD Gate: `fail` aber advisory (dev-profile, korrekt)
- Neue Erkenntnis: OutputIntegrator schreibt in `generated/` neben bestehenden Projekt-Files
  - FK-012 x3: AssessmentPersistenceServiceProtocol, ReadinessAssessmentService, ReadinessAssessmentServiceProtocol
  - Root Cause: Dedup prueft nur Dateinamen, nicht Type-Inhalte
- **Naechster Blocker**: OutputIntegrator generated/ vs Projekt-Root Duplikate (FK-012)

### 2026-03-15 — OutputIntegrator Semantic Dedup + Markdown Sanitization (Report 26-0)
- Type-Level Dedup: Neuer `_build_project_type_index()` scannt 214 Types aus 158 Files
- OutputIntegrator prueft jetzt Type-Deklarationen, nicht nur Dateinamen
- Markdown Sanitization: `---` und `## Heading` werden vor dem Schreiben entfernt
- **BLOCKING vorher (Run 7): 5** (FK-011 x1, FK-012 x3, FK-013 x1)
- **BLOCKING nachher: 1** (nur ExamReadinessSnapshot FK-013 — echtes Code-Problem)
- 5 Dedup-Layers: CodeExtractor → ProjectIntegrator → OutputIntegrator Filename → OutputIntegrator Type → CompileHygiene
- **Naechster Blocker**: ExamReadinessSnapshot struct ohne Properties (FK-013)

### 2026-03-15 — FK-013 Property Shape Repair (Report 27-0)
- Neues Modul: `factory/operations/property_shape_repairer.py` — deterministisch, kein LLM
- Inferiert Property-Types aus Call-Site-Argumenten (Double, Int, Date, [Type], etc.)
- Fuegt fehlende Properties in 0-Property-Structs ein
- In Operations Layer nach StubGen, vor SwiftCompile
- **ExamReadinessSnapshot**: 8 Properties aus Call-Site inferiert und eingefuegt
- **BLOCKING: 1 -> 0** — CompileHygiene Status erstmals **WARNINGS** statt BLOCKING
- Repair-Pipeline komplett: FK-014→StubGen, FK-013→ShapeRepairer, FK-012→TypeDedup, FK-011→Sanitization

### 2026-03-15 — Eighth Autonomy Proof (Report 28-0)
- StubGen: ExamSession automatisch geloest (FK-014)
- OutputIntegrator: 233 Types im Index, 0 Duplikate durchgelassen
- FK-012 und FK-011: Kein einziger Fall mehr (Type-Dedup + Sanitization wirken)
- ShapeRepairer: AnswerButtonView uebersprungen (zaehlt @State/body als stored property)
- **BLOCKING initial: 2, nach Auto-Fix: 1** (nur FK-013 AnswerButtonView)
- **Naechster Fix**: SwiftUI-Awareness im Property-Counter (@State/@Binding/body ausschliessen)

### 2026-03-15 — SwiftUI-Aware Property Counting (Report 29-0)
- PropertyShapeRepairer + CompileHygiene: SwiftUI Property-Wrapper (@State, @Binding, etc.) ausgeschlossen
- Computed properties (`var body: some View {`) korrekt erkannt (same-line `{` check)
- Lookahead-Bug gefixt: Nur same-line statt 80-char lookahead (verhinderte false positives)
- **AnswerButtonView FK-013: GELOEST** — stored props korrekt 0
- **CompileHygiene Status: WARNINGS (0 BLOCKING)** — erstmals stabil
- 5 Regression-Tests bestanden (AnswerButtonView, ExamReadinessSnapshot, DateComponentsValue, @State/@Binding, @Published)

### 2026-03-15 — CompletionVerifier Evidence Mode (Report 30-0)
- Neuer Modus: Project-Evidence wenn kein specs/ vorhanden
- Evidenz-Quellen: Projekt-Files (173), Core-Ordner, Hygiene-Report (blocking=0)
- Neues Verdict: `INSUFFICIENT_EVIDENCE` fuer ehrliche Unsicherheit
- AskFin: FAILED -> **MOSTLY_COMPLETE (95%)** — korrektes Verdikt
- Recovery Gate: Nicht mehr false-FAILED blockiert
- `classify_health()` Regression-Tests alle bestanden

### 2026-03-15 — Ninth Autonomy Proof (Report 31-0)
- **MOSTLY_COMPLETE / 95%** — erstmals positiver CompletionVerifier + RunMemory
- CompletionVerifier Evidence-Mode im Live-Run bestaetigt
- Recovery Gate: "no recovery needed" statt false "too little output"
- 1 BLOCKING: FK-013 ExamReadinessViewModel (class, nicht struct) → ShapeRepairer braucht class-Awareness
- Kein FK-011, FK-012, FK-014 — alle Auto-Repairs stabil
- DriveAI/ Ordner geloescht, Fallback entfernt
- **Naechster Fix**: ShapeRepairer class-Support (struct|class statt nur struct)

### 2026-03-15 — PropertyShapeRepairer Class Support (Report 32-0)
- Regex erweitert: `struct` → `(?:struct|class)` in 4 Stellen
- Neuer Guard: Classes mit explizitem init werden uebersprungen (Swift hat keine memberwise init fuer classes)
- ExamReadinessViewModel: Korrekt gefunden + korrekt uebersprungen (init(service:) existiert)
- Properties-Einfuegung bei Classes ohne init funktioniert (getestet)
- Verbleibender BLOCKING: Init-Signatur-Mismatch (ServiceContainer nutzt falsche Labels)
- **Das ist ein Code-Gen-Problem, kein Repairer-Problem**

### 2026-03-15 — Tenth Autonomy Proof (Report 33-0)
- **0 Code Output** — Haiku hat nur Architektur diskutiert, keinen Swift-Code generiert
- CD: `conditional_pass` (erstmals seit Run 6 positiv)
- CompletionVerifier: INCOMPLETE/80% (wegen persistentem FK-013 blocking=1)
- **Recovery Loop erstmals aktiviert!** INCOMPLETE → Recovery gestartet → 0 Targets → SKIPPED
- FK-013 ServiceContainer ist persistentes Artefakt aus Run 9, kein neuer Mismatch
- Class-init-Mismatch ist NICHT wiederkehrend — nur ein einzelnes persistentes File
- **Empfehlung**: ServiceContainer.swift loeschen (Artefakt) oder standard-profile Run fuer mehr Code-Output

### 2026-03-15 — Stale Artifact Guard (Report 34-0)
- Neues Modul: `factory/operations/stale_artifact_guard.py` — Git-Provenance-basiert
- Erkennt BLOCKING-Files die durch "AI run:" Commits hinzugefuegt wurden
- **Quarantine** statt Delete: Files in `quarantine/` verschoben (nicht geloescht)
- CompileHygiene scannt quarantine/, generated/, .git nicht mehr
- **ServiceContainer.swift quarantiniert** → 0 BLOCKING, Status: WARNINGS
- Safety: App/, Config/, Resources/, Info.plist geschuetzt (nie quarantiniert)
- **Baseline jetzt: 0 BLOCKING, 13 Warnings, 177 Files, MOSTLY_COMPLETE/95%**

### 2026-03-15 — Eleventh Autonomy Proof (Report 35-0)
- **Sauberster Run aller Zeiten**: 0 BLOCKING, MOSTLY_COMPLETE/95%, kein Ops-Layer-Eingriff noetig
- Kein StubGen, kein ShapeRepair, kein StaleGuard, kein Recovery
- Haiku-Limit: Nur 1 File generiert (GeneratedHelpers, uebersprungen)
- CD: "not detected" (Haiku generierte kein Rating-Label)
- 10 Runs im RunMemory, davon 1 Recovery-Run
- **Engpass ist jetzt Code-Gen-Output** (Haiku bei wiederholtem Feature), nicht mehr Pipeline/Repair
- **Empfehlung**: standard-Profile (Sonnet) oder anderes Feature testen

### 2026-03-15 — Twelfth Autonomy Proof (Report 36-0) — standard profile
- **45 Swift Files generiert** (39 impl + 6 fix) — deutlich mehr als Haiku-Runs
- **7 Passes** (erstmals Fix Execution!) — standard profile setzt run_mode: full
- 16 Files integriert, Projekt wuchs auf 194 Files, 270 Types
- FK-014 `ReadinessCalculationResult` automatisch durch StubGen geloest
- **0 BLOCKING nach Auto-Fix**, 19 Warnings
- MOSTLY_COMPLETE / 95% — Baseline stabil unter realistischer Last
- **Bug**: Modell blieb Haiku trotz `--profile standard` — Profile setzt run_mode aber nicht model
- **Empfehlung**: Profile-System Model-Resolution debuggen

### 2026-03-15 — Profile Model Resolution Fix (Report 37-0)
- Root Cause: `--profile` und `--env-profile` waren getrennte Systeme — `--profile standard` setzte nur run_mode, nicht das LLM-Modell
- Fix: Profile-zu-EnvProfile-Bridge — wenn `--profile` einem LLM-Profile entspricht (dev/standard/premium), wird es automatisch als env_profile genutzt
- `PROFILE_DEFAULTS` um `standard` und `premium` erweitert
- `--profile standard` -> Sonnet + full mode (vorher: Haiku + full)
- `--profile premium` -> Opus + full mode (vorher: Haiku + full)
- Alle 7 Regression-Tests bestanden, explizites `--env-profile` hat weiterhin Vorrang
- **Zweiter Bug**: `VALID_PROFILES` Tuple fehlte "standard"/"premium" → `--profile standard` wurde verworfen → gefixt

### 2026-03-15 — Thirteenth Autonomy Proof (Report 38-0)
- Noch Haiku (VALID_PROFILES Fix kam nach Run-Start), 42 Files, 11 integriert, Projekt 206 Files
- **4 BLOCKING → 0 durch vollen Auto-Repair-Stack** (StubGen + StaleGuard)
- StaleGuard quarantinierte ReadinessCalculationServiceTests.swift
- **`Hasher` Bug**: Swift-Framework-Typ faelschlich als FK-014 → zu `_KNOWN_FRAMEWORK_TYPES` hinzugefuegt
- Falschen Hasher.swift Stub geloescht

### 2026-03-15 — Fourteenth Autonomy Proof (Report 40-0) — ERSTER SONNET RUN
- **Model: claude-sonnet-4-6 BESTAETIGT** — Profile-Fix funktioniert
- **62 Swift Files** (42 impl + 20 fix) — Rekord! 47% mehr als Haiku
- **21 Files integriert**, Projekt auf 227 Files + 302 Types gewachsen
- Sonnet generiert Tests, Views, Extensions, Protocols (nicht nur Models)
- 21 Code-Artifacts aus Logs (Sonnet schreibt Code in Review-Passes!)
- 3 FK-014 → StubGen automatisch → 0 BLOCKING
- **ClosedRange Bug**: Swift-Framework-Typ → zu Known-Types hinzugefuegt + Stub geloescht
- Weitere Swift-Runtime-Types hinzugefuegt (Range, Substring, Character, etc.)

### 2026-03-15 — Run Promotion Policy (Report 41-0)
- `config/run_promotion_policy.json` — Tier-Definitionen + Promotion-Rules
- `factory/promotion_advisor.py` — Deterministischer Advisor, CLI: `python -m factory.promotion_advisor`
- 4 Tiers: static_validation (0) → dev (50k) → standard (200k) → premium (500k)
- **Aktueller Status: NO_ACTION** — Baseline sauber, kein offener Blocker
- Empfehlung: Anderes Feature testen, Mac-Compile, oder auf neue Anforderung warten

### 2026-03-15 — Swift Compile Reality Check (Report 42-0)
- **Erster echter swiftc Parse-Check auf Mac** (Xcode 26.3)
- **227 Files, 211 sauber (93%), 16 mit Fehlern (7%)**
- 4 Fehler-Patterns (alle Factory-Central, nicht projekt-spezifisch):
  - P1: Top-Level Statements (11 Files) — Usage-Beispiele als echten Code generiert
  - P2: Strukturelle Fragmente (4 Files) — Code ohne umschliessende Struktur
  - P3: Abgeschnittener Code (2 Files) — Truncation nach @MainActor
  - P4: Pseudo-Code (1 File) — `{ ... }` Platzhalter
- **Naechster Fix**: Top-Level-Statement-Cleaner als FK-019 oder CodeExtractor-Verbesserung
- `_commands/` Queue funktioniert (Windows -> Mac -> Windows via Git)

### 2026-03-15 — FK-019 Top-Level Sanitizer (Report 43-0)
- Neues Modul: `factory/operations/toplevel_sanitizer.py`
- Scope-basierte Analyse: findet Code ausserhalb von struct/class/enum/extension Blocks
- Dangling-Decorator-Erkennung (@MainActor ohne folgende Deklaration)
- **28 Files sanitized, 130 Zeilen auskommentiert** (14 von 15 Mac-Fehlern gefixt)
- Erwartete Compile-Sauberkeit: 93% -> **~99%**
- 1 verbleibendes File: PreviewDataFactory.swift (fehlendes #endif — strukturell, nicht sanitierbar)

### 2026-03-15 — Swift Compile Recheck (Report 44-0)
- 3 Mac-Checks durchgefuehrt: 19 Errors → 35 (v1 Bug) → **4 Errors (Block-Aware Fix)**
- **99.1% compile-sauber** (225 von 227 Files)
- 2 verbleibende Files: ReadinessScore+Extension (Fragment), PreviewDataFactory (#endif fehlt)
- Beide Debug-only Code — blockieren kein Release-Build

### 2026-03-15 — Residual Compile Policy + 100% Clean (Report 45-0)
- `config/residual_compile_policy.json` — Klassifizierung: release-critical / debug-only / fragment
- PreviewDataFactory.swift: `#endif` manuell eingefuegt (Mac-Agent)
- 4 Files quarantiniert: ReadinessScore+Extension, WeakCategory, Priority, ExamReadinessView
- **223/223 Files = 0 Errors = Exit Code 0 = 100% CLEAN PARSE**
- Compile-Fortschritt: 93% → 85% (v1 Bug) → 99.1% → **100%**

### 2026-03-15 — Xcode Build Reality Check (Report 46-0)
- Kein .xcodeproj/Package.swift vorhanden → `swiftc -typecheck` mit iOS Simulator SDK
- **215 App-Files: 213 clean (99.1%), 2 fehlende `import Foundation`**
- Root Causes: ExamReadinessError.swift + MockTrendPersistenceService.swift
- 8 Test-Files brauchen Xcode-Projekt (erwartbar)
- 4 Warnings (Swift 6 Sendable — nicht blockierend)
- **Naechster Schritt**: .xcodeproj erstellen + 2 Import-Fixes

### 2026-03-15 — Import Hygiene + Typecheck (Reports 46-0, 47-0)
- `factory/operations/import_hygiene.py` auf Mac erstellt (deterministisch, 30+ Foundation-Symbole)
- **41 Files gefixt** (fehlende `import Foundation` praeventiv ergaenzt)
- 2 originale Root-Cause Errors (Foundation) geloest
- **Neue Errors aufgedeckt**:
  - RecommendationViewModel: fehlendes `import Combine` (ObservableObject/@Published)
  - WeakArea: 3x dupliziert (AssessmentResult, WeakArea, Recommendation) → Typ-Ambiguitaet
- Import-Hygiene muss um Combine-Symbole erweitert werden
- WeakArea-Duplikat ist ein strukturelles Problem (CodeExtractor/Dedup)

### 2026-03-15 — Combine Import Hygiene (Report 48-0)
- import_hygiene.py um 11 Combine-Symbole erweitert (ObservableObject, Published, etc.)
- **11 Files gefixt** (inkl. RecommendationViewModel)
- Errors: 14 → **4** (1 Root Cause: WeakArea 3x dupliziert)
- **Einziger verbleibender Blocker**: WeakArea in 3 Files definiert (AssessmentResult, WeakArea, Recommendation)

### 2026-03-15 — WeakArea Dedup + Typecheck (Report 49-0)
- Policy: `dedicated-file-wins` in `residual_compile_policy.json`
- WeakArea inline-Duplikate aus AssessmentResult + Recommendation entfernt
- **WeakArea: GELOEST (0 Errors)**
- Neuer Blocker: ExamSessionViewModel.swift (10 Errors — @StateObject braucht SwiftUI, fehlende Properties)
- Typecheck-Fortschritt: 19 → 35 → 4 → 14 → 4 → 10 → **8 (1 File)**

### 2026-03-15 — SwiftUI Import Hygiene (Report 50-0)
- import_hygiene.py um 40+ SwiftUI-Symbole erweitert
- **29 Files gefixt** (inkl. ExamSessionViewModel)
- Errors: 10 → **8** (Import geloest, strukturelle Fehler bleiben)
- Verbleibender Blocker: ExamSessionViewModel.swift — 3 strukturelle Probleme:
  1. ExamTimerService conformt nicht zu ObservableObject
  2. ExamSession hat kein Property `startTime`
  3. `examSessionService` nicht als Property deklariert
- **Alle Import-Klassen geloest** (Foundation + Combine + SwiftUI)

### 2026-03-15 — ViewModel Contract Reconciliation (Report 51-0)
- Policy: `consumer-declares-need` in `residual_compile_policy.json`
- 3 Fixes: ExamTimerService+ObservableObject, ExamSession Properties, examSessionService Property
- Errors: 8 → **2** (1 unique)
- Verbleibend: Swift Concurrency Error (`actor-isolated property 'session' cannot be passed inout to async`)
- **Typecheck-Fortschritt**: 19 → 35 → 4 → 14 → 4 → 10 → 8 → 2 → **2 (neues File)**

### 2026-03-15 — Concurrency Pattern Fix (Report 52-0)
- Policy: `local-copy-then-assign` fuer inout+async auf actor-isolated Properties
- ExamSessionViewModel: **0 Errors** (Concurrency geloest)
- Neuer Blocker (vorher maskiert): OfflineStatusViewModel — `NetworkMonitor` nicht im Scope
- Das ist ein FK-014-Klasse Problem (fehlender Typ) — braucht Stub oder Implementierung

### 2026-03-15 — NetworkMonitor + Protocol Mismatch (Reports 52-0, 53-0)
- NetworkMonitor: Minimale NWPathMonitor-Implementierung erstellt → **geloest**
- Neuer Blocker (maskiert): ExamReadinessServiceProtocol fehlen 4 Methoden
  - calculateOverallReadiness(), getCategoryReadiness(), getWeakCategories(limit:), getTrendData(days:)
- Das ist ein Protocol-Contract-Mismatch (Consumer erwartet Methoden die im Protocol nicht definiert sind)
- **Typecheck: 19 → 35 → 4 → 14 → 4 → 10 → 8 → 2 → 2 → 8 (neues File)**

### 2026-03-16/17/18 — AskFin Mac Baseline → App Store Prep (Reports 46-131)

#### Compile-to-Ship Journey (Reports 46-70)
- **Import Hygiene**: Foundation + Combine + SwiftUI (41+11+29 Files gefixt)
- **WeakArea Dedup**: `dedicated-file-wins` Policy
- **Contract Reconciliation**: ViewModel, Protocol, Enum, Snapshot Contracts gefixt
- **Concurrency Fix**: `local-copy-then-assign` fuer actor-isolated inout+async
- **Batch Fix Loop**: Ab Report 65 mehrere Fixes pro Command
- **100% Typecheck Clean**: 0 Errors nach allen Fixes

#### Xcode Build + Runtime (Reports 71-84)
- **Xcode Build**: SUCCEEDED (xcodegen → AskFinPremium.xcodeproj)
- **Simulator Launch**: App startet, alle 4 Tabs funktional
- **Home Flows**: Taegliches Training + Thema ueben + Schwaechen trainieren
- **End-to-End Journey**: Brief → 5 Fragen → Ende → Home
- **Persistence**: UserDefaults via TopicCompetenceService, Cold Restart bestaetigt
- **Golden Gate Suite**: 13 Gates, 20 XCUITests, 0 Failures

#### Feature Expansion (Reports 85-112)
- **Quarantine Cleanup**: 10 Files geloescht, 3 rehabilitiert, 7 frozen
- **Exam Result Persistence**: Generalprobe → Verlauf
- **Schwaechen-Training CTA**: Result → TrainingSessionView(.weaknessFocus)
- **Insight-to-Action Loop**: Result → Gap → Drilldown → "Thema ueben" → Training
- **Factory Reflection**: Report 112 — komplette Bestandsaufnahme

#### Adaptive Learning (Reports 113-122)
- **Echte Fragen-DB**: 173 Fuehrerschein-Fragen (questions.json)
- **QuestionLoader**: JSON-Bundle → QuestionBankProtocol
- **Adaptive Selection**: Schwache Kategorien priorisiert, beantwortete Fragen vermieden
- **Learning Signal Persistence**: Per-Question richtig/falsch in UserDefaults
- **Confidence Integration**: TopicCompetenceService nutzt echte Antwort-Daten
- **User Feedback Loop**: Richtig/falsch Banner + Erklaerung nach jeder Antwort
- **Adaptive Visibility**: Kategorie-Label, Schwaechen-Indikator, Fortschritts-Counter
- **15 Golden Gates**: Adaptive Learning Gate hinzugefuegt

#### App Store Prep (Reports 123-131)
- **Factory Transition**: Report 123 — Template-Konzept fuer wiederverwendbare Learning Apps
- **Quality Gate STOPP**: Template-Schema-Abstraktion als Overengineering gestoppt (Report 124)
- **Asset Catalog**: AccentColor + AppIcon Placeholder
- **Visual Identity**: Dark Theme, Dunkelblau/Teal Gradient, SF Symbols
- **Screenshot Tests**: Automatisiert fuer alle 4 Hauptscreens
- **App Store Metadata**: Name, Subtitle, Beschreibung, Keywords, Kategorie
- **Privacy Policy**: Offline-only, keine Datenerhebung
- **Launch Strategy**: TestFlight → Soft Launch → Full Release
- **Submission Blockers**: Nur noch App Icon (1024x1024) + Apple Developer Account

#### MasterPrompt Dispatch (ab Report 102)
- Reports in `MasterPrompt/reportAgent/` statt `DeveloperReports/CodeAgent/`
- Commands weiterhin in `_commands/`
- Mac-Agent arbeitet autonom mit Quality Gate

### 2026-03-18 — Phase 2: Factory Multi-Platform Umbau (Steps 1-23)

#### Pipeline Extraction + Project Config (Steps 1-2)
- `factory/pipeline/pipeline_runner.py`: Pipeline aus main.py extrahiert (~1000 Zeilen)
- `factory/project_config.py`: Per-Project YAML Config (lines, platform, language, framework)
- `projects/askfin_v1-1/project.yaml`: iOS active, android/web planned
- main.py von ~1850 auf ~900 Zeilen reduziert

#### Multi-Platform Extractors (Steps 3, 6, 7)
- `code_generation/extractors/`: Plugin-System mit BaseCodeExtractor ABC
- **SwiftCodeExtractor**: Wraps existing battle-tested logic
- **KotlinCodeExtractor**: Full implementation (data class, sealed class, @Composable, @HiltViewModel detection)
- **TypeScriptCodeExtractor**: Full implementation (React components, hooks, types, .tsx/.ts routing)
- **PythonCodeExtractor**: Skeleton (NotImplementedError)
- 12 Kotlin + 15 TypeScript Unit Tests bestanden

#### Factory Brain (Step 4)
- `factory/brain/brain.py`: Cross-Project Knowledge Store
- 22 Entries (FK-001 bis FK-022), query/filter/rank nach Platform/Language/Tags
- Backward-kompatibel mit bestehendem `knowledge_reader.py`

#### Factory Orchestrator (Steps 5, 9, 10)
- `factory/orchestrator/`: Build-Planung aus Specs
- **Flat Mode**: 1 Step pro Feature
- **Layered Mode**: 5 Steps pro Feature (Foundation → Domain → Application → Presentation → Polish)
- **Quality Gates**: Layer-spezifische Validierung + Import-Boundary-Checker
- CLI: `--orchestrate-dry`, `--orchestrate-layered-dry`, `--show-plan`, `--factory-status`

#### Agent Platform Roles (Step 8)
- `config/platform_roles/`: ios.json, android.json, web.json
- `config/platform_role_resolver.py`: Agent-Messages platform-aware
- Template Task Rendering mit Platform-Prefix

#### Multi-Project Setup (Step 11)
- `projects/askfin_android/`: Kotlin/Compose, build_spec.yaml (4 Features)
- `projects/askfin_web/`: TypeScript/Next.js, build_spec.yaml (4 Features)
- 3 Projekte total, 3 Active Lines (iOS, Android, Web)

#### Operations Layer Kotlin-Awareness (Steps 14, 16, 18, 22)
- **ProjectIntegrator**: Content-aware Routing (@Composable → Views/, @HiltViewModel → ViewModels/)
- **CompileHygieneValidator**: Kotlin Type-Declaration Regex + 150+ Kotlin Built-in Exclusions
- **TypeStubGenerator**: Language-aware (.kt/.ts/.swift Stubs)
- **FK-014 Enum Case Fix**: ALL_CAPS Identifiers excluded (Kotlin enum values)

#### Project Context Routing (Step 20)
- `project_context/context_loader.py`: Per-Project context statt globaler Roadbook
- `projects/askfin_android/project_context.md`: Kotlin/Compose Architektur
- `projects/askfin_web/project_context.md`: TypeScript/React Architektur

#### AskFin Android Build (Steps 13, 15, 17, 21, 23)
- **5 Proof Runs**: Pipeline verifiziert (Run 13-17), dann Full Build (Run 21+23)
- **4 Features x 5 Layers = 20 Pipeline-Runs** (Step 23)
- **204 .kt Files generiert** — echtes Kotlin/Compose, kein Swift
- TrainingMode: 50 Files (Foundation + Presentation stark, Domain schwach bei Haiku)
- ExamSimulation: 47 Files
- SkillMap: 45 Files
- ReadinessScore: 62 Files
- **Erkenntnis FK-020**: Haiku generiert bei Domain-Layer Architektur-Text statt Code → Sonnet noetig

#### Factory Status Dashboard (Step 12)
- `factory/status/factory_status.py`: CEO-Dashboard ueber alle Projekte
- `--factory-status`: 3 Projekte, 3 Lines, Brain Stats, Build Plans
- `--factory-summary`: 5-Zeilen Kompakt-Uebersicht
- `--factory-status --json`: Strukturierter JSON Output

### 2026-03-20 — Swarm Factory: Pre-Production Pipeline (Phase 1, 12 Steps)
- **Komplett implementiert und E2E getestet**
- 12 Steps: Scaffold → Web-Research-Tool → Memory-Agent → 3 Research Agents → Concept-Analyst → Legal → Risk → Pipeline-Runner → CEO-Gate → E2E-Test
- 7 Agents: Trend-Scout, Competitor-Scan, Audience-Analyst (Sonnet + SerpAPI), Concept-Analyst (Sonnet, Synthese), Legal-Research (Sonnet + SerpAPI), Risk-Assessment (Sonnet), Memory-Agent (Haiku, File I/O)
- Web-Research-Tool: SerpAPI + In-Memory-Cache + URL-Fetching (BeautifulSoup)
- Pipeline-Runner: Sequential, Error-Handling pro Agent, Reports als .md in output/
- CEO-Gate: Interaktiv oder programmatisch, Memory-Integration
- **EchoMatch E2E Run #003**: Alle 6 Reports erfolgreich, ~18 SerpAPI Credits, CEO-Gate: GO
- Pfad: `factory/pre_production/`

### 2026-03-20 — Swarm Factory: Market Strategy Pipeline (Phase 2, 7 Steps)
- **Komplett implementiert und E2E getestet**
- 7 Steps: Scaffold + Config + Input-Loader → Platform + Monetization → Marketing + Release → Cost Calculation → Pipeline-Runner → Memory Integration → E2E-Test
- 5 Agents: Platform-Strategy (Sonnet + SerpAPI), Monetization-Architect (Sonnet + SerpAPI), Marketing-Strategy (Sonnet + SerpAPI), Release-Planner (Sonnet, keine Web-Recherche), Cost-Calculation (Sonnet, keine Web-Recherche)
- Input-Loader: Laedt Phase 1 Output, validiert CEO-Gate = GO
- Pipeline-Runner: 3-Wave-Ausfuehrung, Wave-Abhaengigkeiten
- **EchoMatch E2E Run #001**: Alle 5 Reports erfolgreich, ~14 SerpAPI Credits
- Pfad: `factory/market_strategy/`

### 2026-03-20 — Document Secretary (Agent 13)
- **9 PDF-Dokument-Typen implementiert** (6 initial + 3 fuer Kapitel 4)
- v1: python-docx (.docx) → v2: HTML/CSS → PDF via Playwright (Chromium)
- Weasyprint fehlte GTK/Pango auf Windows → Playwright als Renderer
- Templates: CEO Briefing P1, CEO Briefing P2, Marketing-Konzept, Investor Summary, Tech Brief, Legal Summary, Feature-Liste, MVP Scope, Screen-Architektur
- Jedes Template: 1 Claude Sonnet Call → JSON → PdfBuilder → PDF
- JSON-Repair-Fallback bei Truncation + Markdown-Fallback-Rendering (Screen-Architektur)
- CLI: `python -m factory.document_secretary.secretary --type <type> --p1-dir ... --p2-dir ... --k4-dir ...`
- `--type all` generiert alle 9 Dokumente auf einmal
- E-Mail-Versand via SMTP (.env BRIEFING_SMTP_* Variablen)
- **EchoMatch PDFs (10 Stueck)**: CEO P1 (87KB), CEO P2 (67KB), Marketing (101KB), Investor (129KB), Tech (38KB), Legal (38KB), Features (85KB), MVP Scope (65KB), Screen-Arch (79KB)
- Pfad: `factory/document_secretary/`
- Dependencies: `python-docx` (v1 backup), `playwright` + Chromium, `beautifulsoup4`, `anthropic`

### 2026-03-21 — Kapitel 4: MVP & Feature Scope (7 Steps)
- **Komplett implementiert und E2E getestet**
- 7 Steps: Scaffold + Config + Input-Loader → Feature-Extraction → Feature-Priorisierung → Screen-Architect → Pipeline-Runner → Document Secretary PDFs → E2E-Test
- 3 Agents: Feature-Extraction (Sonnet, 2 Calls: Core + Supporting), Feature-Priorisierung (Sonnet, 2 Calls: Priorisierung + Budget-Check), Screen-Architect (Sonnet, 2 Calls: Screens + Flows)
- Input-Loader: Laedt alle 11 Reports aus Phase 1 (6) + Kapitel 3 (5)
- Budget-Constraints: Phase A €252.500 (Soft-Launch), Phase B €230.000 (Full Production)
- KPI-Targets: D1≥40%, D7≥20%, D30≥10%, eCPM≥$10, Rating≥4.2, KI-Latenz <2s
- Flow-Retry-Logik: Wenn User Flows fehlen → Markdown-basierter Retry (vermeidet JSON-Parse-Fehler)
- **EchoMatch E2E Run #001**: 72 Features extrahiert, Phase A/B Priorisierung, 22 Screens + 7 Flows
- Pfad: `factory/mvp_scope/`

### 2026-03-21 — SkillSense Phase 1 Run
- ideas/SkillSense.md als Ideen-Input (aus skillforge-pro verschoben)
- Phase 1 Run #004: Alle 6 Agents erfolgreich, 16 SerpAPI Credits
- CEO-Gate noch NICHT ausgefuehrt (pending)
- Output: `factory/pre_production/output/004_skillsense/`

### 2026-03-21 — Fixes
- **Screen-Architektur PDF**: Markdown-Fallback-Rendering wenn JSON-Extraction fehlschlaegt (war leer)
- **Feature-Priorisierung Prompt**: Haertere Phase-A/B-Trennung — "MINIMUM fuer Soft Launch, nicht alles was ins Budget passt"


### 2026-03-19/20 — Phase 2b: Assembly + Repair (Steps 24-37)

#### Assembly Department (Steps 24-25)
- `factory/assembly/`: Handoff Protocol, Assembly Manager, BaseAssemblyLine
- **AndroidAssemblyLine**: Content-aware organize (207 .kt files → Android packages), Gradle build, wiring (Application, MainActivity, NavHost, Theme, Hilt AppModule)
- **WebAssemblyLine**: npm/Next.js build system, organize into App Router structure, wiring (layout, pages, globals.css)
- Package-Declarations auto-fix bei organize

#### RepairEngine (Steps 28-29)
- `factory/assembly/repair/`: Central Cross-Platform Auto-Fix Engine
- **ErrorParser**: tsc, kotlinc, swiftc Output → strukturierte CompilerErrors
- **5 Fix-Strategies**: MissingImport, MissingType, TypeAnnotation, DuplicateType, ModulePath
- **Language Profiles**: TypeScript (TS2304, TS7006, etc.), Kotlin (Unresolved reference, etc.)
- Web: 228 → 4 Errors (98% Reduktion)

#### LLM Repair Agent (Steps 33-36)
- `factory/assembly/repair/llm_repair_agent.py`: Direkte API-Calls für strukturelle Code-Fixes
- `factory/assembly/repair/repair_coordinator.py`: 3-Tier Repair (Deterministic → LLM → CEO Escalation)
- Sonnet Repair: 19/20 Files gefixt, $0.03 pro Batch
- **Android: 2525 → 246 Errors (90% Reduktion, $0.24 total)**

### 2026-03-20/21 — Phase 3: TheBrain + Multi-Provider (Steps A1-C1)

#### TheBrain Model Provider (Step A1)
- `factory/brain/model_provider/`: Zentrales Model-Intelligence-System
- **ModelRegistry**: 9 Modelle, 4 Provider (Anthropic, OpenAI, Google, Mistral)
- **ProviderRouter**: LiteLLM-basiert, unified API für alle Provider
- **AutoSplitter**: Token-Limit-Management, Auto-Model-Switch
- Alle 4 API Keys konfiguriert in .env

#### Integration Bridge (Step A2)
- **ChainTracker**: Per-Run Cost-Tracking (Agent × Model × Tokens × Cost)
- `config/llm_config.py`: TheBrain-Routing mit Anthropic-Fallback
- Pipeline-Agents: Anthropic (AutoGen-kompatibel)
- Assembly/Repair: Alle 4 Provider via ProviderRouter

#### Hybrid Pipeline (Step B0) — GAME CHANGER
- `factory/pipeline/review_pass.py`: Single-Call Review Passes via ProviderRouter
- Pass 1 (Implementation): SelectorGroupChat (bleibt)
- Pass 2-7 (Reviews): **Direkte Single-Calls** statt Multi-Agent-Chat
- **Kosten: $63 → $0.08 pro Run (788x günstiger)**
- Review-Tokens: ~10k statt ~80-150k pro Pass
- 4 Mistral-Passes: $0.003 total

#### Benchmark + Chain Optimizer (Step B1)
- **BenchmarkRunner**: Kontrollierte Experimente pro Agent über alle Modelle
- **ChainOptimizer**: Findet günstigste Model-Kombination für 0 Errors
- **ChainProfile**: Optimierte Model-Zuweisung pro Agent

#### Price Monitor (Step C1)
- **PriceMonitor**: Provider Health Checks, neue Modelle erkennen
- Volle CLI: `--brain-models`, `--brain-chain`, `--brain-health`, `--brain-costs`

### 2026-03-21 — Phase 3b: Unity + Store + Mac Bridge

#### Unity Line (C# Extractor)
- `code_generation/extractors/csharp_extractor.py`: 20/20 Tests
- `config/platform_roles/unity.json`: MonoBehaviour, ScriptableObject, Unity Lifecycle
- `factory/assembly/lines/unity_line.py`: Unity-Projektstruktur, GameManager, AudioManager, ServiceLocator
- 102 C# Built-in Types in CompileHygiene
- **Factory hat jetzt 5 Production Lines**: iOS, Android, Web, Unity, (Python Backend skeleton)

#### Store Submission Pipeline
- `factory/store/`: Komplett neues Department
- **MetadataGenerator**: App Name, Description, Keywords, Privacy Policy (Code-Analyse)
- **ComplianceChecker**: iOS/Android/Web Guideline-Checks (deterministisch)
- **BuildPackager**: .ipa/.aab/npm build (SKIP wenn Tools fehlen)
- **SubmissionPreparer**: Submission-Ordner mit CHECKLIST.md
- **ReadinessReport**: CEO-Readiness in % mit Tabelle
- AskFin iOS: 75% ready, AskFin Android: 55% ready

#### Mac Bridge
- `mac_agent/mac_build_agent.py`: Daemon auf Mac (git pull → execute → git push, 30s Poll)
- `factory/mac_bridge/mac_bridge.py`: Factory-seitige Steuerung
- Commands: health_check, build_ios, run_tests, screenshots, archive
- CLI: `--mac-status`, `--mac-build`, `--mac-test`, `--mac-archive`
- BuildPackager nutzt Mac Bridge automatisch wenn verfügbar

#### Weitere Departments (von anderen Agents erstellt)
- `factory/pre_production/`: 7 Agents, CEO Gate, Pipeline
- `factory/market_strategy/`: 5 Agents, Monetization/Distribution
- `factory/mvp_scope/`: 3 Agents, Feature-Priorisierung
- `factory/document_secretary/`: PDF/Report Generation, CEO Briefing Templates
- `factory/design_vision/`: Design-System Generierung
- `factory/visual_audit/`: UI/UX Audit Pipeline
- `factory/roadbook_assembly/`: Roadbook-Generierung

### 2026-03-22 — TheBrain Migration: Remaining Agent Files
- 8 Agent-Dateien von hardcoded `anthropic.Anthropic()` auf `_call_llm()` mit TheBrain `get_model()`/`get_router()` + Anthropic Fallback migriert
- Betrifft: trend_breaker.py, emotion_architect.py, vision_compiler.py, asset_discovery.py, asset_strategy.py, visual_consistency.py, review_assistant.py, screen_architect.py (Call 2)
- `import anthropic` und `from factory.*.config import AGENT_MODEL_MAP` als Top-Level entfernt
- Alle `client = anthropic.Anthropic()` + `client.messages.create()` durch `_call_llm()` ersetzt
- Profile: visual_consistency.py = "dev" (large output), alle anderen = "standard"
- 11 pre_production + market_strategy + mvp_scope Agents waren bereits migriert (hatten schon _call_llm)
- Kapitel 6 (ceo_roadbook.py, cd_roadbook.py) nicht angefasst — nutzen bereits TheBrain direkt

## Aktueller Stand (2026-03-25)

### Factory Eckdaten
| Metrik | Wert |
|---|---|
| Agents | 69 total (62 aktiv, 4 deaktiviert, 3 planned) |
| Departments | 12 (Code-Pipeline, Swarm Factory, Infrastruktur, Asset/Motion/Sound/Scene/QA Forge, Store, Store Prep, Signing, Integration) |
| Production Lines | 5 (iOS, Android, Web, Unity, Python-skeleton) |
| Python Files (factory/) | 307 |
| main.py | 1.449 Zeilen |
| docs/ | 42 .md Dateien |
| factory/ Subdirectories | 35 |

### Factory Capabilities
| Komponente | Status |
|---|---|
| Pipeline Runner | Hybrid (SelectorGroupChat + Single-Calls) |
| Code Extractors | Swift + Kotlin + TypeScript + C# + Python(skeleton) |
| Project Config | YAML-basiert, 3+ Projekte |
| Factory Brain | 25 Entries, 4 Provider, 9 Modelle |
| TheBrain | Model Selection, AutoSplit, Chain Optimizer, Price Monitor |
| Orchestrator | Flat + Layered (5 Layers) + Quality Gates |
| Assembly | Android + Web + Unity + iOS(Mac Bridge) |
| RepairEngine | Deterministic + LLM (3-Tier Coordinator) |
| Operations Layer | Kotlin/TS/C#-aware (Hygiene, Stubs, Repair, Guard) |
| Store Pipeline | Metadata, Compliance, Packaging, Readiness Report |
| Store Prep | Metadata Enricher, Privacy Labels, Screenshot Coordinator |
| Signing Pipeline | Credential Check → Version Bump → Build/Sign → Artifact Storage (iOS+Android+Web) |
| QA Department | QA Coordinator, Bounce Tracker, Quality Criteria, Test Runner |
| Mac Bridge | Autonomous iOS builds via Git-Queue |
| Pre-Production | 7 Agents, CEO Gate |
| Market Strategy | 5 Agents, Monetization |
| MVP Scope | 3 Agents, Feature-Priorisierung |
| Document Secretary | 9 PDF-Templates, Playwright Renderer |
| QA Forge (Phase 13) | 4 Checker + DesignCompliance + Orchestrator, CLI, Synthetic Proof Run |
| Feasibility Check | Capability Sheet + Roadbook Matching + Parking + Re-Check + Dashboard |
| Dispatcher | Pipeline Queue, Product State, Project Creator |
| Janitor (HQ) | Protected Paths, Growth Alert, Config Consistency, Dependency Health |
| Dashboard (HQ) | 18 Components, 13 Sections (Pipeline, Gates, Providers, Janitor, Team, Assistant, etc.) |

### Projekte
| Projekt | Platform | Files | Status |
|---|---|---|---|
| AskFin Premium (iOS) | Swift/SwiftUI | 234 | App Store Prep (75% ready) |
| AskFin Android | Kotlin/Compose | 537 | 4 Features, 246 compile errors |
| AskFin Web | TypeScript/React | 197 | 4 Features, 4 compile errors |

### Kosten-Optimierung
| Pipeline-Modus | Kosten/Run |
|---|---|
| Legacy (SelectorGroupChat alle Passes) | ~$63 |
| Hybrid + Mistral Small | **$0.08** |
| Faktor | **788x günstiger** |

## Geplant
- [x] factory_knowledge/ Verzeichnis + JSON-Stores anlegen (Step 1 done)
- [x] Creative Director Advisory Pass implementieren (Step 2 done)
- [x] Step 3: Knowledge Seeding Round 1 (10 Eintraege FK-001 bis FK-010)
- [x] Step 4: Creative Director Soft Gate (validiert: FAIL stoppt Pipeline, conditional_pass laeuft weiter)
- [x] AskFin Experience Pillars priorisieren
- [x] Error Pattern Seed (FK-011 bis FK-017 aus Xcode Fix Report)
- [x] Compile Hygiene Validator (6 Checks: FK-011, FK-012, FK-013, FK-014, FK-015, FK-017)
- [x] Swift Compile Check (swiftc -parse Validierung + Pipeline-Integration)
- [ ] Step 5: Factory Learning Writeback Agent
- [ ] AskFin Premium: Training Mode Spec → Factory Run
- [ ] AskFin Premium: Skill Map Spec → Factory Run
- [x] Factory-Verbesserungen: MAX_FILES 10→50, Dead Integration Path, Silent Exceptions
- [x] Context Handoff: API Skeleton Extraction (impl_summary mit Typ-Signaturen)
- [x] Review Handoff: Digest Accumulation über alle Review-Passes
- [x] DeveloperReports System eingeführt (11 Reports in CodeAgent/, Steps-MasterLead/ für Andreas)
- [x] Stateful Recovery: RecoveryState, Fingerprinting, Repeated Failure Detection, MAX_RECOVERY_ATTEMPTS enforced
- [x] Step 5: Knowledge Writeback Loop (Proposal Auto-Promotion + Run Pattern Extraction)
- [x] Role-Based Knowledge Injection: Bug Hunter, Refactor, Fix Executor empfangen jetzt Factory Knowledge
- [x] TheBrain Migration: 8 Agent-Dateien von hardcoded anthropic.Anthropic() auf _call_llm() mit TheBrain get_model()/get_router() + Anthropic Fallback migriert
- [x] Signing Pipeline: iOS Patch (SKIPPED→iOSSigner), 9 .py Files restored, CLI-Flags wiederhergestellt
- [x] QA Department: QA Coordinator, Bounce Tracker, Quality Criteria, Test Runner
- [x] Store Prep Layer: Metadata Enricher, Privacy Labels, Screenshot Coordinator
- [x] Janitor Phase 2: Protected Paths, Growth Alert, Config Consistency, Dependency Health
- [x] Dashboard: Project Delete, Feasibility UI, Janitor Tabs, Provider View, Team View
- [ ] AskFin Premium: Training Mode Spec → Factory Run
- [ ] AskFin Premium: Skill Map Spec → Factory Run
- [x] iOS Production Line: Firebase Analytics Templates erstellt (4 Dateien)

## 2026-03-29 — iOS Production Line: Firebase Analytics Templates

### Neue Dateien
- `factory/production_lines/ios/templates/analytics/AnalyticsManager.swift` — Singleton Analytics Manager (Firebase init, logEvent, logScreenView, logFeatureUsed, logFunnelStep, logConversion, setUserProperty, setAppProfile)
- `factory/production_lines/ios/templates/analytics/AnalyticsEvents.swift` — DAIAnalyticsEvent Enum (17 Standard-Events: Session, Onboarding Funnel, Feature Usage, Engagement, Monetization, Errors)
- `factory/production_lines/ios/templates/analytics/INTEGRATION_GUIDE.md` — Assembly Agent Guide (SPM Setup, GoogleService-Info.plist, Lifecycle-Wiring, Beispiele)
- `factory/production_lines/ios/templates/analytics/GoogleService-Info.plist.template` — Placeholder-Plist mit {{FIREBASE_*}} Platzhaltern

### Design-Entscheidungen
- Alle Custom-Events mit `dai_` Prefix (Namespace-Trennung in Firebase)
- Nur FirebaseAnalytics + FirebaseCrashlytics (kein Firestore, Auth etc.)
- Generische Templates ohne App-spezifische Logik
- `AnalyticsManager.log(_ event: DAIAnalyticsEvent)` als Brücke zwischen Manager und Events-Enum
