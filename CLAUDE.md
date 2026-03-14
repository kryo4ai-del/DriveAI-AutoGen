# DriveAI-AutoGen - Projektkontext

## Projektübersicht
- **Name**: DriveAI-AutoGen (AI App Factory + AskFin iOS App)
- **Typ**: Multi-Agent AI System (Python) + SwiftUI iOS App (Swift)
- **Repo**: GitHub `kryo4ai-del/DriveAI-AutoGen`
- **Lokal Windows**: `C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\`
- **Lokal Mac**: `/Users/andreasott/DriveAI-AutoGen/`
- **Besitzer**: Andreas Ott

## Tech-Stack
- **LLM Provider**: Anthropic Claude (100% — kein OpenAI mehr)
- **Modelle**: claude-sonnet-4-6 (Tier 1+2), claude-haiku-4-5 (Tier 3)
- **Premium**: claude-opus-4-6 (bei Bedarf)
- **Framework**: Python + AutoGen AgentChat v0.4+
- **API Key**: `ANTHROPIC_API_KEY` in `.env`

## 3-Tier Modell-System
| Tier | Modell | Aufgaben |
|---|---|---|
| 1 (Code) | claude-sonnet-4-6 | code_generation, architecture, code_review, bug_hunting, refactoring, test_generation |
| 2 (Reasoning) | claude-sonnet-4-6 | planning, orchestration, content, compliance, accessibility |
| 3 (Lightweight) | claude-haiku-4-5 | classification, summarization, trend_analysis, scoring, labeling, extraction, briefing |

## Projektstruktur
```
DriveAI-AutoGen/
├── main.py                          ← Python Einstiegspunkt (AutoGen Pipeline)
├── CLAUDE.md                        ← Diese Datei
│
├── projects/                        ← Generierte Projekte
│   └── askfin_v1-1/                 ← AskFin Premium iOS App (75 Swift Files)
│       ├── App/                     ← App Entry Point
│       ├── Models/                  ← Swift Datenmodelle
│       ├── Services/                ← Business Logic
│       ├── ViewModels/              ← MVVM ViewModels
│       └── Views/                   ← SwiftUI Views
│
├── agents/                          ← AI Agenten (Python, AutoGen)
├── config/                          ← Konfiguration
│   ├── llm_config.py               ← LLM Config (Anthropic + Ollama)
│   ├── llm_profiles.json           ← 3 Profile: dev/standard/premium
│   ├── model_router.py             ← 3-Tier Routing (Sonnet + Haiku)
│   ├── agent_toggles.json          ← 21 aktiv, 4 deaktiviert
│   └── agent_roles.json            ← Agent System Messages
├── factory/                         ← Factory Operations Layer
│   ├── operations/                  ← Post-Generation Validierung
│   │   ├── compile_hygiene_validator.py  ← FK-011 bis FK-017 (Regex)
│   │   ├── swift_compile_check.py        ← swiftc -parse Validierung
│   │   ├── output_integrator.py          ← Code-Integration
│   │   ├── completion_verifier.py        ← Vollstaendigkeitspruefung
│   │   ├── recovery_runner.py            ← Automatische Reparatur
│   │   └── run_memory.py                 ← Run-History
│   └── reports/                     ← Generierte Reports
│       ├── hygiene/                 ← Compile Hygiene Reports (JSON)
│       └── compile/                 ← Swift Compile Reports (JSON)
├── factory_knowledge/               ← Factory Knowledge System
│   ├── knowledge.json               ← 17 Eintraege (FK-001 bis FK-017)
│   ├── index.json                   ← Uebersichts-Index
│   ├── knowledge_reader.py          ← Deterministische Entry-Selektion
│   └── proposal_generator.py        ← Run-basierte Knowledge-Kandidaten
├── factory_strategy/                ← Commercial Strategy Generator
├── control_center/                  ← Streamlit Dashboard (19 Pages)
├── briefings/                       ← Daily Briefing Agent
├── strategy/                        ← Weekly Strategy Reports
├── research/                        ← Auto Research Agent
├── research_graph/                  ← Knowledge Graph (Nodes + Edges)
├── docs/                            ← Dokumentation
├── _logs/                           ← Shared Logs (Mac ↔ Windows via Git)
└── venv/                            ← Python Virtual Environment
```

## Agents (21 aktiv / 4 deaktiviert)

### Aktive Agents
| Agent | Task Type | Modell |
|---|---|---|
| driveai_lead | planning | Sonnet |
| ios_architect | architecture | Sonnet |
| swift_developer | code_generation | Sonnet |
| reviewer | code_review | Sonnet |
| bug_hunter | bug_hunting | Sonnet |
| refactor_agent | refactoring | Sonnet |
| test_generator | test_generation | Sonnet |
| creative_director | advisory_review | Sonnet |
| ux_psychology | advisory_review | Sonnet |
| product_strategist | classification | Haiku |
| roadmap_agent | planning | Sonnet |
| content_script_agent | content_generation | Sonnet |
| change_watch_agent | trend_analysis | Haiku |
| accessibility_agent | accessibility_review | Sonnet |
| opportunity_agent | trend_analysis | Haiku |
| legal_risk_agent | compliance_review | Sonnet |
| project_bootstrap_agent | planning | Sonnet |
| autonomous_project_orchestrator | orchestration | Sonnet |

### Deaktiviert (nicht benötigt für iOS-only)
- android_architect, kotlin_developer, web_architect, webapp_developer

## AskFin Premium iOS App (askfin_v1-1)
- **Typ**: SwiftUI MVVM Coaching App (nicht Scanner Tool)
- **4 Pillars**: Training Mode, Exam Simulation, Skill Map, Readiness Score
- **75 Swift Files** in `projects/askfin_v1-1/`
- **Status**: Factory-generiert, Xcode-Compile-Fixes auf Mac durchgefuehrt (2026-03-13)
- **Bearbeitung**: Mac (Xcode) + Windows (Factory/Claude Code)

## AI App Factory
- **21 aktive Agents** (Python, AutoGen-basiert, 100% Anthropic Claude)
- **Streamlit Control Center**: `streamlit run control_center/app.py`
- **Bearbeitung**: Windows oder Server

## Operations Layer Pipeline
```
Output Integrator → Completion Verifier → Compile Hygiene Validator → Swift Compile Check → Recovery Runner → Run Memory
```
- **Compile Hygiene Validator**: 6 Regex-Checks (FK-011 bis FK-017) — laeuft ueberall
- **Swift Compile Check**: swiftc -parse Validierung — nur Mac/Linux (SKIPPED auf Windows)

## Factory Knowledge System
- **17 Eintraege** (FK-001 bis FK-017)
- FK-001 bis FK-010: Product/UX Knowledge (Premium Strategy, Psychology)
- FK-011 bis FK-017: Error Patterns (aus Xcode Build Failures)
- Deterministische Selektion fuer Creative Director Review

## Konventionen
- Sprache mit User: Deutsch
- Commit-Messages: Englisch
- Keine unnötigen Nachfragen – einfach machen
- Alle Änderungen in CLAUDE.md + MEMORY.md dokumentieren
- `_logs/` für Mac ↔ Windows Austausch via Git

## Erledigtes
- [2026-03-14] Swift Compile Check: swiftc-basierte Syntax-Validierung + Pipeline-Integration
- [2026-03-14] Compile Hygiene Validator Round 3: FK-013, FK-014, FK-017 (6 Checks total)
- [2026-03-14] Compile Hygiene Validator Round 2: FK-011, FK-012, FK-015
- [2026-03-14] Factory Knowledge Error Patterns: FK-011 bis FK-017 aus Xcode Fix Report
- [2026-03-14] Repo bereinigt: DriveAI/, DriveAi-AutoGen/ geloescht, AskFin Premium nach projects/askfin_v1-1/
- [2026-03-13] UX Psychology Review Layer + UX Knowledge Seed (FK-007 bis FK-010)
- [2026-03-13] Creative Director Soft Gate + Advisory Pass
- [2026-03-13] Commercial Strategy Generator + AskFin Premium Projekt
- [2026-03-12] Premium Product Strategy: 5 strategische Docs
- [2026-03-12] Komplette Migration OpenAI GPT → Anthropic Claude (3-Tier System)
- [2026-03-12] Factory erweitert: AutoResearchAgent, ResearchMemoryGraph, StrategyReportAgent
- [2026-03-12] Pipeline Reliability: team.reset(), _run_with_retry(), Implementation Summary
