import { TIER_STYLES, TIER_OPTIONS, PROVIDER_STYLES } from './team-utils';

export default function TeamFilters({
  departments, deptFilter, onDeptFilter,
  tierFilter, onTierFilter,
  providerFilter, onProviderFilter,
  agents,
}) {
  const deptCounts = {};
  agents.forEach(a => {
    const d = a.department || 'Unbekannt';
    deptCounts[d] = (deptCounts[d] || 0) + 1;
  });

  const providerOptions = ['Alle',
    ...new Set(agents.map(a => a.matched_provider).filter(Boolean))
  ].sort();

  return (
    <div className="space-y-3 mb-4">
      {/* Department row */}
      <div className="flex gap-2 flex-wrap">
        {departments.map(d => {
          const count = d === 'Alle' ? agents.length : (deptCounts[d] || 0);
          return (
            <FilterBtn key={d} active={deptFilter === d} onClick={() => onDeptFilter(d)}>
              {d} ({count})
            </FilterBtn>
          );
        })}
      </div>

      {/* Tier + Provider row */}
      <div className="flex gap-4 items-center flex-wrap">
        <div className="flex gap-1 items-center">
          <span className="text-xs text-factory-text-secondary mr-1">Tier:</span>
          {TIER_OPTIONS.map(t => (
            <FilterBtn key={t} active={tierFilter === t} onClick={() => onTierFilter(t)} small>
              {t === 'Alle' ? 'Alle' : (TIER_STYLES[t]?.label || t)}
            </FilterBtn>
          ))}
        </div>
        <div className="w-px h-5 bg-factory-border" />
        <div className="flex gap-1 items-center">
          <span className="text-xs text-factory-text-secondary mr-1">Provider:</span>
          {providerOptions.map(p => (
            <FilterBtn key={p} active={providerFilter === p} onClick={() => onProviderFilter(p)} small>
              {p === 'Alle' ? 'Alle' : (PROVIDER_STYLES[p]?.label || p)}
            </FilterBtn>
          ))}
        </div>
      </div>
    </div>
  );
}

function FilterBtn({ active, onClick, children, small }) {
  return (
    <button onClick={onClick}
      className={`rounded-lg text-xs transition-colors ${
        active
          ? 'bg-factory-accent text-factory-bg font-medium'
          : 'bg-factory-surface text-factory-text-secondary hover:text-factory-text'
      } ${small ? 'px-2 py-1' : 'px-4 py-2'}`}>
      {children}
    </button>
  );
}
