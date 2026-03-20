import { CategoryCompetence, CompetenceLevel, SkillMapData } from '@/types/skillmap';

/**
 * Calculate accuracy percentage for a category
 * @param correct - Number of correct answers
 * @param total - Total questions answered
 * @returns Percentage (0-100), or 0 if no questions answered
 */
export function calculateAccuracy(correct: number, total: number): number {
  return total === 0 ? 0 : Math.round((correct / total) * 100);
}

/**
 * Validate category competence data
 * Ensures correctAnswers ≤ totalAnswered and values are non-negative
 * @throws Error if validation fails
 */

/**
 * Get categories where user shows strength (PROFICIENT or EXPERT)
 */

/**
 * Get categories needing improvement (BEGINNER or DEVELOPING)
 */
export function getWeakCategories(data: SkillMapData): string[] {
  return data.categories
    .filter((c) => [CompetenceLevel.BEGINNER, CompetenceLevel.DEVELOPING].includes(c.competenceLevel))
    .map((c) => c.category);
}

/**
 * Calculate weighted overall competence from categories
 * Uses competence level weights: BEGINNER=1, DEVELOPING=2, COMPETENT=3, PROFICIENT=4, EXPERT=5
 */

/**
 * Build and validate a SkillMapData object
 * Validates all categories and computes overall competence
 */
export function buildSkillMap(categories: CategoryCompetence[]): SkillMapData {
  categories.forEach(validateCategoryCompetence);

  return {
    categories,
    overallCompetence: calculateOverallCompetence(categories),
    generatedAt: new Date(),
  };
}