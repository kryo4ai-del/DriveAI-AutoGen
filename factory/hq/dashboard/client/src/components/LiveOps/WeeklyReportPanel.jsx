/**
 * WeeklyReportPanel — CEO Weekly Report Summary fuer Dashboard.
 * Zeigt Executive Summary, Fleet Status, Top Empfehlungen.
 */

import { useState, useEffect } from 'react';

const STATUS_COLORS = {
  EXZELLENT: 'text-factory-success',
  STABIL: 'text-factory-accent-blue',
  WARNUNG: 'text-factory-warning',
  KRITISCH: 'text-factory-error',
};

export default function WeeklyReportPanel() {
  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(true);
  const [expanded, setExpanded] = useState(false);

  useEffect(() => {
    fetchReport();
  }, []);

  async function fetchReport() {
    try {
      const res = await fetch('/api/liveops/weekly-report');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setReport(data);
    } catch {
      setReport({ error: 'Nicht erreichbar' });
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="bg-factory-surface border border-factory-border rounded-lg p-4">
        <div className="text-factory-text-secondary text-sm">Lade Weekly Report...</div>
      </div>
    );
  }

  if (!report || report.error) {
    return (
      <div className="bg-factory-surface border border-factory-border rounded-lg p-4">
        <h3 className="text-sm font-semibold text-white">Weekly Report</h3>
        <p className="text-xs text-factory-text-secondary mt-1">{report?.error || 'Keine Daten'}</p>
      </div>
    );
  }

  const summary = report.executive_summary || {};
  const recs = report.recommendations || [];
  const fleet = report.fleet_health || [];
  const statusColor = STATUS_COLORS[summary.fleet_status] || 'text-factory-text';

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-4">
      {/* Header */}
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-semibold text-white">Weekly Report</h3>
        <button
          onClick={() => setExpanded(e => !e)}
          className="text-xs text-factory-text-secondary hover:text-factory-text transition-colors"
        >
          {expanded ? 'Einklappen' : 'Details'}
        </button>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-2 gap-3 text-xs">
        <div>
          <span className="text-factory-text-secondary">Fleet Status</span>
          <p className={`font-semibold ${statusColor}`}>{summary.fleet_status || '?'}</p>
        </div>
        <div>
          <span className="text-factory-text-secondary">Avg Score</span>
          <p className="text-white font-semibold">{summary.avg_health_score || 0}</p>
        </div>
        <div>
          <span className="text-factory-text-secondary">Pending Actions</span>
          <p className="text-white font-semibold">{summary.pending_actions || 0}</p>
        </div>
        <div>
          <span className="text-factory-text-secondary">Releases (Woche)</span>
          <p className="text-white font-semibold">{summary.releases_week || 0}</p>
        </div>
      </div>

      {/* CEO Alerts Badge */}
      {summary.ceo_alerts_week > 0 && (
        <div className="mt-3 bg-factory-error/10 border border-factory-error/30 rounded px-3 py-1.5">
          <span className="text-xs text-factory-error font-semibold">
            {summary.ceo_alerts_week} CEO Alert(s) diese Woche
          </span>
        </div>
      )}

      {/* Recommendations */}
      {recs.length > 0 && (
        <div className="mt-3 pt-2 border-t border-factory-border">
          <p className="text-xs font-semibold text-factory-text-secondary mb-1.5">Empfehlungen</p>
          {recs.slice(0, expanded ? recs.length : 2).map((r, i) => (
            <p key={i} className="text-xs text-factory-text-secondary mb-1 leading-relaxed">
              {r}
            </p>
          ))}
        </div>
      )}

      {/* Expanded: Fleet Table */}
      {expanded && fleet.length > 0 && (
        <div className="mt-3 pt-2 border-t border-factory-border">
          <p className="text-xs font-semibold text-factory-text-secondary mb-2">Fleet Health</p>
          <div className="space-y-1">
            {fleet.slice(0, 10).map(app => (
              <div key={app.app_id} className="flex items-center justify-between text-xs">
                <span className="text-factory-text truncate flex-1 mr-2">{app.app_name}</span>
                <span className={`w-8 text-right ${
                  app.health_zone === 'red' ? 'text-factory-error' :
                  app.health_zone === 'yellow' ? 'text-factory-warning' :
                  'text-factory-success'
                }`}>
                  {(app.health_score || 0).toFixed(0)}
                </span>
                <span className={`w-8 text-right ${
                  app.trend > 0 ? 'text-factory-success' :
                  app.trend < 0 ? 'text-factory-error' :
                  'text-factory-text-secondary'
                }`}>
                  {app.trend > 0 ? '+' : ''}{(app.trend || 0).toFixed(0)}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
