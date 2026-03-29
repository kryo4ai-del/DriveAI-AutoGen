/**
 * brain-scanner.js — Scannt TheBrain-Subsysteme und liefert Dashboard-Daten.
 *
 * Liest:
 *   - factory/brain/reports/state_report_*.json  (neuester)
 *   - factory/brain/directives/directives_registry.json
 *   - factory/agent_registry.json  (Brain-Department filtern)
 *   - factory/brain/memory/data/events.json
 */

const fs = require('fs');
const path = require('path');
const config = require('../config');

const FACTORY_BASE = config.FACTORY_BASE;

// ---------- helpers ----------

function safeReadJSON(filePath) {
  try {
    if (!fs.existsSync(filePath)) return null;
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch {
    return null;
  }
}

function latestReportFile(dir) {
  try {
    if (!fs.existsSync(dir)) return null;
    const files = fs.readdirSync(dir)
      .filter(f => f.startsWith('state_report_') && f.endsWith('.json'))
      .sort()
      .reverse();
    return files.length ? path.join(dir, files[0]) : null;
  } catch {
    return null;
  }
}

// ---------- main scanner ----------

function scanBrainStatus() {
  const brainDir = path.join(FACTORY_BASE, 'factory', 'brain');

  // 1. Latest State Report
  const reportsDir = path.join(brainDir, 'reports');
  const reportFile = latestReportFile(reportsDir);
  const report = reportFile ? safeReadJSON(reportFile) : null;

  // 2. Directives
  const directivesFile = path.join(brainDir, 'directives', 'directives_registry.json');
  const directivesData = safeReadJSON(directivesFile);
  const directives = directivesData?.directives || [];

  // 3. Brain Agents (aus agent_registry.json)
  const registryFile = path.join(FACTORY_BASE, 'factory', 'agent_registry.json');
  const registry = safeReadJSON(registryFile);
  const brainAgents = (registry?.agents || []).filter(a => a.department === 'Brain');

  // 4. Memory Events (letzte 20)
  const eventsFile = path.join(brainDir, 'memory', 'data', 'events.json');
  const allEvents = safeReadJSON(eventsFile) || [];
  const recentEvents = allEvents.slice(-20).reverse();

  // 5. Memory Lessons
  const lessonsFile = path.join(brainDir, 'memory', 'data', 'lessons.json');
  const allLessons = safeReadJSON(lessonsFile) || [];

  // 6. Memory Patterns
  const patternsFile = path.join(brainDir, 'memory', 'data', 'patterns.json');
  const allPatterns = safeReadJSON(patternsFile) || [];

  // ---------- Status Header ----------

  const factoryState = report?.factory_state || {};
  const overallHealth = report?.overall_health || 'unknown';
  const alertCount = report?.alert_count || 0;
  const subsystemsAvailable = factoryState.subsystems_available || 0;
  const subsystemsTotal = factoryState.subsystems_total || 0;

  const statusHeader = {
    overall_health: overallHealth,
    alert_count: alertCount,
    subsystems_available: subsystemsAvailable,
    subsystems_total: subsystemsTotal,
    report_generated: report?.generated_at || null,
    report_file: reportFile ? path.basename(reportFile) : null,
  };

  // ---------- Alerts ----------

  const alerts = (report?.alerts || []).map(a => ({
    level: a.level || 'info',
    source: a.source || 'unknown',
    message: a.message || '',
  }));

  // Health Monitor Alerts (detail)
  const healthAlerts = (factoryState.health_monitor?.alerts || []).map(a => ({
    level: a.severity || 'info',
    source: `health_monitor/${a.category || 'unknown'}`,
    message: a.message || '',
    project: a.project || null,
    auto_fixable: a.auto_fixable || false,
  }));

  // ---------- Subsystems ----------

  const subsystems = {};
  const subsystemKeys = [
    'health_monitor', 'janitor', 'pipeline_queue', 'project_registry',
    'service_provider', 'model_provider', 'command_queue', 'auto_repair',
  ];
  for (const key of subsystemKeys) {
    const sub = factoryState[key];
    if (sub) {
      subsystems[key] = {
        status: sub.status || 'unknown',
        summary: buildSubsystemSummary(key, sub),
      };
    }
  }

  // ---------- Gaps ----------

  const gaps = (report?.gaps || []).map(g => ({
    type: g.type,
    severity: g.severity || 'yellow',
    area: g.area,
    name: g.name,
    message: g.message,
  }));

  const gapStats = {
    total: gaps.length,
    red: gaps.filter(g => g.severity === 'red').length,
    yellow: gaps.filter(g => g.severity === 'yellow').length,
    green: gaps.filter(g => g.severity === 'green').length,
  };

  // ---------- Capabilities Summary ----------

  const caps = report?.capabilities || {};
  const capabilities = {
    agents: caps.totals?.agents || 0,
    agents_active: caps.totals?.agents_active || 0,
    services: caps.totals?.services || 0,
    services_active: caps.totals?.services_active || 0,
    models: caps.totals?.models || 0,
    forges: caps.totals?.forges || 0,
    production_lines: caps.totals?.production_lines || 0,
    production_lines_active: caps.totals?.production_lines_active || 0,
  };

  // ---------- Memory Summary ----------

  const memorySummary = {
    total_events: allEvents.length,
    total_lessons: allLessons.length,
    total_patterns: allPatterns.length,
    recent_events: recentEvents.slice(0, 10).map(e => ({
      event_id: e.event_id,
      type: e.type,
      timestamp: e.timestamp,
      severity: e.severity || 'info',
      title: e.title || '',
    })),
  };

  // ---------- Result ----------

  return {
    status_header: statusHeader,
    alerts,
    health_alerts: healthAlerts,
    subsystems,
    gaps,
    gap_stats: gapStats,
    directives,
    brain_agents: brainAgents,
    capabilities,
    memory: memorySummary,
    scanned_at: new Date().toISOString(),
  };
}

// ---------- Subsystem summary builder ----------

function buildSubsystemSummary(key, data) {
  switch (key) {
    case 'health_monitor':
      return `${data.total_projects || 0} Projekte, ${data.total_alerts || 0} Alerts (${data.critical || 0} kritisch)`;
    case 'janitor':
      return `Health ${data.health_score || 0}/100, ${data.issues_found || 0} Issues`;
    case 'pipeline_queue':
      return `${data.total_projects || 0} Projekte in Pipeline`;
    case 'project_registry':
      return `${data.total || 0} Projekte (${data.active || 0} aktiv)`;
    case 'service_provider':
      return `${data.active_services?.length || 0}/${data.total_services || 0} Services aktiv`;
    case 'model_provider':
      return `${data.registered_models || 0} Modelle, ${data.available_models || 0} verfuegbar`;
    case 'command_queue':
      return `${data.total_commands || 0} Commands, aelteste ${data.oldest_age_days || 0} Tage`;
    case 'auto_repair':
      return `${data.active_repairs || 0} aktive Reparaturen`;
    default:
      return data.status || 'unknown';
  }
}

module.exports = { scanBrainStatus };
