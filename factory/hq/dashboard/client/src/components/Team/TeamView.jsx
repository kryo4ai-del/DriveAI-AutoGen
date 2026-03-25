import { useState, useEffect } from 'react';
import { Users, ChevronRight, X, RefreshCw } from 'lucide-react';

const STATUS_ICONS = { active: '🟢', disabled: '🔴', planned: '⚫' };
const DEPARTMENTS = ['Alle', 'Code-Pipeline', 'Swarm Factory', 'Infrastruktur'];

export default function TeamView() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [deptFilter, setDeptFilter] = useState('Alle');
  const [selectedAgent, setSelectedAgent] = useState(null);
  const [refreshing, setRefreshing] = useState(false);

  function loadTeam() {
    fetch('/api/team')
      .then(r => r.json())
      .then(setData)
      .finally(() => setLoading(false));
  }

  async function handleRefresh() {
    setRefreshing(true);
    try {
      await fetch('/api/team/refresh', { method: 'POST' });
      loadTeam();
    } catch (e) { /* ignore */ }
    finally { setRefreshing(false); }
  }

  useEffect(() => { loadTeam(); }, []);

  if (loading) return <p className="text-factory-text-secondary">Lade Team...</p>;
  if (!data) return null;

  const agents = deptFilter === 'Alle'
    ? data.agents
    : data.agents.filter(a => a.department === deptFilter);
  const summary = data.summary || {};

  return (
    <div className="flex gap-6">
      {/* Main content */}
      <div className="flex-1">
        {/* Header with Refresh */}
        <div className="flex items-center justify-between mb-4">
          <span className="text-factory-text-secondary text-sm">{data.agents.length} Agents via Auto-Discovery</span>
          <button
            onClick={handleRefresh}
            disabled={refreshing}
            className="flex items-center gap-1 px-3 py-1 text-xs bg-factory-bg border border-factory-border rounded-lg text-factory-text-secondary hover:text-factory-accent transition-colors disabled:opacity-50"
            title="Agent-Verzeichnisse neu scannen"
          >
            <RefreshCw size={12} className={refreshing ? 'animate-spin' : ''} />
            {refreshing ? 'Scanning...' : 'Refresh'}
          </button>
        </div>
        {/* Summary Cards */}
        <div className="grid grid-cols-4 gap-4 mb-6">
          <StatCard label="Gesamt" value={summary.total || 0} />
          <StatCard label="Aktiv" value={summary.active || 0} color="success" />
          <StatCard label="Disabled" value={summary.disabled || 0} color="error" />
          <StatCard label="Geplant" value={summary.planned || 0} color="warning" />
        </div>

        {/* Department Tabs */}
        <div className="flex gap-2 mb-4">
          {DEPARTMENTS.map(d => {
            const count = d === 'Alle' ? data.agents.length : data.agents.filter(a => a.department === d).length;
            return (
              <button
                key={d}
                onClick={() => { setDeptFilter(d); setSelectedAgent(null); }}
                className={`px-4 py-2 rounded-lg text-sm transition-colors ${
                  deptFilter === d
                    ? 'bg-factory-accent text-factory-bg font-medium'
                    : 'bg-factory-surface text-factory-text-secondary hover:text-factory-text'
                }`}
              >
                {d} ({count})
              </button>
            );
          })}
        </div>

        {/* Agent Table */}
        <div className="bg-factory-surface rounded-xl border border-factory-border overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="border-b border-factory-border text-left">
                <th className="px-3 py-2 text-xs text-factory-text-secondary w-8"></th>
                <th className="px-3 py-2 text-xs text-factory-text-secondary">ID</th>
                <th className="px-3 py-2 text-xs text-factory-text-secondary">Name</th>
                <th className="px-3 py-2 text-xs text-factory-text-secondary">Rolle</th>
                <th className="px-3 py-2 text-xs text-factory-text-secondary">Kapitel</th>
                <th className="px-3 py-2 text-xs text-factory-text-secondary">Modell</th>
                <th className="px-3 py-2 text-xs text-factory-text-secondary">Provider</th>
                <th className="px-3 py-2 text-xs text-factory-text-secondary w-6"></th>
              </tr>
            </thead>
            <tbody>
              {agents.map((a, i) => (
                <tr
                  key={a.id}
                  onClick={() => setSelectedAgent(a)}
                  className={`border-b border-factory-border/30 cursor-pointer hover:bg-factory-surface-hover transition-colors ${
                    i % 2 === 1 ? 'bg-factory-bg/20' : ''
                  } ${selectedAgent?.id === a.id ? 'bg-factory-accent/10' : ''}`}
                >
                  <td className="px-3 py-2 text-center text-sm">{STATUS_ICONS[a.status] || '⚫'}</td>
                  <td className="px-3 py-2 text-xs text-factory-text-secondary font-mono">{a.id}</td>
                  <td className="px-3 py-2 text-sm text-factory-text font-medium">{a.name}</td>
                  <td className="px-3 py-2 text-xs text-factory-text-secondary">{a.role}</td>
                  <td className="px-3 py-2 text-xs text-factory-text-secondary">{a.chapter || '—'}</td>
                  <td className="px-3 py-2 text-xs text-factory-text-secondary">{a.default_model || '—'}</td>
                  <td className="px-3 py-2 text-xs text-factory-text-secondary">{a.provider || '—'}</td>
                  <td className="px-3 py-2"><ChevronRight size={12} className="text-factory-text-secondary" /></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Provider Distribution */}
        <div className="mt-6">
          <h3 className="text-sm font-medium text-factory-text-secondary mb-3 uppercase tracking-wide">Provider-Verteilung</h3>
          <div className="grid grid-cols-5 gap-3">
            {Object.entries(summary.by_provider || {}).map(([prov, count]) => (
              <div key={prov} className="bg-factory-surface rounded-lg border border-factory-border p-3 text-center">
                <p className="text-lg font-bold text-factory-text">{count}</p>
                <p className="text-xs text-factory-text-secondary capitalize">{prov === 'none' ? 'Kein LLM' : prov}</p>
                <p className="text-[10px] text-factory-text-secondary">{Math.round(count / (summary.total || 1) * 100)}%</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Detail Panel */}
      {selectedAgent && (
        <div className="w-80 bg-factory-surface rounded-xl border border-factory-border p-5 flex-shrink-0 h-fit sticky top-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-factory-text">{selectedAgent.name}</h3>
            <button onClick={() => setSelectedAgent(null)} className="text-factory-text-secondary hover:text-factory-text">
              <X size={16} />
            </button>
          </div>
          <div className="space-y-3 text-sm">
            <DetailRow label="ID" value={selectedAgent.id} />
            <DetailRow label="Rolle" value={selectedAgent.role} />
            <DetailRow label="Abteilung" value={selectedAgent.department} />
            <DetailRow label="Kapitel" value={selectedAgent.chapter || '—'} />
            <DetailRow label="Datei" value={selectedAgent.file} mono />
            <DetailRow label="Modell" value={selectedAgent.default_model || '—'} />
            <DetailRow label="Provider" value={selectedAgent.provider || '—'} />
            <DetailRow label="Routing" value={selectedAgent.routing || '—'} />
            <DetailRow label="Web" value={selectedAgent.uses_web ? 'Ja (SerpAPI)' : 'Nein'} />
            <DetailRow label="Status" value={`${STATUS_ICONS[selectedAgent.status] || ''} ${selectedAgent.status}`} />
            <div className="pt-2 border-t border-factory-border">
              <p className="text-xs text-factory-text-secondary">{selectedAgent.description}</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function StatCard({ label, value, color }) {
  const c = color === 'success' ? 'text-factory-success' : color === 'error' ? 'text-factory-error' : color === 'warning' ? 'text-factory-warning' : 'text-factory-text';
  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-4">
      <p className="text-sm text-factory-text-secondary">{label}</p>
      <p className={`text-2xl font-bold ${c} mt-1`}>{value}</p>
    </div>
  );
}

function DetailRow({ label, value, mono }) {
  return (
    <div>
      <p className="text-xs text-factory-text-secondary">{label}</p>
      <p className={`text-factory-text ${mono ? 'font-mono text-xs' : 'text-sm'}`}>{value}</p>
    </div>
  );
}
