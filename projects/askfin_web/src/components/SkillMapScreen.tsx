// ADD to SkillMapScreen
interface SkillMapScreenProps {
  data?: SkillMapData | null;
  isLoading?: boolean;
  error?: string | null;
}

export function SkillMapScreen({
  data,
  isLoading = false,
  error = null,
}: SkillMapScreenProps) {
  if (isLoading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {[...Array(6)].map((_, i) => (
          <div key={i} className="h-64 bg-gray-200 rounded-lg animate-pulse" />
        ))}
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-red-800">
        <h3 className="font-bold">Failed to load skill map</h3>
        <p className="text-sm mt-2">{error}</p>
      </div>
    );
  }

  if (!data || !validateSkillMapData(data)) {
    return <div className="text-gray-600 p-6">No skill data available</div>;
  }

  // ... rest of component
}