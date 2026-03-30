/**
 * AppDetailView — Detailansicht einer einzelnen App.
 * Health Score Chart, Kategorie-Breakdown, Alerts, Release History, Action Queue.
 *
 * Kein recharts — nutzt reine SVG-Charts (keine zusaetzliche Dependency noetig).
 */

import { useState, useEffect, useCallback } from 'react';
import { ArrowLeft } from 'lucide-react';
import HealthScoreCircle, { getColor, getZone } from './HealthScoreCircle';

const ZONE_ICONS = { green: '🟢', yellow: '🟡', red: '🔴' };
const PROFILE_COLORS = {
  gaming: 'bg-purple-500/20 text-purple-300',
  education: 'bg-blue-500/20 text-blue-300',
  utility: 'bg-gray-500/20 text-gray-300',
  content: 'bg-orange-500/20 text-orange-300',
  subscription: 'bg-emerald-500/20 text-emerald-300',
};
const CATEGORY_LABELS = {
  stability: 'Stability',
  satisfaction: 'Satisfaction',
  engagement: 'Engagement',
  revenue: 'Revenue',
  growth: 'Growth',
};

export default function AppDetailView({ appId, onBack }) {
  const [app, setApp] = useState(null);
  const [healthHistory, setHealthHistory] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    try {
      const [appRes, historyRes] = await Promise.all([
        fetch(`/api/liveops/app/${appId}`),
        fetch(`/api/liveops/app/${appId}/health-history`),
      ]);
      if (appRes.ok) setApp(await appRes.json());
      if (historyRes.ok) {
        const data = await historyRes.json();
        setHealthHistory(data.history || []);
      }
    } catch (err) {
      console.error('LiveOps fetch error:', err);
    } finally {
      setLoading(false);
    }
  }, [appId]);

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 15000);
    return () => clearInterval(interval);
  }, [fetchData]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-factory-text-secondary">Lade App-Details...</div>
      </div>
    );
  }

  if (!app) {
    return (
      <div className="text-center py-12">
        <p className="text-factory-text-secondary">App nicht gefunden.</p>
        <button onClick={onBack} className="text-factory-accent mt-2 hover:underline">Zurueck</button>
      </div>
    );
  }

  const zone = getZone(app.health_score || 0);
  const profileClass = PROFILE_COLORS[app.app_profile] || PROFILE_COLORS.utility;

  return (
    <div>
      {/* Header */}
      <div className="flex items-center gap-4 mb-6">
        <button
          onClick={onBack}
          className="p-2 text-factory-text-secondary hover:text-white hover:bg-factory-surface-hover rounded transition-colors"
        >
          <ArrowLeft size={20} />
        </button>
        <div className="flex-1">
          <div className="flex items-center gap-3">
            <h2 className="text-2xl font-bold text-white">{app.app_name}</h2>
            <span className={`text-xs px-2 py-0.5 rounded-full ${profileClass}`}>
              {app.app_profile || 'utility'}
            </span>
          </div>
          <p className="text-factory-text-secondary text-sm mt-0.5">
            {app.bundle_id || app.package_name || app.app_id}
            {app.current_version && ` • v${app.current_version}`}
          </p>
        </div>
        <HealthScoreCircle score={app.health_score || 0} size="lg" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left Column */}
        <div className="space-y-6">
          {/* Category Breakdown */}
          <CategoryBreakdown scores={app.category_scores} />

          {/* Alerts */}
          {app.alerts && app.alerts.length > 0 && (
            <AlertsSection alerts={app.alerts} />
          )}

          {/* Cooling Status */}
          {app.cooling_info && (
            <CoolingSection info={app.cooling_info} />
          )}
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          {/* Health History Chart */}
          <HealthChart history={healthHistory} />

          {/* Release History */}
          <ReleaseHistory releases={app.releases || []} />

          {/* Action Queue */}
          <ActionQueue actions={app.actions || []} />
        </div>
      </div>
    </div>
  );
}

// ------------------------------------------------------------------
// Sub-Components
// ------------------------------------------------------------------

function CategoryBreakdown({ scores }) {
  if (!scores || scores.length === 0) {
    return (
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <h3 className="text-white font-semibold mb-4">Kategorie-Breakdown</h3>
        <p className="text-factory-text-secondary text-sm">Noch keine Score-Daten vorhanden.</p>
      </div>
    );
  }

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">Kategorie-Breakdown</h3>
      <div className="space-y-3">
        {Object.entries(scores).map(([cat, data]) => {
          const score = data?.score ?? data ?? 0;
          const weight = data?.weight ?? 0;
          const color = getColor(score);
          const label = CATEGORY_LABELS[cat] || cat;

          return (
            <div key={cat}>
              <div className="flex items-center justify-between text-sm mb-1">
                <span className="text-factory-text-secondary">{label}</span>
                <div className="flex items-center gap-2">
                  <span className="text-xs text-factory-text-secondary">x{weight.toFixed(2)}</span>
                  <span className="text-white font-medium w-10 text-right">{Math.round(score)}</span>
                </div>
              </div>
              <div className="w-full bg-white/5 rounded-full h-2">
                <div
                  className="h-2 rounded-full transition-all duration-500"
                  style={{ width: `${Math.min(score, 100)}%`, backgroundColor: color }}
                />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function AlertsSection({ alerts }) {
  return (
    <div className="bg-factory-error/5 border border-factory-error/20 rounded-lg p-5">
      <h3 className="text-factory-error font-semibold mb-3">Alerts ({alerts.length})</h3>
      <div className="space-y-2">
        {alerts.map((alert, i) => (
          <div key={i} className="flex items-start gap-2 text-sm">
            <span className="text-factory-error mt-0.5">⚠</span>
            <div>
              <span className="text-factory-text-secondary">[{alert.category}]</span>{' '}
              <span className="text-white">{alert.message}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function CoolingSection({ info }) {
  return (
    <div className="bg-factory-accent-blue/5 border border-factory-accent-blue/20 rounded-lg p-5">
      <h3 className="text-factory-accent-blue font-semibold mb-2">Cooling Period aktiv</h3>
      <p className="text-sm text-factory-text-secondary">
        Typ: <span className="text-white">{info.cooling_type}</span>
      </p>
      <p className="text-sm text-factory-text-secondary">
        Verbleibend: <span className="text-white">{info.remaining_human}</span>
      </p>
    </div>
  );
}

function HealthChart({ history }) {
  if (!history || history.length < 2) {
    return (
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <h3 className="text-white font-semibold mb-4">Health Score Verlauf</h3>
        <div className="flex items-center justify-center h-40 text-factory-text-secondary text-sm">
          Mindestens 2 Datenpunkte noetig fuer Chart.
        </div>
      </div>
    );
  }

  // Simple SVG line chart
  const width = 500;
  const height = 160;
  const padding = { top: 10, right: 10, bottom: 20, left: 35 };
  const chartW = width - padding.left - padding.right;
  const chartH = height - padding.top - padding.bottom;

  const data = [...history].reverse().slice(-30); // chronological, max 30
  const maxScore = 100;

  const points = data.map((d, i) => ({
    x: padding.left + (i / Math.max(data.length - 1, 1)) * chartW,
    y: padding.top + chartH - ((d.overall_score || 0) / maxScore) * chartH,
    score: d.overall_score || 0,
  }));

  const pathD = points.map((p, i) => `${i === 0 ? 'M' : 'L'} ${p.x} ${p.y}`).join(' ');

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">Health Score Verlauf</h3>
      <svg viewBox={`0 0 ${width} ${height}`} className="w-full" preserveAspectRatio="xMidYMid meet">
        {/* Grid lines */}
        {[0, 25, 50, 75, 100].map(val => {
          const y = padding.top + chartH - (val / maxScore) * chartH;
          return (
            <g key={val}>
              <line x1={padding.left} y1={y} x2={width - padding.right} y2={y}
                stroke="rgba(255,255,255,0.06)" strokeDasharray="4 4" />
              <text x={padding.left - 5} y={y + 4} fill="rgba(255,255,255,0.3)"
                fontSize="9" textAnchor="end">{val}</text>
            </g>
          );
        })}

        {/* Zone backgrounds */}
        <rect x={padding.left} y={padding.top}
          width={chartW} height={chartH * 0.2}
          fill="rgba(34,197,94,0.05)" />
        <rect x={padding.left} y={padding.top + chartH * 0.2}
          width={chartW} height={chartH * 0.3}
          fill="rgba(234,179,8,0.03)" />
        <rect x={padding.left} y={padding.top + chartH * 0.5}
          width={chartW} height={chartH * 0.5}
          fill="rgba(239,68,68,0.03)" />

        {/* Line */}
        <path d={pathD} fill="none" stroke="#D660D7" strokeWidth="2" strokeLinejoin="round" />

        {/* Dots */}
        {points.map((p, i) => (
          <circle key={i} cx={p.x} cy={p.y} r="3"
            fill={getColor(p.score)} stroke="rgba(0,0,0,0.3)" strokeWidth="1" />
        ))}
      </svg>
    </div>
  );
}

function ReleaseHistory({ releases }) {
  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">Release History</h3>
      {releases.length === 0 ? (
        <p className="text-factory-text-secondary text-sm">Keine Releases vorhanden.</p>
      ) : (
        <div className="space-y-2 max-h-48 overflow-y-auto">
          {releases.slice(0, 10).map((r, i) => (
            <div key={i} className="flex items-center justify-between text-sm border-b border-factory-border/50 pb-2">
              <div>
                <span className="text-white font-medium">v{r.version}</span>
                <span className="text-factory-text-secondary ml-2">{r.update_type}</span>
              </div>
              <div className="text-factory-text-secondary text-xs">
                {r.release_date?.split('T')[0] || '–'}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function ActionQueue({ actions }) {
  const pending = actions.filter(a => a.status === 'pending');
  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">
        Action Queue {pending.length > 0 && <span className="text-factory-error text-sm">({pending.length} offen)</span>}
      </h3>
      {actions.length === 0 ? (
        <p className="text-factory-text-secondary text-sm">Keine Actions in der Queue.</p>
      ) : (
        <div className="space-y-2 max-h-48 overflow-y-auto">
          {actions.slice(0, 10).map((a, i) => (
            <div key={i} className="flex items-center justify-between text-sm border-b border-factory-border/50 pb-2">
              <div className="flex items-center gap-2">
                <StatusDot status={a.status} />
                <span className="text-white">{a.action_type}</span>
              </div>
              <span className="text-factory-text-secondary text-xs">
                Severity: {(a.severity_score || 0).toFixed(1)}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function StatusDot({ status }) {
  const colors = {
    pending: 'bg-factory-warning',
    in_progress: 'bg-factory-accent-blue',
    completed: 'bg-factory-success',
    cancelled: 'bg-factory-text-secondary',
  };
  return <span className={`w-2 h-2 rounded-full ${colors[status] || colors.pending}`} />;
}
