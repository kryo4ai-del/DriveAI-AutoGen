const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const config = require('../config');

const JANITOR_DIR = path.join(config.FACTORY_BASE, 'factory', 'hq', 'janitor');
const REPORTS_DIR = path.join(JANITOR_DIR, 'reports');
const QUARANTINE_DIR = path.join(JANITOR_DIR, 'quarantine');
const PROPOSALS_DIR = path.join(JANITOR_DIR, 'proposals');

function loadJson(filepath, fallback = {}) {
  try {
    return JSON.parse(fs.readFileSync(filepath, 'utf-8'));
  } catch {
    return fallback;
  }
}

function getLatestReport(cycle) {
  const dir = path.join(REPORTS_DIR, cycle);
  if (!fs.existsSync(dir)) return null;
  const files = fs.readdirSync(dir)
    .filter(f => f.startsWith('report_') && f.endsWith('.json'))
    .sort()
    .reverse();
  if (!files.length) return null;
  return loadJson(path.join(dir, files[0]));
}

// GET /api/janitor -- Full status
router.get('/', (req, res) => {
  try {
    const latestDaily = getLatestReport('daily');
    const latestWeekly = getLatestReport('weekly');
    const latestMonthly = getLatestReport('monthly');

    const latest = latestMonthly || latestWeekly || latestDaily;

    const quarantine = loadJson(path.join(QUARANTINE_DIR, '_manifest.json'), { items: [] });
    const activeQuarantine = quarantine.items.filter(i => !i.restored);

    const proposals = loadJson(path.join(PROPOSALS_DIR, '_pending.json'), { proposals: [] });
    const pendingProposals = proposals.proposals.filter(p => p.status === 'pending');

    res.json({
      health_score: latest?.summary?.health_score || null,
      last_scans: {
        daily: latestDaily?.timestamp || null,
        weekly: latestWeekly?.timestamp || null,
        monthly: latestMonthly?.timestamp || null,
      },
      latest_summary: latest?.summary || null,
      latest_scan: latest?.scan || null,
      latest_graph: latest?.graph || null,
      findings: latest?.findings || [],
      growth_alerts: latest?.scan?.growth_alerts || [],
      consistency: latest?.consistency || null,
      dependencies: latest?.dependencies || null,
      quarantine: {
        total: activeQuarantine.length,
        items: activeQuarantine,
      },
      proposals: {
        total: pendingProposals.length,
        items: pendingProposals,
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/janitor/proposals -- Pending proposals
router.get('/proposals', (req, res) => {
  try {
    const data = loadJson(path.join(PROPOSALS_DIR, '_pending.json'), { proposals: [] });
    res.json({ proposals: data.proposals });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/janitor/proposals/:id/decide -- Decide on proposal
router.post('/proposals/:id/decide', (req, res) => {
  try {
    const { id } = req.params;
    const { decision, notes } = req.body;

    const filepath = path.join(PROPOSALS_DIR, '_pending.json');
    const data = loadJson(filepath, { proposals: [] });

    const proposal = data.proposals.find(p => p.proposal_id === id);
    if (!proposal) {
      return res.status(404).json({ error: `Proposal ${id} nicht gefunden` });
    }

    proposal.status = decision;
    proposal.decision = decision;
    proposal.decision_notes = notes || '';
    proposal.decided_at = new Date().toISOString();

    fs.writeFileSync(filepath, JSON.stringify(data, null, 2), 'utf-8');
    res.json({ success: true, proposal_id: id, decision });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/janitor/scan -- Trigger manual scan
router.post('/scan', (req, res) => {
  try {
    const { level } = req.body;
    const cycle = level || 'daily';

    if (!['daily', 'weekly', 'monthly'].includes(cycle)) {
      return res.status(400).json({ error: `Invalid cycle: ${cycle}` });
    }

    // Run Python janitor in background
    const cmd = `cd "${config.FACTORY_BASE}" && python -m factory.hq.janitor ${cycle}`;
    try {
      const output = execSync(cmd, {
        timeout: cycle === 'monthly' ? 120000 : 30000,
        encoding: 'utf-8',
        env: { ...process.env, PYTHONPATH: config.FACTORY_BASE, PYTHONIOENCODING: 'utf-8' },
      });
      res.json({ success: true, cycle, output: output.substring(0, 5000) });
    } catch (execError) {
      res.json({
        success: false,
        cycle,
        error: execError.stderr ? execError.stderr.substring(0, 2000) : execError.message,
        output: execError.stdout ? execError.stdout.substring(0, 2000) : '',
      });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/janitor/restore -- Restore from quarantine
router.post('/restore', (req, res) => {
  try {
    const { path: filePath } = req.body;
    if (!filePath) {
      return res.status(400).json({ error: 'path required' });
    }

    const cmd = `cd "${config.FACTORY_BASE}" && python -m factory.hq.janitor restore "${filePath}"`;
    const output = execSync(cmd, {
      timeout: 10000,
      encoding: 'utf-8',
      env: { ...process.env, PYTHONPATH: config.FACTORY_BASE, PYTHONIOENCODING: 'utf-8' },
    });

    let result;
    try {
      result = JSON.parse(output.trim());
    } catch {
      result = { status: 'unknown', output };
    }
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/janitor/quarantine -- Quarantine contents
router.get('/quarantine', (req, res) => {
  try {
    const data = loadJson(path.join(QUARANTINE_DIR, '_manifest.json'), { items: [] });
    const active = data.items.filter(i => !i.restored);
    res.json({ total: active.length, items: active });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/janitor/history -- Action log (all reports)
router.get('/history', (req, res) => {
  try {
    const history = [];

    for (const cycle of ['daily', 'weekly', 'monthly']) {
      const dir = path.join(REPORTS_DIR, cycle);
      if (!fs.existsSync(dir)) continue;

      const files = fs.readdirSync(dir)
        .filter(f => f.startsWith('report_') && f.endsWith('.json'))
        .sort()
        .reverse()
        .slice(0, 10); // Last 10 per cycle

      for (const file of files) {
        try {
          const report = loadJson(path.join(dir, file));
          const actions = report.actions || {};
          history.push({
            cycle,
            timestamp: report.timestamp,
            duration_sec: report.duration_sec,
            cost_usd: report.cost_usd || 0,
            finding_count: report.summary?.total_findings || 0,
            health_score: report.summary?.health_score || null,
            auto_fixed: (actions.auto_fixed || []).length,
            proposed: (actions.proposed || []).length,
            reported: (actions.reported || []).length,
          });
        } catch {
          // Skip corrupt reports
        }
      }
    }

    // Sort by timestamp descending
    history.sort((a, b) => (b.timestamp || '').localeCompare(a.timestamp || ''));

    res.json({ entries: history.slice(0, 30) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
