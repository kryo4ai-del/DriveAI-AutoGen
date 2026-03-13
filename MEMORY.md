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
- 19 aktive Agents, 4 deaktiviert (Android/Kotlin/Web)

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

## Geplant
- [x] factory_knowledge/ Verzeichnis + JSON-Stores anlegen (Step 1 done)
- [x] Creative Director Advisory Pass implementieren (Step 2 done)
- [x] Step 3: Knowledge Seeding Round 1 (6 Eintraege: 1 failure_case, 1 ux_insight, 1 motivational_mechanic, 2 technical_pattern, 1 success_pattern)
- [x] Step 4: Creative Director Soft Gate (validiert: FAIL stoppt Pipeline, conditional_pass laeuft weiter)
- [ ] Step 5: Factory Learning Writeback Agent (nach Step 4)
- [ ] AskFin Experience Pillars priorisieren und erstes Feature spezifizieren
- [ ] Factory-Verbesserungen: Compiler-Feedback-Loop, Code-Extraction >10 Files, Agent-Echo-Reduktion
