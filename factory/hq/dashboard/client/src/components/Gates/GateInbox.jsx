import { useState, useEffect } from 'react';
import { ShieldCheck } from 'lucide-react';
import ProductionBriefing from '../Production/ProductionBriefing';

export default function GateInbox({ onNavigateToProduction }) {
  const [gates, setGates] = useState([]);
  const [selectedGate, setSelectedGate] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchGates();
    const interval = setInterval(fetchGates, 15000);
    return () => clearInterval(interval);
  }, []);

  async function fetchGates() {
    try {
      const res = await fetch('/api/gates');
      const data = await res.json();
      setGates(data.gates || []);
    } catch (err) {
      console.error('Failed to fetch gates:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <p className="text-factory-text-secondary">Lade Gates...</p>;

  if (gates.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-64">
        <ShieldCheck size={48} className="text-factory-success mb-4" />
        <p className="text-factory-text text-lg">Keine wartenden Gates</p>
        <p className="text-factory-text-secondary">Alle Entscheidungen sind getroffen.</p>
      </div>
    );
  }

  if (selectedGate) {
    // Production Gate → eigener Briefing-Screen
    if (selectedGate.gate_type === 'production_gate') {
      return <ProductionBriefing gate={selectedGate} onBack={() => { setSelectedGate(null); fetchGates(); }} onNavigateToProduction={onNavigateToProduction} />;
    }
    return <GateDecisionView gate={selectedGate} onBack={() => { setSelectedGate(null); fetchGates(); }} />;
  }

  return (
    <div>
      <div className="mb-6">
        <p className="text-factory-text-secondary">{gates.length} Gate{gates.length > 1 ? 's' : ''} warten auf Entscheidung</p>
      </div>
      <div className="space-y-4">
        {gates.map((gate) => (
          <div
            key={`${gate.project_id}-${gate.gate_type}`}
            onClick={() => setSelectedGate(gate)}
            className="bg-factory-surface border-2 border-factory-error rounded-xl p-6 cursor-pointer hover:bg-factory-surface-hover transition-all animate-blink-red"
          >
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-lg font-bold text-factory-text">{gate.project_title}</h3>
                <p className="text-factory-warning font-medium mt-1">{gate.gate_label}</p>
                <p className="text-sm text-factory-text-secondary mt-1">Wartet seit {gate.since}</p>
              </div>
              <span className="px-4 py-2 bg-factory-error/20 text-factory-error font-bold rounded-lg text-sm">
                ENTSCHEIDUNG
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function GateDecisionView({ gate, onBack }) {
  const [decision, setDecision] = useState(null);
  const [reasoning, setReasoning] = useState('');
  const [autoTrigger, setAutoTrigger] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState(null);

  async function submitDecision() {
    if (!decision) return;
    setSubmitting(true);
    try {
      const res = await fetch(`/api/gates/${gate.project_id}/decide`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ gate_type: gate.gate_type, decision, reasoning, auto_trigger: autoTrigger }),
      });
      setResult(await res.json());
    } catch (err) {
      console.error('Gate decision failed:', err);
    } finally {
      setSubmitting(false);
    }
  }

  if (result) {
    const isKill = result.decision === 'KILL' || result.decision === 'kill';
    return (
      <div className="max-w-2xl mx-auto">
        <div className={`p-8 rounded-xl border-2 ${isKill ? 'border-factory-error bg-factory-error/10' : 'border-factory-success bg-factory-success/10'}`}>
          <h2 className="text-2xl font-bold text-factory-text mb-2">
            {isKill ? 'Projekt beendet' : 'Entscheidung gespeichert'}
          </h2>
          <p className="text-factory-text-secondary mb-4">
            {result.gate_type === 'idea_approval' ? 'Idee-Freigabe' : result.gate_type === 'ceo_gate' ? 'CEO-Gate' : result.gate_type === 'feasibility_gate' ? 'Feasibility Gate' : 'Human Review Gate'}: {result.decision}
          </p>
          <p className="text-sm text-factory-text-secondary">Neuer Status: {result.project_status}</p>
          {result.next_pipeline && (
            <p className="text-sm text-factory-accent mt-2">Pipeline gestartet</p>
          )}
          <button onClick={onBack} className="mt-6 px-6 py-2 bg-factory-accent text-factory-bg rounded-lg font-medium hover:bg-factory-accent/80">
            Zurueck
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto">
      <button onClick={onBack} className="text-factory-text-secondary hover:text-factory-text mb-6 flex items-center gap-2 text-sm">
        &#8592; Zurueck zu Gates
      </button>

      <div className="bg-factory-surface rounded-xl border border-factory-border p-6 mb-6">
        <h2 className="text-xl font-bold text-factory-text">{gate.project_title}</h2>
        <p className="text-factory-warning font-medium mt-1">{gate.gate_label}</p>
        {gate.summary?.hint && (
          <p className="text-sm text-factory-text-secondary mt-3">{gate.summary.hint}</p>
        )}
      </div>

      {gate.summary && (
        <div className="grid grid-cols-2 gap-4 mb-6">
          {gate.gate_type === 'idea_approval' && (
            <>
              <MetricCard label="Ambitions-Level" value={gate.summary.ambition || 'realistic'} />
              <MetricCard label="Plattformen" value={(gate.summary.platforms || []).filter(p => p !== 'assembly').length} />
            </>
          )}
          {gate.gate_type === 'ceo_gate' && (
            <>
              <MetricCard label="Kapitel abgeschlossen" value={gate.summary.chapters_complete || 0} />
              <MetricCard label="SerpAPI Credits" value={gate.summary.serpapi_credits || 0} />
            </>
          )}
          {gate.gate_type === 'visual_review' && (
            <>
              <MetricCard label="Assets gesamt" value={gate.summary.assets_total || 0} />
              <MetricCard label="Launch-kritisch" value={gate.summary.assets_critical || 0} />
              <MetricCard label="Blocker" value={gate.summary.blocker_count || 0} color="error" />
              <MetricCard label="KI-Warnungen" value={gate.summary.ki_warnings || 0} color="warning" />
            </>
          )}
          {gate.gate_type === 'feasibility_gate' && (
            <>
              <MetricCard label="Feasibility Score" value={gate.summary.score != null ? `${(gate.summary.score * 100).toFixed(0)}%` : '?'} />
              <MetricCard label="Fehlende Capabilities" value={gate.summary.gaps_count || 0} color="error" />
            </>
          )}
        </div>
      )}

      {gate.gate_type === 'feasibility_gate' && gate.summary?.gaps?.length > 0 && (
        <div className="bg-factory-surface rounded-xl border border-factory-border p-4 mb-6">
          <h4 className="text-sm font-medium text-factory-text-secondary mb-2">Fehlende Capabilities</h4>
          <div className="flex flex-wrap gap-1.5">
            {gate.summary.gaps.map((gap, i) => (
              <span key={i} className="text-xs px-2 py-1 bg-factory-error/10 text-factory-error rounded border border-factory-error/20">
                {gap.capability || gap}
              </span>
            ))}
          </div>
        </div>
      )}

      <div className="bg-factory-surface rounded-xl border border-factory-border p-6">
        <h3 className="text-lg font-semibold text-factory-text mb-4">Entscheidung</h3>

        <div className="flex gap-4 mb-6 flex-wrap">
          {getDecisionOptions(gate).map((d) => (
            <button key={d.id} onClick={() => setDecision(d.id)}
              className={`flex-1 min-w-[120px] py-4 rounded-xl font-bold text-lg transition-all ${
                decision === d.id ? d.activeClass : d.inactiveClass
              }`}>
              {d.label}
            </button>
          ))}
        </div>

        <textarea value={reasoning} onChange={(e) => setReasoning(e.target.value)}
          placeholder="Anmerkungen oder Auflagen (optional)..."
          className="w-full bg-factory-bg border border-factory-border rounded-lg p-4 text-factory-text placeholder-factory-text-secondary resize-none h-24 focus:border-factory-accent focus:outline-none" />

        {decision && decision !== 'KILL' && (
          <label className="flex items-center gap-3 mt-4 cursor-pointer">
            <input type="checkbox" checked={autoTrigger} onChange={(e) => setAutoTrigger(e.target.checked)}
              className="w-4 h-4 accent-factory-accent" />
            <span className="text-sm text-factory-text-secondary">Naechste Pipeline automatisch starten</span>
          </label>
        )}

        <button onClick={submitDecision} disabled={!decision || submitting}
          className={`w-full mt-6 py-3 rounded-xl font-bold text-lg transition-all ${
            !decision || submitting
              ? 'bg-factory-border text-factory-text-secondary cursor-not-allowed'
              : 'bg-factory-accent text-factory-bg hover:bg-factory-accent/80'
          }`}>
          {submitting ? 'Wird gespeichert...' : 'Entscheidung bestaetigen'}
        </button>
      </div>
    </div>
  );
}

const BTN_STYLES = {
  green: {
    active: 'bg-factory-success text-white shadow-lg shadow-factory-success/30',
    inactive: 'bg-factory-success/20 text-factory-success hover:bg-factory-success/30',
  },
  yellow: {
    active: 'bg-factory-warning text-white shadow-lg shadow-factory-warning/30',
    inactive: 'bg-factory-warning/20 text-factory-warning hover:bg-factory-warning/30',
  },
  red: {
    active: 'bg-factory-error text-white shadow-lg shadow-factory-error/30',
    inactive: 'bg-factory-error/20 text-factory-error hover:bg-factory-error/30',
  },
  blue: {
    active: 'bg-factory-accent text-white shadow-lg shadow-factory-accent/30',
    inactive: 'bg-factory-accent/20 text-factory-accent hover:bg-factory-accent/30',
  },
  orange: {
    active: 'bg-orange-500 text-white shadow-lg shadow-orange-500/30',
    inactive: 'bg-orange-500/20 text-orange-400 hover:bg-orange-500/30',
  },
};

function getDecisionOptions(gate) {
  if (gate.gate_type === 'feasibility_gate') {
    const isBlocked = gate.summary?.status === 'parked_blocked';
    if (isBlocked) {
      return [
        { id: 'park', label: 'Parken', activeClass: BTN_STYLES.orange.active, inactiveClass: BTN_STYLES.orange.inactive },
        { id: 'redesign', label: 'Redesign', activeClass: BTN_STYLES.blue.active, inactiveClass: BTN_STYLES.blue.inactive },
        { id: 'kill', label: 'Killen', activeClass: BTN_STYLES.red.active, inactiveClass: BTN_STYLES.red.inactive },
      ];
    }
    return [
      { id: 'proceed_reduced', label: 'Ohne fehlende Features', activeClass: BTN_STYLES.green.active, inactiveClass: BTN_STYLES.green.inactive },
      { id: 'park', label: 'Parken', activeClass: BTN_STYLES.orange.active, inactiveClass: BTN_STYLES.orange.inactive },
      { id: 'adjust_roadbook', label: 'Roadbook anpassen', activeClass: BTN_STYLES.blue.active, inactiveClass: BTN_STYLES.blue.inactive },
      { id: 'kill', label: 'Killen', activeClass: BTN_STYLES.red.active, inactiveClass: BTN_STYLES.red.inactive },
    ];
  }
  // Default: CEO / Visual Review
  return [
    { id: 'GO', label: 'GO', activeClass: BTN_STYLES.green.active, inactiveClass: BTN_STYLES.green.inactive },
    { id: 'GO_MIT_NOTES', label: 'GO mit Auflagen', activeClass: BTN_STYLES.yellow.active, inactiveClass: BTN_STYLES.yellow.inactive },
    { id: 'KILL', label: 'KILL', activeClass: BTN_STYLES.red.active, inactiveClass: BTN_STYLES.red.inactive },
  ];
}

function MetricCard({ label, value, color = 'text' }) {
  const cls = color === 'error' ? 'text-factory-error' : color === 'warning' ? 'text-factory-warning' : 'text-factory-text';
  return (
    <div className="bg-factory-surface rounded-lg border border-factory-border p-4">
      <p className="text-sm text-factory-text-secondary">{label}</p>
      <p className={`text-2xl font-bold ${cls}`}>{value}</p>
    </div>
  );
}
