/**
 * SystemHealthPanel — System Health Status fuer Phase 6.
 * Zeigt Self-Healing Checks, Healer Status, Error Log.
 */

import { useState, useEffect } from 'react';

const CHECK_ICONS = { true: '✓', false: '✗', null: '?' };

export default function SystemHealthPanel() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchHealth();
    const interval = setInterval(fetchHealth, 30000);
    return () => clearInterval(interval);
  }, []);

  async function fetchHealth() {
    try {
      const res = await fetch('/api/liveops/system-health');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setHealth(data);
    } catch {
      setHealth({ error: 'Nicht erreichbar' });
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="bg-factory-surface border border-factory-border rounded-lg p-4">
        <div className="text-factory-text-secondary text-sm">Lade System Health...</div>
      </div>
    );
  }

  if (!health || health.error) {
    return (
      <div className="bg-factory-surface border border-factory-error/30 rounded-lg p-4">
        <h3 className="text-sm font-semibold text-factory-error">System Health</h3>
        <p className="text-xs text-factory-text-secondary mt-1">{health?.error || 'Fehler'}</p>
      </div>
    );
  }

  const allOk = health.all_ok;
  const checks = health.checks || {};
  const checkEntries = Object.entries(checks);

  return (
    <div className={`bg-factory-surface border rounded-lg p-4 ${
      allOk ? 'border-factory-success/30' : 'border-factory-error/30'
    }`}>
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-semibold text-white">System Health</h3>
        <span className={`text-xs px-2 py-0.5 rounded-full ${
          allOk
            ? 'bg-factory-success/20 text-factory-success'
            : 'bg-factory-error/20 text-factory-error'
        }`}>
          {allOk ? 'ALL OK' : 'ISSUES'}
        </span>
      </div>

      <div className="space-y-1.5">
        {checkEntries.map(([name, check]) => (
          <div key={name} className="flex items-center justify-between text-xs">
            <span className="text-factory-text-secondary">{formatCheckName(name)}</span>
            <span className={check.ok ? 'text-factory-success' : 'text-factory-error'}>
              {CHECK_ICONS[check.ok]} {check.ok ? 'OK' : 'FAIL'}
            </span>
          </div>
        ))}
      </div>

      {health.warnings && health.warnings.length > 0 && (
        <div className="mt-3 pt-2 border-t border-factory-border">
          <p className="text-xs text-factory-warning">
            {health.warnings.length} Warning(s)
          </p>
        </div>
      )}
    </div>
  );
}

function formatCheckName(name) {
  return name
    .replace(/_/g, ' ')
    .replace(/\b\w/g, c => c.toUpperCase());
}
