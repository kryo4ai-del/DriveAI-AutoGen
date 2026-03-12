# DriveAI-AutoGen

Multi-agent AI system built with Microsoft AutoGen for iOS app development assistance.

## Structure

```
DriveAI-AutoGen/
├── agents/
│   ├── lead_agent.py           # Orchestrator
│   ├── ios_architect.py        # Architecture & design
│   ├── swift_developer.py      # Swift/SwiftUI code generation
│   ├── reviewer.py             # Code review
│   ├── bug_hunter.py           # Bug analysis & edge-case detection
│   ├── refactor_agent.py       # Code structure & readability improvements
│   └── test_generator.py       # Structured test case generation
├── tasks/
│   ├── task_manager.py         # Task distribution & tracking
│   ├── task_queue.py           # Persistent task queue
│   ├── task_queue.json         # Queue state (pending / in_progress / completed)
│   ├── task_template_manager.py # Loads and renders task templates
│   ├── task_templates.json     # Reusable task templates (edit to add more)
│   ├── task_pack_manager.py    # Loads and renders task packs
│   └── task_packs.json         # Named groups of templates (edit to add more)
├── config/
│   ├── llm_config.py           # LLM configuration loader (reads active profile)
│   ├── llm_profiles.json       # LLM environment profiles: dev / test / prod
│   ├── agent_toggle_config.py  # Loads and resolves agent enable/disable state
│   ├── agent_toggles.json      # Default agent on/off state (edit to customize)
│   ├── role_config.py          # Loads agent roles from agent_roles.json
│   ├── agent_roles.json        # Agent descriptions and system prompts (edit to customize)
│   ├── session_preset_manager.py # Loads and provides access to session presets
│   └── session_presets.json    # Named full-run configurations (edit to add more)
├── project_context/
│   ├── driveai_roadbook.md     # DriveAI project specification (edit this)
│   └── context_loader.py       # Loads the roadbook for agents
├── memory/
│   ├── memory_store.json       # Persistent memory (auto-updated after each run)
│   └── memory_manager.py       # Reads/writes decisions, notes, reviews
├── planning/
│   ├── feature_backlog.json    # Feature backlog (planned / in_progress / completed)
│   ├── feature_planner.py      # Reads/writes feature state
│   └── backlog_io.py           # Export/import backlog and queue to/from JSON
├── workflows/
│   ├── workflow_recipe_manager.py # Loads and provides access to workflow recipes
│   ├── workflow_recipes.json   # Named multi-step workflow definitions (edit to add more)
│   ├── phase_gate_manager.py   # Evaluates go/no-go conditions for each pipeline phase
│   └── phase_gates.json        # Phase gate conditions (edit to customize)
├── code_generation/
│   ├── code_extractor.py       # Extracts Swift code blocks from agent messages
│   └── project_integrator.py  # Copies generated files into Xcode project
├── generated_code/             # Raw AI output (intermediate staging area)
│   ├── Views/
│   ├── ViewModels/
│   ├── Services/
│   └── Models/
├── DriveAI/                    # Xcode project root (production target)
│   ├── Views/
│   ├── ViewModels/
│   ├── Services/
│   └── Models/
├── delivery/
│   ├── delivery_exporter.py    # Creates structured run packages
│   ├── sprint_reporter.py      # Generates sprint_report.md per run
│   ├── run_manifest.py         # Generates run_manifest.json per run
│   └── exports/                # One folder per run (auto-created)
│       └── run_YYYYMMDD_HHMMSS/
│           ├── task.txt
│           ├── summary.md
│           ├── generated_files.txt
│           ├── memory_snapshot.txt
│           ├── sprint_report.md
│           └── run_manifest.json
├── analytics/
│   ├── analytics_tracker.py    # Reads/writes cumulative run metrics
│   └── analytics_summary.json  # Persisted analytics data (auto-updated)
├── logs/                       # Runtime logs (auto-created)
├── main.py                     # Entry point
├── requirements.txt
└── .env.example
```

## Task Templates

Task templates let you launch common task types with a single flag instead of writing the full task text each time. Templates live in `tasks/task_templates.json` and use `{name}` as a placeholder.

### Available templates

| Template | Description |
|---|---|
| `screen` | SwiftUI screen with layout, placeholder states, and structure |
| `viewmodel` | ViewModel with state handling, business logic, and MVVM structure |
| `service` | Swift service with responsibilities, interfaces, and structure |
| `feature` | Full feature: architecture, views, ViewModels, supporting code |

### Usage

```bash
# List all available templates
python main.py --list-templates

# Run a template
python main.py --template screen --name "Settings Screen"
python main.py --template viewmodel --name "QuizViewModel"
python main.py --template service --name "ProgressTrackingService"
python main.py --template feature --name "Learning Progress Tracking"

# Combined with other flags
python main.py --template feature --name "Learning Progress Tracking" --mode standard
python main.py --template screen --name "Onboarding Screen" --mode quick --approval off --json
```

### Adding a custom template

Edit `tasks/task_templates.json` and add a new entry. Use `{name}` where the name value should be inserted:

```json
{
  "model": "Create a Swift data model for DriveAI: {name}. Include Codable conformance, required properties, and computed helpers."
}
```

Then use it with:
```bash
python main.py --template model --name "QuizQuestion"
```

### Task priority

1. `--task-file` (highest)
2. Direct task string argument
3. `--template --name` or `--pack --name` (rendered template / pack)
4. `--queue-run` / `--queue-run-all`
5. Feature backlog (auto-selected)
6. Sample task (backlog empty)

### Delivery outputs

When a template is used, `template` and `template_name_value` are included in:
- `task.txt` and `summary.md` (delivery package)
- `sprint_report.md` (Run Metadata section)
- `run_manifest.json` (machine-readable fields)
- JSON stdout when using `--json`

## Task Packs

Task packs group related templates into a named set that runs as sequential pipeline cycles. Each task in the pack gets its own run ID, delivery package, sprint report, and run manifest. Packs are defined in `tasks/task_packs.json`.

### Available packs

| Pack | Templates | Description |
|---|---|---|
| `screen_plus_viewmodel` | `screen` + `viewmodel` | Screen and matching ViewModel |
| `feature_bundle` | `feature` + `service` + `viewmodel` | Full feature starter bundle |

### Usage

```bash
# List all available packs
python main.py --list-packs

# Run a pack
python main.py --pack screen_plus_viewmodel --name "Settings"
python main.py --pack feature_bundle --name "LearningProgress"

# Combined with other flags (apply to every task in the pack)
python main.py --pack feature_bundle --name "QuizEngine" --mode standard --approval off
python main.py --pack screen_plus_viewmodel --name "Onboarding" --env-profile prod --json
```

`--name` is substituted into each template's `name_pattern`. For example, `--name "Settings"` with `screen_plus_viewmodel` runs:
- `screen` with name `"Settings"` → task for `SettingsView`
- `viewmodel` with name `"SettingsViewModel"` → task for `SettingsViewModel`

### Name patterns

Each pack entry defines a `name_pattern` that controls how `--name` is expanded for that task:

| Pattern | With `--name "Settings"` | Result |
|---|---|---|
| `{name}` | `Settings` | name as-is |
| `{name}ViewModel` | `SettingsViewModel` | suffix appended |
| `{name}Service` | `SettingsService` | suffix appended |

### JSON output for packs

With `--json`, pack results are returned as an array:

```json
{
  "pack": "screen_plus_viewmodel",
  "name": "Settings",
  "total": 2,
  "succeeded": 2,
  "failed": 0,
  "results": [
    {
      "status": "success",
      "task": "Create a SwiftUI screen for DriveAI: Settings...",
      "template": "screen",
      "rendered_name": "Settings",
      "delivery_export_path": "...",
      "sprint_report_path": "...",
      "run_manifest_path": "..."
    },
    {
      "status": "success",
      "task": "Create a ViewModel for DriveAI: SettingsViewModel...",
      "template": "viewmodel",
      "rendered_name": "SettingsViewModel",
      "delivery_export_path": "...",
      "sprint_report_path": "...",
      "run_manifest_path": "..."
    }
  ]
}
```

Failed tasks do not abort the pack — the remaining tasks continue and the failure is reflected in the result entry and final count.

### Adding a custom pack

Edit `tasks/task_packs.json` and add a new entry. Each task needs a `template` (must exist in `task_templates.json`) and a `name_pattern`:

```json
{
  "model_plus_service": {
    "description": "Data model and matching service",
    "tasks": [
      {"template": "model", "name_pattern": "{name}"},
      {"template": "service", "name_pattern": "{name}Service"}
    ]
  }
}
```

Then run with:
```bash
python main.py --pack model_plus_service --name "QuizQuestion"
```

### Task priority

Packs have the same priority level as `--template`:

1. `--task-file` (highest)
2. Direct task string argument
3. `--template --name` or `--pack --name`
4. `--queue-run` / `--queue-run-all`
5. Feature backlog (auto-selected)
6. Sample task (backlog empty)

### Delivery outputs

When a pack is used, `pack` and `pack_task_count` are included per task run in:
- `task.txt` and `summary.md` (delivery package)
- `sprint_report.md` (Run Metadata section)
- `run_manifest.json` (machine-readable fields)
- JSON stdout when using `--json`

## Agent Toggles

Individual agents can be enabled or disabled per run. This lets you run a lighter team for fast iterations or disable agents whose pass you don't need.

### Config file: `config/agent_toggles.json`

```json
{
  "driveai_lead": true,
  "ios_architect": true,
  "swift_developer": true,
  "reviewer": true,
  "bug_hunter": true,
  "refactor_agent": true,
  "test_generator": true
}
```

Edit this file to change the default state for all runs. If the file is missing or invalid, all agents are enabled automatically.

### CLI override: `--disable-agent` / `--enable-agent`

Override config for the current run only without editing the JSON file:

```bash
# Disable one agent
python main.py --disable-agent bug_hunter

# Disable multiple agents
python main.py --disable-agent bug_hunter --disable-agent refactor_agent

# Force-enable an agent that is off in the config
python main.py --enable-agent reviewer

# Combined with other flags
python main.py --mode quick --disable-agent reviewer --json
python main.py --disable-agent bug_hunter --disable-agent test_generator --approval off
```

Multiple `--disable-agent` and `--enable-agent` flags are supported. CLI overrides apply only to the current run — the JSON file is not modified.

### Minimum required agents (always active)

`driveai_lead` and `swift_developer` are **core agents** and are always force-enabled, even if the config or CLI tries to disable them. This ensures the pipeline always has an orchestrator and a code generator.

### Console output

Active and disabled agents are shown in the run header:

```
Active agents   : driveai_lead, ios_architect, swift_developer, reviewer
Disabled agents : bug_hunter, refactor_agent, test_generator
```

### Delivery outputs

`active_agents` and `disabled_agents` are included in:
- `task.txt` and `summary.md` (delivery package)
- `sprint_report.md` (Run Metadata section)
- `run_manifest.json` (machine-readable fields)
- JSON stdout when using `--json`

## Environment Profiles

LLM environment profiles control which model and temperature are used per run.
Profiles are defined in `config/llm_profiles.json` and selected with `--env-profile`.

### Available profiles

| Profile | Model | Temperature | Description |
|---|---|---|---|
| `dev` | `claude-haiku-4-5` | 0.2 | Fast iteration during development (default) |
| `standard` | `claude-sonnet-4-6` | 0.2 | Normal operation |
| `premium` | `claude-opus-4-6` | 0.1 | Highest-quality output for production runs |

### Usage

```bash
# Use dev profile (default — no flag needed)
python main.py

# Use test profile
python main.py --env-profile test

# Use prod profile
python main.py --env-profile prod

# Combined with other flags
python main.py --env-profile prod --mode full --approval auto "Create a SwiftUI settings screen"

# JSON output includes env_profile and model
python main.py --env-profile test --json
```

### What gets set per profile

Each profile in `config/llm_profiles.json` configures:
- **`model`** — the Anthropic Claude model used by all agents and the team selector
- **`temperature`** — sampling temperature for all LLM calls
- **`api_key_env`** — environment variable name to read the API key from

### Adding a custom profile

Edit `config/llm_profiles.json` and add a new entry:

```json
{
  "staging": {
    "model": "claude-sonnet-4-6",
    "temperature": 0.15,
    "api_key_env": "ANTHROPIC_API_KEY",
    "provider": "anthropic"
  }
}
```

Then run with `--env-profile staging`. If the name is not found in the JSON, the system falls back to `dev` automatically.

### Console output

The active profile and selected model are always shown in the run header:

```
Environment profile : test
Model               : claude-haiku-4-5
```

### Delivery outputs

`env_profile` and `model` are included in:
- `task.txt` and `summary.md` (delivery package)
- `sprint_report.md` (Run Metadata section)
- `run_manifest.json` (machine-readable fields)
- JSON stdout when using `--json`

## Agent Role Configuration

Agent descriptions and system prompts are centralized in `config/agent_roles.json`.
Edit this file to customize how each agent behaves — no Python changes needed.

```json
{
  "swift_developer": {
    "description": "Swift Developer agent. Writes SwiftUI and Swift code...",
    "system_message": "You are the Swift Developer for the DriveAI project..."
  }
}
```

Roles are loaded at startup via `config/role_config.py`. If an agent key is missing from the JSON,
a generic fallback role is used automatically.

## Project Context

The file `project_context/driveai_roadbook.md` contains the DriveAI project specification.
It is automatically loaded at startup and injected into every agent conversation as shared context.

To customize: edit `driveai_roadbook.md` with your actual project goals, features, and architecture notes.
All agents will use this as their shared understanding of the DriveAI project.

## Persistent Memory

After each run, the system automatically writes to `memory/memory_store.json`:
- a decision note (task completed)
- an implementation note (messages exchanged)
- a review note (review cycle executed)

On the next run, this memory is loaded and included in the task sent to all agents,
so they can build on previous decisions without starting from scratch.

To reset memory: delete or clear `memory/memory_store.json`.

## Agents

| Agent | Name | Role |
|---|---|---|
| Lead | `driveai_lead` | Orchestrates, breaks down tasks, delegates |
| iOS Architect | `ios_architect` | Architecture, patterns, module structure |
| Swift Developer | `swift_developer` | SwiftUI/Swift code generation |
| Reviewer | `reviewer` | Code quality, readability, structure |
| Bug Hunter | `bug_hunter` | Bugs, edge cases, crash risks, structural weaknesses |
| Refactor Agent | `refactor_agent` | Code structure, naming, modularity, readability |
| Test Generator | `test_generator` | Test cases, happy paths, edge cases, failure scenarios |

Each run executes five automated passes:

1. **Implementation pass** — architect + developer + reviewer build the feature
2. **Bug Hunter pass** — identifies bugs, crash risks, and missing edge cases
3. **Refactor pass** — improves structure, naming, and modularity without changing behavior
4. **Test generation pass** — generates structured test cases grouped by component and behavior
5. **Fix execution pass** — applies the highest-priority bug fixes and refactor improvements; may generate additional Swift files

The fix task is built dynamically from the bug review and refactor outputs (`tasks/fix_executor.py`).
Any new Swift files produced in the fix pass are extracted and integrated into the Xcode project automatically.

Findings from all five passes are saved to persistent memory.

## Feature Planner

Features are tracked in `planning/feature_backlog.json` across three states:

```json
{
  "planned":     ["Home Screen", "Scanner Screen", ...],
  "in_progress": [],
  "completed":   ["Result Screen"]
}
```

When you run `python main.py` **without** a task argument, the system automatically:
1. Picks the first feature from `planned`
2. Moves it to `in_progress`
3. Generates a task: `"Design and implement the SwiftUI <Feature> for DriveAI."`
4. Runs the agent conversation
5. Marks the feature as `completed` after a successful run

To add features: edit `planning/feature_backlog.json` directly.
To reset: move features back to `"planned"` or clear `"completed"`.

## Code Generation & Xcode Integration

The pipeline runs automatically after each agent conversation:

**Step 1 — Extract** (`code_extractor.py`)
Swift code blocks from agent messages are saved to `generated_code/`:
- `Views/` — structs/classes ending in `View`
- `ViewModels/` — structs/classes ending in `ViewModel`
- `Services/` — structs/classes ending in `Service`
- `Models/` — everything else

File names are derived from the Swift type name (e.g., `struct QuestionView` → `QuestionView.swift`).
Unnamed blocks fall back to `GeneratedFile_N.swift`.

**Step 2 — Integrate** (`project_integrator.py`)
Every file in `generated_code/` is copied into the matching subfolder of the Xcode project (`DriveAI/`):
```
generated_code/Views/QuestionView.swift  →  DriveAI/Views/QuestionView.swift
```

Both steps skip files whose content has not changed.
The `.xcodeproj` file is never modified — only Swift source files are copied.

## Delivery Packages

After each full pipeline run, a delivery package is automatically created in `delivery/exports/run_YYYYMMDD_HHMMSS/`:

| File | Contents |
|---|---|
| `task.txt` | Original task, timestamp, source (CLI / backlog / sample) |
| `summary.md` | Per-pass summaries + file counts |
| `generated_files.txt` | All Swift files in `generated_code/` and `DriveAI/` |
| `memory_snapshot.txt` | Memory state used during the run |
| `sprint_report.md` | Full human-readable sprint report (see below) |
| `run_manifest.json` | Machine-readable run metadata and results (see below) |

Each package is a self-contained snapshot of one complete development cycle.

### Run Manifest (`run_manifest.json`)

A machine-readable JSON file generated after every run. Intended for automation, analytics, and tooling integration.

```json
{
  "run_id": "20250307_143022",
  "timestamp": "...",
  "task": "...",
  "task_source": "CLI argument",
  "run_mode": "full",
  "approval_mode": "auto",
  "project_context_loaded": true,
  "memory_used": true,
  "passes": {
    "implementation": true,
    "bug_review": true,
    "refactor": true,
    "test_generation": true,
    "fix_execution": true
  },
  "message_counts": {
    "implementation": 10,
    "bug_review": 8,
    "refactor": 7,
    "test_generation": 6,
    "fix_execution": 9,
    "total": 40
  },
  "generated_files": ["Views/OnboardingView.swift", "..."],
  "integrated_files": ["Views/OnboardingView.swift", "..."],
  "xcode_integration": {
    "status": "integrated",
    "files_copied": 2,
    "files_unchanged": 0
  },
  "delivery_export_path": "...",
  "sprint_report_path": "...",
  "status": "success"
}
```

Skipped passes (e.g. with `--mode quick`) are reflected as `false` in the `passes` block.
Skipped Xcode integration (e.g. with `--approval off`) is reflected in `xcode_integration.status`.

### Sprint Report (`sprint_report.md`)

A readable markdown report generated after every run. Sections:

- **Run Metadata** — timestamp, task source, original task
- **Implementation Summary** — what was built, which agents participated
- **Bug Review Summary** — risks and weaknesses found
- **Refactor Summary** — structural improvements suggested
- **Test Summary** — test cases proposed
- **Generated Code** — list of Swift files extracted
- **Integrated Code** — list of files copied into the Xcode project
- **Memory Updates** — what was added to persistent memory
- **Recommended Next Step** — one suggested follow-up task

## Setup

```bash
cp .env.example .env
pip install -r requirements.txt
python main.py
```

## Run Modes

Control how many passes the pipeline executes with `--mode`:

| Mode | Passes |
|---|---|
| `quick` | Implementation only |
| `standard` | Implementation + Bug Review + Refactor + Tests |
| `full` | All five passes including Fix Execution (default) |

```bash
# Default (full pipeline)
python main.py

# Quick — implementation only
python main.py --mode quick

# Standard — no fix execution pass
python main.py --mode standard

# Full — explicit
python main.py --mode full

# With a custom task
python main.py "Create a SwiftUI settings screen" --mode quick
python main.py --mode full "Create a SwiftUI exam result screen"
```

The selected mode is shown in the console header, log file, delivery package, and sprint report.

## Approval Modes

Control whether generated Swift files are copied into the Xcode project with `--approval`:

| Mode | Behavior |
|---|---|
| `auto` | Integrate automatically after each pass (default) |
| `ask` | Prompt `[y/N]` before integrating — any other input skips |
| `off` | Never integrate; files stay in `generated_code/` only |

```bash
# Auto (default)
python main.py --approval auto

# Ask before integrating
python main.py --approval ask

# Never integrate
python main.py --approval off

# Combined with run mode and custom task
python main.py "Create a SwiftUI profile screen" --mode full --approval ask
```

> **Note:** `generated_code/` always receives extracted Swift files regardless of approval mode. The approval setting only controls whether files are further copied into `DriveAI/` (the Xcode project).

## Analytics

After every pipeline run, key metrics are accumulated in `analytics/analytics_summary.json`.
The file is created automatically on first run.

### What is tracked

| Metric | Description |
|---|---|
| Total / successful / failed runs | Cumulative run counts |
| Task sources | How many runs came from CLI, feature backlog, task queue, or sample task |
| Run modes | Breakdown by `quick`, `standard`, `full` |
| Approval modes | Breakdown by `auto`, `ask`, `off` |
| Generated files total | Sum of Swift files extracted across all runs |
| Integrated files total | Sum of Swift files copied into the Xcode project across all runs |
| Message totals | Cumulative agent messages per pass and overall |

### CLI

```bash
# Print analytics summary
python main.py --analytics-summary
```

Example output:
```
Analytics Summary
----------------------------------------
Total runs      : 14
Successful runs : 13
Failed runs     : 1

Task sources:
  cli     : 5
  backlog : 4
  queue   : 5
  sample  : 0

Run modes:
  quick    : 3
  standard : 4
  full     : 7

Approval modes:
  auto : 8
  ask  : 3
  off  : 3

Generated files total  : 28
Integrated files total : 19

Messages exchanged:
  implementation : 140
  bug review     : 112
  refactor       : 98
  test generation: 84
  fix execution  : 126
  overall        : 560
```

Analytics are updated automatically after each run — no manual action needed.
To reset: clear or delete `analytics/analytics_summary.json`.

## Task Queue

The task queue lets you batch up tasks and run them one at a time, independently of the feature backlog.
State is stored in `tasks/task_queue.json` across all runs.

### Queue commands

```bash
# Add a task to the queue
python main.py --queue-add "Create a SwiftUI onboarding screen"
python main.py --queue-add "Implement the progress tracking feature"

# Run the next pending task from the queue (full pipeline)
python main.py --queue-run

# Run the next queued task in quick mode
python main.py --queue-run --mode quick --approval off

# Run all pending tasks in sequence (batch)
python main.py --queue-run-all

# Run all pending tasks in quick mode, no Xcode integration
python main.py --queue-run-all --mode quick --approval off

# Run at most 2 tasks from the queue
python main.py --queue-run-all --limit 2 --mode standard --approval off

# Show queue status
python main.py --queue-summary
```

### Batch runner (`--queue-run-all`)

Processes all pending tasks in order, one at a time. Each task runs the full pipeline
independently (own run ID, delivery package, sprint report, memory update).

- Use `--limit N` to stop after at most N tasks regardless of how many are pending.
- All `--mode` and `--approval` flags apply to every task in the batch.
- Progress is shown as `Running queued task 1/3:` before each task.
- A summary is printed at the end showing how many tasks were processed and how many remain.

**Failure handling:** If a task raises an unexpected error during `--queue-run-all` or `--queue-run`,
it is moved to the `failed` list (not re-queued automatically). The batch continues with the next task.
Failed tasks are counted and shown in the final summary. Use `--retry-all-failed` to requeue them.

### Failed task recovery

```bash
# Show all failed tasks with error details
python main.py --failed-summary

# Retry one specific failed task (moves back to pending)
python main.py --retry-failed "Create a SwiftUI settings screen"

# Retry all failed tasks at once (moves all back to pending)
python main.py --retry-all-failed

# After retrying, run the queue normally
python main.py --queue-run-all --mode quick --approval off
```

Failed tasks are stored in `tasks/task_queue.json` under the `"failed"` key with the timestamp
and error message. They are never silently dropped or automatically discarded.

### Queue priority

When `--queue-run` or `--queue-run-all` is used, queued tasks take priority over the feature backlog and sample tasks.
Each task is automatically marked as `completed` after the pipeline finishes.

### Queue states

| State | Description |
|---|---|
| `pending` | Waiting to run |
| `in_progress` | Currently being processed |
| `completed` | Finished — preserved for history |
| `failed` | Pipeline raised an error — use `--retry-failed` or `--retry-all-failed` to requeue |

## Backlog & Queue Export / Import

The feature backlog and task queue can be exported to JSON files and imported back — useful for backups, sharing tasks between environments, or pre-loading a queue from an external tool.

### Export

```bash
# Export the feature backlog to a file
python main.py --export-backlog exports/backlog.json

# Export the task queue to a file
python main.py --export-queue exports/queue.json
```

Both commands write the current state to the specified path and exit immediately — no pipeline run is triggered.

### Import

```bash
# Import backlog — merge by default (no duplicates added)
python main.py --import-backlog imports/backlog.json

# Import backlog — replace existing backlog completely
python main.py --import-backlog imports/backlog.json --replace-backlog

# Import queue — merge by default
python main.py --import-queue imports/queue.json

# Import queue — replace existing queue completely
python main.py --import-queue imports/queue.json --replace-queue
```

### Merge vs Replace

| Mode | Flag | Behavior |
|---|---|---|
| `merge` (default) | _(no flag)_ | Adds new entries only; existing entries are kept unchanged; duplicates are skipped |
| `replace` | `--replace-backlog` / `--replace-queue` | Overwrites the current file entirely with the imported data |

**Backlog merge:** Deduplication is by feature name string, per section (`planned`, `in_progress`, `completed`).

**Queue merge:** Deduplication is by task text, per section (`pending`, `in_progress`, `completed`, `failed`). All metadata fields (`added_at`, `started_at`, etc.) from the imported entries are preserved.

### Console output

```
Backlog exported to:
  exports/backlog.json

Queue imported from:
  imports/queue.json
Mode:
  merge
Entries added:
  planned=3  in_progress=0  completed=1  (total 4)
```

### Export format

Both exports are standard JSON files using the same format as the internal state files — you can inspect or edit them directly.

**Backlog (`feature_backlog.json` format):**
```json
{
  "planned": ["Settings Screen", "Profile Screen"],
  "in_progress": [],
  "completed": ["Home Screen"]
}
```

**Queue (`task_queue.json` format):**
```json
{
  "pending": [
    {"task": "Create a SwiftUI onboarding screen", "added_at": "2025-03-07T10:00:00"}
  ],
  "in_progress": [],
  "completed": [],
  "failed": []
}
```

## Workflow Recipes

Workflow recipes are named, end-to-end workflow definitions stored in `workflows/workflow_recipes.json`. A single `--workflow-recipe` flag launches a complete workflow — combining a session preset, task source (template, pack, or queue), and optional overrides. Recipes are the highest-level shortcut in the system.

### Available recipes

| Recipe | Session preset | Task source | Description |
|---|---|---|---|
| `build_screen` | `fast_local` | pack: `screen_plus_viewmodel` | Create a screen + ViewModel quickly |
| `implement_feature` | `agentic_full` | template: `feature` | Full feature implementation with all passes |
| `review_only` | `safe_review` | _(from CLI or backlog)_ | Review-focused pipeline with safe settings |
| `batch_queue_run` | `fast_local` | queue batch | Process all queued tasks in fast mode |

### Usage

```bash
# List all available workflow recipes
python main.py --list-workflow-recipes

# Run a recipe (--name required when recipe uses a template or pack)
python main.py --workflow-recipe build_screen --name "Settings"
python main.py --workflow-recipe implement_feature --name "Progress Tracking"

# Recipe with queue batch (no --name needed)
python main.py --workflow-recipe batch_queue_run

# Override recipe values with explicit flags
python main.py --workflow-recipe build_screen --name "Profile" --mode standard
python main.py --workflow-recipe batch_queue_run --approval off
python main.py --workflow-recipe implement_feature --name "QuizEngine" --env-profile dev --json
```

### Precedence rules

Settings are resolved in this order (highest to lowest):

```
1. Explicit CLI flags         (--mode, --approval, --env-profile, --disable-agent, --enable-agent,
                               --template, --pack, --queue-run-all, direct task, --task-file)
2. Recipe direct values       (run_mode, approval_mode, env_profile, disable_agents, queue_run_all)
3. Recipe session preset      (session_preset → preset values)
4. Profile defaults           (--profile: fast / dev / safe / agentic)
5. System defaults            (full / auto / dev)
```

For agent toggles: preset `disable_agents` < recipe `disable_agents` < `--disable-agent` < `--enable-agent`

For task routing: CLI direct task / `--task-file` / `--template` / `--pack` always take priority over recipe's `task_template` / `task_pack`.

### Recipe fields

| Field | Type | Description |
|---|---|---|
| `description` | string | Human-readable description shown in `--list-workflow-recipes` |
| `session_preset` | string | Apply this session preset as the base config |
| `task_template` | string | Run this template (requires `--name` unless overridden by a direct task) |
| `task_pack` | string | Run this task pack (requires `--name` unless overridden by a direct task) |
| `queue_run_all` | bool | Trigger batch queue processing |
| `run_mode` | string | Override mode (`quick` / `standard` / `full`) |
| `approval_mode` | string | Override approval (`auto` / `ask` / `off`) |
| `env_profile` | string | Override environment profile |
| `disable_agents` | list | Disable additional agents (combined with preset's disable list) |

All fields are optional. Unset fields fall back to the session preset, profile, or system defaults.

### Adding a custom recipe

Edit `workflows/workflow_recipes.json` and add a new entry:

```json
{
  "quick_model": {
    "description": "Create a data model quickly without review passes",
    "session_preset": "fast_local",
    "task_template": "model"
  }
}
```

Then run with:
```bash
python main.py --workflow-recipe quick_model --name "QuizQuestion"
```

### Delivery outputs

`workflow_recipe` is included in all delivery outputs when a recipe is used:
- `task.txt` and `summary.md` (delivery package)
- `sprint_report.md` (Run Metadata section)
- `run_manifest.json` (machine-readable field)
- JSON stdout when using `--json`

## Phase Gates

Phase gates are go/no-go checkpoints evaluated between pipeline passes. Before each phase runs, the gate checks a simple condition based on message counts from previous phases. If the condition is not met, the phase is skipped cleanly and the pipeline continues with the next step.

Gates are configured in `workflows/phase_gates.json` and require no code changes to customize.

### Default gate conditions

| Phase | Condition | Default |
|---|---|---|
| `bug_review` | Implementation produced at least N messages | `min_messages: 1` |
| `refactor` | Bug review produced at least N messages | `requires_bug_review_messages: 1` |
| `test_generation` | Implementation produced at least N messages | `requires_implementation_messages: 1` |
| `fix_execution` | Bug review + refactor combined produced at least N messages | `requires_bug_or_refactor_messages: 1` |

Any gate with `"enabled": false` is always skipped regardless of message counts.

### Config: `workflows/phase_gates.json`

```json
{
  "bug_review": {
    "enabled": true,
    "min_messages": 1
  },
  "refactor": {
    "enabled": true,
    "requires_bug_review_messages": 1
  },
  "test_generation": {
    "enabled": true,
    "requires_implementation_messages": 1
  },
  "fix_execution": {
    "enabled": true,
    "requires_bug_or_refactor_messages": 1
  }
}
```

### When a phase is skipped

A clear message is printed to the console:

```
Phase gate: skipping fix_execution (no review/refactor findings available)
```

And the final run summary lists all skipped phases:

```
Phases skipped     : bug_review, fix_execution
```

### Effect on outputs

Skipped phases are reflected accurately across all outputs:

- **Console summary** — `Phases skipped: <list>` line
- **`run_manifest.json`** — `skipped_phases` field + `passes` flags set to `false` for skipped phases
- **`sprint_report.md`** — `Skipped phases` in Run Metadata
- **`task.txt` / `summary.md`** — `Skipped phases` line
- **JSON stdout** (`--json`) — `skipped_phases` field in result

### Disabling a gate

Set `"enabled": false` to always skip a phase without checking message counts:

```json
{
  "refactor": {
    "enabled": false
  }
}
```

### Raising the threshold

Set a higher count to require more substantial output before the next phase runs:

```json
{
  "fix_execution": {
    "enabled": true,
    "requires_bug_or_refactor_messages": 3
  }
}
```

If the file is missing or invalid, all gates default to permissive (all phases run).

## Session Presets

Session presets are named, fully-configured run profiles stored in `config/session_presets.json`. A single `--session-preset` flag sets all run parameters at once — mode, approval, environment, and agent toggles. Explicit CLI flags always override preset values.

### Available presets

| Preset | Mode | Approval | Env | Description |
|---|---|---|---|---|
| `fast_local` | `quick` | `off` | `dev` | Implementation only, no review passes, no Xcode integration |
| `safe_review` | `standard` | `ask` | `test` | Full review pipeline with approval prompt before integration |
| `agentic_full` | `full` | `auto` | `prod` | All five passes including fix execution, production model, auto-integrate |

### Usage

```bash
# List all available session presets
python main.py --list-session-presets

# Run with a preset
python main.py --session-preset fast_local
python main.py --session-preset safe_review
python main.py --session-preset agentic_full

# Run with a preset and a specific task
python main.py --session-preset fast_local "Create a SwiftUI settings screen"

# Override preset values with explicit flags
python main.py --session-preset safe_review --approval off
python main.py --session-preset agentic_full --mode quick
python main.py --session-preset fast_local --env-profile prod --json
```

### Precedence rules

Settings are resolved in this order (highest to lowest):

```
1. Explicit CLI flags     (--mode, --approval, --env-profile, --disable-agent, --enable-agent)
2. Session preset values  (--session-preset)
3. Profile defaults       (--profile: fast / dev / safe / agentic)
4. System defaults        (full / auto / dev)
```

For agent toggles specifically:
- Preset's `disable_agents` list is applied first
- `--disable-agent` adds to the disabled set
- `--enable-agent` overrides both preset and `--disable-agent` for that agent

### Console output

When a session preset is active, it is shown in the run header:

```
Session preset  : fast_local
Profile         : fast
Env profile     : dev
Model           : claude-haiku-4-5
Run mode        : quick
Approval mode   : off
Disabled agents : bug_hunter, refactor_agent, test_generator
```

### Adding a custom preset

Edit `config/session_presets.json` and add a new entry. All fields are optional — omitted fields fall back to profile defaults or system defaults:

```json
{
  "my_preset": {
    "description": "Custom setup for feature reviews",
    "profile": "dev",
    "env_profile": "test",
    "run_mode": "standard",
    "approval_mode": "off",
    "disable_agents": ["test_generator"]
  }
}
```

Then run with:
```bash
python main.py --session-preset my_preset
```

### Delivery outputs

`session_preset` is included in all delivery outputs when a preset is used:
- `task.txt` and `summary.md` (delivery package)
- `sprint_report.md` (Run Metadata section)
- `run_manifest.json` (machine-readable field)
- JSON stdout when using `--json`

## Profiles

Profiles are named execution presets that set `--mode` and `--approval` defaults with a single flag.

```bash
python main.py --profile fast
python main.py --profile dev
python main.py --profile safe
python main.py --profile agentic
```

### Available profiles

| Profile | Run mode | Approval mode | Description |
|---|---|---|---|
| `fast` | `quick` | `off` | Implementation only, no Xcode integration |
| `dev` | `standard` | `auto` | All review passes, auto-integrate |
| `safe` | `standard` | `ask` | All review passes, prompt before integrating |
| `agentic` | `full` | `auto` | All five passes including fix execution, auto-integrate |

### Precedence

Explicit `--mode` and `--approval` flags always override the profile defaults:

```bash
# profile sets standard/ask, but --approval off overrides the approval
python main.py --profile safe --approval off
# => run_mode=standard, approval_mode=off

# profile sets full/auto, but --mode quick overrides the mode
python main.py --profile agentic --mode quick
# => run_mode=quick, approval_mode=auto

# no profile — existing defaults (full / auto) apply
python main.py
```

The active profile is shown in the console header, logged, and included in the delivery package, sprint report, and run manifest.

## External Trigger Mode

The system can be triggered cleanly by external tools such as n8n, shell scripts, or local API wrappers.

### `--json`

Prints a machine-readable JSON result to stdout at the end of the run instead of (or in addition to) the normal summary. Intended for automation tools that parse stdout.

```bash
python main.py --json
python main.py --mode quick --approval off --json
python main.py "Create a SwiftUI settings screen" --mode full --approval off --json
```

Success output:
```json
{
  "status": "success",
  "task": "Create a SwiftUI settings screen",
  "task_source": "CLI argument",
  "run_mode": "full",
  "approval_mode": "off",
  "delivery_export_path": "...",
  "sprint_report_path": "...",
  "run_manifest_path": "...",
  "generated_files_count": 3,
  "integrated_files_count": 0,
  "message_counts": {
    "implementation": 10,
    "bug_review": 8,
    "refactor": 7,
    "test_generation": 6,
    "fix_execution": 9,
    "total": 40
  }
}
```

Error output:
```json
{
  "status": "error",
  "error": "..."
}
```

### `--task-file PATH`

Loads the task text from a file instead of the CLI argument. Useful for external tools that write the task to a file before triggering the pipeline.

```bash
# Write task to file
echo "Create a SwiftUI onboarding screen" > input_task.txt

# Run pipeline with task from file
python main.py --task-file input_task.txt --mode quick --approval off --json
```

**Task priority:**
1. `--task-file` (highest)
2. Direct task string argument
3. `--queue-run` / `--queue-run-all`
4. Feature backlog (auto-selected)
5. Sample task (backlog empty)

### n8n integration example

Use an **Execute Command** node in n8n:
```
python main.py --task-file /tmp/driveai_task.txt --mode quick --approval off --json
```
Parse the JSON stdout in the next node to extract `delivery_export_path`, `generated_files_count`, or `status`.

## Usage

```bash
# Run with default sample task (full mode)
python main.py

# Run with a custom task
python main.py "Design the onboarding flow for DriveAI"

# Run next backlog feature in quick mode
python main.py --mode quick

# Add tasks to queue and run them one at a time
python main.py --queue-add "Create a SwiftUI onboarding screen"
python main.py --queue-add "Add dark mode support"
python main.py --queue-run
python main.py --queue-run

# Add tasks and run all at once
python main.py --queue-add "Create a SwiftUI onboarding screen"
python main.py --queue-add "Create a SwiftUI settings screen"
python main.py --queue-add "Create a SwiftUI profile screen"
python main.py --queue-run-all --mode quick --approval off
python main.py --queue-run-all --limit 2 --mode standard --approval off
```

## AI Auto Commit

Every successful pipeline run automatically stages all changes, creates a Git commit, and pushes to the configured remote.

### Commit message format

```
AI run: {task description}
```

Example:

```
AI run: Create a SwiftUI screen for DriveAI: Settings
```

### Console output

On success:

```
Git auto commit:
  - changes staged
  - commit created
  - pushed to origin/main
```

When nothing changed:

```
Git auto commit:
  skipped (no changes detected)
```

### Safety

- If Git is not installed or the directory is not a repository, auto-commit is skipped silently.
- A failed commit logs an error but does not crash the pipeline.
- A failed push prints a warning and continues.

### Configuration

Auto-commit uses `utils/git_auto_commit.py` and requires the repository to have a configured remote (`origin`).
To disable auto-commit, remove or comment out the `GitAutoCommit().run_auto_commit(...)` calls in `main.py`.
