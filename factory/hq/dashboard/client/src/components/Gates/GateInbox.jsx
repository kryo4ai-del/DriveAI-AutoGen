import { useState, useEffect } from 'react';
import { ShieldCheck, ArrowLeft, Star, FileText, Loader2 } from 'lucide-react';

const SEVERITY_STYLES = {
  blocking: { border: 'border-factory-error', bg: 'bg-factory-error/10', badge: 'bg-factory-error text-white', label: 'Blocking' },
  warning:  { border: 'border-factory-warning', bg: 'bg-factory-warning/10', badge: 'bg-factory-warning text-factory-bg', label: 'Warning' },
  info:     { border: 'border-factory-accent-blue', bg: 'bg-factory-accent-blue/10', badge: 'bg-factory-accent-blue text-white', label: 'Info' },
};

const OPTION_COLORS = {
  green:  'bg-factory-success hover:bg-factory-success/80 text-white',
  orange: 'bg-factory-warning hover:bg-factory-warning/80 text-factory-bg',
  yellow: 'bg-yellow-500 hover:bg-yellow-400 text-factory-bg',
  red:    'bg-factory-error hover:bg-factory-error/80 text-white',
  blue:   'bg-factory-accent-blue hover:bg-factory-accent-blue/80 text-white',
};

const OPTION_COLORS_INACTIVE = {
  green:  'border-factory-success/50 text-factory-success hover:bg-factory-success/20',
  orange: 'border-factory-warning/50 text-factory-warning hover:bg-factory-warning/20',
  yellow: 'border-yellow-500/50 text-yellow-500 hover:bg-yellow-500/20',
  red:    'border-factory-error/50 text-factory-error hover:bg-factory-error/20',
  blue:   'border-factory-accent-blue/50 text-factory-accent-blue hover:bg-factory-accent-blue/20',
};

export default function GateInbox() {
  const [gates, setGates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedGate, setSelectedGate] = useState(null);
  const [filterCategory, setFilterCategory] = useState('all');

  useEffect(() => { fetchGates(); }, []);

  async function fetchGates() {
    try {
      const res = await fetch('/api/gates');
      const data = await res.json();
      setGates(data.gates || []);
    } catch (err) { console.error(err); }
    finally { setLoading(false); }
  }

  if (loading) return <p className="text-factory-text-secondary">Lade Gates...</p>;

  if (selectedGate) {
    return <GateDetail gate={selectedGate} onBack={() => { setSelectedGate(null); fetchGates(); }} />;
  }

  const categories = ['all', ...new Set(gates.map(g => g.category).filter(Boolean))];
  const filtered = filterCategory === 'all' ? gates : gates.filter(g => g.category === filterCategory);

  if (gates.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-64">
        <ShieldCheck size={48} className="text-factory-success mb-4" />
        <p className="text-factory-text text-lg">Keine wartenden Gates</p>
        <p className="text-factory-text-secondary">Alle Entscheidungen sind getroffen.</p>
      </div>
    );
  }

  return (
    <div>
      {/* Category filter */}
      <div className="flex items-center gap-2 mb-4">
        {categories.map(c => (
          <button key={c} onClick={() => setFilterCategory(c)}
            className={`px-3 py-1 rounded-lg text-xs transition-colors ${
              filterCategory === c ? 'bg-factory-accent text-factory-bg' : 'bg-factory-surface text-factory-text-secondary hover:text-factory-text'
            }`}>
            {c === 'all' ? `Alle (${gates.length})` : `${c} (${gates.filter(g => g.category === c).length})`}
          </button>
        ))}
      </div>

      {/* Gate cards */}
      <div className="space-y-3">
        {filtered.map(gate => {
          const sev = SEVERITY_STYLES[gate.severity] || SEVERITY_STYLES.info;
          const age = gate.created_at ? timeSince(gate.created_at) : '';

          return (
            <div key={gate.gate_id} onClick={() => setSelectedGate(gate)}
              className={`${sev.bg} border-2 ${sev.border} rounded-xl p-5 cursor-pointer hover:brightness-110 transition-all`}>
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${sev.badge}`}>{sev.label}</span>
                    <span className="text-[10px] text-factory-text-secondary">{gate.category}</span>
                    {gate.platform && <span className="text-[10px] px-1.5 py-0.5 bg-factory-border rounded text-factory-text-secondary">{gate.platform}</span>}
                  </div>
                  <h3 className="text-factory-text font-bold">{gate.title}</h3>
                  <p className="text-sm text-factory-text-secondary mt-1">{gate.project} {age ? `• ${age}` : ''}</p>
                </div>
                {gate.recommendation && (
                  <div className="flex items-center gap-1 text-factory-warning text-xs">
                    <Star size={12} /> Empfehlung
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function GateDetail({ gate, onBack }) {
  const [selectedOption, setSelectedOption] = useState(null);
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState(null);

  const sev = SEVERITY_STYLES[gate.severity] || SEVERITY_STYLES.info;
  const recId = gate.recommendation?.option_id;

  async function submitDecision() {
    if (!selectedOption) return;
    setSubmitting(true);
    try {
      const res = await fetch(`/api/gates/${gate.gate_id}/decide`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ decision: selectedOption, notes }),
      });
      const data = await res.json();
      setResult(data);
    } catch (err) {
      setResult({ error: err.message });
    } finally { setSubmitting(false); }
  }

  if (result && !result.error) {
    const chosenOpt = (gate.options || []).find(o => o.id === result.decision);
    return (
      <div className="max-w-2xl mx-auto">
        <div className="p-8 rounded-xl border-2 border-factory-success bg-factory-success/10">
          <h2 className="text-2xl font-bold text-factory-text mb-2">Entscheidung gespeichert</h2>
          <p className="text-factory-text-secondary">{gate.title}: {chosenOpt?.label || result.decision}</p>
          {result.decision_notes && <p className="text-sm text-factory-text-secondary mt-1">Notiz: {result.decision_notes}</p>}
          <button onClick={onBack} className="mt-6 px-6 py-2 bg-factory-accent text-factory-bg rounded-lg font-medium">Zurueck</button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto">
      <button onClick={onBack} className="text-factory-text-secondary hover:text-factory-text mb-4 text-sm flex items-center gap-1">
        <ArrowLeft size={14} /> Zurueck
      </button>

      {/* Header */}
      <div className={`${sev.bg} border ${sev.border} rounded-xl p-5 mb-4`}>
        <div className="flex items-center gap-2 mb-2">
          <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${sev.badge}`}>{sev.label}</span>
          <span className="text-xs text-factory-text-secondary">{gate.gate_type}</span>
          {gate.platform && <span className="text-xs px-1.5 py-0.5 bg-factory-border rounded text-factory-text-secondary">{gate.platform}</span>}
        </div>
        <h2 className="text-xl font-bold text-factory-text">{gate.title}</h2>
        <p className="text-sm text-factory-text-secondary mt-2">{gate.description}</p>
        <p className="text-xs text-factory-text-secondary mt-2">Projekt: {gate.project} • Von: {gate.source_agent} • {gate.source_department}</p>
      </div>

      {/* Context */}
      {gate.context && Object.keys(gate.context).length > 0 && (
        <div className="bg-factory-surface rounded-xl border border-factory-border p-4 mb-4">
          <p className="text-xs text-factory-text-secondary mb-2 font-medium">Kontext</p>
          {/* Reports as clickable chips */}
          {gate.context.reports && (
            <div className="flex flex-wrap gap-2 mb-3">
              {gate.context.reports.map((r, i) => (
                <button key={i} onClick={() => window.open(`/api/documents/${gate.project}/view/phase1/${r.path?.split('/').pop() || r.label}`, '_blank')}
                  className="flex items-center gap-1 px-2 py-1 bg-factory-bg rounded text-xs text-factory-accent-blue hover:text-factory-accent">
                  <FileText size={10} /> {r.label}
                </button>
              ))}
            </div>
          )}
          {/* Other context as key-value */}
          {Object.entries(gate.context).filter(([k]) => k !== 'reports').map(([k, v]) => (
            <div key={k} className="text-xs mb-1">
              <span className="text-factory-text-secondary">{k}: </span>
              <span className="text-factory-text">{typeof v === 'object' ? JSON.stringify(v) : String(v)}</span>
            </div>
          ))}
        </div>
      )}

      {/* Recommendation */}
      {gate.recommendation && (
        <div className="bg-factory-warning/10 border border-factory-warning/30 rounded-xl p-4 mb-4">
          <div className="flex items-center gap-2 mb-1">
            <Star size={14} className="text-factory-warning" />
            <span className="text-sm font-medium text-factory-warning">Agent empfiehlt: {(gate.options || []).find(o => o.id === recId)?.label || recId}</span>
          </div>
          {gate.recommendation.reasoning && (
            <p className="text-xs text-factory-text-secondary mt-1">{gate.recommendation.reasoning}</p>
          )}
        </div>
      )}

      {/* Options */}
      <div className="bg-factory-surface rounded-xl border border-factory-border p-5 mb-4">
        <p className="text-sm font-medium text-factory-text mb-3">Entscheidung</p>
        <div className="flex flex-wrap gap-3">
          {(gate.options || []).map(opt => {
            const isSelected = selectedOption === opt.id;
            const isRec = opt.id === recId;
            return (
              <button key={opt.id} onClick={() => setSelectedOption(opt.id)}
                className={`flex-1 min-w-[120px] py-3 px-4 rounded-xl font-bold text-sm transition-all border-2 ${
                  isSelected
                    ? OPTION_COLORS[opt.color] || OPTION_COLORS.blue
                    : `bg-transparent ${OPTION_COLORS_INACTIVE[opt.color] || 'border-factory-border text-factory-text-secondary'}`
                } ${isRec && !isSelected ? 'ring-2 ring-factory-warning/30' : ''}`}
                title={opt.description || ''}>
                {opt.label}
                {isRec && <span className="ml-1 text-[10px]">★</span>}
              </button>
            );
          })}
        </div>
        {/* Option descriptions */}
        {selectedOption && (
          <p className="text-xs text-factory-text-secondary mt-2">
            {(gate.options || []).find(o => o.id === selectedOption)?.description || ''}
          </p>
        )}
      </div>

      {/* Notes */}
      {gate.notes_field !== false && (
        <textarea value={notes} onChange={e => setNotes(e.target.value)}
          placeholder={gate.notes_placeholder || 'Anmerkungen...'}
          className="w-full bg-factory-bg border border-factory-border rounded-lg p-3 text-sm text-factory-text placeholder-factory-text-secondary resize-none h-20 focus:border-factory-accent focus:outline-none mb-4" />
      )}

      {/* Submit */}
      <button onClick={submitDecision} disabled={!selectedOption || submitting}
        className={`w-full py-3 rounded-xl font-bold text-sm transition-all ${
          selectedOption && !submitting
            ? 'bg-factory-accent text-factory-bg hover:bg-factory-accent/80'
            : 'bg-factory-border text-factory-text-secondary cursor-not-allowed'
        }`}>
        {submitting ? <span className="flex items-center justify-center gap-2"><Loader2 size={16} className="animate-spin" /> Wird gespeichert...</span> : 'Entscheidung bestaetigen'}
      </button>

      {result?.error && <p className="text-factory-error text-sm mt-2">Fehler: {result.error}</p>}
    </div>
  );
}

function timeSince(dateStr) {
  try {
    const diff = Date.now() - new Date(dateStr).getTime();
    const hours = Math.floor(diff / 3600000);
    if (hours < 1) return 'gerade eben';
    if (hours < 24) return `seit ${hours}h`;
    return `seit ${Math.floor(hours / 24)}d`;
  } catch { return ''; }
}
