const express = require('express');
const { exec, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const config = require('../config');

const router = express.Router();

// ── POST /api/production/estimate ────────────────────────────────────────
// Runs production_estimator.py on a project's build_spec.yaml
router.post('/estimate', (req, res) => {
  const { slug } = req.body;
  if (!slug) return res.status(400).json({ error: 'slug required' });

  const specPath = path.join(config.FACTORY_BASE, 'projects', slug, 'specs', 'build_spec.yaml');

  // If build_spec doesn't exist, generate it first
  if (!fs.existsSync(specPath)) {
    const rbPath = _findRoadbook(slug);
    if (!rbPath) {
      return res.status(404).json({ error: `No roadbook found for ${slug}` });
    }

    const specDir = path.dirname(specPath);
    if (!fs.existsSync(specDir)) fs.mkdirSync(specDir, { recursive: true });

    const genCmd = `python -m factory.integration.roadbook_to_spec --roadbook "${rbPath}" --output "${specPath}"`;
    exec(genCmd, { cwd: config.FACTORY_BASE, timeout: 30000, env: _pyEnv() }, (genErr) => {
      if (genErr) {
        return res.status(500).json({ error: `roadbook_to_spec failed: ${genErr.message}` });
      }
      _runEstimator(specPath, res);
    });
  } else {
    _runEstimator(specPath, res);
  }
});

function _runEstimator(specPath, res) {
  const cmd = `python -m factory.integration.production_estimator --spec "${specPath}" --format json`;
  exec(cmd, { cwd: config.FACTORY_BASE, timeout: 60000, env: _pyEnv() }, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: `Estimator failed: ${error.message}`, stderr: (stderr || '').slice(0, 500) });
    }
    try {
      const estimate = JSON.parse(stdout);
      res.json(estimate);
    } catch (e) {
      res.status(500).json({ error: 'Failed to parse estimator output', raw: stdout.slice(0, 500) });
    }
  });
}

// ── POST /api/production/start ───────────────────────────────────────────
// Starts production async (does NOT block the server)
router.post('/start', (req, res) => {
  const { slug } = req.body;
  if (!slug) return res.status(400).json({ error: 'slug required' });

  // Check precondition: production_gate must be GO
  const projectFile = path.join(config.PATHS.projects, slug, 'project.json');
  if (!fs.existsSync(projectFile)) {
    return res.status(404).json({ error: `Project not found: ${slug}` });
  }
  const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
  const gateStatus = project.gates?.production_gate?.status;
  if (gateStatus !== 'GO' && gateStatus !== 'GO_MIT_NOTES') {
    return res.status(400).json({ error: `Production gate not approved (status: ${gateStatus || 'pending'})` });
  }

  // Ensure build_spec exists
  const specPath = path.join(config.FACTORY_BASE, 'projects', slug, 'specs', 'build_spec.yaml');
  if (!fs.existsSync(specPath)) {
    return res.status(400).json({ error: 'build_spec.yaml not found — run estimate first' });
  }

  // Start production async via dispatcher
  // ProductionLogger writes JSONL directly to projects/<slug>/production_log.jsonl
  const child = spawn('python', ['-m', 'factory.dispatcher.dispatcher', '--start-production', slug, '--spec', specPath], {
    cwd: config.FACTORY_BASE,
    env: _pyEnv(),
    detached: true,
    stdio: ['ignore', 'ignore', 'pipe'],
  });

  // Log stderr for debugging
  if (child.stderr) {
    child.stderr.on('data', (data) => {
      console.log(`[Production/${slug}] ${data.toString().trim()}`);
    });
  }
  child.unref();

  // Update project status
  project.status = 'in_production';
  project.current_phase = 'Production laeuft';
  project.production_pid = child.pid;
  project.updated = new Date().toISOString().split('T')[0];
  fs.writeFileSync(projectFile, JSON.stringify(project, null, 2), 'utf-8');

  res.json({ status: 'started', slug, pid: child.pid });
});

// ── GET /api/production/status/:slug ─────────────────────────────────────
// Aggregates production status from production_log.jsonl
router.get('/status/:slug', (req, res) => {
  const { slug } = req.params;
  const logFile = path.join(config.PATHS.projects, slug, 'production_log.jsonl');
  const projectFile = path.join(config.PATHS.projects, slug, 'project.json');

  if (!fs.existsSync(projectFile)) {
    return res.status(404).json({ error: `Project not found: ${slug}` });
  }

  const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));

  if (!fs.existsSync(logFile)) {
    return res.json({
      slug,
      status: 'not_started',
      project_status: project.status,
      phases: {},
      total_cost: 0,
      elapsed_seconds: 0,
    });
  }

  try {
    const lines = fs.readFileSync(logFile, 'utf-8').trim().split('\n').filter(Boolean);
    const entries = [];
    for (const line of lines) {
      try { entries.push(JSON.parse(line)); } catch (e) { /* skip bad lines */ }
    }

    const phases = {};
    let totalCost = 0;
    let startTime = null;
    let lastTime = null;
    let currentPhase = 'unknown';
    let completedSteps = 0;
    let totalSteps = 0;

    for (const entry of entries) {
      if (entry.timestamp && !startTime) startTime = entry.timestamp;
      if (entry.timestamp) lastTime = entry.timestamp;
      if (entry.phase) {
        currentPhase = entry.phase;
        if (!phases[entry.phase]) phases[entry.phase] = { status: 'running', steps: 0, errors: 0 };
      }
      if (entry.type === 'step_complete') {
        completedSteps++;
        if (phases[entry.phase]) phases[entry.phase].steps++;
      }
      if (entry.type === 'phase_complete' && phases[entry.phase]) {
        phases[entry.phase].status = 'complete';
      }
      if (entry.type === 'error' && phases[entry.phase]) {
        phases[entry.phase].errors++;
      }
      if (entry.cost) totalCost += entry.cost;
      if (entry.type === 'production_start' && entry.total_steps) totalSteps = entry.total_steps;
    }

    const elapsed = startTime && lastTime
      ? (new Date(lastTime) - new Date(startTime)) / 1000
      : 0;

    res.json({
      slug,
      status: project.status === 'in_production' ? 'running' : project.status,
      project_status: project.status,
      current_phase: currentPhase,
      completed_steps: completedSteps,
      total_steps: totalSteps,
      phases,
      total_cost: Math.round(totalCost * 100) / 100,
      elapsed_seconds: Math.round(elapsed),
      log_entries: entries.length,
    });
  } catch (e) {
    res.status(500).json({ error: `Failed to read production log: ${e.message}` });
  }
});

// ── GET /api/production/status/:slug/stream ──────────────────────────────
// SSE endpoint — streams new log entries in real-time
router.get('/status/:slug/stream', (req, res) => {
  const { slug } = req.params;
  const logFile = path.join(config.PATHS.projects, slug, 'production_log.jsonl');

  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
  });

  res.write(`data: ${JSON.stringify({ type: 'connected', slug })}\n\n`);

  // Send existing log entries first
  let lastSize = 0;
  if (fs.existsSync(logFile)) {
    const content = fs.readFileSync(logFile, 'utf-8');
    lastSize = Buffer.byteLength(content, 'utf-8');
    const lines = content.trim().split('\n').filter(Boolean);
    for (const line of lines) {
      res.write(`data: ${line}\n\n`);
    }
  }

  // Watch for new entries — watch directory (not file) so it works even if file doesn't exist yet
  let watcher = null;
  const logDir = path.dirname(logFile);
  const logBasename = path.basename(logFile);
  if (!fs.existsSync(logDir)) fs.mkdirSync(logDir, { recursive: true });
  try {
    watcher = fs.watch(logDir, { persistent: false }, (eventType, filename) => {
      if (filename && filename !== logBasename) return;
      try {
        if (!fs.existsSync(logFile)) return;
        const stat = fs.statSync(logFile);
        if (stat.size <= lastSize) return;

        const fd = fs.openSync(logFile, 'r');
        const buf = Buffer.alloc(stat.size - lastSize);
        fs.readSync(fd, buf, 0, buf.length, lastSize);
        fs.closeSync(fd);
        lastSize = stat.size;

        const newLines = buf.toString('utf-8').trim().split('\n').filter(Boolean);
        for (const line of newLines) {
          res.write(`data: ${line}\n\n`);
        }
      } catch (e) { /* file may be locked briefly */ }
    });
  } catch (e) {
    // watch may fail in rare cases — heartbeat still runs
  }

  // Heartbeat every 30s
  const heartbeat = setInterval(() => {
    try { res.write(`: heartbeat\n\n`); } catch (e) { clearInterval(heartbeat); }
  }, 30000);

  // Cleanup on disconnect
  req.on('close', () => {
    clearInterval(heartbeat);
    if (watcher) { try { watcher.close(); } catch (e) { /* ignore */ } }
  });
});

// ── Helpers ──────────────────────────────────────────────────────────────

function _findRoadbook(slug) {
  const rbOutput = path.join(config.FACTORY_BASE, 'factory', 'roadbook_assembly', 'output');
  if (!fs.existsSync(rbOutput)) return null;

  const dirs = fs.readdirSync(rbOutput)
    .filter(d => d.includes(slug) && fs.statSync(path.join(rbOutput, d)).isDirectory())
    .sort()
    .reverse();

  for (const dir of dirs) {
    const rbFile = path.join(rbOutput, dir, 'cd_technical_roadbook.md');
    if (fs.existsSync(rbFile)) return rbFile;
  }
  return null;
}

function _pyEnv() {
  return { ...process.env, PYTHONIOENCODING: 'utf-8' };
}

module.exports = router;
