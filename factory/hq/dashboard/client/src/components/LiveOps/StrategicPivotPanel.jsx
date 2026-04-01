/**
 * StrategicPivotPanel — CEO-Eskalationen die menschliche Entscheidung brauchen.
 *
 * Zeigt prominente Karten fuer alle Level-3 Eskalationen
 * mit vollstaendigem Report und Handlungsvorschlag.
 */

import { useState, useEffect, useCallback } from 'react';

export default function StrategicPivotPanel({ appId }) {
  const [pivots, setPivots] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    try {
      const res = await fetch('/api/liveops/strategic-pivots');
      const data = await res.json();
      let items = data.pivots || [];
      if (appId) items = items.filter(p => p.app_id === appId);
      setPivots(items);
    } catch (err) {
      console.error('StrategicPivotPanel fetch error:', err);
    } finally {
      setLoading(false);
    }
  }, [appId]);

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, [fetchData]);

  if (loading) {
    return <div className="text-factory-text-secondary p-4">Lade Strategic Pivots...</div>;
  }

  if (pivots.length === 0) {
    return (
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <h3 className="text-white font-semibold mb-2">Strategic Pivots</h3>
        <p className="text-factory-text-secondary text-sm">
          Keine CEO-Eskalationen ausstehend. Alles unter Kontrolle.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <h3 className="text-white font-semibold">CEO-Entscheidungen erforderlich</h3>

      {pivots.map((pivot, i) => (
        <PivotCard key={i} pivot={pivot} />
      ))}
    </div>
  );
}

// ------------------------------------------------------------------
// Sub-Components
// ------------------------------------------------------------------

function PivotCard({ pivot }) {
  return (
    <div className="bg-red-500/10 border border-red-500/30 rounded-lg p-5">
      {/* Header */}
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <span className="text-xl">🚨</span>
          <span className="text-red-300 font-semibold text-sm">
            {pivot.action_type?.replace('_', ' ').toUpperCase()}
          </span>
        </div>
        <span className="text-factory-text-secondary text-xs">
          {formatTimestamp(pivot.timestamp)}
        </span>
      </div>

      {/* Detail */}
      <p className="text-white text-sm mb-3">{pivot.detail}</p>

      {/* Metadata */}
      <div className="grid grid-cols-3 gap-3 mb-3">
        <MetaItem label="App" value={pivot.app_id?.slice(0, 12) || '?'} />
        <MetaItem label="Severity" value={Math.round(pivot.severity || 0)} />
        <MetaItem label="Source" value={pivot.source || '?'} />
      </div>

      {/* Recommendation */}
      {pivot.recommendation && (
        <div className="bg-white/5 rounded-lg p-3 mt-3">
          <p className="text-factory-text-secondary text-xs mb-1">Empfehlung:</p>
          <p className="text-white text-sm">{pivot.recommendation}</p>
        </div>
      )}

      {/* Telegram Status */}
      <div className="flex items-center gap-2 mt-3">
        <span className={`text-xs ${pivot.telegram_sent ? 'text-green-400' : 'text-yellow-400'}`}>
          Telegram: {pivot.telegram_sent ? 'gesendet' : 'nicht gesendet'}
        </span>
      </div>
    </div>
  );
}

function MetaItem({ label, value }) {
  return (
    <div>
      <p className="text-factory-text-secondary text-xs">{label}</p>
      <p className="text-white text-sm font-mono">{value}</p>
    </div>
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
