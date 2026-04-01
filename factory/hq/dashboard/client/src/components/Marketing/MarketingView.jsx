import { useState, useEffect } from 'react';

const STATUS_COLORS = {
  operational: { bg: 'bg-green-500/10', text: 'text-green-400', border: 'border-green-500/30', label: 'Operational' },
  partial: { bg: 'bg-yellow-500/10', text: 'text-yellow-400', border: 'border-yellow-500/30', label: 'Partial' },
  offline: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/30', label: 'Offline' },
};

const PRIORITY_COLORS = {
  critical: { bg: 'bg-red-500/20', text: 'text-red-400', border: 'border-red-500/30' },
  high: { bg: 'bg-orange-500/20', text: 'text-orange-400', border: 'border-orange-500/30' },
  medium: { bg: 'bg-yellow-500/20', text: 'text-yellow-400', border: 'border-yellow-500/30' },
  low: { bg: 'bg-gray-500/20', text: 'text-gray-400', border: 'border-gray-500/30' },
};

const TIER_COLORS = {
  mid: 'bg-blue-500/20 text-blue-400',
  low: 'bg-green-500/20 text-green-400',
  premium: 'bg-purple-500/20 text-purple-400',
  unknown: 'bg-gray-500/20 text-gray-400',
};

// ── Main Component ────────────────────────────────────────

export default function MarketingView() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const res = await fetch('/api/marketing');
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const json = await res.json();
        setData(json);
        setError(null);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-factory-text-secondary">Marketing-Daten werden geladen...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-500/10 border border-red-500/30 rounded-lg p-6">
        <p className="text-red-400 font-medium">Fehler beim Laden der Marketing-Daten</p>
        <p className="text-red-400/70 text-sm mt-1">{error}</p>
      </div>
    );
  }

  if (!data?.available) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <p className="text-factory-text text-lg font-medium">Marketing-Abteilung nicht verbunden</p>
          <p className="text-factory-text-secondary text-sm mt-2">
            Das Verzeichnis factory/marketing/ wurde nicht gefunden.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <DepartmentOverview dept={data.department} />
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <AlertsPanel alerts={data.alerts} />
        <KPIPanel kpis={data.kpis} />
      </div>
      {data.pipeline?.projects?.length > 0 && (
        <PipelineProjects projects={data.pipeline.projects} />
      )}
      <AgentTable agents={data.agents} />
    </div>
  );
}

// ── Department Overview ───────────────────────────────────

function StatCard({ label, value, sub }) {
  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-4">
      <p className="text-factory-text-secondary text-xs uppercase">{label}</p>
      <p className="text-xl font-bold text-factory-text mt-1">{value}</p>
      {sub && <p className="text-xs text-factory-text-secondary mt-1">{sub}</p>}
    </div>
  );
}

function DepartmentOverview({ dept }) {
  if (!dept) return null;
  const s = STATUS_COLORS[dept.status] || STATUS_COLORS.offline;

  return (
    <div className="space-y-4">
      <div className={`${s.bg} border ${s.border} rounded-lg p-5`}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className={`text-2xl font-bold ${s.text}`}>Marketing Department</span>
            <span className={`text-sm px-3 py-1 rounded-full ${s.bg} ${s.text} border ${s.border}`}>
              {s.label}
            </span>
          </div>
          <div className="text-right">
            <p className="text-factory-text-secondary text-sm">{dept.python_files} Python-Dateien</p>
            <p className="text-factory-text-secondary text-xs">Dry-Run Mode</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
        <StatCard label="Agents" value={dept.agents_count} />
        <StatCard label="Tools" value={dept.tools_count} />
        <StatCard label="Adapter" value={dept.adapters_count} />
        <StatCard label="DB-Tabellen" value={dept.db_tables} />
        <StatCard label="Gesamt .py" value={dept.python_files} />
      </div>
    </div>
  );
}

// ── Alerts Panel ──────────────────────────────────────────

function AlertsPanel({ alerts }) {
  if (!alerts) return null;

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-factory-text font-semibold">Aktive Alerts</h3>
        <div className="flex gap-2">
          {alerts.active_count > 0 && (
            <span className="bg-orange-500/20 text-orange-400 text-xs px-2 py-1 rounded-full">
              {alerts.active_count} offen
            </span>
          )}
          {alerts.pending_gates_count > 0 && (
            <span className="bg-factory-accent/20 text-factory-accent text-xs px-2 py-1 rounded-full">
              {alerts.pending_gates_count} Gate{alerts.pending_gates_count !== 1 ? 's' : ''} pending
            </span>
          )}
        </div>
      </div>

      {alerts.active_count === 0 && alerts.pending_gates_count === 0 && (
        <p className="text-green-400 text-sm">Keine aktiven Alerts oder offenen Gates.</p>
      )}

      {/* Pending Gates */}
      {alerts.pending_gates?.map((gate) => (
        <div
          key={gate.gate_id}
          className="bg-factory-accent/10 border border-factory-accent/30 rounded-lg p-3 mb-2"
        >
          <div className="flex items-center gap-2">
            <span className="bg-factory-accent/30 text-factory-accent text-xs px-2 py-0.5 rounded">CEO-Gate</span>
            <span className="text-factory-text text-sm font-medium">{gate.title}</span>
          </div>
          <p className="text-factory-text-secondary text-xs mt-1 line-clamp-2">{gate.description}</p>
          <p className="text-factory-text-secondary text-xs mt-1">
            {gate.options?.length || 0} Optionen &bull; {gate.source_agent}
          </p>
        </div>
      ))}

      {/* Active Alerts */}
      {alerts.active_alerts?.map((alert) => {
        const c = PRIORITY_COLORS[alert.priority] || PRIORITY_COLORS.low;
        return (
          <div
            key={alert.alert_id}
            className={`${c.bg} border ${c.border} rounded-lg p-3 mb-2`}
          >
            <div className="flex items-center gap-2">
              <span className={`${c.text} text-xs px-2 py-0.5 rounded ${c.bg}`}>
                {alert.priority}
              </span>
              <span className="text-factory-text text-sm">{alert.title}</span>
            </div>
            <p className="text-factory-text-secondary text-xs mt-1">{alert.category} &bull; {alert.source_agent}</p>
          </div>
        );
      })}
    </div>
  );
}

// ── KPI Panel ─────────────────────────────────────────────

function KPIPanel({ kpis }) {
  if (!kpis) return null;

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-factory-text font-semibold">KPI Dashboard</h3>
        {!kpis.available && (
          <span className="text-factory-text-secondary text-xs">Keine DB</span>
        )}
      </div>

      {!kpis.available ? (
        <p className="text-factory-text-secondary text-sm">{kpis.message || 'Keine KPI-Daten verfuegbar.'}</p>
      ) : (
        <div className="space-y-4">
          {/* Knowledge Stats */}
          {kpis.knowledge && (kpis.knowledge.total > 0) && (
            <div>
              <p className="text-factory-text-secondary text-xs uppercase mb-2">Knowledge Base</p>
              <div className="grid grid-cols-3 gap-2">
                <MiniStat label="Total" value={kpis.knowledge.total} />
                <MiniStat label="Confirmed" value={kpis.knowledge.confirmed} color="text-blue-400" />
                <MiniStat label="Established" value={kpis.knowledge.established} color="text-green-400" />
              </div>
            </div>
          )}

          {/* Review Summary */}
          {kpis.review_summary?.length > 0 && (
            <div>
              <p className="text-factory-text-secondary text-xs uppercase mb-2">Reviews</p>
              {kpis.review_summary.map((r) => (
                <div key={r.store} className="flex items-center justify-between py-1">
                  <span className="text-factory-text-secondary text-sm">{r.store}</span>
                  <div className="flex items-center gap-3">
                    <span className="text-factory-text text-sm">{r.count} Reviews</span>
                    <span className={`text-sm font-medium ${r.avg_rating >= 4 ? 'text-green-400' : r.avg_rating >= 3 ? 'text-yellow-400' : 'text-red-400'}`}>
                      {r.avg_rating} Sterne
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Sentiment */}
          {kpis.sentiment?.length > 0 && (
            <div>
              <p className="text-factory-text-secondary text-xs uppercase mb-2">Sentiment</p>
              {kpis.sentiment.map((s, i) => (
                <div key={i} className="flex items-center justify-between py-1">
                  <span className="text-factory-text-secondary text-sm">{s.topic}</span>
                  <span className={`text-sm ${s.overall_sentiment === 'positive' ? 'text-green-400' : s.overall_sentiment === 'negative' ? 'text-red-400' : 'text-yellow-400'}`}>
                    {s.overall_sentiment} ({s.score})
                  </span>
                </div>
              ))}
            </div>
          )}

          {/* Last Pipeline Run */}
          {kpis.last_pipeline_run && (
            <div>
              <p className="text-factory-text-secondary text-xs uppercase mb-2">Letzter Pipeline-Run</p>
              <div className="bg-factory-bg rounded p-2">
                <p className="text-factory-text text-sm">{kpis.last_pipeline_run.project_slug}</p>
                <p className="text-factory-text-secondary text-xs">
                  {kpis.last_pipeline_run.steps_completed}/{kpis.last_pipeline_run.steps_total} Steps &bull;{' '}
                  {kpis.last_pipeline_run.status}
                </p>
              </div>
            </div>
          )}

          {/* Fallback: No data yet */}
          {!kpis.review_summary?.length && !kpis.sentiment?.length && !kpis.knowledge?.total && !kpis.last_pipeline_run && (
            <p className="text-factory-text-secondary text-sm">Datenbank vorhanden, noch keine Metriken gespeichert.</p>
          )}
        </div>
      )}
    </div>
  );
}

function MiniStat({ label, value, color }) {
  return (
    <div className="bg-factory-bg rounded p-2 text-center">
      <p className={`text-lg font-bold ${color || 'text-factory-text'}`}>{value || 0}</p>
      <p className="text-factory-text-secondary text-xs">{label}</p>
    </div>
  );
}

// ── Pipeline Projects ─────────────────────────────────────

function PipelineProjects({ projects }) {
  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-factory-text font-semibold mb-3">Marketing-Projekte</h3>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
        {projects.map((p) => (
          <div key={p.slug} className="bg-factory-bg border border-factory-border rounded-lg p-3">
            <p className="text-factory-text font-medium text-sm">{p.slug}</p>
            <p className="text-factory-text-secondary text-xs mt-1">
              {p.file_count} Dateien &bull; {new Date(p.last_modified).toLocaleDateString('de-DE')}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── Agent Table ───────────────────────────────────────────

function AgentTable({ agents }) {
  if (!agents?.agents?.length) return null;

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-factory-text font-semibold">Marketing Agents ({agents.count})</h3>
        <span className="text-green-400 text-xs">
          {agents.active} aktiv
        </span>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-factory-text-secondary text-xs uppercase border-b border-factory-border">
              <th className="text-left py-2 pr-4">ID</th>
              <th className="text-left py-2 pr-4">Name</th>
              <th className="text-left py-2 pr-4">Rolle</th>
              <th className="text-left py-2 pr-4">Tier</th>
              <th className="text-left py-2">Status</th>
            </tr>
          </thead>
          <tbody>
            {agents.agents
              .sort((a, b) => (a.id || '').localeCompare(b.id || ''))
              .map((agent) => {
                const tierClass = TIER_COLORS[agent.model_tier] || TIER_COLORS.unknown;
                return (
                  <tr key={agent.id} className="border-b border-factory-border/50 hover:bg-factory-surface-hover">
                    <td className="py-2 pr-4 text-factory-accent font-mono text-xs">{agent.id}</td>
                    <td className="py-2 pr-4 text-factory-text">{agent.name}</td>
                    <td className="py-2 pr-4 text-factory-text-secondary text-xs">{agent.role}</td>
                    <td className="py-2 pr-4">
                      <span className={`text-xs px-2 py-0.5 rounded ${tierClass}`}>{agent.model_tier}</span>
                    </td>
                    <td className="py-2">
                      <span className={`text-xs ${agent.status === 'active' ? 'text-green-400' : agent.status === 'planned' ? 'text-yellow-400' : 'text-red-400'}`}>
                        {agent.status}
                      </span>
                    </td>
                  </tr>
                );
              })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
