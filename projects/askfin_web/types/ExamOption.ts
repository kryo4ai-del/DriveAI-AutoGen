// types/exam.ts

export enum ExamState {
  NOT_STARTED = "NOT_STARTED",
  IN_PROGRESS = "IN_PROGRESS",
  COMPLETED = "COMPLETED",
  REVIEWING = "REVIEWING",
}

// Validation constants
export const EXAM_CONFIG = {
  MIN_QUESTIONS: 10,
  MAX_QUESTIONS: 100,
  MIN_DURATION_MS: 60000,
  MAX_DURATION_MS: 10800000,
  DEFAULT_PASSING_SCORE: 70,
} as const;

export interface ExamOption {
  id: string;
  text: string;
}
