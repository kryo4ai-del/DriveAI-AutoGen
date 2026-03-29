import { useState, useEffect } from 'react';
import { Eye, Zap, Bot } from 'lucide-react';

export default function ShowcaseView() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/showcase')
      .then(r => r.json())
      .then(setData)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p className="text-factory-text-secondary">Lade...</p>;
  if (!data) return null;

  return (
    <div className="max-w-4xl mx-auto">
      {/* Header */}
      <div className="text-center mb-12">
        <div className="flex items-center justify-center gap-3 mb-4">
          <Zap size={32} className="text-factory-accent" />
          <h1 className="text-3xl font-bold text-factory-text">DAI-Core</h1>
        </div>
        <p className="text-lg text-factory-text-secondary">
          Autonome App-Produktion — von der Idee bis zum Store
        </p>
      </div>

      {/* Factory Stats */}
      <div className="grid grid-cols-3 gap-6 mb-12">
        <ShowcaseCard icon={<Eye size={28} />} value={data.factory.total_projects} label="Projekte in der Factory" />
        <ShowcaseCard icon={<Zap size={28} />} value={data.factory.active_projects} label="Aktive Projekte" />
        <ShowcaseCard icon={<Bot size={28} />} value={data.factory.agents_available} label="AI-Agents verfuegbar" />
      </div>

      {/* Project List */}
      {data.projects.length > 0 && (
        <div>
          <h2 className="text-xl font-bold text-factory-text mb-6">Aktuelle Projekte</h2>
          <div className="space-y-4">
            {data.projects.map((project, i) => (
              <div key={i} className="bg-factory-surface rounded-xl border border-factory-border p-6">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h3 className="text-lg font-bold text-factory-text">{project.title}</h3>
                    <p className="text-sm text-factory-text-secondary">{project.phase}</p>
                  </div>
                  {project.active && (
                    <span className="px-3 py-1 bg-factory-warning/20 text-factory-warning text-xs font-bold rounded-full animate-pulse-gold">
                      AKTIV
                    </span>
                  )}
                </div>

                <div className="w-full bg-factory-border rounded-full h-3">
                  <div
                    className="h-3 rounded-full bg-gradient-to-r from-factory-accent to-factory-accent-blue transition-all duration-1000"
                    style={{ width: `${project.progress}%` }}
                  />
                </div>
                <div className="flex justify-between mt-1">
                  <span className="text-xs text-factory-text-secondary">Idee</span>
                  <span className="text-xs text-factory-text-secondary">{project.progress}%</span>
                  <span className="text-xs text-factory-text-secondary">Live</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Footer */}
      <div className="mt-12 text-center">
        <p className="text-sm text-factory-text-secondary">
          DAI-Core — {data.factory.agents_available} AI Specialists &bull; dai-core.ai
        </p>
        <p className="text-xs text-factory-text-secondary mt-1">
          Powered by Anthropic Claude, Google Gemini, OpenAI, Mistral
        </p>
      </div>
    </div>
  );
}

function ShowcaseCard({ icon, value, label }) {
  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-6 text-center">
      <div className="flex justify-center mb-3 text-factory-accent">{icon}</div>
      <p className="text-3xl font-bold text-factory-text">{value}</p>
      <p className="text-sm text-factory-text-secondary mt-1">{label}</p>
    </div>
  );
}
