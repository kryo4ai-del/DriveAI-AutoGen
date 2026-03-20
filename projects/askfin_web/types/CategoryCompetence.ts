/**
 * Competence level enum for skill assessment
 * Represents proficiency stages from beginner to expert
 */
export enum CompetenceLevel {
  BEGINNER = 'BEGINNER',
  DEVELOPING = 'DEVELOPING',
  COMPETENT = 'COMPETENT',
  PROFICIENT = 'PROFICIENT',
  EXPERT = 'EXPERT',
}

/**
 * Represents competence data for a single driving skill category
 */
export interface CategoryCompetence {
  /** Unique identifier for the category */
  category: string;

  /** Current competence level */
  competenceLevel: CompetenceLevel;

  /** Total questions answered in this category */
  totalAnswered: number;

  /** Number of correct answers in this category */
  correctAnswers: number;

  /** Last practice session (ISO 8601 format) */
  lastPracticed: Date;
}

/**
 * Aggregate skill map data across all categories
 * NOTE: strongCategories and weakCategories are derived—compute via utils
 */