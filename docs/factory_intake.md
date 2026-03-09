# Factory Idea Intake System

Last Updated: 2026-03-09

---

## Purpose

Structured system for capturing, classifying, and prioritizing ideas across all AI App Factory projects.

Bridges the gap between raw ideas and implementation-ready tasks.

---

## Folder Structure

```
factory/
├── ideas/
│   └── idea_store.json       # All ideas with metadata
├── projects/
│   └── project_registry.json # Registered projects
├── specs/                    # Future: spec documents for spec-ready ideas
└── idea_manager.py           # Python API for idea + project CRUD
```

---

## Idea Lifecycle

```
inbox → classified → prioritized → spec-ready → done
                                              → blocked
                                              → parked
```

### Status Definitions

| Status | Meaning |
|---|---|
| inbox | Raw idea captured, not yet evaluated |
| classified | Scope, type, and project assigned by ProductStrategistAgent |
| prioritized | Priority (now/next/later/blocked) assigned by RoadmapAgent |
| spec-ready | Specification written, ready for implementation pipeline |
| blocked | Waiting for external dependency |
| done | Implemented and verified |
| parked | Intentionally deferred (not rejected, revisit later) |

---

## Idea Fields

| Field | Type | Description |
|---|---|---|
| id | string | Auto-generated: IDEA-001, IDEA-002, ... |
| title | string | Short descriptive name |
| raw_idea | string | Original idea text as captured |
| source | string | Where it came from: session, roadmap, strategy, user, external |
| project | string | Project ID from registry (e.g. askfin, factory-core) |
| scope | enum | app-level, factory-level, future-product |
| type | enum | feature, agent, infrastructure, marketing, content, monetization, experiment |
| priority | enum | now, next, later, blocked |
| status | enum | inbox, classified, prioritized, spec-ready, blocked, done, parked |
| notes | string | Free-text notes, dependencies, context |
| created_at | date | ISO date when idea was captured |

---

## Project Registry

Projects are registered in `factory/projects/project_registry.json`.

| Field | Type | Description |
|---|---|---|
| id | string | Unique project identifier (lowercase, hyphenated) |
| name | string | Display name |
| description | string | What the project is |
| platform | string | iOS, Android, web, python, etc. |
| status | string | planning, active, mvp-complete, released, archived |
| active | bool | Whether the project is actively worked on |
| notes | string | Additional context |

### Current Projects

| ID | Name | Platform | Status |
|---|---|---|---|
| askfin | AskFin | iOS | mvp-complete |
| factory-core | AI App Factory Core | python | active |

To add a new project:
```python
from factory.idea_manager import ProjectRegistry
registry = ProjectRegistry()
registry.add_project("new-app", "New App Name", platform="android", description="...")
```

---

## How to Capture Ideas

### Manual (edit JSON directly)

Add an entry to `factory/ideas/idea_store.json`:
```json
{
  "id": "IDEA-006",
  "title": "Your Idea Title",
  "raw_idea": "Detailed description of the idea",
  "source": "session",
  "project": "",
  "scope": "",
  "type": "",
  "priority": "later",
  "status": "inbox",
  "notes": "",
  "created_at": "2026-03-09"
}
```

### Programmatic (Python API)

```python
from factory.idea_manager import IdeaManager
mgr = IdeaManager()
idea = mgr.add_idea(
    title="My New Feature",
    raw_idea="Detailed description...",
    source="session",
    project="askfin",
)
# Returns the idea dict with auto-generated ID
```

### During Agent Runs

Planning agents (ProductStrategist, Roadmap) receive the idea summary in their task context automatically. Ideas in inbox status are highlighted for classification.

---

## How Ideas Move Through the Pipeline

### Step 1: Capture (→ inbox)
- Human or agent adds idea to idea_store.json
- Status: inbox
- Scope, type, priority may be empty

### Step 2: Classification (→ classified)
- ProductStrategistAgent evaluates the idea
- Assigns: scope, type, project, initial priority
- Status: classified

### Step 3: Prioritization (→ prioritized)
- RoadmapAgent places the idea into a phase (now/next/later/blocked)
- Considers dependencies and execution order
- Status: prioritized

### Step 4: Spec (→ spec-ready)
- Detailed spec written (in factory/specs/ or docs/)
- Ready for the implementation pipeline
- Status: spec-ready

### Step 5: Implementation (→ done)
- Picked up by LeadAgent + engineering agents
- Implemented through normal pipeline
- Status: done

---

## How Planning Agents Use the System

### ProductStrategistAgent

Receives idea and project summaries in task context.
Evaluates new ideas using structured output format.
Assigns scope, type, project, and initial priority.

### RoadmapAgent

Receives idea and project summaries in task context.
References ideas by ID (IDEA-001, etc.) in roadmap output.
Maps idea priorities to roadmap phases.

### LeadAgent

Uses spec-ready ideas as implementation tasks.
Delegates to architecture and engineering agents.

---

## Integration Points

| Component | How it connects |
|---|---|
| task_manager.py | Loads IdeaManager + ProjectRegistry, injects summaries into task context |
| ProductStrategistAgent | System prompt references idea fields, scopes, types, statuses |
| RoadmapAgent | System prompt references idea IDs and priority-to-phase mapping |
| factory/idea_manager.py | Python API for all CRUD operations |

---

## Future Extensions

- CLI commands for idea management (--add-idea, --list-ideas, --classify)
- Spec template generation for spec-ready ideas
- Automatic idea capture from agent conversation analysis
- Cross-project dependency tracking
- Idea voting / impact scoring
