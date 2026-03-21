import { CompetenceLevel, CompetenceLevelId, CompetenceColor } from '@/types/skillmap';

// Level definitions — type-safe
export const COMPETENCE_LEVELS: Record<CompetenceLevelId, CompetenceLevel> = {
  beginner: {
    id: 'beginner',
    name: 'Beginner',
    color: 'bg-red-500',
    minScore: 0,
    maxScore: 25,
  },
  intermediate: {
    id: 'intermediate',
    name: 'Intermediate',
    color: 'bg-yellow-500',
    minScore: 26,
    maxScore: 50,
  },
  advanced: {
    id: 'advanced',
    name: 'Advanced',
    color: 'bg-blue-500',
    minScore: 51,
    maxScore: 75,
  },
  expert: {
    id: 'expert',
    name: 'Expert',
    color: 'bg-green-500',
    minScore: 76,
    maxScore: 100,
  },
};

/**
 * Normalize score to 0–100 range
 */
export const normalizeScore = (score: number): number => {
  if (typeof score !== 'number') return 0;
  return Math.max(0, Math.min(100, score));
};

/**
 * Get competence level by score
 */
export const getLevelByScore = (score: number): CompetenceLevel => {
  const normalized = normalizeScore(score);
  const level = Object.values(COMPETENCE_LEVELS).find(
    (lvl) => normalized >= lvl.minScore && normalized <= lvl.maxScore
  );
  return level || COMPETENCE_LEVELS.beginner;
};

/**
 * Get color class by level ID
 */
export const getLevelColor = (levelId: CompetenceLevelId): CompetenceColor => {
  return COMPETENCE_LEVELS[levelId]?.color || 'bg-gray-400' as CompetenceColor;
};

/**
 * Get progress bar color by score
 */
export const getProgressBarColor = (score: number): CompetenceColor => {
  const level = getLevelByScore(score);
  return level.color;
};