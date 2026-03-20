export function selectAdaptiveQuestions(
  userWeaknesses: CategoryWeakness[],
  totalQuestions: number
): Question[] {
  if (userWeaknesses.length === 0) {
    return getRandomQuestions([], totalQuestions);
  }

  const weakThreshold = 50;
  const weakPercentage = 0.6;

  const ranked = rankCategoriesByWeakness(userWeaknesses);
  const weak = ranked.filter(w => w.weaknessScore > weakThreshold);
  const strong = ranked.filter(w => w.weaknessScore <= weakThreshold);

  const weakCount = Math.ceil(totalQuestions * weakPercentage);
  const strongCount = totalQuestions - weakCount;

  const weakQuestions = weak.length > 0
    ? weak.flatMap(w =>
        getRandomQuestions(
          getQuestionsByCategory(w.category),
          Math.ceil(weakCount / weak.length)
        )
      )
    : [];

  const strongQuestions = strong.length > 0
    ? strong.flatMap(s =>
        getRandomQuestions(
          getQuestionsByCategory(s.category),
          Math.ceil(strongCount / strong.length)
        )
      )
    : getRandomQuestions([], strongCount);

  return [...weakQuestions, ...strongQuestions]
    .slice(0, totalQuestions)
    .filter(Boolean);
}