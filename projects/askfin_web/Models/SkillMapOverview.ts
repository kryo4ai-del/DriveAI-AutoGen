export function SkillMapOverview({ skillMap }: SkillMapOverviewProps) {
  const weakCategories = getWeakCategories(skillMap); // ❌ No null check in prop
  // skillMap is required but could be null during loading