import { useState, useEffect } from 'react';
import { RefreshCw, ExternalLink, Edit3 } from 'lucide-react';

const STATUS_STYLES = {
  ok:       { border: 'border-factory-success', bg: 'bg-factory-success/5', dot: 'bg-factory-success' },
  warning:  { border: 'border-factory-warning', bg: 'bg-factory-warning/5', dot: 'bg-factory-warning' },
  critical: { border: 'border-factory-error',   bg: 'bg-factory-error/5',   dot: 'bg-factory-error' },
  unknown:  { border: 'border-factory-border',  bg: 'bg-factory-surface',   dot: 'bg-factory-text-secondary' },
};

export default function ProviderView() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [editBalance, setEditBalance] = useState('');

  useEffect(() => { fetchProviders(); }, []);

  async function fetchProviders() {
    try {
      const res = await fetch('/api/providers');
      setData(await res.json());
    } catch (e) { console.error(e); }
    finally { setLoading(false); }
  }

  async function handleRefresh() {
    setRefreshing(true);
    try {
      const res = await fetch('/api/providers/refresh', { method: 'POST' });
      setData(await res.json());
    } catch (e) { console.error(e); }
    finally { setRefreshing(false); }
  }

  async function handleUpdateBalance(providerId) {
    const val = parseFloat(editBalance);
    if (isNaN(val)) return;
    await fetch(`/api/providers/${providerId}/balance`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ balance: val }),
    });
    setEditingId(null);
    setEditBalance('');
    fetchProviders();
  }

  if (loading) return <p className="text-factory-text-secondary">Lade Provider...</p>;
  if (!data || data.error) return <p className="text-factory-error">Fehler: {data?.error || 'unbekannt'}</p>;

  const s = data.summary || {};
  const providers = data.providers || [];

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="grid grid-cols-5 gap-3 flex-1">
          <MiniCard label="Provider" value={s.total || 0} />
          <MiniCard label="OK" value={s.ok || 0} color="success" />
          <MiniCard label="Warning" value={s.warning || 0} color="warning" />
          <MiniCard label="Kritisch" value={s.critical || 0} color="error" />
          <MiniCard label="Unbekannt" value={s.unknown || 0} />
        </div>
        <button onClick={handleRefresh} disabled={refreshing}
          className="ml-4 flex items-center gap-1 px-3 py-2 bg-factory-bg border border-factory-border rounded-lg text-xs text-factory-text-secondary hover:text-factory-accent disabled:opacity-50">
          <RefreshCw size={12} className={refreshing ? 'animate-spin' : ''} />
          {refreshing ? 'Pruefe...' : 'Refresh'}
        </button>
      </div>

      {/* Alerts */}
      {data.alerts?.length > 0 && (
        <div className="mb-6 space-y-2">
          {data.alerts.map((a, i) => (
            <div key={i} className={`px-4 py-2 rounded-lg text-sm ${
              a.severity === 'critical' ? 'bg-factory-error/20 text-factory-error' : 'bg-factory-warning/20 text-factory-warning'
            }`}>
              {a.message}
            </div>
          ))}
        </div>
      )}

      {/* Provider Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {providers.map(p => {
          const st = STATUS_STYLES[p.status] || STATUS_STYLES.unknown;
          const isEditing = editingId === p.id;

          return (
            <div key={p.id} className={`${st.bg} border-2 ${st.border} rounded-xl p-5`}>
              {/* Header */}
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                  <span className="text-lg">{p.logo_emoji}</span>
                  <span className="font-bold text-factory-text">{p.name}</span>
                </div>
                <span className="text-[10px] px-2 py-0.5 bg-factory-border rounded text-factory-text-secondary uppercase">
                  {p.type}
                </span>
              </div>

              {/* Balance */}
              <div className="text-center py-3">
                {p.balance !== null && p.balance !== undefined ? (
                  <>
                    <p className={`text-3xl font-bold ${
                      p.status === 'critical' ? 'text-factory-error' :
                      p.status === 'warning' ? 'text-factory-warning' : 'text-factory-text'
                    }`}>
                      {p.currency === 'USD' ? `$${Number(p.balance).toFixed(2)}` : `${Number(p.balance).toLocaleString()} ${p.currency}`}
                    </p>
                    <p className="text-xs text-factory-text-secondary mt-1">
                      {p.balance_fresh ? 'Aktuell' : 'Geschaetzt'} • {p.balance_method === 'api' ? 'API' : 'Manuell'}
                    </p>
                  </>
                ) : (
                  <p className="text-factory-text-secondary text-sm py-2">
                    {p.error || 'Kein Guthaben eingetragen'}
                  </p>
                )}
              </div>

              {/* Thresholds */}
              <div className="grid grid-cols-2 gap-2 text-xs mb-3">
                <div className="text-factory-text-secondary">
                  Warnung: {p.warning_threshold} {p.currency}
                </div>
                <div className="text-factory-text-secondary">
                  Kritisch: {p.critical_threshold} {p.currency}
                </div>
                <div className="text-factory-text-secondary">
                  Agents: {p.agent_count}
                </div>
                <div className="text-factory-text-secondary">
                  Key: {p.api_key_set ? '✅' : '❌'}
                </div>
              </div>

              {/* Models */}
              {p.models?.length > 0 && (
                <div className="flex flex-wrap gap-1 mb-3">
                  {p.models.map(m => (
                    <span key={m} className="text-[10px] px-1.5 py-0.5 bg-factory-bg rounded text-factory-text-secondary">{m}</span>
                  ))}
                </div>
              )}

              {/* Actions */}
              <div className="flex gap-2 mt-3">
                {isEditing ? (
                  <div className="flex gap-1 flex-1">
                    <input type="number" value={editBalance} onChange={e => setEditBalance(e.target.value)}
                      placeholder="Betrag" autoFocus
                      className="flex-1 bg-factory-bg border border-factory-border rounded px-2 py-1 text-sm text-factory-text focus:border-factory-accent focus:outline-none"
                      onKeyDown={e => { if (e.key === 'Enter') handleUpdateBalance(p.id); if (e.key === 'Escape') setEditingId(null); }}
                    />
                    <button onClick={() => handleUpdateBalance(p.id)}
                      className="px-2 py-1 bg-factory-accent text-factory-bg rounded text-xs">OK</button>
                    <button onClick={() => setEditingId(null)}
                      className="px-2 py-1 bg-factory-border text-factory-text-secondary rounded text-xs">X</button>
                  </div>
                ) : (
                  <>
                    <button onClick={() => { setEditingId(p.id); setEditBalance(p.balance?.toString() || ''); }}
                      className="flex-1 flex items-center justify-center gap-1 px-2 py-1.5 bg-factory-bg border border-factory-border rounded-lg text-xs text-factory-text-secondary hover:text-factory-accent">
                      <Edit3 size={10} /> Guthaben
                    </button>
                    <a href={p.website} target="_blank" rel="noopener noreferrer"
                      className="flex items-center justify-center gap-1 px-2 py-1.5 bg-factory-bg border border-factory-border rounded-lg text-xs text-factory-text-secondary hover:text-factory-accent">
                      <ExternalLink size={10} /> Website
                    </a>
                  </>
                )}
              </div>

              {/* Last check */}
              {p.last_check && (
                <p className="text-[10px] text-factory-text-secondary mt-2 text-center">
                  Zuletzt: {new Date(p.last_check).toLocaleString('de-DE')}
                </p>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

function MiniCard({ label, value, color }) {
  const c = color === 'success' ? 'text-factory-success' : color === 'warning' ? 'text-factory-warning' : color === 'error' ? 'text-factory-error' : 'text-factory-text';
  return (
    <div className="bg-factory-surface rounded-lg border border-factory-border p-3 text-center">
      <p className={`text-xl font-bold ${c}`}>{value}</p>
      <p className="text-[10px] text-factory-text-secondary">{label}</p>
    </div>
  );
}
