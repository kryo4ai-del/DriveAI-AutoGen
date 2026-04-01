import { useState } from 'react';
import { DollarSign, Cpu, Zap, ChevronDown, ChevronRight } from 'lucide-react';

export default function CostTracker({ status, estimate, modelCosts, logEntries }) {
  const [showModels, setShowModels] = useState(false);

  const estCost = estimate?.totals?.cost_usd || 0;
  const estCalls = estimate?.totals?.api_calls || 0;

  const actualCost = status?.total_cost || 0;
  const actualCalls = logEntries.filter(e => e.type === 'step_complete' || e.cost).length;
  const actualTokens = logEntries.reduce((sum, e) => sum + (e.tokens || 0), 0);
  const estTokens = estCalls * 1000; // rough estimate: ~1K tokens per call

  const costPct = estCost > 0 ? Math.min(100, (actualCost / estCost) * 100) : 0;
  const callsPct = estCalls > 0 ? Math.min(100, (actualCalls / estCalls) * 100) : 0;
  const tokensPct = estTokens > 0 ? Math.min(100, (actualTokens / estTokens) * 100) : 0;

  function barColor(pct) {
    if (pct >= 100) return 'bg-factory-error';
    if (pct >= 80) return 'bg-factory-warning';
    return 'bg-factory-success';
  }

  return (
    <div className="space-y-3">
      <div className="grid grid-cols-3 gap-3">
        {/* API Calls */}
        <div className="bg-factory-surface rounded-xl border border-factory-border p-4">
          <div className="flex items-center gap-2 mb-2">
            <Zap size={16} className="text-factory-accent" />
            <span className="text-xs text-factory-text-secondary">API Calls</span>
          </div>
          <p className="text-2xl font-bold text-factory-text">{actualCalls}</p>
          <div className="mt-2">
            <div className="h-1.5 bg-factory-bg rounded-full overflow-hidden">
              <div className={`h-full rounded-full transition-all ${barColor(callsPct)}`} style={{ width: `${callsPct}%` }} />
            </div>
            <p className="text-xs text-factory-text-secondary mt-1">von ~{estCalls} geschaetzt</p>
          </div>
        </div>

        {/* Tokens */}
        <div className="bg-factory-surface rounded-xl border border-factory-border p-4">
          <div className="flex items-center gap-2 mb-2">
            <Cpu size={16} className="text-factory-accent-blue" />
            <span className="text-xs text-factory-text-secondary">Tokens</span>
          </div>
          <p className="text-2xl font-bold text-factory-text">
            {actualTokens > 0 ? formatTokens(actualTokens) : '\u2014'}
          </p>
          <div className="mt-2">
            <div className="h-1.5 bg-factory-bg rounded-full overflow-hidden">
              <div className={`h-full rounded-full transition-all ${barColor(tokensPct)}`} style={{ width: `${tokensPct}%` }} />
            </div>
            <p className="text-xs text-factory-text-secondary mt-1">
              {actualTokens > 0 ? `von ~${formatTokens(estTokens)} geschaetzt` : 'Noch keine Token-Daten'}
            </p>
          </div>
        </div>

        {/* Kosten */}
        <div className="bg-factory-surface rounded-xl border border-factory-border p-4">
          <div className="flex items-center gap-2 mb-2">
            <DollarSign size={16} className="text-factory-success" />
            <span className="text-xs text-factory-text-secondary">Kosten</span>
          </div>
          <p className={`text-2xl font-bold ${costPct >= 100 ? 'text-factory-error' : costPct >= 80 ? 'text-factory-warning' : 'text-factory-success'}`}>
            ${actualCost.toFixed(2)}
          </p>
          <div className="mt-2">
            <div className="h-1.5 bg-factory-bg rounded-full overflow-hidden">
              <div className={`h-full rounded-full transition-all ${barColor(costPct)}`} style={{ width: `${costPct}%` }} />
            </div>
            <p className="text-xs text-factory-text-secondary mt-1">von ~${estCost.toFixed(2)} geschaetzt</p>
          </div>
        </div>
      </div>

      {/* Model Cost Table (collapsible) */}
      {Object.keys(modelCosts).length > 0 && (
        <div className="bg-factory-surface rounded-xl border border-factory-border">
          <button
            onClick={() => setShowModels(!showModels)}
            className="w-full flex items-center justify-between p-3 text-sm text-factory-text-secondary hover:text-factory-text transition-colors"
          >
            <span>Kosten nach Modell</span>
            {showModels ? <ChevronDown size={14} /> : <ChevronRight size={14} />}
          </button>
          {showModels && (
            <div className="px-3 pb-3">
              <table className="w-full text-xs">
                <thead>
                  <tr className="text-factory-text-secondary text-left">
                    <th className="pb-1.5 pr-4">Modell</th>
                    <th className="pb-1.5 pr-4 text-right">Calls</th>
                    <th className="pb-1.5 pr-4 text-right">Tokens</th>
                    <th className="pb-1.5 text-right">Kosten</th>
                  </tr>
                </thead>
                <tbody>
                  {Object.entries(modelCosts)
                    .sort((a, b) => b[1].cost - a[1].cost)
                    .map(([model, data]) => (
                      <tr key={model} className="border-t border-factory-border/30">
                        <td className="py-1.5 pr-4 text-factory-text capitalize">{model}</td>
                        <td className="py-1.5 pr-4 text-right text-factory-text-secondary">{data.calls}</td>
                        <td className="py-1.5 pr-4 text-right text-factory-text-secondary">
                          {data.tokens > 0 ? formatTokens(data.tokens) : '\u2014'}
                        </td>
                        <td className="py-1.5 text-right text-factory-text">${data.cost.toFixed(3)}</td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function formatTokens(n) {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${Math.round(n / 1_000)}K`;
  return String(n);
}
