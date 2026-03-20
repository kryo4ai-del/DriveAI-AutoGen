import { QuestionCategory } from '../types/Answer';
import { CategoryStats } from '../types/CategoryStats';
export interface UserStatistics {
  userId: string;
  totalSessions: number;
  totalQuestionsAnswered: number;
  categoryStats: Record<QuestionCategory, CategoryStats>;
  lastSessionAt?: number;
  streakDays: number;
  
  // REMOVED: overallAccuracy (derive it instead)
}

// Calculate on-demand
export function getOverallAccuracy(stats: UserStatistics): number {
  const totalCorrect = Object.values(stats.categoryStats).reduce(
    (sum, cat) => sum + cat.correctAnswers,
    0
  );
  const totalAnswered = Object.values(stats.categoryStats).reduce(
    (sum, cat) => sum + cat.questionsAnswered,
    0
  );
  return totalAnswered > 0 ? totalCorrect / totalAnswered : 0;
}