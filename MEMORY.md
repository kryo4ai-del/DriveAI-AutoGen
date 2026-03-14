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
- 21 aktive Agents, 4 deaktiviert (Android/Kotlin/Web)

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
- [ ] AskFin Premium: Training Mode Spec → Factory Run
- [ ] AskFin Premium: Skill Map Spec → Factory Run
