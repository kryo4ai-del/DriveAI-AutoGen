const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const config = require('../config');
const { exec } = require('child_process');

let cachedRegistry = null;
let cacheTime = 0;
const CACHE_TTL = 60000; // 1 minute

function loadRegistry() {
  const now = Date.now();
  if (cachedRegistry && now - cacheTime < CACHE_TTL) return cachedRegistry;

  const jsonPath = path.join(config.FACTORY_BASE, 'factory', 'agent_registry.json');

  // Try JSON file first
  if (fs.existsSync(jsonPath)) {
    try {
      cachedRegistry = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));
      cacheTime = now;
      return cachedRegistry;
    } catch (e) { /* fall through */ }
  }

  // Generate JSON via Python
  try {
    const { execSync } = require('child_process');
    execSync('python -c "from factory.agent_registry import export_json; export_json()"',
      { cwd: config.FACTORY_BASE, timeout: 10000 });
    if (fs.existsSync(jsonPath)) {
      cachedRegistry = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));
      cacheTime = now;
      return cachedRegistry;
    }
  } catch (e) { /* fall through */ }

  return { agents: [], summary: {} };
}

// GET /api/team
router.get('/', (req, res) => {
  try {
    const data = loadRegistry();
    const { department, provider, status } = req.query;

    let agents = data.agents || [];
    if (department) agents = agents.filter(a => a.department === department);
    if (provider) agents = agents.filter(a => a.provider === provider);
    if (status && status !== 'all') agents = agents.filter(a => a.status === status);

    res.json({ agents, summary: data.summary, count: agents.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── Enriched data (classifier + matcher) ─────────────────────────
let cachedEnriched = null;
let enrichedCacheTime = 0;
const ENRICHED_CACHE_TTL = 300000; // 5 minutes

function loadEnrichedRegistry() {
  const now = Date.now();
  if (cachedEnriched && now - enrichedCacheTime < ENRICHED_CACHE_TTL) return cachedEnriched;

  try {
    const { execSync } = require('child_process');
    const script = path.join(config.FACTORY_BASE, 'factory', 'brain', 'model_provider', 'team_enrichment.py');
    const output = execSync(`python "${script}"`, {
      cwd: config.FACTORY_BASE,
      timeout: 30000,
      encoding: 'utf-8',
      maxBuffer: 5 * 1024 * 1024,
    });
    cachedEnriched = JSON.parse(output);
    enrichedCacheTime = now;
    return cachedEnriched;
  } catch (e) {
    console.error('Enrichment failed, falling back to basic registry:', e.message);
    const basic = loadRegistry();
    return { ...basic, enrichment_stats: null };
  }
}

// GET /api/team/enriched
router.get('/enriched', (req, res) => {
  try {
    const data = loadEnrichedRegistry();
    const { department, provider, status, tier } = req.query;

    let agents = data.agents || [];
    if (department && department !== 'Alle') agents = agents.filter(a => a.department === department);
    if (provider) agents = agents.filter(a => (a.matched_provider || a.provider) === provider);
    if (status && status !== 'all') agents = agents.filter(a => a.status === status);
    if (tier) agents = agents.filter(a => a.auto_tier === tier);

    res.json({
      agents,
      summary: data.summary,
      enrichment_stats: data.enrichment_stats,
      count: agents.length,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/team/:id
router.get('/:id', (req, res) => {
  try {
    const data = loadRegistry();
    const agent = (data.agents || []).find(a => a.id === req.params.id);
    if (!agent) return res.status(404).json({ error: 'Agent not found' });
    res.json(agent);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/team/refresh — rescan agent directories
router.post('/refresh', (req, res) => {
  try {
    cachedRegistry = null;
    cacheTime = 0;
    cachedEnriched = null;
    enrichedCacheTime = 0;
    const { execSync } = require('child_process');
    execSync('python -c "from factory.agent_registry import export_json; export_json()"',
      { cwd: config.FACTORY_BASE, timeout: 15000 });
    const data = loadRegistry();
    res.json({ refreshed: true, count: (data.agents || []).length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
