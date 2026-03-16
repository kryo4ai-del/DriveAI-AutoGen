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
│   └── askfin_v1-1/                 ← AskFin Premium iOS App (~170 Swift Files)
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
│   ├── operations/                  ← Post-Generation Validierung + Auto-Repair
│   │   ├── compile_hygiene_validator.py  ← FK-011 bis FK-017 (Column-aware, Memberwise-Init)
│   │   ├── swift_compile_check.py        ← swiftc -parse Validierung
│   │   ├── output_integrator.py          ← Code-Integration + Type-Level Dedup + Markdown Sanitization
│   │   ├── completion_verifier.py        ← Vollstaendigkeitspruefung
│   │   ├── type_stub_generator.py        ← Auto-Stub fuer FK-014 fehlende Typen
│   │   ├── property_shape_repairer.py    ← Auto-Repair fuer FK-013 Struct-Property-Mismatches
│   │   ├── recovery_runner.py            ← Automatische Reparatur
│   │   └── run_memory.py                 ← Run-History
│   └── reports/                     ← Generierte Reports
│       ├── hygiene/                 ← Compile Hygiene Reports (JSON)
│       ├── compile/                 ← Swift Compile Reports (JSON)
│       ├── stubs/                   ← Type Stub Reports (JSON)
│       └── shape_repairs/           ← Property Shape Repair Reports (JSON)
├── factory_knowledge/               ← Factory Knowledge System
│   ├── knowledge.json               ← 18 Eintraege (FK-001 bis FK-018)
│   ├── index.json                   ← Uebersichts-Index
│   ├── knowledge_reader.py          ← Deterministische Entry-Selektion
│   ├── proposal_generator.py        ← Run-basierte Knowledge-Kandidaten
│   └── knowledge_writeback.py       ← Feedback Loop (Auto-Promotion + Pattern Extraction)
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
- **~170 Swift Files** in `projects/askfin_v1-1/`
- **Status**: Factory-generiert, 8 Autonomy Proof Runs durchgefuehrt (2026-03-15)
- **Bearbeitung**: Mac (Xcode) + Windows (Factory/Claude Code)
- **Projekt-Inferenz**: Automatisch erkannt wenn `--project` weggelassen wird

## AI App Factory
- **21 aktive Agents** (Python, AutoGen-basiert, 100% Anthropic Claude)
- **Streamlit Control Center**: `streamlit run control_center/app.py`
- **Bearbeitung**: Windows oder Server

## Operations Layer Pipeline
```
Output Integrator → Completion Verifier → Compile Hygiene Validator
  → Type Stub Generator (FK-014) → Re-Hygiene
  → Property Shape Repairer (FK-013) → Re-Hygiene
  → Swift Compile Check → Recovery Runner → Run Memory → Knowledge Writeback
```
- **Output Integrator**: 5-Layer Dedup (Filename + Type-Level + Markdown Sanitization)
- **Compile Hygiene Validator**: 6 Checks (FK-011 bis FK-017), Column-aware, Memberwise-Init-Erkennung
- **Type Stub Generator**: Automatische Stubs fuer FK-014 (fehlende Typ-Deklarationen)
- **Property Shape Repairer**: Automatische Struct-Property-Reparatur bei FK-013 (0%-Match)
- **Swift Compile Check**: swiftc -parse Validierung — nur Mac/Linux (SKIPPED auf Windows)
- **5 Dedup-Layers**: CodeExtractor → ProjectIntegrator → OutputIntegrator Filename → OutputIntegrator Type → CompileHygiene

## Factory Knowledge System
- **18 Eintraege** (FK-001 bis FK-018)
- FK-001 bis FK-010: Product/UX Knowledge (Premium Strategy, Psychology)
- FK-011 bis FK-017: Error Patterns (aus Xcode Build Failures)
- FK-018: Auto-promoted Proposal (File Duplication, 6 Beobachtungen)
- Deterministische Selektion fuer Creative Director Review
- **Writeback Loop**: Proposals mit 2+ Beobachtungen → auto-promoted zu `validated`
- **Run Pattern Extraction**: Recurring failures + Recovery outcomes → Knowledge
- **Role-Based Injection**: Bug Hunter, Refactor, Fix Executor empfangen validated+ Knowledge

## Quality Gate (PFLICHT bei jedem Prompt)

> **Vor jeder Ausfuehrung** eines Prompts vom User oder Master Lead:
> Pruefe ob der Prompt ins aktuelle Konzept passt.

### Pruefkriterien
1. **Konzept-Konsistenz**: Passt der Prompt zur aktuellen Projektphase und Architektur?
2. **Overengineering-Check**: Fuegt der Prompt eine Schicht/Abstraktion hinzu die das Problem nicht braucht?
3. **Scope-Drift**: Weicht der Prompt vom aktuellen Fokus ab ohne erklaerten Grund?
4. **Fehler im Prompt**: Enthaelt der Prompt falsche Annahmen, veraltete Referenzen, oder widersprüchliche Anforderungen?
5. **Kosten-Nutzen**: Wird ein teurer Run/Ansatz vorgeschlagen obwohl ein guenstigerer ausreicht?

### Verhalten
- **Alles OK**: Prompt ausfuehren, kein Kommentar noetig
- **Kleinigkeit**: Kurzer Hinweis, dann trotzdem ausfuehren
- **Gravierendes Problem**: **STOPP** — Prompt NICHT ausfuehren, stattdessen:
  - Klar benennen was das Problem ist
  - Vergleich zum bestehenden Konzept/Prinzip zeigen
  - Alternativen vorschlagen (z.B. guenstigerer Ansatz, anderer Scope)
  - Entscheidung dem User ueberlassen

### Beispiele fuer STOPP
- Prompt will eine 6. Abstraktionsschicht auf ein 2-Destinations-Problem bauen
- Prompt startet einen teuren Sonnet-Run obwohl ein statischer Check reicht
- Prompt will AskFin-Files manuell patchen statt einen Factory-Layer-Fix zu bauen
- Prompt widerspricht einer bereits getroffenen Architektur-Entscheidung
- Prompt dupliziert Arbeit die ein anderer Agent bereits erledigt hat

### Prinzip
> "Small single-responsibility agents" + "avoid large monolithic systems"
> Lieber einen hoeheren Hebel finden als Micro-Layers stapeln.

## Konventionen
- Sprache mit User: Deutsch
- Commit-Messages: Englisch
- Keine unnötigen Nachfragen – einfach machen
- Alle Änderungen in CLAUDE.md + MEMORY.md dokumentieren
- `_logs/` für Mac ↔ Windows Austausch via Git

## DeveloperReports (Grundregel)
> **PFLICHT bei jedem Agent-Wechsel**: Jeder strukturierte Report wird als `.md` gespeichert.

**Ordnerstruktur**:
```
DeveloperReports/
├── CodeAgent/           ← Reports vom Code-Agent (Claude Code)
│   ├── 1-0_Factory Core Audit Report.md
│   ├── 2-0_Three Hotfixes Report.md
│   └── ...
└── Steps-MasterLead/    ← Reports vom Master Lead (Andreas)
    └── ...
```

**Nummerierung** (pro Unterordner):
- Neues Thema: `N-0_Titel.md` (nächste freie Nummer)
- Folge-Report zum gleichen Thema: `N-1_Titel.md`, `N-2_Titel.md`, ...

**Regel**: Vor dem Erstellen prüfen welche Nummer als nächstes dran ist. Reports sind dauerhaft und dienen als Projekthistorie. Code-Agent-Reports → `CodeAgent/`, Master-Lead-Steps → `Steps-MasterLead/`.

## Erledigtes
- [2026-03-15] Property Shape Repairer: FK-013 Struct-Property-Reparatur (0-Property-Structs)
- [2026-03-15] OutputIntegrator Semantic Dedup: Type-Level Dedup + Markdown Sanitization
- [2026-03-15] Compile Hygiene Truthfulness: Column-aware FK-012, Memberwise-Init FK-013
- [2026-03-15] Type Stub Generator: Automatische FK-014 Stub-Generierung
- [2026-03-15] Project Context Hardening: Auto-Inferenz aus projects/ Verzeichnis
- [2026-03-15] CD Gate Profile-Awareness: dev-profile = advisory (fail nicht blockierend)
- [2026-03-15] CD Rating Parser Fix: Agent-spezifische Extraktion statt letzter Match
- [2026-03-15] 8 Autonomy Proof Runs (Run 3-8) mit progressiver Verbesserung
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
