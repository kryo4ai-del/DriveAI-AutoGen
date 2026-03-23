import { useState, useEffect } from 'react';
import { Rocket, Sparkles, Wrench, Trash2, Play, FileText, ChevronRight } from 'lucide-react';

const TEMPLATES = [
  {
    name: 'Mobile Game',
    icon: '🎮',
    text: 'Ein Mobile Game Konzept:\n\n- Genre: \n- Kern-Mechanik: \n- Zielgruppe: \n- Besonderheit: \n- Monetarisierung: ',
  },
  {
    name: 'Web App / SaaS',
    icon: '🌐',
    text: 'Eine Web-App / SaaS Idee:\n\n- Problem das geloest wird: \n- Zielgruppe: \n- Kernfunktion: \n- Monetarisierung: \n- Warum jetzt: ',
  },
  {
    name: 'AI Tool',
    icon: '🤖',
    text: 'Ein AI-Tool Konzept:\n\n- Was macht es: \n- Welche AI/Modelle: \n- Zielgruppe: \n- Warum besser als bestehende Loesungen: \n- Datenschutz-Ansatz: ',
  },
];

export default function StartView() {
  const [ambition, setAmbition] = useState('realistic');
  const [title, setTitle] = useState('');
  const [ideaText, setIdeaText] = useState('');
  const [ideas, setIdeas] = useState([]);
  const [launching, setLaunching] = useState(false);
  const [launchResult, setLaunchResult] = useState(null);

  useEffect(() => {
    fetchIdeas();
  }, []);

  async function fetchIdeas() {
    try {
      const res = await fetch('/api/start/ideas');
      const data = await res.json();
      setIdeas(data.ideas || []);
    } catch (err) {
      console.error('Failed to fetch ideas:', err);
    }
  }

  async function handleSubmit() {
    if (!title.trim() || !ideaText.trim()) return;
    setLaunching(true);
    setLaunchResult(null);

    try {
      const res = await fetch('/api/start/launch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: title.trim(),
          ambition,
          idea_source: 'text',
          idea_text: ideaText.trim(),
        }),
      });
      const data = await res.json();
      setLaunchResult(data);
      setTitle('');
      setIdeaText('');
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
    if (!title) setTitle(template.name + ' — Meine Idee');
    setIdeaText(template.text);
  }

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
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Projektname..."
          className="w-full bg-factory-bg border border-factory-border rounded-lg px-4 py-3 text-factory-text placeholder-factory-text-secondary focus:border-factory-accent focus:outline-none mb-4 text-lg font-semibold"
        />

        <div className="relative">
          <textarea
            value={ideaText}
            onChange={(e) => setIdeaText(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey && title.trim() && ideaText.trim()) {
                e.preventDefault();
                handleSubmit();
              }
            }}
            placeholder="Beschreibe deine Idee... (Shift+Enter fuer neue Zeile, Enter zum Starten)"
            className="w-full bg-factory-bg border border-factory-border rounded-lg px-4 py-3 pr-14 text-factory-text placeholder-factory-text-secondary focus:border-factory-accent focus:outline-none resize-none"
            rows={6}
          />
          <button
            onClick={handleSubmit}
            disabled={!title.trim() || !ideaText.trim() || launching}
            className={`absolute bottom-3 right-3 w-10 h-10 rounded-lg flex items-center justify-center transition-all ${
              title.trim() && ideaText.trim() && !launching
                ? 'bg-factory-accent text-factory-bg hover:bg-factory-accent/80'
                : 'bg-factory-border text-factory-text-secondary cursor-not-allowed'
            }`}
          >
            {launching ? (
              <div className="w-5 h-5 border-2 border-factory-bg border-t-transparent rounded-full animate-spin" />
            ) : (
              <ChevronRight size={20} />
            )}
          </button>
        </div>

        {/* Templates */}
        <div className="flex gap-2 mt-3">
          <span className="text-xs text-factory-text-secondary py-1">Templates:</span>
          {TEMPLATES.map(t => (
            <button
              key={t.name}
              onClick={() => applyTemplate(t)}
              className="text-xs px-3 py-1 bg-factory-bg border border-factory-border rounded-lg text-factory-text-secondary hover:text-factory-accent hover:border-factory-accent transition-colors"
            >
              {t.icon} {t.name}
            </button>
          ))}
        </div>
      </div>

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
