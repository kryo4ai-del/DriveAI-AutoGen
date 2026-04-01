import { useState, useEffect } from 'react';
import { AlertTriangle, Info, CheckCircle, Cpu, Clock, DollarSign, Layers, Smartphone, ArrowLeft } from 'lucide-react';

export default function ProductionBriefing({ gate, onBack, onDecisionComplete, onNavigateToProduction }) {
  const [estimate, setEstimate] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [decision, setDecision] = useState(null);
  const [reasoning, setReasoning] = useState('');
  const [showConfirm, setShowConfirm] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState(null);

  const slug = gate.project_id;

  useEffect(() => {
    fetchEstimate();
  }, [slug]);

  async function fetchEstimate() {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch('/api/production/estimate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ slug }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.error || `HTTP ${res.status}`);
      }
      setEstimate(await res.json());
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  function handleDecisionClick(d) {
    setDecision(d);
    if (d === 'GO' || d === 'GO_MIT_NOTES') {
      setShowConfirm(true);
    }
  }

  async function submitDecision(finalDecision) {
    setSubmitting(true);
    setShowConfirm(false);
    try {
      const res = await fetch(`/api/gates/${slug}/decide`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          gate_type: 'production_gate',
          decision: finalDecision || decision,
          reasoning,
          auto_trigger: finalDecision === 'GO' || finalDecision === 'GO_MIT_NOTES' || decision === 'GO' || decision === 'GO_MIT_NOTES',
        }),
      });
      const data = await res.json();
      setResult(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  // ── Result View ──────────────────────────────────────────────────────
  if (result) {
    const isKill = result.decision === 'KILL' || result.decision === 'PARK';
    return (
      <div className="max-w-2xl mx-auto">
        <div className={`p-8 rounded-xl border-2 ${isKill ? 'border-factory-error bg-factory-error/10' : 'border-factory-success bg-factory-success/10'}`}>
          <h2 className="text-2xl font-bold text-factory-text mb-2">
            {result.decision === 'KILL' ? 'Projekt beendet' : result.decision === 'PARK' ? 'Projekt geparkt' : 'Production freigegeben'}
          </h2>
          <p className="text-factory-text-secondary mb-2">
            Production Gate: {result.decision}
          </p>
          <p className="text-sm text-factory-text-secondary">Neuer Status: {result.project_status}</p>
          {result.next_pipeline && (
            <p className="text-sm text-factory-accent mt-2">Production Pipeline gestartet</p>
          )}
          <div className="flex gap-3 mt-6">
            <button onClick={onBack} className="px-6 py-2 bg-factory-accent/20 text-factory-accent rounded-lg font-medium hover:bg-factory-accent/30">
              Zurueck
            </button>
            {!isKill && onNavigateToProduction && (
              <button onClick={() => onNavigateToProduction(slug)} className="px-6 py-2 bg-factory-success text-white rounded-lg font-bold hover:bg-green-600">
                Zum Production Dashboard
              </button>
            )}
          </div>
        </div>
      </div>
    );
  }

  // ── Loading State ────────────────────────────────────────────────────
  if (loading) {
    return (
      <div className="max-w-4xl mx-auto">
        <button onClick={onBack} className="text-factory-text-secondary hover:text-factory-text mb-6 flex items-center gap-2 text-sm">
          <ArrowLeft size={16} /> Zurueck zu Gates
        </button>
        <div className="bg-factory-surface rounded-xl border border-factory-border p-8 animate-pulse">
          <div className="h-8 bg-white/5 rounded-lg w-64 mb-4" />
          <div className="h-4 bg-white/5 rounded-lg w-96 mb-8" />
          <div className="grid grid-cols-3 gap-4 mb-6">
            {[1, 2, 3].map(i => <div key={i} className="h-40 bg-white/5 rounded-lg" />)}
          </div>
          <div className="h-32 bg-white/5 rounded-lg" />
        </div>
      </div>
    );
  }

  // ── Error State ──────────────────────────────────────────────────────
  if (error && !estimate) {
    return (
      <div className="max-w-4xl mx-auto">
        <button onClick={onBack} className="text-factory-text-secondary hover:text-factory-text mb-6 flex items-center gap-2 text-sm">
          <ArrowLeft size={16} /> Zurueck zu Gates
        </button>
        <div className="bg-factory-surface rounded-xl border border-factory-error/30 p-6">
          <p className="text-factory-error font-medium">Estimate fehlgeschlagen</p>
          <p className="text-sm text-factory-text-secondary mt-2">{error}</p>
          <button onClick={fetchEstimate} className="mt-4 px-4 py-2 bg-factory-accent/20 text-factory-accent rounded-lg text-sm hover:bg-factory-accent/30">
            Erneut versuchen
          </button>
        </div>
      </div>
    );
  }

  const est = estimate;
  const scope = est.scope || {};
  const totals = est.totals || {};
  const hours = totals.estimated_hours || {};
  const phases = est.phases || {};
  const platforms = est.platforms || {};
  const risks = est.risks || [];
  const models = est.model_usage || {};

  return (
    <div className="max-w-4xl mx-auto">
      <button onClick={onBack} className="text-factory-text-secondary hover:text-factory-text mb-6 flex items-center gap-2 text-sm">
        <ArrowLeft size={16} /> Zurueck zu Gates
      </button>

      {/* ── Header ─────────────────────────────────────────────────── */}
      <div className="bg-factory-surface rounded-xl border border-factory-border p-6 mb-6">
        <div className="flex items-start justify-between">
          <div>
            <h2 className="text-2xl font-bold text-factory-text">{est.project?.name || gate.project_title}</h2>
            <p className="text-factory-accent font-medium mt-1">Production Briefing</p>
          </div>
          <div className="flex items-center gap-3">
            {gate.summary?.feasibility_score != null && (
              <span className={`px-3 py-1.5 rounded-lg text-sm font-bold ${
                gate.summary.feasibility_score >= 0.8 ? 'bg-factory-success/20 text-factory-success' :
                gate.summary.feasibility_score >= 0.5 ? 'bg-factory-warning/20 text-factory-warning' :
                'bg-factory-error/20 text-factory-error'
              }`}>
                Feasibility {(gate.summary.feasibility_score * 100).toFixed(0)}%
              </span>
            )}
          </div>
        </div>

        {/* Platform Badges */}
        <div className="flex gap-2 mt-4">
          {(platforms.target_lines || []).map(line => {
            const info = platforms.lines?.[line] || {};
            return (
              <span key={line} className="flex items-center gap-1.5 px-3 py-1.5 bg-factory-accent/10 text-factory-accent rounded-lg text-sm">
                <Smartphone size={14} />
                {line.toUpperCase()}
                {info.tech_stack && <span className="text-factory-text-secondary ml-1">({info.tech_stack})</span>}
                {info.ready && <CheckCircle size={12} className="text-factory-success ml-1" />}
              </span>
            );
          })}
        </div>
      </div>

      {/* ── Three Cards ────────────────────────────────────────────── */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        {/* Card 1: Scope */}
        <div className="bg-factory-surface rounded-xl border border-factory-border p-5">
          <div className="flex items-center gap-2 mb-4">
            <Layers size={18} className="text-factory-accent" />
            <h3 className="font-semibold text-factory-text">Scope</h3>
          </div>
          <div className="space-y-3">
            <MetricRow label="Features" value={scope.total_features || 0} />
            <MetricRow label="Screens" value={scope.total_screens || 0} />
            <MetricRow label="Assets (Launch)" value={`${scope.launch_critical_assets || 0} / ${scope.total_assets || 0}`} />
            <MetricRow label="API Integrationen" value={scope.apis || 0} />
            {scope.features_by_phase && (
              <div className="pt-2 border-t border-factory-border">
                <p className="text-xs text-factory-text-secondary mb-1.5">Features nach Phase</p>
                <div className="flex gap-2">
                  {Object.entries(scope.features_by_phase).map(([phase, count]) => (
                    <span key={phase} className="text-xs px-2 py-0.5 rounded bg-factory-bg text-factory-text-secondary">
                      {phase}: {count}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Card 2: Dauer */}
        <div className="bg-factory-surface rounded-xl border border-factory-border p-5">
          <div className="flex items-center gap-2 mb-4">
            <Clock size={18} className="text-factory-accent-blue" />
            <h3 className="font-semibold text-factory-text">Dauer</h3>
          </div>
          <div className="space-y-3">
            <div>
              <p className="text-xs text-factory-text-secondary">Factory-Laufzeit</p>
              <p className="text-2xl font-bold text-factory-text">{hours.factory_hours_estimated || '?'}h</p>
              <p className="text-xs text-factory-text-secondary">{hours.factory_runs_estimated || '?'} Runs</p>
            </div>
            <div className="pt-2 border-t border-factory-border">
              <p className="text-xs text-factory-text-secondary mb-1">Manuell geschaetzt</p>
              <p className="text-lg font-bold text-factory-warning">{hours.manual_weeks_estimated || '?'} Wochen</p>
            </div>
            <div className="pt-2 border-t border-factory-border">
              <p className="text-xs text-factory-text-secondary mb-1.5">Phasen</p>
              <div className="space-y-1">
                {Object.entries(phases).map(([name, ph]) => (
                  <div key={name} className="flex justify-between text-xs">
                    <span className="text-factory-text-secondary capitalize">{name}</span>
                    <span className="text-factory-text">{ph.api_calls} Calls</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Card 3: Kosten */}
        <div className="bg-factory-surface rounded-xl border border-factory-border p-5">
          <div className="flex items-center gap-2 mb-4">
            <DollarSign size={18} className="text-factory-success" />
            <h3 className="font-semibold text-factory-text">Kosten</h3>
          </div>
          <div className="space-y-3">
            <div>
              <p className="text-xs text-factory-text-secondary">Gesamtkosten (API)</p>
              <p className="text-3xl font-bold text-factory-success">${(totals.cost_usd || 0).toFixed(2)}</p>
              <p className="text-xs text-factory-text-secondary">{totals.api_calls || 0} API-Calls</p>
            </div>
            <div className="pt-2 border-t border-factory-border">
              <p className="text-xs text-factory-text-secondary mb-1.5">Kosten nach Phase</p>
              <div className="space-y-1">
                {Object.entries(phases).map(([name, ph]) => (
                  <div key={name} className="flex justify-between text-xs">
                    <span className="text-factory-text-secondary capitalize">{name}</span>
                    <span className="text-factory-text">${(ph.cost_usd || 0).toFixed(2)}</span>
                  </div>
                ))}
              </div>
            </div>
            {models.total_active > 0 && (
              <div className="pt-2 border-t border-factory-border">
                <p className="text-xs text-factory-text-secondary mb-1.5">Agents ({models.total_active} aktiv)</p>
                <div className="flex flex-wrap gap-1">
                  {Object.entries(models.active_agents_by_model || {}).map(([model, count]) => (
                    <span key={model} className="text-xs px-1.5 py-0.5 rounded bg-factory-bg text-factory-text-secondary">
                      {model}: {count}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ── Risks ──────────────────────────────────────────────────── */}
      {risks.length > 0 && (
        <div className="bg-factory-surface rounded-xl border border-factory-border p-5 mb-6">
          <h3 className="font-semibold text-factory-text mb-3">Risiken & Hinweise</h3>
          <div className="space-y-2">
            {risks.map((risk, i) => (
              <div key={i} className={`flex items-start gap-3 p-3 rounded-lg ${
                risk.level === 'warning' ? 'bg-factory-warning/10' :
                risk.level === 'error' ? 'bg-factory-error/10' :
                'bg-factory-accent/5'
              }`}>
                {risk.level === 'warning' ? <AlertTriangle size={16} className="text-factory-warning mt-0.5 shrink-0" /> :
                 risk.level === 'error' ? <AlertTriangle size={16} className="text-factory-error mt-0.5 shrink-0" /> :
                 <Info size={16} className="text-factory-accent-blue mt-0.5 shrink-0" />}
                <div>
                  <span className={`text-xs font-medium uppercase ${
                    risk.level === 'warning' ? 'text-factory-warning' :
                    risk.level === 'error' ? 'text-factory-error' :
                    'text-factory-accent-blue'
                  }`}>{risk.area}</span>
                  <p className="text-sm text-factory-text-secondary mt-0.5">{risk.message}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── Decision ───────────────────────────────────────────────── */}
      <div className="bg-factory-surface rounded-xl border border-factory-border p-6">
        <h3 className="text-lg font-semibold text-factory-text mb-4">Entscheidung</h3>

        <div className="flex gap-4 mb-4">
          <button onClick={() => handleDecisionClick('GO')}
            className={`flex-1 py-4 rounded-xl font-bold text-lg transition-all ${
              decision === 'GO' ? 'bg-factory-success text-white shadow-lg shadow-factory-success/30' : 'bg-factory-success/20 text-factory-success hover:bg-factory-success/30'
            }`}>
            GO
          </button>
          <button onClick={() => handleDecisionClick('GO_MIT_NOTES')}
            className={`flex-1 py-4 rounded-xl font-bold text-lg transition-all ${
              decision === 'GO_MIT_NOTES' ? 'bg-factory-warning text-white shadow-lg shadow-factory-warning/30' : 'bg-factory-warning/20 text-factory-warning hover:bg-factory-warning/30'
            }`}>
            GO mit Auflagen
          </button>
          <button onClick={() => { setDecision('PARK'); }}
            className={`flex-1 py-4 rounded-xl font-bold text-lg transition-all ${
              decision === 'PARK' ? 'bg-orange-500 text-white shadow-lg shadow-orange-500/30' : 'bg-orange-500/20 text-orange-400 hover:bg-orange-500/30'
            }`}>
            PARK
          </button>
          <button onClick={() => { setDecision('KILL'); }}
            className={`flex-1 py-4 rounded-xl font-bold text-lg transition-all ${
              decision === 'KILL' ? 'bg-factory-error text-white shadow-lg shadow-factory-error/30' : 'bg-factory-error/20 text-factory-error hover:bg-factory-error/30'
            }`}>
            KILL
          </button>
        </div>

        <textarea value={reasoning} onChange={(e) => setReasoning(e.target.value)}
          placeholder="Anmerkungen oder Auflagen (optional)..."
          className="w-full bg-factory-bg border border-factory-border rounded-lg p-4 text-factory-text placeholder-factory-text-secondary resize-none h-20 focus:border-factory-accent focus:outline-none" />

        {decision && decision !== 'GO' && decision !== 'GO_MIT_NOTES' && (
          <button onClick={() => submitDecision(decision)} disabled={submitting}
            className={`w-full mt-4 py-3 rounded-xl font-bold text-lg transition-all ${
              submitting ? 'bg-factory-border text-factory-text-secondary cursor-not-allowed' : 'bg-factory-accent text-factory-bg hover:bg-factory-accent/80'
            }`}>
            {submitting ? 'Wird gespeichert...' : `${decision} bestaetigen`}
          </button>
        )}
      </div>

      {/* ── Confirm Modal ──────────────────────────────────────────── */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50" onClick={() => setShowConfirm(false)}>
          <div className="bg-factory-surface border border-factory-border rounded-xl p-6 max-w-md w-full mx-4 shadow-2xl" onClick={e => e.stopPropagation()}>
            <h3 className="text-xl font-bold text-factory-text mb-3">Production starten?</h3>
            <div className="space-y-2 mb-4">
              <p className="text-sm text-factory-text-secondary">
                Projekt <span className="text-factory-text font-medium">{est.project?.name || slug}</span> wird in Production uebergeben.
              </p>
              <div className="flex justify-between text-sm p-3 bg-factory-bg rounded-lg">
                <span className="text-factory-text-secondary">Geschaetzte Kosten</span>
                <span className="text-factory-success font-bold">${(totals.cost_usd || 0).toFixed(2)}</span>
              </div>
              <div className="flex justify-between text-sm p-3 bg-factory-bg rounded-lg">
                <span className="text-factory-text-secondary">API-Calls</span>
                <span className="text-factory-text font-bold">{totals.api_calls || 0}</span>
              </div>
              <div className="flex justify-between text-sm p-3 bg-factory-bg rounded-lg">
                <span className="text-factory-text-secondary">Dauer</span>
                <span className="text-factory-text font-bold">~{hours.factory_hours_estimated || '?'}h ({hours.factory_runs_estimated || '?'} Runs)</span>
              </div>
            </div>
            {decision === 'GO_MIT_NOTES' && reasoning && (
              <div className="p-3 bg-factory-warning/10 rounded-lg mb-4">
                <p className="text-xs text-factory-warning font-medium mb-1">Auflagen:</p>
                <p className="text-sm text-factory-text-secondary">{reasoning}</p>
              </div>
            )}
            <div className="flex gap-3">
              <button onClick={() => setShowConfirm(false)}
                className="flex-1 py-3 rounded-lg font-medium text-factory-text-secondary bg-factory-bg hover:bg-factory-border transition-colors">
                Abbrechen
              </button>
              <button onClick={() => submitDecision(decision)} disabled={submitting}
                className={`flex-1 py-3 rounded-lg font-bold transition-all ${
                  submitting ? 'bg-factory-border text-factory-text-secondary cursor-not-allowed' : 'bg-factory-success text-white hover:bg-green-600'
                }`}>
                {submitting ? 'Startet...' : 'Bestaetigen'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function MetricRow({ label, value }) {
  return (
    <div className="flex justify-between items-center">
      <span className="text-sm text-factory-text-secondary">{label}</span>
      <span className="text-sm font-bold text-factory-text">{value}</span>
    </div>
  );
}
