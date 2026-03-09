# Factory Operating Guide

Last Updated: 2026-03-09

---

## What This Guide Covers

How to use the AI App Factory from raw idea to finished product.
Practical workflows, prompts, and rules for working with the 12-agent system.

---

## System Overview

The AI App Factory is a multi-agent development system built on AutoGen.

```
12 Agents:
  2 Planning    — ProductStrategist, Roadmap
  1 Content     — ContentScript
  1 Monitoring  — ChangeWatch
  1 Quality     — Accessibility
  7 Build       — Lead, Architect, Developer, Reviewer, BugHunter, Refactor, TestGenerator
```

```
Data Stores:
  factory/ideas/idea_store.json       — Ideas
  factory/projects/project_registry.json — Projects
  factory/specs/spec_store.json       — Specs
  content/content_store.json          — Content
  watch/watch_events.json             — Watch Events
  accessibility/accessibility_reports.json — A11Y Reports
```

---

## End-to-End Workflow

```
1. Idea Capture        → idea_store.json (inbox)
2. Classification      → ProductStrategist assigns scope, type, project
3. Prioritization      → RoadmapAgent assigns phase (now/next/later/blocked)
4. Spec Creation       → spec_store.json (draft → approved)
5. Implementation      → AutoGen pipeline run
6. Review              → Bug Hunter + Reviewer + Accessibility
7. Integration         → Code extraction → Xcode → Git
8. Content             → App Store copy, release notes, video scripts
9. Release             → Build validation, TestFlight, App Store
```

---

## Step 1: Capture an Idea

### Quick capture (tell Claude)

```
Neue Idee für AskFin: Offline-Modus für häufige Fragen ohne LLM-Abhängigkeit.
Trag das in die Factory ein.
```

Claude creates the idea in `idea_store.json` with status `inbox`.

### Manual capture (Python)

```python
from factory.idea_manager import IdeaManager
mgr = IdeaManager()
mgr.add_idea(
    title="Offline Rule Engine",
    raw_idea="Local rule-based answers for common questions without LLM",
    source="session",
    project="askfin",
)
```

### During planning runs

Planning agents automatically see inbox ideas and can classify them.

---

## Step 2: Classify the Idea

### Prompt for classification

```
Classify all inbox ideas in the factory.
Use ProductStrategist logic: assign scope, type, project, priority.
Update idea_store.json directly.
```

### Or run the planning pipeline

```
python main.py --template feature --name "IdeaClassification" --profile dev --approval auto
```

The ProductStrategistAgent will evaluate ideas and assign:
- **scope**: app-level, factory-level, future-product
- **type**: feature, agent, infrastructure, monetization, etc.
- **project**: askfin, factory-core, or a new project
- **priority**: now, next, later, blocked

---

## Step 3: Prioritize

### Prompt for prioritization

```
Review all classified ideas and create a roadmap.
Group by phase: NOW / NEXT / LATER / BLOCKED.
Reference idea IDs.
```

The RoadmapAgent organizes ideas into execution phases and identifies dependencies.

---

## Step 4: Create a Spec

When an idea reaches `prioritized` with priority `now`, create a spec.

### Prompt for spec creation

```
Create a spec for IDEA-001 (CoreML Model Swap).
Define: goal, in-scope, out-of-scope, acceptance criteria, dependencies, suggested template, suggested agents.
Save to spec_store.json and transition IDEA-001 to spec-ready.
```

### Programmatic

```python
from factory.idea_manager import IdeaManager
from factory.spec_manager import SpecManager

ideas = IdeaManager()
specs = SpecManager()

idea = ideas.get_idea("IDEA-001")
spec = specs.create_from_idea(idea,
    goal="Replace placeholder with real CoreML model",
    in_scope=["Model integration", "Prediction pipeline"],
    out_of_scope=["Model training", "Data collection"],
    acceptance_criteria=["Model loads successfully", "Top-3 sign prediction works"],
    suggested_template="service",
    suggested_agents=["ios_architect", "swift_developer", "reviewer"],
)
ideas.transition("IDEA-001", "spec-ready")
```

---

## Step 5: Run the Implementation Pipeline

### Standard feature run

```
python main.py --template feature --name "CoreMLModelSwap" --profile dev --approval auto
```

### Available templates

| Template | Use Case |
|---|---|
| feature | Full feature with Views + ViewModels + Services |
| screen | Single screen with View + ViewModel |
| service | Backend service or data layer |
| viewmodel | ViewModel only |

### Direct implementation (recommended for complex features)

For features that need precise control, implement directly with Claude Code:

```
Implement system expansion: CoreMLModelSwap

Context: [describe what exists]
Goal: [describe what to build]
Scope: [what to change, what not to change]
Tasks:
1. [specific task]
2. [specific task]
3. [specific task]
Constraints: [boundaries]
```

Then run the pipeline for memory + review:

```
python main.py --template feature --name "CoreMLModelSwap" --profile dev --approval auto
```

---

## Step 6: Review

### Prompt for focused review

```
Review the generated code for CoreMLModelSwap.
Focus on: bugs, edge cases, accessibility, test coverage.
Do not auto-fix — report findings only.
```

### Pipeline review passes

Every pipeline run automatically includes:
- Bug Hunter pass (10 messages)
- Refactor pass (10 messages)
- Test Generation pass (10 messages)

### Accessibility review

```
Run an accessibility review on all AskFin Views.
Check: labels, contrast, touch targets, VoiceOver, Dynamic Type.
Save findings to accessibility_reports.json.
```

---

## Step 7: Content Generation

### Prompt for content

```
Generate App Store descriptions for AskFin (short + long).
Language: German. Audience: Fahrschüler in DACH. Tone: enthusiastic.
Base on real features from project docs.
```

### Supported content types

| Type | Use Case |
|---|---|
| video_script | YouTube / demo video script |
| app_store_short | App Store subtitle / short description |
| app_store_long | App Store full description |
| landingpage_copy | Website landing page text |
| social_post | Social media announcement |
| feature_announcement | Feature launch communication |
| release_notes | What's new in this version |

---

## Step 8: Release Preparation

1. Validate all specs are `done`
2. Run final accessibility review
3. Generate release notes content
4. Build in Xcode, test on device
5. Submit to TestFlight / App Store

---

## Prompt Templates

### Idea Intake

```
Neue Idee: [Titel]
Beschreibung: [Was soll gebaut werden]
Projekt: [askfin / factory-core / neues Projekt]
Quelle: [session / roadmap / strategy / user]

Trag das als neue Idea in die Factory ein.
```

### Planning / Spec

```
Implement system expansion: [Name]

Context: [Was existiert bereits]
Goal: [Was soll erreicht werden]
Scope: [Was ändern, was nicht]
Tasks:
1. [Aufgabe 1]
2. [Aufgabe 2]
3. [Aufgabe 3]
Constraints:
- [Einschränkung 1]
- [Einschränkung 2]
```

### Feature Implementation (Pipeline)

```
python main.py --template [feature|screen|service|viewmodel] --name "[FeatureName]" --profile dev --approval auto
```

### Review

```
Review [Komponente/Feature].
Focus: [bugs / accessibility / performance / structure].
Do not auto-fix — report findings only.
```

### Content

```
Generate [content_type] for [project].
Language: [de/en]. Audience: [Zielgruppe]. Tone: [tone].
Base on real features from project docs and specs.
```

---

## Working Rules

### One active build project at a time

- Only one project should be in active implementation at any time
- This keeps agent context focused and prevents cross-project confusion
- Planning and idea intake can happen for multiple projects in parallel

### Multiple projects in the registry

- The project registry can hold many projects
- Each project has its own ideas, specs, and content
- Use `project` field to filter by project

### Planning vs. Implementation

| Activity | Can run in parallel? |
|---|---|
| Idea capture | Yes — any time, any project |
| Classification | Yes — planning agents handle it |
| Prioritization | Yes — roadmap for multiple projects |
| Spec creation | Yes — specs for future work |
| Implementation | No — one project at a time |
| Review | Yes — review previous work while planning next |
| Content generation | Yes — independent of build pipeline |

### Factory-level vs. App-level work

| Scope | What it means | Examples |
|---|---|---|
| factory-level | Changes to the AutoGen system itself | New agent, new template, pipeline improvement |
| app-level | Changes to a specific app (e.g. AskFin) | New screen, new service, UI change |
| future-product | Work for a product that doesn't exist yet | Android version, web app, new SaaS |

**Rule**: Factory-level work improves all projects. App-level work improves one project. Prioritize factory-level work when it unblocks multiple projects.

### When to use the pipeline vs. direct implementation

| Situation | Approach |
|---|---|
| Simple, well-defined feature | Pipeline (`python main.py ...`) |
| Complex system expansion | Direct implementation + pipeline for memory/review |
| Documentation only | Direct implementation (no pipeline needed) |
| Planning / classification | Direct or pipeline (planning agents) |
| Content generation | Direct (tell Claude what to generate) |

### Extraction guard: max 10 files

The pipeline aborts extraction when more than 10 files are detected.
This is intentional — it prevents boilerplate code from being written.

When extraction aborts:
- Memory is still saved (decisions, architecture, implementation, review notes)
- No Swift files are written
- The actual implementation should be done directly

This is normal and expected for complex features.

---

## Managing Multiple Projects

### Register a new project

```
Register a new project in the factory:
- ID: my-new-app
- Name: My New App
- Platform: android
- Description: [what it is]
```

### Switch context between projects

All factory stores support filtering by project:

```python
ideas.by_project("askfin")      # Ideas for AskFin
specs.by_project("factory-core") # Specs for factory
content.by_project("my-new-app") # Content for new app
```

### Project lifecycle

```
planning → active → mvp-complete → released → archived
```

---

## Ecosystem Monitoring

### Add a watch event

```
New ecosystem change detected:
- Xcode 16.2 requires minimum iOS 17
- Affects: askfin
- Severity: medium
- Deadline: 2026-06-01

Add to watch events.
```

### Review the watch dashboard

```
Generate the watch dashboard.
Group by urgency: Now / Soon / Later / Info.
```

---

## Quick Reference

### File Locations

| What | Where |
|---|---|
| Ideas | `factory/ideas/idea_store.json` |
| Projects | `factory/projects/project_registry.json` |
| Specs | `factory/specs/spec_store.json` |
| Content | `content/content_store.json` |
| Watch Events | `watch/watch_events.json` |
| A11Y Reports | `accessibility/accessibility_reports.json` |
| Agent Roles | `config/agent_roles.json` |
| Agent Toggles | `config/agent_toggles.json` |
| Pipeline Logs | `logs/driveai_run_*.txt` |
| Sprint Reports | `delivery/exports/run_*/sprint_report.md` |

### ID Formats

| Store | Format | Example |
|---|---|---|
| Ideas | IDEA-NNN | IDEA-001 |
| Specs | SPEC-NNN | SPEC-001 |
| Content | CONTENT-NNN | CONTENT-001 |
| Watch | WATCH-NNN | WATCH-001 |
| Accessibility | A11Y-NNN | A11Y-001 |

### Status Lifecycles

| Store | Lifecycle |
|---|---|
| Ideas | inbox → classified → prioritized → spec-ready → done / blocked / parked |
| Specs | draft → review → approved → in-progress → done / rejected |
| Content | draft → review → approved → published → archived |
| Watch | new → acknowledged → in-progress → resolved / dismissed |
| A11Y | new → acknowledged → fixed / wont_fix / false_positive |

---

## Current System State (2026-03-09)

- **Agents**: 12 (all active)
- **Projects**: 2 (askfin: mvp-complete, factory-core: active)
- **Ideas**: 5 (2 inbox, 3 classified)
- **Specs**: 0 (empty, ready for use)
- **Content**: 0 (empty, ready for use)
- **Watch Events**: 0 (empty, ready for use)
- **A11Y Reports**: 0 (empty, ready for use)
- **AskFin MVP**: structurally complete, ready for real testing
