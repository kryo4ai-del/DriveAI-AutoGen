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
│   └── config.toml           # Dark theme, headless mode
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

## V1 Limitations

- Read-only (no editing factory stores from the dashboard)
- No authentication (rely on Cloudflare Access or network-level security)
- No real-time updates (refresh browser to see changes)
- No historical trends or charts (shows current state only)

---

## Future Ideas (V2+)

- Write actions (transition statuses, create ideas from dashboard)
- Authentication (Streamlit auth or Cloudflare Access)
- Auto-refresh / WebSocket updates
- Pipeline run history and log viewer
- Charts and trend visualizations
- Agent activity timeline
