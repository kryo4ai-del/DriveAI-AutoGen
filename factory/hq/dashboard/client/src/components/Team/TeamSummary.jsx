import { QUALITY_STYLES } from './team-utils';

export default function TeamSummary({ summary, enrichmentStats }) {
  return (
    <div className="space-y-4 mb-6">
      {/* Row 1: Agent Status */}
      <div className="grid grid-cols-4 gap-4">
        <StatCard label="Gesamt" value={summary?.total || 0} />
        <StatCard label="Aktiv" value={summary?.active || 0} color="success" />
        <StatCard label="Disabled" value={summary?.disabled || 0} color="error" />
        <StatCard label="Geplant" value={summary?.planned || 0} color="warning" />
      </div>

      {/* Row 2: Match Quality */}
      {enrichmentStats && (
        <div className="grid grid-cols-5 gap-3">
          {Object.entries(enrichmentStats.by_match_quality || {}).map(([quality, count]) => {
            const style = QUALITY_STYLES[quality] || QUALITY_STYLES.none;
            return (
              <div key={quality}
                className={`${style.bg} border border-factory-border rounded-lg p-3 text-center`}>
                <p className={`text-lg font-bold ${style.text}`}>{count}</p>
                <p className="text-xs text-factory-text-secondary">{style.label}</p>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function StatCard({ label, value, color }) {
  const c = color === 'success' ? 'text-factory-success'
          : color === 'error' ? 'text-factory-error'
          : color === 'warning' ? 'text-factory-warning'
          : 'text-factory-text';
  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-4">
      <p className="text-sm text-factory-text-secondary">{label}</p>
      <p className={`text-2xl font-bold ${c} mt-1`}>{value}</p>
    </div>
  );
}
