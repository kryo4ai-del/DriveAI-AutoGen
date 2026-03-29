const express = require('express');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const config = require('../config');

const router = express.Router();

const REPORTS_DIR = path.join(config.FACTORY_BASE, 'factory', 'hq', 'capabilities', 'reports');

// GET /api/feasibility/capability-sheet
router.get('/capability-sheet', (req, res) => {
  const cmd = `python main.py --capability-sheet --json`;
  exec(cmd, { cwd: config.FACTORY_BASE, timeout: 30000 }, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: `Capability sheet failed: ${error.message}` });
    }
    try {
      const sheet = JSON.parse(stdout);
      res.json(sheet);
    } catch (e) {
      res.status(500).json({ error: 'Failed to parse capability sheet', raw: stdout.slice(0, 500) });
    }
  });
});

// GET /api/feasibility/:projectId — load saved report
router.get('/:projectId', (req, res) => {
  const reportFile = path.join(REPORTS_DIR, `${req.params.projectId}_feasibility.json`);
  if (!fs.existsSync(reportFile)) {
    return res.status(404).json({ error: 'Feasibility report not found', project: req.params.projectId });
  }
  try {
    const report = JSON.parse(fs.readFileSync(reportFile, 'utf-8'));
    res.json(report);
  } catch (e) {
    res.status(500).json({ error: 'Failed to read feasibility report' });
  }
});

// POST /api/feasibility/:projectId/check — run check
router.post('/:projectId/check', (req, res) => {
  const cmd = `python main.py --feasibility-check ${req.params.projectId} --json`;
  exec(cmd, { cwd: config.FACTORY_BASE, timeout: 60000 }, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: `Feasibility check failed: ${error.message}` });
    }
    try {
      const result = JSON.parse(stdout);
      res.json(result);
    } catch (e) {
      res.status(500).json({ error: 'Failed to parse result', raw: stdout.slice(0, 500) });
    }
  });
});

// POST /api/feasibility/:projectId/recheck — re-check single project
router.post('/:projectId/recheck', (req, res) => {
  const cmd = `python main.py --feasibility-check ${req.params.projectId} --json`;
  exec(cmd, { cwd: config.FACTORY_BASE, timeout: 60000 }, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: `Re-check failed: ${error.message}` });
    }
    try {
      const result = JSON.parse(stdout);
      res.json({ recheck: true, ...result });
    } catch (e) {
      res.status(500).json({ error: 'Failed to parse result', raw: stdout.slice(0, 500) });
    }
  });
});

// POST /api/feasibility/recheck-parked — re-check all parked projects
router.post('/recheck-parked', (req, res) => {
  const cmd = `python main.py --recheck-parked --json`;
  exec(cmd, { cwd: config.FACTORY_BASE, timeout: 120000 }, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: `Recheck failed: ${error.message}` });
    }
    try {
      const changes = JSON.parse(stdout);
      res.json({ changes });
    } catch (e) {
      res.status(500).json({ error: 'Failed to parse result', raw: stdout.slice(0, 500) });
    }
  });
});

module.exports = router;
