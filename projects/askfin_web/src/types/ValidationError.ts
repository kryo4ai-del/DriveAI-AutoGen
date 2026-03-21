export interface ValidationError {
  category: string;
  error: string;
}

export function buildSkillMap(categories: CategoryCompetence[]): {
  skillMap: SkillMapData | null;
  errors: ValidationError[];
} {
  const errors: ValidationError[] = [];
  const validCategories: CategoryCompetence[] = [];

  categories.forEach(cat => {
    const error = validateCategoryCompetence(cat);
    if (error) {
      errors.push(error);
    } else {
      validCategories.push(cat);
    }
  });

  if (validCategories.length === 0) {
    return { skillMap: null, errors };
  }

  return {
    skillMap: {
      categories: validCategories,
      overallCompetence: calculateOverallCompetence(validCategories),
      generatedAt: new Date(),
    },
    errors,
  };
}