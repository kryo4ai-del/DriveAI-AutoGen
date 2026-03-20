export interface Question {
  id: string;
  text: string;
  category: QuestionCategory;
  difficulty: DifficultyLevel;
  answers: Answer[];
  correctAnswerIndex: number;
  explanation: string;
  imageUrl?: string;
  tags?: string[];
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

// Add validator
export function validateQuestion(q: Question): {
  valid: boolean;
  errors: string[];
} {
  const errors: string[] = [];

  if (!q.id) errors.push("Missing question ID");
  if (q.answers.length === 0) errors.push("Question has no answers");
  if (q.correctAnswerIndex < 0 || q.correctAnswerIndex >= q.answers.length) {
    errors.push(
      `correctAnswerIndex ${q.correctAnswerIndex} out of range [0, ${q.answers.length - 1}]`
    );
  }

  const answerIds = new Set(q.answers.map(a => a.id));
  if (answerIds.size !== q.answers.length) {
    errors.push("Duplicate answer IDs detected");
  }

  return { valid: errors.length === 0, errors };
}