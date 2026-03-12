# DriveAI-AutoGen - Projektkontext

## Projektübersicht
- **Name**: DriveAI-AutoGen (AI App Factory + AskFinn iOS App)
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
├── DriveAI/DriveAI/AskFinn/        ← iOS App (Xcode Projekt)
│   ├── AskFinn.xcodeproj/
│   └── AskFinn/
│       ├── AskFinnApp.swift
│       ├── ContentView.swift
│       ├── Assets.xcassets/
│       ├── Models/                  ← Swift Datenmodelle (82 Files)
│       ├── Services/                ← Business Logic (22 Files)
│       ├── ViewModels/              ← MVVM ViewModels (38 Files)
│       └── Views/                   ← SwiftUI Views (42 Files)
│
├── agents/                          ← AI Agenten (Python, AutoGen)
├── config/                          ← Konfiguration
│   ├── llm_config.py               ← LLM Config (Anthropic + Ollama)
│   ├── llm_profiles.json           ← 3 Profile: dev/standard/premium
│   ├── model_router.py             ← 3-Tier Routing (Sonnet + Haiku)
│   ├── agent_toggles.json          ← 19 aktiv, 4 deaktiviert
│   └── agent_roles.json            ← Agent System Messages
├── factory/                         ← Factory Layer (ideas, projects, specs)
├── control_center/                  ← Streamlit Dashboard (19 Pages)
├── briefings/                       ← Daily Briefing Agent
├── strategy/                        ← Weekly Strategy Reports
├── research/                        ← Auto Research Agent
├── research_graph/                  ← Knowledge Graph (Nodes + Edges)
├── radar/                           ← Opportunity Radar
├── trends/                          ← AI Trend Scanner
├── opportunities/                   ← Opportunity Store
├── compliance/                      ← Legal/Compliance Reports
├── accessibility/                   ← A11Y Reports
├── improvements/                    ← Factory Improvement Proposals
├── costs/                           ← AI Cost Tracking
├── memory/                          ← Agent Memory Store
├── docs/                            ← Dokumentation
├── _logs/                           ← Shared Logs (Mac ↔ Windows via Git)
└── venv/                            ← Python Virtual Environment
```

## Agents (19 aktiv / 4 deaktiviert)

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

## AskFinn iOS App
- **Bundle ID**: com.kryo4ai.AskFinn
- **Target**: iOS 26.3, iPhone 17 Pro Simulator
- **Status**: BUILD SUCCEEDED (2026-03-12)
- **Bearbeitung**: Nur auf Mac in Xcode
- **Pfad im Repo**: `DriveAI/DriveAI/AskFinn/`

## AI App Factory
- **19 aktive Agents** (Python, AutoGen-basiert, 100% Anthropic Claude)
- **Streamlit Control Center**: `streamlit run control_center/app.py`
- **Bearbeitung**: Windows oder Server

## Konventionen
- Sprache mit User: Deutsch
- Commit-Messages: Englisch
- Keine unnötigen Nachfragen – einfach machen
- Alle Änderungen in CLAUDE.md + MEMORY.md dokumentieren
- `_logs/` für Mac ↔ Windows Austausch via Git

## Erledigtes
- [2026-03-12] Komplette Migration von OpenAI GPT → Anthropic Claude (3-Tier System)
- [2026-03-12] 4 Agents deaktiviert (Android/Kotlin/Web) — iOS-only Fokus
- [2026-03-12] Projekt bereinigt: alte DriveAI-Duplikate gelöscht, nur AskFinn bleibt
- [2026-03-12] Factory erweitert: AutoResearchAgent, ResearchMemoryGraph, StrategyReportAgent
- [2026-03-12] 68 AutoGen-Logs analysiert → 3 kritische Factory-Schwachstellen identifiziert
