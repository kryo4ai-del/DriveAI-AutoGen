import { Question } from './Question';
import { QuestionCategory } from './Answer';
export interface QuestionRepository {
  getQuestions(limit?: number): Promise<Question[]>;
  getQuestionsByCategory(
    category: QuestionCategory,
    limit?: number
  ): Promise<Question[]>;
  getWeakQuestions(
    userAnswers: UserAnswer[],
    options?: { limit?: number; threshold?: number }
  ): Promise<Question[]>;
}