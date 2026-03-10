# Factory Control Center

Last Updated: 2026-03-10

---

## What It Is

The Factory Control Center is a lightweight browser-based dashboard for the AI App Factory.
It provides read-only visibility into all factory stores — ideas, projects, specs, compliance, orchestration plans, and more.

Built with Python + Streamlit. Designed to run on the existing Ubuntu/Docker server alongside other services.

---

## Pages

| Page | What it shows |
|---|---|
| Overview | KPI metrics, alerts banner, blocked items, project readiness, idea pipeline, recent activity, opportunities/watch summary, data store health |
| Ideas | All ideas with filters (status, priority, project) |
| Projects | Status groups, per-project steering metrics (ideas/specs/plans/compliance/a11y), latest plan info, bootstrapped projects |
| Specs | Implementation specs with filters |
| Opportunities | Discovered opportunities by category/status |
| Watch Events | Ecosystem changes by severity/status |
| Compliance | Legal/regulatory reports by risk level |
| Accessibility | A11Y findings by issue type/severity |
| Orchestration | Execution plans with steps, blockers, risks |
| Content | Marketing copy, scripts, release notes |
| Activity Feed | Chronological event feed across all stores with filters (source, project, severity) |
| Agent Memory | Browse agent memory entries (decisions, architecture notes, implementation notes, review notes) with category/agent/keyword filters |

### Overview Sections

| Section | Purpose |
|---|---|
| KPI Row | Total counts for all 10 stores + agent count |
| Alerts Banner | Count of items needing attention (red/green) |
| Alerts & Blocked Items | High-priority ideas, blocked plans, high-risk compliance, critical watch events, external review needed, critical a11y |
| Project Readiness | Per-project expandable cards with idea/spec/plan/compliance/a11y metrics |
| Idea Pipeline | Status flow counts (inbox → classified → prioritized → spec-ready → done/blocked/parked) |
| Recent Activity | Preview of latest 10 feed events (full feed on Activity Feed page) |
| Opportunities & Watch | Active opportunities and unresolved watch events |
| Agent Memory Snapshot | Category counts + 5 most recent memory notes (full explorer on Agent Memory page) |
| Data Store Health | Per-store exists/count/last-modified (collapsed) |

---

## Architecture

```
control_center/
├── app.py                    # Main overview page
├── store_reader.py           # Read-only access to all JSON stores
├── activity_feed.py          # Normalized event feed aggregator
├── requirements.txt          # streamlit
├── Dockerfile
├── docker-compose.yml
├── .streamlit/
│   └── config.toml           # Dark theme, headless, poll watcher
└── pages/
    ├── 1_Ideas.py
    ├── 2_Projects.py
    ├── 3_Specs.py
    ├── 4_Opportunities.py
    ├── 5_Watch_Events.py
    ├── 6_Compliance.py
    ├── 7_Accessibility.py
    ├── 8_Orchestration.py
    ├── 9_Content.py
    ├── 10_Activity_Feed.py
    └── 11_Agent_Memory.py
```

### Data Flow

```
Factory JSON Stores (read-only)
  ├── factory/ideas/idea_store.json
  ├── factory/projects/project_registry.json
  ├── factory/specs/spec_store.json
  ├── content/content_store.json
  ├── watch/watch_events.json
  ├── accessibility/accessibility_reports.json
  ├── compliance/compliance_reports.json
  ├── opportunities/opportunity_store.json
  ├── orchestration/orchestration_plan_store.json
  ├── bootstrap/project_store.json
  └── config/agent_toggles.json
         │
         ▼
  StoreReader (store_reader.py)
         │
         ▼
  Streamlit Pages (app.py + pages/)
```

The StoreReader resolves the factory root via:
1. `FACTORY_ROOT` environment variable (Docker)
2. Parent of `control_center/` directory (local dev)

### Activity Feed

The Activity Feed (`activity_feed.py`) aggregates events from all factory stores into a normalized chronological feed. Each event has:

| Field | Description |
|---|---|
| event_type | Human-readable label (e.g. "Idea Created", "Compliance Warning", "Plan Approved") |
| source_store | Which store it came from (e.g. "ideas", "compliance") |
| ref_id | Item ID (e.g. "IDEA-001", "LEGAL-002") |
| title | Item title or description |
| project | Linked project or "—" |
| severity | Priority/severity/risk level or "—" |
| timestamp | Date for chronological sorting |

Event types are derived from each item's current status:

| Source | Example Events |
|---|---|
| Ideas | Idea Created, Idea Classified, Idea Prioritized, Idea Blocked |
| Specs | Spec Drafted, Spec Approved, Spec In Progress, Spec Completed |
| Orchestration | Plan Created, Plan Approved, Plan Executing, Plan Completed |
| Opportunities | Opportunity Detected, Opportunity Evaluated, Opportunity Accepted |
| Watch Events | Watch Alert, Watch Acknowledged, Watch Resolved |
| Compliance | Compliance Warning, Compliance Reviewed, Compliance Blocker |
| Accessibility | Accessibility Warning, Accessibility Fixed |
| Content | Content Draft Created, Content Published |
| Bootstrap | Project Bootstrapped, Project Released |

The feed is **read-only** and **derived** — no separate event store is needed. Events are aggregated fresh on each page load from existing JSON stores.

The Overview page shows a preview of the latest 10 events. The dedicated Activity Feed page shows up to 100 events with filters for source, project, and severity.

---

## Running Locally

```bash
cd control_center
pip install -r requirements.txt
streamlit run app.py --server.port=8502
```

Opens at `http://localhost:8502`.

---

## Deploying on Server (Docker)

### Option 1: docker-compose (recommended)

```bash
# On the server, from the factory repo root
cd control_center

# Build and start
docker compose up -d --build

# Check status
docker compose ps
docker compose logs -f factory-control-center
```

The dashboard runs on port 8502. The factory repo is mounted read-only at `/data`.

### Option 2: Standalone docker build

```bash
cd control_center
docker build -t factory-control-center .
docker run -d \
  --name factory-control-center \
  -p 8502:8502 \
  -v /path/to/DriveAI-AutoGen:/data:ro \
  --memory=256m \
  --cpus=0.5 \
  --restart=unless-stopped \
  factory-control-center
```

### Exposing via Cloudflare Tunnel

Add a public hostname in the Cloudflare dashboard or cloudflared config:
- Service: `http://localhost:8502`
- Hostname: e.g. `factory.yourdomain.com`

---

## Resource Usage

- **RAM**: ~80-120 MB typical (256 MB limit set in docker-compose)
- **CPU**: minimal (0.5 CPU limit, mostly idle)
- **Disk**: ~200 MB Docker image (Python slim + Streamlit)
- **Network**: minimal (reads local JSON files, no external API calls)

No background workers, no database, no LLM dependency.

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `FACTORY_ROOT` | parent of `control_center/` | Path to the factory repo root |

### Theme

Dark theme configured in `.streamlit/config.toml`. Matches the futuristic aesthetic of AskFin.

---

## Read-Only Behavior

The Control Center is strictly read-only in v1:
- All JSON stores are mounted as read-only volumes in Docker (`ro` flag)
- StoreReader never writes to any file
- No database is used — data is read directly from JSON on every page load
- Changes made via Claude/CLI/pipeline are visible on next browser refresh

---

## Expected Folder Mount

The Docker volume mount expects the factory repo root at `/data`. The StoreReader looks for:

```
/data/
├── factory/ideas/idea_store.json
├── factory/projects/project_registry.json
├── factory/specs/spec_store.json
├── content/content_store.json
├── watch/watch_events.json
├── accessibility/accessibility_reports.json
├── compliance/compliance_reports.json
├── opportunities/opportunity_store.json
├── orchestration/orchestration_plan_store.json
├── bootstrap/project_store.json
├── config/agent_toggles.json
└── main.py (used as repo marker)
```

Missing stores are handled gracefully — the dashboard shows empty states instead of errors.

---

## Troubleshooting

### Dashboard shows "Factory root not found"
- Check the `FACTORY_ROOT` env var or volume mount
- Verify the mounted path contains the factory repo (look for `main.py` or `config/agent_toggles.json`)
- Docker: `docker exec factory-control-center ls /data/main.py`

### Dashboard shows 0 for everything
- Stores may be empty (normal for a fresh factory)
- Check the "Data Store Health" expander on the Overview page
- Verify mount: `docker exec factory-control-center ls /data/factory/ideas/`

### Container keeps restarting
- Check logs: `docker logs factory-control-center --tail 50`
- Common cause: missing `curl` in image (needed for healthcheck) — fixed in Dockerfile
- Memory limit too low: increase `mem_limit` if needed (256 MB is usually enough)

### Pages load slowly
- Normal on first load (Streamlit cold start ~3-5s)
- Subsequent page switches are fast
- If persistently slow: check if JSON files are very large

### Updating after factory changes
- Changes from Claude/CLI/pipeline are picked up on next page load
- No restart needed — Streamlit reads JSON files fresh on each request
- For Docker: the volume mount is live, no rebuild needed for data changes
- For code changes: `docker compose up -d --build`

---

## V1 Limitations

- Read-only (no editing factory stores from the dashboard)
- No authentication (rely on Cloudflare Access or network-level security)
- No real-time auto-refresh (manual browser refresh to see changes)
- No historical trends or charts (shows current state only)

---

## Future Ideas (V2+)

- Write actions (transition statuses, create ideas from dashboard)
- Authentication (Streamlit auth or Cloudflare Access)
- Auto-refresh / WebSocket updates
- Pipeline run history and log viewer
- Charts and trend visualizations
- Agent activity timeline
