import { QuestionCategory } from './Answer';
import { DifficultyLevel } from './DifficultyLevel';
export interface CategoryStats {
  category: QuestionCategory;
  questionsAnswered: number;
  correctAnswers: number;
  accuracy: number;
  lastReviewedAt?: number;
  recommendedDifficulty?: DifficultyLevel; // User's recommended next level
  // OR
  attemptedDifficulties?: DifficultyLevel[]; // Levels user has attempted
}