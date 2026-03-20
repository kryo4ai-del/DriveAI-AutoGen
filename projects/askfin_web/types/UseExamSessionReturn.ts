// hooks/useExamSession.ts
export interface UseExamSessionReturn {
  session: ExamSession | null;
  // ...
}

// hooks/index.ts
export type { UseExamSessionReturn } from './useExamSession';