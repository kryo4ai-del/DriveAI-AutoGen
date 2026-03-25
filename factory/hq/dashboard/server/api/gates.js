const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const config = require('../config');

const PENDING_DIR = path.join(config.FACTORY_BASE, 'factory', 'hq', 'gates', 'pending');
const DECIDED_DIR = path.join(config.FACTORY_BASE, 'factory', 'hq', 'gates', 'decided');

// GET /api/gates — all pending gates
router.get('/', (req, res) => {
  try {
    const { project, category, platform, severity } = req.query;
    const gates = loadPendingGates(project, category, platform, severity);
    res.json({ gates, count: gates.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/gates/:gate_id — single gate (pending or decided)
router.get('/:gate_id', (req, res) => {
  try {
    const gate = loadGate(req.params.gate_id);
    if (!gate) return res.status(404).json({ error: 'Gate not found' });
    res.json(gate);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/gates/:gate_id/decide — set decision
router.post('/:gate_id/decide', (req, res) => {
  const { decision, notes } = req.body;
  const gateId = req.params.gate_id;

  if (!decision) {
    return res.status(400).json({ error: 'decision required' });
  }

  // Validate gate exists and decision is valid
  const gate = loadGate(gateId);
  if (!gate) return res.status(404).json({ error: 'Gate not found' });
  if (gate.status !== 'pending') return res.status(400).json({ error: 'Gate already decided' });

  const validOptions = (gate.options || []).map(o => o.id);
  if (!validOptions.includes(decision)) {
    return res.status(400).json({ error: `Invalid decision '${decision}'. Valid: ${validOptions.join(', ')}` });
  }

  // Execute via Python gate_api
  const safeNotes = (notes || '').replace(/'/g, '').replace(/"/g, '');
  const cmd = `python -c "from factory.hq.gate_api import decide_gate; import json; r=decide_gate('${gateId}', '${decision}', '${safeNotes}'); print(json.dumps(r, default=str))"`;

  exec(cmd, { cwd: config.FACTORY_BASE, timeout: 15000 }, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: `Gate decision failed: ${error.message}` });
    }
    try {
      const result = JSON.parse(stdout.trim());
      res.json(result);
    } catch (e) {
      // Fallback: do it in Node directly
      try {
        gate.status = 'decided';
        gate.decided_at = new Date().toISOString();
        gate.decision = decision;
        gate.decision_notes = notes || '';

        // Move to decided
        if (!fs.existsSync(DECIDED_DIR)) fs.mkdirSync(DECIDED_DIR, { recursive: true });
        fs.writeFileSync(path.join(DECIDED_DIR, `${gateId}.json`), JSON.stringify(gate, null, 2), 'utf-8');
        const pendingFile = path.join(PENDING_DIR, `${gateId}.json`);
        if (fs.existsSync(pendingFile)) fs.unlinkSync(pendingFile);

        res.json(gate);
      } catch (e2) {
        res.status(500).json({ error: e2.message });
      }
    }
  });
});

// POST /api/gates — create new gate (from Factory departments)
router.post('/', (req, res) => {
  try {
    const gate = req.body;
    if (!gate.gate_id || !gate.project || !gate.options) {
      return res.status(400).json({ error: 'gate_id, project, and options required' });
    }
    if (!fs.existsSync(PENDING_DIR)) fs.mkdirSync(PENDING_DIR, { recursive: true });
    fs.writeFileSync(
      path.join(PENDING_DIR, `${gate.gate_id}.json`),
      JSON.stringify(gate, null, 2), 'utf-8'
    );
    res.json({ created: gate.gate_id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

function loadPendingGates(project, category, platform, severity) {
  if (!fs.existsSync(PENDING_DIR)) return [];

  const gates = [];
  for (const file of fs.readdirSync(PENDING_DIR)) {
    if (!file.startsWith('gate_') || !file.endsWith('.json')) continue;
    try {
      const gate = JSON.parse(fs.readFileSync(path.join(PENDING_DIR, file), 'utf-8'));
      if (project && gate.project !== project) continue;
      if (category && gate.category !== category) continue;
      if (platform && gate.platform !== platform) continue;
      if (severity && gate.severity !== severity) continue;
      gates.push(gate);
    } catch (e) { continue; }
  }

  const order = { blocking: 0, warning: 1, info: 2 };
  gates.sort((a, b) => (order[a.severity] || 9) - (order[b.severity] || 9) || (a.created_at || '').localeCompare(b.created_at || ''));
  return gates;
}

function loadGate(gateId) {
  for (const dir of [PENDING_DIR, DECIDED_DIR]) {
    const file = path.join(dir, `${gateId}.json`);
    if (fs.existsSync(file)) {
      return JSON.parse(fs.readFileSync(file, 'utf-8'));
    }
  }
  return null;
}

module.exports = router;
