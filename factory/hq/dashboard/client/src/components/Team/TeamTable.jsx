import { ChevronRight } from 'lucide-react';
import { STATUS_ICONS, TIER_STYLES, QUALITY_STYLES, CAP_LABELS, PROVIDER_STYLES } from './team-utils';

export default function TeamTable({ agents, selectedAgent, onSelectAgent }) {
  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border overflow-hidden">
      <table className="w-full">
        <thead>
          <tr className="border-b border-factory-border text-left">
            <Th w="w-8" />
            <Th>ID</Th>
            <Th>Name</Th>
            <Th>Tier</Th>
            <Th>Capabilities</Th>
            <Th>Modell</Th>
            <Th>Score</Th>
            <Th>Provider</Th>
            <Th w="w-6" />
          </tr>
        </thead>
        <tbody>
          {agents.map((a, i) => (
            <tr key={a.id}
              onClick={() => onSelectAgent(a)}
              className={`border-b border-factory-border/30 cursor-pointer
                hover:bg-factory-surface-hover transition-colors
                ${i % 2 === 1 ? 'bg-factory-bg/20' : ''}
                ${selectedAgent?.id === a.id ? 'bg-factory-accent/10' : ''}`}>
              <td className="px-3 py-2 text-center text-sm">{STATUS_ICONS[a.status] || '\u26AB'}</td>
              <td className="px-3 py-2 text-xs text-factory-text-secondary font-mono">{a.id}</td>
              <td className="px-3 py-2 text-sm text-factory-text font-medium">{a.name}</td>
              <td className="px-3 py-2"><TierBadge tier={a.auto_tier} /></td>
              <td className="px-3 py-2"><CapChips caps={a.capabilities_required} /></td>
              <td className="px-3 py-2 text-xs text-factory-text-secondary font-mono">
                {a.matched_model || a.default_model || '\u2014'}
              </td>
              <td className="px-3 py-2"><ScoreBadge score={a.match_score} quality={a.match_quality} /></td>
              <td className="px-3 py-2 text-xs"><ProviderLabel provider={a.matched_provider} /></td>
              <td className="px-3 py-2"><ChevronRight size={12} className="text-factory-text-secondary" /></td>
            </tr>
          ))}
        </tbody>
      </table>
      {agents.length === 0 && (
        <p className="text-center text-factory-text-secondary text-sm py-6">Keine Agents mit diesen Filtern.</p>
      )}
    </div>
  );
}

function Th({ children, w }) {
  return <th className={`px-3 py-2 text-xs text-factory-text-secondary ${w || ''}`}>{children}</th>;
}

function TierBadge({ tier }) {
  const s = TIER_STYLES[tier] || TIER_STYLES.standard;
  return (
    <span className={`${s.bg} ${s.text} px-2 py-0.5 rounded text-[10px] font-medium whitespace-nowrap`}>
      {s.label}
    </span>
  );
}

function CapChips({ caps }) {
  if (!caps || !caps.length) return <span className="text-factory-text-secondary text-[10px]">{'\u2014'}</span>;
  return (
    <div className="flex gap-1 flex-wrap">
      {caps.map(c => (
        <span key={c}
          className="bg-factory-bg text-factory-text-secondary px-1.5 py-0.5 rounded text-[10px] border border-factory-border whitespace-nowrap">
          {CAP_LABELS[c] || c}
        </span>
      ))}
    </div>
  );
}

function ScoreBadge({ score, quality }) {
  if (score === null || score === undefined) {
    const s = QUALITY_STYLES[quality] || QUALITY_STYLES.no_llm;
    return <span className={`${s.text} text-[10px]`}>{s.label}</span>;
  }
  const pct = Math.round(score * 100);
  const barColor = score >= 1.0 ? 'bg-factory-success'
                 : score >= 0.5 ? 'bg-factory-warning'
                 : 'bg-factory-error';
  return (
    <div className="flex items-center gap-1">
      <div className="w-8 h-1.5 bg-factory-bg rounded-full overflow-hidden">
        <div className={`h-full rounded-full ${barColor}`} style={{ width: `${pct}%` }} />
      </div>
      <span className="text-[10px] text-factory-text-secondary">{pct}%</span>
    </div>
  );
}

function ProviderLabel({ provider }) {
  if (!provider) return <span className="text-factory-text-secondary">{'\u2014'}</span>;
  const s = PROVIDER_STYLES[provider] || {};
  return <span className={s.color || 'text-factory-text-secondary'}>{s.label || provider}</span>;
}
