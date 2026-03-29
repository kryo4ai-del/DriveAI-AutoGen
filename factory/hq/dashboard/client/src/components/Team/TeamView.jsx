import { useState, useEffect, useMemo } from 'react';
import { RefreshCw } from 'lucide-react';
import TeamSummary from './TeamSummary';
import TeamFilters from './TeamFilters';
import TeamTable from './TeamTable';
import TeamDetailPanel from './TeamDetailPanel';
import TeamDistribution from './TeamDistribution';

export default function TeamView() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [deptFilter, setDeptFilter] = useState('Alle');
  const [tierFilter, setTierFilter] = useState('Alle');
  const [providerFilter, setProviderFilter] = useState('Alle');
  const [selectedAgent, setSelectedAgent] = useState(null);

  function loadTeam() {
    setLoading(true);
    fetch('/api/team/enriched')
      .then(r => r.ok ? r.json() : fetch('/api/team').then(r2 => r2.json()))
      .then(setData)
      .catch(() => setData(null))
      .finally(() => setLoading(false));
  }

  async function handleRefresh() {
    setRefreshing(true);
    try {
      await fetch('/api/team/refresh', { method: 'POST' });
      loadTeam();
    } catch (_) { /* ignore */ }
    finally { setRefreshing(false); }
  }

  useEffect(() => { loadTeam(); }, []);

  // Dynamic departments from data
  const departments = useMemo(() => {
    if (!data?.agents) return ['Alle'];
    const depts = [...new Set(data.agents.map(a => a.department).filter(Boolean))].sort();
    return ['Alle', ...depts];
  }, [data]);

  // Filtered agents
  const filteredAgents = useMemo(() => {
    if (!data?.agents) return [];
    let agents = data.agents;
    if (deptFilter !== 'Alle') agents = agents.filter(a => a.department === deptFilter);
    if (tierFilter !== 'Alle') agents = agents.filter(a => a.auto_tier === tierFilter);
    if (providerFilter !== 'Alle') agents = agents.filter(a => a.matched_provider === providerFilter);
    return agents;
  }, [data, deptFilter, tierFilter, providerFilter]);

  if (loading) return <p className="text-factory-text-secondary">Lade Team...</p>;
  if (!data) return null;

  const allAgents = data.agents || [];

  return (
    <div className="flex gap-6">
      {/* Main content */}
      <div className="flex-1 min-w-0">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <span className="text-factory-text-secondary text-sm">
            {allAgents.length} Agents via Auto-Discovery
            {data.enrichment_stats && ' — enriched'}
          </span>
          <button
            onClick={handleRefresh}
            disabled={refreshing}
            className="flex items-center gap-1 px-3 py-1 text-xs bg-factory-bg border border-factory-border rounded-lg text-factory-text-secondary hover:text-factory-accent transition-colors disabled:opacity-50"
            title="Agent-Verzeichnisse neu scannen"
          >
            <RefreshCw size={12} className={refreshing ? 'animate-spin' : ''} />
            {refreshing ? 'Scanning...' : 'Refresh'}
          </button>
        </div>

        <TeamSummary summary={data.summary} enrichmentStats={data.enrichment_stats} />

        <TeamFilters
          departments={departments}
          deptFilter={deptFilter}
          onDeptFilter={d => { setDeptFilter(d); setSelectedAgent(null); }}
          tierFilter={tierFilter}
          onTierFilter={setTierFilter}
          providerFilter={providerFilter}
          onProviderFilter={setProviderFilter}
          agents={allAgents}
        />

        <TeamTable
          agents={filteredAgents}
          selectedAgent={selectedAgent}
          onSelectAgent={setSelectedAgent}
        />

        <TeamDistribution enrichmentStats={data.enrichment_stats} />
      </div>

      {/* Detail sidebar */}
      {selectedAgent && (
        <TeamDetailPanel
          agent={selectedAgent}
          onClose={() => setSelectedAgent(null)}
        />
      )}
    </div>
  );
}
