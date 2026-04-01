/**
 * Name Gate API — REST Endpoints for the CEO Cockpit.
 *
 * POST /api/namegate/validate       — Full 6-dimension name validation
 * POST /api/namegate/generate       — Generate names from idea + validate all
 * POST /api/namegate/alternatives   — Generate + validate alternative names
 * POST /api/namegate/lock           — Lock a validated name for project creation
 * GET  /api/namegate/status/:name   — Check name lock status
 */

const express = require('express');
const router = express.Router();
const config = require('../config');

// ------------------------------------------------------------------
// Helper — Run Name Gate CLI via python -m factory.name_gate
// ------------------------------------------------------------------

function parseNameGateOutput(stdout) {
  const lines = stdout.trim().split('\n');
  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      const jsonStr = lines.slice(i).join('\n');
      return JSON.parse(jsonStr);
    }
  }
  throw new Error('No JSON in Name Gate output: ' + lines.slice(0, 3).join(' | '));
}

function runNameGate(args, timeoutMs) {
  const { execFileSync } = require('child_process');

  const result = execFileSync('python', ['-m', 'factory.name_gate', ...args], {
    cwd: config.FACTORY_BASE,
    timeout: timeoutMs || 60000,
    env: { ...process.env, PYTHONDONTWRITEBYTECODE: '1', PYTHONIOENCODING: 'utf-8' },
    stdio: ['pipe', 'pipe', 'pipe'],
  });

  return parseNameGateOutput(result.toString('utf-8'));
}

function runNameGateAsync(args, timeoutMs) {
  const { execFile } = require('child_process');

  return new Promise((resolve, reject) => {
    const proc = execFile(
      'python',
      ['-m', 'factory.name_gate', ...args],
      {
        cwd: config.FACTORY_BASE,
        timeout: timeoutMs || 300000,
        env: { ...process.env, PYTHONDONTWRITEBYTECODE: '1', PYTHONIOENCODING: 'utf-8' },
        maxBuffer: 10 * 1024 * 1024,
      },
      (err, stdout, stderr) => {
        if (err) {
          return reject(err);
        }
        try {
          resolve(parseNameGateOutput(stdout));
        } catch (parseErr) {
          reject(parseErr);
        }
      },
    );
  });
}

// ------------------------------------------------------------------
// POST /api/namegate/validate
// ------------------------------------------------------------------

router.post('/validate', (req, res) => {
  const { name, idea, template } = req.body;

  if (!name || !idea) {
    return res.status(400).json({ error: 'Missing required fields: name, idea' });
  }

  try {
    const args = ['validate', '--name', name, '--idea', idea];
    if (template) args.push('--template', template);

    const report = runNameGate(args, 90000);
    res.json(report);
  } catch (err) {
    console.error('[NameGate API] Validate error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------------------------------------------------
// POST /api/namegate/alternatives
// ------------------------------------------------------------------

router.post('/alternatives', (req, res) => {
  const { idea, template, rejected } = req.body;

  if (!idea) {
    return res.status(400).json({ error: 'Missing required field: idea' });
  }

  try {
    const args = ['alternatives', '--idea', idea];
    if (template) args.push('--template', template);
    if (rejected && Array.isArray(rejected) && rejected.length) {
      args.push('--rejected', rejected.join(','));
    }

    const reports = runNameGate(args, 120000);
    res.json({ alternatives: reports, total: Array.isArray(reports) ? reports.length : 0 });
  } catch (err) {
    console.error('[NameGate API] Alternatives error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------------------------------------------------
// POST /api/namegate/generate
// ------------------------------------------------------------------

router.post('/generate', async (req, res) => {
  const { idea, template, count } = req.body;

  if (!idea) {
    return res.status(400).json({ error: 'Missing required field: idea' });
  }

  try {
    const args = ['generate', '--idea', idea];
    if (template) args.push('--template', template);
    if (count) args.push('--count', String(count));

    const result = await runNameGateAsync(args, 300000);
    res.json(result);
  } catch (err) {
    console.error('[NameGate API] Generate error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------------------------------------------------
// POST /api/namegate/lock
// ------------------------------------------------------------------

router.post('/lock', (req, res) => {
  const { name } = req.body;

  if (!name) {
    return res.status(400).json({ error: 'Missing required field: name' });
  }

  try {
    const args = ['lock', '--name', name];
    const result = runNameGate(args, 30000);

    if (result.error) {
      return res.status(409).json(result);
    }

    res.json(result);
  } catch (err) {
    console.error('[NameGate API] Lock error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/namegate/status/:name
// ------------------------------------------------------------------

router.get('/status/:name', (req, res) => {
  const { name } = req.params;

  try {
    const args = ['status', '--name', name];
    const result = runNameGate(args, 10000);
    res.json(result);
  } catch (err) {
    console.error('[NameGate API] Status error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
