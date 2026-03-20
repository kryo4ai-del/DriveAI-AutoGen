export function validateCategoryCompetence(cat: CategoryCompetence): void {
  if (cat.correctAnswers < 0 || cat.totalAnswered < 0) {
    throw new Error(`Negative values...`); // ❌ Throws synchronously
  }
  if (cat.correctAnswers > cat.totalAnswered) {
    throw new Error(`Invalid ratio...`); // ❌ No recovery path
  }
}

// In buildSkillMap:
categories.forEach(validateCategoryCompetence); // ❌ Stops on first error