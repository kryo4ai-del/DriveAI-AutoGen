# DriveAI-AutoGen — MEMORY.md

## Projekt-Übersicht
- **Pfad**: `C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\`
- **Zweck**: Microsoft AutoGen v0.4+ Multi-Agent Pipeline zur automatischen Swift/SwiftUI Code-Generierung für die DriveAI iOS App
- **GitHub**: `https://github.com/kryo4ai-del/DriveAI-AutoGen` (main branch)
- **Git-User**: `kryo4ai-del` / `kryo4ai@gmail.com`

## Tech-Stack
- Python + AutoGen AgentChat v0.4+
- Modell: `gpt-4o-mini` (dev profile)
- Agents: `driveai_lead`, `ios_architect`, `swift_developer`, `reviewer`, `bug_hunter`, `refactor_agent`, `test_generator`
- Xcode-Integration: generierter Code wird automatisch in `DriveAI/` kopiert

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

## Bisherige Runs (diese Session)

| Name | Template/Pack | Dateien (neu) | Status |
|---|---|---|---|
| Settings | screen_plus_viewmodel | — | ✅ committed |
| Home | screen_plus_viewmodel | — | ✅ committed |
| TestFix | screen_plus_viewmodel | — | ✅ committed (Extractor-Verify) |
| Result | screen_plus_viewmodel | 16 + 6 | ✅ committed |
| OCRRecognition | service | 4 | ✅ committed |
| OCRRecognitionService | service | 10 | ✅ committed |
| QuestionAnalysisService | service | 13 | ✅ committed |
| ScannerOCRIntegration | feature | 17 | ✅ committed |
| QuestionParsingEngine | feature | 20 | ✅ committed |
| MultipleChoiceDetection | feature | 16 | ✅ committed |
| LLMQuestionSolverService | service | 8 | ✅ committed |

## Fixes & Bugs (diese Session)

### SyntaxError in delivery-Dateien (behoben)
- `delivery/delivery_exporter.py`, `delivery/sprint_reporter.py`, `delivery/run_manifest.py`
- Problem: required params nach optional params ohne `*`-Separator
- Fix: `*` vor erstem required param eingefügt

### code_extractor.py — komplettes Rewrite
- Alt: generische `NAME_PATTERNS`, fallback auf `GeneratedFile_N.swift` → File-Explosion
- Neu: Priority-Detection (SwiftUI View > named type > extension > orphan)
- Orphan-Blocks → einzelne `GeneratedHelpers.swift` statt N Dateien
- Console-Summary nach Extraction

### Regex-Bug: `to.swift` (behoben)
- Problem: `_TYPE_RE` matched `class to` in Kommentar `// A mock class to simulate...`
- Fix: `[A-Z]\w+` statt `\w+` — Typname muss mit Großbuchstabe beginnen (PascalCase)
- Datei `DriveAI/Models/to.swift` gelöscht + committed

## Schlüsseldateien
| Datei | Zweck |
|---|---|
| `main.py` | Entry Point, CLI-Parsing, Pipeline-Orchestrierung |
| `code_generation/code_extractor.py` | Swift-Code-Extraktion aus Agent-Messages |
| `utils/git_auto_commit.py` | Automatischer Git-Commit nach Pipeline-Run |
| `delivery/delivery_exporter.py` | Delivery-Package-Export |
| `delivery/sprint_reporter.py` | Sprint-Report-Generierung |
| `delivery/run_manifest.py` | Run-Manifest JSON |
| `memory/memory_store.json` | Persistente Agent-Memory (Decisions, Architecture, etc.) |
| `.gitignore` | `generated_code/`, `logs/`, `delivery/exports/`, `.env` etc. |

## Xcode-Projekt
- **Pfad**: `DriveAI/` im Repo
- Öffnen: Doppelklick auf `.xcodeproj` oder `open DriveAI.xcodeproj` im Terminal
- Generierter Code landet automatisch per Xcode-Integration dort
