/**
 * EscalationLog — Chronologisches Log aller Eskalationen.
 *
 * Zeigt:
 * - Alle Eskalationen (Level 1-3) mit Zeitstempel
 * - Filterbar nach App + Level
 * - Telegram-Status bei Level 3
 */

import { useState, useEffect, useCallback } from 'react';

const LEVEL_CONFIG = {
  1: { label: 'Info', color: 'bg-blue-500/20 text-blue-300', icon: 'ℹ️' },
  2: { label: 'Warning', color: 'bg-yellow-500/20 text-yellow-300', icon: '⚠️' },
  3: { label: 'CEO', color: 'bg-red-500/20 text-red-300', icon: '🚨' },
};

export default function EscalationLog({ appId }) {
  const [entries, setEntries] = useState([]);
  const [total, setTotal] = useState(0);
  const [filterLevel, setFilterLevel] = useState(0); // 0 = all
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    try {
      const res = await fetch('/api/liveops/escalation-log?limit=50');
      const data = await res.json();
      setEntries(data.entries || []);
      setTotal(data.total || 0);
    } catch (err) {
      console.error('EscalationLog fetch error:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, [fetchData]);

  if (loading) {
    return <div className="text-factory-text-secondary p-4">Lade Escalation Log...</div>;
  }

  // Filter
  let filtered = entries;
  if (appId) filtered = filtered.filter(e => e.app_id === appId);
  if (filterLevel > 0) filtered = filtered.filter(e => e.escalation_level === filterLevel);

  return (
    <div className="space-y-4">
      {/* Header + Filter */}
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-white font-semibold">Escalation Log</h3>
          <span className="text-xs text-factory-text-secondary">{total} gesamt</span>
        </div>

        {/* Level Filter */}
        <div className="flex gap-2 mb-4">
          <FilterButton active={filterLevel === 0} onClick={() => setFilterLevel(0)} label="Alle" />
          <FilterButton active={filterLevel === 1} onClick={() => setFilterLevel(1)} label="Info" />
          <FilterButton active={filterLevel === 2} onClick={() => setFilterLevel(2)} label="Warning" />
          <FilterButton active={filterLevel === 3} onClick={() => setFilterLevel(3)} label="CEO" />
        </div>

        {/* Entries */}
        {filtered.length === 0 ? (
          <p className="text-factory-text-secondary text-sm">Keine Eskalationen.</p>
        ) : (
          <div className="space-y-2 max-h-96 overflow-y-auto">
            {filtered.map((entry, i) => {
              const levelConf = LEVEL_CONFIG[entry.escalation_level] || LEVEL_CONFIG[1];
              return (
                <div key={i} className="p-3 bg-white/5 rounded-lg">
                  <div className="flex items-center justify-between mb-1">
                    <div className="flex items-center gap-2">
                      <span>{levelConf.icon}</span>
                      <span className={`text-xs px-2 py-0.5 rounded-full ${levelConf.color}`}>
                        {levelConf.label}
                      </span>
                      <span className="text-white text-sm font-medium">
                        {entry.action_type?.replace('_', ' ').toUpperCase()}
                      </span>
                    </div>
                    <span className="text-factory-text-secondary text-xs">
                      {formatTimestamp(entry.timestamp)}
                    </span>
                  </div>
                  <p className="text-factory-text-secondary text-xs mt-1">{entry.detail}</p>
                  <div className="flex items-center gap-3 mt-2">
                    <span className="text-xs text-factory-text-secondary">
                      App: {entry.app_id?.slice(0, 8) || '?'}
                    </span>
                    <span className="text-xs text-factory-text-secondary">
                      Source: {entry.source}
                    </span>
                    {entry.escalation_level >= 3 && (
                      <span className={`text-xs ${entry.telegram_sent ? 'text-green-400' : 'text-yellow-400'}`}>
                        Telegram: {entry.telegram_sent ? 'gesendet' : 'nicht gesendet'}
                      </span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

// ------------------------------------------------------------------
// Sub-Components
// ------------------------------------------------------------------

function FilterButton({ active, onClick, label }) {
  return (
    <button
      onClick={onClick}
      className={`px-3 py-1 text-xs rounded-full transition-colors ${
        active
          ? 'bg-factory-accent text-white'
          : 'bg-white/5 text-factory-text-secondary hover:text-white'
      }`}
    >
      {label}
    </button>
  );
}

function formatTimestamp(iso) {
  if (!iso) return '-';
  try {
    const d = new Date(iso);
    return d.toLocaleString('de-DE', {
      day: '2-digit', month: '2-digit',
      hour: '2-digit', minute: '2-digit'
    });
  } catch { return iso; }
}
