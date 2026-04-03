import { useState, useEffect } from 'react';
import { ArrowLeft, ChevronDown, ChevronRight, FileText, ShieldCheck, RefreshCw } from 'lucide-react';

export default function ProjectDetail({ projectId, onBack, onNavigateToProduction }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`/api/projects/${projectId}/timeline`)
      .then(r => r.json())
      .then(d => { setData(d); setLoading(false); })
      .catch(() => setLoading(false));
  }, [projectId]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-factory-text-secondary">Timeline wird geladen...</p>
      </div>
    );
  }

  if (!data) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-factory-text-secondary">Projekt nicht gefunden</p>
      </div>
    );
  }

  const { project, timeline } = data;

  return (
    <div>
      <button
        onClick={onBack}
        className="flex items-center gap-2 text-factory-text-secondary hover:text-factory-text mb-6 transition-colors"
      >
        <ArrowLeft size={18} />
        <span className="text-sm">Zurueck zur Uebersicht</span>
      </button>

      <div className="bg-factory-surface rounded-xl border border-factory-border p-6 mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-factory-text">{project.title}</h2>
            <p className="text-factory-text-secondary mt-1">{project.current_phase}</p>
          </div>
          <div className="flex items-center gap-4">
            {onNavigateToProduction && ['in_production', 'production_started', 'production_complete', 'production_failed'].includes(project.status) && (
              <button
                onClick={() => onNavigateToProduction(projectId)}
                className={`px-4 py-2 text-white rounded-lg font-bold transition-colors ${
                  project.status === 'production_complete'
                    ? 'bg-factory-success hover:bg-green-600'
                    : project.status === 'production_failed'
                    ? 'bg-factory-error hover:bg-red-600'
                    : 'bg-factory-success hover:bg-green-600 animate-pulse'
                }`}
              >
                Production Dashboard
              </button>
            )}
            <div className="text-right text-sm text-factory-text-secondary">
              <p>SerpAPI: {project.costs?.serpapi_credits_total || 0} Credits</p>
              <p>LLM: ${(project.costs?.llm_cost_usd_total || 0).toFixed(2)}</p>
            </div>
          </div>
        </div>
      </div>

      {project.feasibility && project.feasibility.status !== 'not_checked' && (
        <FeasibilitySection project={project} />
      )}

      <div className="relative ml-4">
        <div className="absolute left-2.5 top-0 bottom-0 w-0.5 bg-factory-border" />

        {timeline.map((entry, i) => (
          <TimelineEntry key={i} entry={entry} />
        ))}
      </div>
    </div>
  );
}

function TimelineEntry({ entry }) {
  const [expanded, setExpanded] = useState(false);
  const isGate = entry.type === 'gate';
  const isComplete = entry.status === 'complete';
  const isPending = entry.status === 'pending' || entry.decision === 'pending';
  const isNotStarted = entry.status === 'not_started';

  const dotColor = isGate
    ? entry.decision === 'GO' ? 'border-factory-success bg-factory-success/20'
      : entry.decision === 'KILL' ? 'border-factory-error bg-factory-error/20'
      : 'border-factory-warning bg-factory-warning/20'
    : isComplete ? 'border-factory-success bg-factory-success/20'
    : isNotStarted ? 'border-factory-border bg-factory-bg'
    : 'border-factory-warning bg-factory-warning/20';

  return (
    <div className="relative pl-10 pb-6">
      <div className={`absolute left-0 w-5 h-5 rounded-full border-2 ${dotColor} z-10`} />

      <div className={`bg-factory-surface rounded-lg border border-factory-border ${isNotStarted ? 'opacity-40' : ''}`}>
        <div
          className="flex items-center justify-between p-4 cursor-pointer hover:bg-factory-surface-hover transition-colors rounded-lg"
          onClick={() => !isNotStarted && setExpanded(!expanded)}
        >
          <div className="flex items-center gap-3">
            {isGate ? <ShieldCheck size={18} className="text-factory-warning" /> : <FileText size={18} className="text-factory-text-secondary" />}
            <div>
              <h3 className="font-semibold text-factory-text text-sm">{entry.phase}</h3>
              {entry.date && <p className="text-xs text-factory-text-secondary">{entry.date}</p>}
            </div>
          </div>

          <div className="flex items-center gap-3">
            <StatusBadge status={entry.status} decision={entry.decision} />
            {!isNotStarted && (expanded ? <ChevronDown size={16} className="text-factory-text-secondary" /> : <ChevronRight size={16} className="text-factory-text-secondary" />)}
          </div>
        </div>

        {expanded && !isGate && (
          <div className="px-4 pb-4 border-t border-factory-border/50">
            {entry.agents && entry.agents.length > 0 && (
              <div className="mt-3">
                <h4 className="text-xs font-medium text-factory-text-secondary mb-2 uppercase tracking-wider">Agents</h4>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="text-factory-text-secondary text-left text-xs">
                        <th className="pb-2 pr-4">Agent</th>
                        <th className="pb-2 pr-4">Status</th>
                        <th className="pb-2 pr-4">Modell</th>
                        <th className="pb-2 pr-4">Report</th>
                      </tr>
                    </thead>
                    <tbody>
                      {entry.agents.map((agent, j) => (
                        <tr key={j} className="border-t border-factory-border/30">
                          <td className="py-1.5 pr-4 text-factory-text">{agent.name}</td>
                          <td className="py-1.5 pr-4">
                            <span className={agent.status === 'OK' || agent.status === '✓' ? 'text-factory-success' : 'text-factory-error'}>
                              {agent.status}
                            </span>
                          </td>
                          <td className="py-1.5 pr-4 text-factory-text-secondary text-xs">{agent.model}</td>
                          <td className="py-1.5 pr-4 text-factory-text-secondary text-xs">{agent.report_length}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                {entry.serpapi_total > 0 && (
                  <p className="text-xs text-factory-text-secondary mt-2">SerpAPI: {entry.serpapi_total} Calls</p>
                )}
              </div>
            )}

            {entry.documents && entry.documents.length > 0 && (
              <div className="mt-3">
                <h4 className="text-xs font-medium text-factory-text-secondary mb-2 uppercase tracking-wider">Dokumente</h4>
                <div className="flex flex-wrap gap-1.5">
                  {entry.documents.map((doc, j) => (
                    <span key={j} className="px-2 py-1 bg-factory-bg rounded text-[11px] text-factory-accent-blue border border-factory-border/50">
                      {doc.name} <span className="text-factory-text-secondary">({doc.size})</span>
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {expanded && isGate && (
          <div className="px-4 pb-4 border-t border-factory-border/50">
            <div className="mt-3 text-sm">
              <p className="text-factory-text">
                <span className="font-medium text-factory-text-secondary">Entscheidung: </span>
                <span className={
                  entry.decision === 'GO' ? 'text-factory-success font-bold' :
                  entry.decision === 'KILL' ? 'text-factory-error font-bold' :
                  'text-factory-warning font-bold'
                }>{entry.decision}</span>
              </p>
              {entry.notes && (
                <p className="text-factory-text-secondary mt-1">
                  <span className="font-medium">Anmerkungen: </span>{entry.notes}
                </p>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function FeasibilitySection({ project }) {
  const [report, setReport] = useState(null);
  const [expanded, setExpanded] = useState(false);
  const [rechecking, setRechecking] = useState(false);

  const feas = project.feasibility || {};
  const statusColors = {
    feasible: 'border-factory-success bg-factory-success/10',
    parked_partially: 'border-orange-500 bg-orange-500/10',
    parked_blocked: 'border-factory-error bg-factory-error/10',
  };
  const statusLabels = {
    feasible: 'Produktionsbereit',
    parked_partially: 'Teilweise machbar',
    parked_blocked: 'Blockiert',
    not_checked: 'Nicht geprueft',
  };

  async function loadReport() {
    if (report) { setExpanded(!expanded); return; }
    try {
      const res = await fetch(`/api/feasibility/${project.project_id}`);
      if (res.ok) setReport(await res.json());
    } catch (err) { console.error(err); }
    setExpanded(true);
  }

  async function recheck() {
    setRechecking(true);
    try {
      await fetch(`/api/feasibility/${project.project_id}/recheck`, { method: 'POST' });
      window.location.reload();
    } catch (err) { console.error(err); }
    setRechecking(false);
  }

  return (
    <div className={`rounded-xl border-2 ${statusColors[feas.status] || 'border-factory-border'} p-6 mb-8`}>
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-bold text-factory-text">Feasibility Check</h3>
          <p className="text-sm text-factory-text-secondary mt-1">
            {statusLabels[feas.status] || feas.status}
            {feas.score != null && ` — Score: ${(feas.score * 100).toFixed(0)}%`}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={recheck} disabled={rechecking}
            className="flex items-center gap-1 px-3 py-1.5 text-sm bg-factory-bg border border-factory-border rounded-lg text-factory-text-secondary hover:text-factory-text transition-colors disabled:opacity-50">
            <RefreshCw size={14} className={rechecking ? 'animate-spin' : ''} />
            Re-Check
          </button>
          <button onClick={loadReport}
            className="px-3 py-1.5 text-sm bg-factory-bg border border-factory-border rounded-lg text-factory-text-secondary hover:text-factory-text transition-colors">
            {expanded ? 'Zuklappen' : 'Details'}
          </button>
        </div>
      </div>

      {feas.gaps?.length > 0 && (
        <div className="mt-3 flex flex-wrap gap-1.5">
          {feas.gaps.map((gap, i) => (
            <span key={i} className="text-xs px-2 py-1 bg-factory-error/10 text-factory-error rounded border border-factory-error/20">
              {gap.capability || gap}
            </span>
          ))}
        </div>
      )}

      {expanded && report && (
        <div className="mt-4 border-t border-factory-border/50 pt-4 space-y-4">
          {report.requirements?.length > 0 && (
            <div>
              <h4 className="text-xs font-medium text-factory-text-secondary mb-2 uppercase tracking-wider">Requirements</h4>
              <div className="space-y-1">
                {report.requirements.map((req, i) => (
                  <div key={i} className="flex items-center gap-2 text-sm">
                    <span className={req.status === 'met' ? 'text-factory-success' : req.status === 'warning' ? 'text-factory-warning' : 'text-factory-error'}>
                      {req.status === 'met' ? '\u2713' : req.status === 'warning' ? '!' : '\u2717'}
                    </span>
                    <span className="text-factory-text">{req.name}</span>
                    {req.gap && <span className="text-factory-text-secondary text-xs">— {req.gap}</span>}
                  </div>
                ))}
              </div>
            </div>
          )}

          {report.recommendations?.length > 0 && (
            <div>
              <h4 className="text-xs font-medium text-factory-text-secondary mb-2 uppercase tracking-wider">Empfehlungen</h4>
              <ul className="space-y-1">
                {report.recommendations.map((rec, i) => (
                  <li key={i} className="text-sm text-factory-text-secondary">{rec}</li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function StatusBadge({ status, decision }) {
  if (decision === 'GO') return <span className="px-2 py-0.5 bg-factory-success/20 text-factory-success text-xs rounded-full font-bold">GO</span>;
  if (decision === 'KILL') return <span className="px-2 py-0.5 bg-factory-error/20 text-factory-error text-xs rounded-full font-bold">KILL</span>;
  if (decision === 'GO_MIT_NOTES') return <span className="px-2 py-0.5 bg-factory-warning/20 text-factory-warning text-xs rounded-full font-bold">GO*</span>;
  if (decision === 'pending') return <span className="px-2 py-0.5 bg-factory-warning/20 text-factory-warning text-xs rounded-full">Wartet</span>;
  if (status === 'complete') return <span className="px-2 py-0.5 bg-factory-success/20 text-factory-success text-xs rounded-full">Fertig</span>;
  if (status === 'error') return <span className="px-2 py-0.5 bg-factory-error/20 text-factory-error text-xs rounded-full">Fehler</span>;
  if (status === 'not_started') return <span className="px-2 py-0.5 bg-factory-border/50 text-factory-text-secondary text-xs rounded-full">Offen</span>;
  return <span className="px-2 py-0.5 bg-factory-warning/20 text-factory-warning text-xs rounded-full">Laeuft</span>;
}
