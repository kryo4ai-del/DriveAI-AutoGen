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

## Geplant
- [ ] Dynamic Model Upgrade Agent — entscheidet autonom ob ein Projekt ein höheres Tier braucht
- [ ] Factory-Verbesserungen: Compiler-Feedback-Loop, Code-Extraction >10 Files, Agent-Echo-Reduktion
