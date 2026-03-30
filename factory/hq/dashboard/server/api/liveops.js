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

module.exports = router;
