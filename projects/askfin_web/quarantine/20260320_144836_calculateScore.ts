export function calculateScore(session: TrainingSession): SessionScore {
  const categoryBreakdown: Record<QuestionCategory, number> = {};

  // Initialize all categories
  session.questions.forEach(q => {
    if (!categoryBreakdown[q.category]) {
      categoryBreakdown[q.category] = 0;
    }
  });

  // Count correct per category
  const categoryCounts = session.questions.reduce(
    (acc, q) => {
      if (!acc[q.category]) acc[q.category] = { correct: 0, total: 0 };
      acc[q.category].total++;

      const answer = session.answers.find(a => a.questionId === q.id);
      if (answer?.isCorrect) acc[q.category].correct++;

      return acc;
    },
    {} as Record<QuestionCategory, { correct: number; total: number }>
  );

  // Calculate accuracy once per category
  Object.entries(categoryCounts).forEach(([category, { correct, total }]) => {
    categoryBreakdown[category as QuestionCategory] =
      total > 0 ? Math.round((correct / total) * 10000) / 100 : 0;
  });

  return {
    totalQuestions: session.questions.length,
    correctAnswers: session.answers.filter(a => a.isCorrect).length,
    accuracy: Math.round(
      (session.answers.filter(a => a.isCorrect).length / 
       session.questions.length) * 10000
    ) / 100,
    totalTimeMs: session.answers.reduce((sum, a) => sum + a.timeSpentMs, 0),
    averageTimePerQuestion: session.answers.length > 0
      ? Math.round(
          session.answers.reduce((sum, a) => sum + a.timeSpentMs, 0) /
          session.answers.length * 100
        ) / 100
      : 0,
    categoryBreakdown,
  };
}