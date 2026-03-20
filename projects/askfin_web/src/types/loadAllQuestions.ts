import type { Question, QuestionCategory, DifficultyLevel } from '@/types/question';
import { QuestionCategory } from './Answer';
import { DifficultyLevel } from './DifficultyLevel';

// Mock data — replace with actual JSON import or API call
const QUESTIONS_DATABASE: Question[] = [
  {
    id: 'q1',
    text: 'What does a red traffic light mean?',
    category: 'traffic-signals',
    difficulty: 'easy',
    correctAnswer: 'Stop',
    options: ['Stop', 'Proceed with caution', 'Speed up', 'Turn right'],
    explanation: 'A red light means you must come to a complete stop.',
    tags: ['essential', 'safety'],
  },
  {
    id: 'q2',
    text: 'What is the speed limit in residential areas?',
    category: 'speed-limits',
    difficulty: 'easy',
    correctAnswer: '25 mph',
    options: ['15 mph', '25 mph', '35 mph', '45 mph'],
    explanation: 'Most residential areas have a 25 mph speed limit.',
    tags: ['essential'],
  },
  {
    id: 'q3',
    text: 'When should you use your headlights?',
    category: 'vehicle-operation',
    difficulty: 'medium',
    correctAnswer: 'At dawn, dusk, and night',
    options: [
      'Only at night',
      'At dawn, dusk, and night',
      'Only during rain',
      'Never during the day',
    ],
    explanation: 'Headlights should be on during reduced visibility conditions.',
    tags: ['safety'],
  },
  {
    id: 'q4',
    text: 'What is the proper distance to maintain from other vehicles?',
    category: 'safe-driving',
    difficulty: 'medium',
    correctAnswer: '3+ seconds',
    options: ['1 second', '2 seconds', '3+ seconds', 'No specific rule'],
    explanation: 'Maintain at least a 3-second following distance.',
    tags: ['safety', 'essential'],
  },
  {
    id: 'q5',
    text: 'How should you handle a skid on wet pavement?',
    category: 'emergency-procedures',
    difficulty: 'hard',
    correctAnswer: 'Steer in the direction you want the front to go',
    options: [
      'Brake hard immediately',
      'Steer in the direction you want the front to go',
      'Turn the wheel sharply',
      'Accelerate to regain traction',
    ],
    explanation:
      'During a skid, steer in the direction you want the front wheels to go.',
    tags: ['safety'],
  },
];

/**
 * Load all questions from database
 */
export function loadAllQuestions(): Question[] {
  return [...QUESTIONS_DATABASE];
}

/**
 * Filter questions by single category
 */
export function getQuestionsByCategory(
  category: QuestionCategory
): Question[] {
  return QUESTIONS_DATABASE.filter((q) => q.category === category);
}

/**
 * Filter questions by multiple categories
 */
export function getQuestionsByCategories(
  categories: QuestionCategory[]
): Question[] {
  return QUESTIONS_DATABASE.filter((q) =>
    categories.includes(q.category)
  );
}

/**
 * Filter questions by difficulty level
 */
export function getQuestionsByDifficulty(
  difficulty: DifficultyLevel
): Question[] {
  return QUESTIONS_DATABASE.filter((q) => q.difficulty === difficulty);
}

/**
 * Get questions that match category AND difficulty
 */
export function getQuestionsByFilter(
  category?: QuestionCategory,
  difficulty?: DifficultyLevel
): Question[] {
  return QUESTIONS_DATABASE.filter((q) => {
    if (category && q.category !== category) return false;
    if (difficulty && q.difficulty !== difficulty) return false;
    return true;
  });
}

/**
 * Get a random question from a pool
 */
export function getRandomQuestion(pool: Question[]): Question | null {
  if (pool.length === 0) return null;
  return pool[Math.floor(Math.random() * pool.length)];
}

/**
 * Get N random questions from a pool (without replacement)
 */
export function getRandomQuestions(
  pool: Question[],
  count: number
): Question[] {
  if (pool.length === 0) return [];
  const shuffled = [...pool].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, Math.min(count, pool.length));
}

/**
 * Get questions by tag
 */
export function getQuestionsByTag(tag: string): Question[] {
  return QUESTIONS_DATABASE.filter((q) => q.tags.includes(tag));
}

/**
 * Get unique categories from all questions
 */
export function getAllCategories(): QuestionCategory[] {
  const categories = new Set<QuestionCategory>();
  QUESTIONS_DATABASE.forEach((q) => categories.add(q.category));
  return Array.from(categories);
}

/**
 * Check if a question ID exists
 */
export function questionExists(id: string): boolean {
  return QUESTIONS_DATABASE.some((q) => q.id === id);
}

/**
 * Get question by ID
 */