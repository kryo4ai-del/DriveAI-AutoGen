import { Question } from './Question';
import { UserAnswer } from '../hooks/UserAnswer';
export function assertValidQuestion(q: unknown): asserts q is Question { /* ... */ }
   export function assertValidUserAnswer(ua: unknown): asserts ua is UserAnswer { /* ... */ }