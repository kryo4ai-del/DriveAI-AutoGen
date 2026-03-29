import { useState, useEffect } from 'react';

const STATUS_COLORS = {
  idea: 'border-factory-text-secondary',
  phase1_running: 'border-factory-warning animate-pulse-gold',
  ceo_gate_pending: 'border-factory-error animate-blink-red',
  ceo_gate_go: 'border-factory-success',
  killed: 'border-factory-text-secondary opacity-50',
  strategy_complete: 'border-factory-success',
  features_complete: 'border-factory-success',
  design_complete: 'border-factory-success',
  review_pending: 'border-factory-error animate-blink-red',
  review_go: 'border-factory-success',
  preproduction_done: 'border-factory-accent',
  in_production: 'border-factory-warning animate-pulse-gold',
  feasibility_checking: 'border-factory-accent animate-pulse-gold',
  feasible: 'border-factory-success',
  parked_partially: 'border-orange-500',
  parked_blocked: 'border-factory-error',
};

const STATUS_LABELS = {
  idea: 'Idee',
  phase1_running: 'Phase 1 laeuft',
  ceo_gate_pending: 'CEO-Gate wartet',
  ceo_gate_go: 'CEO: GO',
  killed: 'KILLED',
  strategy_complete: 'Strategie fertig',
  features_complete: 'Features fertig',
  design_complete: 'Design fertig',
  review_pending: 'Review wartet',
  review_go: 'Review: GO',
  preproduction_done: 'Pre-Prod fertig',
  in_production: 'In Produktion',
  feasibility_checking: 'Feasibility-Check',
  feasible: 'Produktionsbereit',
  parked_partially: 'Geparkt (teilweise)',
  parked_blocked: 'Geparkt (blockiert)',
};

export default function ProjectGrid({ onSelectProject }) {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAll, setShowAll] = useState(false);

  useEffect(() => {
    fetchProjects();
    const interval = setInterval(fetchProjects, 15000);
    return () => clearInterval(interval);
  }, [showAll]);

  async function fetchProjects() {
    try {
      const url = showAll ? '/api/projects?type=all&archived=true' : '/api/projects?type=production';
      const res = await fetch(url);
      const data = await res.json();
      setProjects(data.projects || []);
    } catch (err) {
      console.error('Failed to fetch projects:', err);
    } finally {
      setLoading(false);
    }
  }

  async function handleArchive(projectId, archived) {
    await fetch(`/api/projects/${projectId}/archive`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ archived }),
    });
    fetchProjects();
  }

  async function handleSetType(projectId, type) {
    await fetch(`/api/projects/${projectId}/type`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type }),
    });
    fetchProjects();
  }

  async function handleDelete(projectId) {
    if (!window.confirm(`Projekt "${projectId}" endgültig löschen?\n\nAlle Dateien, Reports, Outputs und Code werden unwiderruflich gelöscht.`)) return;
    try {
      const res = await fetch(`/api/projects/${projectId}`, { method: 'DELETE' });
      const data = await res.json();
      if (data.success) {
        fetchProjects();
      } else {
        alert('Fehler: ' + (data.error || 'Unbekannt'));
      }
    } catch (err) {
      alert('Fehler beim Löschen: ' + err.message);
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-factory-text-secondary">Factory wird gescannt...</p>
      </div>
    );
  }

  if (projects.length === 0) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-factory-text-secondary">Keine Projekte gefunden</p>
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <p className="text-factory-text-secondary">{projects.length} Projekte</p>
        <button
          onClick={() => setShowAll(!showAll)}
          className="text-sm text-factory-text-secondary hover:text-factory-text px-3 py-1 border border-factory-border rounded-lg transition-colors"
        >
          {showAll ? 'Nur Produktionsprojekte' : 'Alle anzeigen (inkl. Tests)'}
        </button>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {projects.map((project) => (
          <ProjectCard
            key={project.project_id}
            project={project}
            onArchive={handleArchive}
            onSetType={handleSetType}
            onDelete={handleDelete}
            onSelect={() => onSelectProject && onSelectProject(project.project_id)}
          />
        ))}
      </div>
    </div>
  );
}

function ProjectCard({ project, onArchive, onSetType, onDelete, onSelect }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const statusColor = STATUS_COLORS[project.status] || 'border-factory-border';
  const statusLabel = STATUS_LABELS[project.status] || project.status;
  const isGateWaiting = project.status?.includes('pending');
  const isParked = project.status === 'parked_partially' || project.status === 'parked_blocked';
  const isIteration = project.project_type === 'iteration';
  const isTest = project.project_type === 'test';

  return (
    <div onClick={onSelect} className={`bg-factory-surface rounded-xl border-2 ${statusColor} p-6 cursor-pointer hover:bg-factory-surface-hover transition-all relative ${project.archived ? 'opacity-40' : ''}`}>
      <div className="flex items-start justify-between mb-4">
        <div>
          <div className="flex items-center gap-2">
            <h3 className="text-lg font-bold text-factory-text">{project.title}</h3>
            {isIteration && <span className="text-[10px] px-1.5 py-0.5 bg-factory-border rounded text-factory-text-secondary">Iteration</span>}
            {isTest && <span className="text-[10px] px-1.5 py-0.5 bg-factory-warning/20 rounded text-factory-warning">Test</span>}
            {project.archived && <span className="text-[10px] px-1.5 py-0.5 bg-factory-border rounded text-factory-text-secondary">Archiv</span>}
          </div>
          <p className="text-sm text-factory-text-secondary mt-1">{project.current_phase}</p>
        </div>
        <div className="flex items-center gap-2">
          {isGateWaiting && (
            <span className="px-3 py-1 bg-factory-error/20 text-factory-error text-xs font-bold rounded-full">
              AKTION
            </span>
          )}
          <button
            onClick={(e) => { e.stopPropagation(); setMenuOpen(!menuOpen); }}
            className="text-factory-text-secondary hover:text-factory-text p-1"
          >
            &#8942;
          </button>
        </div>
      </div>

      {menuOpen && (
        <div className="absolute right-4 top-14 bg-factory-bg border border-factory-border rounded-lg shadow-xl z-10 py-1 min-w-[180px]">
          <button onClick={() => { onArchive(project.project_id, !project.archived); setMenuOpen(false); }}
            className="w-full text-left px-4 py-2 text-sm text-factory-text-secondary hover:text-factory-text hover:bg-factory-surface-hover">
            {project.archived ? 'Wiederherstellen' : 'Archivieren'}
          </button>
          <button onClick={() => { onSetType(project.project_id, 'production'); setMenuOpen(false); }}
            className="w-full text-left px-4 py-2 text-sm text-factory-text-secondary hover:text-factory-text hover:bg-factory-surface-hover">
            Als Hauptprojekt
          </button>
          <button onClick={() => { onSetType(project.project_id, 'test'); setMenuOpen(false); }}
            className="w-full text-left px-4 py-2 text-sm text-factory-text-secondary hover:text-factory-text hover:bg-factory-surface-hover">
            Als Test markieren
          </button>
          <div className="border-t border-factory-border my-1" />
          <button onClick={(e) => { e.stopPropagation(); onDelete(project.project_id); setMenuOpen(false); }}
            className="w-full text-left px-4 py-2 text-sm text-factory-error hover:bg-factory-error/10">
            Projekt löschen
          </button>
        </div>
      )}

      <ProgressBar status={project.status} />

      {isParked && project.feasibility?.gaps?.length > 0 && (
        <div className="mt-3 flex flex-wrap gap-1">
          {project.feasibility.gaps.slice(0, 3).map((gap, i) => (
            <span key={i} className="text-[10px] px-1.5 py-0.5 bg-factory-error/10 text-factory-error rounded border border-factory-error/20">
              {gap.capability || gap}
            </span>
          ))}
          {project.feasibility.gaps.length > 3 && (
            <span className="text-[10px] px-1.5 py-0.5 text-factory-text-secondary">
              +{project.feasibility.gaps.length - 3} mehr
            </span>
          )}
          {project.feasibility?.score != null && (
            <span className="text-[10px] px-1.5 py-0.5 bg-factory-warning/10 text-factory-warning rounded border border-factory-warning/20 ml-auto">
              Score: {(project.feasibility.score * 100).toFixed(0)}%
            </span>
          )}
        </div>
      )}

      <div className="mt-4 flex items-center justify-between text-sm">
        <span className={`px-2 py-1 rounded text-xs font-medium ${
          project.status === 'killed' ? 'bg-factory-error/20 text-factory-error' :
          project.status === 'parked_blocked' ? 'bg-factory-error/20 text-factory-error' :
          project.status === 'parked_partially' ? 'bg-orange-500/20 text-orange-400' :
          project.status === 'preproduction_done' ? 'bg-factory-accent/20 text-factory-accent' :
          project.status === 'feasible' ? 'bg-factory-success/20 text-factory-success' :
          project.status?.includes('pending') ? 'bg-factory-warning/20 text-factory-warning' :
          'bg-factory-success/20 text-factory-success'
        }`}>
          {statusLabel}
        </span>
        <div className="flex gap-4 text-factory-text-secondary">
          <span>{project.costs?.serpapi_credits_total || 0} API</span>
          <span>${(project.costs?.llm_cost_usd_total || 0).toFixed(2)}</span>
        </div>
      </div>
    </div>
  );
}

const PHASE_LABELS = ['Idee', 'Pre-Prod', 'Production', 'QA', 'Release', 'Live'];

function getPhaseIndex(status) {
  if (!status) return 0;
  if (status === 'idea') return 0;
  if (status === 'killed') return -1;
  if (['phase1_running', 'ceo_gate_pending', 'ceo_gate_go', 'strategy_complete',
       'features_complete', 'design_complete', 'review_pending', 'review_go',
       'preproduction_done', 'feasibility_checking', 'feasible',
       'parked_partially', 'parked_blocked'].includes(status)) return 1;
  if (status.includes('production')) return 2;
  return 0;
}

function ProgressBar({ status }) {
  const currentIndex = getPhaseIndex(status);
  const isKilled = status === 'killed';

  return (
    <div className="flex items-center gap-1">
      {PHASE_LABELS.map((label, i) => (
        <div key={label} className="flex-1 flex flex-col items-center">
          <div className={`w-full h-2 rounded-full ${
            isKilled ? 'bg-factory-error/30' :
            i < currentIndex ? 'bg-factory-success' :
            i === currentIndex ? 'bg-factory-warning' :
            'bg-factory-border'
          }`} />
          <span className="text-[10px] text-factory-text-secondary mt-1">{label}</span>
        </div>
      ))}
    </div>
  );
}
