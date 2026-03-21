interface SkillMapOverviewProps {
  skillMap: Record<string, unknown>;
}

export function SkillMapOverview({ skillMap }: SkillMapOverviewProps) {
  const weakCategories = getWeakCategories(skillMap);
  // skillMap is required but could be null during loading
}

function getWeakCategories(skillMap: Record<string, unknown>) {
  return [];
}