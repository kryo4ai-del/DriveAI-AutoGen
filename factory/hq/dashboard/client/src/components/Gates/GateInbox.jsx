import { useState, useEffect } from 'react';
import { ShieldCheck } from 'lucide-react';

export default function GateInbox() {
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
    const isKill = result.decision === 'KILL';
    return (
      <div className="max-w-2xl mx-auto">
        <div className={`p-8 rounded-xl border-2 ${isKill ? 'border-factory-error bg-factory-error/10' : 'border-factory-success bg-factory-success/10'}`}>
          <h2 className="text-2xl font-bold text-factory-text mb-2">
            {isKill ? 'Projekt beendet' : 'Entscheidung gespeichert'}
          </h2>
          <p className="text-factory-text-secondary mb-4">
            {result.gate_type === 'ceo_gate' ? 'CEO-Gate' : 'Human Review Gate'}: {result.decision}
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
        </div>
      )}

      <div className="bg-factory-surface rounded-xl border border-factory-border p-6">
        <h3 className="text-lg font-semibold text-factory-text mb-4">Entscheidung</h3>

        <div className="flex gap-4 mb-6">
          {['GO', 'GO_MIT_NOTES', 'KILL'].map((d) => {
            const colors = {
              GO: { active: 'bg-factory-success text-white shadow-lg shadow-factory-success/30', inactive: 'bg-factory-success/20 text-factory-success hover:bg-factory-success/30' },
              GO_MIT_NOTES: { active: 'bg-factory-warning text-white shadow-lg shadow-factory-warning/30', inactive: 'bg-factory-warning/20 text-factory-warning hover:bg-factory-warning/30' },
              KILL: { active: 'bg-factory-error text-white shadow-lg shadow-factory-error/30', inactive: 'bg-factory-error/20 text-factory-error hover:bg-factory-error/30' },
            };
            const labels = { GO: 'GO', GO_MIT_NOTES: 'GO mit Auflagen', KILL: 'KILL' };
            return (
              <button key={d} onClick={() => setDecision(d)}
                className={`flex-1 py-4 rounded-xl font-bold text-lg transition-all ${decision === d ? colors[d].active : colors[d].inactive}`}>
                {labels[d]}
              </button>
            );
          })}
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

function MetricCard({ label, value, color = 'text' }) {
  const cls = color === 'error' ? 'text-factory-error' : color === 'warning' ? 'text-factory-warning' : 'text-factory-text';
  return (
    <div className="bg-factory-surface rounded-lg border border-factory-border p-4">
      <p className="text-sm text-factory-text-secondary">{label}</p>
      <p className={`text-2xl font-bold ${cls}`}>{value}</p>
    </div>
  );
}
