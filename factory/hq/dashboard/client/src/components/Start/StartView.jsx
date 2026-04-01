import { useState, useEffect, useRef } from 'react';
import { Rocket, Sparkles, Wrench, Trash2, Play, FileText, Shield, Wand2 } from 'lucide-react';
import NameGateReportCard from './NameGateReportCard';
import NameAlternativesPanel from './NameAlternativesPanel';
import NameSuggestionsPanel from './NameSuggestionsPanel';

const TEMPLATES = [
  {
    name: 'Mobile Game',
    icon: '\uD83C\uDFAE',
    text: 'Ein Mobile Game Konzept:\n\n- Genre: \n- Kern-Mechanik: \n- Zielgruppe: \n- Besonderheit: \n- Monetarisierung: ',
  },
  {
    name: 'Web App / SaaS',
    icon: '\uD83C\uDF10',
    text: 'Eine Web-App / SaaS Idee:\n\n- Problem das geloest wird: \n- Zielgruppe: \n- Kernfunktion: \n- Monetarisierung: \n- Warum jetzt: ',
  },
  {
    name: 'AI Tool',
    icon: '\uD83E\uDD16',
    text: 'Ein AI-Tool Konzept:\n\n- Was macht es: \n- Welche AI/Modelle: \n- Zielgruppe: \n- Warum besser als bestehende Loesungen: \n- Datenschutz-Ansatz: ',
  },
];

const VALIDATION_MESSAGES = [
  'Pruefe Domain-Verfuegbarkeit...',
  'Pruefe App Stores...',
  'Pruefe Social Media Handles...',
  'Pruefe Markenrecht (DPMA/EUIPO)...',
  'Pruefe Brand Fit...',
  'Pruefe ASO-Keyword-Saettigung...',
  'Berechne Gesamtbewertung...',
];

const GENERATION_MESSAGES = [
  'Analysiere deine Idee...',
  'Generiere kreative Namen...',
  'Pruefe Verfuegbarkeit...',
  'Bewerte Markentauglichkeit...',
  'Pruefe Domain-Optionen...',
  'Berechne Gesamtbewertungen...',
  'Sortiere beste Vorschlaege...',
];

export default function StartView() {
  const [ambition, setAmbition] = useState('realistic');
  const [title, setTitle] = useState('');
  const [ideaText, setIdeaText] = useState('');
  const [ideas, setIdeas] = useState([]);
  const [launching, setLaunching] = useState(false);
  const [launchResult, setLaunchResult] = useState(null);

  // Name Gate state
  // Phases: input | validating | result | generating | suggestions | loading_alternatives | alternatives | locking | done
  const [ngPhase, setNgPhase] = useState('input');
  const [ngReport, setNgReport] = useState(null);
  const [ngSuggestions, setNgSuggestions] = useState(null);
  const [ngAlternatives, setNgAlternatives] = useState(null);
  const [ngMessage, setNgMessage] = useState('');
  const [ngError, setNgError] = useState(null);
  const msgInterval = useRef(null);

  useEffect(() => {
    fetchIdeas();
  }, []);

  // Rotating messages for validating + generating phases
  useEffect(() => {
    const messages = ngPhase === 'validating' ? VALIDATION_MESSAGES
      : ngPhase === 'generating' ? GENERATION_MESSAGES
      : null;

    if (messages) {
      let idx = 0;
      setNgMessage(messages[0]);
      msgInterval.current = setInterval(() => {
        idx = (idx + 1) % messages.length;
        setNgMessage(messages[idx]);
      }, 2200);
      return () => clearInterval(msgInterval.current);
    }
    return () => { if (msgInterval.current) clearInterval(msgInterval.current); };
  }, [ngPhase]);

  async function fetchIdeas() {
    try {
      const res = await fetch('/api/start/ideas');
      const data = await res.json();
      setIdeas(data.ideas || []);
    } catch (err) {
      console.error('Failed to fetch ideas:', err);
    }
  }

  // ── Primary action: Validate (with name) or Generate (without) ───

  function handlePrimaryAction() {
    if (!ideaText.trim()) return;
    if (title.trim()) {
      handleNameCheck();
    } else {
      handleGenerate();
    }
  }

  // ── Name Gate: Validate (existing flow, unchanged) ─────────────

  async function handleNameCheck() {
    if (!title.trim() || !ideaText.trim()) return;
    setNgPhase('validating');
    setNgReport(null);
    setNgSuggestions(null);
    setNgAlternatives(null);
    setNgError(null);
    setLaunchResult(null);

    try {
      const res = await fetch('/api/namegate/validate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: title.trim(), idea: ideaText.trim() }),
      });
      const data = await res.json();
      if (data.error && !data.ampel) {
        setNgError(data.error);
        setNgPhase('input');
      } else {
        setNgReport(data);
        setNgPhase('result');
      }
    } catch (err) {
      setNgError(err.message);
      setNgPhase('input');
    }
  }

  // ── Name Gate: Generate names from idea ────────────────────────

  async function handleGenerate() {
    if (!ideaText.trim()) return;
    setNgPhase('generating');
    setNgReport(null);
    setNgSuggestions(null);
    setNgAlternatives(null);
    setNgError(null);
    setLaunchResult(null);

    try {
      const res = await fetch('/api/namegate/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ idea: ideaText.trim(), count: 3 }),
      });
      const data = await res.json();
      if (data.error) {
        setNgError(data.error);
        setNgPhase('input');
      } else {
        setNgSuggestions(data.suggestions || []);
        setNgPhase('suggestions');
      }
    } catch (err) {
      setNgError(err.message);
      setNgPhase('input');
    }
  }

  // ── Name Gate: Select suggestion from panel ────────────────────

  function handleSelectSuggestion(name, report) {
    setTitle(name);
    setNgReport(report);
    setNgSuggestions(null);
    setNgPhase('result');
  }

  // ── Name Gate: Custom name from suggestions panel ──────────────

  async function handleCustomNameFromSuggestions(name) {
    setTitle(name);
    setNgSuggestions(null);
    setNgPhase('validating');
    setNgReport(null);
    setNgError(null);

    try {
      const res = await fetch('/api/namegate/validate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, idea: ideaText.trim() }),
      });
      const data = await res.json();
      if (data.error && !data.ampel) {
        setNgError(data.error);
        setNgPhase('input');
      } else {
        setNgReport(data);
        setNgPhase('result');
      }
    } catch (err) {
      setNgError(err.message);
      setNgPhase('input');
    }
  }

  // ── Name Gate: Alternatives ──────────────────────────────────

  async function handleRequestAlternatives() {
    setNgPhase('loading_alternatives');

    try {
      const rejected = ngReport ? [ngReport.name] : [];
      const res = await fetch('/api/namegate/alternatives', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          idea: ideaText.trim(),
          rejected,
        }),
      });
      const data = await res.json();
      setNgAlternatives(data.alternatives || []);
      setNgPhase('alternatives');
    } catch (err) {
      setNgError(err.message);
      setNgPhase('result');
    }
  }

  // ── Name Gate: Select Alternative → Re-validate ──────────────

  async function handleSelectAlternative(name) {
    setTitle(name);
    setNgPhase('validating');
    setNgReport(null);
    setNgAlternatives(null);
    setNgError(null);

    try {
      const res = await fetch('/api/namegate/validate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, idea: ideaText.trim() }),
      });
      const data = await res.json();
      if (data.error && !data.ampel) {
        setNgError(data.error);
        setNgPhase('input');
      } else {
        setNgReport(data);
        setNgPhase('result');
      }
    } catch (err) {
      setNgError(err.message);
      setNgPhase('input');
    }
  }

  // ── Name Gate: Lock & Launch ─────────────────────────────────

  async function handleApprove(name) {
    setNgPhase('locking');

    try {
      const lockRes = await fetch('/api/namegate/lock', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name }),
      });
      const lockData = await lockRes.json();

      if (lockData.error && !lockData.locked) {
        setNgError(`Lock fehlgeschlagen: ${lockData.error}`);
        setNgPhase('result');
        return;
      }

      // Lock OK → proceed with existing project launch
      setNgPhase('done');
      await launchProject(name);
    } catch (err) {
      setNgError(err.message);
      setNgPhase('result');
    }
  }

  async function handleForce(name) {
    // Force: skip lock, go straight to launch
    setNgPhase('done');
    await launchProject(name);
  }

  // ── Existing launch logic (preserved) ────────────────────────

  async function launchProject(name) {
    setLaunching(true);
    setLaunchResult(null);

    try {
      const res = await fetch('/api/start/launch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: name || title.trim(),
          ambition,
          idea_source: 'text',
          idea_text: ideaText.trim(),
        }),
      });
      const data = await res.json();
      setLaunchResult(data);
      setTitle('');
      setIdeaText('');
      setNgPhase('input');
      setNgReport(null);
      setNgSuggestions(null);
      setNgAlternatives(null);
      fetchIdeas();
    } catch (err) {
      setLaunchResult({ status: 'error', message: err.message });
    } finally {
      setLaunching(false);
    }
  }

  async function handleLaunchFromFile(idea) {
    if (!idea.filename) return;
    setLaunching(true);
    setLaunchResult(null);

    try {
      const res = await fetch('/api/start/launch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: idea.title,
          ambition,
          idea_source: 'file',
          idea_file: idea.filename,
        }),
      });
      const data = await res.json();
      setLaunchResult(data);
      fetchIdeas();
    } catch (err) {
      setLaunchResult({ status: 'error', message: err.message });
    } finally {
      setLaunching(false);
    }
  }

  async function handleDeleteIdea(filename) {
    try {
      await fetch(`/api/start/ideas/${filename}`, { method: 'DELETE' });
      fetchIdeas();
    } catch (err) {
      console.error('Delete failed:', err);
    }
  }

  function applyTemplate(template) {
    if (!title) setTitle(template.name + ' \u2014 Meine Idee');
    setIdeaText(template.text);
  }

  function handleReset() {
    setNgPhase('input');
    setNgReport(null);
    setNgSuggestions(null);
    setNgAlternatives(null);
    setNgError(null);
  }

  const isNameGateActive = ngPhase !== 'input' && ngPhase !== 'done';
  const isBusy = ngPhase === 'validating' || ngPhase === 'generating' || ngPhase === 'loading_alternatives' || ngPhase === 'locking' || launching;
  const hasName = title.trim().length > 0;
  const hasIdea = ideaText.trim().length > 0;
  const canSubmit = hasIdea && !isBusy;

  return (
    <div className="max-w-4xl mx-auto">

      {/* Launch Result Banner */}
      {launchResult && (
        <div className={`mb-6 p-4 rounded-xl border-2 ${
          launchResult.status === 'launched'
            ? 'border-factory-success bg-factory-success/10'
            : 'border-factory-error bg-factory-error/10'
        }`}>
          <div className="flex items-center gap-3">
            {launchResult.status === 'launched' && (
              <Rocket size={24} className="text-factory-success" />
            )}
            <div>
              <p className="font-bold text-factory-text">{launchResult.message}</p>
              {launchResult.command && (
                <p className="text-xs text-factory-text-secondary mt-1 font-mono">{launchResult.command}</p>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Name Gate Error */}
      {ngError && (
        <div className="mb-6 p-4 rounded-xl border-2 border-factory-error bg-factory-error/10">
          <div className="flex items-center gap-3">
            <Shield size={20} className="text-factory-error" />
            <div>
              <p className="font-bold text-factory-text">Name Gate Fehler</p>
              <p className="text-xs text-factory-text-secondary mt-1">{ngError}</p>
            </div>
            <button onClick={() => setNgError(null)} className="ml-auto text-factory-text-secondary hover:text-factory-text text-xs">
              Schliessen
            </button>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="flex items-center gap-3 mb-8">
        <Rocket size={28} className="text-factory-accent" />
        <h1 className="text-2xl font-bold text-factory-text">Neues Projekt starten</h1>
      </div>

      {/* Ambition Toggle */}
      <div className="bg-factory-surface rounded-xl border border-factory-border p-6 mb-6">
        <p className="text-sm text-factory-text-secondary mb-4">Ambitions-Level</p>
        <div className="flex rounded-xl overflow-hidden border border-factory-border">
          <button
            onClick={() => setAmbition('realistic')}
            className={`flex-1 flex items-center justify-center gap-3 py-4 px-6 transition-all ${
              ambition === 'realistic'
                ? 'bg-factory-accent text-factory-bg font-bold'
                : 'bg-factory-surface text-factory-text-secondary hover:bg-factory-surface-hover'
            }`}
          >
            <Wrench size={20} />
            <div className="text-left">
              <p className="font-bold">Factory Mode</p>
              <p className={`text-xs ${ambition === 'realistic' ? 'text-factory-bg/70' : 'text-factory-text-secondary'}`}>
                Max 20 Features, 12 Screens, sofort umsetzbar
              </p>
            </div>
          </button>
          <button
            onClick={() => setAmbition('visionary')}
            className={`flex-1 flex items-center justify-center gap-3 py-4 px-6 transition-all ${
              ambition === 'visionary'
                ? 'bg-factory-warning text-factory-bg font-bold'
                : 'bg-factory-surface text-factory-text-secondary hover:bg-factory-surface-hover'
            }`}
          >
            <Sparkles size={20} />
            <div className="text-left">
              <p className="font-bold">Vision Mode</p>
              <p className={`text-xs ${ambition === 'visionary' ? 'text-factory-bg/70' : 'text-factory-text-secondary'}`}>
                Volles Roadbook, 72+ Features, Investor-Grade
              </p>
            </div>
          </button>
        </div>
      </div>

      {/* Idea Input */}
      <div className="bg-factory-surface rounded-xl border border-factory-border p-6 mb-6">
        <input
          type="text"
          value={title}
          onChange={(e) => { setTitle(e.target.value); if (isNameGateActive) handleReset(); }}
          placeholder="Optional — wird automatisch generiert"
          disabled={isBusy}
          className="w-full bg-factory-bg border border-factory-border rounded-lg px-4 py-3 text-factory-text placeholder-factory-text-secondary focus:border-factory-accent focus:outline-none mb-4 text-lg font-semibold disabled:opacity-50"
        />

        <div className="relative">
          <textarea
            value={ideaText}
            onChange={(e) => { setIdeaText(e.target.value); if (isNameGateActive) handleReset(); }}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey && canSubmit) {
                e.preventDefault();
                handlePrimaryAction();
              }
            }}
            placeholder="Beschreibe deine Idee... (Shift+Enter fuer neue Zeile, Enter zum Starten)"
            disabled={isBusy}
            className="w-full bg-factory-bg border border-factory-border rounded-lg px-4 py-3 pr-14 text-factory-text placeholder-factory-text-secondary focus:border-factory-accent focus:outline-none resize-none disabled:opacity-50"
            rows={6}
          />
          <button
            onClick={handlePrimaryAction}
            disabled={!canSubmit}
            title={hasName ? 'Name pruefen' : 'Namen generieren & pruefen'}
            className={`absolute bottom-3 right-3 w-10 h-10 rounded-lg flex items-center justify-center transition-all ${
              canSubmit
                ? hasName
                  ? 'bg-factory-accent text-factory-bg hover:bg-factory-accent/80'
                  : 'bg-purple-500 text-white hover:bg-purple-400'
                : 'bg-factory-border text-factory-text-secondary cursor-not-allowed'
            }`}
          >
            {isBusy ? (
              <div className="w-5 h-5 border-2 border-factory-bg border-t-transparent rounded-full animate-spin" />
            ) : hasName ? (
              <Shield size={20} />
            ) : (
              <Wand2 size={20} />
            )}
          </button>
        </div>

        {/* Context hint below textarea */}
        {hasIdea && !isBusy && !isNameGateActive && (
          <p className="text-xs text-factory-text-secondary mt-2">
            {hasName
              ? 'Enter: Name pruefen'
              : 'Enter: Namen automatisch generieren & pruefen'
            }
          </p>
        )}

        {/* Templates */}
        <div className="flex gap-2 mt-3">
          <span className="text-xs text-factory-text-secondary py-1">Templates:</span>
          {TEMPLATES.map(t => (
            <button
              key={t.name}
              onClick={() => applyTemplate(t)}
              disabled={isBusy}
              className="text-xs px-3 py-1 bg-factory-bg border border-factory-border rounded-lg text-factory-text-secondary hover:text-factory-accent hover:border-factory-accent transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {t.icon} {t.name}
            </button>
          ))}
        </div>
      </div>

      {/* ── Name Gate: Validation Loading ── */}
      {ngPhase === 'validating' && (
        <div className="bg-factory-surface rounded-xl border border-factory-accent/30 p-6 mb-6">
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-factory-accent/20 flex items-center justify-center flex-shrink-0">
              <div className="w-5 h-5 border-2 border-factory-accent border-t-transparent rounded-full animate-spin" />
            </div>
            <div>
              <p className="text-sm font-bold text-factory-text">Name Gate Validierung</p>
              <p className="text-xs text-factory-accent mt-0.5 transition-all">{ngMessage}</p>
            </div>
          </div>

          {/* Progress dots */}
          <div className="flex gap-1.5 mt-4 ml-14">
            {VALIDATION_MESSAGES.map((_, i) => (
              <div key={i} className={`w-2 h-2 rounded-full transition-all ${
                VALIDATION_MESSAGES.indexOf(ngMessage) >= i
                  ? 'bg-factory-accent'
                  : 'bg-white/10'
              }`} />
            ))}
          </div>
        </div>
      )}

      {/* ── Name Gate: Generating Loading ── */}
      {ngPhase === 'generating' && (
        <div className="bg-factory-surface rounded-xl border border-purple-500/30 p-6 mb-6">
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-purple-500/20 flex items-center justify-center flex-shrink-0">
              <div className="w-5 h-5 border-2 border-purple-400 border-t-transparent rounded-full animate-spin" />
            </div>
            <div>
              <p className="text-sm font-bold text-factory-text">Namen generieren & validieren</p>
              <p className="text-xs text-purple-400 mt-0.5 transition-all">{ngMessage}</p>
            </div>
          </div>

          {/* Progress dots */}
          <div className="flex gap-1.5 mt-4 ml-14">
            {GENERATION_MESSAGES.map((_, i) => (
              <div key={i} className={`w-2 h-2 rounded-full transition-all ${
                GENERATION_MESSAGES.indexOf(ngMessage) >= i
                  ? 'bg-purple-400'
                  : 'bg-white/10'
              }`} />
            ))}
          </div>
        </div>
      )}

      {/* ── Name Gate: Locking ── */}
      {ngPhase === 'locking' && (
        <div className="bg-factory-surface rounded-xl border border-green-500/30 p-6 mb-6">
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-green-500/20 flex items-center justify-center flex-shrink-0">
              <div className="w-5 h-5 border-2 border-green-400 border-t-transparent rounded-full animate-spin" />
            </div>
            <div>
              <p className="text-sm font-bold text-factory-text">Name wird gesperrt...</p>
              <p className="text-xs text-green-400 mt-0.5">Projekt wird erstellt</p>
            </div>
          </div>
        </div>
      )}

      {/* ── Name Gate: Suggestions (from generate flow) ── */}
      {ngPhase === 'suggestions' && ngSuggestions && (
        <div className="mb-6">
          <NameSuggestionsPanel
            suggestions={ngSuggestions}
            idea={ideaText}
            onSelectName={handleSelectSuggestion}
            onCustomName={handleCustomNameFromSuggestions}
            onRegenerate={handleGenerate}
            loading={false}
          />

          {/* Back to edit */}
          <button
            onClick={handleReset}
            className="mt-3 text-xs text-factory-text-secondary hover:text-factory-accent transition-colors"
          >
            Zurueck zur Eingabe
          </button>
        </div>
      )}

      {/* ── Name Gate: Result (single name validation) ── */}
      {(ngPhase === 'result' || ngPhase === 'loading_alternatives' || ngPhase === 'alternatives') && ngReport && (
        <div className="mb-6">
          <NameGateReportCard
            report={ngReport}
            onApprove={handleApprove}
            onRequestAlternatives={handleRequestAlternatives}
            onForce={handleForce}
            loading={false}
          />

          {/* Back to edit */}
          <button
            onClick={handleReset}
            className="mt-3 text-xs text-factory-text-secondary hover:text-factory-accent transition-colors"
          >
            Zurueck zur Eingabe
          </button>
        </div>
      )}

      {/* ── Name Gate: Loading Alternatives ── */}
      {ngPhase === 'loading_alternatives' && (
        <div className="mb-6">
          <NameAlternativesPanel alternatives={null} onSelectAlternative={() => {}} loading={true} />
        </div>
      )}

      {/* ── Name Gate: Alternatives ── */}
      {ngPhase === 'alternatives' && ngAlternatives && (
        <div className="mb-6">
          <NameAlternativesPanel
            alternatives={ngAlternatives}
            onSelectAlternative={handleSelectAlternative}
            loading={false}
          />
        </div>
      )}

      {/* Saved Ideas */}
      <div>
        <h3 className="text-sm font-medium text-factory-text-secondary mb-3 uppercase tracking-wide">
          Gespeicherte Ideen ({ideas.length})
        </h3>

        {ideas.length === 0 ? (
          <p className="text-factory-text-secondary text-sm">Noch keine Ideen gespeichert. Schreibe oben deine erste Idee.</p>
        ) : (
          <div className="space-y-2">
            {ideas.map(idea => (
              <div
                key={idea.filename}
                className={`bg-factory-surface rounded-lg border border-factory-border p-4 flex items-center gap-4 ${
                  idea.is_running ? 'opacity-70' : ''
                }`}
              >
                <FileText size={20} className={idea.is_running ? 'text-factory-warning' : 'text-factory-accent-blue'} />

                <div className="flex-1 min-w-0">
                  <p className="font-medium text-factory-text truncate">{idea.title}</p>
                  <p className="text-xs text-factory-text-secondary truncate">{idea.preview}</p>
                </div>

                <span className="text-xs text-factory-text-secondary flex-shrink-0">{idea.size_kb} KB</span>
                <span className="text-xs text-factory-text-secondary flex-shrink-0">{idea.modified}</span>

                {idea.is_running ? (
                  <span className="px-3 py-1 bg-factory-warning/20 text-factory-warning text-xs font-medium rounded-full flex-shrink-0">
                    {idea.project_status || 'Laeuft'}
                  </span>
                ) : (
                  <div className="flex gap-2 flex-shrink-0">
                    <button
                      onClick={() => handleLaunchFromFile(idea)}
                      disabled={launching}
                      className="px-3 py-1.5 bg-factory-accent/20 text-factory-accent text-xs font-medium rounded-lg hover:bg-factory-accent/30 transition-colors flex items-center gap-1"
                    >
                      <Play size={12} /> Starten
                    </button>
                    <button
                      onClick={() => handleDeleteIdea(idea.filename)}
                      className="px-2 py-1.5 text-factory-text-secondary hover:text-factory-error transition-colors rounded-lg hover:bg-factory-error/10"
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
