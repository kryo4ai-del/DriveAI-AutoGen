export interface TrainingSessionResult {
  correctCount: number;
  totalQuestions: number;
  completedAt?: string;
  weaknessAreas?: string[];
}
