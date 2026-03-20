export interface WeaknessData {
  category: QuestionCategory;
  correctAnswers: number;
  attemptCount: number;
  lastAttemptedAt: number;
}

export function getWeaknessRate(data: WeaknessData): number {
  return data.attemptCount > 0 ? data.correctAnswers / data.attemptCount : 0;
}