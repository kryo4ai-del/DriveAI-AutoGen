import type { Question, QuestionCategory } from '@/types/question';
import { validateCategory } from '@/utils/validation';

/**
 * Question service manages question retrieval and filtering.
 * Data is initialized externally via initializeQuestions().
 */

let questionsDatabase: Question[] = [];
let isInitialized = false;

/**
 * Initialize the questions database.
 * Call once at app startup or route entry.
 */
export function initializeQuestions(questions: Question[]): void {
  if (!Array.isArray(questions) || questions.length === 0) {
    throw new Error('Questions array must contain at least one question');
  }
  questionsDatabase = questions;
  isInitialized = true;
}

/**
 * Check if questions are loaded
 */
export function areQuestionsInitialized(): boolean {
  return isInitialized;
}

/**
 * Load all questions (throws if not initialized)
 */

/**
 * Get questions by single category
 */
export function getQuestionsByCategory(
  category: QuestionCategory
): Question[] {
  validateCategory(category);
  return questionsDatabase.filter((q) => q.category === category);
}

/**
 * Get questions by multiple categories
 */
export function getQuestionsByCategories(
  categories: QuestionCategory[]
): Question[] {
  if (!Array.isArray(categories) || categories.length === 0) {
    return [];
  }
  categories.forEach(validateCategory);
  return questionsDatabase.filter((q) =>
    categories.includes(q.category)
  );
}

/**
 * Filter by difficulty
 */
export function getQuestionsByDifficulty(
  difficulty: 'easy' | 'medium' | 'hard'
): Question[] {
  return questionsDatabase.filter((q) => q.difficulty === difficulty);
}

/**
 * Filter by category AND difficulty
 */
export function getQuestionsByFilter(
  category?: QuestionCategory,
  difficulty?: 'easy' | 'medium' | 'hard'
): Question[] {
  return questionsDatabase.filter((q) => {
    if (category && q.category !== category) return false;
    if (difficulty && q.difficulty !== difficulty) return false;
    return true;
  });
}

/**
 * Get single random question from pool
 */
export function getRandomQuestion(pool: Question[]): Question | null {
  return pool.length > 0
    ? pool[Math.floor(Math.random() * pool.length)]
    : null;
}

/**
 * Get N random questions (without replacement)
 */
export function getRandomQuestions(
  pool: Question[],
  count: number
): Question[] {
  if (count < 0) {
    throw new Error('Count must be non-negative');
  }
  if (pool.length === 0) return [];

  const shuffled = [...pool].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, Math.min(count, pool.length));
}

/**
 * Get questions by tag
 */
export function getQuestionsByTag(tag: string): Question[] {
  if (!tag?.trim()) return [];
  return questionsDatabase.filter((q) => q.tags.includes(tag));
}

/**
 * Get all unique categories
 */
export function getAllCategories(): QuestionCategory[] {
  const categories = new Set<QuestionCategory>();
  questionsDatabase.forEach((q) => categories.add(q.category));
  return Array.from(categories).sort();
}

/**
 * Check if question exists
 */
export function questionExists(id: string): boolean {
  return questionsDatabase.some((q) => q.id === id);
}

/**
 * Get question by ID (returns copy)
 */