import { X } from 'lucide-react';
import { STATUS_ICONS, TIER_STYLES, QUALITY_STYLES, CAP_LABELS } from './team-utils';

export default function TeamDetailPanel({ agent, onClose }) {
  const a = agent;
  const tierStyle = TIER_STYLES[a.auto_tier] || TIER_STYLES.standard;
  const qualStyle = QUALITY_STYLES[a.match_quality] || QUALITY_STYLES.none;

  return (
    <div className="w-96 bg-factory-surface rounded-xl border border-factory-border p-5
                    flex-shrink-0 h-fit sticky top-6 max-h-[calc(100vh-6rem)] overflow-y-auto">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="font-bold text-factory-text">{a.name}</h3>
          <p className="text-xs text-factory-text-secondary font-mono">{a.id}</p>
        </div>
        <button onClick={onClose} className="text-factory-text-secondary hover:text-factory-text">
          <X size={16} />
        </button>
      </div>

      {/* Badges */}
      <div className="flex gap-2 mb-4">
        <span className={`${tierStyle.bg} ${tierStyle.text} px-2 py-0.5 rounded text-xs`}>
          {tierStyle.label}
        </span>
        <span className={`${qualStyle.bg} ${qualStyle.text} px-2 py-0.5 rounded text-xs`}>
          {qualStyle.label}
        </span>
        <span className="text-sm">{STATUS_ICONS[a.status]}</span>
      </div>

      {/* Model Match */}
      {a.auto_tier !== 'none' && (
        <Section title="Model-Matching">
          <Row label="Empfohlenes Modell" value={a.matched_model || '\u2014'} mono />
          <Row label="Aktuelles Modell" value={a.default_model || '\u2014'} mono />
          {a.match_score !== null && a.match_score !== undefined && (
            <div>
              <p className="text-xs text-factory-text-secondary">Match Score</p>
              <div className="flex items-center gap-2 mt-1">
                <div className="flex-1 h-2 bg-factory-bg rounded-full overflow-hidden">
                  <div className={`h-full rounded-full ${
                    a.match_score >= 1.0 ? 'bg-factory-success'
                    : a.match_score >= 0.5 ? 'bg-factory-warning'
                    : 'bg-factory-error'
                  }`} style={{ width: `${Math.round(a.match_score * 100)}%` }} />
                </div>
                <span className="text-sm font-mono text-factory-text">
                  {Math.round(a.match_score * 100)}%
                </span>
              </div>
            </div>
          )}
          <Row label="Match-Grund" value={a.match_reason || '\u2014'} />
          {a.matched_caps?.length > 0 && (
            <ChipRow label="Abgedeckt" caps={a.matched_caps} color="text-factory-success" />
          )}
          {a.unmatched_caps?.length > 0 && (
            <ChipRow label="Nicht abgedeckt" caps={a.unmatched_caps} color="text-factory-error" />
          )}
        </Section>
      )}

      {/* Classification */}
      <Section title="Klassifikation">
        <Row label="Capabilities"
          value={(a.capabilities_required || []).map(c => CAP_LABELS[c] || c).join(', ') || '\u2014'} />
        <Row label="Konfidenz" value={a.classification_confidence || '\u2014'} />
        <Row label="Begruendung" value={a.classification_reasoning || '\u2014'} />
      </Section>

      {/* Agent Info */}
      <Section title="Agent-Info">
        <Row label="Rolle" value={a.role} />
        <Row label="Abteilung" value={a.department} />
        <Row label="Task Type" value={a.task_type || '\u2014'} />
        <Row label="Datei" value={a.file || a._source || '\u2014'} mono />
        <Row label="Routing" value={a.routing || '\u2014'} />
        <Row label="Web" value={a.uses_web ? 'Ja (SerpAPI)' : 'Nein'} />
      </Section>

      {/* Description */}
      {a.description && (
        <div className="mt-2 pt-3 border-t border-factory-border">
          <p className="text-xs text-factory-text-secondary">{a.description}</p>
        </div>
      )}
    </div>
  );
}

function Section({ title, children }) {
  return (
    <div className="mb-4 pb-3 border-b border-factory-border">
      <h4 className="text-xs font-medium text-factory-text-secondary uppercase tracking-wide mb-2">{title}</h4>
      <div className="space-y-2">{children}</div>
    </div>
  );
}

function Row({ label, value, mono }) {
  return (
    <div>
      <p className="text-xs text-factory-text-secondary">{label}</p>
      <p className={`text-factory-text ${mono ? 'font-mono text-xs' : 'text-sm'}`}>{value}</p>
    </div>
  );
}

function ChipRow({ label, caps, color }) {
  return (
    <div>
      <p className="text-xs text-factory-text-secondary mb-1">{label}</p>
      <div className="flex gap-1 flex-wrap">
        {caps.map(c => (
          <span key={c} className={`bg-factory-bg ${color} px-1.5 py-0.5 rounded text-[10px] border border-factory-border`}>
            {CAP_LABELS[c] || c}
          </span>
        ))}
      </div>
    </div>
  );
}
