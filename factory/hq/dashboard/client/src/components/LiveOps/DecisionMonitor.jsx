/**
 * DecisionMonitor — Cycle Status + Action Queue Overview.
 *
 * Zeigt:
 * - Orchestrator Status (letzte Zyklen, naechster Run)
 * - Action Queue (pending, in_progress, completed)
 * - Cooling Status aller Apps
 *
 * Pure SVG, keine externen Chart-Libs.
 */

import { useState, useEffect, useCallback } from 'react';

const STATUS_COLORS = {
  pending: 'bg-yellow-500/20 text-yellow-300',
  in_progress: 'bg-blue-500/20 text-blue-300',
  completed: 'bg-green-500/20 text-green-300',
  cancelled: 'bg-red-500/20 text-red-300',
};

const ACTION_ICONS = {
  hotfix: '🔥',
  patch: '🔧',
  feature_update: '✨',
  strategic_pivot: '🎯',
};

export default function DecisionMonitor({ appId }) {
  const [cycleStatus, setCycleStatus] = useState(null);
  const [actionQueue, setActionQueue] = useState([]);
  const [coolingStatus, setCoolingStatus] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    try {
      const urls = [
        '/api/liveops/cycle-status',
        `/api/liveops/action-queue${appId ? `?appId=${appId}` : ''}`,
        '/api/liveops/cooling-status',
      ];
      const [cycleRes, queueRes, coolingRes] = await Promise.all(
        urls.map(u => fetch(u).then(r => r.json()).catch(() => ({})))
      );
      setCycleStatus(cycleRes);
      setActionQueue(queueRes.actions || []);
      setCoolingStatus(coolingRes.cooling || []);
    } catch (err) {
      console.error('DecisionMonitor fetch error:', err);
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
    return <div className="text-factory-text-secondary p-4">Lade Decision Monitor...</div>;
  }

  return (
    <div className="space-y-6">
      {/* Cycle Status */}
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <h3 className="text-white font-semibold mb-4">Cycle Status</h3>
        {cycleStatus ? (
          <div className="grid grid-cols-2 gap-4">
            <StatusCard
              label="Decision Cycles"
              value={cycleStatus.decision_cycles_completed || 0}
              sub={cycleStatus.last_decision_cycle
                ? `Letzter: ${formatTime(cycleStatus.last_decision_cycle)}`
                : 'Noch nicht gestartet'}
            />
            <StatusCard
              label="Anomaly Scans"
              value={cycleStatus.anomaly_scans_completed || 0}
              sub={cycleStatus.last_anomaly_scan
                ? `Letzter: ${formatTime(cycleStatus.last_anomaly_scan)}`
                : 'Noch nicht gestartet'}
            />
          </div>
        ) : (
          <p className="text-factory-text-secondary text-sm">Orchestrator nicht aktiv.</p>
        )}
      </div>

      {/* Action Queue */}
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-white font-semibold">Action Queue</h3>
          <span className="text-xs text-factory-text-secondary">
            {actionQueue.length} Aktionen
          </span>
        </div>
        {actionQueue.length === 0 ? (
          <p className="text-factory-text-secondary text-sm">Keine Aktionen in der Queue.</p>
        ) : (
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {actionQueue.map((action, i) => (
              <div key={action.action_id || i}
                   className="flex items-center justify-between p-3 bg-white/5 rounded-lg">
                <div className="flex items-center gap-3">
                  <span className="text-lg">{ACTION_ICONS[action.action_type] || '?'}</span>
                  <div>
                    <p className="text-white text-sm font-medium">
                      {action.action_type?.replace('_', ' ').toUpperCase()}
                    </p>
                    <p className="text-factory-text-secondary text-xs">
                      {action.app_id?.slice(0, 8)}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <SeverityBadge score={action.severity_score} />
                  <span className={`text-xs px-2 py-0.5 rounded-full ${STATUS_COLORS[action.status] || ''}`}>
                    {action.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Cooling Status */}
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <h3 className="text-white font-semibold mb-4">Cooling Periods</h3>
        {coolingStatus.length === 0 ? (
          <p className="text-factory-text-secondary text-sm">Keine aktiven Cooling Periods.</p>
        ) : (
          <div className="space-y-2">
            {coolingStatus.map((c, i) => (
              <div key={c.app_id || i}
                   className="flex items-center justify-between p-3 bg-white/5 rounded-lg">
                <div>
                  <p className="text-white text-sm">{c.app_name || c.app_id}</p>
                  <p className="text-factory-text-secondary text-xs">{c.cooling_type}</p>
                </div>
                <span className="text-blue-300 text-sm font-mono">{c.remaining_human}</span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ------------------------------------------------------------------
// Sub-Components
// ------------------------------------------------------------------

function StatusCard({ label, value, sub }) {
  return (
    <div className="bg-white/5 rounded-lg p-4">
      <p className="text-factory-text-secondary text-xs mb-1">{label}</p>
      <p className="text-white text-2xl font-bold">{value}</p>
      <p className="text-factory-text-secondary text-xs mt-1">{sub}</p>
    </div>
  );
}

function SeverityBadge({ score }) {
  if (!score && score !== 0) return null;
  const color = score > 85 ? 'text-red-400' : score > 50 ? 'text-yellow-400' : 'text-green-400';
  return <span className={`text-xs font-mono ${color}`}>{Math.round(score)}</span>;
}

function formatTime(iso) {
  if (!iso) return '-';
  try {
    const d = new Date(iso);
    return d.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
  } catch { return iso; }
}
