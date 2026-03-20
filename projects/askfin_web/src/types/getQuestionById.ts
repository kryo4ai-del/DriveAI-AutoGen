import { Question } from './Question';
import { QUESTIONS_DATABASE } from './stubs';
export function getQuestionById(id: string): Question | null {
  const question = QUESTIONS_DATABASE.find((q) => q.id === id);
  return question ? { ...question } : null;
}