import { Question } from '../src/types/Question';
import { UserAnswer } from '../src/hooks/UserAnswer';
export function assertValidQuestion(q: unknown): asserts q is Question { /* ... */ }
   export function assertValidUserAnswer(ua: unknown): asserts ua is UserAnswer { /* ... */ }