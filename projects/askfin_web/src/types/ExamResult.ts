/**
 * Exam result snapshot (immutable)
 */
export interface ExamResult {
  readonly id: string; // unique result ID
  readonly sessionId: string;
  readonly score: number; // 0–100
  readonly passingScore: number;
  readonly totalQuestions: number;
  readonly correctAnswers: number;
  readonly categoryBreakdown: readonly CategoryBreakdown[];
  readonly passed: boolean;
  readonly completedAt: number;
  readonly timeSpent: number;
}

/**
 * Factory to safely create ExamResult
 */
export function createExamResult(
  sessionId: string,
  answers: Record<string, string>,
  questions: ExamQuestion[],
  timeSpent: number,
  passingScore: number = EXAM_DEFAULTS.PASSING_SCORE
): ExamResult {
  const correctAnswers = Object.entries(answers).filter(
    ([qId, aId]) =>
      questions.find((q) => q.id === qId)?.correctAnswerId === aId
  ).length;

  const score = Math.round((correctAnswers / questions.length) * 100);
  const categoryBreakdown = computeCategoryBreakdown(questions, answers);

  return {
    id: `result_${Date.now()}_${Math.random()}`, // or UUID
    sessionId,
    score,
    passingScore,
    totalQuestions: questions.length,
    correctAnswers,
    categoryBreakdown,
    passed: score >= passingScore,
    completedAt: Date.now(),
    timeSpent,
  };
}

function computeCategoryBreakdown(
  questions: ExamQuestion[],
  answers: Record<string, string>
): CategoryBreakdown[] {
  const byCategory = questions.reduce(
    (acc, q) => {
      if (!acc[q.category]) {
        acc[q.category] = { correct: 0, total: 0 };
      }
      acc[q.category].total++;
      if (answers[q.id] === q.correctAnswerId) {
        acc[q.category].correct++;
      }
      return acc;
    },
    {} as Record<string, { correct: number; total: number }>
  );

  return Object.entries(byCategory).map(([category, { correct, total }]) => ({
    category,
    correct,
    total,
    percentage: Math.round((correct / total) * 100),
  }));
}