/**
 * AnalyticsTab — Analytics-Ansicht fuer eine einzelne App.
 * Zeigt Trends, Funnels, Cohorts, Feature Usage und Empfehlungen.
 *
 * Reine SVG-Charts — keine zusaetzliche Dependency.
 * Liest Daten von /api/liveops/app/:appId/analytics.
 */

import { useState, useEffect, useCallback } from 'react';

const TREND_COLORS = {
  rising: '#22c55e',
  falling: '#ef4444',
  stable: '#eab308',
  unknown: '#6b7280',
};

const SEVERITY_COLORS = {
  critical: 'text-red-400 bg-red-500/10 border-red-500/20',
  high: 'text-orange-400 bg-orange-500/10 border-orange-500/20',
  medium: 'text-yellow-400 bg-yellow-500/10 border-yellow-500/20',
  low: 'text-gray-400 bg-gray-500/10 border-gray-500/20',
};

export default function AnalyticsTab({ appId }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchAnalytics = useCallback(async () => {
    try {
      const res = await fetch(`/api/liveops/app/${appId}/analytics`);
      if (res.ok) {
        const json = await res.json();
        setData(json);
      }
    } catch (err) {
      console.error('Analytics fetch error:', err);
    } finally {
      setLoading(false);
    }
  }, [appId]);

  useEffect(() => {
    fetchAnalytics();
    const interval = setInterval(fetchAnalytics, 30000);
    return () => clearInterval(interval);
  }, [fetchAnalytics]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-factory-text-secondary">Lade Analytics...</div>
      </div>
    );
  }

  if (!data || !data.available) {
    return (
      <div className="bg-factory-surface border border-factory-border rounded-lg p-8 text-center">
        <p className="text-factory-text-secondary text-lg mb-2">Keine Analytics-Daten vorhanden</p>
        <p className="text-factory-text-secondary text-sm">
          Analytics Agent wurde noch nicht ausgefuehrt.
          Starte den Agent mit: <code className="text-factory-accent">python -m factory.live_operations.agents.analytics --simulate</code>
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Recommendations (top, most actionable) */}
      {data.recommendations && data.recommendations.length > 0 && (
        <RecommendationsPanel recommendations={data.recommendations} />
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Trends */}
        {data.trends && data.trends.length > 0 && (
          <TrendsPanel trends={data.trends} />
        )}

        {/* Funnels */}
        {data.funnels && data.funnels.length > 0 && (
          <FunnelsPanel funnels={data.funnels} />
        )}

        {/* Cohorts */}
        {data.cohorts && (
          <CohortsPanel cohorts={data.cohorts} />
        )}

        {/* Feature Usage */}
        {data.feature_usage && (
          <FeatureUsagePanel features={data.feature_usage} />
        )}
      </div>
    </div>
  );
}

// ------------------------------------------------------------------
// Recommendations
// ------------------------------------------------------------------

function RecommendationsPanel({ recommendations }) {
  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">Empfehlungen</h3>
      <div className="space-y-2">
        {recommendations.map((rec, i) => {
          const severity = rec.severity || 'medium';
          const colorClass = SEVERITY_COLORS[severity] || SEVERITY_COLORS.medium;
          return (
            <div key={i} className={`flex items-start gap-3 p-3 rounded border ${colorClass}`}>
              <span className="text-sm font-medium w-16 shrink-0 uppercase">{severity}</span>
              <span className="text-sm text-factory-text">{rec.message || rec}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ------------------------------------------------------------------
// Trends Panel with SVG spark lines
// ------------------------------------------------------------------

function TrendsPanel({ trends }) {
  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">Metriken & Trends</h3>
      <div className="space-y-4">
        {trends.map((trend, i) => (
          <TrendRow key={i} trend={trend} />
        ))}
      </div>
    </div>
  );
}

function TrendRow({ trend }) {
  const direction = trend.direction || trend.trend || 'stable';
  const color = TREND_COLORS[direction] || TREND_COLORS.unknown;
  const arrows = { rising: '\u2191', falling: '\u2193', stable: '\u2192' };
  const arrow = arrows[direction] || '-';

  // Spark line from raw data if available
  const sparkData = trend.data || trend.recent_values || [];

  return (
    <div className="flex items-center gap-4">
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="text-factory-text-secondary text-sm truncate">{trend.metric || trend.name}</span>
          <span className="text-xs font-medium px-1.5 py-0.5 rounded" style={{ color, backgroundColor: `${color}20` }}>
            {arrow} {direction}
          </span>
        </div>
        {trend.strength !== undefined && (
          <div className="text-xs text-factory-text-secondary mt-0.5">
            Staerke: {(trend.strength * 100).toFixed(0)}%
            {trend.anomaly && <span className="text-red-400 ml-2">Anomalie erkannt</span>}
          </div>
        )}
      </div>
      {sparkData.length >= 2 && (
        <SparkLine data={sparkData} color={color} width={80} height={24} />
      )}
    </div>
  );
}

function SparkLine({ data, color, width = 80, height = 24 }) {
  if (!data || data.length < 2) return null;

  const min = Math.min(...data);
  const max = Math.max(...data);
  const range = max - min || 1;
  const pad = 2;

  const points = data.map((val, i) => {
    const x = pad + (i / (data.length - 1)) * (width - 2 * pad);
    const y = pad + (1 - (val - min) / range) * (height - 2 * pad);
    return `${x},${y}`;
  });

  return (
    <svg width={width} height={height} className="shrink-0">
      <polyline
        points={points.join(' ')}
        fill="none"
        stroke={color}
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

// ------------------------------------------------------------------
// Funnels Panel — horizontal bar chart
// ------------------------------------------------------------------

function FunnelsPanel({ funnels }) {
  const [expanded, setExpanded] = useState(null);

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">Funnel-Analyse</h3>
      <div className="space-y-4">
        {funnels.map((funnel, i) => (
          <div key={i}>
            <button
              onClick={() => setExpanded(expanded === i ? null : i)}
              className="w-full text-left flex items-center justify-between mb-2 hover:text-factory-accent transition-colors"
            >
              <span className="text-sm text-white font-medium">{funnel.name || `Funnel ${i + 1}`}</span>
              <span className="text-xs text-factory-text-secondary">
                {funnel.overall_conversion !== undefined
                  ? `${(funnel.overall_conversion * 100).toFixed(1)}% Conversion`
                  : ''}
              </span>
            </button>
            {expanded === i && funnel.steps && (
              <FunnelBars steps={funnel.steps} />
            )}
            {expanded !== i && funnel.steps && (
              <FunnelMiniBar steps={funnel.steps} />
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

function FunnelMiniBar({ steps }) {
  if (!steps || steps.length === 0) return null;
  const maxVal = steps[0]?.count || steps[0]?.users || 1;

  return (
    <div className="flex gap-0.5 h-3">
      {steps.map((step, i) => {
        const val = step.count || step.users || 0;
        const pct = (val / maxVal) * 100;
        const isLast = i === steps.length - 1;
        return (
          <div
            key={i}
            className="h-full rounded-sm"
            style={{
              width: `${pct}%`,
              minWidth: '4px',
              backgroundColor: pct < 30 ? '#ef4444' : pct < 60 ? '#eab308' : '#22c55e',
              opacity: isLast ? 1 : 0.7,
            }}
          />
        );
      })}
    </div>
  );
}

function FunnelBars({ steps }) {
  if (!steps || steps.length === 0) return null;
  const maxVal = steps[0]?.count || steps[0]?.users || 1;

  return (
    <div className="space-y-1.5">
      {steps.map((step, i) => {
        const val = step.count || step.users || 0;
        const pct = (val / maxVal) * 100;
        const dropOff = step.drop_off_rate || step.drop_off || 0;

        return (
          <div key={i}>
            <div className="flex items-center justify-between text-xs mb-0.5">
              <span className="text-factory-text-secondary truncate">{step.name || step.step}</span>
              <div className="flex items-center gap-2">
                <span className="text-white">{val.toLocaleString()}</span>
                {dropOff > 0 && (
                  <span className={`${dropOff > 0.4 ? 'text-red-400' : dropOff > 0.2 ? 'text-yellow-400' : 'text-gray-400'}`}>
                    -{(dropOff * 100).toFixed(0)}%
                  </span>
                )}
              </div>
            </div>
            <div className="w-full bg-white/5 rounded-full h-2">
              <div
                className="h-2 rounded-full transition-all duration-500"
                style={{
                  width: `${pct}%`,
                  backgroundColor: pct < 30 ? '#ef4444' : pct < 60 ? '#eab308' : '#22c55e',
                }}
              />
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ------------------------------------------------------------------
// Cohorts Panel
// ------------------------------------------------------------------

function CohortsPanel({ cohorts }) {
  const cohortList = cohorts.cohorts || cohorts.data || [];
  const updateImpact = cohorts.update_impact || null;

  if (cohortList.length === 0 && !updateImpact) {
    return null;
  }

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">Cohort-Analyse</h3>

      {/* Update Impact */}
      {updateImpact && (
        <div className={`p-3 rounded border mb-4 ${
          updateImpact.impact_percent > 0
            ? 'bg-green-500/10 border-green-500/20'
            : updateImpact.impact_percent < 0
              ? 'bg-red-500/10 border-red-500/20'
              : 'bg-gray-500/10 border-gray-500/20'
        }`}>
          <p className="text-sm text-white font-medium">
            Update-Impact: {updateImpact.version || updateImpact.release}
          </p>
          <p className={`text-xs mt-1 ${
            updateImpact.impact_percent > 0 ? 'text-green-400' : 'text-red-400'
          }`}>
            {updateImpact.impact_percent > 0 ? '+' : ''}{updateImpact.impact_percent?.toFixed(1)}% Retention
          </p>
        </div>
      )}

      {/* Cohort Table */}
      {cohortList.length > 0 && (
        <div className="overflow-x-auto">
          <table className="w-full text-xs">
            <thead>
              <tr className="text-factory-text-secondary">
                <th className="text-left py-1 pr-3">Kohorte</th>
                <th className="text-right py-1 px-2">Nutzer</th>
                <th className="text-right py-1 px-2">D7 Ret.</th>
                <th className="text-right py-1 px-2">D30 Ret.</th>
              </tr>
            </thead>
            <tbody>
              {cohortList.slice(0, 8).map((c, i) => (
                <tr key={i} className="border-t border-factory-border/30">
                  <td className="text-factory-text-secondary py-1.5 pr-3 truncate max-w-[120px]">
                    {c.label || c.week || `W${i + 1}`}
                  </td>
                  <td className="text-white text-right py-1.5 px-2">{c.users?.toLocaleString() || '-'}</td>
                  <td className="text-right py-1.5 px-2">
                    <RetentionCell value={c.retention_day7 || c.d7} />
                  </td>
                  <td className="text-right py-1.5 px-2">
                    <RetentionCell value={c.retention_day30 || c.d30} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function RetentionCell({ value }) {
  if (value === undefined || value === null) return <span className="text-gray-500">-</span>;
  const pct = typeof value === 'number' && value <= 1 ? value * 100 : value;
  const color = pct >= 40 ? 'text-green-400' : pct >= 20 ? 'text-yellow-400' : 'text-red-400';
  return <span className={color}>{pct.toFixed(1)}%</span>;
}

// ------------------------------------------------------------------
// Feature Usage Panel
// ------------------------------------------------------------------

function FeatureUsagePanel({ features }) {
  const featureList = features.features || features.data || [];
  const stars = features.star_features || [];
  const unused = features.unused_features || [];
  const rising = features.rising_features || [];

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <h3 className="text-white font-semibold mb-4">Feature Usage</h3>

      {/* Highlight chips */}
      <div className="flex flex-wrap gap-2 mb-4">
        {stars.map((f, i) => (
          <span key={`s${i}`} className="text-xs px-2 py-1 rounded-full bg-green-500/10 text-green-400 border border-green-500/20">
            {typeof f === 'string' ? f : f.name || f.feature} (Star)
          </span>
        ))}
        {rising.map((f, i) => (
          <span key={`r${i}`} className="text-xs px-2 py-1 rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20">
            {typeof f === 'string' ? f : f.name || f.feature} (Rising)
          </span>
        ))}
        {unused.map((f, i) => (
          <span key={`u${i}`} className="text-xs px-2 py-1 rounded-full bg-red-500/10 text-red-400 border border-red-500/20">
            {typeof f === 'string' ? f : f.name || f.feature} (Unused)
          </span>
        ))}
      </div>

      {/* Feature bars */}
      {featureList.length > 0 && (
        <div className="space-y-2">
          {featureList.slice(0, 10).map((feat, i) => {
            const name = feat.name || feat.feature || `Feature ${i}`;
            const adoption = feat.adoption_rate || feat.usage_rate || 0;
            const pct = typeof adoption === 'number' && adoption <= 1 ? adoption * 100 : adoption;

            return (
              <div key={i}>
                <div className="flex items-center justify-between text-xs mb-0.5">
                  <span className="text-factory-text-secondary truncate">{name}</span>
                  <span className="text-white">{pct.toFixed(1)}%</span>
                </div>
                <div className="w-full bg-white/5 rounded-full h-1.5">
                  <div
                    className="h-1.5 rounded-full"
                    style={{
                      width: `${Math.min(pct, 100)}%`,
                      backgroundColor: pct >= 50 ? '#22c55e' : pct >= 20 ? '#eab308' : '#6b7280',
                    }}
                  />
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
