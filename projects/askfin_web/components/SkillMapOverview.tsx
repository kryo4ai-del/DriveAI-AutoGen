export function SkillMapOverview({ skillMap, loading }: SkillMapOverviewProps) {
  if (loading) {
    return (
      <div
        role="status"
        aria-live="polite"
        aria-busy="true"
        className="animate-pulse space-y-4"
      >
        <div className="h-8 bg-gray-300 rounded w-1/3" />
        <div className="h-4 bg-gray-300 rounded w-2/3" />
      </div>
    );
  }
  
  if (!skillMap) {
    return (
      <div role="status" className="text-gray-500">
        No skill data available
      </div>
    );
  }

  // ... rest of component
}