const fs = require('fs');
const path = require('path');
const config = require('../config');

/**
 * Marketing Department Scanner — READ-ONLY.
 * Liest direkt aus dem Filesystem + SQLite DB.
 * Kein Python-Aufruf, keine HQ Bridge Abhaengigkeit.
 */

function scanMarketing() {
  const marketingPath = config.PATHS.marketing;
  const result = {
    available: false,
    timestamp: new Date().toISOString(),
    department: null,
    alerts: null,
    kpis: null,
    agents: null,
    pipeline: null,
  };

  if (!fs.existsSync(marketingPath)) {
    return result;
  }
  result.available = true;

  result.department = scanDepartmentOverview(marketingPath);
  result.alerts = scanAlerts(marketingPath);
  result.kpis = scanKPIs(marketingPath);
  result.agents = scanMarketingAgents();
  result.pipeline = scanPipelineStatus(marketingPath);

  return result;
}

// ── Department Overview ───────────────────────────────────

function scanDepartmentOverview(marketingPath) {
  const agentsDir = path.join(marketingPath, 'agents');
  const toolsDir = path.join(marketingPath, 'tools');
  const adaptersDir = path.join(marketingPath, 'adapters');

  const agentsCount = countPyFiles(agentsDir);
  const toolsCount = countPyFiles(toolsDir);
  const adaptersCount = countPyFiles(adaptersDir);

  // DB-Tabellen zaehlen
  let tablesCount = 0;
  const dbPath = path.join(marketingPath, 'data', 'marketing_metrics.db');
  if (fs.existsSync(dbPath)) {
    try {
      const Database = require('better-sqlite3');
      const db = new Database(dbPath, { readonly: true });
      tablesCount = db.prepare("SELECT COUNT(*) as c FROM sqlite_master WHERE type='table'").get().c;
      db.close();
    } catch (e) { /* ignore */ }
  }

  const status = (agentsCount > 0 && toolsCount > 0) ? 'operational'
    : agentsCount > 0 ? 'partial'
    : 'offline';

  return {
    status,
    agents_count: agentsCount,
    tools_count: toolsCount,
    adapters_count: adaptersCount,
    db_tables: tablesCount,
    python_files: countPyFilesRecursive(marketingPath),
  };
}

// ── Alerts + Gates ────────────────────────────────────────

function scanAlerts(marketingPath) {
  const alertsPath = path.join(marketingPath, 'alerts');
  const active = readJsonFiles(path.join(alertsPath, 'active'));
  const gateFiles = readJsonFiles(path.join(alertsPath, 'gates'));

  // Sortiere aktive Alerts nach Prioritaet
  const priorityOrder = { critical: 0, high: 1, medium: 2, low: 3 };
  active.sort((a, b) => (priorityOrder[a.priority] || 99) - (priorityOrder[b.priority] || 99));

  const pendingGates = gateFiles.filter(g => g.status === 'pending');
  const decidedGates = gateFiles.filter(g => g.status === 'decided');

  return {
    active_count: active.length,
    pending_gates_count: pendingGates.length,
    decided_gates_count: decidedGates.length,
    active_alerts: active.slice(0, 10),
    pending_gates: pendingGates.slice(0, 5),
  };
}

// ── KPIs aus SQLite DB ────────────────────────────────────

function scanKPIs(marketingPath) {
  const dbPath = path.join(marketingPath, 'data', 'marketing_metrics.db');
  if (!fs.existsSync(dbPath)) {
    return { available: false, message: 'Keine Metrik-Datenbank vorhanden' };
  }

  try {
    const Database = require('better-sqlite3');
    const db = new Database(dbPath, { readonly: true });

    // Letzte App-Metriken
    let latestMetrics = [];
    try {
      latestMetrics = db.prepare(
        'SELECT * FROM app_metrics ORDER BY date DESC LIMIT 5'
      ).all();
    } catch (e) { /* Tabelle existiert evtl. nicht */ }

    // Review-Stats
    let reviewStats = [];
    try {
      reviewStats = db.prepare(
        'SELECT store, COUNT(*) as count, ROUND(AVG(rating), 1) as avg_rating FROM review_log GROUP BY store'
      ).all();
    } catch (e) { /* ignore */ }

    // Sentiment-Daten
    let sentimentLatest = [];
    try {
      sentimentLatest = db.prepare(
        'SELECT topic, overall_sentiment, score, date FROM sentiment_data ORDER BY date DESC LIMIT 5'
      ).all();
    } catch (e) { /* ignore */ }

    // Knowledge-Stats
    let knowledgeStats = {};
    try {
      const row = db.prepare(
        "SELECT COUNT(*) as total, SUM(CASE WHEN status='established' THEN 1 ELSE 0 END) as established, SUM(CASE WHEN status='confirmed' THEN 1 ELSE 0 END) as confirmed FROM marketing_knowledge"
      ).get();
      knowledgeStats = row || {};
    } catch (e) { /* ignore */ }

    // Pipeline-Runs
    let lastPipelineRun = null;
    try {
      lastPipelineRun = db.prepare(
        'SELECT * FROM pipeline_runs ORDER BY started_at DESC LIMIT 1'
      ).get();
    } catch (e) { /* ignore */ }

    db.close();

    return {
      available: true,
      latest_metrics: latestMetrics,
      review_summary: reviewStats,
      sentiment: sentimentLatest,
      knowledge: knowledgeStats,
      last_pipeline_run: lastPipelineRun,
    };
  } catch (e) {
    return { available: false, error: e.message };
  }
}

// ── Marketing Agents ──────────────────────────────────────

function scanMarketingAgents() {
  const registryPath = path.join(config.FACTORY_BASE, 'factory', 'agent_registry.json');
  try {
    const registry = JSON.parse(fs.readFileSync(registryPath, 'utf-8'));
    const agents = (registry.agents || []).filter(a => a.department === 'Marketing');
    return {
      count: agents.length,
      active: agents.filter(a => a.status === 'active').length,
      agents: agents.map(a => ({
        id: a.id,
        name: a.name,
        role: a.role,
        status: a.status,
        model_tier: a.model_tier || 'unknown',
        routing: a.routing || 'unknown',
      })),
    };
  } catch (e) {
    // Fallback: Agent-JSON-Dateien direkt lesen
    const agentsDir = path.join(config.PATHS.marketing, 'agents');
    const agents = [];
    try {
      for (const f of fs.readdirSync(agentsDir)) {
        if (f.startsWith('agent_') && f.endsWith('.json')) {
          const data = JSON.parse(fs.readFileSync(path.join(agentsDir, f), 'utf-8'));
          agents.push({
            id: data.id,
            name: data.name,
            role: data.role,
            status: data.status || 'active',
            model_tier: data.model_tier || 'unknown',
            routing: data.routing || 'unknown',
          });
        }
      }
    } catch (e2) { /* ignore */ }
    return { count: agents.length, active: agents.filter(a => a.status === 'active').length, agents };
  }
}

// ── Pipeline Status ───────────────────────────────────────

function scanPipelineStatus(marketingPath) {
  const outputDir = path.join(marketingPath, 'output');
  if (!fs.existsSync(outputDir)) return { projects: [] };

  const projects = [];
  try {
    for (const dir of fs.readdirSync(outputDir)) {
      const fullPath = path.join(outputDir, dir);
      if (!fs.statSync(fullPath).isDirectory()) continue;
      // Nur Projekt-Slugs (nicht system-Ordner wie templates, daily, etc.)
      const hasContent = fs.readdirSync(fullPath).some(f => f.endsWith('.md') || f.endsWith('.json'));
      if (hasContent && !['templates', 'daily', 'naming', 'pr', 'press_kit', 'videos', 'ideas', 'community', 'hq_bridge'].includes(dir)) {
        const stat = fs.statSync(fullPath);
        projects.push({
          slug: dir,
          last_modified: stat.mtime.toISOString(),
          file_count: fs.readdirSync(fullPath).length,
        });
      }
    }
  } catch (e) { /* ignore */ }

  return { projects };
}

// ── Hilfsfunktionen ───────────────────────────────────────

function countPyFiles(dir) {
  if (!fs.existsSync(dir)) return 0;
  try {
    return fs.readdirSync(dir).filter(f =>
      f.endsWith('.py') && f !== '__init__.py'
    ).length;
  } catch (e) { return 0; }
}

function countPyFilesRecursive(dir) {
  let count = 0;
  if (!fs.existsSync(dir)) return 0;
  try {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.name === '__pycache__' || entry.name === 'node_modules') continue;
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        count += countPyFilesRecursive(full);
      } else if (entry.name.endsWith('.py')) {
        count++;
      }
    }
  } catch (e) { /* ignore */ }
  return count;
}

function readJsonFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  const results = [];
  try {
    for (const f of fs.readdirSync(dir)) {
      if (!f.endsWith('.json')) continue;
      try {
        const data = JSON.parse(fs.readFileSync(path.join(dir, f), 'utf-8'));
        results.push(data);
      } catch (e) { /* skip broken JSON */ }
    }
  } catch (e) { /* ignore */ }
  return results;
}

module.exports = { scanMarketing };
