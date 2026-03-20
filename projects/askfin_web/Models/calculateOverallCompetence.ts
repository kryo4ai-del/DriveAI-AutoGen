export function calculateOverallCompetence(categories: CategoryCompetence[]): CompetenceLevel {
  if (categories.length === 0) return CompetenceLevel.BEGINNER;

  const competenceLevelWeights: Record<CompetenceLevel, number> = {
    [CompetenceLevel.BEGINNER]: 1,
    [CompetenceLevel.DEVELOPING]: 2,
    [CompetenceLevel.COMPETENT]: 3,
    [CompetenceLevel.PROFICIENT]: 4,
    [CompetenceLevel.EXPERT]: 5,
  };

  // Weight by practice volume (totalAnswered)
  const totalWeight = categories.reduce(
    (sum, cat) => sum + competenceLevelWeights[cat.competenceLevel] * cat.totalAnswered,
    0
  );
  const totalQuestions = categories.reduce((sum, cat) => sum + cat.totalAnswered, 0);

  if (totalQuestions === 0) return CompetenceLevel.BEGINNER;

  const weightedAverage = totalWeight / totalQuestions;
  
  if (weightedAverage < 1.5) return CompetenceLevel.BEGINNER;
  if (weightedAverage < 2.5) return CompetenceLevel.DEVELOPING;
  if (weightedAverage < 3.5) return CompetenceLevel.COMPETENT;
  if (weightedAverage < 4.5) return CompetenceLevel.PROFICIENT;
  return CompetenceLevel.EXPERT;
}