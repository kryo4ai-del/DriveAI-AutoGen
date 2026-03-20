import { QuestionRepositoryError } from './stubs';
import { Question } from './Question';
export type Result<T, E = QuestionRepositoryError> = 
  | { ok: true; value: T }
  | { ok: false; error: E };

export interface IQuestionRepository {
  getQuestions(): Promise<Result<Question[]>>;
}