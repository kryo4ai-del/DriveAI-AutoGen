import { useState, useEffect } from 'react';

const SEVERITY_COLORS = {
  green: { bg: 'bg-green-500/10', text: 'text-green-400', border: 'border-green-500/30', dot: 'bg-green-400' },
  yellow: { bg: 'bg-yellow-500/10', text: 'text-yellow-400', border: 'border-yellow-500/30', dot: 'bg-yellow-400' },
  red: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/30', dot: 'bg-red-400' },
  unknown: { bg: 'bg-gray-500/10', text: 'text-gray-400', border: 'border-gray-500/30', dot: 'bg-gray-400' },
};

const HEALTH_MAP = {
  green: { label: 'Healthy', color: 'text-green-400', bg: 'bg-green-500/10', border: 'border-green-500/30' },
  yellow: { label: 'Warnings', color: 'text-yellow-400', bg: 'bg-yellow-500/10', border: 'border-yellow-500/30' },
  red: { label: 'Critical', color: 'text-red-400', bg: 'bg-red-500/10', border: 'border-red-500/30' },
  unknown: { label: 'Unknown', color: 'text-gray-400', bg: 'bg-gray-500/10', border: 'border-gray-500/30' },
};

function StatCard({ label, value, sub }) {
  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-4">
      <p className="text-factory-text-secondary text-xs uppercase">{label}</p>
      <p className="text-xl font-bold text-factory-text mt-1">{value}</p>
      {sub && <p className="text-xs text-factory-text-secondary mt-1">{sub}</p>}
    </div>
  );
}

// ---------- 1. Status Header ----------

function StatusHeader({ header, capabilities }) {
  if (!header) return null;
  const health = HEALTH_MAP[header.overall_health] || HEALTH_MAP.unknown;

  return (
    <div className="space-y-4">
      {/* Overall Status Banner */}
      <div className={`${health.bg} border ${health.border} rounded-lg p-5`}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className={`text-3xl font-bold ${health.color}`}>{health.label}</span>
            <span className="text-factory-text-secondary text-sm">
              {header.subsystems_available}/{header.subsystems_total} Subsysteme
            </span>
          </div>
          <div className="text-right">
            {header.alert_count > 0 && (
              <span className="bg-yellow-500/20 text-yellow-400 text-sm px-3 py-1 rounded-full">
                {header.alert_count} Alert{header.alert_count !== 1 ? 's' : ''}
              </span>
            )}
            {header.report_generated && (
              <p className="text-xs text-factory-text-secondary mt-2">
                Report: {new Date(header.report_generated).toLocaleString('de-DE')}
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Capability Stats */}
      {capabilities && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <StatCard label="Agents" value={capabilities.agents_active} sub={`von ${capabilities.agents} gesamt`} />
          <StatCard label="Services" value={capabilities.services_active} sub={`von ${capabilities.services} gesamt`} />
          <StatCard label="Modelle" value={capabilities.models} sub={`${capabilities.forges} Forges`} />
          <StatCard label="Lines" value={capabilities.production_lines_active} sub={`von ${capabilities.production_lines} gesamt`} />
        </div>
      )}
    </div>
  );
}

// ---------- 2. Alerts ----------

function AlertsPanel({ alerts, healthAlerts }) {
  const all = [...(alerts || []), ...(healthAlerts || [])];
  if (!all.length) return <p className="text-green-400 text-sm py-4">Keine aktiven Alerts.</p>;

  const warnings = all.filter(a => a.level === 'warning');
  const infos = all.filter(a => a.level === 'info');

  return (
    <div className="space-y-3">
      {warnings.map((a, i) => (
        <div key={`w-${i}`} className="flex items-start gap-3 p-3 rounded-lg bg-yellow-500/10 border border-yellow-500/30">
          <span className="inline-block w-2 h-2 mt-1.5 rounded-full bg-yellow-400" />
          <div className="flex-1">
            <span className="text-xs font-mono text-yellow-400">{a.source}</span>
            <p className="text-sm text-factory-text mt-0.5">{a.message}</p>
            {a.project && <span className="text-xs text-factory-text-secondary">Projekt: {a.project}</span>}
          </div>
          {a.auto_fixable && (
            <span className="text-xs px-2 py-0.5 rounded bg-green-500/20 text-green-400">auto-fix</span>
          )}
        </div>
      ))}
      {infos.length > 0 && (
        <details className="group">
          <summary className="text-xs text-factory-text-secondary cursor-pointer hover:text-factory-text">
            {infos.length} Info-Meldung{infos.length !== 1 ? 'en' : ''} anzeigen
          </summary>
          <div className="mt-2 space-y-2">
            {infos.map((a, i) => (
              <div key={`i-${i}`} className="flex items-start gap-3 p-2 rounded-lg bg-blue-500/5 border border-blue-500/20">
                <span className="inline-block w-2 h-2 mt-1.5 rounded-full bg-blue-400" />
                <div>
                  <span className="text-xs font-mono text-blue-400">{a.source}</span>
                  <p className="text-sm text-factory-text mt-0.5">{a.message}</p>
                </div>
              </div>
            ))}
          </div>
        </details>
      )}
    </div>
  );
}

// ---------- 3. Subsystems ----------

function SubsystemsPanel({ subsystems }) {
  if (!subsystems || !Object.keys(subsystems).length) {
    return <p className="text-factory-text-secondary text-sm py-4">Keine Subsystem-Daten.</p>;
  }

  const STATUS_ICON = { ok: 'bg-green-400', warning: 'bg-yellow-400', error: 'bg-red-400', unknown: 'bg-gray-400' };

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
      {Object.entries(subsystems).map(([key, sub]) => (
        <div key={key} className="flex items-center gap-3 p-3 bg-factory-bg rounded-lg border border-factory-border">
          <span className={`inline-block w-2.5 h-2.5 rounded-full ${STATUS_ICON[sub.status] || STATUS_ICON.unknown}`} />
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-factory-text truncate">{formatSubsystemName(key)}</p>
            <p className="text-xs text-factory-text-secondary truncate">{sub.summary}</p>
          </div>
          <span className={`text-xs px-2 py-0.5 rounded ${
            sub.status === 'ok' ? 'bg-green-500/10 text-green-400' :
            sub.status === 'warning' ? 'bg-yellow-500/10 text-yellow-400' :
            'bg-red-500/10 text-red-400'
          }`}>{sub.status}</span>
        </div>
      ))}
    </div>
  );
}

function formatSubsystemName(key) {
  const names = {
    health_monitor: 'Health Monitor',
    janitor: 'Factory Janitor',
    pipeline_queue: 'Pipeline Queue',
    project_registry: 'Project Registry',
    service_provider: 'Service Provider',
    model_provider: 'Model Provider',
    command_queue: 'Command Queue',
    auto_repair: 'Auto-Repair',
  };
  return names[key] || key;
}

// ---------- 4. Gaps ----------

function GapsPanel({ gaps, gapStats }) {
  if (!gaps?.length) return <p className="text-green-400 text-sm py-4">Keine Capability Gaps.</p>;

  return (
    <div className="space-y-4">
      <div className="flex gap-3">
        <span className="text-xs px-2 py-1 rounded bg-red-500/10 text-red-400">
          {gapStats?.red || 0} kritisch
        </span>
        <span className="text-xs px-2 py-1 rounded bg-yellow-500/10 text-yellow-400">
          {gapStats?.yellow || 0} Warnung
        </span>
        <span className="text-xs px-2 py-1 rounded bg-green-500/10 text-green-400">
          {gapStats?.green || 0} geplant
        </span>
      </div>
      <div className="space-y-2">
        {gaps.map((g, i) => {
          const sev = SEVERITY_COLORS[g.severity] || SEVERITY_COLORS.yellow;
          return (
            <div key={i} className={`flex items-start gap-3 p-3 rounded-lg ${sev.bg} border ${sev.border}`}>
              <span className={`inline-block w-2 h-2 mt-1.5 rounded-full ${sev.dot}`} />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className={`text-xs font-mono ${sev.text}`}>{g.type}</span>
                  <span className="text-xs text-factory-text-secondary">{g.area}</span>
                </div>
                <p className="text-sm text-factory-text mt-0.5">{g.message}</p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ---------- 5. Directives ----------

function DirectivesPanel({ directives }) {
  if (!directives?.length) return <p className="text-factory-text-secondary text-sm py-4">Keine CEO-Direktiven.</p>;

  return (
    <div className="space-y-3">
      {directives.map((d, i) => (
        <div key={i} className="p-4 rounded-lg bg-purple-500/5 border border-purple-500/30">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="text-xs font-mono font-bold text-purple-400">{d.id}</span>
              <span className="text-sm font-medium text-factory-text">{d.name}</span>
            </div>
            <div className="flex items-center gap-2">
              <span className={`text-xs px-2 py-0.5 rounded ${
                d.priority === 'highest' ? 'bg-red-500/20 text-red-400' :
                d.priority === 'high' ? 'bg-orange-500/20 text-orange-400' :
                'bg-blue-500/20 text-blue-400'
              }`}>{d.priority}</span>
              <span className={`text-xs px-2 py-0.5 rounded ${
                d.status === 'active' ? 'bg-green-500/20 text-green-400' : 'bg-gray-500/20 text-gray-400'
              }`}>{d.status}</span>
            </div>
          </div>
          <p className="text-sm text-factory-text-secondary mt-2">{d.summary}</p>
          {d.affects?.length > 0 && (
            <div className="flex flex-wrap gap-1 mt-2">
              {d.affects.map((a, j) => (
                <span key={j} className="text-xs px-2 py-0.5 rounded bg-factory-bg text-factory-text-secondary">
                  {a}
                </span>
              ))}
            </div>
          )}
          <p className="text-xs text-factory-text-secondary mt-2">
            Issued by {d.issued_by} &bull; {d.issued_at} &bull; {d.enforcement}
          </p>
        </div>
      ))}
    </div>
  );
}

// ---------- 6. Brain Agents ----------

function BrainAgentsPanel({ agents }) {
  if (!agents?.length) return <p className="text-factory-text-secondary text-sm py-4">Keine Brain-Agents gefunden.</p>;

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
      {agents.map((a) => (
        <div key={a.id} className="p-4 rounded-lg bg-factory-bg border border-factory-border hover:border-factory-accent/30 transition-colors">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="text-xs font-mono font-bold text-factory-accent">{a.id}</span>
              <span className="text-sm font-medium text-factory-text">{a.name}</span>
            </div>
            <span className={`text-xs px-2 py-0.5 rounded ${
              a.status === 'active' ? 'bg-green-500/20 text-green-400' :
              a.status === 'planned' ? 'bg-blue-500/20 text-blue-400' :
              'bg-gray-500/20 text-gray-400'
            }`}>{a.status}</span>
          </div>
          {a.description && (
            <p className="text-xs text-factory-text-secondary mt-2 line-clamp-2">{a.description}</p>
          )}
          <div className="flex items-center gap-3 mt-2 text-xs text-factory-text-secondary">
            <span>{a.task_type}</span>
            <span>&bull;</span>
            <span>{a.model_tier === 'none' ? 'deterministisch' : a.model_tier}</span>
            {a.py_file && (
              <>
                <span>&bull;</span>
                <span className="font-mono">{a.py_file}</span>
              </>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}

// ---------- 7. Memory Summary ----------

function MemoryPanel({ memory }) {
  if (!memory) return <p className="text-factory-text-secondary text-sm py-4">Keine Memory-Daten.</p>;

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-3 gap-3">
        <StatCard label="Events" value={memory.total_events} />
        <StatCard label="Lessons" value={memory.total_lessons} />
        <StatCard label="Patterns" value={memory.total_patterns} />
      </div>
      {memory.recent_events?.length > 0 && (
        <div>
          <p className="text-xs text-factory-text-secondary uppercase mb-2">Letzte Events</p>
          <div className="space-y-1">
            {memory.recent_events.map((e, i) => {
              const sev = SEVERITY_COLORS[e.severity] || SEVERITY_COLORS.unknown;
              return (
                <div key={i} className="flex items-center gap-2 py-1.5 border-b border-factory-border/30">
                  <span className={`inline-block w-2 h-2 rounded-full ${sev.dot}`} />
                  <span className="text-xs font-mono text-factory-text-secondary">{e.event_id}</span>
                  <span className={`text-xs px-1.5 py-0.5 rounded ${sev.bg} ${sev.text}`}>{e.type}</span>
                  <span className="text-xs text-factory-text truncate flex-1">{e.title}</span>
                  {e.timestamp && (
                    <span className="text-xs text-factory-text-secondary whitespace-nowrap">
                      {new Date(e.timestamp).toLocaleString('de-DE')}
                    </span>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}

// ---------- Main Component ----------

export default function BrainView() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('alerts');

  async function fetchData() {
    try {
      const res = await fetch('/api/brain');
      setData(await res.json());
    } catch (err) {
      console.error('Brain fetch error:', err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  if (loading) return <p className="text-factory-text-secondary p-6">TheBrain wird geladen...</p>;
  if (!data) return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-factory-text">TheBrain</h2>
        <p className="text-sm text-factory-text-secondary mt-1">COO-Level Awareness</p>
      </div>
      <p className="text-factory-text-secondary">Keine Brain-Daten verfuegbar. Ist der State Report vorhanden?</p>
    </div>
  );

  const alertCount = (data.alerts?.length || 0) + (data.health_alerts?.length || 0);
  const TABS = [
    { id: 'alerts', label: 'Alerts', badge: alertCount },
    { id: 'subsystems', label: 'Subsysteme' },
    { id: 'gaps', label: 'Gaps', badge: data.gap_stats?.total || 0 },
    { id: 'directives', label: 'Direktiven' },
    { id: 'agents', label: 'Brain Agents', badge: data.brain_agents?.length || 0 },
    { id: 'memory', label: 'Memory' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-bold text-factory-text">TheBrain</h2>
        <p className="text-sm text-factory-text-secondary mt-1">COO-Level Awareness — Factory Intelligence</p>
      </div>

      {/* Status Header + Stats */}
      <StatusHeader header={data.status_header} capabilities={data.capabilities} />

      {/* Tabs */}
      <div className="border-b border-factory-border flex gap-1 overflow-x-auto">
        {TABS.map(tab => (
          <button key={tab.id} onClick={() => setActiveTab(tab.id)}
            className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors whitespace-nowrap ${
              activeTab === tab.id
                ? 'border-factory-accent text-factory-accent'
                : 'border-transparent text-factory-text-secondary hover:text-factory-text'
            }`}>
            {tab.label}
            {tab.badge > 0 && (
              <span className="ml-2 bg-yellow-500/20 text-yellow-400 text-xs px-1.5 py-0.5 rounded-full">{tab.badge}</span>
            )}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      <div className="bg-factory-surface border border-factory-border rounded-lg p-4">
        {activeTab === 'alerts' && <AlertsPanel alerts={data.alerts} healthAlerts={data.health_alerts} />}
        {activeTab === 'subsystems' && <SubsystemsPanel subsystems={data.subsystems} />}
        {activeTab === 'gaps' && <GapsPanel gaps={data.gaps} gapStats={data.gap_stats} />}
        {activeTab === 'directives' && <DirectivesPanel directives={data.directives} />}
        {activeTab === 'agents' && <BrainAgentsPanel agents={data.brain_agents} />}
        {activeTab === 'memory' && <MemoryPanel memory={data.memory} />}
      </div>
    </div>
  );
}
