import { DifficultyLevel } from './DifficultyLevel';
/**
 * TrainingMode Types for DriveAI Web
 * Foundational type definitions for the driving exam training system
 */

// ============================================================================
// ENUMS
// ============================================================================

/**
 * Training mode selection for the user
 */
export enum TrainingMode {
  DAILY = "daily",
  TOPIC = "topic",
  WEAKNESS = "weakness",
}

/**
 * German driving exam question categories (StVO)
 */
export enum QuestionCategory {
  VORFAHRT = "vorfahrt", // Right of way
  VERKEHRSZEICHEN = "verkehrszeichen", // Traffic signs
  TECHNIK = "technik", // Vehicle technology
  VERHALTEN = "verhalten", // Behavior/conduct
  UMWELT = "umwelt", // Environmental/ecological
  ERSTE_HILFE = "erste_hilfe", // First aid
  GEFAHRENERKENNUNG = "gefahrenerkennung", // Hazard perception
}

/**
 * Difficulty level for filtering and progression
 */

// ============================================================================
// INTERFACES
// ============================================================================

/**
 * Single multiple-choice answer option
 */
export interface Answer {
  id: string;
  text: string;
}

/**
 * Exam question with metadata
 */

/**
 * User's response to a question
 */

/**
 * Session result aggregation
 */

/**
 * User weakness/performance data
 */

/**
 * Question repository interface for data access
 */

/**
 * Training configuration
 */
export interface TrainingConfig {
  mode: TrainingMode;
  category?: QuestionCategory;
  difficulty?: DifficultyLevel;
  questionCount: number;
  timerEnabled: boolean;
  timePerQuestion?: number; // seconds
}

/**
 * Statistics for user progression tracking
 */

/**
 * Per-category statistics
 */

/**
 * API response wrapper (optional, for consistency)
 */