import { useState, useEffect } from 'react';

const SEVERITY_COLORS = {
  green: { bg: 'bg-green-500/10', text: 'text-green-400', border: 'border-green-500/30', dot: 'bg-green-400' },
  yellow: { bg: 'bg-yellow-500/10', text: 'text-yellow-400', border: 'border-yellow-500/30', dot: 'bg-yellow-400' },
  red: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/30', dot: 'bg-red-400' },
};

function HealthBar({ score }) {
  const pct = Math.max(0, Math.min(100, score || 0));
  const color = pct >= 80 ? 'bg-green-500' : pct >= 60 ? 'bg-yellow-500' : 'bg-red-500';
  return (
    <div className="flex items-center gap-3">
      <span className="text-2xl font-bold text-factory-text">{pct}/100</span>
      <div className="flex-1 h-3 bg-factory-bg rounded-full overflow-hidden">
        <div className={`h-full ${color} rounded-full transition-all`} style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

function StatCard({ label, value, sub }) {
  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-4">
      <p className="text-factory-text-secondary text-xs uppercase">{label}</p>
      <p className="text-xl font-bold text-factory-text mt-1">{value}</p>
      {sub && <p className="text-xs text-factory-text-secondary mt-1">{sub}</p>}
    </div>
  );
}

function FindingsTable({ findings, filter }) {
  const filtered = filter === 'all' ? findings : findings.filter(f => f.severity === filter);
  if (!filtered.length) return <p className="text-factory-text-secondary text-sm py-4">Keine Findings.</p>;

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-factory-text-secondary text-left border-b border-factory-border">
            <th className="py-2 px-2 w-8"></th>
            <th className="py-2 px-2">ID</th>
            <th className="py-2 px-2">Typ</th>
            <th className="py-2 px-2">Pfad / Titel</th>
            <th className="py-2 px-2 text-right">Dateien</th>
          </tr>
        </thead>
        <tbody>
          {filtered.slice(0, 50).map((f, i) => {
            const sev = SEVERITY_COLORS[f.severity] || SEVERITY_COLORS.red;
            return (
              <tr key={i} className="border-b border-factory-border/30 hover:bg-factory-surface-hover">
                <td className="py-2 px-2"><span className={`inline-block w-2 h-2 rounded-full ${sev.dot}`} /></td>
                <td className="py-2 px-2 font-mono text-xs">{f.id}</td>
                <td className="py-2 px-2"><span className={`text-xs px-2 py-0.5 rounded ${sev.bg} ${sev.text}`}>{f.type}</span></td>
                <td className="py-2 px-2 text-factory-text truncate max-w-md">{f.title || f.details || f.path}</td>
                <td className="py-2 px-2 text-right text-factory-text-secondary">{f.affected_count || 1}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
      {filtered.length > 50 && <p className="text-xs text-factory-text-secondary py-2">... und {filtered.length - 50} weitere</p>}
    </div>
  );
}

function HistoryTable({ entries }) {
  if (!entries.length) return <p className="text-factory-text-secondary text-sm py-4">Noch keine Scans.</p>;
  return (
    <table className="w-full text-sm">
      <thead>
        <tr className="text-factory-text-secondary text-left border-b border-factory-border">
          <th className="py-2 px-2">Datum</th>
          <th className="py-2 px-2">Zyklus</th>
          <th className="py-2 px-2 text-right">Findings</th>
          <th className="py-2 px-2 text-right">Auto-Fixed</th>
          <th className="py-2 px-2 text-right">Proposals</th>
          <th className="py-2 px-2 text-right">Health</th>
          <th className="py-2 px-2 text-right">Kosten</th>
        </tr>
      </thead>
      <tbody>
        {entries.map((e, i) => (
          <tr key={i} className="border-b border-factory-border/30">
            <td className="py-2 px-2 font-mono text-xs">{e.timestamp ? new Date(e.timestamp).toLocaleString('de-DE') : '-'}</td>
            <td className="py-2 px-2">
              <span className={`text-xs px-2 py-0.5 rounded ${
                e.cycle === 'daily' ? 'bg-blue-500/10 text-blue-400' :
                e.cycle === 'weekly' ? 'bg-purple-500/10 text-purple-400' :
                'bg-orange-500/10 text-orange-400'
              }`}>{e.cycle}</span>
            </td>
            <td className="py-2 px-2 text-right text-factory-text">{e.finding_count}</td>
            <td className="py-2 px-2 text-right text-green-400">{e.auto_fixed || 0}</td>
            <td className="py-2 px-2 text-right text-yellow-400">{e.proposed || 0}</td>
            <td className="py-2 px-2 text-right text-factory-text">{e.health_score || '-'}</td>
            <td className="py-2 px-2 text-right text-factory-text-secondary">${(e.cost_usd || 0).toFixed(4)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function QuarantineTable({ items, onRestore }) {
  if (!items.length) return <p className="text-factory-text-secondary text-sm py-4">Quarantaene leer.</p>;
  return (
    <table className="w-full text-sm">
      <thead>
        <tr className="text-factory-text-secondary text-left border-b border-factory-border">
          <th className="py-2 px-2">Datei</th>
          <th className="py-2 px-2">Grund</th>
          <th className="py-2 px-2">Seit</th>
          <th className="py-2 px-2">Auto-Loeschung</th>
          <th className="py-2 px-2"></th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, i) => (
          <tr key={i} className="border-b border-factory-border/30">
            <td className="py-2 px-2 font-mono text-xs text-factory-text">{item.original_path}</td>
            <td className="py-2 px-2 text-factory-text-secondary text-xs">{item.reason}</td>
            <td className="py-2 px-2 text-xs">{item.quarantined_at ? new Date(item.quarantined_at).toLocaleDateString('de-DE') : '-'}</td>
            <td className="py-2 px-2 text-xs">{item.auto_delete_after ? new Date(item.auto_delete_after).toLocaleDateString('de-DE') : '-'}</td>
            <td className="py-2 px-2">
              <button
                onClick={() => onRestore(item.original_path)}
                className="text-xs px-2 py-1 rounded bg-blue-500/20 text-blue-400 hover:bg-blue-500/30"
              >Restore</button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function ProposalsList({ proposals, onDecide }) {
  if (!proposals.length) return <p className="text-factory-text-secondary text-sm py-4">Keine offenen Vorschlaege.</p>;
  return (
    <div className="space-y-3">
      {proposals.map((p, i) => (
        <div key={i} className="bg-factory-surface border border-yellow-500/30 rounded-lg p-4">
          <div className="flex items-start justify-between">
            <div>
              <span className="text-xs font-mono text-yellow-400">{p.proposal_id}</span>
              <h4 className="text-factory-text font-medium mt-1">{p.title}</h4>
              <p className="text-xs text-factory-text-secondary mt-1">{p.description}</p>
              {p.affected_files && (
                <p className="text-xs text-factory-text-secondary mt-2 font-mono">
                  {p.affected_files.slice(0, 3).join(', ')}{p.affected_files.length > 3 ? ` +${p.affected_files.length - 3}` : ''}
                </p>
              )}
            </div>
            <div className="flex gap-2 ml-4">
              <button onClick={() => onDecide(p.proposal_id, 'approved')}
                className="text-xs px-3 py-1.5 rounded bg-green-500/20 text-green-400 hover:bg-green-500/30">
                Genehmigen
              </button>
              <button onClick={() => onDecide(p.proposal_id, 'rejected')}
                className="text-xs px-3 py-1.5 rounded bg-red-500/20 text-red-400 hover:bg-red-500/30">
                Ablehnen
              </button>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

export default function JanitorView() {
  const [data, setData] = useState(null);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [scanning, setScanning] = useState(false);
  const [activeTab, setActiveTab] = useState('findings');
  const [findingFilter, setFindingFilter] = useState('all');

  async function fetchData() {
    try {
      const [statusRes, historyRes] = await Promise.all([
        fetch('/api/janitor'),
        fetch('/api/janitor/history'),
      ]);
      setData(await statusRes.json());
      const h = await historyRes.json();
      setHistory(h.entries || []);
    } catch (err) {
      console.error('Janitor fetch error:', err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  async function handleScan(level) {
    setScanning(true);
    try {
      await fetch('/api/janitor/scan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ level }),
      });
      await fetchData();
    } catch (err) {
      console.error('Scan error:', err);
    } finally {
      setScanning(false);
    }
  }

  async function handleRestore(path) {
    try {
      await fetch('/api/janitor/restore', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ path }),
      });
      await fetchData();
    } catch (err) {
      console.error('Restore error:', err);
    }
  }

  async function handleDecide(proposalId, decision) {
    try {
      await fetch(`/api/janitor/proposals/${proposalId}/decide`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ decision }),
      });
      await fetchData();
    } catch (err) {
      console.error('Decide error:', err);
    }
  }

  if (loading) return <p className="text-factory-text-secondary p-6">Janitor wird geladen...</p>;
  if (!data) return <p className="text-factory-text-secondary p-6">Keine Daten. Starte einen Scan.</p>;

  const summary = data.latest_summary || {};
  const findings = data.findings || [];
  const greenCount = summary.green_auto_fixable || 0;
  const yellowCount = summary.yellow_proposals || 0;
  const redCount = summary.red_report_only || 0;

  const TABS = [
    { id: 'findings', label: 'Findings' },
    { id: 'history', label: 'Aktions-Log' },
    { id: 'quarantine', label: 'Quarantaene' },
    { id: 'proposals', label: 'Vorschlaege', badge: data.proposals?.total || 0 },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-factory-text">Factory Janitor</h2>
          <p className="text-sm text-factory-text-secondary mt-1">Autonome Code-Hygiene</p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => handleScan('daily')} disabled={scanning}
            className="text-xs px-3 py-1.5 rounded bg-blue-500/20 text-blue-400 hover:bg-blue-500/30 disabled:opacity-50">
            {scanning ? 'Scannt...' : 'Daily Scan'}
          </button>
          <button onClick={() => handleScan('weekly')} disabled={scanning}
            className="text-xs px-3 py-1.5 rounded bg-purple-500/20 text-purple-400 hover:bg-purple-500/30 disabled:opacity-50">
            Weekly
          </button>
        </div>
      </div>

      {/* Health Score */}
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <p className="text-xs text-factory-text-secondary uppercase mb-2">Factory Health Score</p>
        <HealthBar score={data.health_score} />
        <div className="flex gap-4 mt-3 text-xs text-factory-text-secondary">
          {data.last_scans?.daily && <span>Daily: {new Date(data.last_scans.daily).toLocaleString('de-DE')}</span>}
          {data.last_scans?.weekly && <span>Weekly: {new Date(data.last_scans.weekly).toLocaleString('de-DE')}</span>}
          {data.last_scans?.monthly && <span>Monthly: {new Date(data.last_scans.monthly).toLocaleString('de-DE')}</span>}
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard label="Dateien" value={data.latest_scan?.total_files || 0} sub={`${data.latest_scan?.total_size_mb || 0} MB`} />
        <StatCard label="Code-Zeilen" value={(data.latest_scan?.total_lines || 0).toLocaleString('de-DE')} />
        <StatCard label="Graph Nodes" value={data.latest_graph?.total_nodes || 0} sub={`${data.latest_graph?.total_edges || 0} Edges`} />
        <StatCard label="Findings" value={summary.total_findings || 0}
          sub={`G:${greenCount} Y:${yellowCount} R:${redCount}`} />
      </div>

      {/* Tabs */}
      <div className="border-b border-factory-border flex gap-1">
        {TABS.map(tab => (
          <button key={tab.id} onClick={() => setActiveTab(tab.id)}
            className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
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
        {activeTab === 'findings' && (
          <>
            <div className="flex gap-2 mb-4">
              {[
                { id: 'all', label: 'Alle', count: findings.length },
                { id: 'green', label: 'Auto-Fix', count: greenCount },
                { id: 'yellow', label: 'Vorschlaege', count: yellowCount },
                { id: 'red', label: 'Reports', count: redCount },
              ].map(f => (
                <button key={f.id} onClick={() => setFindingFilter(f.id)}
                  className={`text-xs px-3 py-1 rounded transition-colors ${
                    findingFilter === f.id
                      ? 'bg-factory-accent/20 text-factory-accent'
                      : 'bg-factory-bg text-factory-text-secondary hover:text-factory-text'
                  }`}>
                  {f.label} ({f.count})
                </button>
              ))}
            </div>
            <FindingsTable findings={findings} filter={findingFilter} />
          </>
        )}
        {activeTab === 'history' && <HistoryTable entries={history} />}
        {activeTab === 'quarantine' && (
          <QuarantineTable items={data.quarantine?.items || []} onRestore={handleRestore} />
        )}
        {activeTab === 'proposals' && (
          <ProposalsList proposals={data.proposals?.items || []} onDecide={handleDecide} />
        )}
      </div>
    </div>
  );
}
