/**
 * Live Operations API — REST Endpoints fuer das CEO Cockpit.
 *
 * GET /api/liveops/fleet              — Alle Apps mit Health Score
 * GET /api/liveops/app/:appId         — App Detail inkl. Scores, Releases, Actions
 * GET /api/liveops/app/:appId/health-history — Health Score Verlauf
 */

const express = require('express');
const router = express.Router();
const path = require('path');
const config = require('../config');

// ------------------------------------------------------------------
// SQLite Connection (lazy init)
// ------------------------------------------------------------------

let _db = null;

function getDb() {
  if (_db) return _db;

  try {
    const Database = require('better-sqlite3');
    const dbPath = config.PATHS.liveOpsRegistryDb;

    if (!dbPath) {
      console.warn('[LiveOps API] No registry DB path configured.');
      return null;
    }

    // Check if file exists
    const fs = require('fs');
    if (!fs.existsSync(dbPath)) {
      console.warn(`[LiveOps API] Registry DB not found: ${dbPath}`);
      return null;
    }

    _db = new Database(dbPath, { readonly: true });
    _db.pragma('foreign_keys = ON');
    console.log(`[LiveOps API] Connected to registry DB: ${dbPath}`);
    return _db;
  } catch (err) {
    console.error('[LiveOps API] Failed to connect to DB:', err.message);
    return null;
  }
}

// ------------------------------------------------------------------
// Helper
// ------------------------------------------------------------------

function dbAvailable(res) {
  const db = getDb();
  if (!db) {
    res.json({ apps: [], error: 'Registry DB not available' });
    return null;
  }
  return db;
}

// ------------------------------------------------------------------
// GET /api/liveops/fleet
// ------------------------------------------------------------------

router.get('/fleet', (req, res) => {
  const db = dbAvailable(res);
  if (!db) return;

  try {
    const apps = db.prepare(`
      SELECT * FROM apps ORDER BY health_score ASC
    `).all();

    res.json({ apps, total: apps.length });
  } catch (err) {
    console.error('[LiveOps API] Fleet error:', err.message);
    res.json({ apps: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/app/:appId
// ------------------------------------------------------------------

router.get('/app/:appId', (req, res) => {
  const db = dbAvailable(res);
  if (!db) return;

  const { appId } = req.params;

  try {
    const app = db.prepare('SELECT * FROM apps WHERE app_id = ?').get(appId);
    if (!app) {
      return res.status(404).json({ error: 'App not found' });
    }

    // Health history (last record for category scores)
    const lastHealth = db.prepare(`
      SELECT * FROM health_score_history
      WHERE app_id = ? ORDER BY timestamp DESC LIMIT 1
    `).get(appId);

    // Build category scores from last health record
    const category_scores = lastHealth ? {
      stability: { score: lastHealth.stability_score || 0, weight: 0, weighted: 0 },
      satisfaction: { score: lastHealth.satisfaction_score || 0, weight: 0, weighted: 0 },
      engagement: { score: lastHealth.engagement_score || 0, weight: 0, weighted: 0 },
      revenue: { score: lastHealth.revenue_score || 0, weight: 0, weighted: 0 },
      growth: { score: lastHealth.growth_score || 0, weight: 0, weighted: 0 },
    } : {};

    // Apply weights based on profile
    const WEIGHTS = {
      gaming:       { stability: 0.20, satisfaction: 0.15, engagement: 0.35, revenue: 0.25, growth: 0.05 },
      education:    { stability: 0.20, satisfaction: 0.30, engagement: 0.25, revenue: 0.10, growth: 0.15 },
      utility:      { stability: 0.35, satisfaction: 0.25, engagement: 0.10, revenue: 0.20, growth: 0.10 },
      content:      { stability: 0.10, satisfaction: 0.15, engagement: 0.30, revenue: 0.20, growth: 0.25 },
      subscription: { stability: 0.15, satisfaction: 0.25, engagement: 0.20, revenue: 0.30, growth: 0.10 },
    };
    const profileWeights = WEIGHTS[app.app_profile] || WEIGHTS.utility;
    for (const cat of Object.keys(category_scores)) {
      const w = profileWeights[cat] || 0;
      category_scores[cat].weight = w;
      category_scores[cat].weighted = Math.round(category_scores[cat].score * w * 100) / 100;
    }

    // Alerts
    const alerts = [];
    for (const [cat, data] of Object.entries(category_scores)) {
      if (data.score < 50) {
        alerts.push({ category: cat, message: `${cat} in roter Zone (${Math.round(data.score)})` });
      }
    }

    // Release history
    const releases = db.prepare(`
      SELECT * FROM release_history WHERE app_id = ? ORDER BY release_date DESC LIMIT 20
    `).all(appId);

    // Actions
    const actions = db.prepare(`
      SELECT * FROM action_queue WHERE app_id = ? ORDER BY severity_score DESC LIMIT 20
    `).all(appId);

    // Cooling info
    let cooling_info = null;
    if (app.cooling_until) {
      const coolingUntil = new Date(app.cooling_until);
      const now = new Date();
      if (now < coolingUntil) {
        const remaining = coolingUntil - now;
        const hours = Math.floor(remaining / 3600000);
        const minutes = Math.floor((remaining % 3600000) / 60000);
        cooling_info = {
          cooling_type: app.cooling_type,
          cooling_until: app.cooling_until,
          remaining_human: `${hours}h ${minutes}m`,
        };
      }
    }

    res.json({
      ...app,
      category_scores,
      alerts,
      releases,
      actions,
      cooling_info,
    });
  } catch (err) {
    console.error('[LiveOps API] App detail error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/app/:appId/health-history
// ------------------------------------------------------------------

router.get('/app/:appId/health-history', (req, res) => {
  const db = dbAvailable(res);
  if (!db) return;

  const { appId } = req.params;

  try {
    const history = db.prepare(`
      SELECT * FROM health_score_history
      WHERE app_id = ?
      ORDER BY timestamp DESC
      LIMIT 30
    `).all(appId);

    res.json({ history, total: history.length });
  } catch (err) {
    console.error('[LiveOps API] Health history error:', err.message);
    res.json({ history: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/app/:appId/analytics — Full analytics insights
// ------------------------------------------------------------------

function readInsightFile(appId) {
  const fs = require('fs');
  const insightsDir = config.PATHS.liveOpsInsights;
  if (!insightsDir) return null;

  const filePath = path.join(insightsDir, `${appId}_latest.json`);
  if (!fs.existsSync(filePath)) return null;

  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch (err) {
    console.error(`[LiveOps API] Failed to read insights for ${appId}:`, err.message);
    return null;
  }
}

router.get('/app/:appId/analytics', (req, res) => {
  const insights = readInsightFile(req.params.appId);
  if (!insights) {
    return res.json({ available: false, message: 'No analytics data yet. Run analytics agent first.' });
  }
  res.json({ available: true, ...insights });
});

// ------------------------------------------------------------------
// GET /api/liveops/app/:appId/trends — Trend data only
// ------------------------------------------------------------------

router.get('/app/:appId/trends', (req, res) => {
  const insights = readInsightFile(req.params.appId);
  if (!insights || !insights.trends) {
    return res.json({ available: false, trends: [] });
  }
  res.json({ available: true, trends: insights.trends });
});

// ------------------------------------------------------------------
// GET /api/liveops/app/:appId/funnels — Funnel data only
// ------------------------------------------------------------------

router.get('/app/:appId/funnels', (req, res) => {
  const insights = readInsightFile(req.params.appId);
  if (!insights || !insights.funnels) {
    return res.json({ available: false, funnels: [] });
  }
  res.json({ available: true, funnels: insights.funnels });
});

// ------------------------------------------------------------------
// GET /api/liveops/app/:appId/reviews-analysis — Review analysis
// ------------------------------------------------------------------

router.get('/app/:appId/reviews-analysis', (req, res) => {
  const insights = readInsightFile(req.params.appId);
  if (!insights || !insights.reviews) {
    return res.json({ available: false, reviews: null });
  }
  res.json({ available: true, reviews: insights.reviews });
});

// ------------------------------------------------------------------
// GET /api/liveops/app/:appId/support-analysis — Support analysis
// ------------------------------------------------------------------

router.get('/app/:appId/support-analysis', (req, res) => {
  const insights = readInsightFile(req.params.appId);
  if (!insights || !insights.support) {
    return res.json({ available: false, support: null });
  }
  res.json({ available: true, support: insights.support });
});

// ------------------------------------------------------------------
// GET /api/liveops/action-queue — Action Queue (all or per app)
// ------------------------------------------------------------------

router.get('/action-queue', (req, res) => {
  const db = dbAvailable(res);
  if (!db) return;

  const { appId, status } = req.query;

  try {
    let query = 'SELECT * FROM action_queue';
    const params = [];
    const conditions = [];

    if (appId) { conditions.push('app_id = ?'); params.push(appId); }
    if (status) { conditions.push('status = ?'); params.push(status); }
    if (conditions.length) query += ' WHERE ' + conditions.join(' AND ');
    query += ' ORDER BY severity_score DESC LIMIT 50';

    const actions = db.prepare(query).all(...params);
    res.json({ actions, total: actions.length });
  } catch (err) {
    console.error('[LiveOps API] Action queue error:', err.message);
    res.json({ actions: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/escalation-log — Escalation Log (JSONL)
// ------------------------------------------------------------------

router.get('/escalation-log', (req, res) => {
  const fs = require('fs');
  const limit = parseInt(req.query.limit) || 30;
  const logPath = path.join(config.PATHS.liveOpsEscalation, 'escalation_log.jsonl');

  if (!fs.existsSync(logPath)) {
    return res.json({ entries: [], total: 0 });
  }

  try {
    const lines = fs.readFileSync(logPath, 'utf-8').trim().split('\n').filter(Boolean);
    const entries = lines.map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);
    entries.reverse();
    res.json({ entries: entries.slice(0, limit), total: entries.length });
  } catch (err) {
    console.error('[LiveOps API] Escalation log error:', err.message);
    res.json({ entries: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/cycle-status — Orchestrator Status
// ------------------------------------------------------------------

router.get('/cycle-status', (req, res) => {
  const fs = require('fs');
  const statusPath = path.join(config.PATHS.liveOpsEscalation, 'orchestrator_status.json');

  if (!fs.existsSync(statusPath)) {
    return res.json({
      running: false,
      last_decision_cycle: null,
      last_anomaly_scan: null,
      decision_cycles_completed: 0,
      anomaly_scans_completed: 0,
    });
  }

  try {
    const data = JSON.parse(fs.readFileSync(statusPath, 'utf-8'));
    res.json(data);
  } catch (err) {
    res.json({ running: false, error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/cooling-status — All active cooling periods
// ------------------------------------------------------------------

router.get('/cooling-status', (req, res) => {
  const db = dbAvailable(res);
  if (!db) return;

  try {
    const now = new Date().toISOString();
    const apps = db.prepare(`
      SELECT app_id, app_name, cooling_type, cooling_until
      FROM apps WHERE cooling_until IS NOT NULL AND cooling_until > ?
    `).all(now);

    const result = apps.map(a => {
      const remaining = new Date(a.cooling_until) - new Date();
      const hours = Math.floor(remaining / 3600000);
      const minutes = Math.floor((remaining % 3600000) / 60000);
      return { ...a, remaining_human: `${hours}h ${minutes}m` };
    });

    res.json({ cooling: result, total: result.length });
  } catch (err) {
    console.error('[LiveOps API] Cooling status error:', err.message);
    res.json({ cooling: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/strategic-pivots — Level 3 CEO escalations
// ------------------------------------------------------------------

router.get('/strategic-pivots', (req, res) => {
  const fs = require('fs');
  const logPath = path.join(config.PATHS.liveOpsEscalation, 'escalation_log.jsonl');

  if (!fs.existsSync(logPath)) {
    return res.json({ pivots: [], total: 0 });
  }

  try {
    const lines = fs.readFileSync(logPath, 'utf-8').trim().split('\n').filter(Boolean);
    const entries = lines.map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);
    const pivots = entries.filter(e => e.escalation_level >= 3);
    pivots.reverse();
    res.json({ pivots: pivots.slice(0, 20), total: pivots.length });
  } catch (err) {
    console.error('[LiveOps API] Strategic pivots error:', err.message);
    res.json({ pivots: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/briefings — Briefing Documents (JSON files)
// ------------------------------------------------------------------

router.get('/briefings', (req, res) => {
  const fs = require('fs');
  const briefDir = config.PATHS.liveOpsBriefings;
  const { appId } = req.query;
  const limit = parseInt(req.query.limit) || 30;

  if (!briefDir || !fs.existsSync(briefDir)) {
    return res.json({ briefings: [], total: 0 });
  }

  try {
    const files = fs.readdirSync(briefDir).filter(f => f.startsWith('BRF-') && f.endsWith('.json'));
    files.sort().reverse();

    const briefings = [];
    for (const f of files) {
      if (briefings.length >= limit) break;
      try {
        const data = JSON.parse(fs.readFileSync(path.join(briefDir, f), 'utf-8'));
        if (appId && data.app_context && data.app_context.app_id !== appId) continue;
        briefings.push({
          briefing_id: data.briefing_id,
          app_id: data.app_context ? data.app_context.app_id : '',
          action_type: data.update_details ? data.update_details.action_type : '',
          priority: data.update_details ? data.update_details.priority : '',
          target_version: data.update_details ? data.update_details.target_version : '',
          created_at: data.created_at,
          status: data.tracking ? data.tracking.briefing_status : 'unknown',
        });
      } catch (_) { /* skip malformed */ }
    }

    res.json({ briefings, total: briefings.length });
  } catch (err) {
    console.error('[LiveOps API] Briefings error:', err.message);
    res.json({ briefings: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/submissions — Factory Submissions (JSON files)
// ------------------------------------------------------------------

router.get('/submissions', (req, res) => {
  const fs = require('fs');
  const subDir = config.PATHS.liveOpsSubmissions;
  const { appId, status } = req.query;
  const limit = parseInt(req.query.limit) || 30;

  if (!subDir || !fs.existsSync(subDir)) {
    return res.json({ submissions: [], total: 0 });
  }

  try {
    const files = fs.readdirSync(subDir).filter(f => f.startsWith('SUB-') && f.endsWith('.json'));
    files.sort().reverse();

    const submissions = [];
    for (const f of files) {
      if (submissions.length >= limit) break;
      try {
        const data = JSON.parse(fs.readFileSync(path.join(subDir, f), 'utf-8'));
        if (appId && data.app_id !== appId) continue;
        if (status && data.status !== status) continue;
        submissions.push({
          submission_id: data.submission_id,
          briefing_id: data.briefing_id,
          app_id: data.app_id,
          action_type: data.action_type,
          priority: data.priority,
          target_version: data.target_version,
          status: data.status,
          created_at: data.created_at,
          factory_task_id: data.factory_task_id,
        });
      } catch (_) { /* skip malformed */ }
    }

    res.json({ submissions, total: submissions.length });
  } catch (err) {
    console.error('[LiveOps API] Submissions error:', err.message);
    res.json({ submissions: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/releases-exec — Release Records (JSON files)
// ------------------------------------------------------------------

router.get('/releases-exec', (req, res) => {
  const fs = require('fs');
  const relDir = config.PATHS.liveOpsReleases;
  const { appId, status } = req.query;
  const limit = parseInt(req.query.limit) || 30;

  if (!relDir || !fs.existsSync(relDir)) {
    return res.json({ releases: [], total: 0 });
  }

  try {
    const files = fs.readdirSync(relDir).filter(f => f.startsWith('REL-') && f.endsWith('.json'));
    files.sort().reverse();

    const releases = [];
    for (const f of files) {
      if (releases.length >= limit) break;
      try {
        const data = JSON.parse(fs.readFileSync(path.join(relDir, f), 'utf-8'));
        if (appId && data.app_id !== appId) continue;
        if (status && data.status !== status) continue;
        releases.push({
          release_id: data.release_id,
          app_id: data.app_id,
          action_type: data.action_type,
          target_version: data.target_version,
          status: data.status,
          created_at: data.created_at,
          completed_at: data.completed_at,
          qa_passed: data.qa_result ? data.qa_result.passed : null,
          cooling_hours: data.cooling_hours || null,
        });
      } catch (_) { /* skip malformed */ }
    }

    res.json({ releases, total: releases.length });
  } catch (err) {
    console.error('[LiveOps API] Releases error:', err.message);
    res.json({ releases: [], error: err.message });
  }
});

// ------------------------------------------------------------------
// GET /api/liveops/synthetic-fleet — Synthetic Fleet Status
// ------------------------------------------------------------------

router.get('/synthetic-fleet', (req, res) => {
  const db = dbAvailable(res);
  if (!db) return;

  try {
    const all = db.prepare('SELECT * FROM apps ORDER BY health_score ASC').all();
    const synthetic = all.filter(a => a.repository_path === 'SYNTHETIC_FLEET');
    const real = all.filter(a => a.repository_path !== 'SYNTHETIC_FLEET');

    const byZone = { green: 0, yellow: 0, red: 0 };
    const byProfile = {};
    for (const app of synthetic) {
      const z = app.health_zone || 'red';
      byZone[z] = (byZone[z] || 0) + 1;
      const p = app.app_profile || 'unknown';
      byProfile[p] = (byProfile[p] || 0) + 1;
    }

    // Check injection log
    const fs = require('fs');
    const syntheticDir = path.join(config.FACTORY_BASE, 'factory', 'live_operations', 'data', 'synthetic');
    let injections = 0;
    const logPath = path.join(syntheticDir, 'injection_log.jsonl');
    if (fs.existsSync(logPath)) {
      injections = fs.readFileSync(logPath, 'utf-8').trim().split('\n').filter(Boolean).length;
    }

    res.json({
      total_synthetic: synthetic.length,
      total_real: real.length,
      by_zone: byZone,
      by_profile: byProfile,
      active_injections: injections,
      apps: synthetic.map(a => ({
        app_id: a.app_id,
        name: a.app_name,
        profile: a.app_profile,
        score: a.health_score,
        zone: a.health_zone,
        version: a.current_version,
      })),
    });
  } catch (err) {
    console.error('[LiveOps API] Synthetic fleet error:', err.message);
    res.json({ total_synthetic: 0, error: err.message });
  }
});

// ------------------------------------------------------------------
// Phase 6: Helper — Python via execFileSync (kein Shell-Escaping)
// ------------------------------------------------------------------

function runPython(code, timeoutMs) {
  const { execFileSync } = require('child_process');
  const script = 'import sys, os; sys.path.insert(0, "."); os.environ["PYTHONDONTWRITEBYTECODE"]="1"; ' + code;
  const result = execFileSync('python', ['-c', script], {
    cwd: config.FACTORY_BASE,
    timeout: timeoutMs || 15000,
    stdio: ['pipe', 'pipe', 'pipe'],
  });
  const lines = result.toString().trim().split('\n');
  // Letzte Zeile ist der JSON-Output — vorherige sind Log-Meldungen
  for (let i = lines.length - 1; i >= 0; i--) {
    const line = lines[i].trim();
    if (line.startsWith('{') || line.startsWith('[')) {
      return JSON.parse(line);
    }
  }
  throw new Error('No JSON in Python output: ' + lines.slice(0, 3).join(' | '));
}

// ------------------------------------------------------------------
// Phase 6: System Health
// ------------------------------------------------------------------

router.get('/system-health', (req, res) => {
  try {
    const data = runPython(
      'import json; ' +
      'from factory.live_operations.self_healing.health_monitor import SystemHealthMonitor; ' +
      'from factory.live_operations.self_healing.utilities import ErrorLog; ' +
      'from factory.live_operations.app_registry.database import AppRegistryDB; ' +
      'db = AppRegistryDB(); el = ErrorLog(); m = SystemHealthMonitor(registry_db=db, error_log=el); ' +
      'print(json.dumps(m.run_health_check(), default=str))'
    );
    res.json(data);
  } catch (err) {
    console.error('[LiveOps API] System health error:', err.message);
    res.json({ all_ok: null, error: err.message });
  }
});

// ------------------------------------------------------------------
// Phase 6: Weekly Report
// ------------------------------------------------------------------

router.get('/weekly-report', (req, res) => {
  try {
    const data = runPython(
      'import json; ' +
      'from factory.live_operations.reporting.weekly_report import WeeklyReportGenerator; ' +
      'r = WeeklyReportGenerator(); ' +
      'print(json.dumps(r.generate_data_only(), default=str))',
      30000
    );
    res.json(data);
  } catch (err) {
    console.error('[LiveOps API] Weekly report error:', err.message);
    res.json({ error: err.message });
  }
});

router.get('/weekly-report/archive', (req, res) => {
  try {
    const data = runPython(
      'import json; ' +
      'from factory.live_operations.reporting.weekly_report import WeeklyReportGenerator; ' +
      'r = WeeklyReportGenerator(); ' +
      'print(json.dumps(r.list_reports(), default=str))'
    );
    res.json(data);
  } catch (err) {
    console.error('[LiveOps API] Weekly report archive error:', err.message);
    res.json([]);
  }
});

// ------------------------------------------------------------------
// Phase 6: Full Status Overview
// ------------------------------------------------------------------

router.get('/phase6-status', (req, res) => {
  try {
    const db = getDb();
    if (!db) return res.json({ error: 'No DB' });

    const apps = db.prepare('SELECT COUNT(*) as c FROM apps').get();
    const pending = db.prepare("SELECT COUNT(*) as c FROM action_queue WHERE status = 'pending'").get();
    const inProgress = db.prepare("SELECT COUNT(*) as c FROM action_queue WHERE status = 'in_progress'").get();

    const zones = { green: 0, yellow: 0, red: 0 };
    const zoneRows = db.prepare("SELECT health_zone, COUNT(*) as c FROM apps GROUP BY health_zone").all();
    zoneRows.forEach(r => { if (zones[r.health_zone] !== undefined) zones[r.health_zone] = r.c; });

    const scores = db.prepare('SELECT AVG(health_score) as avg FROM apps WHERE health_score IS NOT NULL').get();

    res.json({
      total_apps: apps.c,
      avg_health_score: scores.avg ? Math.round(scores.avg * 10) / 10 : 0,
      zones,
      pending_actions: pending.c,
      in_progress_actions: inProgress.c,
      phase6_features: {
        synthetic_fleet: true,
        stress_test: true,
        self_healing: true,
        weekly_report: true,
        system_health_dashboard: true,
      },
    });
  } catch (err) {
    console.error('[LiveOps API] Phase 6 status error:', err.message);
    res.json({ error: err.message });
  }
});

module.exports = router;
