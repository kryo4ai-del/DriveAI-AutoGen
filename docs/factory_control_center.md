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
| Overview | KPI metrics, status breakdowns, high-priority items |
| Ideas | All ideas with filters (status, priority, project) |
| Projects | Registered projects + bootstrapped projects |
| Specs | Implementation specs with filters |
| Opportunities | Discovered opportunities by category/status |
| Watch Events | Ecosystem changes by severity/status |
| Compliance | Legal/regulatory reports by risk level |
| Accessibility | A11Y findings by issue type/severity |
| Orchestration | Execution plans with steps, blockers, risks |
| Content | Marketing copy, scripts, release notes |

---

## Architecture

```
control_center/
├── app.py                    # Main overview page
├── store_reader.py           # Read-only access to all JSON stores
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
    └── 9_Content.py
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
