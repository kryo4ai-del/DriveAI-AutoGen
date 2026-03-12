# DriveAI-AutoGen - Projektkontext

## Projektübersicht
- **Name**: DriveAI-AutoGen (AI App Factory + AskFinn iOS App)
- **Typ**: Multi-Agent AI System (Python) + SwiftUI iOS App (Swift)
- **Repo**: GitHub `kryo4ai-del/DriveAI-AutoGen`
- **Lokal Windows**: `C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\`
- **Lokal Mac**: `/Users/andreasott/DriveAI-AutoGen/`
- **Besitzer**: Andreas Ott

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
├── config/                          ← Konfiguration (agent_toggles, cost_budgets, etc.)
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

## AskFinn iOS App
- **Bundle ID**: com.kryo4ai.AskFinn
- **Target**: iOS 26.3, iPhone 17 Pro Simulator
- **Status**: BUILD SUCCEEDED (2026-03-12)
- **Bearbeitung**: Nur auf Mac in Xcode
- **Pfad im Repo**: `DriveAI/DriveAI/AskFinn/`

## AI App Factory
- **23 Agents** (Python, AutoGen-basiert)
- **Streamlit Control Center**: `streamlit run control_center/app.py`
- **Bearbeitung**: Windows oder Server
- **Server**: `root@192.168.178.122` → `/opt/trading-projekt/` (Crypto Screener)

## Konventionen
- Sprache mit User: Deutsch
- Commit-Messages: Englisch
- Keine unnötigen Nachfragen – einfach machen
- Alle Änderungen in CLAUDE.md dokumentieren
- `_logs/` für Mac ↔ Windows Austausch via Git

## Erledigtes
- [2026-03-12] Projekt bereinigt: alte DriveAI-Duplikate gelöscht, nur AskFinn bleibt
- [2026-03-12] Projekt analysiert, Strukturproblem mit verschachteltem Git-Repo identifiziert
- [2026-03-12] 68 AutoGen-Logs analysiert → 3 kritische Factory-Schwachstellen identifiziert
- [2026-03-12] Factory erweitert: AutoResearchAgent, ResearchMemoryGraph, StrategyReportAgent
