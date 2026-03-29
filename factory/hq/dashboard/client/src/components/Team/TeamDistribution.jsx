import { TIER_STYLES, QUALITY_STYLES, PROVIDER_STYLES } from './team-utils';

export default function TeamDistribution({ enrichmentStats }) {
  if (!enrichmentStats) return null;

  return (
    <div className="mt-6 grid grid-cols-3 gap-4">
      <DistPanel
        title="Provider-Verteilung"
        data={enrichmentStats.by_provider_match || {}}
        total={enrichmentStats.total}
        styler={key => PROVIDER_STYLES[key] || {}}
        barKey="bar"
        labelFn={(key, s) => s.label || (key === 'none' ? 'Kein LLM' : key)}
      />
      <DistPanel
        title="Tier-Verteilung"
        data={enrichmentStats.by_tier || {}}
        total={enrichmentStats.total}
        styler={key => TIER_STYLES[key] || TIER_STYLES.standard}
        barKey="bg"
        labelFn={(key, s) => s.label || key}
      />
      <DistPanel
        title="Match-Qualität"
        data={enrichmentStats.by_match_quality || {}}
        total={enrichmentStats.total}
        styler={key => QUALITY_STYLES[key] || QUALITY_STYLES.none}
        barKey="bar"
        labelFn={(key, s) => s.label || key}
      />
    </div>
  );
}

function DistPanel({ title, data, total, styler, barKey, labelFn }) {
  const entries = Object.entries(data).sort((a, b) => b[1] - a[1]);
  const maxCount = Math.max(...entries.map(([, c]) => c), 1);

  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-4">
      <h4 className="text-xs font-medium text-factory-text-secondary uppercase tracking-wide mb-3">
        {title}
      </h4>
      <div className="space-y-2">
        {entries.map(([key, count]) => {
          const style = styler(key);
          const pct = total ? Math.round((count / total) * 100) : 0;
          const barWidth = Math.round((count / maxCount) * 100);
          const barColor = style[barKey] || 'bg-factory-accent';
          return (
            <div key={key}>
              <div className="flex items-center justify-between mb-0.5">
                <span className="text-xs text-factory-text">{labelFn(key, style)}</span>
                <span className="text-xs text-factory-text-secondary">{count} ({pct}%)</span>
              </div>
              <div className="h-1.5 bg-factory-bg rounded-full overflow-hidden">
                <div className={`h-full rounded-full ${barColor}`}
                  style={{ width: `${barWidth}%` }} />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
