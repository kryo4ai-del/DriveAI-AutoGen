import { Question } from './Question';
import { TrainingSession } from './TrainingSession';
export function createSession(
  sessionId: string,
  questions: Question[]
): TrainingSession {
  if (!sessionId?.trim()) {
    throw new Error('sessionId required');
  }
  if (!Array.isArray(questions) || questions.length === 0) {
    throw new Error('At least one question required');
  }
  return { /* ... */ };
}

export function getRandomQuestions(pool: Question[], count: number): Question[] {
  if (!Array.isArray(pool)) throw new Error('Pool must be array');
  if (!Number.isInteger(count) || count < 0) {
    throw new Error('Count must be non-negative integer');
  }
  // ...
}