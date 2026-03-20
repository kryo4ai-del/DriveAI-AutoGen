// types/exam.ts

/**
 * Exam Configuration
 */
export const EXAM_DEFAULTS = {
  QUESTION_COUNT: { min: 10, max: 100, default: 50 },
  DURATION_MS: { min: 60000, max: 10800000, default: 3600000 },
  PASSING_SCORE: 70,
} as const;

export interface ExamStartConfig {
  questionCount: number;
  duration: number;
  categories?: string[];
  passingScore?: number;
}

/**
 * State Machine
 */
export enum ExamState {
  NOT_STARTED = "NOT_STARTED",
  IN_PROGRESS = "IN_PROGRESS",
  COMPLETED = "COMPLETED",
  REVIEWING = "REVIEWING",
}

  from: ExamState,
  to: ExamState
): boolean {
  const validTransitions: Record<ExamState, ExamState[]> = {
    [ExamState.NOT_STARTED]: [ExamState.IN_PROGRESS],
    [ExamState.IN_PROGRESS]: [ExamState.COMPLETED, ExamState.REVIEWING],
    [ExamState.COMPLETED]: [ExamState.REVIEWING],
    [ExamState.REVIEWING]: [ExamState.IN_PROGRESS, ExamState.COMPLETED],
  };
  return validTransitions[from]?.includes(to) ?? false;
}

/**
 * Questions
 */

/**
 * Sessions
 */
export type AnswerMap = Record<string, string>;

/**
 * Results
 */

/**
 * Repository
 */
export class ExamRepositoryError extends Error {
  constructor(
    public code: "NOT_FOUND" | "INVALID_STATE" | "VALIDATION_FAILED",
    message: string
  ) {
    super(message);
    this.name = "ExamRepositoryError";
  }
}

/**
 * Utilities
 */

export function getElapsedTime(window: TimeWindow): number {
  return (window.endTime ?? Date.now()) - window.startTime;
}

export function isTimeExpired(
  startTime: number,
  duration: number
): boolean {
  return Date.now() - startTime > duration;
}

export function createExamResult(
  sessionId: string,
  answers: AnswerMap,
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
    id: `result_${Date.now()}_${Math.random()}`,
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
  answers: AnswerMap
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