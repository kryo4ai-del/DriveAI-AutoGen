import { useState, useEffect } from 'react';

export default function AgentMonitor() {
  const [projects, setProjects] = useState([]);
  const [selectedProject, setSelectedProject] = useState(null);
  const [agentData, setAgentData] = useState(null);

  useEffect(() => {
    fetch('/api/projects?type=all&archived=false')
      .then(r => r.json())
      .then(data => {
        const p = data.projects || [];
        setProjects(p);
        if (p.length > 0 && !selectedProject) {
          setSelectedProject(p[0].project_id);
        }
      });
  }, []);

  useEffect(() => {
    if (selectedProject) {
      setAgentData(null);
      fetch(`/api/agents/${selectedProject}`)
        .then(r => r.json())
        .then(setAgentData);
    }
  }, [selectedProject]);

  return (
    <div>
      {/* Project Selector */}
      <div className="flex items-center gap-4 mb-6">
        <span className="text-factory-text-secondary text-sm">Projekt:</span>
        <div className="flex gap-2 flex-wrap">
          {projects.map(p => (
            <button
              key={p.project_id}
              onClick={() => setSelectedProject(p.project_id)}
              className={`px-4 py-2 rounded-lg text-sm transition-colors ${
                selectedProject === p.project_id
                  ? 'bg-factory-accent text-factory-bg font-medium'
                  : 'bg-factory-surface text-factory-text-secondary hover:text-factory-text border border-factory-border'
              }`}
            >
              {p.title}
            </button>
          ))}
        </div>
      </div>

      {!agentData && selectedProject && (
        <p className="text-factory-text-secondary">Lade Agent-Daten...</p>
      )}

      {agentData && (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            <SummaryCard label="Agents aktiv" value={`${agentData.totals.agents_run} / ${agentData.totals.agents_total}`} />
            <SummaryCard label="SerpAPI Credits" value={agentData.totals.serpapi_credits} />
            <SummaryCard label="LLM-Kosten" value={`$${agentData.totals.llm_cost_usd.toFixed(2)}`} />
            <SummaryCard label="PDFs generiert" value={agentData.totals.pdf_count} />
          </div>

          {/* Agent Table */}
          <div className="bg-factory-surface rounded-xl border border-factory-border overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="border-b border-factory-border">
                  <th className="text-left px-4 py-3 text-xs font-medium text-factory-text-secondary uppercase tracking-wider">#</th>
                  <th className="text-left px-4 py-3 text-xs font-medium text-factory-text-secondary uppercase tracking-wider">Agent</th>
                  <th className="text-left px-4 py-3 text-xs font-medium text-factory-text-secondary uppercase tracking-wider">Kapitel</th>
                  <th className="text-left px-4 py-3 text-xs font-medium text-factory-text-secondary uppercase tracking-wider">Status</th>
                  <th className="text-left px-4 py-3 text-xs font-medium text-factory-text-secondary uppercase tracking-wider">Modell</th>
                  <th className="text-left px-4 py-3 text-xs font-medium text-factory-text-secondary uppercase tracking-wider">Report</th>
                  <th className="text-left px-4 py-3 text-xs font-medium text-factory-text-secondary uppercase tracking-wider">Web</th>
                </tr>
              </thead>
              <tbody>
                {agentData.agents.map((agent, i) => (
                  <tr key={agent.num} className={`border-b border-factory-border/30 ${i % 2 === 0 ? '' : 'bg-factory-bg/30'} hover:bg-factory-surface-hover transition-colors`}>
                    <td className="px-4 py-3 text-sm text-factory-text-secondary font-mono">{agent.num}</td>
                    <td className="px-4 py-3 text-sm text-factory-text font-medium">{agent.name}</td>
                    <td className="px-4 py-3 text-sm text-factory-text-secondary">{agent.chapter}</td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`px-2 py-0.5 rounded text-xs font-medium ${
                        agent.status === 'OK' ? 'bg-factory-success/20 text-factory-success' :
                        agent.status === 'Nicht gelaufen' ? 'bg-factory-border/50 text-factory-text-secondary' :
                        'bg-factory-error/20 text-factory-error'
                      }`}>
                        {agent.status}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-factory-text-secondary font-mono text-xs">{agent.model}</td>
                    <td className="px-4 py-3 text-sm text-factory-text-secondary">{agent.report_length}</td>
                    <td className="px-4 py-3 text-sm">
                      {agent.hasWeb ? (
                        <span className="text-factory-accent-blue">{agent.serpapi}</span>
                      ) : (
                        <span className="text-factory-text-secondary/50">—</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Chapter Summary */}
          <div className="mt-6 grid grid-cols-3 md:grid-cols-6 gap-3">
            {['Phase 1', 'Kapitel 3', 'Kapitel 4', 'Kapitel 4.5', 'Kapitel 5', 'Kapitel 6'].map(ch => {
              const chAgents = agentData.agents.filter(a => a.chapter === ch);
              const ran = chAgents.filter(a => a.status === 'OK').length;
              const total = chAgents.length;
              return (
                <div key={ch} className="bg-factory-surface rounded-lg border border-factory-border p-3 text-center">
                  <p className="text-xs text-factory-text-secondary">{ch}</p>
                  <p className={`text-lg font-bold mt-1 ${
                    ran === total && total > 0 ? 'text-factory-success' :
                    ran > 0 ? 'text-factory-warning' :
                    'text-factory-text-secondary'
                  }`}>
                    {ran}/{total}
                  </p>
                </div>
              );
            })}
          </div>
        </>
      )}
    </div>
  );
}

function SummaryCard({ label, value }) {
  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-5">
      <p className="text-sm text-factory-text-secondary">{label}</p>
      <p className="text-2xl font-bold text-factory-text mt-1">{value}</p>
    </div>
  );
}
