import { SkillCategory, SortOption, FilterOption } from '@/types/skillmap';

/**
 * Calculate completion progress for a category (0-1)
 * Safely handles edge cases: missing data, zero total skills, over-completion
 */
export function calculateProgress(category: SkillCategory): number {
  const { completedSkills = 0, totalSkills = 0 } = category;

  if (totalSkills <= 0) {
    return 0; // No skills = 0% progress
  }

  return Math.min(completedSkills / totalSkills, 1); // Cap at 100%
}

/**
 * Get safe proficiency value (0-1, defaults to 0)
 */
export function getProficiency(category: SkillCategory): number {
  const value = category.averageProficiency ?? 0;
  return Math.max(0, Math.min(value, 1)); // Clamp to [0, 1]
}

/**
 * Sort categories by specified option
 * Returns new array, does not mutate input
 */
export function sortCategories(
  categories: SkillCategory[],
  sortBy: SortOption
): SkillCategory[] {
  const sorted = [...categories];

  switch (sortBy) {
    case 'proficiency':
      return sorted.sort((a, b) => getProficiency(b) - getProficiency(a));

    case 'name':
      return sorted.sort((a, b) => a.name.localeCompare(b.name));

    case 'progress':
      return sorted.sort((a, b) => calculateProgress(b) - calculateProgress(a));

    case 'recent':
      return sorted.sort((a, b) => {
        const timeA = new Date(a.lastUpdated ?? '').getTime() || 0;
        const timeB = new Date(b.lastUpdated ?? '').getTime() || 0;
        return timeB - timeA;
      });

    default:
      return sorted;
  }
}

/**
 * Filter categories by proficiency or completion level
 * Input array should already be sorted
 */
export function filterCategories(
  categories: SkillCategory[],
  filterBy: FilterOption
): SkillCategory[] {
  switch (filterBy) {
    case 'mastered':
      return categories.filter((cat) => getProficiency(cat) >= 0.8);

    case 'learning':
      return categories.filter((cat) => {
        const prof = getProficiency(cat);
        return prof >= 0.3 && prof < 0.8;
      });

    case 'beginner':
      return categories.filter((cat) => getProficiency(cat) < 0.3);

    case 'incomplete':
      return categories.filter(
        (cat) => (cat.completedSkills ?? 0) < (cat.totalSkills ?? 1)
      );

    case 'all':
    default:
      return categories;
  }
}