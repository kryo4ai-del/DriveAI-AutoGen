import { TrainingMode } from './Answer';
import { Question } from './Question';
export interface TrainingSession {
  id: string;
  userId: string;
  mode: TrainingMode;
  category?: QuestionCategory;
  questions: Question[];
  userAnswers: UserAnswer[];
  startedAt: number;
  completedAt?: number;
  score: number;
  totalQuestions: number;
  correctAnswers: number;
}

// Add validation helper (services layer)
export function validateSessionIntegrity(session: TrainingSession): {
  valid: boolean;
  orphanedAnswers: string[]; // questionIds with no matching Question
  unansweredQuestions: string[]; // questionIds with no UserAnswer
} {
  const questionIds = new Set(session.questions.map(q => q.id));
  const answeredIds = new Set(session.userAnswers.map(a => a.questionId));

  const orphanedAnswers = Array.from(answeredIds).filter(
    id => !questionIds.has(id)
  );
  const unansweredQuestions = Array.from(questionIds).filter(
    id => !answeredIds.has(id)
  );

  return {
    valid: orphanedAnswers.length === 0 && unansweredQuestions.length === 0,
    orphanedAnswers,
    unansweredQuestions,
  };
}