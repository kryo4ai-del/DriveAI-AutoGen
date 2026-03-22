# DriveAI-AutoGen - Projektkontext

## Projektübersicht
- **Name**: DriveAI-AutoGen (Multi-Platform AI App Factory + TheBrain)
- **Typ**: Multi-Agent AI System (Python) + iOS/Android/Web App Generation
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
│   ├── askfin_v1-1/                 ← AskFin Premium iOS App (234 Swift Files)
│   ├── askfin_android/              ← AskFin Android (204 Kotlin Files)
│   └── askfin_web/                  ← AskFin Web (TypeScript/React, Spec ready)
│
├── factory/                         ← Factory Core
│   ├── pipeline/                    ← Extrahierter Pipeline Runner
│   ├── orchestrator/                ← Build-Planer (flat + layered + quality gates)
│   ├── brain/                       ← Cross-Project Knowledge Store (22 FK Entries)
│   ├── operations/                  ← Post-Generation Validierung + Auto-Repair
│   ├── status/                      ← Factory Status Dashboard
│   ├── pre_production/              ← Swarm Factory Phase 1: Pre-Production Pipeline
│   │   ├── agents/                  ← 7 Agents (Trend, Competitor, Audience, Concept, Legal, Risk, Memory)
│   │   ├── tools/                   ← Web Research Tool (SerpAPI + Caching)
│   │   ├── memory/                  ← Learnings + Run-Logs
│   │   ├── output/                  ← Phase 1 Reports pro Run
│   │   ├── pipeline.py              ← Phase 1 Pipeline Runner
│   │   ├── ceo_gate.py              ← Kill-or-Go Entscheidung
│   │   └── config.py                ← Agent-Model-Mapping
│   ├── market_strategy/             ← Swarm Factory Phase 2: Market Strategy Pipeline
│   │   ├── agents/                  ← 5 Agents (Platform, Monetization, Marketing, Release, Cost)
│   │   ├── output/                  ← Phase 2 Reports pro Run
│   │   ├── pipeline.py              ← Phase 2 Pipeline Runner
│   │   ├── input_loader.py          ← Laedt Phase 1 Output als Input
│   │   └── config.py                ← Agent-Model-Mapping
│   ├── mvp_scope/                   ← Swarm Factory Kapitel 4: MVP & Feature Scope
│   │   ├── agents/                  ← 3 Agents (Feature-Extraction, Priorisierung, Screen-Architect)
│   │   ├── output/                  ← Kapitel 4 Reports pro Run
│   │   ├── pipeline.py              ← Kapitel 4 Pipeline Runner
│   │   ├── input_loader.py          ← Laedt Phase 1 + Kapitel 3 Output
│   │   └── config.py                ← Agent-Mapping + Budget + KPI-Targets
│   └── document_secretary/          ← Agent 13: PDF-Dokument-Generator
│       ├── templates/               ← 9 Templates (CEO P1/P2, Marketing, Investor, Tech, Legal, Features, MVP, Screens)
│       ├── pdf_builder.py           ← HTML/CSS → PDF via Playwright
│       ├── email_service.py         ← SMTP E-Mail-Versand
│       ├── secretary.py             ← Orchestrator + CLI
│       └── output/                  ← Generierte PDFs
│
├── agents/                          ← AI Agenten (Python, AutoGen)
├── config/                          ← Konfiguration
├── factory_knowledge/               ← Factory Knowledge System (22 Entries)
├── code_generation/                 ← Code Extractors (Swift, Kotlin, TypeScript)
├── control_center/                  ← Streamlit Dashboard (19 Pages)
├── briefings/                       ← Daily Briefing Agent
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

### Mac Baseline (Stand 2026-03-18)
- **Xcode Build**: SUCCEEDED (xcodegen, iPhone 17 Pro Simulator)
- **Golden Gates**: 15 Gates, 20+ XCUITests, 0 Failures
- **4 Pillars**: Alle runtime-validiert + gate-geschuetzt (Training, Skill Map, Generalprobe, Readiness)
- **Adaptive Learning**: Echte Fragen-DB (173 Fuehrerschein-Fragen), Confidence-basierte Selektion, Learning Signal Persistence
- **Persistence**: UserDefaults (Competence + History + Learning Signals), ueberlebt Cold Restart
- **Insight-to-Action Loop**: Generalprobe → Gap-Analyse → Drilldown → "Thema ueben" CTA → Training
- **Schwaechen-Training CTA**: Result → "Schwaechen trainieren" → TrainingSessionView(.weaknessFocus)
- **App Store Prep**: Metadata, Privacy Policy, Screenshots (automatisiert), Icon Spec — submission-ready (fehlt: Icon + Developer Account)
- **Quarantine**: 7 Files FROZEN (siehe quarantine/QUARANTINE_STATUS.md)
- **Commands**: 092 ausgefuehrt, Reports bis 131-0
- **MasterPrompt Dispatch**: Reports ab 102-0 in `MasterPrompt/reportAgent/`

- **Typ**: SwiftUI MVVM Coaching App (Fuehrerschein-Pruefungsvorbereitung)
- **4 Pillars**: Training Mode, Exam Simulation, Skill Map, Readiness Score
- **~200+ Swift Files** in `projects/askfin_v1-1/`
- **Status**: Factory-generiert, 14 Autonomy Proof Runs, App Store Prep abgeschlossen
- **Bearbeitung**: Mac (Xcode/Build/Runtime) + Windows (Factory/Prompts/Quality Gate)
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
- **22 Eintraege** (FK-001 bis FK-022)
- FK-001 bis FK-010: Product/UX Knowledge (Premium Strategy, Psychology)
- FK-011 bis FK-017: Error Patterns (aus Xcode Build Failures)
- FK-018: Auto-promoted Proposal (File Duplication, 6 Beobachtungen)
- Deterministische Selektion fuer Creative Director Review
- **Writeback Loop**: Proposals mit 2+ Beobachtungen → auto-promoted zu `validated`
- **Run Pattern Extraction**: Recurring failures + Recovery outcomes → Knowledge
- **Role-Based Injection**: Bug Hunter, Refactor, Fix Executor empfangen validated+ Knowledge

## Quality Gate
> **PFLICHT bei jedem Prompt.** Regeln: `~/.claude/docs/QUALITY-GATE.md` (zentral, projektuebergreifend).
> Gilt automatisch — Prompt Pilot prueft vor Ausfuehrung, Agents lesen die Datei direkt.

## Konventionen
- Sprache mit User: Deutsch
- Commit-Messages: Englisch
- Keine unnötigen Nachfragen – einfach machen
- Alle Änderungen in CLAUDE.md + MEMORY.md dokumentieren
- `_logs/` für Mac ↔ Windows Austausch via Git

## Reports (Grundregel)
> **PFLICHT bei jedem Command**: Zwei Dateien schreiben.

### Aktueller Report-Pfad (ab Command 062)
```
MasterPrompt/reportAgent/    ← NEUER Pfad fuer alle Reports
  102-0_Quarantine Cleanup Report.md
  103-0_ReadinessService Rehabilitation Report.md
  ...
```

### Alter Report-Pfad (Commands 001-061)
```
DeveloperReports/CodeAgent/  ← Reports 1-0 bis 101-0
```

### Bei jedem Command ausfuehren
1. `_commands/XXX_..._result.md` — Detailliertes Ergebnis
2. `MasterPrompt/reportAgent/NNN-0_Titel.md` — Kompakter Report

## DeveloperReports (alt, bis Report 101-0)
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

## Swarm Factory (Autonome Produkt-Pipeline)

### Phase 1: Pre-Production Pipeline (12 Steps — KOMPLETT)
```
CEO-Idee → Memory-Briefing → [Trend+Competitor+Audience parallel] → Concept Brief → Legal → Risk → CEO-Gate → Memory
```
- 7 Agents (6x Sonnet, 1x Haiku), Web-Recherche via SerpAPI + Caching
- Runs: EchoMatch #003 (**GO**), SkillSense #004 (Gate pending)
- Output: `factory/pre_production/output/{NNN}_{slug}/`

### Kapitel 3: Market Strategy Pipeline (7 Steps — KOMPLETT)
```
Phase-1-Input → [Platform+Monetization] → [Marketing+Release] → Cost Calculation
```
- 5 Agents (alle Sonnet), Wave-basierte Ausfuehrung
- Run: EchoMatch #001 (5 Reports)
- Output: `factory/market_strategy/output/{NNN}_{slug}/`

### Kapitel 4: MVP & Feature Scope (7 Steps — KOMPLETT)
```
Alle 11 Reports → Feature-Extraction (72 Features) → Priorisierung (Phase A/B/Backlog) → Screen-Architektur (22 Screens, 7 Flows)
```
- 3 Agents (alle Sonnet), sequentiell, kein Web-Research
- Budget-Constraints: Phase A €252.500, Phase B €230.000
- KPI-Targets: D1≥40%, D7≥20%, D30≥10%, Session 6-10min
- Flow-Retry-Logik fuer robuste User-Flow-Generierung
- Run: EchoMatch #001 (Feature-Liste + Priorisierung + Screen-Architektur)
- Output: `factory/mvp_scope/output/{NNN}_{slug}/`

### Document Secretary (Agent 13 — KOMPLETT)
- 9 PDF-Typen: CEO Briefing P1/P2, Marketing-Konzept, Investor Summary, Tech Brief, Legal Summary, Feature-Liste, MVP Scope, Screen-Architektur
- HTML/CSS → PDF via Playwright (Chromium)
- CLI: `python -m factory.document_secretary.secretary --type all --p1-dir ... --p2-dir ... --k4-dir ...`
- E-Mail-Versand via SMTP (.env Config)
- 10 PDFs generiert fuer EchoMatch (Stand 2026-03-21)

### Ideas Pipeline
- `ideas/` Ordner fuer CEO-Ideen als .md Dateien
- SkillSense.md vorhanden (Phase 1 durchgelaufen, Gate pending)
- `--idea-file ideas/SkillSense.md` fuer Pipeline-Input

## Erledigtes
- [2026-03-21] Kapitel 4 (MVP & Feature Scope) komplett: 3 Agents, EchoMatch E2E Run, 3 neue PDF-Templates
- [2026-03-21] Document Secretary: 9 PDF-Typen (3 neue: Feature-Liste, MVP Scope, Screen-Architektur)
- [2026-03-21] Screen-Architektur PDF Fix: Markdown-Fallback-Rendering bei JSON-Parse-Fehler
- [2026-03-21] Feature-Priorisierung: Haertere Phase-A/B-Trennung (MINIMUM statt alles-ins-Budget)
- [2026-03-21] SkillSense: Phase 1 Pre-Production Run #004 komplett (Gate pending)
- [2026-03-20] Swarm Factory Phase 1 + Phase 2 (Kapitel 3) + Document Secretary komplett implementiert und getestet
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
