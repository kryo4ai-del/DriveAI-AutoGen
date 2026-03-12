# Factory Operating Guide

Last Updated: 2026-03-10

---

## What This Guide Covers

How to use the AI App Factory from raw idea to finished product.
Practical workflows, prompts, and rules for working with the 20-agent multi-platform system.

---

## System Overview

The AI App Factory is a multi-agent development system built on AutoGen.

```
19 Active Agents (powered by Anthropic Claude — Sonnet + Haiku):
  2 Planning       — ProductStrategist, Roadmap
  1 Bootstrap      — ProjectBootstrap
  1 Orchestration  — AutonomousProjectOrchestrator
  1 Content        — ContentScript
  1 Discovery      — Opportunity
  1 Compliance     — LegalRisk
  1 Monitoring     — ChangeWatch
  1 Quality        — Accessibility
  1 Strategy       — StrategyReportAgent
  1 Knowledge      — ResearchMemoryGraph
  1 Research       — AutoResearchAgent
  1 Cost/Routing   — ModelRouter + AICostMonitor
  7 Build (iOS)    — Lead, iOSArchitect, SwiftDeveloper, Reviewer, BugHunter, Refactor, TestGenerator

4 Disabled Agents (not needed for iOS-only):
  AndroidArchitect, KotlinDeveloper, WebArchitect, WebAppDeveloper
```

```

```
Data Stores:
  factory/ideas/idea_store.json       — Ideas
  factory/projects/project_registry.json — Projects
  factory/specs/spec_store.json       — Specs
  content/content_store.json          — Content
  watch/watch_events.json             — Watch Events
  accessibility/accessibility_reports.json — A11Y Reports
  opportunities/opportunity_store.json   — Opportunities
  compliance/compliance_reports.json     — Compliance Reports
  bootstrap/project_store.json           — Bootstrapped Projects
  orchestration/orchestration_plan_store.json — Execution Plans
  radar/radar_sources.json               — Radar Sources
  radar/radar_hits.json                  — Radar Hits
  costs/cost_usage.json                  — AI Usage Log
  costs/cost_summary.json                — Daily Cost Summaries
  strategy/weekly_reports.json            — Weekly Strategy Reports
  research_graph/graph_nodes.json         — Knowledge Graph Nodes
  research_graph/graph_edges.json         — Knowledge Graph Edges
  research_reports/research_reports.json   — Research Reports
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
| Opportunities | `opportunities/opportunity_store.json` |
| Compliance | `compliance/compliance_reports.json` |
| Bootstrap | `bootstrap/project_store.json` |
| Orchestration | `orchestration/orchestration_plan_store.json` |
| Radar Sources | `radar/radar_sources.json` |
| Radar Hits | `radar/radar_hits.json` |
| AI Usage Log | `costs/cost_usage.json` |
| Cost Summaries | `costs/cost_summary.json` |
| Cost Budgets | `config/cost_budgets.json` |
| Strategy Reports | `strategy/weekly_reports.json` |
| Strategy HTML | `strategy/html/strategy_YYYY-WNN.html` |
| Graph Nodes | `research_graph/graph_nodes.json` |
| Graph Edges | `research_graph/graph_edges.json` |
| Research Reports | `research_reports/research_reports.json` |
| Model Routing | `config/model_routing.json` |
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
| Opportunities | OPP-NNN | OPP-001 |
| Compliance | LEGAL-NNN | LEGAL-001 |
| Bootstrap | PROJ-NNN | PROJ-001 |
| Orchestration | PLAN-NNN | PLAN-001 |
| Radar Sources | RSRC-NNN | RSRC-001 |
| Radar Hits | RADAR-NNN | RADAR-001 |
| AI Usage | COST-NNNN | COST-0001 |
| Strategy Reports | STR-NNN | STR-001 |
| Graph Nodes | GNODE-NNNN | GNODE-0001 |
| Graph Edges | GEDGE-NNNN | GEDGE-0001 |
| Research Reports | RES-NNN | RES-001 |

### Status Lifecycles

| Store | Lifecycle |
|---|---|
| Ideas | inbox → classified → prioritized → spec-ready → done / blocked / parked |
| Specs | draft → review → approved → in-progress → done / rejected |
| Content | draft → review → approved → published → archived |
| Watch | new → acknowledged → in-progress → resolved / dismissed |
| A11Y | new → acknowledged → fixed / wont_fix / false_positive |
| Opportunities | new → evaluated → accepted → idea_created / rejected / deferred |
| Compliance | new → reviewed → mitigated / accepted / blocked / dismissed |
| Bootstrap | created → planning → in_development → mvp_complete → released / paused / archived |
| Orchestration | draft → approved → executing → completed / cancelled |
| Radar Hits | new → evaluated → promising → opportunity_created / dismissed / expired |
| Strategy Reports | draft → review → published → archived |
| Research Reports | draft → review → published → archived / superseded |

---

## Opportunity Radar

The Opportunity Radar is a lightweight external signal intake layer. It collects raw product opportunity signals from external sources (Product Hunt, Hacker News, newsletters, competitors, etc.) before they become trends or opportunities.

**Key difference**: Radar catches raw external signals. Trends detect patterns from internal data. Opportunities are evaluated product ideas ready for action.

**Flow**: External signal → Radar Hit → (score/evaluate) → Opportunity → Idea → Spec

### Add a radar source

```
Neue Radar-Quelle:
- Name: Product Hunt AI Category
- Category: product_hunt
- URL: https://producthunt.com/topics/artificial-intelligence
Add to radar sources.
```

### Add a radar hit

```
Neuer Radar-Hit:
- Title: AI-powered budget tracker trending on PH
- Category: new_product
- Source: RSRC-001
- Summary: 500+ upvotes, finance niche, subscription model
- Relevance: 0.8
- Platforms: ios, web
Add to radar hits.
```

### Review promotable hits

```
Show all promotable radar hits (evaluated/promising + score >= 0.70).
Convert the best ones to opportunities.
```

---

## Strategy Reports

The StrategyReportAgent generates a weekly strategic analysis report every Sunday.

**Daily Briefing vs. Strategy Report**:
- **Daily Briefing**: Operational focus — what needs attention today, current alerts, triage actions
- **Strategy Report**: Strategic focus — where is the factory heading, cross-signal insights, risk assessment, growth opportunities

### Generate a strategy report

```bash
python -m strategy.strategy_manager
```

The report aggregates all factory signals: ideas, opportunities, radar hits, trends, projects, compliance, costs, and memory. It produces both a JSON record and a professional HTML report.

### Report content

- **Executive Summary** — system metrics, alert count, overall factory health
- **Strategic Opportunities** — top opportunities + promotable radar hits
- **Emerging Trends** — highest relevance trends
- **Project Status** — per-project readiness with specs/plans/ideas
- **Risk Overview** — compliance risks, critical watch events, blocked plans
- **AI Usage** — weekly cost, model breakdown, budget status
- **Recommended Actions** — prioritized next steps

### Review strategy reports

```
Show the latest strategy report.
What are the top risks and recommended actions?
```

### Scheduling

Reports are designed to run weekly (Sunday). Add to scheduler:

```python
from strategy.strategy_manager import generate_weekly_report
report = generate_weekly_report()
```

Reports are idempotent per week — running twice returns the existing report.

---

## Research Memory Graph

The ResearchMemoryGraph connects all factory entities into a lightweight knowledge graph.

**Why**: Factory stores contain isolated records. The graph layer reveals *how* they relate — which idea came from which trend, which compliance finding affects which project, which radar hit became which opportunity.

### Populate the graph

```bash
python -m research_graph.ingest
```

Reads all factory stores and builds nodes + edges automatically. Idempotent — safe to run multiple times.

### Query connected context

```python
from research_graph.graph_manager import GraphManager
gm = GraphManager()

# What's connected to IDEA-001?
ctx = gm.connected_context("IDEA-001")
print(f"Connections: {ctx['total_connections']}")
for edge in ctx['edges_out']:
    print(f"  → {edge['edge_type']}: {edge['other_entity_id']} ({edge['other_title']})")

# Most connected entities
for n in gm.most_connected(5):
    print(f"  {n['entity_id']}: {n['connection_count']} links")

# Graph overview
print(gm.get_summary())
```

### Relationship types

| Edge | Example |
|---|---|
| derived_from | Idea derived from Trend |
| promoted_to | Radar hit promoted to Opportunity |
| recommended_for | Idea recommended for Project |
| affects | Compliance finding affects Project |
| generated_from | Improvement generated from Watch Event |
| related_to | Trend related to Opportunity (category overlap) |
| linked_to | Strategy report linked to featured entities |
| addresses | Improvement addresses risk |
| blocked_by | Entity blocked by another |
| depends_on | Entity depends on another |

### When to re-run ingestion

Run `python -m research_graph.ingest` after:
- New ideas, opportunities, or trends are created
- Radar hits are promoted to opportunities
- Strategy reports are generated
- New compliance or watch events are added

---

## Research Reports

The AutoResearchAgent generates structured research reports from factory signals — analyzing technologies, tools, architecture patterns, product opportunities, and market trends.

**How it differs from other agents**:
- **ResearchMemoryGraph**: Captures *relationships* between entities (graph of connections)
- **AutoResearchAgent**: Produces *written analysis* (deep-dive research reports)
- **StrategyReportAgent**: Weekly operational/strategic overview across all signals
- **AutoResearchAgent**: Focused deep-dive into a specific topic or category

### Generate a research report

```bash
python -m research.auto_research
```

The agent (`research/auto_research.py`) scans current factory signals — trends, opportunities, radar hits, watch events — and generates focused research reports. Reports are managed by `research_reports/research_manager.py`.

### Report categories

| Category | Focus |
|---|---|
| technology_research | Deep-dive into a specific technology |
| tool_discovery | Evaluation of new tools or services |
| architecture_comparison | Comparing architecture approaches |
| product_opportunity | Analysis of a product opportunity |
| ai_model_evaluation | Evaluation of AI models |
| market_analysis | Market trend analysis |
| general | Uncategorized research |

### Review research reports

```
Show all research reports.
Filter by category: technology_research.
What are the latest findings?
```

### Report lifecycle

```
draft → review → published → archived / superseded
```

Reports can be superseded when a newer report on the same topic is published.

### Programmatic access

```python
from research_reports.research_manager import ResearchManager
mgr = ResearchManager()

# List by category
reports = mgr.by_category("technology_research")

# Get specific report
report = mgr.get_report("RES-001")

# Transition status
mgr.transition("RES-001", "published")
```

---

## ModelRouter & AI Cost Monitor

### Model Routing

The ModelRouter automatically selects the optimal Claude model based on task type (3-tier system):

- **Tier 1 — Sonnet** (high quality): code_generation, architecture, code_review, bug_hunting, refactoring, test_generation
- **Tier 2 — Sonnet** (reasoning): planning, orchestration, content, compliance, accessibility
- **Tier 3 — Haiku** (fast & cheap): classification, summarization, trend_analysis, scoring, labeling, extraction, briefing

```python
from config.llm_config import get_routed_llm_config

# Auto-selects model based on agent role
config = get_routed_llm_config(agent_name="swift_developer")  # → claude-sonnet-4-6
config = get_routed_llm_config(agent_name="product_strategist")  # → claude-haiku-4-5
```

Custom routes can be set in `config/model_routing.json` or via `ModelRouter.update_route()`.

### Cost Tracking

Every AI call should be logged:

```python
from costs.cost_manager import CostManager
mgr = CostManager()
mgr.log_usage("swift_developer", "claude-sonnet-4-6", "code_generation",
              prompt_tokens=2000, completion_tokens=1500,
              estimated_cost=0.0525, project="askfin")
```

### Budget Limits

Configure in `config/cost_budgets.json`:
- `daily_budget`: max USD per day (default: $5.00)
- `monthly_budget`: max USD per month (default: $100.00)

Budget alerts appear in the Daily Briefing and Control Center when thresholds are exceeded.

### Review AI costs

```
Show AI cost summary for today.
Which agents are the most expensive?
Are we within budget?
```

---

## Factory Control Center

A lightweight browser-based dashboard for the AI App Factory.

```
Run locally:
  cd control_center
  pip install -r requirements.txt
  streamlit run app.py --server.port=8502

Run on server (Docker):
  cd control_center
  docker compose up -d --build
```

Dashboard pages: Overview, Ideas, Projects, Specs, Opportunities, Watch Events, Compliance, Accessibility, Orchestration, Content, Activity Feed, Agent Memory, Improvements, Trends, Briefings, Radar, AI Costs, Strategy, Research Graph, Research.

Reads all factory JSON stores (read-only). No database required.

See `docs/factory_control_center.md` for full documentation.

---

## Current System State (2026-03-10)

- **Agents**: 23 (all active — iOS + Android + Web + Orchestration + Strategy + Knowledge + Research)
- **Projects**: 2 (askfin: mvp-complete, factory-core: active)
- **Ideas**: 5 (2 inbox, 3 classified)
- **Specs**: 0 (empty, ready for use)
- **Content**: 0 (empty, ready for use)
- **Watch Events**: 0 (empty, ready for use)
- **A11Y Reports**: 0 (empty, ready for use)
- **Opportunities**: 0 (empty, ready for use)
- **Compliance**: 2 (LEGAL-001 copyright HIGH, LEGAL-002 GDPR MEDIUM)
- **Bootstrap**: 0 (empty, ready for use)
- **Control Center**: v1 (Streamlit, Docker-ready, port 8502)
- **AskFin MVP**: structurally complete, ready for real testing
