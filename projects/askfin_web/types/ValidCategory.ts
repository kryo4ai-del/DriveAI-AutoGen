/**
 * Shared validation utilities
 */

export function validateSessionId(id: string): void {
  if (!id?.trim()) {
    throw new Error('Session ID is required and cannot be empty');
  }
}

export function validateQuestionArray(questions: unknown[]): void {
  if (!Array.isArray(questions)) {
    throw new Error('Questions must be an array');
  }
  if (questions.length === 0) {
    throw new Error('At least one question is required');
  }
}

export function validateAnswerInput(answer: string): void {
  if (!answer?.trim()) {
    throw new Error('Answer cannot be empty');
  }
}

export function validateTimeSpent(ms: number): void {
  if (!Number.isInteger(ms) || ms < 0) {
    throw new Error('Time spent must be a non-negative integer');
  }
}

export function validateQuestionCount(count: number): void {
  if (!Number.isInteger(count) || count < 0) {
    throw new Error('Question count must be a non-negative integer');
  }
}

export type ValidCategory = import('@/types/question').QuestionCategory;

const VALID_CATEGORIES: ValidCategory[] = [
  'traffic-signals',
  'speed-limits',
  'vehicle-operation',
  'safe-driving',
  'emergency-procedures',
  'parking',
  'right-of-way',
  'road-signs',
];

export function isValidCategory(value: unknown): value is ValidCategory {
  return VALID_CATEGORIES.includes(value as ValidCategory);
}

export function validateCategory(value: unknown): asserts value is ValidCategory {
  if (!isValidCategory(value)) {
    throw new Error(`Invalid category: ${value}`);
  }
}