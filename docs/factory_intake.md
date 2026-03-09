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

## Factory Spec Pipeline

The spec pipeline transforms prioritized ideas into structured implementation specs.

### Spec Lifecycle

```
draft → review → approved → in-progress → done
                                        → rejected
```

| Status | Meaning |
|---|---|
| draft | Spec created, fields may be incomplete |
| review | Spec complete, awaiting approval |
| approved | Ready for implementation pipeline |
| in-progress | Being implemented by engineering agents |
| done | Implemented and verified |
| rejected | Not viable, will not be implemented |

### Spec Fields

| Field | Type | Description |
|---|---|---|
| spec_id | string | Auto-generated: SPEC-001, SPEC-002, ... |
| linked_idea_id | string | References idea from idea_store (e.g. IDEA-001) |
| title | string | Short descriptive name |
| project | string | Project ID (e.g. askfin, factory-core) |
| type | string | feature, agent, infrastructure, etc. |
| scope | string | app-level, factory-level, future-product |
| priority | string | now, next, later, blocked |
| status | string | draft, review, approved, in-progress, done, rejected |
| summary | string | Brief description of what the spec covers |
| goal | string | What this spec aims to achieve |
| in_scope | list | What is included in this spec |
| out_of_scope | list | What is explicitly excluded |
| dependencies | list | Other specs/ideas/systems this depends on |
| affected_systems | list | Which systems/modules are impacted |
| acceptance_criteria | list | Conditions that must be met for completion |
| risks | list | Known risks and mitigation notes |
| suggested_template | string | Recommended AutoGen template (feature, screen, service, viewmodel) |
| suggested_agents | list | Recommended agent configuration for implementation |
| notes | string | Additional context |
| created_at | date | ISO date when spec was created |

### Storage

```
factory/
├── specs/
│   └── spec_store.json       # All specs with metadata
└── spec_manager.py            # Python API for spec CRUD
```

### Creating Specs

#### From an Idea (programmatic)

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
    acceptance_criteria=["Model loads successfully", "Prediction returns top-3 signs"],
    suggested_template="service",
    suggested_agents=["ios_architect", "swift_developer", "reviewer"],
)
# Also transition the idea to spec-ready:
ideas.transition("IDEA-001", "spec-ready")
```

#### Manual (standalone)

```python
from factory.spec_manager import SpecManager

specs = SpecManager()
spec = specs.create_spec(
    title="Offline Rule Engine",
    linked_idea_id="IDEA-002",
    project="askfin",
    goal="Local rule-based answers without LLM dependency",
    acceptance_criteria=["Handles top 50 question types", "Works fully offline"],
)
```

### How Specs Connect to Ideas

```
IDEA-001 (prioritized) → SPEC-001 (draft → approved) → Implementation pipeline
```

When a spec is created from an idea:
1. `linked_idea_id` references the source idea
2. The idea status transitions to `spec-ready`
3. The spec goes through its own lifecycle (draft → approved)
4. Once approved, it enters the implementation pipeline

### How Planning Agents Use Specs

#### ProductStrategistAgent
- Recommends spec creation for ideas reaching `prioritized` status with `now` priority
- Evaluates whether spec scope is appropriate

#### RoadmapAgent
- References spec IDs (SPEC-001, etc.) alongside idea IDs in roadmap output
- Flags `now`-phase ideas that lack approved specs
- Uses spec dependencies to inform execution order

#### LeadAgent
- Uses approved specs as implementation task definitions
- Extracts goal, acceptance criteria, and suggested agents from the spec

### Integration Points

| Component | How it connects |
|---|---|
| factory/spec_manager.py | Python API for spec CRUD |
| task_manager.py | Loads SpecManager, injects spec summaries into task context |
| ProductStrategistAgent | System prompt references spec fields and recommends spec creation |
| RoadmapAgent | System prompt references spec IDs and uses spec readiness for planning |

---

## Future Extensions

- CLI commands for idea management (--add-idea, --list-ideas, --classify)
- CLI commands for spec management (--create-spec, --list-specs, --approve-spec)
- Automatic spec generation from agent conversation analysis
- Cross-project dependency tracking
- Idea voting / impact scoring
- Spec templates per type (feature spec, service spec, infrastructure spec)
