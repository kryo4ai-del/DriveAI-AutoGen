export interface UserAnswer {
  questionId: string;
  selectedAnswerIndex: number; // Must be 0 <= index < answers.length
  isCorrect: boolean;
  timestamp: number;
  sessionId: string;
  timeSpent?: number;
  skipped?: boolean;
}

// Add runtime validator (services layer)
export function isValidAnswerIndex(
  answerIndex: number,
  answerCount: number
): boolean {
  return answerIndex >= 0 && answerIndex < answerCount;
}