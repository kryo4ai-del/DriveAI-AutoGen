import { useState, useEffect } from 'react';
import { Clock, CheckCircle, XCircle, ArrowRight } from 'lucide-react';

const STATUS_DISPLAY = {
  preproduction_done: { label: 'Pre-Prod fertig', color: 'text-factory-accent', icon: CheckCircle },
  in_production: { label: 'In Produktion', color: 'text-factory-warning', icon: ArrowRight },
  production_done: { label: 'Produktion fertig', color: 'text-factory-success', icon: CheckCircle },
  killed: { label: 'KILLED', color: 'text-factory-error', icon: XCircle },
  live: { label: 'LIVE', color: 'text-factory-success', icon: CheckCircle },
  sunset: { label: 'Eingestellt', color: 'text-factory-text-secondary', icon: Clock },
};

export default function ProjectHistory() {
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/history')
      .then(r => r.json())
      .then(data => setHistory(data.projects || []))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p className="text-factory-text-secondary">Lade Historie...</p>;

  if (history.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-64">
        <Clock size={48} className="text-factory-text-secondary mb-4" />
        <p className="text-factory-text text-lg">Noch keine abgeschlossenen Projekte</p>
        <p className="text-factory-text-secondary">Projekte erscheinen hier sobald die Pre-Production abgeschlossen ist.</p>
      </div>
    );
  }

  const totalProjects = history.length;
  const completedProjects = history.filter(p => p.status !== 'killed').length;
  const killedProjects = history.filter(p => p.status === 'killed').length;
  const totalCost = history.reduce((sum, p) => sum + (p.costs?.llm_cost_usd_total || 0), 0);
  const totalSerpApi = history.reduce((sum, p) => sum + (p.costs?.serpapi_credits_total || 0), 0);

  return (
    <div>
      {/* Aggregate Stats */}
      <div className="grid grid-cols-5 gap-4 mb-8">
        <StatCard label="Projekte gesamt" value={totalProjects} />
        <StatCard label="Abgeschlossen" value={completedProjects} color="success" />
        <StatCard label="Beendet (Kill)" value={killedProjects} color="error" />
        <StatCard label="LLM-Kosten gesamt" value={`$${totalCost.toFixed(2)}`} />
        <StatCard label="SerpAPI gesamt" value={`${totalSerpApi} Credits`} />
      </div>

      {/* Project List */}
      <div className="space-y-4">
        {history.map(project => {
          const display = STATUS_DISPLAY[project.status] || STATUS_DISPLAY.preproduction_done;
          const StatusIcon = display.icon;

          return (
            <div key={project.project_id} className={`bg-factory-surface rounded-xl border border-factory-border p-6 ${
              project.status === 'killed' ? 'opacity-60' : ''
            }`}>
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-4">
                  <StatusIcon size={24} className={display.color} />
                  <div>
                    <h3 className="text-lg font-bold text-factory-text">{project.title}</h3>
                    <span className={`text-sm font-medium ${display.color}`}>{display.label}</span>
                  </div>
                </div>
                <div className="text-right text-sm text-factory-text-secondary">
                  <p>{project.created} &rarr; {project.updated}</p>
                  {project.duration_days && <p>{project.duration_days} Tage</p>}
                </div>
              </div>

              <div className="grid grid-cols-6 gap-4 mt-4 pt-4 border-t border-factory-border/50">
                <MiniStat label="Kapitel" value={`${project.chapters_complete}/${project.chapters_total}`} />
                <MiniStat label="Dokumente" value={project.documents} />
                <MiniStat label="PDFs" value={project.pdfs} />
                <MiniStat label="SerpAPI" value={`${project.costs?.serpapi_credits_total || 0}`} />
                <MiniStat label="LLM-Kosten" value={`$${(project.costs?.llm_cost_usd_total || 0).toFixed(2)}`} />
                <MiniStat label="Ergebnis" value={
                  project.status === 'killed' ? 'KILL' :
                  project.status === 'preproduction_done' ? 'Ready' :
                  project.status
                } color={project.status === 'killed' ? 'error' : 'success'} />
              </div>

              {project.status === 'killed' && project.result && (
                <p className="mt-3 text-sm text-factory-error/70 italic">{project.result}</p>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

function StatCard({ label, value, color }) {
  const colorClass = color === 'success' ? 'text-factory-success' : color === 'error' ? 'text-factory-error' : 'text-factory-text';
  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-4">
      <p className="text-sm text-factory-text-secondary">{label}</p>
      <p className={`text-xl font-bold ${colorClass} mt-1`}>{value}</p>
    </div>
  );
}

function MiniStat({ label, value, color }) {
  const colorClass = color === 'error' ? 'text-factory-error' : color === 'success' ? 'text-factory-success' : 'text-factory-text';
  return (
    <div>
      <p className="text-xs text-factory-text-secondary">{label}</p>
      <p className={`text-sm font-medium ${colorClass}`}>{value}</p>
    </div>
  );
}
