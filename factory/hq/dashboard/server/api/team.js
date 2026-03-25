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
