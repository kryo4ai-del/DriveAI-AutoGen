# Marketing Phase 1 — Factory Audit Report

> Erstellt: 2026-03-26
> Zweck: Vorbereitung der neuen Marketing-Abteilung
> Modus: Nur lesen, keine Aenderungen vorgenommen

---

## 1. Agent Registry Format

### Datei: `factory/agent_registry.json`

**Root-Struktur:**
```json
{
  "agents": [ ... ],      // Array aller Agents
  "summary": {
    "total": 76,
    "active": 69,
    "disabled": 4,
    "planned": 3,
    "by_department": { ... },   // Department -> Count
    "by_provider": { ... },     // Provider -> Count
    "by_model": { ... }         // Model -> Count
  }
}
```

**Schema eines einzelnen Agent-Eintrags (Beispiel: SWF-01 Trend-Scout):**
```json
{
  "id": "SWF-01",                          // Prefix = Department-Kuerzel
  "name": "Trend-Scout",                   // Anzeigename
  "role": "Market Trend Researcher",       // Rollenbeschreibung
  "department": "Swarm Factory",           // Department-Zuordnung
  "status": "active",                      // active | disabled | planned
  "chapter": "Phase 1",                    // Optional: Swarm-Phase
  "task_type": "research",                 // Aufgabentyp
  "model_tier": "mid",                     // premium | standard | mid | fast | none
  "default_model": "via TheBrain",         // Model oder "via TheBrain" | "none"
  "provider": "dynamic",                   // anthropic | google | dynamic | none
  "routing": "TheBrain",                   // TheBrain | hardcoded | tier_lock=X | no_llm
  "uses_web": true,                        // Braucht Internet-Zugang
  "description": "...",                    // Kurzbeschreibung
  "py_file": "trend_scout.py",            // Python-Implementierung
  "_source": "factory\\pre_production\\agents\\agent.json"  // Quell-JSON
}
```

**Departments aktuell (13):**
| Department | Agents | ID-Prefix |
|---|---|---|
| Asset Forge | 1 | ASF- |
| Brain | 7 | BRN- |
| Code-Pipeline | 22 | CPL- |
| Infrastruktur | 11 | INF- |
| Integration | 1 | INT- |
| Motion Forge | 1 | MOF- |
| QA Forge | 1 | QAF- |
| Scene Forge | 1 | SCF- |
| Signing | 1 | SGN- |
| Sound Forge | 1 | SOF- |
| Store | 1 | STR- |
| Store Prep | 1 | STP- |
| Swarm Factory | 27 | SWF- |

**Gibt es `factory/agent_registry.py`?** NEIN — existiert nicht. Die Registry ist rein JSON-basiert, kein Python-Wrapper.

---

## 2. Agent Toggles Format

### Datei: `config/agent_toggles.json`

**Format:** Flat key-value, Agent-Slug (snake_case) -> boolean
```json
{
  "driveai_lead": true,
  "ios_architect": true,
  "swift_developer": true,
  "reviewer": true,
  "android_architect": false,
  "kotlin_developer": false,
  "web_architect": false,
  "webapp_developer": false,
  ...
}
```

**Aktuell gelistet:** 23 Agents (19 enabled, 4 disabled)

**Auffaelligkeit:** Nur Code-Pipeline Agents sind in den Toggles. Swarm Factory, Brain, Infrastruktur etc. sind NICHT in den Toggles — sie werden direkt ueber `agent_registry.json` Status gesteuert.

---

## 3. Service Registry — Echter Zustand

### Datei: `factory/brain/service_registry.json`

**6 Services registriert:**

| Service | Kategorie | Provider | Status | Kosten/Call |
|---|---|---|---|---|
| DALL-E 3 | image | openai | **active** | $0.04 (1024x1024) |
| Stability AI SDXL | image | stability | **active** | $0.03 (1024x1024) |
| Recraft v3 | image | recraft | **inactive** | $0.02 (SVG/PNG) |
| ElevenLabs SFX | sound | elevenlabs | **active** | $0.01/generation |
| Suno AI | sound | suno | **inactive** | $0.05/track |
| Runway ML Gen-3 | video | runway | **inactive** | $0.10-0.20/video |

**Kategorien mit Fallback-Order:**
- `image`: dalle3 -> stability_sdxl -> recraft_v3
- `sound`: elevenlabs_sfx -> suno_ai
- `animation`: Primär intern via Claude (Lottie JSON)
- `video`: runway_ml

**3 active, 3 inactive.** Keine Draft-Services in der Registry.

### Draft-Adapter: `factory/brain/service_provider/adapters/drafts/`

**8 Draft-Adapter vorhanden:**
1. `black_forest_labs_adapter.py` (Bild — FLUX)
2. `kling_adapter.py` (Video)
3. `leonardo_adapter.py` (Bild)
4. `luma_adapter.py` (Video/3D)
5. `meta_audiocraft_adapter.py` (Audio/Musik)
6. `rive_adapter.py` (Animation)
7. `stability_audio_adapter.py` (Audio)
8. `__init__.py`

**Auffaelligkeit:** Draft-Adapter sind Code-ready aber nicht in der Service-Registry eingetragen. Koennen bei Bedarf aktiviert werden.

---

## 4. Bestehende Department-Strukturen als Referenz

### `factory/pre_production/` (Phase 1 — Research)
```
pre_production/
├── __init__.py              # Version + Docstring
├── agent.json               # SWF-26 CEO-Gate Persona
├── agent_ceo_gate.json      # Duplikat/Alias
├── agents/
│   ├── __init__.py          # Exportiert: extract_keywords
│   ├── _keywords.py         # Keyword-Extraction Helper
│   ├── agent.json           # SWF-01 Trend-Scout Persona
│   ├── agent_audience_analyst.json
│   ├── agent_competitor_scan.json
│   ├── agent_concept_analyst.json
│   ├── agent_legal_research.json
│   ├── agent_memory_agent.json
│   ├── agent_risk_assessment.json
│   ├── agent_trend_scout.json
│   ├── audience_analyst.py
│   ├── competitor_scan.py
│   ├── concept_analyst.py
│   ├── legal_research.py
│   ├── memory_agent.py
│   ├── risk_assessment.py
│   └── trend_scout.py
├── ambition_controller.py   # Ambitions-Steuerung
├── ceo_gate.py              # Kill-or-Go Gate
├── config.py                # Phase-Config
├── memory/                  # Learnings + Run-History
├── output/                  # Projekt-Outputs
├── pipeline.py              # Orchestrator
├── README.md
└── tools/
    └── web_research.py      # SerpAPI Wrapper
```

### `factory/market_strategy/` (Phase 2 — Kapitel 3)
```
market_strategy/
├── __init__.py              # Version + Docstring
├── agents/
│   ├── __init__.py          # Leer (nur Docstring)
│   ├── agent.json           # SWF-08 Plattform-Strategie Persona
│   ├── agent_cost_calculation.json
│   ├── agent_marketing_strategy.json
│   ├── agent_monetization_architect.json
│   ├── agent_platform_strategy.json
│   ├── agent_release_planner.json
│   ├── cost_calculation.py
│   ├── marketing_strategy.py
│   ├── monetization_architect.py
│   ├── platform_strategy.py
│   └── release_planner.py
├── config.py
├── input_loader.py          # Laedt Vorgaenger-Output
├── output/                  # Projekt-Outputs
├── pipeline.py              # Orchestrator
└── README.md
```

### `__init__.py` Exports:
- `pre_production/__init__.py`: Nur `__version__ = "0.1.0"` + Docstring
- `market_strategy/__init__.py`: Nur `__version__ = "0.1.0"` + Docstring
- `pre_production/agents/__init__.py`: `from ._keywords import extract_keywords` → `__all__ = ["extract_keywords"]`
- `market_strategy/agents/__init__.py`: Leer (nur Docstring)

**Pattern:** Departments haben eine flache Struktur mit `agents/` Unterordner fuer Agent-Personas (JSON) + Implementierungen (Python). Pipeline orchestriert alles.

---

## 5. Agent Persona-Files als Referenz

### Beispiel: `factory/pre_production/agents/agent_trend_scout.json`
```json
{
  "id": "SWF-01",
  "name": "Trend-Scout",
  "role": "Market Trend Researcher",
  "department": "Swarm Factory",
  "status": "active",
  "chapter": "Phase 1",
  "task_type": "research",
  "model_tier": "mid",
  "default_model": "via TheBrain",
  "provider": "dynamic",
  "routing": "TheBrain",
  "uses_web": true,
  "description": "Markttrends und Technologie-Entwicklungen via SerpAPI",
  "py_file": "trend_scout.py"
}
```

### Beispiel: `factory/market_strategy/agents/agent_marketing_strategy.json`
```json
{
  "id": "SWF-10",
  "name": "Marketing-Strategie",
  "role": "Marketing Planner",
  "department": "Swarm Factory",
  "status": "active",
  "chapter": "Kapitel 3",
  "task_type": "strategy",
  "model_tier": "mid",
  "default_model": "via TheBrain",
  "provider": "dynamic",
  "routing": "TheBrain",
  "uses_web": true,
  "description": "Go-to-Market Konzept von Pre-Launch bis Post-Launch",
  "py_file": "marketing_strategy.py"
}
```

### Format-Konsistenz:
- **Einheitliches JSON-Schema** ueber alle Departments
- Pflichtfelder: `id`, `name`, `role`, `department`, `status`, `task_type`
- Optionale Felder: `chapter`, `model_tier`, `default_model`, `provider`, `routing`, `uses_web`, `description`, `py_file`
- Brain-Agents haben zusaetzlich: `_source` (wird beim Registry-Build gesetzt)
- Dateiname-Konvention: `agent_<snake_case_name>.json`

---

## 6. TheBrain Schnittstelle

### TaskRouter (`factory/brain/task_router.py`)

**Oeffentliche Methoden:**

| Methode | Signatur | Beschreibung |
|---|---|---|
| `__init__` | `(self, factory_root: str = None)` | Init mit allen Subsystemen |
| `route()` | `(self, request: str, context: dict = None) -> dict` | Hauptmethode: Keyword-Klassifikation + LLM-Fallback |
| `route_and_collect()` | `(self, request: str, context: dict = None) -> dict` | route() + ResponseCollector.process() |
| `diagnose_and_propose()` | `(self) -> dict` | ProblemDetector + SolutionProposer |
| `analyze_gaps()` | `(self) -> dict` | GapAnalyzer Tiefenanalyse |
| `get_extension_roadmap()` | `(self) -> dict` | GapAnalyzer + ExtensionAdvisor |
| `get_available_routes()` | `(self) -> list` | Alle verfuegbaren Routen |

**Routen-Kategorien:** factory_status, capabilities, project_status, maintenance, health_check, repair, service_status, department_task

**Wichtig:** TaskRouter wird von HQ/Assistant aufgerufen, NICHT direkt von Departments. Departments rufen ihre eigenen Agents auf.

### ProviderRouter (`factory/brain/model_provider/provider_router.py`)

**Oeffentliche Methoden:**

| Methode | Signatur | Beschreibung |
|---|---|---|
| `call()` | `(self, model_id, provider, messages, max_tokens=4096, temperature=0.0) -> ProviderResponse` | LLM-Call via LiteLLM |
| `call_with_fallback()` | `(self, primary_model, primary_provider, fallback_model, fallback_provider, messages, **kwargs) -> ProviderResponse` | Primary + Fallback |
| `health_check()` | `(self, provider: str) -> dict` | API Health Check |
| `get_available_providers()` | `(self) -> list[str]` | Verfuegbare Provider |

**ProviderResponse Dataclass:**
```python
@dataclass
class ProviderResponse:
    content: str = ""
    model: str = ""
    provider: str = ""
    input_tokens: int = 0
    output_tokens: int = 0
    cost_usd: float = 0.0
    latency_ms: int = 0
    was_fallback: bool = False
    error: str | None = None
```

### LLM-Call von aussen (Standard-Pattern):
```python
from factory.brain.model_provider import get_model, get_router

# 1. Model waehlen
selection = get_model(profile="standard", expected_output_tokens=8000)

# 2. Router holen
router = get_router()

# 3. Call mit Fallback
response = router.call(
    model_id=selection["model"],
    provider=selection["provider"],
    messages=[{"role": "user", "content": prompt}],
    max_tokens=8000,
)

# 4. Ergebnis
text = response.content
cost = response.cost_usd
```

Jeder Agent nutzt dieses Pattern mit Anthropic-Fallback im except-Block.

---

## 7. Factory-Pfade

### Absoluter Projektpfad (Root):
```
C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\
```

### Output-Verzeichnisse:

**`factory/pre_production/output/`** (Phase 1 Research)
```
003_echomatch/
004_skillsense/
005_brainpuzzle/
005_memerun2026/
```

**`factory/market_strategy/output/`** (Phase 2 Kapitel 3)
```
001_echomatch/
002_skillsense/
003_memerun2026/
```

**`factory/mvp_scope/output/`** (Phase 3 Kapitel 4)
```
001_echomatch/
002_skillsense/
003_memerun2026/
```

**`factory/roadbook_assembly/output/`** (Phase 4 Kapitel 6)
```
001_echomatch/
007_memerun2026/
```

**Namensschema:** `NNN_<projekt-slug>/` — Nummerierung ist pro Department eigenstaendig (nicht global).

**Inhalt pro Output-Ordner:** Markdown-Reports (z.B. `trend_report.md`, `concept_brief.md`, `marketing_strategy.md`, `pipeline_summary.md` etc.)

---

## 8. Namenskonflikte

### Gibt es `factory/marketing/`?
**NEIN** — Verzeichnis existiert nicht. Kein Namenskonflikt.

### Dateien/Module mit "marketing" im Namen:

| Pfad | Typ | Konflikt? |
|---|---|---|
| `factory/market_strategy/` | Department-Verzeichnis | Nein — anderer Name |
| `factory/market_strategy/agents/marketing_strategy.py` | Agent-Implementierung (SWF-10) | Nein — ist Swarm Agent, nicht Department |
| `factory/market_strategy/agents/agent_marketing_strategy.json` | Agent-Persona | Nein — gehört zu market_strategy |
| `factory/market_strategy/output/*/marketing_strategy.md` | Output-Reports | Nein — Projekt-Output |
| `factory/document_secretary/templates/marketing_konzept.py` | PDF-Template | Nein — Document Secretary Template |
| `factory/store_prep/platform_metadata.py` | Referenziert "marketing" in Metadaten | Nein — nur Textinhalt |

**Fazit:** Kein Namenskonflikt. `factory/marketing/` ist frei. Der bestehende `market_strategy` ist ein Swarm-Factory-Department (Kapitel 3), NICHT eine eigenstaendige Marketing-Abteilung.

**Wichtiger Unterschied:**
- `market_strategy` = Swarm Factory Phase 2 Agent (SWF-08 bis SWF-12), analysiert Markt fuer neue Produkte
- `marketing` (neu) = Eigenstaendiges Department fuer laufendes Marketing (Social Media, Content, Campaigns etc.)

---

## 9. HQ Dashboard Anbindung

### Scanner-Verzeichnis: `factory/hq/dashboard/server/scanner/`

**5 Scanner vorhanden:**

| Scanner | Exportierte Funktion | Was wird gescannt |
|---|---|---|
| `health-scanner.js` | `scanFactoryHealth()` | Factory-Gesundheit: Agents, Services, API Keys, Directories |
| `brain-scanner.js` | `scanBrainStatus()` | TheBrain: State Reports, Directives, Brain Agents, Memory |
| `cost-scanner.js` | `scanAgentData(projectId)` | Kosten pro Projekt: LLM-Costs, SerpAPI Credits, Agent-Nutzung |
| `document-scanner.js` | `scanProjectDocuments(projectId)` | Projekt-Dokumente: PDFs, Reports, Outputs |
| `summary-parser.js` | `parsePipelineSummary(content)`, `parseGateDecision(content)` | Parst Pipeline-Summaries und Gate-Entscheidungen |

### Allgemeines Scanner-Pattern:

```javascript
// 1. Scanner-Datei: server/scanner/<name>-scanner.js
const fs = require('fs');
const path = require('path');
const config = require('../config');  // FACTORY_BASE, PATHS

function scanXyz() {
  // Liest JSON/Markdown aus dem Filesystem
  const dataPath = path.join(config.FACTORY_BASE, 'factory', '...');
  const data = JSON.parse(fs.readFileSync(dataPath, 'utf-8'));

  // Strukturiert und gibt zurueck
  return {
    status: '...',
    items: [...],
    timestamp: new Date().toISOString(),
  };
}

module.exports = { scanXyz };

// 2. API-Route: server/api/<name>.js
const express = require('express');
const router = express.Router();
const { scanXyz } = require('../scanner/<name>-scanner');

router.get('/', (req, res) => {
  try {
    const data = scanXyz();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

// 3. Registration: server/index.js
const xyzApi = require('./api/<name>');
app.use('/api/<name>', xyzApi);

// 4. Frontend: client/src/components/<Name>/<Name>View.jsx
// React Component mit useState + useEffect + fetch('/api/<name>')
// 30s Auto-Refresh, Factory-Tailwind-Klassen
```

### Wie wuerde ein Marketing-Scanner eingebunden werden:

1. `server/scanner/marketing-scanner.js` erstellen — liest `factory/marketing/output/` + Metriken
2. `server/api/marketing.js` erstellen — Express Router GET /api/marketing
3. In `server/index.js` registrieren: `app.use('/api/marketing', marketingApi)`
4. `client/src/components/Marketing/MarketingView.jsx` erstellen
5. In `App.jsx` Section + Import hinzufuegen
6. In `Sidebar.jsx` Icon registrieren

**Kein Code wurde erstellt — nur Pattern-Beschreibung.**

---

## Zusammenfassung & Auffaelligkeiten

1. **Kein Namenskonflikt** — `factory/marketing/` ist frei
2. **Agent Registry ist JSON-only** — kein Python-Wrapper, manuell gepflegt
3. **Agent Toggles nur fuer Code-Pipeline** — Swarm/Brain/Infra Agents werden anders gesteuert
4. **Department-Pattern ist klar** — `__init__.py` + `agents/` (JSON + .py) + `pipeline.py` + `config.py` + `output/`
5. **TheBrain-Anbindung** ueber `get_model()` + `get_router()` + `router.call()` mit Anthropic-Fallback
6. **8 Draft-Adapter warten auf Aktivierung** — koennen fuer Marketing-Assets relevant sein
7. **Dashboard-Anbindung** folgt klarem 4-Schritt-Pattern (Scanner → API → Index → React)
8. **ID-Prefix fuer Marketing** muss noch vergeben werden (MKT-? MRK-? MAR-?)
9. **Bestehender SWF-10 "Marketing-Strategie"** ist ein Swarm-Agent, KEIN Department — kein Konflikt aber Verwechslungsgefahr in der Kommunikation
