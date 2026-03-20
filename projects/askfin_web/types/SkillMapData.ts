export interface SkillMapData {
  categories: CategoryCompetence[];
  overallCompetence: CompetenceLevel;
  // Remove these—calculate in selector/hook instead:
  // strongCategories?: string[];
  // weakCategories?: string[];
}

// utils/skillmap.ts