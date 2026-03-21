// utils/skillmap.ts

export function getStrongCategories(data: SkillMapData): string[] {
  return data.categories
    .filter(c => [CompetenceLevel.PROFICIENT, CompetenceLevel.EXPERT].includes(c.competenceLevel))
    .map(c => c.category);
}

export function getWeakCategories(data: SkillMapData): string[] {
  return data.categories
    .filter(c => [CompetenceLevel.BEGINNER, CompetenceLevel.DEVELOPING].includes(c.competenceLevel))
    .map(c => c.category);
}
